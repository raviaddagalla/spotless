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

/// Scans the user-selected library folder into SQLite.
///
/// Rescanning is deliberately *non-destructive*: it updates catalog metadata
/// in place so play counts, ratings, likes, cached covers and in-app downloads
/// survive. The previous implementation used `insertOrReplace` for every row,
/// which silently reset those user-owned fields.
class LibraryScanner {
  final AppDatabase _db;

  LibraryScanner(this._db);

  static const _audioExtensions = {
    '.mp3',
    '.m4a',
    '.aac',
    '.flac',
    '.ogg',
    '.opus',
    '.wav',
    '.webm',
  };

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
  ///     music/*.mp3 (and m4a/flac/ogg/opus/wav)
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

    // 1. Audio files on disk. Recursive so artist/album subfolders work.
    final audioByBase = <String, File>{};
    final audioByName = <String, File>{};
    final audioFiles = musicDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) {
      final lower = f.path.toLowerCase();
      return _audioExtensions.any(lower.endsWith);
    }).toList();
    for (final f in audioFiles) {
      final name = f.uri.pathSegments.last;
      audioByName[name.toLowerCase()] = f;
      final dot = name.lastIndexOf('.');
      final base = dot > 0 ? name.substring(0, dot) : name;
      audioByBase.putIfAbsent(base.toLowerCase(), () => f);
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
      for (final f in lyricsDir.listSync(recursive: true).whereType<File>()) {
        final name = f.uri.pathSegments.last.toLowerCase();
        final base = f.uri.pathSegments.last
            .replaceAll(RegExp(r'\.(lrc|txt)$', caseSensitive: false), '')
            .toLowerCase();
        if (name.endsWith('.lrc')) lrcByBase[base] = f;
        if (name.endsWith('.txt')) txtByBase[base] = f;
      }
    }

    // Build a map: normalized title|artist -> csv row + order.
    final songRowsByKey = <String, (Map<String, String> row, int order)>{
      for (var i = 0; i < songCsvRows.length; i++)
        '${_norm(songCsvRows[i]['title'] ?? '')}|${_norm(songCsvRows[i]['artist'] ?? '')}':
            (songCsvRows[i], i),
    };

    final existing = <String, SongRow>{
      for (final s in await _db.select(_db.songs).get()) s.id: s,
    };

    final total = songCsvRows.length + playlistRows.length;
    var done = 0;

    void progress(String msg) {
      done++;
      onProgress?.call(done, total, msg);
    }

    final lyricsToInsert = <LyricsTableCompanion>[];
    final sleepSongIds = <String>[];
    final noSleepSongIds = <String>[];
    final currentPlaylistOnlyIds = <String>{};
    final seenSleep = <String>{};
    final seenNoSleep = <String>{};

    var downloaded = 0;
    var streamable = 0;
    var missing = 0;

    // ---- Pass A: songs.csv songs ----
    for (var i = 0; i < songCsvRows.length; i++) {
      final r = songCsvRows[i];
      final filename = (r['filename'] ?? '').trim();
      final id = filename.replaceAll(RegExp(r'\.(mp3|m4a|aac|flac|ogg|opus|wav|webm)$',
          caseSensitive: false), '');
      if (id.isEmpty) {
        progress('Skipped row (no filename)');
        continue;
      }
      final old = existing[id];
      final localFile = filename.isNotEmpty
          ? (audioByName[filename.toLowerCase()] ??
              audioByBase[id.toLowerCase()])
          : audioByBase[id.toLowerCase()];
      final preservedPath = _existingFile(old?.localPath);
      final localPath = localFile?.path ?? preservedPath;
      final youtubeId =
          (r['youtube_id'] ?? '').trim().isEmpty ? null : r['youtube_id']!.trim();
      // A path that is no longer on disk must not keep a row marked
      // "downloaded": playback would fail and the UI would hide the stream
      // fallback. Only retain a non-downloaded status when there is still a
      // known YouTube source.
      final status = localPath != null
          ? SongStatus.downloaded.name
          : youtubeId != null
              ? SongStatus.streamable.name
              : (old?.status == SongStatus.downloaded.name
                  ? SongStatus.missing.name
                  : (old?.status ?? SongStatus.missing.name));

      if (status == SongStatus.downloaded.name) {
        downloaded++;
      } else if (status == SongStatus.streamable.name) {
        streamable++;
      } else {
        missing++;
      }

      final lrc = lrcByBase[id.toLowerCase()];
      final txt = txtByBase[id.toLowerCase()];
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

      final meta = _mergeCompanion(
        old: old,
        m: _SongMeta(
          title: _clean(r['title'] ?? ''),
          artist: _clean(r['artist'] ?? ''),
          filename: filename.isEmpty ? null : filename,
          youtubeId: youtubeId,
          localPath: localPath,
          status: status,
        ),
      );

      if (old == null) {
        await _db.into(_db.songs).insert(meta.insertCompanion(id));
      } else {
        await (_db.update(_db.songs)..where((t) => t.id.equals(id)))
            .write(meta.updateCompanion);
      }
      progress(r['title'] ?? filename);
    }

    // ---- Pass B: playlist-only songs (metadata join) ----
    for (var p = 0; p < playlistRows.length; p++) {
      final (playlist, r) = playlistRows[p];
      final title = _clean(r['Track Name'] ?? '');
      final artist = _clean(r['Artist Name(s)'] ?? '');
      final key = '${_norm(title)}|${_norm(artist)}';

      final existingMatch = songRowsByKey[key];
      final matchedId = existingMatch == null
          ? ''
          : (existingMatch.$1['filename'] ?? '').replaceAll(
              RegExp(r'\.(mp3|m4a|aac|flac|ogg|opus|wav|webm)$',
                  caseSensitive: false),
              '');
      String songId;
      if (existingMatch != null && matchedId.isNotEmpty) {
        songId = matchedId;
        // Refresh the richer Spotify metadata onto the local file row, but
        // never touch its download status/path.
        await _updateMetadataOnly(songId, r, playlist, p);
      } else {
        final trackUri = (r['Track URI'] ?? '').trim();
        songId = 'pl:${trackUri.isEmpty ? 'p$p' : trackUri}';
        currentPlaylistOnlyIds.add(songId);
        final old = existing[songId];
        if (old == null) {
          await _db.into(_db.songs).insert(
                _playlistOnlyCompanion(songId, r, playlist, p)
                    .insertCompanion(songId),
              );
        } else {
          // Preserve localPath/status/playCount/likes; only catalog fields
          // are refreshed by this playlist export.
          await _updateMetadataOnly(songId, r, playlist, p);
        }
        final lrc = lrcByBase[songId.toLowerCase()];
        final txt = txtByBase[songId.toLowerCase()];
        if (lrc != null) {
          lyricsToInsert.add(LyricsTableCompanion.insert(
            songId: songId,
            type: 'lrc',
            content: lrc.readAsStringSync(),
          ));
        } else if (txt != null) {
          lyricsToInsert.add(LyricsTableCompanion.insert(
            songId: songId,
            type: 'txt',
            content: txt.readAsStringSync(),
          ));
        }
      }

      if (playlist == 'sleep') {
        if (seenSleep.add(songId)) sleepSongIds.add(songId);
      } else if (seenNoSleep.add(songId)) {
        noSleepSongIds.add(songId);
      }
      progress('$title — $artist');
    }

    // ---- Lyrics ----
    if (lyricsToInsert.isNotEmpty) {
      await _db.batch((b) {
        b.insertAll(_db.lyricsTable, lyricsToInsert,
            mode: InsertMode.insertOrReplace);
      });
    }

    // ---- Rebuild imported playlists from their source CSVs ----
    if (sleepSongIds.isNotEmpty) {
      await _syncImportedPlaylist('sleep', 'Sleep', sleepSongIds);
    }
    if (noSleepSongIds.isNotEmpty) {
      await _syncImportedPlaylist('no_sleep', 'No Sleep', noSleepSongIds);
    }

    // ---- Remove playlist-only stubs no longer present in the CSVs ----
    final stale = existing.values
        .where((s) =>
            s.id.startsWith('pl:') &&
            !currentPlaylistOnlyIds.contains(s.id) &&
            s.localPath == null &&
            s.status != SongStatus.downloaded.name &&
            s.likedAt == null &&
            s.playCount == 0)
        .map((s) => s.id)
        .toList();
    if (stale.isNotEmpty) {
      await (_db.delete(_db.playlistSongs)
            ..where((p) => p.songId.isIn(stale)))
          .go();
      await (_db.delete(_db.songs)..where((s) => s.id.isIn(stale))).go();
    }

    return ScanResult(
      root: rootPath,
      totalSongs: songCsvRows.length + currentPlaylistOnlyIds.length,
      downloaded: downloaded,
      streamable: streamable,
      missing: missing,
      lrcLyrics: lrcByBase.length,
      txtLyrics: txtByBase.length,
    );
  }

  Future<void> _syncImportedPlaylist(
      String id, String name, List<String> songIds) async {
    final now = DateTime.now();
    await _db.into(_db.playlists).insert(
          PlaylistsCompanion.insert(id: id, name: name, createdAt: now),
          mode: InsertMode.insertOrIgnore,
        );
    await _db.transaction(() async {
      await (_db.delete(_db.playlistSongs)
            ..where((p) => p.playlistId.equals(id)))
          .go();
      await _db.batch((b) {
        b.insertAll(
          _db.playlistSongs,
          [
            for (var i = 0; i < songIds.length; i++)
              PlaylistSongsCompanion.insert(
                playlistId: id,
                songId: songIds[i],
                position: i,
              ),
          ],
          mode: InsertMode.insertOrIgnore,
        );
      });
    });
  }

  Future<void> _updateMetadataOnly(
      String songId, Map<String, String> r, String playlist, int order) async {
    final old = await (_db.select(_db.songs)
          ..where((t) => t.id.equals(songId)))
        .getSingleOrNull();
    if (old == null) return;
    await (_db.update(_db.songs)..where((t) => t.id.equals(songId))).write(
      SongsCompanion(
        durationMs: _valueOrKeep(_intOrNull(r['Track Duration (ms)']), old.durationMs),
        album: _valueOrKeep(
            _clean(r['Album Name'] ?? '').isEmpty
                ? null
                : _clean(r['Album Name'] ?? ''),
            old.album),
        albumArtUrl: _valueOrKeep(
            (r['Album Image URL'] ?? '').isEmpty
                ? null
                : r['Album Image URL'],
            old.albumArtUrl),
        trackUri: _valueOrKeep(
            (r['Track URI'] ?? '').isEmpty ? null : r['Track URI'],
            old.trackUri),
        isrc: _valueOrKeep(
            (r['ISRC'] ?? '').isEmpty ? null : r['ISRC'], old.isrc),
        trackNumber:
            _valueOrKeep(_intOrNull(r['Track Number']), old.trackNumber),
        explicit: Value(r['Explicit']?.toLowerCase() == 'true'),
        popularity:
            _valueOrKeep(_intOrNull(r['Popularity']), old.popularity),
        genres: _valueOrKeep(
            (r['Artist Genres'] ?? '').isEmpty ? null : r['Artist Genres'],
            old.genres),
        danceability: _valueOrKeep(
            _doubleOrNull(r['Danceability']), old.danceability),
        energy: _valueOrKeep(_doubleOrNull(r['Energy']), old.energy),
        key: _valueOrKeep(_intOrNull(r['Key']), old.key),
        loudness: _valueOrKeep(_doubleOrNull(r['Loudness']), old.loudness),
        mode: _valueOrKeep(_intOrNull(r['Mode']), old.mode),
        speechiness:
            _valueOrKeep(_doubleOrNull(r['Speechiness']), old.speechiness),
        acousticness:
            _valueOrKeep(_doubleOrNull(r['Acousticness']), old.acousticness),
        instrumentalness: _valueOrKeep(
            _doubleOrNull(r['Instrumentalness']), old.instrumentalness),
        liveness: _valueOrKeep(_doubleOrNull(r['Liveness']), old.liveness),
        valence: _valueOrKeep(_doubleOrNull(r['Valence']), old.valence),
        tempo: _valueOrKeep(_doubleOrNull(r['Tempo']), old.tempo),
        timeSignature: _valueOrKeep(
            _intOrNull(r['Time Signature']), old.timeSignature),
        addedAt: _valueOrKeep(
            DateTime.tryParse(r['Added At'] ?? ''), old.addedAt),
        sleepOrder: Value(playlist == 'sleep' ? order : old.sleepOrder),
        noSleepOrder: Value(playlist == 'no_sleep' ? order : old.noSleepOrder),
      ),
    );
  }

  /// Builds a full row for a catalog-only track (no local audio file).
  _MergedSong _playlistOnlyCompanion(
      String id, Map<String, String> r, String playlist, int order) {
    return _SongMeta(
      title: _clean(r['Track Name'] ?? ''),
      artist: _clean(r['Artist Name(s)'] ?? ''),
      filename: null,
      youtubeId: null,
      localPath: null,
      status: SongStatus.missing.name,
      album: _clean(r['Album Name'] ?? '').isEmpty
          ? null
          : _clean(r['Album Name'] ?? ''),
      durationMs: _intOrNull(r['Track Duration (ms)']),
      albumArtUrl: (r['Album Image URL'] ?? '').isEmpty
          ? null
          : r['Album Image URL'],
      trackUri: (r['Track URI'] ?? '').isEmpty ? null : r['Track URI'],
      isrc: (r['ISRC'] ?? '').isEmpty ? null : r['ISRC'],
      trackNumber: _intOrNull(r['Track Number']),
      explicit: r['Explicit']?.toLowerCase() == 'true',
      popularity: _intOrNull(r['Popularity']),
      genres: (r['Artist Genres'] ?? '').isEmpty ? null : r['Artist Genres'],
      danceability: _doubleOrNull(r['Danceability']),
      energy: _doubleOrNull(r['Energy']),
      key: _intOrNull(r['Key']),
      loudness: _doubleOrNull(r['Loudness']),
      mode: _intOrNull(r['Mode']),
      speechiness: _doubleOrNull(r['Speechiness']),
      acousticness: _doubleOrNull(r['Acousticness']),
      instrumentalness: _doubleOrNull(r['Instrumentalness']),
      liveness: _doubleOrNull(r['Liveness']),
      valence: _doubleOrNull(r['Valence']),
      tempo: _doubleOrNull(r['Tempo']),
      timeSignature: _intOrNull(r['Time Signature']),
      addedAt: DateTime.tryParse(r['Added At'] ?? ''),
      sleepOrder: playlist == 'sleep' ? order : null,
      noSleepOrder: playlist == 'no_sleep' ? order : null,
    ).merged(old: null);
  }

  _MergedSong _mergeCompanion({required SongRow? old, required _SongMeta m}) {
    return m.merged(old: old);
  }

  String? _existingFile(String? path) {
    if (path == null || path.isEmpty) return null;
    return File(path).existsSync() ? path : null;
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

  static int? _intOrNull(String? s) => int.tryParse((s ?? '').trim());

  static double? _doubleOrNull(String? s) => double.tryParse((s ?? '').trim());

  static Value<T?> _valueOrKeep<T>(T? incoming, T? current) {
    if (incoming != null) return Value<T?>(incoming);
    if (current != null) return Value<T?>(current);
    return Value<T?>(null);
  }
}

