import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

enum RepeatMode { off, all, one }

/// just_audio + audio_service wrapper. Owns the playback queue and
/// index, handles notification button presses, auto-advance and repeat.
/// The player controller tells it what to play and observes callbacks.
class AudioEngine extends BaseAudioHandler {
  AudioPlayer _player = AudioPlayer();

  /// Second player used for crossfading: the next song starts on it (at
  /// volume 0) while the current one fades out, then the roles swap.
  AudioPlayer _aux = AudioPlayer();

  StreamSubscription<PlaybackEvent>? _eventSub;
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<ProcessingState>? _procSub;

  /// Live position is driven by this ticker (not just_audio's
  /// positionStream, which can be coarse/quirky on some platforms): it reads
  /// `_player.position` (itself extrapolated from the last playback event)
  /// at a fixed ~200ms cadence while playing.
  static const _tickInterval = Duration(milliseconds: 200);

  Timer? _ticker;
  int _tickCount = 0;

  List<MediaItem> _queue = [];
  List<int> _order = [];
  int _seq = -1;
  RepeatMode _repeat = RepeatMode.off;

  /// Zero = crossfade off. Otherwise forward transitions overlap the next
  /// song with the tail of the current one over this duration.
  Duration _crossfade = const Duration(seconds: 4);

  bool _crossfading = false;
  Future<void>? _fadeFuture;

  /// True while we expect the active player to be playing a loaded source.
  /// An idle state while this is set means playback failed (expired stream
  /// URL, HTTP 403, network drop) rather than a user/engine-requested stop.
  bool _activePlayback = false;

  /// Fired whenever the active queue index changes (song started).
  void Function(int queueIndex)? onSongChanged;

  /// Fired when the queue ends with repeat off.
  void Function()? onQueueEnded;

  /// Fired once when a track plays to its natural end, before advancing.
  void Function(int queueIndex)? onTrackCompleted;

  /// Fired when loading/playing a song fails (expired URL, network...).
  void Function(int queueIndex, Object error)? onLoadError;

  /// Called lazily to obtain a playable source for a queue item (stream URLs
  /// expire, so they are resolved per play and cached for the session).
  Future<({String url, Map<String, String> headers})> Function(int queueIndex)?
      resolver;

  final Map<String, ({String url, Map<String, String> headers})> _urls = {};

  AudioEngine() {
    // Note: do NOT pipe the event stream into playbackState with
    // `addStream`/`pipe` — the position ticker's `add()` would then race the
    // addStream pump ("cannot add items while items are being added from
    // addStream") and silently drop position updates.
    _attach(_player);
  }

  void _attach(AudioPlayer p) {
    // Cancel any previous subscriptions first: crossfades swap the active
    // player, and attaching twice would leak the old listeners.
    _detach();
    _eventSub = p.playbackEventStream.listen(_onPlaybackEvent);
    _stateSub = p.playerStateStream.listen(_onPlayerState);
    _procSub = p.processingStateStream.listen(_onProcessingState);
  }

  void _detach() {
    _eventSub?.cancel();
    _stateSub?.cancel();
    _procSub?.cancel();
    _ticker?.cancel();
    _ticker = null;
  }

  void _onPlaybackEvent(PlaybackEvent event) {
    playbackState.add(_transformEvent(event));
  }

  // ---- public surface for the controller ----

  bool get playing => _player.playing;
  Duration get position => _player.position;
  int get currentIndex => _seq >= 0 && _seq < _order.length ? _order[_seq] : -1;
  MediaItem? get currentMediaItem =>
      currentIndex >= 0 && currentIndex < _queue.length ? _queue[currentIndex] : null;
  RepeatMode get repeatMode => _repeat;

  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<ProcessingState> get processingStateStream => _player.processingStateStream;
  Stream<PlaybackState> get stateStream => playbackState;

  void setCrossfade(Duration duration) {
    _crossfade = duration.isNegative ? Duration.zero : duration;
  }

  void setRepeat(RepeatMode mode) {
    _repeat = mode;
    _player.setLoopMode(mode == RepeatMode.one ? LoopMode.one : LoopMode.off);
  }

