import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../audio/audio_engine.dart';
import '../db/app_database.dart';
import '../models/lyrics.dart';
import '../services/music_repository.dart';

enum ShuffleMode {
  off,
  normal,
  smart,
}

/// Playback state for the UI. Talks only to [MusicRepository] + [AudioEngine].
class PlayerController extends ChangeNotifier {
  final MusicRepository repo;
  final AudioEngine engine;

  List<SongRow> _queue = [];
  List<int> _shuffleOrder = [];
  int _current = -1;
  RepeatMode _repeat = RepeatMode.off;
  ShuffleMode _shuffleMode = ShuffleMode.off;
  bool _loading = false;
  bool _queueEnded = false;
  String? _error;
  Lyrics? _currentLyrics;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _playing = false;
  ProcessingState _processingState = ProcessingState.idle;

  StreamSubscription<PlaybackState>? _stateSub;
  StreamSubscription<Duration?>? _durationSub;

  PlayerController({required this.repo, required this.engine}) {
    engine.onSongChanged = _onSongChanged;
    engine.onQueueEnded = _onQueueEnded;
    engine.onLoadError = _onLoadError;
    engine.resolver = _resolveUri;
    _stateSub = engine.stateStream.listen((state) {
      _playing = state.playing;
      // state.position extrapolates updatePosition by the elapsed time
      // since updateTime, so the value is live rather than "last known".
      _position = state.position;
      _processingState = switch (state.processingState) {
        AudioProcessingState.idle => ProcessingState.idle,
        AudioProcessingState.loading => ProcessingState.loading,
        AudioProcessingState.buffering => ProcessingState.buffering,
        AudioProcessingState.ready => ProcessingState.ready,
        AudioProcessingState.completed => ProcessingState.completed,
        AudioProcessingState.error => ProcessingState.idle,
      };
      // _loading stays true while the engine resolves/loads a song (set in
      // _onSongChanged/_startCurrent, since processingState is still idle
      // during yt-dlp resolution); clear it once playback is actually ready.
      if (state.processingState == AudioProcessingState.loading ||
          state.processingState == AudioProcessingState.buffering) {
        _loading = true;
      } else if (state.processingState == AudioProcessingState.ready ||
          state.processingState == AudioProcessingState.completed) {
        _loading = false;
      }
      notifyListeners();
    });
    _durationSub = engine.durationStream.listen((d) {
      _duration = d ?? Duration.zero;
      notifyListeners();
    });
  }

  // ---- state getters ----

  List<SongRow> get queue => List.unmodifiable(_queue);
  int get currentIndex => _current;
  SongRow? get currentSong =>
      _current >= 0 && _current < _queue.length ? _queue[_current] : null;
  bool get hasCurrent => currentSong != null;
  bool get loading => _loading;
  bool get playing => _playing;
  bool get shuffle => _shuffleMode != ShuffleMode.off;
  ShuffleMode get shuffleMode => _shuffleMode;
  bool get isSmartShuffle => _shuffleMode == ShuffleMode.smart;
  RepeatMode get repeat => _repeat;
  Duration get position => _position;
  Duration get duration => _duration;
  ProcessingState get processingState => _processingState;
  String? get error => _error;
  Lyrics? get currentLyrics => _currentLyrics;
  bool get queueEnded => _queueEnded;
  bool get isStreaming =>
      currentSong != null &&
      !(currentSong!.status == 'downloaded' &&
          currentSong!.localPath != null &&
          currentSong!.localPath!.isNotEmpty);

  // ---- queue control ----

  Future<void> playQueue(List<SongRow> songs, {int startIndex = 0}) async {
    if (songs.isEmpty) return;
    _queue = List.of(songs);
    _current = startIndex.clamp(0, _queue.length - 1);
    _queueEnded = false;
    _error = null;
    if (_shuffleMode == ShuffleMode.normal) {
      _regenerateShuffle(keepFirst: _current);
    } else if (_shuffleMode == ShuffleMode.smart) {
      await _regenerateSmartShuffle(keepFirst: _current);
    }
    await _startCurrent();
  }

  Future<void> playSong(SongRow song) async {
    await playQueue([song], startIndex: 0);
  }

  Future<void> addNext(SongRow song) async {
    final pos = _current + 1;
    _queue.insert(pos, song);
    await _syncEngineQueue(reload: false);
    notifyListeners();
  }

