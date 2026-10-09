import 'dart:math';

import 'package:drift/drift.dart';

import '../config/app_config.dart';
import '../db/app_database.dart';
import 'session_manager.dart';

/// Rating statistics for a song.
class SongRatingStats {
  final String songId;
  final int count;
  final double average;
  final int? latestRating;
  final int distinctSessionsCount;
  final double consistencyScore; // 0.0 to 1.0 (higher = consistently rated high)

  const SongRatingStats({
    required this.songId,
    required this.count,
    required this.average,
    required this.latestRating,
    required this.distinctSessionsCount,
    required this.consistencyScore,
  });
}

/// Service managing the 1-10 rating system and persistent rating history.
///
/// Per Specification §11-§14:
/// - Allows 1-10 ratings.
/// - Every rating event is stored with its track ID, session ID, timestamp, and rating.
/// - Previous ratings are never overwritten.
/// - Repeated high ratings across independent sessions increase long-term preference.
/// - Inconsistent ratings indicate unstable preference.
class RatingService {
  final AppDatabase db;
  final SessionManager sessionManager;

  RatingService({
    required this.db,
    required this.sessionManager,
  });

  /// Records a 1-10 rating for a song, tied to the active listening session.
  Future<RatingEvent> rateSong(String songId, int rating, {DateTime? now}) async {
    final clampedRating = rating.clamp(AppConfig.ratingMin, AppConfig.ratingMax);
    final timestamp = now ?? DateTime.now();

    // Meaningful user activity updates the session.
    final session = await sessionManager.recordActivity(
      now: timestamp,
      reason: 'explicit_rating_$clampedRating',
    );

    final eventId = 'rate_${timestamp.millisecondsSinceEpoch}_${Random().nextInt(10000)}';
    final companion = RatingEventsCompanion.insert(
      id: eventId,
      songId: songId,
      sessionId: session.id,
      rating: clampedRating,
      timestamp: timestamp,
    );

    await db.into(db.ratingEvents).insert(companion);

    // Keep legacy likedAt column in sync (rated 8-10 counts as liked).
    if (clampedRating >= 8) {
      await (db.update(db.songs)..where((s) => s.id.equals(songId))).write(
        SongsCompanion(likedAt: Value(timestamp)),
      );
    }

    return RatingEvent(
      id: eventId,
      songId: songId,
      sessionId: session.id,
      rating: clampedRating,
      timestamp: timestamp,
    );
  }

  /// Returns the complete rating history for a song, oldest first.
  Future<List<RatingEvent>> getRatingHistory(String songId) =>
      (db.select(db.ratingEvents)
            ..where((r) => r.songId.equals(songId))
            ..orderBy([(r) => OrderingTerm.asc(r.timestamp)]))
          .get();

  /// Returns the most recent rating given to a song, or null if unrated.
  Future<int?> getLatestRating(String songId) async {
    final event = await (db.select(db.ratingEvents)
          ..where((r) => r.songId.equals(songId))
          ..orderBy([(r) => OrderingTerm.desc(r.timestamp)])
          ..limit(1))
        .getSingleOrNull();
    return event?.rating;
  }

  /// Calculates rating statistics including cross-session consistency.
  Future<SongRatingStats> getRatingStats(String songId) async {
    final history = await getRatingHistory(songId);
    if (history.isEmpty) {
      return SongRatingStats(
        songId: songId,
        count: 0,
        average: 0.0,
        latestRating: null,
        distinctSessionsCount: 0,
        consistencyScore: 0.0,
      );
    }

    final ratings = history.map((e) => e.rating).toList();
    final avg = ratings.reduce((a, b) => a + b) / ratings.length;
    final latest = history.last.rating;
    final distinctSessions = history.map((e) => e.sessionId).toSet().length;

    // Calculate variance across ratings.
    double variance = 0.0;
    for (final r in ratings) {
      variance += pow(r - avg, 2);
    }
    variance /= ratings.length;
    final stdDev = sqrt(variance);

    // High consistency score when average is high and standard deviation is low across sessions.
    // Normalized to 0.0 - 1.0.
    final normalizedAvg = (avg - AppConfig.ratingMin) / (AppConfig.ratingMax - AppConfig.ratingMin);
    final stabilityPenalty = (stdDev / 4.5).clamp(0.0, 1.0);
    final sessionBonus = (distinctSessions > 1) ? min(1.0, distinctSessions * 0.2) : 0.0;

    final consistency = (normalizedAvg * 0.7 + sessionBonus * 0.3) * (1.0 - stabilityPenalty * 0.3);

    return SongRatingStats(
      songId: songId,
      count: history.length,
      average: avg,
      latestRating: latest,
      distinctSessionsCount: distinctSessions,
      consistencyScore: consistency.clamp(0.0, 1.0),
    );
  }

  /// Watches the latest rating of a song for reactive UI updates.
  Stream<int?> watchLatestRating(String songId) {
    return (db.select(db.ratingEvents)
          ..where((r) => r.songId.equals(songId))
          ..orderBy([(r) => OrderingTerm.desc(r.timestamp)])
          ..limit(1))
        .watchSingleOrNull()
        .map((event) => event?.rating);
  }
}
