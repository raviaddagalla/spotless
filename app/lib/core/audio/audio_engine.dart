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
    _eventSub = p.playbackEventStream.listen(_onPlaybackEvent);
    _stateSub = p.playerStateStream.listen(_onPlayerState);
    _procSub = p.processingStateStream.listen(_onProcessingState);
  }

  void _detach() {
    _eventSub?.cancel();
    _stateSub?.cancel();
    _procSub?.cancel();
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
    _queue = List.of(items);
    _order = List.of(order ?? List.generate(items.length, (i) => i));
    if (_order.length != items.length) {
      _order = List.generate(items.length, (i) => i);
    }
    _publishQueue();
    _urls.clear();
    if (items.isEmpty) return;
    if (reload) {
      final start = (startAt ?? 0).clamp(0, items.length - 1);
      await _load(start, autoPlay: autoPlay);
    } else {
      final cur = currentIndex;
      _seq = cur >= 0 && _order.contains(cur) ? _order.indexOf(cur) : -1;
    }
  }

  Future<void> loadIndex(int queueIndex, {bool autoPlay = true}) async {
    if (queueIndex < 0 || queueIndex >= _queue.length) return;
    await _load(queueIndex, autoPlay: autoPlay);
  }

  Future<void> toggle() => _player.playing ? _player.pause() : _player.play();

  Future<void> next() async {
    if (_queue.isEmpty) return;
    await _ensureIdle();
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
      _activePlayback = false;
      await old.stop();
      await old.setVolume(1.0);
      await next.setVolume(1.0);
      _detach();
      _player = next;
      _aux = old;
      _attach(_player);
      _seq = _order.indexOf(queueIndex);
      if (_seq < 0) _seq = queueIndex;
      mediaItem.add(item);
      onSongChanged?.call(queueIndex);
    } catch (e) {
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
      if (autoPlay) await _player.play();
      _activePlayback = true;
    } catch (e) {
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
    if (_repeat == RepeatMode.one) {
      await _player.seek(Duration.zero);
      await _player.play();
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
      queueIndex: _seq >= 0 ? _seq : event.currentIndex,
      repeatMode: switch (_repeat) {
        RepeatMode.off => AudioServiceRepeatMode.none,
        RepeatMode.all => AudioServiceRepeatMode.all,
        RepeatMode.one => AudioServiceRepeatMode.one,
      },
    );
  }

  // ---- BaseAudioHandler overrides (notification + system controls) ----

  @override
  Future<void> play() => _player.play();

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
    _activePlayback = false;
    await _player.stop();
    playbackState.add(playbackState.value.copyWith(
      controls: const [MediaControl.stop],
      processingState: AudioProcessingState.idle,
      playing: false,
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
