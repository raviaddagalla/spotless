import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../csv/csv_parser.dart';
import '../db/app_database.dart';
import '../lyrics/lrc_parser.dart';
import '../models/lyrics.dart';
import '../models/song_status.dart';
import '../youtube/yt_bridge.dart';
import 'cover_service.dart';
import 'discovery_service.dart';
import 'downloader.dart';
import 'feedback_service.dart';
import 'lastfm_provider.dart';
import 'library_scanner.dart';
import 'local_provider.dart';
import 'qloo_provider.dart';
import 'rating_service.dart';
import 'recommender.dart';
import 'session_manager.dart';

/// Result of resolving a song into something playable.
class ResolvedPlayable {
  final String source;
  final bool isStream;
  final SongStatus status;
  final Map<String, String> headers;

  const ResolvedPlayable({
    required this.source,
    required this.isStream,
    required this.status,
    this.headers = const {},
  });
}

/// The single facade the UI talks to. SQLite, audio resolution, downloading,
/// covers, lyrics and recommendations all live behind this class.
class MusicRepository {
  static const _prefsRootKey = 'library_root';
  static const _lastFmKeyPref = 'lastfm_api_key';
  static const _qlooKeyPref = 'qloo_api_key';

  final AppDatabase db;
  final YtBridge yt;
  late final LibraryScanner scanner;
  late final CoverService covers;
  late final Downloader downloader;
  late final Recommender recommender;
  late final SessionManager sessionManager;
  late final RatingService ratingService;
  late final FeedbackService feedbackService;
  late final DiscoveryService discoveryService;

  late final Future<SharedPreferences> _prefs =
      SharedPreferences.getInstance();

  MusicRepository({required this.db, required this.yt}) {
    scanner = LibraryScanner(db);
    recommender = MetadataRecommender(db);
    sessionManager = SessionManager(db: db);
    ratingService = RatingService(db: db, sessionManager: sessionManager);
    feedbackService = FeedbackService(db: db, sessionManager: sessionManager);
    discoveryService = DiscoveryService(
      db: db,
      sessionManager: sessionManager,
      ratingService: ratingService,
      feedbackService: feedbackService,
      providers: [
        LocalMetadataProvider(db),
        LastFmProvider(),
        QlooProvider(),
      ],
      ytBridge: yt,
    );
  }

  void _updateProviders(SharedPreferences prefs) {
    final lastFmKey = prefs.getString(_lastFmKeyPref);
    final qlooKey = prefs.getString(_qlooKeyPref);
    discoveryService = DiscoveryService(
      db: db,
      sessionManager: sessionManager,
      ratingService: ratingService,
      feedbackService: feedbackService,
      providers: [
        LocalMetadataProvider(db),
        LastFmProvider(apiKey: lastFmKey),
        QlooProvider(apiKey: qlooKey),
      ],
      ytBridge: yt,
    );
  }

  Directory _dir(String name) {
    return Directory(p.join(_appSupport, 'spotless', name));
  }

  late String _appSupport;
  Directory get supportDir => Directory(_appSupport);

  String? get libraryRoot => _cachedRoot;

  String? _cachedRoot;

  Future<void> init() async {
    final support = await getApplicationSupportDirectory();
    _appSupport = support.path;
    covers = CoverService(db, yt, _dir('covers'));
    downloader = Downloader(yt, _dir('downloads'));
    Directory(p.join(_appSupport, 'spotless')).createSync(recursive: true);
    await covers.ensureDir();
    await downloader.ensureDir();
    final prefs = await _prefs;
    _cachedRoot = prefs.getString(_prefsRootKey);
    _updateProviders(prefs);
    unawaited(discoveryService.cleanupStaleCandidates());
  }

  Future<String?> getLastFmApiKey() async => (await _prefs).getString(_lastFmKeyPref);
  Future<void> setLastFmApiKey(String key) async {
    final prefs = await _prefs;
    if (key.trim().isEmpty) {
      await prefs.remove(_lastFmKeyPref);
    } else {
      await prefs.setString(_lastFmKeyPref, key.trim());
    }
    _updateProviders(prefs);
  }