/// Metadata collected from a `songs.csv` or Spotify export row.
class _SongMeta {
  final String title;
  final String artist;
  final String? filename;
  final String? youtubeId;
  final String? localPath;
  final String status;
  final String? album;
  final int? durationMs;
  final String? albumArtUrl;
  final String? trackUri;
  final String? isrc;
  final int? trackNumber;
  final bool explicit;
  final int? popularity;
  final String? genres;
  final double? danceability;
  final double? energy;
  final int? key;
  final double? loudness;
  final int? mode;
  final double? speechiness;
  final double? acousticness;
  final double? instrumentalness;
  final double? liveness;
  final double? valence;
  final double? tempo;
  final int? timeSignature;
  final DateTime? addedAt;
  final int? sleepOrder;
  final int? noSleepOrder;

  const _SongMeta({
    required this.title,
    required this.artist,
    this.filename,
    this.youtubeId,
    this.localPath,
    required this.status,
    this.album,
    this.durationMs,
    this.albumArtUrl,
    this.trackUri,
    this.isrc,
    this.trackNumber,
    this.explicit = false,
    this.popularity,
    this.genres,
    this.danceability,
    this.energy,
    this.key,
    this.loudness,
    this.mode,
    this.speechiness,
    this.acousticness,
    this.instrumentalness,
    this.liveness,
    this.valence,
    this.tempo,
    this.timeSignature,
    this.addedAt,
    this.sleepOrder,
    this.noSleepOrder,
  });

