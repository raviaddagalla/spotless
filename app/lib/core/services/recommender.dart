import 'dart:math';

import 'package:drift/drift.dart' hide Column;

import '../db/app_database.dart';

/// Recommendation engine seam. The UI only talks to the repository, never
/// to this class directly, so the algorithm can be swapped (embeddings,
/// collaborative filtering, history signals, ...) without UI changes.
abstract class Recommender {
  Future<List<SongRow>> forYou(int limit);
  Future<List<SongRow>> similarTo(SongRow seed, int limit);
}

/// v1: history + lightweight feature similarity (energy, tempo, valence,
/// danceability) with genre overlap boost.
class MetadataRecommender implements Recommender {
  final AppDatabase _db;
  final Random _random = Random();

  MetadataRecommender(this._db);

  @override
  Future<List<SongRow>> forYou(int limit) async {
    final recent = await (_db.select(_db.songs)
          ..where((t) => t.lastPlayedAt.isNotNull())
          ..orderBy([(t) => OrderingTerm.desc(t.lastPlayedAt)])
          ..limit(5))
        .get();
    final mostPlayed = await (_db.select(_db.songs)
          ..where((t) => t.playCount.isBiggerThanValue(1))
          ..orderBy([(t) => OrderingTerm.desc(t.playCount)])
          ..limit(5))
        .get();
    final seen = <String>{};
    final out = <SongRow>[
      ...mostPlayed.where((s) => seen.add(s.id)),
      ...recent.where((s) => seen.add(s.id)),
    ];
    if (out.length >= limit) return out.take(limit).toList();

    final all = await (_db.select(_db.songs)).get();
    final pool = all
        .where((s) => !seen.contains(s.id))
        .where((s) => s.danceability != null || s.energy != null)
        .toList();
    pool.shuffle(_random);
    out.addAll(pool.take(limit - out.length));
    return out;
  }

  @override
  Future<List<SongRow>> similarTo(SongRow seed, int limit) async {
    final hasFeatures = seed.energy != null &&
        seed.tempo != null &&
        seed.valence != null &&
        seed.danceability != null;
    if (!hasFeatures) {
      return _fallback(seed, limit);
    }
    final all = await (_db.select(_db.songs)).get();
    final seedGenres = (seed.genres ?? '').split(',').map((g) => g.trim()).toSet();
    final scored = <(double, SongRow)>[];
    for (final s in all) {
      if (s.id == seed.id) continue;
      if (s.energy == null || s.tempo == null || s.valence == null || s.danceability == null) {
        continue;
      }
      var d = sqrt(
        pow(s.energy! - seed.energy!, 2) +
            pow((s.tempo! - seed.tempo!) / 60, 2) +
            pow(s.valence! - seed.valence!, 2) +
            pow(s.danceability! - seed.danceability!, 2),
      );
      final overlap = seedGenres
          .intersection((s.genres ?? '').split(',').map((g) => g.trim()).toSet())
          .length;
      d -= overlap * 0.15;
      scored.add((d, s));
    }
    scored.sort((a, b) => a.$1.compareTo(b.$1));
    return scored.take(limit).map((e) => e.$2).toList();
  }

  Future<List<SongRow>> _fallback(SongRow seed, int limit) async {
    final all = await (_db.select(_db.songs)).get();
    final pool = all.where((s) => s.id != seed.id).toList();
    pool.shuffle(_random);
    return pool.take(limit).toList();
  }
}