  Future<String?> getQlooApiKey() async => (await _prefs).getString(_qlooKeyPref);
  Future<void> setQlooApiKey(String key) async {
    final prefs = await _prefs;
    if (key.trim().isEmpty) {
      await prefs.remove(_qlooKeyPref);
    } else {
      await prefs.setString(_qlooKeyPref, key.trim());
    }
    _updateProviders(prefs);
  }

  Future<void> setLibraryRoot(String path) async {
    _cachedRoot = path;
    (await _prefs).setString(_prefsRootKey, path);
  }

  Future<ScanResult> scanLibrary({
    void Function(int done, int total, String message)? onProgress,
  }) {
    final root = _cachedRoot;
    if (root == null) throw StateError('No library root set');
    return scanner.scan(root, onProgress: onProgress);
  }

  // ---- preferences ----

  static const _offlineOnlyKey = 'offline_only';
  static const _crossfadeKey = 'crossfade';
  static const _historyKey = 'search_history';

  Future<bool> offlineOnly() async =>
      (await _prefs).getBool(_offlineOnlyKey) ?? false;

  Future<void> setOfflineOnly(bool value) async =>
      (await _prefs).setBool(_offlineOnlyKey, value);

  Future<bool> crossfadeEnabled() async =>
      (await _prefs).getBool(_crossfadeKey) ?? true;

  Future<void> setCrossfadeEnabled(bool value) async =>
      (await _prefs).setBool(_crossfadeKey, value);

  // ---- queries ----

  Stream<List<SongRow>> watchSongs({String? status, bool offlineOnly = false}) {
    final q = db.select(db.songs);
    if (offlineOnly) {
      q.where((t) => t.status.equals(SongStatus.downloaded.name));
    } else if (status != null) {
      q.where((t) => t.status.equals(status));
    }
    // CSV import order (date added), songs without a date last.
    q.orderBy([
      (t) => OrderingTerm.asc(t.addedAt.isNull()),
      (t) => OrderingTerm.asc(t.addedAt),
      (t) => OrderingTerm.asc(t.title),
    ]);
    return q.watch();
  }

  Future<List<SongRow>> allSongs() => db.select(db.songs).get();

  /// Returns songs in the given playlist ID using the standard PlaylistSongs join table.
  /// (Sleep and No Sleep are standard playlists, no hardcoded column queries).
  Future<List<SongRow>> playlist(String playlistId) => playlistSongRows(playlistId);

  Future<List<SongRow>> recent({int limit = 30}) {
    final q = db.select(db.songs)
      ..where((t) => t.lastPlayedAt.isNotNull())
      ..orderBy([(t) => OrderingTerm.desc(t.lastPlayedAt)])
      ..limit(limit);
    return q.get();
  }

  Future<List<SongRow>> mostPlayed({int limit = 30}) {
    final q = db.select(db.songs)
      ..orderBy([(t) => OrderingTerm.desc(t.playCount)])
      ..limit(limit);
    return q.get();
  }

  Future<Lyrics?> lyricsFor(SongRow song) async {
    final row = await (db.select(db.lyricsTable)
          ..where((t) => t.songId.equals(song.id)))
        .getSingleOrNull();
    if (row == null) return null;
    if (row.type == 'lrc') return LrcParser.parse(row.content);
    return Lyrics(
      synced: false,
      lines: const [],
      plainText: row.content.trim(),
    );
  }

  // ---- playback resolution ----

