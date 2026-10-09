import 'dart:async';
import 'dart:io';

import '../youtube/yt_bridge.dart';

class DownloadResult {
  final String? path;
  final String? ext;
  final String? title;
  final int? duration;
  final String? videoId;
  final String? thumbnail;
  final String? error;

  const DownloadResult({
    this.path,
    this.ext,
    this.title,
    this.duration,
    this.videoId,
    this.thumbnail,
    this.error,
  });
}

/// Downloads a song from YouTube into the app's private storage using yt-dlp.
class Downloader {
  final YtBridge _yt;
  final Directory _destDir;

  Downloader(this._yt, this._destDir);

  Future<void> ensureDir() async {
    if (!_destDir.existsSync()) await _destDir.create(recursive: true);
  }

  /// Downloads `query` (youtube url or search) to the app downloads folder.
  /// Returns the downloaded song's new path. Throws on failure (the caller
  /// surfaces the error to the user instead of failing silently).
  Future<DownloadResult> download(
    String query, {
    void Function(double percent)? onProgress,
  }) async {
    await ensureDir();
    final baseName = 'dl_${DateTime.now().millisecondsSinceEpoch}';
    final outDir = _destDir.path;
    final res = await _yt.download(query, outDir, baseName);
    final path = res['path'] as String?;
    if (path == null) {
      throw Exception('No audio downloaded (yt-dlp returned no file)');
    }
    if (onProgress != null) {
      onProgress(1.0);
    }
    return DownloadResult(
      path: path,
      ext: res['ext'] as String?,
      title: res['title'] as String?,
      duration: res['duration'] as int?,
      videoId: res['id'] as String?,
      thumbnail: res['thumbnail'] as String?,
    );
  }

  /// Polls the python-side progress file; returns percent 0..1 or null.
  Future<double?> pollProgress() async {
    final raw = await _yt.progress();
    if (raw.isEmpty) return null;
    final parts = raw.split('|');
    final pct = double.tryParse(parts.first);
    if (pct == null) return null;
    return pct / 100.0;
  }
}