  /// Replaces the queue. [startAt] is a queue index; [order] is the playback
  /// sequence as queue indices (shuffle permutation). With [reload] false the
  /// currently playing song keeps playing and only the queue/order swap.
  Future<void> setQueue(
    List<MediaItem> items, {
    int? startAt,
    List<int>? order,
    bool autoPlay = true,
    bool reload = true,
  }) async {
    // Capture the currently playing *queue* index before replacing the
    // order. The old code computed it after assigning `_order`, so swapping
    // in a new shuffle permutation pointed `_seq` at an unrelated song.
    final previousQueueIndex = currentIndex;

    _queue = List.of(items);
    _order = List.of(order ?? List.generate(items.length, (i) => i));
    if (_order.length != items.length ||
        _order.toSet().length != items.length ||
        _order.any((i) => i < 0 || i >= items.length)) {
      // A stale shuffle permutation from the controller must never make the
      // engine index out of bounds.
      _order = List.generate(items.length, (i) => i);
    }
    _publishQueue();
    _urls.clear();
    if (items.isEmpty) {
      _seq = -1;
      mediaItem.add(null);
      return;
    }
    if (reload) {
      final start = (startAt ?? 0).clamp(0, items.length - 1);
      await _load(start, autoPlay: autoPlay);
    } else {
      // The controller has already adjusted its current index for any queue
      // insertion/removal. Prefer that explicit startAt over our own previous
      // queue index: removing an item before the current song shifts every
      // later index, so the old index would point at the wrong track and the
      // engine would silently jump to its neighbour.
      final keep = startAt != null && _order.contains(startAt)
          ? startAt
          : previousQueueIndex >= 0 && _order.contains(previousQueueIndex)
              ? previousQueueIndex
              : -1;
      _seq = keep >= 0 ? _order.indexOf(keep) : -1;
      if (keep >= 0) {
        mediaItem.add(_queue[keep]);
      }
      // Keep the media session's queue position in sync with reorder/insert
      // operations; otherwise notification/lock-screen controls show a stale
      // index until the next playback event.
      playbackState.add(playbackState.value.copyWith(
        queueIndex: currentIndex >= 0 ? currentIndex : null,
      ));
    }
  }

  Future<void> loadIndex(int queueIndex, {bool autoPlay = true}) async {
    if (queueIndex < 0 || queueIndex >= _queue.length) return;
    await _load(queueIndex, autoPlay: autoPlay);
  }

