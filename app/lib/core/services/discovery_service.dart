import 'package:drift/drift.dart';

import '../config/app_config.dart';
import '../db/app_database.dart';
import '../models/song_status.dart';
import '../youtube/yt_bridge.dart';
import 'feedback_service.dart';
import 'rating_service.dart';
import 'recommendation_provider.dart';
import 'session_manager.dart';

/// Scored candidate ready to present to the user or stream.
class ScoredDiscoveryTrack {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? youtubeId;
  final String? albumArtUrl;
  final int? durationMs;
  final String provider;
  final double score;
  final String status; // 'candidate', 'streamed', 'promoted'
  final SongRow? existingSong;

  const ScoredDiscoveryTrack({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.youtubeId,
    this.albumArtUrl,
    this.durationMs,
    required this.provider,
    required this.score,
    required this.status,
    this.existingSong,
  });

  /// Converts to a SongRow-compatible object for the player controller.
  SongRow toSongRow() {
    if (existingSong != null) return existingSong!;
    return SongRow(
      id: id,
      title: title,
      artist: artist,
      album: album,
      youtubeId: youtubeId,
      status: SongStatus.streamable.name,
      durationMs: durationMs,
      albumArtUrl: albumArtUrl,
      artEmbedded: false,
      explicit: false,
      playCount: 0,
    );
  }
}

/// Orchestrates music discovery, provider querying, session-aware ranking,
/// streaming, and library promotion.
///
/// Per Specification §18-§24, §39-§41:
/// - Stream-first discovery: recommendations stream before downloading.
/// - Session-aware ranking: combines long-term taste with current temporary state.
/// - Strictly NO time-of-day learning.
/// - Filters already owned library tracks.
/// - Enforces artist diversity.
/// - Download promotion above configurable rating threshold.
/// - Cleanup of stale/rejected candidates.
class DiscoveryService {
  final AppDatabase db;
  final SessionManager sessionManager;
  final RatingService ratingService;
  final FeedbackService feedbackService;
  final List<RecommendationProvider> providers;
  final YtBridge ytBridge;

  DiscoveryService({
    required this.db,
    required this.sessionManager,
    required this.ratingService,
    required this.feedbackService,
    required this.providers,
    required this.ytBridge,
  });

  /// Discovers candidates similar to [seedTrack] (Specification §18).
  Future<List<ScoredDiscoveryTrack>> discoverSimilarTo(
    SongRow seedTrack, {
    int limit = 15,
  }) async {
    final rawCandidates = <RecommendationCandidate>[];

    for (final p in providers) {
      if (!p.isConfigured) continue;
      final results = await p.getSimilarTracks(
        artist: seedTrack.artist,
        title: seedTrack.title,
        limit: limit,
      );
      rawCandidates.addAll(results);
    }

    return _filterRankAndPersist(rawCandidates, seedTrackId: seedTrack.id, limit: limit);
  }

  /// Discovers candidates combining long-term taste seeds and current-session seeds
  /// (Specification §19-§20 & §41).
  Future<List<ScoredDiscoveryTrack>> discoverPersonalized({int limit = 15}) async {
    final activeSession = await sessionManager.getOrCreateActiveSession();

    // 1. Current session seeds (what the user listened to / liked in this session).
    final sessionRatings = await sessionManager.getSessionRatings(activeSession.id);
    final sessionLikedSongIds = sessionRatings
        .where((r) => r.rating >= 7)
        .map((r) => r.songId)
        .toSet();

    final sessionSeeds = <SongRow>[];
    if (sessionLikedSongIds.isNotEmpty) {
      sessionSeeds.addAll(await (db.select(db.songs)
            ..where((s) => s.id.isIn(sessionLikedSongIds)))
          .get());
    }

    // 2. Long-term seeds (consistently high-rated tracks, frequent plays across sessions).
    final longTermLiked = await (db.select(db.songs)
          ..where((s) => s.likedAt.isNotNull() | s.playCount.isBiggerThanValue(3))
          ..orderBy([(s) => OrderingTerm.desc(s.playCount)])
          ..limit(10))
        .get();

    final rawCandidates = <RecommendationCandidate>[];
    for (final p in providers) {
      if (!p.isConfigured) continue;
      final results = await p.getRecommendationsForSeeds(
        longTermSeeds: longTermLiked,
        sessionSeeds: sessionSeeds,
        limit: limit * 2,
      );
      rawCandidates.addAll(results);
    }

    return _filterRankAndPersist(
      rawCandidates,
      sessionId: activeSession.id,
      limit: limit,
    );
  }