  _MergedSong merged({required SongRow? old}) {
    return _MergedSong(
      title: title.isEmpty ? (old?.title ?? 'Untitled') : title,
      artist: artist.isEmpty ? (old?.artist ?? '') : artist,
      filename: filename ?? old?.filename,
      youtubeId: youtubeId ?? old?.youtubeId,
      // The caller has already resolved the definitive on-disk path (and
      // used the old path only if that file still exists). Falling back to
      // old?.localPath here would resurrect a deleted file forever.
      localPath: localPath,
      status: status.isEmpty ? (old?.status ?? 'missing') : status,
      album: album ?? old?.album,
      durationMs: durationMs ?? old?.durationMs,
      albumArtUrl: albumArtUrl ?? old?.albumArtUrl,
      albumArtPath: old?.albumArtPath,
      artEmbedded: old?.artEmbedded ?? false,
      trackUri: trackUri ?? old?.trackUri,
      isrc: isrc ?? old?.isrc,
      trackNumber: trackNumber ?? old?.trackNumber,
      explicit: explicit,
      popularity: popularity ?? old?.popularity,
      genres: genres ?? old?.genres,
      danceability: danceability ?? old?.danceability,
      energy: energy ?? old?.energy,
      key: key ?? old?.key,
      loudness: loudness ?? old?.loudness,
      mode: mode ?? old?.mode,
      speechiness: speechiness ?? old?.speechiness,
      acousticness: acousticness ?? old?.acousticness,
      instrumentalness: instrumentalness ?? old?.instrumentalness,
      liveness: liveness ?? old?.liveness,
      valence: valence ?? old?.valence,
      tempo: tempo ?? old?.tempo,
      timeSignature: timeSignature ?? old?.timeSignature,
      addedAt: addedAt ?? old?.addedAt,
      sleepOrder: sleepOrder ?? old?.sleepOrder,
      noSleepOrder: noSleepOrder ?? old?.noSleepOrder,
      lastPlayedAt: old?.lastPlayedAt,
      playCount: old?.playCount ?? 0,
      likedAt: old?.likedAt,
      resolvedYtTitle: old?.resolvedYtTitle,
      error: old?.error,
    );
  }
}