  Future<void> toggle() async {
    if (_player.playing) {
      await _player.pause();
      return;
    }
    _activePlayback = true;
    // just_audio's play() future only completes when playback pauses, stops
    // or reaches the end. Never await it here (or in _load) — that would
    // block the caller for the whole song and freeze UI transitions.
    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero);
    }
    unawaited(_player.play());
  }

  Future<void> next() async {
    if (_queue.isEmpty) return;
    await _ensureIdle();
    final nextIdx = _computeNext();
    if (nextIdx == null) {
      onQueueEnded?.call();
      return;
    }
    // Crossfading only makes sense while audio is actually audible. When the
    // user presses Next while paused, starting the next track at volume 0 and
    // fading it in produces an unexpected burst of sound before the paused
    // check at the end of the fade. Load it normally instead.
    if (_crossfade > Duration.zero && _player.playing) {
      await _crossfadeTo(nextIdx);
    } else {
      await _load(nextIdx);
    }
  }

  /// Next queue index honoring repeat-all, or null when the queue ends.
  int? _computeNext() {
    if (_seq + 1 < _order.length) return _order[_seq + 1];
    if (_repeat == RepeatMode.all && _order.isNotEmpty) return _order.first;
    return null;
  }

  Future<void> previous() async {
    if (_queue.isEmpty) return;
    await _ensureIdle();
    if (_seq > 0) {
      await _load(_order[_seq - 1]);
    } else if (_repeat == RepeatMode.all && _order.isNotEmpty) {
      await _load(_order.last);
    } else {
      await _player.seek(Duration.zero);
    }
  }

  /// Waits for an in-flight crossfade so transitions don't race each other.
  Future<void> _ensureIdle() async {
    while (_crossfading) {
      final f = _fadeFuture;
      if (f == null) break;
      await f;
    }
  }

  // ---- internal ----

  /// Crossfade transition: start [queueIndex] on the aux player at volume 0,
  /// ramp the current song down and the next one up over [_crossfade], then
  /// swap players and reattach the event listeners.
  Future<void> _crossfadeTo(int queueIndex) async {
    if (kDebugMode) debugPrint('[engine] crossfade -> $queueIndex');
    _crossfading = true;
    final f = _runCrossfade(queueIndex);
    _fadeFuture = f;
    try {
      await f;
    } finally {
      _crossfading = false;
      _fadeFuture = null;
    }
  }

  Future<void> _runCrossfade(int queueIndex) async {
    final item = _queue[queueIndex];
    try {
      await _startSourceOn(_aux, queueIndex);
      await _aux.setVolume(0);
      // NOTE: play() only completes when playback pauses/stops/completes,
      // so it must NOT be awaited here or the fade never runs.
      unawaited(_aux.play());
      final old = _player;
      final next = _aux;
      await Future.wait([
        _fadeVolume(old, 1.0, 0.0, _crossfade),
        _fadeVolume(next, 0.0, 1.0, _crossfade),
      ]);
      // If the user paused during the fade, keep the next song paused too
      // (unless the old song had simply completed — that's the normal case).
      if (!old.playing && old.processingState != ProcessingState.completed) {
        await next.pause();
      }
      // Detach before stopping the old player. Otherwise its transition to
      // idle is reported as an unexpected stream failure and the controller
      // skips a track after every successful crossfade.
      _detach();
      _activePlayback = false;
      await old.stop();
      await old.setVolume(1.0);
      await next.setVolume(1.0);
      _player = next;
      _aux = old;
      _attach(_player);
      _seq = _order.indexOf(queueIndex);
      if (_seq < 0) _seq = queueIndex;
      _activePlayback = next.playing;
      mediaItem.add(item);
      onSongChanged?.call(queueIndex);
    } catch (e) {
      // A failed crossfade must not leave the auxiliary player audible.
      try {
        await _aux.stop();
        await _aux.setVolume(1.0);
      } catch (_) {}
      onLoadError?.call(queueIndex, e);
    }
  }

  Future<void> _fadeVolume(
      AudioPlayer p, double from, double to, Duration dur) async {
    const steps = 16;
    for (var i = 1; i <= steps; i++) {
      try {
        await p.setVolume(from + (to - from) * i / steps);
      } catch (_) {}
      await Future.delayed(dur ~/ steps);
    }
  }

  Future<void> _load(int queueIndex, {bool autoPlay = true}) async {
    await _ensureIdle();
    if (kDebugMode) debugPrint('[engine] _load $queueIndex');
    final item = _queue[queueIndex];
    final idx = _order.indexOf(queueIndex);
    _seq = idx >= 0 ? idx : queueIndex;
    mediaItem.add(item);
    onSongChanged?.call(queueIndex);
    try {
      await _startSourceOn(_player, queueIndex);
      if (autoPlay) {
        // Mark active before calling play(): the state listener uses this
        // flag to distinguish a stream failure (unexpected idle) from a
        // user/engine-requested stop. Awaiting play() would never return
        // until the song ends, so it must stay unawaited.
        _activePlayback = true;
        unawaited(_player.play());
      } else {
        _activePlayback = false;
      }
    } catch (e) {
      _activePlayback = false;
      onLoadError?.call(queueIndex, e);
    }
  }

  /// Loads the source for [queueIndex] onto [p], resolving it on demand.
  /// Stream URLs expire after a few hours, so if a cached URL fails to
  /// load the cache entry is dropped and the source is re-resolved once
  /// (fresh yt-dlp extract) before giving up.
  Future<void> _startSourceOn(AudioPlayer p, int queueIndex) async {
    final item = _queue[queueIndex];
    final cached = _urls[item.id];
    try {
      if (cached != null) {
        await p.setAudioSource(_sourceFor(cached), initialPosition: Duration.zero);
        return;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[engine] cached URL failed for ${item.id}, re-resolving: $e');
      }
      _urls.remove(item.id);
    }
    if (resolver == null) throw StateError('No resolver');
    final fresh = await resolver!(queueIndex);
    if (fresh.url.isEmpty) throw StateError('Not available');
    _urls[item.id] = fresh;
    await p.setAudioSource(_sourceFor(fresh), initialPosition: Duration.zero);
  }

  /// Builds the [AudioSource] for a resolved URL. Local file paths are
  /// passed as file: URIs with NO headers: just_audio routes any source
  /// with a non-null headers map (even an empty one) through its localhost
  /// proxy (http://127.0.0.1), and a schemeless path through that proxy
  /// makes ExoPlayer try cleartext HTTP to 127.0.0.1 -> "Source error".
  /// Remote (stream) URLs keep their headers and go through the proxy,
  /// which is allowed by the network security config.
  AudioSource _sourceFor(({String url, Map<String, String> headers}) r) {
    final uri = Uri.parse(r.url);
    final isLocal = uri.scheme.isEmpty || uri.scheme == 'file';
    return AudioSource.uri(
      isLocal ? Uri.file(uri.path) : uri,
      headers: isLocal ? null : r.headers,
    );
  }

  /// Start/stop the live position ticker based on the player state.
  /// Ticks ~200ms while playing (even while buffering), stops when paused,
  /// idle or completed.
  void _onPlayerState(PlayerState state) {
    if (state.playing &&
        state.processingState != ProcessingState.idle &&
        state.processingState != ProcessingState.completed) {
      _ticker ??= Timer.periodic(_tickInterval, _onTick);
    } else {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  void _onTick(Timer _) {
    if (!_player.playing) return;
    _tickCount++;
    // Log sparingly: this device's logcat buffer is tiny and 1Hz output
    // flushes everything else within seconds. ~4s cadence still proves
    // the 200ms ticker is running.
    if (kDebugMode && _tickCount % 20 == 0) {
      debugPrint('[pos] tick #$_tickCount = ${_player.position}');
    }
    _publishPosition();
  }

  void _publishPosition() {
    playbackState.add(playbackState.value.copyWith(
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
    ));
  }

  Future<void> _onProcessingState(ProcessingState state) async {
    if (state == ProcessingState.completed) {
      await _handleCompletion();
    } else if (state == ProcessingState.idle && _activePlayback) {
      // The active player dropped to idle while we expected playback — the
      // stream failed (expired URL, HTTP 403, network drop). Drop the cached
      // URL and surface the error so the controller can retry/skip.
      _activePlayback = false;
      if (kDebugMode) debugPrint('[engine] unexpected idle (stream failed)');
      final idx = _seq >= 0 && _seq < _order.length ? _order[_seq] : -1;
      if (idx >= 0 && idx < _queue.length) {
        _urls.remove(_queue[idx].id);
        onLoadError?.call(
          idx,
          StateError('Stream failed (expired URL or blocked) — '
              'trying the next song'),
        );
      }
    }
  }

  Future<void> _handleCompletion() async {
    _activePlayback = false;
    final completed = currentIndex;
    if (completed >= 0) onTrackCompleted?.call(completed);
    if (_repeat == RepeatMode.one) {
      await _player.seek(Duration.zero);
      _activePlayback = true;
      unawaited(_player.play());
      return;
    }
    final nextIdx = _computeNext();
    if (nextIdx == null) {
      onQueueEnded?.call();
      return;
    }
    if (_crossfade > Duration.zero) {
      await _crossfadeTo(nextIdx);
    } else {
      await _load(nextIdx);
    }
  }

  void _publishQueue() {
    queue.add(List.of(_queue));
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: switch (_player.processingState) {
        ProcessingState.idle => AudioProcessingState.idle,
        ProcessingState.loading => AudioProcessingState.loading,
        ProcessingState.buffering => AudioProcessingState.buffering,
        ProcessingState.ready => AudioProcessingState.ready,
        ProcessingState.completed => AudioProcessingState.completed,
      },
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      // `queue` is published in library order, not shuffle order, so the
      // media-session index must be the queue index. `_seq` indexes `_order`
      // and would point at the wrong MediaItem when shuffle is enabled.
      queueIndex: currentIndex >= 0 ? currentIndex : event.currentIndex,
      repeatMode: switch (_repeat) {
        RepeatMode.off => AudioServiceRepeatMode.none,
        RepeatMode.all => AudioServiceRepeatMode.all,
        RepeatMode.one => AudioServiceRepeatMode.one,
      },
    );
  }

  // ---- BaseAudioHandler overrides (notification + system controls) ----

  @override
  Future<void> play() async {
    // The media session can deliver play after stop() cleared the queue.
    // Calling AudioPlayer.play() with no source throws asynchronously.
    if (_queue.isEmpty || _seq < 0) return;
    _activePlayback = true;
    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero);
    }
    unawaited(_player.play());
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => next();

  @override
  Future<void> skipToPrevious() => previous();

  @override
  Future<void> stop() async {
    // A crossfade has both players live; stopping only the active one would
    // leave the previous/next track audible until the fade finishes.
    await _ensureIdle();
    _activePlayback = false;
    _seq = -1;
    await _player.stop();
    await _aux.stop();
    mediaItem.add(null);
    queue.add(const []);
    playbackState.add(playbackState.value.copyWith(
      controls: const [MediaControl.stop],
      processingState: AudioProcessingState.idle,
      playing: false,
      queueIndex: null,
    ));
    await super.stop();
  }

  @override
  Future<void> onTaskRemoved() => stop();

  Future<void> shutdown() {
    _ticker?.cancel();
    _ticker = null;
    return Future.wait([_player.dispose(), _aux.dispose()]).then((_) {});
  }
}
