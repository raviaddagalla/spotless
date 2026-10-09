import 'dart:io';

import 'package:drift/drift.dart' hide Column;

import '../csv/csv_parser.dart';
import '../db/app_database.dart';
import '../models/song_status.dart';

class ScanResult {
  final String root;
  final int totalSongs;
  final int downloaded;
  final int streamable;
  final int missing;
  final int lrcLyrics;
  final int txtLyrics;

  const ScanResult({
    required this.root,
    required this.totalSongs,
    required this.downloaded,
    required this.streamable,
    required this.missing,
    required this.lrcLyrics,
    required this.txtLyrics,
  });
}

class LibraryScanner {
  final AppDatabase _db;

  LibraryScanner(this._db);

  static String _norm(String s) => s.trim().toLowerCase();

  /// Maps Spotify export placeholder junk ("null") to an empty string.
  static String _clean(String s) {
    final v = s.trim();
    if (v.isEmpty || v.toLowerCase() == 'null' || v.toLowerCase() == 'none') {
      return '';
    }
    return v;
  }

  /// Scans the user-selected library root and writes everything into the DB.
  /// Layout expected:
  ///   root/
  ///     songs.csv            (id, filename, title, artist, youtube_id, ...)
  ///     sleep.csv / no_sleep.csv (full spotify playlist exports)
  ///     music/*.mp3
  ///     lyrics/*.lrc, *.txt
  Future<ScanResult> scan(
    String rootPath, {
    void Function(int done, int total, String message)? onProgress,
  }) async {
    final root = Directory(rootPath);
    if (!root.existsSync()) {
      throw FileSystemException('Library folder not found', rootPath);
    }

    final musicDir = _findSubdir(root, const ['music', 'Music']) ?? root;
    final lyricsDir = _findSubdir(root, const ['lyrics', 'Lyrics']);

    // 1. mp3 files on disk.
    final mp3ByName = <String, File>{};
    final mp3Files = musicDir
        .listSync(recursive: false)
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.mp3'))
        .toList();
    for (final f in mp3Files) {
      mp3ByName[f.uri.pathSegments.last] = f;
    }

    // 2. songs.csv mapping.
    final songCsvPath = _findFile(root, const ['songs.csv']);
    final songCsvRows = songCsvPath != null
        ? CsvParser.parse(songCsvPath.readAsStringSync()).toMaps()
        : <Map<String, String>>[];

    // 3. playlist exports.
    final playlistRows = <(String, Map<String, String>)>[];
    final sleepCsv = _findFile(root, const ['sleep.csv']);
    final noSleepCsv = _findFile(root, const ['no_sleep.csv']);
    if (sleepCsv != null) {
      playlistRows.addAll(CsvParser.parse(sleepCsv.readAsStringSync())
          .toMaps()
          .map((r) => ('sleep', r)));
    }
    if (noSleepCsv != null) {
      playlistRows.addAll(CsvParser.parse(noSleepCsv.readAsStringSync())
          .toMaps()
          .map((r) => ('no_sleep', r)));
    }

    // 4. lyrics files.
    final lrcByBase = <String, File>{};
    final txtByBase = <String, File>{};
    if (lyricsDir != null) {
      for (final f in lyricsDir.listSync(recursive: false).whereType<File>()) {
        final name = f.uri.pathSegments.last.toLowerCase();
        final base = f.uri.pathSegments.last.replaceAll(RegExp(r'\.(lrc|txt)$'), '');
        if (name.endsWith('.lrc')) lrcByBase[base] = f;
        if (name.endsWith('.txt')) txtByBase[base] = f;
      }
    }

    // Build a map: normalized title|artist -> row + order.
    final songRowsByKey = <String, (Map<String, String> row, int order)>{
      for (var i = 0; i < songCsvRows.length; i++)
        '${_norm(songCsvRows[i]['title'] ?? '')}|${_norm(songCsvRows[i]['artist'] ?? '')}':
            (songCsvRows[i], i),
    };

    final total = (songCsvRows.isNotEmpty ? songCsvRows.length : 0) + playlistRows.length;
    var done = 0;

    void progress(String msg) {
      done++;
      onProgress?.call(done, total, msg);
    }

    final songsToInsert = <SongsCompanion>[];
    final lyricsToInsert = <LyricsTableCompanion>[];

    // ---- Pass A: songs.csv songs ----
    for (var i = 0; i < songCsvRows.length; i++) {
      final r = songCsvRows[i];
      final filename = (r['filename'] ?? '').trim();
      final id = filename.replaceAll(RegExp(r'\.mp3$'), '');
      final localFile = filename.isNotEmpty ? mp3ByName[filename] : null;
      final baseName = id;

      final lrc = lrcByBase[baseName];
      final txt = txtByBase[baseName];
      if (lrc != null) {
        lyricsToInsert.add(LyricsTableCompanion.insert(
          songId: id,
          type: 'lrc',
          content: lrc.readAsStringSync(),
        ));
      } else if (txt != null) {
        lyricsToInsert.add(LyricsTableCompanion.insert(
          songId: id,
          type: 'txt',
          content: txt.readAsStringSync(),
        ));
      }

      songsToInsert.add(SongsCompanion.insert(
        id: id,
        title: _clean(r['title'] ?? ''),
        filename: Value(filename.isEmpty ? null : filename),
        artist: Value(_clean(r['artist'] ?? '')),
        youtubeId: Value((r['youtube_id'] ?? '').isEmpty ? null : r['youtube_id']),
        localPath: Value(localFile?.path),
        status: Value(localFile != null
            ? SongStatus.downloaded.name
            : SongStatus.streamable.name),
        albumArtUrl: const Value(null),
        error: const Value(null),
      ));
      progress(r['title'] ?? filename);
    }

    // ---- Pass B: playlist-only songs (metadata join) ----
    // Metadata updates for matched songs are collected here and applied AFTER
    // the batch insert below — insertOrReplace would otherwise wipe them.
    // Stale pl: rows from previous scans (whose playlists no longer produce a
    // companion) are dropped first so they can't linger as duplicates.
    await (_db.delete(_db.songs)..where((t) => t.id.like('pl:%'))).go();
    final playlistMetaUpdates =
        <(String songId, String playlist, Map<String, String> r, int order)>[];
    for (var p = 0; p < playlistRows.length; p++) {
      final (playlist, r) = playlistRows[p];
      final title = _clean(r['Track Name'] ?? '');
      final artist = _clean(r['Artist Name(s)'] ?? '');
      final key = '${_norm(title)}|${_norm(artist)}';

      final existing = songRowsByKey[key];
      if (existing != null) {
        final songRow = existing.$1;
        final songId = (songRow['filename'] ?? '').replaceAll(RegExp(r'\.mp3$'), '');
        playlistMetaUpdates.add((songId, playlist, r, p));
        progress('$title — $artist');
        continue;
      }

      final id = 'pl:${r['Track URI'] ?? 'p$p'}';
      final lrc = lrcByBase['pl:${r['Track URI'] ?? 'p$p'}'];
      final txt = txtByBase['pl:${r['Track URI'] ?? 'p$p'}'];
      if (lrc != null) {
        lyricsToInsert.add(LyricsTableCompanion.insert(
          songId: id,
          type: 'lrc',
          content: lrc.readAsStringSync(),
        ));
      } else if (txt != null) {
        lyricsToInsert.add(LyricsTableCompanion.insert(
          songId: id,
          type: 'txt',
          content: txt.readAsStringSync(),
        ));
      }

      songsToInsert.add(SongsCompanion.insert(
        id: id,
        title: title,
        artist: Value(artist),
        localPath: const Value(null),
        status: Value(SongStatus.missing.name),
        durationMs: Value(_intOrNull(r['Track Duration (ms)'])),
        albumArtUrl: Value((r['Album Image URL'] ?? '').isEmpty
            ? null
            : r['Album Image URL']),
        trackUri: Value((r['Track URI'] ?? '').isEmpty ? null : r['Track URI']),
        isrc: Value((r['ISRC'] ?? '').isEmpty ? null : r['ISRC']),
        trackNumber: Value(_intOrNull(r['Track Number'])),
        explicit: Value(r['Explicit']?.toLowerCase() == 'true'),
        popularity: Value(_intOrNull(r['Popularity'])),
        genres: Value(
            (r['Artist Genres'] ?? '').isEmpty ? null : r['Artist Genres']),
        danceability: Value(_doubleOrNull(r['Danceability'])),
        energy: Value(_doubleOrNull(r['Energy'])),
        key: Value(_intOrNull(r['Key'])),
        loudness: Value(_doubleOrNull(r['Loudness'])),
        mode: Value(_intOrNull(r['Mode'])),
        speechiness: Value(_doubleOrNull(r['Speechiness'])),
        acousticness: Value(_doubleOrNull(r['Acousticness'])),
        instrumentalness: Value(_doubleOrNull(r['Instrumentalness'])),
        liveness: Value(_doubleOrNull(r['Liveness'])),
        valence: Value(_doubleOrNull(r['Valence'])),
        tempo: Value(_doubleOrNull(r['Tempo'])),
        timeSignature: Value(_intOrNull(r['Time Signature'])),
        addedAt: Value(DateTime.tryParse(r['Added At'] ?? '')),
        sleepOrder: Value(playlist == 'sleep' ? p : null),
        noSleepOrder: Value(playlist == 'no_sleep' ? p : null),
        error: const Value(null),
      ));
      progress('$title — $artist');
    }

    await _db.batch((b) {
      b.insertAll(_db.songs, songsToInsert, mode: InsertMode.insertOrReplace);
      b.insertAll(_db.lyricsTable, lyricsToInsert, mode: InsertMode.insertOrReplace);
    });

    for (final (songId, playlist, r, order) in playlistMetaUpdates) {
      await _applyPlaylistMeta(songId, playlist, r, order);
    }

    final downloadedCount =
        songsToInsert.where((s) => s.status.value == SongStatus.downloaded.name).length;
    final streamableCount =
        songsToInsert.where((s) => s.status.value == SongStatus.streamable.name).length;
    final missingCount =
        songsToInsert.where((s) => s.status.value == SongStatus.missing.name).length;

    return ScanResult(
      root: rootPath,
      totalSongs: songsToInsert.length,
      downloaded: downloadedCount,
      streamable: streamableCount,
      missing: missingCount,
      lrcLyrics: lrcByBase.length,
      txtLyrics: txtByBase.length,
    );
  }

