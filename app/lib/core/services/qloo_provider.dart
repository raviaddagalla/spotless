import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../db/app_database.dart';
import 'recommendation_provider.dart';

/// Recommendation provider implementation using Qloo Taste Intelligence API.
///
/// Per Specification §17, §47, §48:
/// - Provides cultural & cross-domain taste similarity.
/// - Requires Qloo API Key (configurable via settings/env, never hardcoded).
/// - Gracefully falls back when API key is missing or service is unavailable.
class QlooProvider implements RecommendationProvider {
  final String? apiKey;
  final http.Client _client;

  QlooProvider({this.apiKey, http.Client? client})
      : _client = client ?? http.Client();

  @override
  String get name => 'Qloo';

  @override
  bool get isConfigured => apiKey != null && apiKey!.trim().isNotEmpty;

  static const _baseUrl = 'https://api.qloo.com/v2/insights';

  @override
  Future<List<RecommendationCandidate>> getSimilarTracks({
    required String artist,
    required String title,
    int limit = 15,
  }) async {
    if (!isConfigured) return const [];

    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'entity_type': 'music',
        'query': '$artist $title',
        'limit': '$limit',
      });

      final response = await _client.get(
        uri,
        headers: {
          'X-Api-Key': apiKey!.trim(),
          'Accept': 'application/json',
        },
      ).timeout(AppConfig.providerTimeout);

      if (response.statusCode != 200) {
        if (kDebugMode) {
          debugPrint('[QlooProvider] HTTP ${response.statusCode}: ${response.body}');
        }
        return const [];
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final resultsList = data['results'] ?? data['data'];
      if (resultsList == null || resultsList is! List) return const [];

      final results = <RecommendationCandidate>[];
      for (final item in resultsList) {
        if (item is! Map) continue;
        final trackName = item['title'] ?? item['name'];
        final artistName = item['artist'] ?? item['author'];
        if (trackName == null || artistName == null) continue;

        double score = 0.5;
        if (item['affinity'] != null) {
          score = (double.tryParse(item['affinity'].toString()) ?? 0.5) / 100.0;
        }

        results.add(RecommendationCandidate(
          title: trackName.toString(),
          artist: artistName.toString(),
          providerName: name,
          seedTrackTitle: title,
          seedArtist: artist,
          providerScore: score.clamp(0.0, 1.0),
        ));
      }

      return results;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[QlooProvider] Error fetching similar tracks: $e');
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

    final seeds = [...sessionSeeds.take(2), ...longTermSeeds.take(2)];
    final all = <RecommendationCandidate>[];

    for (final s in seeds) {
      final tracks = await getSimilarTracks(artist: s.artist, title: s.title, limit: 10);
      all.addAll(tracks);
      if (all.length >= limit) break;
    }

    return all.take(limit).toList();
  }
}