class _MergedSong {
  final String title;
  final String artist;
  final String? filename;
  final String? youtubeId;
  final String? localPath;
  final String status;
  final String? album;
  final int? durationMs;
  final String? albumArtUrl;
  final String? albumArtPath;
  final bool artEmbedded;
  final String? trackUri;
  final String? isrc;
  final int? trackNumber;
  final bool explicit;
  final int? popularity;
  final String? genres;
  final double? danceability;
  final double? energy;
  final int? key;
  final double? loudness;
  final int? mode;
  final double? speechiness;
  final double? acousticness;
  final double? instrumentalness;
  final double? liveness;
  final double? valence;
  final double? tempo;
  final int? timeSignature;
  final DateTime? addedAt;
  final int? sleepOrder;
  final int? noSleepOrder;
  final DateTime? lastPlayedAt;
  final int playCount;
  final DateTime? likedAt;
  final String? resolvedYtTitle;
  final String? error;

  const _MergedSong({
    required this.title,
    required this.artist,
    this.filename,
    this.youtubeId,
    this.localPath,
    required this.status,
    this.album,
    this.durationMs,
    this.albumArtUrl,
    this.albumArtPath,
    required this.artEmbedded,
    this.trackUri,
    this.isrc,
    this.trackNumber,
    required this.explicit,
    this.popularity,
    this.genres,
    this.danceability,
    this.energy,
    this.key,
    this.loudness,
    this.mode,
    this.speechiness,
    this.acousticness,
    this.instrumentalness,
    this.liveness,
    this.valence,
    this.tempo,
    this.timeSignature,
    this.addedAt,
    this.sleepOrder,
    this.noSleepOrder,
    this.lastPlayedAt,
    required this.playCount,
    this.likedAt,
    this.resolvedYtTitle,
    this.error,
  });

