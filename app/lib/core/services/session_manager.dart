import 'package:drift/drift.dart';

import '../config/app_config.dart';
import '../db/app_database.dart';

/// Manages listening sessions based strictly on user/playback activity continuity.
///
/// Per Specification §1-§10:
/// - A session does NOT mean morning, afternoon, evening, night, weekday, or any
///   time-of-day category. No clock time-of-day learning.
/// - Sessions continue across short interruptions (< 1 hour).
/// - A session ends only when inactivity >= threshold (default 1 hour, configurable).
/// - Survived across app restarts, kills, and backgrounding via database persistence.
class SessionManager {
  final AppDatabase db;
  final Duration inactivityThreshold;

  SessionManager({
    required this.db,
    this.inactivityThreshold = AppConfig.sessionInactivityThreshold,
  });

  ListeningSession? _cachedSession;

  /// Returns the current active session, continuing an existing one if the gap
  /// is less than [inactivityThreshold], or creating a new one if inactive for >= 1 hour
  /// or if no session exists yet.
  Future<ListeningSession> getOrCreateActiveSession({DateTime? now}) async {
    final currentTime = now ?? DateTime.now();

    // Fetch the most recent session from the database.
    final latest = await (db.select(db.listeningSessions)
          ..orderBy([(s) => OrderingTerm.desc(s.lastActivityAt)])
          ..limit(1))
        .getSingleOrNull();

    if (latest == null) {
      // First session ever.
      return _createNewSession(currentTime);
    }

    final gap = currentTime.difference(latest.lastActivityAt);

    if (gap < inactivityThreshold) {
      // Continue existing session.
      _cachedSession = latest;
      return latest;
    } else {
      // Gap >= threshold: mark previous session completed and start new one.
      await (db.update(db.listeningSessions)..where((s) => s.id.equals(latest.id))).write(
        ListeningSessionsCompanion(
          state: const Value('completed'),
          endedAt: Value(latest.lastActivityAt),
        ),
      );

      return _createNewSession(currentTime);
    }
  }

  /// Records meaningful music/user activity (playback, rating, skip, seek, etc.).
  /// Updates [lastActivityAt] of the current session or creates a new session
  /// if the gap exceeded the inactivity threshold.
  Future<ListeningSession> recordActivity({DateTime? now, String? reason}) async {
    final currentTime = now ?? DateTime.now();
    final session = await getOrCreateActiveSession(now: currentTime);

    await (db.update(db.listeningSessions)..where((s) => s.id.equals(session.id))).write(
      ListeningSessionsCompanion(
        lastActivityAt: Value(currentTime),
        state: const Value('active'),
      ),
    );

    final updated = session.copyWith(lastActivityAt: currentTime);
    _cachedSession = updated;
    return updated;
  }

  /// Closes the current session explicitly if needed.
  Future<void> endCurrentSession({DateTime? now}) async {
    final session = _cachedSession;
    if (session == null) return;
    final currentTime = now ?? DateTime.now();
    await (db.update(db.listeningSessions)..where((s) => s.id.equals(session.id))).write(
      ListeningSessionsCompanion(
        state: const Value('completed'),
        endedAt: Value(currentTime),
      ),
    );
    _cachedSession = null;
  }

  /// Loads the most recent session without creating a new one if none exists or if expired.
  /// (Per Spec §7: app start shouldn't create a session merely by opening).
  Future<ListeningSession?> getActiveSession({DateTime? now}) async {
    final currentTime = now ?? DateTime.now();
    final latest = await (db.select(db.listeningSessions)
          ..orderBy([(s) => OrderingTerm.desc(s.lastActivityAt)])
          ..limit(1))
        .getSingleOrNull();

    if (latest == null) return null;

    final gap = currentTime.difference(latest.lastActivityAt);
    if (gap < inactivityThreshold && latest.state == 'active') {
      _cachedSession = latest;
      return latest;
    }

    if (latest.state == 'active') {
      // Expired: mark it completed.
      await (db.update(db.listeningSessions)..where((s) => s.id.equals(latest.id))).write(
        ListeningSessionsCompanion(
          state: const Value('completed'),
          endedAt: Value(latest.lastActivityAt),
        ),
      );
    }
    _cachedSession = null;
    return null;
  }

  Future<ListeningSession> _createNewSession(DateTime startTime) async {
    final id = 'sess_${startTime.millisecondsSinceEpoch}_${startTime.microsecondsSinceEpoch % 1000}';
    final companion = ListeningSessionsCompanion.insert(
      id: id,
      startedAt: startTime,
      lastActivityAt: startTime,
      state: const Value('active'),
    );
    await db.into(db.listeningSessions).insert(companion);
    final created = ListeningSession(
      id: id,
      startedAt: startTime,
      lastActivityAt: startTime,
      endedAt: null,
      state: 'active',
    );
    _cachedSession = created;
    return created;
  }

  /// Returns all sessions in descending order of start time.
  Future<List<ListeningSession>> getAllSessions() =>
      (db.select(db.listeningSessions)..orderBy([(s) => OrderingTerm.desc(s.startedAt)])).get();

  /// Returns the ratings given during the specified session.
  Future<List<RatingEvent>> getSessionRatings(String sessionId) =>
      (db.select(db.ratingEvents)
            ..where((r) => r.sessionId.equals(sessionId))
            ..orderBy([(r) => OrderingTerm.asc(r.timestamp)]))
          .get();

  /// Returns the playback events recorded during the specified session.
  Future<List<PlaybackEvent>> getSessionPlaybackEvents(String sessionId) =>
      (db.select(db.playbackEvents)
            ..where((p) => p.sessionId.equals(sessionId))
            ..orderBy([(p) => OrderingTerm.asc(p.timestamp)]))
          .get();
}
