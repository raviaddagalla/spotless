import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotless/core/config/app_config.dart';
import 'package:spotless/core/db/app_database.dart';
import 'package:spotless/core/lyrics/lrc_parser.dart';
import 'package:spotless/core/services/feedback_service.dart';
import 'package:spotless/core/services/rating_service.dart';
import 'package:spotless/core/services/session_manager.dart';

void main() {
  late AppDatabase db;
  late SessionManager sessionManager;
  late RatingService ratingService;
  late FeedbackService feedbackService;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    sessionManager = SessionManager(
      db: db,
      inactivityThreshold: AppConfig.sessionInactivityThreshold,
    );
    ratingService = RatingService(db: db, sessionManager: sessionManager);
    feedbackService = FeedbackService(db: db, sessionManager: sessionManager);
  });

  tearDown(() async {
    await db.close();
  });

  group('Session Logic Specification §51', () {
    test('Session Test 1: Continuous activity within 1 hour stays in same session', () async {
      // 10:00 - Activity 1
      final t1 = DateTime(2026, 10, 10, 10, 0);
      final s1 = await sessionManager.recordActivity(now: t1);

      // 10:30 - Activity 2 (gap = 30m < 1h)
      final t2 = DateTime(2026, 10, 10, 10, 30);
      final s2 = await sessionManager.recordActivity(now: t2);

      // 10:45 - Activity 3 (gap = 15m < 1h)
      final t3 = DateTime(2026, 10, 10, 10, 45);
      final s3 = await sessionManager.recordActivity(now: t3);

      expect(s1.id, equals(s2.id));
      expect(s2.id, equals(s3.id));

      final allSessions = await sessionManager.getAllSessions();
      expect(allSessions.length, equals(1));
    });

    test('Session Test 2: Inactivity gap >= 1 hour creates a new session', () async {
      // 10:00 - Activity 1
      final t1 = DateTime(2026, 10, 10, 10, 0);
      final s1 = await sessionManager.recordActivity(now: t1);

      // 10:30 - Activity 2 (gap = 30m)
      final t2 = DateTime(2026, 10, 10, 10, 30);
      final s2 = await sessionManager.recordActivity(now: t2);
      expect(s1.id, equals(s2.id));

      // 11:31 - Activity 3 (gap from 10:30 = 61m >= 1h)
      final t3 = DateTime(2026, 10, 10, 11, 31);
      final s3 = await sessionManager.recordActivity(now: t3);

      expect(s3.id, isNot(equals(s1.id)));

      final allSessions = await sessionManager.getAllSessions();
      expect(allSessions.length, equals(2));
      // First session was marked completed
      final oldSession = allSessions.firstWhere((s) => s.id == s1.id);
      expect(oldSession.state, equals('completed'));
    });

    test('Session Test 3: Application closes 10:30, reopens 10:50 (< 1h) -> Same session', () async {
      // 10:30 - User uses app, then closes
      final t1 = DateTime(2026, 10, 10, 10, 30);
      final s1 = await sessionManager.recordActivity(now: t1);

      // 10:50 - Reopens (gap = 20m)
      final t2 = DateTime(2026, 10, 10, 10, 50);
      final active = await sessionManager.getActiveSession(now: t2);

      expect(active, isNotNull);
      expect(active!.id, equals(s1.id));
    });

    test('Session Test 4: Application closes 10:30, reopens 12:00 (>= 1h) -> New session on activity', () async {
      // 10:30 - User uses app, then closes
      final t1 = DateTime(2026, 10, 10, 10, 30);
      final s1 = await sessionManager.recordActivity(now: t1);

      // 12:00 - Reopens (gap = 90m)
      final t2 = DateTime(2026, 10, 10, 12, 0);
      final active = await sessionManager.getActiveSession(now: t2);
      // App reopen alone does not automatically create new session (Spec §7)
      expect(active, isNull);

      // Activity begins at 12:05
      final t3 = DateTime(2026, 10, 10, 12, 5);
      final s2 = await sessionManager.recordActivity(now: t3);

      expect(s2.id, isNot(equals(s1.id)));
      expect(s2.state, equals('active'));
    });

    test('Session Test 5: Pause 10:30, resume 10:40 (< 1h) -> Same session', () async {
      final t1 = DateTime(2026, 10, 10, 10, 30);
      final s1 = await sessionManager.recordActivity(now: t1, reason: 'pause');

      final t2 = DateTime(2026, 10, 10, 10, 40);
      final s2 = await sessionManager.recordActivity(now: t2, reason: 'resume');

      expect(s1.id, equals(s2.id));
    });

    test('Session Test 6: Pause 10:30, resume 11:31 (>= 1h) -> New session', () async {
      final t1 = DateTime(2026, 10, 10, 10, 30);
      final s1 = await sessionManager.recordActivity(now: t1, reason: 'pause');

      final t2 = DateTime(2026, 10, 10, 11, 31);
      final s2 = await sessionManager.recordActivity(now: t2, reason: 'resume');

      expect(s2.id, isNot(equals(s1.id)));
    });

    test('Session Test 7: Backgrounded < 1 hour -> Same session when activity resumes', () async {
      final t1 = DateTime(2026, 10, 10, 14, 0);
      final s1 = await sessionManager.recordActivity(now: t1);

      // 45 minutes backgrounded
      final t2 = DateTime(2026, 10, 10, 14, 45);
      final s2 = await sessionManager.recordActivity(now: t2);

      expect(s1.id, equals(s2.id));
    });

    test('Session Test 8: Backgrounded > 1 hour -> New session when activity resumes', () async {
      final t1 = DateTime(2026, 10, 10, 14, 0);
      final s1 = await sessionManager.recordActivity(now: t1);

      // 75 minutes backgrounded
      final t2 = DateTime(2026, 10, 10, 15, 15);
      final s2 = await sessionManager.recordActivity(now: t2);

      expect(s2.id, isNot(equals(s1.id)));
    });
  });

  group('Rating System Specification §11-§14', () {
    test('Stores 1-10 rating events with history preservation', () async {
      final t1 = DateTime(2026, 10, 10, 10, 0);
      await ratingService.rateSong('song_1', 10, now: t1);

      final t2 = DateTime(2026, 10, 10, 10, 15);
      await ratingService.rateSong('song_1', 8, now: t2);

      final history = await ratingService.getRatingHistory('song_1');
      expect(history.length, equals(2));
      expect(history[0].rating, equals(10));
      expect(history[1].rating, equals(8));

      final latest = await ratingService.getLatestRating('song_1');
      expect(latest, equals(8));
    });

    test('Repeated high ratings across independent sessions increase consistency score', () async {
      // Session 1: rated 10
      final t1 = DateTime(2026, 10, 10, 10, 0);
      await ratingService.rateSong('song_fav', 10, now: t1);

      // Session 2 (2 hours later): rated 9
      final t2 = DateTime(2026, 10, 10, 12, 30);
      await ratingService.rateSong('song_fav', 9, now: t2);

      // Session 3 (next day): rated 10
      final t3 = DateTime(2026, 10, 11, 9, 0);
      await ratingService.rateSong('song_fav', 10, now: t3);

      final stats = await ratingService.getRatingStats('song_fav');
      expect(stats.distinctSessionsCount, equals(3));
      expect(stats.average, greaterThanOrEqualTo(9.5));
      expect(stats.consistencyScore, greaterThan(0.8));
    });

    test('Inconsistent ratings lower the consistency score', () async {
      // Session 1: 10
      final t1 = DateTime(2026, 10, 10, 10, 0);
      await ratingService.rateSong('song_wild', 10, now: t1);

      // Session 2: 2
      final t2 = DateTime(2026, 10, 10, 12, 30);
      await ratingService.rateSong('song_wild', 2, now: t2);

      // Session 3: 4
      final t3 = DateTime(2026, 10, 11, 9, 0);
      await ratingService.rateSong('song_wild', 4, now: t3);

      final stats = await ratingService.getRatingStats('song_wild');
      expect(stats.distinctSessionsCount, equals(3));
      expect(stats.consistencyScore, lessThan(0.5));
    });
  });

  group('Implicit Feedback & Duration-weighted Skips Specification §25', () {
    test('Early skips (<20%) penalize score more than late skips (>80%)', () async {
      // Song A: 2 early skips at 5 seconds (5%)
      await feedbackService.recordSkip('song_early_skip', secondsPlayed: 5, completionPercentage: 0.05);
      await feedbackService.recordSkip('song_early_skip', secondsPlayed: 8, completionPercentage: 0.08);

      // Song B: 2 late skips at 180 seconds (90%)
      await feedbackService.recordSkip('song_late_skip', secondsPlayed: 180, completionPercentage: 0.90);
      await feedbackService.recordSkip('song_late_skip', secondsPlayed: 185, completionPercentage: 0.92);

      final scoreEarly = await feedbackService.getImplicitScore('song_early_skip');
      final scoreLate = await feedbackService.getImplicitScore('song_late_skip');

      expect(scoreEarly, lessThan(scoreLate));
    });
  });

  group('Synchronized Lyrics Specification §30-§32', () {
    test('LRC parser parses timestamps and plain text', () {
      const lrcContent = '''
[00:12.50]Line one of lyrics
[00:18.20]Second synchronized line
[01:05.00]Chorus starts here
''';

      final lyrics = LrcParser.parse(lrcContent);
      expect(lyrics.synced, isTrue);
      expect(lyrics.lines.length, equals(3));
      expect(lyrics.lines[0].time, equals(const Duration(seconds: 12, milliseconds: 500)));
      expect(lyrics.lines[0].text, equals('Line one of lyrics'));
      expect(lyrics.lines[1].time, equals(const Duration(seconds: 18, milliseconds: 200)));
      expect(lyrics.lines[2].time, equals(const Duration(minutes: 1, seconds: 5)));
    });

    test('Plain text lyrics parser falls back to unsynchronized correctly', () {
      const plainText = '''
Just regular plain lyrics
Without any timestamp brackets
''';

      final lyrics = LrcParser.parse(plainText);
      expect(lyrics.synced, isFalse);
      expect(lyrics.plainText.trim(), equals(plainText.trim()));
    });
  });
}
