import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:http/http.dart' as http;

import '../db/app_database.dart';
import '../youtube/yt_bridge.dart';

/// Downloads cover art from Spotify URLs, caches it in app storage and
/// embeds it into the MP3 ID3 tags so every player shows the cover.
class CoverService {
  final AppDatabase _db;
  final YtBridge _yt;
  final Directory _cacheDir;

  CoverService(this._db, this._yt, this._cacheDir);

  Future<void> ensureDir() async {
    if (!_cacheDir.existsSync()) await _cacheDir.create(recursive: true);
  }

  String cachePathFor(String songId, String url) {
    final ext = url.toLowerCase().contains('.png') ? 'png' : 'jpg';
    return '${_cacheDir.path}${Platform.pathSeparator}$songId.$ext';
  }

  /// Returns a local path to the cover for the given song (cached file),
  /// or null if none is available.
  Future<String?> coverFor(SongRow song) async {
    if (song.albumArtPath != null && File(song.albumArtPath!).existsSync()) {
      return song.albumArtPath;
    }
    if (song.albumArtUrl == null || song.albumArtUrl!.isEmpty) return null;
    final path = cachePathFor(song.id, song.albumArtUrl!);
    if (File(path).existsSync()) {
      await _setCachePath(song.id, path);
      return path;
    }
    try {
      final bytes = await _fetch(song.albumArtUrl!);
      if (bytes == null) return null;
      await File(path).writeAsBytes(bytes);
      await _setCachePath(song.id, path);
      return path;
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List?> _fetch(String url) async {
    final res = await http.get(Uri.parse(url),
        headers: {'User-Agent': 'Spotless/1.0'}).timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) return null;
    return res.bodyBytes;
  }

  /// Fetches + embeds the cover into the song's local audio file (ID3 APIC /
  /// MP4 covr) and records it in the DB.
  Future<bool> embedFor(SongRow song) async {
    if (song.artEmbedded == true) return true;
    if (song.localPath == null || !File(song.localPath!).existsSync()) {
      return false;
    }
    String? url = song.albumArtUrl;
    if (url == null || url.isEmpty) {
      url = song.albumArtUrl;
      if (url == null || url.isEmpty) return false;
    }
    try {
      final bytes = await _fetch(url);
      if (bytes == null) return false;
      final ok = await _yt.embedCover(song.localPath!, bytes);
      if (ok) {
        await (_db.update(_db.songs)..where((t) => t.id.equals(song.id)))
            .write(const SongsCompanion(artEmbedded: Value(true)));
      }
      return ok;
    } catch (_) {
      return false;
    }
  }

  /// Background pass over all local songs without embedded art.
  Future<({int done, int failed})> embedAll({
    void Function(int done, int total, String current)? onProgress,
    bool Function()? isCancelled,
  }) async {
    final songs = await (_db.select(_db.songs)
          ..where((t) => t.localPath.isNotNull() & t.artEmbedded.equals(false)))
        .get();
    var done = 0;
    var failed = 0;
    for (final song in songs) {
      if (isCancelled?.call() ?? false) break;
      onProgress?.call(done, songs.length, song.title);
      final ok = await embedFor(song);
      if (ok) {
        done++;
      } else {
        failed++;
      }
    }
    return (done: done, failed: failed);
  }

  Future<void> _setCachePath(String songId, String path) async {
    await (_db.update(_db.songs)..where((t) => t.id.equals(songId)))
        .write(SongsCompanion(albumArtPath: Value(path)));
  }
}