  SongsCompanion insertCompanion(String id) {
    return SongsCompanion.insert(
      id: id,
      title: title,
      artist: Value(artist),
      filename: Value(filename),
      youtubeId: Value(youtubeId),
      localPath: Value(localPath),
      status: Value(status),
      album: Value(album),
      durationMs: Value(durationMs),
      albumArtUrl: Value(albumArtUrl),
      albumArtPath: Value(albumArtPath),
      artEmbedded: Value(artEmbedded),
      trackUri: Value(trackUri),
      isrc: Value(isrc),
      trackNumber: Value(trackNumber),
      explicit: Value(explicit),
      popularity: Value(popularity),
      genres: Value(genres),
      danceability: Value(danceability),
      energy: Value(energy),
      key: Value(key),
      loudness: Value(loudness),
      mode: Value(mode),
      speechiness: Value(speechiness),
      acousticness: Value(acousticness),
      instrumentalness: Value(instrumentalness),
      liveness: Value(liveness),
      valence: Value(valence),
      tempo: Value(tempo),
      timeSignature: Value(timeSignature),
      addedAt: Value(addedAt),
      sleepOrder: Value(sleepOrder),
      noSleepOrder: Value(noSleepOrder),
      lastPlayedAt: Value(lastPlayedAt),
      playCount: Value(playCount),
      likedAt: Value(likedAt),
      resolvedYtTitle: Value(resolvedYtTitle),
      error: Value(error),
    );
  }