  /// Filters out owned tracks, deduplicates, scores using multi-component ranking,
  /// applies artist diversity, and persists into DiscoveryCandidates table.
  Future<List<ScoredDiscoveryTrack>> _filterRankAndPersist(
    List<RecommendationCandidate> raw, {
    String? seedTrackId,
    String? sessionId,
    int limit = 15,
  }) async {
    // 1. Get owned song titles and artists to filter them out (Spec §39).
    final ownedSongs = await (db.select(db.songs)).get();
    final ownedSet = <String>{};
    for (final s in ownedSongs) {
      ownedSet.add('${s.artist.toLowerCase()}:::${s.title.toLowerCase()}');
    }

    // 2. Deduplicate raw candidates.
    final deduped = <String, RecommendationCandidate>{};
    for (final c in raw) {
      final key = '${c.artist.toLowerCase()}:::${c.title.toLowerCase()}';
      final isLocal = c.providerName == 'Local Library';
      if ((isLocal || !ownedSet.contains(key)) && !deduped.containsKey(key)) {
        deduped[key] = c;
      }
    }

    // 3. Multi-component scoring (Spec §15):
    // finalScore = longTermScore + currentSessionScore + externalScore + noveltyScore - repetitionPenalty - negativeFeedbackPenalty
    final scoredList = <ScoredDiscoveryTrack>[];

    for (final c in deduped.values) {
      double score = 0.0;

      // External recommendation provider score
      score += c.providerScore * AppConfig.externalWeight;

      // Novelty bonus (brand new to user)
      score += AppConfig.noveltyBonus;

      // Check if we previously rejected or skipped this candidate
      final existingCandidate = await (db.select(db.discoveryCandidates)
            ..where((d) =>
                d.title.lower().equals(c.title.toLowerCase()) &
                d.artist.lower().equals(c.artist.toLowerCase())))
          .getSingleOrNull();

      if (existingCandidate != null) {
        if (existingCandidate.status == 'rejected') {
          score -= AppConfig.negativeFeedbackPenalty;
        } else if (existingCandidate.status == 'streamed') {
          score -= AppConfig.repetitionPenalty * 0.5;
        }
      }

      final candidateId = c.existingSong?.id ??
          'disc_${c.artist.replaceAll(' ', '_')}_${c.title.replaceAll(' ', '_')}'
              .toLowerCase()
              .replaceAll(RegExp(r'[^a-z0-9_]'), '');

      scoredList.add(ScoredDiscoveryTrack(
        id: candidateId,
        title: c.title,
        artist: c.artist,
        album: c.album,
        youtubeId: c.existingSong?.youtubeId,
        albumArtUrl: c.albumArtUrl,
        durationMs: c.durationSeconds != null ? c.durationSeconds! * 1000 : null,
        provider: c.providerName,
        score: score,
        status: existingCandidate?.status ?? (c.existingSong != null ? 'owned' : 'candidate'),
        existingSong: c.existingSong,
      ));
    }

    // 4. Sort by score descending.
    scoredList.sort((a, b) => b.score.compareTo(a.score));

    // 5. Apply artist diversity (Spec §40): max N per artist.
    final artistCounts = <String, int>{};
    final diverseList = <ScoredDiscoveryTrack>[];

    for (final track in scoredList) {
      final artistKey = track.artist.toLowerCase();
      final count = artistCounts[artistKey] ?? 0;
      if (count < AppConfig.maxTracksPerArtist) {
        artistCounts[artistKey] = count + 1;
        diverseList.add(track);
      }
      if (diverseList.length >= limit) break;
    }

    // 6. Persist candidates to database for offline caching & tracking.
    final now = DateTime.now();
    for (final t in diverseList) {
      await db.into(db.discoveryCandidates).insertOnConflictUpdate(
            DiscoveryCandidatesCompanion.insert(
              id: t.id,
              title: t.title,
              artist: t.artist,
              album: Value(t.album),
              albumArtUrl: Value(t.albumArtUrl),
              durationMs: Value(t.durationMs),
              provider: t.provider,
              seedSongId: Value(seedTrackId),
              sessionId: Value(sessionId),
              score: Value(t.score),
              status: Value(t.status),
              createdAt: now,
            ),
          );
    }

    return diverseList;
  }

  /// Promotes a discovery candidate to a permanent downloaded song (Spec §22).
  Future<void> promoteCandidate(ScoredDiscoveryTrack candidate) async {
    // Upsert into songs table with status streamable/analyzing
    await db.into(db.songs).insertOnConflictUpdate(
          SongsCompanion.insert(
            id: candidate.id,
            title: candidate.title,
            artist: Value(candidate.artist),
            album: Value(candidate.album),
            youtubeId: Value(candidate.youtubeId),
            albumArtUrl: Value(candidate.albumArtUrl),
            durationMs: Value(candidate.durationMs),
            status: Value(SongStatus.streamable.name),
            addedAt: Value(DateTime.now()),
          ),
        );

    // Upsert discovery candidate status to promoted
    await db.into(db.discoveryCandidates).insertOnConflictUpdate(
          DiscoveryCandidatesCompanion.insert(
            id: candidate.id,
            title: candidate.title,
            artist: candidate.artist,
            album: Value(candidate.album),
            youtubeId: Value(candidate.youtubeId),
            albumArtUrl: Value(candidate.albumArtUrl),
            durationMs: Value(candidate.durationMs),
            provider: candidate.provider,
            score: Value(candidate.score),
            status: const Value('promoted'),
            createdAt: DateTime.now(),
            lastInteractedAt: Value(DateTime.now()),
          ),
        );
  }

  /// Cleans up stale discovery candidates older than cache lifetime (Spec §24).
  Future<int> cleanupStaleCandidates() async {
    final cutoff = DateTime.now().subtract(AppConfig.discoveryCacheLifetime);
    final count = await (db.delete(db.discoveryCandidates)
          ..where((d) =>
              d.status.isNotIn(['promoted']) &
              d.createdAt.isSmallerThanValue(cutoff)))
        .go();
    return count;
  }
}