  /// Returns a playable source for the song: a local file path when
  /// downloaded, otherwise a freshly extracted YouTube audio URL (stream).
  /// Stream URLs from yt-dlp expire after a few hours, so they are never
  /// persisted — each resolve re-extracts. Throws when extraction fails so
  /// the caller can surface the real error instead of failing silently.
  Future<ResolvedPlayable> resolve(SongRow song) async {
    if (kDebugMode) debugPrint('[repo] resolve ${song.id} ${song.title}');
    final sw = Stopwatch()..start();
    if (song.status == SongStatus.downloaded.name &&
        song.localPath != null &&
        File(song.localPath!).existsSync()) {
      debugPrint('[resolve] ${song.id} ${song.title}: local '
          '${sw.elapsedMilliseconds}ms');
      return ResolvedPlayable(
        source: song.localPath!,
        isStream: false,
        status: SongStatus.downloaded,
      );
    }
    // Not downloaded (or the file vanished): stream from YouTube. Songs
    // without a youtubeId (plain playlist-only rows, status missing) have
    // nothing to stream — leave them to the caller as missing.
    if (song.youtubeId != null && song.youtubeId!.isNotEmpty) {
      try {
        final query = 'https://www.youtube.com/watch?v=${song.youtubeId}';
        final info = await yt.extract(query);
        final url = info['url'] as String?;
        if (url == null || url.isEmpty) {
          throw StateError(
              'yt-dlp could not extract an audio URL for "${song.title}"');
        }
        final rawHeaders = info['headers'];
        final headers = rawHeaders is Map
            ? rawHeaders.map(
                (k, v) => MapEntry(k.toString(), v.toString()))
            : const <String, String>{};
        debugPrint('[resolve] ${song.id} ${song.title}: stream '
            '${sw.elapsedMilliseconds}ms');
        return ResolvedPlayable(
          source: url,
          isStream: true,
          status: SongStatus.streamable,
          headers: headers,
        );
      } catch (e) {
        debugPrint('[resolve] ${song.id} ${song.title}: extract FAILED '
            '${sw.elapsedMilliseconds}ms: $e');
        rethrow;
      }
    }
    debugPrint('[resolve] ${song.id} ${song.title}: not downloadable/streamable '
        '${sw.elapsedMilliseconds}ms');
    return ResolvedPlayable(
      source: '',
      isStream: false,
      status: SongStatus.missing,
    );
  }

  /// Search the local library (title, artist or lyrics) by keyword.
  Future<List<SongRow>> searchSongs(String query, {bool offlineOnly = false}) async {
    final like = '%${query.replaceAll('%', '').replaceAll('_', '')}%';
    final q = db.select(db.songs);
    final lyricMatch = db.selectOnly(db.lyricsTable)
      ..addColumns([db.lyricsTable.songId])
      ..where(db.lyricsTable.content.lower().like(like));
    q.where(
      (t) =>
          t.title.lower().like(like) |
          t.artist.lower().like(like) |
          t.id.isInQuery(lyricMatch),
    );
    if (offlineOnly) {
      q.where((t) => t.status.equals(SongStatus.downloaded.name));
    }
    q.orderBy([
      (t) => OrderingTerm.asc(t.addedAt.isNull()),
      (t) => OrderingTerm.asc(t.addedAt),
      (t) => OrderingTerm.asc(t.title),
    ]);
    return q.get();
  }

  /// Returns a playable source for the song, or null when not downloaded.
  Future<String?> retryResolve(SongRow song) async {
    final res = await resolve(song);
    return res.source.isEmpty ? null : res.source;
  }

  // ---- playlists ----

  Future<List<Playlist>> playlists() => (db.select(db.playlists)
        ..orderBy([(p) => OrderingTerm.asc(p.createdAt)]))
      .get();

  Future<List<PlaylistSong>> playlistSongs(String playlistId) async {
    final q = db.select(db.playlistSongs)
      ..where((p) => p.playlistId.equals(playlistId));
    q.orderBy([(p) => OrderingTerm.asc(p.position)]);
    return q.get();
  }

