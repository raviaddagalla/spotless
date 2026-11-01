import 'dart:io';

import 'package:drift/drift.dart' hide Column, isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotless/core/db/app_database.dart';
import 'package:spotless/core/services/library_scanner.dart';
import 'package:spotless/core/models/song_status.dart';

void main() {
  late AppDatabase db;
  late LibraryScanner scanner;
  late Directory root;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    scanner = LibraryScanner(db);
    root = await Directory.systemTemp.createTemp('spotless_scan_');
    Directory('${root.path}${Platform.pathSeparator}music').createSync();
    Directory('${root.path}${Platform.pathSeparator}lyrics').createSync();
  });

  tearDown(() async {
    await db.close();
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  test('rescan preserves user data and clears a deleted local path', () async {
    final music =
        File('${root.path}${Platform.pathSeparator}music${Platform.pathSeparator}abc.mp3')
          ..writeAsBytesSync(const [0, 1, 2]);
    File('${root.path}${Platform.pathSeparator}lyrics${Platform.pathSeparator}abc.LRC')
        .writeAsStringSync('[00:01.00]hello');
    File('${root.path}${Platform.pathSeparator}songs.csv').writeAsStringSync(
      'filename,title,artist,youtube_id\n'
      'abc.mp3,Test Song,Test Artist,yt123\n',
    );

    final first = await scanner.scan(root.path);
    expect(first.downloaded, 1);

    var row = await (db.select(db.songs)
          ..where((s) => s.id.equals('abc')))
        .getSingle();
    expect(row.status, SongStatus.downloaded.name);
    expect(row.localPath, music.path);

    // User-owned state that a rescan must never reset.
    await (db.update(db.songs)..where((s) => s.id.equals('abc'))).write(
      SongsCompanion(
        playCount: const Value(7),
        likedAt: Value(DateTime(2026, 10, 20)),
      ),
    );

    // The local file disappears (user deleted it / storage unmounted).
    music.deleteSync();
    await scanner.scan(root.path);

    row = await (db.select(db.songs)..where((s) => s.id.equals('abc')))
        .getSingle();
    expect(row.localPath, isNull,
        reason: 'a missing file must not keep a stale localPath');
    expect(row.status, SongStatus.streamable.name,
        reason: 'the known YouTube id still makes the track playable');
    expect(row.playCount, 7);
    expect(row.likedAt, isNotNull);

    final lyrics = await (db.select(db.lyricsTable)
          ..where((l) => l.songId.equals('abc')))
        .getSingle();
    expect(lyrics.type, 'lrc',
        reason: 'uppercase .LRC files must match their song id');
  });

  test('a missing file with no YouTube id becomes missing, not downloaded',
      () async {
    final music =
        File('${root.path}${Platform.pathSeparator}music${Platform.pathSeparator}xyz.mp3')
          ..writeAsBytesSync(const [0]);
    File('${root.path}${Platform.pathSeparator}songs.csv').writeAsStringSync(
      'filename,title,artist,youtube_id\n'
      'xyz.mp3,No Source,Test Artist,\n',
    );

    await scanner.scan(root.path);
    music.deleteSync();
    await scanner.scan(root.path);

    final row = await (db.select(db.songs)
          ..where((s) => s.id.equals('xyz')))
        .getSingle();
    expect(row.localPath, isNull);
    expect(row.status, SongStatus.missing.name);
  });
}
