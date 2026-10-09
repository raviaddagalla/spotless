import 'dart:math';

import 'package:drift/drift.dart';

import '../config/app_config.dart';
import '../db/app_database.dart';
import 'session_manager.dart';

/// Service recording and querying implicit playback behavior.
///
/// Per Specification §25:
/// - Records playback starts, skips, completions, replays, seeks.
/// - Early skips (< 10s or < 20%) are strong negative signals;
///   late skips (> 80%) are mild.
/// - Full completions and replays are positive signals.
/// - All events are associated with the active listening session.
class FeedbackService {
  final AppDatabase db;
  final SessionManager sessionManager;

  FeedbackService({
    required this.db,
    required this.sessionManager,
  });

  /// Records when playback of a song starts.
  Future<void> recordPlayStart(String songId, {DateTime? now}) async {
    final timestamp = now ?? DateTime.now();
    final session = await sessionManager.recordActivity(
      now: timestamp,
      reason: 'play_start',
    );

    final eventId = 'play_${timestamp.millisecondsSinceEpoch}_${Random().nextInt(10000)}';
    await db.into(db.playbackEvents).insert(
          PlaybackEventsCompanion.insert(
            id: eventId,
            songId: songId,
            sessionId: session.id,
            eventType: 'play_start',
            timestamp: timestamp,
          ),
        );
  }

  /// Records when a track plays to completion.
  Future<void> recordTrackCompleted(
    String songId, {
    int? secondsPlayed,
    DateTime? now,
  }) async {
    final timestamp = now ?? DateTime.now();
    final session = await sessionManager.recordActivity(
      now: timestamp,
      reason: 'track_completed',
    );

    final eventId = 'comp_${timestamp.millisecondsSinceEpoch}_${Random().nextInt(10000)}';
    await db.into(db.playbackEvents).insert(
          PlaybackEventsCompanion.insert(
            id: eventId,
            songId: songId,
            sessionId: session.id,
            eventType: 'completed',
            secondsPlayed: Value(secondsPlayed),
            completionPercentage: const Value(1.0),
            timestamp: timestamp,
          ),
        );
  }

  /// Records an explicit skip with seconds played and percentage completed.
  Future<void> recordSkip(
    String songId, {
    required int secondsPlayed,
    required double completionPercentage,
    DateTime? now,
  }) async {
    final timestamp = now ?? DateTime.now();
    final session = await sessionManager.recordActivity(
      now: timestamp,
      reason: 'track_skipped',
    );

    final eventId = 'skip_${timestamp.millisecondsSinceEpoch}_${Random().nextInt(10000)}';
    await db.into(db.playbackEvents).insert(
          PlaybackEventsCompanion.insert(
            id: eventId,
            songId: songId,
            sessionId: session.id,
            eventType: 'skip',
            secondsPlayed: Value(secondsPlayed),
            completionPercentage: Value(completionPercentage.clamp(0.0, 1.0)),
            timestamp: timestamp,
          ),
        );
  }

  /// Records when a track is replayed immediately.
  Future<void> recordReplay(String songId, {DateTime? now}) async {
    final timestamp = now ?? DateTime.now();
    final session = await sessionManager.recordActivity(
      now: timestamp,
      reason: 'track_replayed',
    );

    final eventId = 'rep_${timestamp.millisecondsSinceEpoch}_${Random().nextInt(10000)}';
    await db.into(db.playbackEvents).insert(
          PlaybackEventsCompanion.insert(
            id: eventId,
            songId: songId,
            sessionId: session.id,
            eventType: 'replay',
            timestamp: timestamp,
          ),
        );
  }

  /// Computes an implicit score for a song based on completion rate, skips, and replays.
  /// Normalized to [-1.0, 1.0].
  Future<double> getImplicitScore(String songId) async {
    final events = await (db.select(db.playbackEvents)
          ..where((p) => p.songId.equals(songId)))
        .get();

    if (events.isEmpty) return 0.0;

    double score = 0.0;
    int count = 0;

    for (final e in events) {
      count++;
      switch (e.eventType) {
        case 'completed':
          score += AppConfig.completionWeight;
          break;
        case 'replay':
          score += AppConfig.replayWeight;
          break;
        case 'skip':
          final pct = e.completionPercentage ?? 0.0;
          if (pct < 0.20) {
            // Immediate skip: strong penalty.
            score -= AppConfig.skipWeight * 1.5;
          } else if (pct < 0.60) {
            score -= AppConfig.skipWeight;
          } else {
            // Late skip (> 60%): very mild penalty.
            score -= AppConfig.skipWeight * 0.3;
          }
          break;
        case 'play_start':
          // Neutral baseline.
          break;
      }
    }

    if (count == 0) return 0.0;
    return (score / count).clamp(-1.0, 1.0);
  }
}