  Future<void> addToQueue(SongRow song) async {
    _queue.add(song);
    await _syncEngineQueue(reload: false);
    notifyListeners();
  }

  Future<void> removeAt(int index) async {
    if (index < 0 || index >= _queue.length) return;
    _queue.removeAt(index);
    if (_queue.isEmpty) {
      await stop();
      return;
    }
    if (index == _current) {
      _current = _current.clamp(0, _queue.length - 1);
      await _startCurrent();
      return;
    }
    if (index < _current) _current--;
    await _syncEngineQueue(reload: false);
    notifyListeners();
  }

  /// Moves a queue item (F4). With shuffle on, the underlying queue order
  /// changes and the shuffle sequence is regenerated keeping the current
  /// song first.
  Future<void> moveQueueItem(int from, int to) async {
    if (from < 0 || from >= _queue.length) return;
    if (to < 0 || to >= _queue.length) return;
    if (from == to) return;
    final song = _queue.removeAt(from);
    _queue.insert(to, song);
    if (_current == from) {
      _current = to;
    } else if (from < _current && to >= _current) {
      _current--;
    } else if (from > _current && to <= _current) {
      _current++;
    }
    if (_shuffleMode == ShuffleMode.normal) {
      _regenerateShuffle(keepFirst: _current);
    } else if (_shuffleMode == ShuffleMode.smart) {
      await _regenerateSmartShuffle(keepFirst: _current);
    }
    await _syncEngineQueue(reload: false);
    notifyListeners();
  }

  Future<void> cycleShuffleMode() async {
    switch (_shuffleMode) {
      case ShuffleMode.off:
        await setShuffleMode(ShuffleMode.normal);
        break;
      case ShuffleMode.normal:
        await setShuffleMode(ShuffleMode.smart);
        break;
      case ShuffleMode.smart:
        await setShuffleMode(ShuffleMode.off);
        break;
    }
  }

  Future<void> setShuffleMode(ShuffleMode mode) async {
    if (_shuffleMode == mode) return;
    _shuffleMode = mode;
    if (_shuffleMode == ShuffleMode.off) {
      _shuffleOrder = [];
    } else if (_shuffleMode == ShuffleMode.normal) {
      _regenerateShuffle(keepFirst: _current);
    } else if (_shuffleMode == ShuffleMode.smart) {
      await _regenerateSmartShuffle(keepFirst: _current);
    }
    await _syncEngineQueue(reload: false);
    notifyListeners();
  }

  void setShuffle(bool enabled) {
    setShuffleMode(enabled ? ShuffleMode.normal : ShuffleMode.off);
  }

  void setRepeat(RepeatMode mode) {
    _repeat = mode;
    engine.setRepeat(mode);
    notifyListeners();
  }

  void setCrossfade(Duration duration) {
    engine.setCrossfade(duration);
  }

  Future<void> togglePlayPause() => engine.toggle();

  Future<void> next() async {
    _queueEnded = false;
    // Record implicit skip if moving away before 80% played
    if (currentSong != null && _duration > Duration.zero) {
      final pct = _position.inMilliseconds / _duration.inMilliseconds;
      if (pct < 0.80) {
        unawaited(repo.feedbackService.recordSkip(
          currentSong!.id,
          secondsPlayed: _position.inSeconds,
          completionPercentage: pct,
        ));
      }
    }
    await engine.next();
  }

  Future<void> previous() async {
    _queueEnded = false;
    await engine.previous();
  }

  Future<void> seek(Duration position) {
    unawaited(repo.sessionManager.recordActivity(reason: 'seek'));
    return engine.seek(position);
  }

  Future<void> jumpTo(int queueIndex) async {
    _queueEnded = false;
    await engine.loadIndex(queueIndex);
  }

  Future<void> stop() async {
    await engine.stop();
    _current = -1;
    _queue = [];
    _shuffleOrder = [];
    _currentLyrics = null;
    _error = null;
    _queueEnded = false;
    notifyListeners();
  }

