import 'dart:convert';

import 'package:flutter/services.dart';

/// Bridge to the Python (yt-dlp + mutagen) runtime embedded via Chaquopy.
/// Python methods return JSON strings (see android/.../python/ytdlp.py) so
/// results survive the platform channel untouched.
class YtBridge {
  static const _channel = MethodChannel('spotless/ytdlp');

  Future<Map<String, dynamic>> extract(String query) async {
    final result = await _channel.invokeMethod<String>('extract', {'query': query});
    final decoded = jsonDecode(result ?? '{}');
    return Map<String, dynamic>.from(decoded as Map);
  }

  Future<List<Map<String, dynamic>>> search(String query, {int maxResults = 10}) async {
    final result = await _channel
        .invokeMethod<String>('search', {'query': query, 'max_results': maxResults});
    final decoded = jsonDecode(result ?? '[]') as List;
    return decoded
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<Map<String, dynamic>> download(
      String url, String outDir, String baseName) async {
    final result = await _channel.invokeMethod<String>('download', {
      'url': url,
      'outdir': outDir,
      'base_name': baseName,
    });
    final decoded = jsonDecode(result ?? '{}');
    return Map<String, dynamic>.from(decoded as Map);
  }

  Future<bool> embedCover(String path, Uint8List imageBytes, {String mime = 'image/jpeg'}) async {
    final result = await _channel.invokeMethod<String>('embedCover', {
      'path': path,
      'image_bytes': imageBytes,
      'mime': mime,
    });
    return jsonDecode(result ?? 'false') as bool;
  }

  Future<bool> setTags(String path, {String? title, String? artist}) async {
    final result = await _channel.invokeMethod<String>('setTags', {
      'path': path,
      'title': title,
      'artist': artist,
    });
    return jsonDecode(result ?? 'false') as bool;
  }

  Future<Map<String, dynamic>> probe(String path) async {
    final result = await _channel.invokeMethod<String>('probe', {'path': path});
    final decoded = jsonDecode(result ?? '{}');
    return Map<String, dynamic>.from(decoded as Map);
  }

  Future<String> progress() async {
    final result = await _channel.invokeMethod<String>('getProgress');
    return result ?? '';
  }

  Future<Map<String, dynamic>> fetchLyrics(
    String title,
    String artist, {
    String? album,
    int? durationSeconds,
  }) async {
    final result = await _channel.invokeMethod<String>('fetch_lyrics', {
      'title': title,
      'artist': artist,
      'album': album,
      'duration_s': durationSeconds,
    });
    return Map<String, dynamic>.from(jsonDecode(result ?? '{}') as Map);
  }

  /// Searches YouTube for the best canonical (studio) recording of a song.
  /// Returns the highest-scored result with id/title/duration/channel/score.
  Future<Map<String, dynamic>> canonicalSearch(
    String artist,
    String title, {
    int? expectedDurationSeconds,
    int maxCandidates = 8,
  }) async {
    final result = await _channel.invokeMethod<String>('canonical_search', {
      'artist': artist,
      'title': title,
      'expected_duration_s': expectedDurationSeconds,
      'max_candidates': maxCandidates,
    });
    return Map<String, dynamic>.from(jsonDecode(result ?? '{}') as Map);
  }
}
