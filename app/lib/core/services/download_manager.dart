import 'dart:async';

import 'package:flutter/foundation.dart';

import '../db/app_database.dart';
import 'downloader.dart';

enum DownloadTaskStatus { queued, running, completed, failed, cancelled }

class DownloadCancelledException implements Exception {
  const DownloadCancelledException();

  @override
  String toString() => 'Download cancelled';
}

class DownloadTask {
  final int id;
  final SongRow song;
  DownloadTaskStatus status;
  double progress;
  String? error;
  bool cancelRequested;
  DownloadResult? result;
  final List<void Function(double)> progressListeners = [];

  final Completer<DownloadResult> _completer = Completer<DownloadResult>();

  DownloadTask({
    required this.id,
    required this.song,
    this.status = DownloadTaskStatus.queued,
    this.progress = 0.0,
    this.error,
    this.cancelRequested = false,
    this.result,
  });

  Future<DownloadResult> get done => _completer.future;
  bool get isFinished =>
      status == DownloadTaskStatus.completed ||
      status == DownloadTaskStatus.failed ||
      status == DownloadTaskStatus.cancelled;

  void _complete(DownloadResult r) {
    if (!_completer.isCompleted) _completer.complete(r);
  }

  void _fail(Object error) {
    if (!_completer.isCompleted) _completer.completeError(error);
  }

  void _cancel() {
    if (!_completer.isCompleted) {
      _completer.completeError(const DownloadCancelledException());
    }
  }
}

/// Serializes all yt-dlp downloads. The embedded Python progress file is
/// global, so two simultaneous downloads would overwrite each other's
/// progress and compete for the single download worker.
///
/// Tasks are in-memory only: completed files and their SQLite rows survive
/// restarts, but an interrupted queue does not.
class DownloadManager extends ChangeNotifier {
  final Future<DownloadResult> Function(
    SongRow song, {
    void Function(double percent)? onProgress,
  }) perform;
  final Future<bool> Function() cancelRemote;

  final List<DownloadTask> _tasks = [];
  DownloadTask? _active;
  bool _pumping = false;
  int _nextId = 0;

  DownloadManager({
    required this.perform,
    required this.cancelRemote,
  });

  List<DownloadTask> get tasks => List.unmodifiable(_tasks);
  DownloadTask? get active => _active;
  int get activeCount =>
      _tasks.where((t) => !t.isFinished).length;
  bool get isBusy => _active != null || _pumping;

  /// Queues a download and returns the same future if this song is already
  /// queued or running.
  Future<DownloadResult> enqueue(
    SongRow song, {
    void Function(double percent)? onProgress,
  }) {
    for (final t in _tasks) {
      if (t.song.id == song.id && !t.isFinished) {
        if (onProgress != null) {
          t.progressListeners.add(onProgress);
          onProgress(t.progress);
        }
        return t.done;
      }
    }
    final task = DownloadTask(id: _nextId++, song: song);
    if (onProgress != null) task.progressListeners.add(onProgress);
    _tasks.add(task);
    notifyListeners();
    unawaited(_pump());
    return task.done;
  }

  Future<void> _pump() async {
    if (_pumping) return;
    _pumping = true;
    try {
      while (true) {
        DownloadTask? next;
        for (final t in _tasks) {
          if (t.status == DownloadTaskStatus.queued) {
            next = t;
            break;
          }
        }
        if (next == null) break;
        final task = next;
        _active = task;
        task.status = DownloadTaskStatus.running;
        task.progress = 0;
        notifyListeners();
        try {
          final result = await perform(
            task.song,
            onProgress: (p) {
              task.progress = p.clamp(0.0, 1.0);
              for (final listener in List.of(task.progressListeners)) {
                listener(task.progress);
              }
              notifyListeners();
            },
          );
          task.result = result;
          if (task.cancelRequested) {
            // The Python side returns {cancelled:true} rather than an error
            // when the progress hook aborts mid-transfer.
            task.status = DownloadTaskStatus.cancelled;
            task._cancel();
          } else {
            task.progress = 1;
            task.status = DownloadTaskStatus.completed;
            task._complete(result);
          }
        } on DownloadCancelledException catch (e) {
          task.status = DownloadTaskStatus.cancelled;
          task.error = e.toString();
          task._cancel();
        } catch (e) {
          task.status = DownloadTaskStatus.failed;
          task.error = '$e';
          task._fail(e);
        } finally {
          _active = null;
          notifyListeners();
        }
      }
    } finally {
      _pumping = false;
      notifyListeners();
    }
  }

  Future<void> cancel(DownloadTask task) async {
    if (task.isFinished) return;
    task.cancelRequested = true;
    if (task.status == DownloadTaskStatus.queued) {
      task.status = DownloadTaskStatus.cancelled;
      task._cancel();
      notifyListeners();
      return;
    }
    if (task.status == DownloadTaskStatus.running) {
      notifyListeners();
      try {
        await cancelRemote();
      } catch (_) {}
    }
  }

  Future<void> cancelAll() async {
    for (final task in List.of(_tasks)) {
      await cancel(task);
    }
  }

  /// Retries a failed/cancelled task by creating a fresh queue entry.
  Future<DownloadResult> retry(DownloadTask task,
      {void Function(double percent)? onProgress}) {
    if (!task.isFinished) return task.done;
    return enqueue(task.song, onProgress: onProgress);
  }

  void remove(DownloadTask task) {
    if (!task.isFinished) return;
    _tasks.remove(task);
    notifyListeners();
  }

  void clearFinished() {
    _tasks.removeWhere((t) => t.isFinished);
    notifyListeners();
  }
}
