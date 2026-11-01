import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:spotless/core/db/app_database.dart';
import 'package:spotless/core/services/download_manager.dart';
import 'package:spotless/core/services/downloader.dart';

SongRow _song(String id) => SongRow(
      id: id,
      title: 'Track $id',
      artist: 'Artist',
      status: 'streamable',
      artEmbedded: false,
      explicit: false,
      playCount: 0,
    );

void main() {
  group('DownloadManager', () {
    test('runs queued downloads one at a time and reports progress', () async {
      final started = <String>[];
      final gates = <String, Completer<DownloadResult>>{};
      final progress = <double>[];

      final manager = DownloadManager(
        perform: (song, {onProgress}) {
          started.add(song.id);
          onProgress?.call(0.5);
          final gate = Completer<DownloadResult>();
          gates[song.id] = gate;
          return gate.future;
        },
        cancelRemote: () async => true,
      );

      final first = manager.enqueue(_song('1'), onProgress: progress.add);
      final second = manager.enqueue(_song('2'));

      await Future<void>.delayed(Duration.zero);
      expect(started, ['1'],
          reason: 'the second download must wait for the first to finish');
      expect(manager.tasks.length, 2);
      expect(progress, [0.5]);

      gates['1']!.complete(const DownloadResult(path: '/tmp/1.mp3'));
      await first;
      await Future<void>.delayed(Duration.zero);

      expect(started, ['1', '2']);
      expect(manager.tasks.first.status, DownloadTaskStatus.completed);

      gates['2']!.complete(const DownloadResult(path: '/tmp/2.mp3'));
      await second;
      expect(manager.tasks.last.status, DownloadTaskStatus.completed);
    });

    test('cancelling a running task marks it cancelled and rejects its future',
        () async {
      final started = Completer<void>();
      var remoteCancelCalls = 0;

      final manager = DownloadManager(
        perform: (song, {onProgress}) async {
          started.complete();
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return const DownloadResult(path: '/tmp/1.mp3');
        },
        cancelRemote: () async {
          remoteCancelCalls++;
          return true;
        },
      );

      final future = manager.enqueue(_song('1'));
      await started.future;
      final task = manager.tasks.single;

      await manager.cancel(task);
      expect(remoteCancelCalls, 1);
      await expectLater(future, throwsA(isA<DownloadCancelledException>()));
      expect(task.status, DownloadTaskStatus.cancelled);
      expect(task.cancelRequested, isTrue);
    });

    test('retry queues a fresh task after a failure', () async {
      var attempts = 0;
      final manager = DownloadManager(
        perform: (song, {onProgress}) async {
          attempts++;
          if (attempts == 1) throw StateError('network down');
          return const DownloadResult(path: '/tmp/1.mp3');
        },
        cancelRemote: () async => true,
      );

      final failed = manager.enqueue(_song('1'));
      await expectLater(failed, throwsA(isA<StateError>()));
      final failedTask = manager.tasks.single;
      expect(failedTask.status, DownloadTaskStatus.failed);

      final result = await manager.retry(failedTask);
      expect(result.path, '/tmp/1.mp3');
      expect(attempts, 2);
      expect(manager.tasks, hasLength(2));
      expect(manager.tasks.last.status, DownloadTaskStatus.completed);
    });

    test('retry is a no-op while the same song is still queued', () async {
      final gate = Completer<DownloadResult>();
      var starts = 0;
      final manager = DownloadManager(
        perform: (song, {onProgress}) {
          starts++;
          return gate.future;
        },
        cancelRemote: () async => true,
      );

      final first = manager.enqueue(_song('1'));
      final again = manager.enqueue(_song('1'));
      expect(starts, 1);
      expect(manager.tasks, hasLength(1));

      gate.complete(const DownloadResult(path: '/tmp/1.mp3'));
      await first;
      await again;
    });
  });
}