  Future<void> _applyPlaylistMeta(
      String songId, String playlist, Map<String, String> r, int? order) async {
    await (_db.update(_db.songs)..where((t) => t.id.equals(songId))).write(
      SongsCompanion(
        durationMs: Value(_intOrNull(r['Track Duration (ms)'])),
        albumArtUrl: Value(
            (r['Album Image URL'] ?? '').isEmpty ? null : r['Album Image URL']),
        trackUri:
            Value((r['Track URI'] ?? '').isEmpty ? null : r['Track URI']),
        isrc: Value((r['ISRC'] ?? '').isEmpty ? null : r['ISRC']),
        trackNumber: Value(_intOrNull(r['Track Number'])),
        explicit: Value(r['Explicit']?.toLowerCase() == 'true'),
        popularity: Value(_intOrNull(r['Popularity'])),
        genres:
            Value((r['Artist Genres'] ?? '').isEmpty ? null : r['Artist Genres']),
        danceability: Value(_doubleOrNull(r['Danceability'])),
        energy: Value(_doubleOrNull(r['Energy'])),
        key: Value(_intOrNull(r['Key'])),
        loudness: Value(_doubleOrNull(r['Loudness'])),
        mode: Value(_intOrNull(r['Mode'])),
        speechiness: Value(_doubleOrNull(r['Speechiness'])),
        acousticness: Value(_doubleOrNull(r['Acousticness'])),
        instrumentalness: Value(_doubleOrNull(r['Instrumentalness'])),
        liveness: Value(_doubleOrNull(r['Liveness'])),
        valence: Value(_doubleOrNull(r['Valence'])),
        tempo: Value(_doubleOrNull(r['Tempo'])),
        timeSignature: Value(_intOrNull(r['Time Signature'])),
        addedAt: Value(DateTime.tryParse(r['Added At'] ?? '')),
        sleepOrder: Value(playlist == 'sleep' ? order ?? 0 : null),
        noSleepOrder: Value(playlist == 'no_sleep' ? order ?? 0 : null),
      ),
    );
  }

  Directory? _findSubdir(Directory root, List<String> names) {
    for (final name in names) {
      final d = Directory('${root.path}${Platform.pathSeparator}$name');
      if (d.existsSync()) return d;
    }
    return null;
  }

  File? _findFile(Directory root, List<String> names) {
    for (final name in names) {
      final f = File('${root.path}${Platform.pathSeparator}$name');
      if (f.existsSync()) return f;
    }
    return null;
  }

  static int? _intOrNull(String? s) {
    final v = int.tryParse((s ?? '').trim());
    return v;
  }

  static double? _doubleOrNull(String? s) {
    final v = double.tryParse((s ?? '').trim());
    return v;
  }
}