  Future<void> downloadCurrent() async {
    final song = currentSong;
    if (song == null || _downloading) return;
    _downloading = true;
    _downloadProgress = 0.0;
    _error = null;
    notifyListeners();
    try {
      await repo.downloadSong(
        song,
        onProgress: (p) {
          _downloadProgress = p;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'Download failed: $e';
    } finally {
      _downloading = false;
      notifyListeners();
    }
  }

  /// Downloads an arbitrary song (from a menu action). Throws on failure so
  /// the caller can show a SnackBar.
  Future<void> downloadSong(
    SongRow song, {
    void Function(double percent)? onProgress,
  }) async {
    try {
      await repo.downloadSong(song, onProgress: onProgress);
    } catch (e) {
      _error = 'Download failed: $e';
      notifyListeners();
      rethrow;
    }
  }

  // ---- sleep timer (F8) ----

  Timer? _sleepTimer;
  Timer? _sleepTick;
  DateTime? _sleepEndsAt;
  bool _sleepAfterCurrent = false;

  bool get sleepTimerActive => _sleepEndsAt != null || _sleepAfterCurrent;

  Duration? get sleepRemaining {
    final end = _sleepEndsAt;
    if (end == null) return null;
    final left = end.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  void startSleepTimer(Duration duration) {
    _sleepAfterCurrent = false;
    _sleepEndsAt = DateTime.now().add(duration);
    _sleepTimer?.cancel();
    _sleepTick?.cancel();
    _sleepTimer = Timer(duration, _fireSleepTimer);
    _sleepTick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_sleepEndsAt != null &&
          !DateTime.now().isBefore(_sleepEndsAt!)) {
        _fireSleepTimer();
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void startSleepAfterCurrent() {
    _sleepEndsAt = null;
    _sleepTimer?.cancel();
    _sleepTick?.cancel();
    _sleepAfterCurrent = true;
    notifyListeners();
  }

  void cancelSleepTimer() {
    _sleepEndsAt = null;
    _sleepAfterCurrent = false;
    _sleepTimer?.cancel();
    _sleepTick?.cancel();
    notifyListeners();
  }

  Future<void> _fireSleepTimer() async {
    _sleepEndsAt = null;
    _sleepAfterCurrent = false;
    _sleepTimer?.cancel();
    _sleepTick?.cancel();
    await engine.pause();
    notifyListeners();
  }

  // ---- internals ----

  bool _downloading = false;
  double _downloadProgress = 0.0;
  bool get downloading => _downloading;
  double get downloadProgress => _downloadProgress;

  void _regenerateShuffle({int? keepFirst}) {
    final n = _queue.length;
    if (n == 0) {
      _shuffleOrder = [];
      return;
    }
    if (keepFirst != null && keepFirst >= 0 && keepFirst < n) {
      final rest = [
        for (var i = 0; i < n; i++)
          if (i != keepFirst) i,
      ]..shuffle(Random());
      _shuffleOrder = [keepFirst, ...rest];
    } else {
      _shuffleOrder = List.generate(n, (i) => i)..shuffle(Random());
    }
  }

  /// Generates a Smart Shuffle sequence: incorporates explicit ratings,
  /// session preferences, implicit completion scores, and spaces out
  /// consecutive tracks by the same artist (Spec §34).
  Future<void> _regenerateSmartShuffle({int? keepFirst}) async {
    final n = _queue.length;
    if (n == 0) {
      _shuffleOrder = [];
      return;
    }
    final candidateIndices = [
      for (var i = 0; i < n; i++)
        if (i != keepFirst) i,
    ];

    if (candidateIndices.isEmpty) {
      _shuffleOrder = keepFirst != null ? [keepFirst] : [0];
      return;
    }

    final scored = <(double, int)>[];
    final now = DateTime.now();
    final random = Random();

    for (final idx in candidateIndices) {
      final song = _queue[idx];
      double score = 1.0;

      // Rating bonus
      final stats = await repo.ratingService.getRatingStats(song.id);
      if (stats.latestRating != null) {
        if (stats.latestRating! >= 8) {
          score += 0.5 * (stats.latestRating! - 7);
        } else if (stats.latestRating! <= 4) {
          score -= 0.4 * (5 - stats.latestRating!);
        }
      }

      // Implicit score
      final implicit = await repo.feedbackService.getImplicitScore(song.id);
      score += implicit * 0.4;

      // Recency penalty
      if (song.lastPlayedAt != null) {
        final hoursSince = now.difference(song.lastPlayedAt!).inHours;
        if (hoursSince < 12) {
          score -= 0.5;
        } else if (hoursSince < 48) {
          score -= 0.2;
        }
      }

      // Liked bonus
      if (song.likedAt != null) {
        score += 0.3;
      }

      // Non-deterministic jitter
      score += random.nextDouble() * 0.35;

      scored.add((score, idx));
    }

    scored.sort((a, b) => b.$1.compareTo(a.$1));

    // Artist diversity spacing
    final spaced = <int>[];
    final remaining = scored.map((e) => e.$2).toList();
    String lastArtist = (keepFirst != null && keepFirst >= 0 && keepFirst < n)
        ? _queue[keepFirst].artist.toLowerCase()
        : '';

    while (remaining.isNotEmpty) {
      int pickIdx = 0;
      if (lastArtist.isNotEmpty) {
        for (var i = 0; i < remaining.length; i++) {
          if (_queue[remaining[i]].artist.toLowerCase() != lastArtist) {
            pickIdx = i;
            break;
          }
        }
      }
      final chosen = remaining.removeAt(pickIdx);
      spaced.add(chosen);
      lastArtist = _queue[chosen].artist.toLowerCase();
    }

    _shuffleOrder = keepFirst != null && keepFirst >= 0 && keepFirst < n
        ? [keepFirst, ...spaced]
        : spaced;
  }

  Future<void> _syncEngineQueue({bool reload = true}) async {
    if (_queue.isEmpty) return;
    final items = _queue
        .map((s) => MediaItem(
              id: s.id,
              title: s.title,
              artist: s.artist,
              album: s.album,
              duration: s.durationMs != null
                  ? Duration(milliseconds: s.durationMs!)
                  : null,
              artUri: _artUriFor(s),
            ))
        .toList();
    await engine.setQueue(
      items,
      startAt: _current,
      order: shuffle ? _shuffleOrder : null,
      autoPlay: true,
      reload: reload,
    );
  }

  /// Lazy per-song resolution used by the engine for auto-advance.
  Future<({String url, Map<String, String> headers})> _resolveUri(
      int queueIndex) async {
    if (kDebugMode) debugPrint('[controller] _resolveUri $queueIndex');
    if (queueIndex < 0 || queueIndex >= _queue.length) {
      throw StateError('Queue index out of range');
    }
    final song = _queue[queueIndex];
    final resolved = await repo.resolve(song);
    if (resolved.source.isEmpty) {
      throw StateError('Nothing to play for "${song.title}"');
    }
    return (url: resolved.source, headers: resolved.headers);
  }

  Uri? _artUriFor(SongRow song) {
    if (song.albumArtPath != null && song.albumArtPath!.isNotEmpty) {
      try {
        return Uri.file(song.albumArtPath!);
      } catch (_) {}
    }
    if (song.albumArtUrl != null && song.albumArtUrl!.isNotEmpty) {
      return Uri.parse(song.albumArtUrl!);
    }
    return null;
  }

  Future<void> _startCurrent() async {
    final song = currentSong;
    if (song == null) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _syncEngineQueue();
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _loadLyrics(String songId) async {
    final song = _queue.where((s) => s.id == songId).firstOrNull;
    if (song == null) return;
    _currentLyrics = await repo.lyricsFor(song);
    notifyListeners();
  }

  Future<void> _onSongChanged(int queueIndex) async {
    _current = queueIndex;
    _queueEnded = false;
    _error = null;
    _loading = true;
    notifyListeners();
    final song = currentSong;
    if (song == null) return;
    if (_sleepAfterCurrent) {
      _sleepAfterCurrent = false;
      _sleepTick?.cancel();
      unawaited(engine.pause());
      notifyListeners();
    }
    unawaited(_loadLyrics(song.id));
    unawaited(repo.recordPlay(song));
  }

  Future<void> _onQueueEnded() async {
    _queueEnded = true;
    if (currentSong != null) {
      unawaited(repo.feedbackService.recordTrackCompleted(
        currentSong!.id,
        secondsPlayed: _duration.inSeconds,
      ));
    }
    await engine.pause();
    notifyListeners();
  }

  Future<void> _onLoadError(int queueIndex, Object error) async {
    if (queueIndex == _current) {
      _error = 'Playback failed: $error';
      notifyListeners();
      await next();
    }
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _durationSub?.cancel();
    _sleepTimer?.cancel();
    _sleepTick?.cancel();
    super.dispose();
  }
}
