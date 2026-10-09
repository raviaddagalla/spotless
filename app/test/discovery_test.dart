import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotless/core/config/app_config.dart';
import 'package:spotless/core/db/app_database.dart';
import 'package:spotless/core/models/song_status.dart';
import 'package:spotless/core/services/discovery_service.dart';
import 'package:spotless/core/services/feedback_service.dart';
import 'package:spotless/core/services/local_provider.dart';
import 'package:spotless/core/services/rating_service.dart';
import 'package:spotless/core/services/session_manager.dart';
import 'package:spotless/core/youtube/yt_bridge.dart';

class _FakeYtBridge extends Fake implements YtBridge {}

void main() {
  late AppDatabase db;
  late SessionManager sessionManager;
  late RatingService ratingService;
  late FeedbackService feedbackService;
  late LocalMetadataProvider localProvider;
  late DiscoveryService discoveryService;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    sessionManager = SessionManager(
      db: db,
      inactivityThreshold: AppConfig.sessionInactivityThreshold,
    );
    ratingService = RatingService(db: db, sessionManager: sessionManager);
    feedbackService = FeedbackService(db: db, sessionManager: sessionManager);
    localProvider = LocalMetadataProvider(db);
    discoveryService = DiscoveryService(
      db: db,
      sessionManager: sessionManager,
      ratingService: ratingService,
      feedbackService: feedbackService,
      providers: [localProvider],
      ytBridge: _FakeYtBridge(),
    );

    // Insert sample library songs with acoustic features
    // Seed song: Upbeat electronic dance track
    await db.into(db.songs).insert(
          SongsCompanion.insert(
            id: 'song_seed',
            title: 'Strobe',
            artist: const Value('deadmau5'),
            status: const Value('downloaded'),
            energy: const Value(0.85),
            tempo: const Value(128.0),
            valence: const Value(0.70),
            danceability: const Value(0.80),
            genres: const Value('electronic, dance, progressive house'),
            playCount: const Value(10),
          ),
        );

    // Acoustically close match (electronic, similar tempo/energy/danceability)
    await db.into(db.songs).insert(
          SongsCompanion.insert(
            id: 'song_match',
            title: 'Ghosts n Stuff',
            artist: const Value('deadmau5 feat. Rob Swire'),
            status: const Value('downloaded'),
            energy: const Value(0.88),
            tempo: const Value(130.0),
            valence: const Value(0.68),
            danceability: const Value(0.82),
            genres: const Value('electronic, electro house'),
            playCount: const Value(8),
          ),
        );

    // Acoustically distant match (slow sad acoustic ballad)
    await db.into(db.songs).insert(
          SongsCompanion.insert(
            id: 'song_distant',
            title: 'Someone Like You',
            artist: const Value('Adele'),
            status: const Value('downloaded'),
            energy: const Value(0.20),
            tempo: const Value(68.0),
            valence: const Value(0.15),
            danceability: const Value(0.30),
            genres: const Value('pop, soul, acoustic'),
            playCount: const Value(2),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('Local Acoustic Provider & Track Radio Specification §17 & §18', () {
    test('Calculates acoustic similarity and ranks closer track highest', () async {
      final results = await localProvider.getSimilarTracks(
        artist: 'deadmau5',
        title: 'Strobe',
        limit: 5,
      );

      expect(results.isNotEmpty, isTrue);
      // 'Ghosts n Stuff' should have a higher similarity score than 'Someone Like You'
      final ghostMatch = results.firstWhere((r) => r.title == 'Ghosts n Stuff');
      final adeleMatch = results.firstWhere((r) => r.title == 'Someone Like You');

      expect(ghostMatch.providerScore, greaterThan(adeleMatch.providerScore));
      expect(results.first.title, equals('Ghosts n Stuff'));
    });

    test('discoverSimilarTo returns scored discovery tracks preserving existingSong', () async {
      final seed = await (db.select(db.songs)..where((s) => s.id.equals('song_seed'))).getSingle();
      final tracks = await discoveryService.discoverSimilarTo(seed, limit: 10);

      expect(tracks.isNotEmpty, isTrue);
      final top = tracks.first;
      expect(top.title, equals('Ghosts n Stuff'));
      expect(top.existingSong, isNotNull);
      expect(top.toSongRow().status, equals(SongStatus.downloaded.name));
    });

    test('promoteCandidate marks candidate promoted and persists to songs table', () async {
      final candidate = ScoredDiscoveryTrack(
        id: 'disc_candidate_1',
        title: 'Midnight City',
        artist: 'M83',
        album: 'Hurry Up, We\'re Dreaming',
        provider: 'Last.fm',
        score: 0.92,
        status: 'candidate',
      );

      // Promote
      await discoveryService.promoteCandidate(candidate);

      // Verify songs table has candidate
      final song = await (db.select(db.songs)..where((s) => s.id.equals('disc_candidate_1'))).getSingleOrNull();
      expect(song, isNotNull);
      expect(song!.title, equals('Midnight City'));
      expect(song.status, equals(SongStatus.streamable.name));

      // Verify discovery candidate status updated to 'promoted'
      final row = await (db.select(db.discoveryCandidates)..where((d) => d.id.equals('disc_candidate_1'))).getSingleOrNull();
      expect(row?.status, equals('promoted'));
    });

    test('cleanupStaleCandidates cleans up old entries while keeping promoted entries', () async {
      final cutoff = DateTime.now().subtract(const Duration(days: 40));

      // Insert old candidate
      await db.into(db.discoveryCandidates).insert(
            DiscoveryCandidatesCompanion.insert(
              id: 'stale_track',
              title: 'Stale Song',
              artist: 'Old Artist',
              provider: 'qloo',
              createdAt: cutoff,
              status: const Value('candidate'),
            ),
          );

      // Insert old promoted track (must NOT be deleted)
      await db.into(db.discoveryCandidates).insert(
            DiscoveryCandidatesCompanion.insert(
              id: 'promoted_track',
              title: 'Keeper Song',
              artist: 'Good Artist',
              provider: 'lastfm',
              createdAt: cutoff,
              status: const Value('promoted'),
            ),
          );

      final deleted = await discoveryService.cleanupStaleCandidates();
      expect(deleted, equals(1));

      final stale = await (db.select(db.discoveryCandidates)..where((d) => d.id.equals('stale_track'))).getSingleOrNull();
      expect(stale, isNull);

      final promoted = await (db.select(db.discoveryCandidates)..where((d) => d.id.equals('promoted_track'))).getSingleOrNull();
      expect(promoted, isNotNull);
    });
  });
}
