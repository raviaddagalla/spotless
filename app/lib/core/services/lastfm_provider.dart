import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../db/app_database.dart';
import 'recommendation_provider.dart';

/// Recommendation provider implementation using Last.fm Web Services.
///
/// Per Specification §17, §47, §48:
/// - Connects to track.getSimilar and artist.getSimilar.
/// - Requires Last.fm API Key (configurable, never hardcoded).
/// - Gracefully returns empty list on network failure, timeout, or missing key.
class LastFmProvider implements RecommendationProvider {
  final String? apiKey;
  final http.Client _client;

  LastFmProvider({this.apiKey, http.Client? client})
      : _client = client ?? http.Client();

  @override
  String get name => 'Last.fm';

  @override
  bool get isConfigured => apiKey != null && apiKey!.trim().isNotEmpty;

  static const _baseUrl = 'https://ws.audioscrobbler.com/2.0/';

  @override
  Future<List<RecommendationCandidate>> getSimilarTracks({
    required String artist,
    required String title,
    int limit = 15,
  }) async {
    if (!isConfigured) return const [];

    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'method': 'track.getsimilar',
        'artist': artist,
        'track': title,
        'api_key': apiKey!.trim(),
        'format': 'json',
        'limit': '$limit',
        'autocorrect': '1',
      });

      final response = await _client
          .get(uri)
          .timeout(AppConfig.providerTimeout);

      if (response.statusCode != 200) {
        if (kDebugMode) {
          debugPrint('[LastFmProvider] HTTP ${response.statusCode}: ${response.body}');
        }
        return const [];
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final similarTracks = data['similartracks'];
      if (similarTracks == null || similarTracks is! Map) return const [];

      final trackList = similarTracks['track'];
      if (trackList == null || trackList is! List) return const [];

      final results = <RecommendationCandidate>[];
      for (final item in trackList) {
        if (item is! Map) continue;
        final trackName = item['name'] as String?;
        final artistObj = item['artist'];
        final artistName = artistObj is Map
            ? artistObj['name'] as String?
            : (artistObj is String ? artistObj : null);

        if (trackName == null || artistName == null) continue;

        // Extract match score (0.0 to 1.0)
        double score = 0.5;
        final matchStr = item['match'];
        if (matchStr != null) {
          score = double.tryParse(matchStr.toString()) ?? 0.5;
        }

        // Extract largest image url if available
        String? artUrl;
        final images = item['image'];
        if (images is List && images.isNotEmpty) {
          final last = images.last;
          if (last is Map && last['#text'] != null && (last['#text'] as String).isNotEmpty) {
            artUrl = last['#text'] as String;
          }
        }

        final durationSeconds = int.tryParse(item['duration']?.toString() ?? '');

        results.add(RecommendationCandidate(
          title: trackName,
          artist: artistName,
          durationSeconds: durationSeconds,
          albumArtUrl: artUrl,
          providerName: name,
          seedTrackTitle: title,
          seedArtist: artist,
          providerScore: score.clamp(0.0, 1.0),
        ));
      }

      return results;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LastFmProvider] Error fetching similar tracks: $e');
      }
      return const [];
    }
  }

  @override
  Future<List<RecommendationCandidate>> getRecommendationsForSeeds({
    required List<SongRow> longTermSeeds,
    required List<SongRow> sessionSeeds,
    int limit = 20,
  }) async {
    if (!isConfigured) return const [];

    final candidates = <String, RecommendationCandidate>{};

    // Prioritize current-session seeds first, then long-term seeds
    final prioritizedSeeds = [
      ...sessionSeeds.take(3),
      ...longTermSeeds.take(3),
    ];

    for (final seed in prioritizedSeeds) {
      final results = await getSimilarTracks(
        artist: seed.artist,
        title: seed.title,
        limit: (limit / 2).ceil(),
      );

      for (final r in results) {
        final key = '${r.artist.toLowerCase()} - ${r.title.toLowerCase()}';
        if (!candidates.containsKey(key)) {
          candidates[key] = r;
        }
      }

      if (candidates.length >= limit * 2) break;
    }

    return candidates.values.take(limit).toList();
  }
}