  Future<List<SongRow>> playlistSongRows(String playlistId) async {
    final q = db.select(db.songs).join([
      innerJoin(db.playlistSongs,
          db.playlistSongs.songId.equalsExp(db.songs.id)),
    ])..where(db.playlistSongs.playlistId.equals(playlistId));
    q.orderBy([OrderingTerm.asc(db.playlistSongs.position)]);
    return q.map((row) => row.readTable(db.songs)).get();
  }

  Future<void> createPlaylist(String name) async {
    final id = 'pl_${DateTime.now().millisecondsSinceEpoch}';
    await db.into(db.playlists).insert(
          PlaylistsCompanion.insert(
            id: id,
            name: name,
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> renamePlaylist(String id, String name) async {
    await (db.update(db.playlists)..where((p) => p.id.equals(id)))
        .write(PlaylistsCompanion(name: Value(name)));
  }

  Future<void> deletePlaylist(String id) async {
    await (db.delete(db.playlistSongs)
          ..where((p) => p.playlistId.equals(id)))
        .go();
    await (db.delete(db.playlists)..where((p) => p.id.equals(id))).go();
  }

  /// Adds [song] to a playlist. When the song isn't in the library yet (e.g.
  /// a YouTube search result that was never downloaded), a stub `songs` row
  /// is upserted first (status streamable) so the playlist join in
  /// [playlistSongRows] always has something to match — otherwise the song
  /// would silently vanish from the playlist.
  Future<void> addToPlaylist(String playlistId, SongRow song) async {
    final inLibrary = await (db.select(db.songs)
          ..where((t) => t.id.equals(song.id)))
        .getSingleOrNull();
    if (inLibrary == null) {
      await db.into(db.songs).insert(
            SongsCompanion.insert(
              id: song.id,
              title: song.title,
              artist: Value(song.artist),
              album: Value(song.album),
              youtubeId: Value(song.youtubeId),
              status: Value(SongStatus.streamable.name),
              durationMs: Value(song.durationMs),
              albumArtUrl: Value(song.albumArtUrl),
              artEmbedded: Value(song.artEmbedded),
              explicit: Value(song.explicit),
              addedAt: Value(DateTime.now()),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
    final existing = await playlistSongs(playlistId);
    if (existing.any((p) => p.songId == song.id)) return;
    await db.into(db.playlistSongs).insert(
          PlaylistSongsCompanion.insert(
            playlistId: playlistId,
            songId: song.id,
            position: existing.length,
          ),
        );
  }

  Future<void> removeFromPlaylist(String playlistId, String songId) async {
    await (db.delete(db.playlistSongs)
          ..where((p) =>
              p.playlistId.equals(playlistId) & p.songId.equals(songId)))
        .go();
  }

  /// Reorders a song within a playlist and persists the new order.
  Future<void> reorderPlaylistSong(
      String playlistId, int oldIndex, int newIndex) async {
    final songs = await playlistSongs(playlistId);
    if (oldIndex < 0 || oldIndex >= songs.length) return;
    if (newIndex < 0 || newIndex > songs.length) return;
    if (oldIndex == newIndex) return;

    final item = songs.removeAt(oldIndex);
    final targetIndex = oldIndex < newIndex ? newIndex - 1 : newIndex;
    songs.insert(targetIndex, item);

    await db.transaction(() async {
      for (var i = 0; i < songs.length; i++) {
        await (db.update(db.playlistSongs)
              ..where((p) =>
                  p.playlistId.equals(playlistId) &
                  p.songId.equals(songs[i].songId)))
            .write(PlaylistSongsCompanion(position: Value(i)));
      }
    });
  }

  // ---- search history (F6) ----

  Future<List<String>> searchHistory() async =>
      (await _prefs).getStringList(_historyKey) ?? const [];

  Future<void> addSearchHistory(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    final prefs = await _prefs;
    final list = prefs.getStringList(_historyKey) ?? [];
    list.remove(q);
    list.insert(0, q);
    await prefs.setStringList(_historyKey, list.take(10).toList());
  }

  Future<void> clearSearchHistory() async =>
      (await _prefs).remove(_historyKey);

  // ---- artists / albums (F10) ----

  Future<List<({String name, int count})>> artists() async {
    final q = db.selectOnly(db.songs)
      ..addColumns([db.songs.artist, db.songs.id.count()])
      ..groupBy([db.songs.artist]);
    final rows = await q.get();
    return [
      for (final r in rows)
        (name: r.read(db.songs.artist) ?? '', count: r.read(db.songs.id.count()) ?? 0),
    ]..removeWhere((a) => a.name.isEmpty);
  }

  Future<List<({String album, String artist, int count})>> albums() async {
    final q = db.selectOnly(db.songs)
      ..addColumns([db.songs.album, db.songs.artist, db.songs.id.count()])
      ..groupBy([db.songs.album]);
    final rows = await q.get();
    return [
      for (final r in rows)
        (
          album: r.read(db.songs.album) ?? '',
          artist: r.read(db.songs.artist) ?? '',
          count: r.read(db.songs.id.count()) ?? 0,
        ),
    ]..removeWhere((a) => a.album.isEmpty);
  }

  Future<List<SongRow>> songsByArtist(String artist) {
    final q = db.select(db.songs)..where((t) => t.artist.equals(artist));
    q.orderBy([
      (t) => OrderingTerm.asc(t.album.isNull()),
      (t) => OrderingTerm.asc(t.album),
      (t) => OrderingTerm.asc(t.trackNumber.isNull()),
      (t) => OrderingTerm.asc(t.trackNumber),
      (t) => OrderingTerm.asc(t.title),
    ]);
    return q.get();
  }

  Future<List<SongRow>> songsByAlbum(String album) {
    final q = db.select(db.songs)..where((t) => t.album.equals(album));
    q.orderBy([
      (t) => OrderingTerm.asc(t.trackNumber.isNull()),
      (t) => OrderingTerm.asc(t.trackNumber),
      (t) => OrderingTerm.asc(t.title),
    ]);
    return q.get();
  }

  // ---- playlist export (F12) ----

  /// Writes the playlist as a .m3u file in the app support dir and returns
  /// the file path. Lines point at local files when downloaded, else title.
  Future<String> exportPlaylist(String playlistId) async {
    final pl = await (db.select(db.playlists)
          ..where((p) => p.id.equals(playlistId)))
        .getSingleOrNull();
    if (pl == null) throw StateError('Playlist not found');
    final songs = await playlistSongRows(playlistId);
    final dir = Directory(p.join(_appSupport, 'spotless', 'exports'));
    dir.createSync(recursive: true);
    final safe = pl.name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final file = File(p.join(dir.path, '$safe.m3u'));
    final buf = StringBuffer()..writeln('#EXTM3U');
    for (final s in songs) {
      final dur = s.durationMs != null ? s.durationMs! ~/ 1000 : -1;
      buf.writeln('#EXTINF:$dur,${s.artist} - ${s.title}');
      buf.writeln(s.localPath ?? s.title);
    }
    await file.writeAsString(buf.toString());
    return file.path;
  }

  // ---- liked songs ----

  Future<List<SongRow>> likedSongs() => (db.select(db.songs)
        ..where((t) => t.likedAt.isNotNull())
        ..orderBy([(t) => OrderingTerm.desc(t.likedAt)]))
      .get();

  Future<bool> isLiked(String songId) async {
    final row = await (db.select(db.songs)..where((t) => t.id.equals(songId)))
        .getSingleOrNull();
    return row?.likedAt != null;
  }

  Future<void> setLiked(String songId, bool liked) async {
    await (db.update(db.songs)..where((t) => t.id.equals(songId))).write(
      SongsCompanion(likedAt: Value(liked ? DateTime.now() : null)),
    );
  }

  Future<void> recordPlay(SongRow song) async {
    await (db.update(db.songs)..where((t) => t.id.equals(song.id))).write(
      SongsCompanion(
        lastPlayedAt: Value(DateTime.now()),
        playCount: Value(song.playCount + 1),
      ),
    );
    await feedbackService.recordPlayStart(song.id);
  }

  // ---- downloads (in-app) ----

  Future<DownloadResult> downloadSong(
    SongRow song, {
    void Function(double percent)? onProgress,
  }) async {
    final sw = Stopwatch()..start();
    debugPrint('[download] ${song.id} ${song.title}: start');
    Timer? poller;
    if (onProgress != null) {
      poller = Timer.periodic(const Duration(milliseconds: 500), (_) async {
        try {
          final p = await downloader.pollProgress();
          if (p != null) onProgress(p);
        } catch (_) {}
      });
    }
    try {
      String downloadUrl;
      if (song.youtubeId != null && song.youtubeId!.isNotEmpty) {
        downloadUrl = 'https://www.youtube.com/watch?v=${song.youtubeId}';
      } else {
        // Phase 2: Canonical search to find official studio recording
        try {
          final canonical = await yt.canonicalSearch(
            song.artist,
            song.title,
            expectedDurationSeconds:
                song.durationMs != null ? song.durationMs! ~/ 1000 : null,
          );
          if (canonical['id'] != null &&
              canonical['id'].toString().isNotEmpty) {
            downloadUrl = 'https://www.youtube.com/watch?v=${canonical['id']}';
          } else {
            downloadUrl =
                'ytsearch1:${song.title} ${song.artist} official audio';
          }
        } catch (_) {
          downloadUrl = 'ytsearch1:${song.title} ${song.artist} official audio';
        }
      }
      final res = await downloader.download(
        downloadUrl,
        onProgress: onProgress,
      );
      debugPrint('[download] ${song.id} ${song.title}: done '
          '${sw.elapsedMilliseconds}ms path=${res.path}');
      if (res.path != null && File(res.path!).existsSync()) {
        await _finalizeDownload(song, res.path!, result: res);
      }
      return res;
    } catch (e) {
      debugPrint('[download] ${song.id} ${song.title}: FAILED '
          '${sw.elapsedMilliseconds}ms: $e');
      rethrow;
    } finally {
      poller?.cancel();
    }
  }

  Future<void> _finalizeDownload(SongRow song, String path,
      {DownloadResult? result}) async {
    try {
      await yt.setTags(path, title: song.title, artist: song.artist);
    } catch (_) {}
    final info = await yt.probe(path).catchError((_) => const <String, dynamic>{});
    final durationMs = (info['duration'] as num?)?.toInt() != null
        ? (info['duration'] as num).toInt() * 1000
        : null;
    // For search-query downloads (no known youtube id yet) capture the
    // video id + resolved title + thumbnail from the yt-dlp result so the
    // song behaves like a normal library entry (streamable fallback, art).
    final videoId = result?.videoId?.isNotEmpty == true ? result!.videoId : null;
    final resolvedTitle = result?.title?.isNotEmpty == true ? result!.title : null;
    final thumbnail = result?.thumbnail?.isNotEmpty == true ? result!.thumbnail : null;
    final updated =
        await (db.update(db.songs)..where((t) => t.id.equals(song.id))).write(
      SongsCompanion(
        localPath: Value(path),
        status: Value(SongStatus.downloaded.name),
        durationMs: Value(durationMs),
        filename: Value(p.basename(path)),
        youtubeId: Value(videoId ?? song.youtubeId),
        resolvedYtTitle: Value(resolvedTitle),
        albumArtUrl: Value(song.albumArtUrl ?? thumbnail),
        error: const Value(null),
      ),
    );
    if (updated == 0) {
      // Song isn't in the DB yet (e.g. a YouTube search result): insert it
      // so the download is tracked and appears in the library.
      await db.into(db.songs).insert(
        SongsCompanion.insert(
          id: song.id,
          title: song.title,
          artist: Value(song.artist),
          album: Value(song.album),
          youtubeId: Value(videoId ?? song.youtubeId),
          localPath: Value(path),
          status: Value(SongStatus.downloaded.name),
          durationMs: Value(durationMs),
          filename: Value(p.basename(path)),
          albumArtUrl: Value(song.albumArtUrl ?? thumbnail),
          artEmbedded: Value(song.artEmbedded),
          explicit: Value(song.explicit),
          addedAt: Value(DateTime.now()),
        ),
      );
    }
    final fresh = await (db.select(db.songs)
          ..where((t) => t.id.equals(song.id)))
        .getSingleOrNull();
    if (fresh != null && fresh.albumArtUrl != null) {
      await covers.embedFor(fresh);
    }
    try {
      final lyr = await yt.fetchLyrics(
        song.title,
        song.artist,
        album: song.album,
        durationSeconds: durationMs != null ? durationMs ~/ 1000 : null,
      );
      final lyricsText = lyr['lyrics'] as String?;
      final isSynced = lyr['is_synced'] as bool? ?? false;
      if (lyricsText != null && lyricsText.isNotEmpty && fresh != null) {
        await db.into(db.lyricsTable).insert(
          LyricsTableCompanion.insert(
            songId: fresh.id,
            type: isSynced ? 'lrc' : 'txt',
            content: lyricsText,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    } catch (_) {}
  }

  // ---- playlist CSV import (from scratch, no local files needed) ----

  static String _csvVal(Map<String, String> row, List<String> keys) {
    for (final k in keys) {
      final v = (row[k] ?? '').trim();
      if (v.isNotEmpty && v.toLowerCase() != 'null') return v;
    }
    return '';
  }

  /// Imports Spotify-style playlist CSVs: each file becomes a playlist, and
  /// every song is located on YouTube, downloaded, tagged, and given lyrics
  /// + embedded cover art automatically. Already-downloaded songs are
  /// skipped, so re-running an import resumes where it left off.
  /// Returns counts for the summary snackbar.
  Future<({int total, int imported, int skipped, int failed})> importPlaylistCsvs(
    List<String> paths, {
    void Function(int done, int total, String message)? onProgress,
  }) async {
    // Parse everything up front so progress can count the real total.
    final files = <(String name, List<Map<String, String>> rows)>[];
    for (final path in paths) {
      final text = await File(path).readAsString();
      files.add((
        p.basenameWithoutExtension(path),
        CsvParser.parse(text).toMaps(),
      ));
    }
    var total = 0;
    for (final (_, rows) in files) {
      total += rows.length;
    }
    var done = 0;
    var imported = 0;
    var skipped = 0;
    var failed = 0;

    for (var f = 0; f < files.length; f++) {
      final (name, rows) = files[f];
      final playlistId = 'pl_${DateTime.now().millisecondsSinceEpoch}_$f';
      await db.into(db.playlists).insert(
        PlaylistsCompanion.insert(
          id: playlistId,
          name: name,
          createdAt: DateTime.now(),
        ),
        mode: InsertMode.insertOrIgnore,
      );
      for (var i = 0; i < rows.length; i++) {
        final r = rows[i];
        final lower = r.map((k, v) => MapEntry(k.toLowerCase(), v));
        final title = _csvVal(
            lower, const ['track name', 'song title', 'title', 'name']);
        if (title.isEmpty) {
          done++;
          onProgress?.call(done, total, 'Skipped row (no title)');
          continue;
        }
        final artist = _csvVal(lower,
            const ['artist name(s)', 'artist', 'artist name', 'artists']);
        final trackUri = _csvVal(lower, const ['track uri', 'uri']);
        final songId = trackUri.isNotEmpty
            ? trackUri
            : 'imp:$playlistId:$i';
        final album = _csvVal(lower, const ['album name', 'album']);
        final albumArtUrl = _csvVal(lower, const [
          'album image url',
          'album art url',
          'cover url',
          'image url',
          'thumbnail',
        ]);
        final durationMs = int.tryParse(_csvVal(lower,
            const ['track duration (ms)', 'duration_ms', 'duration ms', 'duration']));
        final youtubeId = _csvVal(
            lower, const ['youtube_id', 'youtube id', 'video id', 'youtube']);
        final addedAt = DateTime.tryParse(
            _csvVal(lower, const ['added at', 'date added']));

        await db.into(db.songs).insert(
          SongsCompanion.insert(
            id: songId,
            title: title,
            artist: Value(artist.isEmpty ? 'Unknown Artist' : artist),
            album: Value(album.isEmpty ? null : album),
            youtubeId: Value(youtubeId.isEmpty ? null : youtubeId),
            status: Value(SongStatus.analyzing.name),
            durationMs: Value(durationMs),
            albumArtUrl: Value(albumArtUrl.isEmpty ? null : albumArtUrl),
            addedAt: Value(addedAt ?? DateTime.now()),
          ),
          mode: InsertMode.insertOrIgnore,
        );
        // Link into the playlist (idempotent).
        final linked = await (db.select(db.playlistSongs)
              ..where((p) =>
                  p.playlistId.equals(playlistId) & p.songId.equals(songId)))
            .getSingleOrNull();
        if (linked == null) {
          final pos = await (db.select(db.playlistSongs)
                ..where((p) => p.playlistId.equals(playlistId)))
              .get();
          await db.into(db.playlistSongs).insert(
            PlaylistSongsCompanion.insert(
              playlistId: playlistId,
              songId: songId,
              position: pos.length,
            ),
          );
        }

        done++;
        final row = await (db.select(db.songs)
              ..where((t) => t.id.equals(songId)))
            .getSingleOrNull();
        if (row == null) {
          failed++;
          continue;
        }
        final alreadyDownloaded = row.status == SongStatus.downloaded.name &&
            row.localPath != null &&
            File(row.localPath!).existsSync();
        if (alreadyDownloaded) {
          skipped++;
          onProgress?.call(done, total, 'Already downloaded: $title');
          continue;
        }
        onProgress?.call(done, total, 'Downloading: $title — $artist');
        try {
          await downloadSong(row);
          imported++;
        } catch (e) {
          failed++;
          await (db.update(db.songs)..where((t) => t.id.equals(songId)))
              .write(SongsCompanion(
            status: Value(SongStatus.failed.name),
            error: Value('$e'),
          ));
        }
      }
    }
    return (total: total, imported: imported, skipped: skipped, failed: failed);
  }

  // ---- covers ----

  Future<String?> coverFor(SongRow song) => covers.coverFor(song);

  Future<bool> embedCover(SongRow song) => covers.embedFor(song);

  Future<({int done, int failed})> embedAllCovers({
    void Function(int done, int total, String current)? onProgress,
    bool Function()? isCancelled,
  }) {
    return covers.embedAll(onProgress: onProgress, isCancelled: isCancelled);
  }

  Future<void> clearCoverCache() async {
    final dir = _dir('covers');
    if (dir.existsSync()) {
      for (final f in dir.listSync().whereType<File>()) {
        try {
          f.deleteSync();
        } catch (_) {}
      }
    }
    await (db.update(db.songs)..where((t) => t.albumArtPath.isNotNull()))
        .write(const SongsCompanion(albumArtPath: Value(null)));
  }

  // ---- recommendations ----

  Future<List<SongRow>> forYou(int limit) => recommender.forYou(limit);

  Future<List<SongRow>> similarTo(SongRow seed, int limit) =>
      recommender.similarTo(seed, limit);

  // ---- youtube search (for "Find on YouTube" + Search tab) ----

  Future<List<Map<String, dynamic>>> searchYoutube(String query,
      {int maxResults = 15}) {
    return yt.search(query, maxResults: maxResults);
  }
}
