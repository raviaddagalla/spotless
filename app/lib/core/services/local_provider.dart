import 'dart:math';

import 'package:drift/drift.dart' hide Column;

import '../db/app_database.dart';
import 'recommendation_provider.dart';

/// Offline recommendation provider using Spotify audio features stored in SQLite.
///
/// Per Specification §17 & §47:
/// - Guarantees recommendation capability when internet is unavailable or external
///   APIs are unconfigured.
/// - Calculates multi-dimensional Euclidean acoustic distance using energy, tempo,
///   valence, danceability, and genre overlaps.
class LocalMetadataProvider implements RecommendationProvider {
  final AppDatabase db;
  final Random _random = Random();

  LocalMetadataProvider(this.db);

  @override
  String get name => 'Local Library';

  @override
  bool get isConfigured => true; // Always available offline

  @override
  Future<List<RecommendationCandidate>> getSimilarTracks({
    required String artist,
    required String title,
    int limit = 15,
  }) async {
    // Find matching seed song in local DB
    final seed = await (db.select(db.songs)
          ..where((s) =>
              s.title.lower().equals(title.toLowerCase()) &
              s.artist.lower().equals(artist.toLowerCase()))
          ..limit(1))
        .getSingleOrNull();

    final all = await (db.select(db.songs)).get();
    if (all.isEmpty) return const [];

    if (seed == null ||
        seed.energy == null ||
        seed.tempo == null ||
        seed.valence == null ||
        seed.danceability == null) {
      // Fallback: shuffle other songs by genre or random
      final pool = all.where((s) => s.artist.toLowerCase() != artist.toLowerCase()).toList()
        ..shuffle(_random);
      return pool.take(limit).map((s) => _toCandidate(s, 0.5, title, artist)).toList();
    }

    final seedGenres = (seed.genres ?? '').split(',').map((g) => g.trim().toLowerCase()).toSet();
    final scored = <(double, SongRow)>[];

    for (final s in all) {
      if (s.id == seed.id) continue;
      if (s.energy == null || s.tempo == null || s.valence == null || s.danceability == null) {
        continue;
      }

      var distance = sqrt(
        pow(s.energy! - seed.energy!, 2) +
            pow((s.tempo! - seed.tempo!) / 60, 2) +
            pow(s.valence! - seed.valence!, 2) +
            pow(s.danceability! - seed.danceability!, 2),
      );

      final otherGenres = (s.genres ?? '').split(',').map((g) => g.trim().toLowerCase()).toSet();
      final overlap = seedGenres.intersection(otherGenres).length;
      distance -= overlap * 0.15;

      scored.add((distance, s));
    }

    scored.sort((a, b) => a.$1.compareTo(b.$1));

    return scored.take(limit).map((e) {
      final normScore = (1.0 - (e.$1 / 3.0)).clamp(0.1, 1.0);
      return _toCandidate(e.$2, normScore, title, artist);
    }).toList();
  }

  @override
  Future<List<RecommendationCandidate>> getRecommendationsForSeeds({
    required List<SongRow> longTermSeeds,
    required List<SongRow> sessionSeeds,
    int limit = 20,
  }) async {
    final seeds = [...sessionSeeds.take(3), ...longTermSeeds.take(3)];
    if (seeds.isEmpty) {
      final all = await (db.select(db.songs)).get();
      return all
          .take(limit)
          .map((s) => _toCandidate(s, 0.5, null, null))
          .toList();
    }

    final candidates = <String, RecommendationCandidate>{};
    for (final seed in seeds) {
      final similar = await getSimilarTracks(
        artist: seed.artist,
        title: seed.title,
        limit: 8,
      );
      for (final c in similar) {
        final key = '${c.artist.toLowerCase()}:::${c.title.toLowerCase()}';
        if (!candidates.containsKey(key)) {
          candidates[key] = c;
        }
      }
      if (candidates.length >= limit) break;
    }

    return candidates.values.take(limit).toList();
  }

  RecommendationCandidate _toCandidate(
    SongRow s,
    double score,
    String? seedTitle,
    String? seedArtist,
  ) {
    return RecommendationCandidate(
      title: s.title,
      artist: s.artist,
      album: s.album,
      durationSeconds: s.durationMs != null ? s.durationMs! ~/ 1000 : null,
      albumArtUrl: s.albumArtUrl,
      providerName: name,
      seedTrackTitle: seedTitle,
      seedArtist: seedArtist,
      providerScore: score,
      existingSong: s,
    );
  }
}