  SongsCompanion get updateCompanion => SongsCompanion(
        title: Value(title),
        artist: Value(artist),
        filename: Value(filename),
        youtubeId: Value(youtubeId),
        localPath: Value(localPath),
        status: Value(status),
        album: Value(album),
        durationMs: Value(durationMs),
        albumArtUrl: Value(albumArtUrl),
        albumArtPath: Value(albumArtPath),
        artEmbedded: Value(artEmbedded),
        trackUri: Value(trackUri),
        isrc: Value(isrc),
        trackNumber: Value(trackNumber),
        explicit: Value(explicit),
        popularity: Value(popularity),
        genres: Value(genres),
        danceability: Value(danceability),
        energy: Value(energy),
        key: Value(key),
        loudness: Value(loudness),
        mode: Value(mode),
        speechiness: Value(speechiness),
        acousticness: Value(acousticness),
        instrumentalness: Value(instrumentalness),
        liveness: Value(liveness),
        valence: Value(valence),
        tempo: Value(tempo),
        timeSignature: Value(timeSignature),
        addedAt: Value(addedAt),
        sleepOrder: Value(sleepOrder),
        noSleepOrder: Value(noSleepOrder),
        lastPlayedAt: Value(lastPlayedAt),
        playCount: Value(playCount),
        likedAt: Value(likedAt),
        resolvedYtTitle: Value(resolvedYtTitle),
        error: Value(error),
      );
}
