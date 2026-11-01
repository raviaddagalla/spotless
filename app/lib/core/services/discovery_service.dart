import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

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
      try {
        final results = await p.getSimilarTracks(
          artist: seedTrack.artist,
          title: seedTrack.title,
          limit: limit,
        );
        rawCandidates.addAll(results);
      } catch (e) {
        // One flaky external provider must not take down the whole radio,
        // especially when the offline local provider is available.
        debugPrint('[discovery] ${p.name} similar failed: $e');
      }
    }

    return _filterRankAndPersist(rawCandidates,
        seedTrackId: seedTrack.id, limit: limit);
  }

  /// Discovers candidates combining long-term taste seeds and current-session
  /// seeds (Specification §19-§20 & §41).
  ///
  /// Opening the Discovery screen is not listening activity, so this method
  /// deliberately uses [SessionManager.getActiveSession] rather than
  /// [SessionManager.getOrCreateActiveSession]. Otherwise merely browsing
  /// recommendations would create a session and break session continuity.
  Future<List<ScoredDiscoveryTrack>> discoverPersonalized(
      {int limit = 15}) async {
    final activeSession = await sessionManager.getActiveSession();

    // 1. Current session seeds (rated highly or played in this session).
    final sessionSeeds = <SongRow>[];
    if (activeSession != null) {
      final sessionRatings =
          await sessionManager.getSessionRatings(activeSession.id);
      final likedIds = sessionRatings
          .where((r) => r.rating >= 7)
          .map((r) => r.songId)
          .toSet();
      if (likedIds.isNotEmpty) {
        sessionSeeds.addAll(await (db.select(db.songs)
              ..where((s) => s.id.isIn(likedIds)))
            .get());
      }
      final events =
          await sessionManager.getSessionPlaybackEvents(activeSession.id);
      final playedIds = events
          .where((e) => e.eventType == 'play_start' || e.eventType == 'completed')
          .map((e) => e.songId)
          .where((id) => !likedIds.contains(id))
          .toSet()
          .take(4);
      if (playedIds.isNotEmpty) {
        sessionSeeds.addAll(await (db.select(db.songs)
              ..where((s) => s.id.isIn(playedIds)))
            .get());
      }
    }

    // 2. Long-term seeds (consistently high-rated tracks / frequent plays).
    final longTermLiked = await (db.select(db.songs)
          ..where(
              (s) => s.likedAt.isNotNull() | s.playCount.isBiggerThanValue(3))
          ..orderBy([
            (s) => OrderingTerm.desc(s.playCount),
            (s) => OrderingTerm.desc(s.likedAt),
          ])
          ..limit(10))
        .get();

    final rawCandidates = <RecommendationCandidate>[];
    for (final p in providers) {
      if (!p.isConfigured) continue;
      try {
        final results = await p.getRecommendationsForSeeds(
          longTermSeeds: longTermLiked,
          sessionSeeds: sessionSeeds,
          limit: limit * 2,
        );
        rawCandidates.addAll(results);
      } catch (e) {
        debugPrint('[discovery] ${p.name} recommendations failed: $e');
      }
    }

    return _filterRankAndPersist(
      rawCandidates,
      sessionId: activeSession?.id,
      limit: limit,
    );
  }

  /// Filters out owned tracks, deduplicates, scores using multi-component
  /// ranking, applies artist diversity, and persists into DiscoveryCandidates.
  Future<List<ScoredDiscoveryTrack>> _filterRankAndPersist(
    List<RecommendationCandidate> raw, {
    String? seedTrackId,
    String? sessionId,
    int limit = 15,
  }) async {
    // 1. Owned songs, for novelty/filtering decisions.
    final ownedSongs = await (db.select(db.songs)).get();
    final ownedSet = <String>{};
    for (final s in ownedSongs) {
      ownedSet.add(_key(s.artist, s.title));
    }

    // 2. Deduplicate raw candidates. Local-library candidates are already
    // owned by definition and are intentionally allowed (offline radio).
    final deduped = <String, RecommendationCandidate>{};
    for (final c in raw) {
      final key = _key(c.artist, c.title);
      final isLocal = c.providerName == 'Local Library';
      if ((isLocal || !ownedSet.contains(key)) && !deduped.containsKey(key)) {
        deduped[key] = c;
      }
    }

    // 3. Preload previous candidate records keyed by title+artist.
    final previousCandidates = await (db.select(db.discoveryCandidates)).get();
    final previousByKey = <String, DiscoveryCandidate>{
      for (final c in previousCandidates) _key(c.artist, c.title): c,
    };

    // 4. Build taste profiles from rating history (separate session vs
    // long-term; no clock-of-day inference).
    final taste = await _buildTasteProfile(sessionId: sessionId);

    // 5. Multi-component scoring (Spec §15):
    // external + session taste + long-term taste + novelty - penalties.
    final scoredList = <ScoredDiscoveryTrack>[];

    for (final c in deduped.values) {
      final key = _key(c.artist, c.title);
      final existingCandidate = previousByKey[key];
      final isOwned = ownedSet.contains(key);
      final artistKey = c.artist.trim().toLowerCase();

      double score = 0.0;
      score += c.providerScore.clamp(0.0, 1.0) * AppConfig.externalWeight;
      score += _affinity(taste.sessionArtists[artistKey]) *
          AppConfig.sessionWeight;
      score += _affinity(taste.longTermArtists[artistKey]) *
          AppConfig.longTermWeight;

      // Novelty is only meaningful for tracks the user does not own.
      if (!isOwned && !taste.playedArtists.containsKey(artistKey)) {
        score += AppConfig.noveltyBonus;
      }

      if (existingCandidate != null) {
        if (existingCandidate.status == 'rejected') {
          score -= AppConfig.negativeFeedbackPenalty;
        } else if (existingCandidate.status == 'streamed') {
          score -= AppConfig.repetitionPenalty * 0.5;
        } else if (existingCandidate.status == 'promoted') {
          // Already promoted; keep it available but don't recommend it as new.
          score -= AppConfig.repetitionPenalty;
        }
      }

      final candidateId = c.existingSong?.id ??
          existingCandidate?.id ??
          _candidateId(c.artist, c.title);

      // Explicit ratings for this candidate are strong signals.
      if (existingCandidate != null) {
        final rating = await ratingService.getLatestRating(candidateId);
        if (rating != null) {
          if (rating <= 3) {
            score -= AppConfig.negativeFeedbackPenalty;
          } else if (rating >= 8) {
            score += 0.15;
          }
        }
      }

      scoredList.add(ScoredDiscoveryTrack(
        id: candidateId,
        title: c.title,
        artist: c.artist,
        album: c.album,
        youtubeId: c.existingSong?.youtubeId ?? existingCandidate?.youtubeId,
        albumArtUrl: c.albumArtUrl,
        durationMs:
            c.durationSeconds != null ? c.durationSeconds! * 1000 : null,
        provider: c.providerName,
        score: score.clamp(0.0, 1.0),
        status: existingCandidate?.status ??
            (c.existingSong != null ? 'owned' : 'candidate'),
        existingSong: c.existingSong,
      ));
    }

    // 6. Sort by score descending.
    scoredList.sort((a, b) => b.score.compareTo(a.score));

    // 7. Apply artist diversity (Spec §40): max N per artist.
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

    // 8. Persist candidates to database for offline caching & tracking.
    // Preserve the original createdAt so cleanup reflects first discovery.
    final now = DateTime.now();
    for (final t in diverseList) {
      final previous = previousByKey[_key(t.artist, t.title)];
      await db.into(db.discoveryCandidates).insertOnConflictUpdate(
            DiscoveryCandidatesCompanion.insert(
              id: t.id,
              title: t.title,
              artist: t.artist,
              album: Value(t.album),
              youtubeId: Value(t.youtubeId),
              albumArtUrl: Value(t.albumArtUrl),
              durationMs: Value(t.durationMs),
              provider: t.provider,
              seedSongId: Value(seedTrackId),
              sessionId: Value(sessionId),
              score: Value(t.score),
              status: Value(t.status),
              createdAt: previous?.createdAt ?? now,
              lastInteractedAt: Value(previous?.lastInteractedAt),
            ),
          );
    }

    return diverseList;
  }

  /// Marks a candidate as streamed (repetition penalty + interaction time).
  Future<void> markStreamed(ScoredDiscoveryTrack candidate,
      {String? youtubeId}) async {
    await (db.update(db.discoveryCandidates)
          ..where((d) => d.id.equals(candidate.id)))
        .write(DiscoveryCandidatesCompanion(
      status: const Value('streamed'),
      youtubeId: Value(youtubeId ?? candidate.youtubeId),
      score: Value(candidate.score),
      lastInteractedAt: Value(DateTime.now()),
    ));
  }

  /// Promotes a discovery candidate to a permanent song (Spec §22).
  Future<void> promoteCandidate(ScoredDiscoveryTrack candidate) async {
    final existing = await (db.select(db.songs)
          ..where((s) => s.id.equals(candidate.id)))
        .getSingleOrNull();

    if (existing == null) {
      await db.into(db.songs).insert(
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
            mode: InsertMode.insertOrIgnore,
          );
    } else {
      // Never overwrite play counts, likes, ratings or a downloaded file when
      // "promoting" a track that is already in the library.
      await (db.update(db.songs)..where((s) => s.id.equals(candidate.id)))
          .write(SongsCompanion(
        youtubeId: Value(existing.youtubeId ?? candidate.youtubeId),
        albumArtUrl: Value(existing.albumArtUrl ?? candidate.albumArtUrl),
        durationMs: Value(existing.durationMs ?? candidate.durationMs),
        album: Value(existing.album ?? candidate.album),
      ));
    }

    final old = await (db.select(db.discoveryCandidates)
          ..where((d) => d.id.equals(candidate.id)))
        .getSingleOrNull();
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
            createdAt: old?.createdAt ?? DateTime.now(),
            lastInteractedAt: Value(DateTime.now()),
          ),
        );
  }

  /// Cleans up stale discovery candidates older than cache lifetime (Spec §24).
  Future<int> cleanupStaleCandidates() async {
    final cutoff = DateTime.now().subtract(AppConfig.discoveryCacheLifetime);
    return (db.delete(db.discoveryCandidates)
          ..where((d) =>
              d.status.isNotIn(['promoted']) &
              d.createdAt.isSmallerThanValue(cutoff)))
        .go();
  }

  Future<_TasteProfile> _buildTasteProfile({String? sessionId}) async {
    final events = await (db.select(db.ratingEvents)).get();
    if (events.isEmpty) return const _TasteProfile({}, {}, {});

    final songIds = events.map((e) => e.songId).toSet();
    final songs = await (db.select(db.songs)
          ..where((s) => s.id.isIn(songIds)))
        .get();
    final songsById = {for (final s in songs) s.id: s};

    final longTerm = <String, double>{};
    final session = <String, double>{};
    final playedArtists = <String, int>{};

    for (final e in events) {
      final song = songsById[e.songId];
      if (song == null) continue;
      final artist = song.artist.trim().toLowerCase();
      if (artist.isEmpty) continue;
      // -1.0 (hate) .. +1.0 (love), neutral around 5.5.
      final weight = ((e.rating - 5.5) / 4.5).clamp(-1.0, 1.0);
      longTerm[artist] = (longTerm[artist] ?? 0) + weight;
      if (sessionId != null && e.sessionId == sessionId) {
        session[artist] = (session[artist] ?? 0) + weight;
      }
      playedArtists[artist] = (playedArtists[artist] ?? 0) + 1;
    }

    return _TasteProfile(
      _normalize(longTerm),
      _normalize(session),
      playedArtists,
    );
  }

  static Map<String, double> _normalize(Map<String, double> raw) {
    if (raw.isEmpty) return const {};
    final maxAbs = raw.values.map((v) => v.abs()).reduce(math.max);
    if (maxAbs == 0) return const {};
    return raw.map((k, v) => MapEntry(k, (v / maxAbs).clamp(-1.0, 1.0)));
  }

  /// Maps -1..1 affinity to 0..1, with 0.5 neutral.
  static double _affinity(double? value) => value == null ? 0.5 : (value + 1) / 2;

  static String _key(String artist, String title) =>
      '${artist.trim().toLowerCase()}:::${title.trim().toLowerCase()}';

  /// Stable, Unicode-safe candidate ID. The old sanitizer stripped every
  /// non-ASCII character, so Telugu/Tamil/Hindi recommendations all collapsed
  /// onto the same id and overwrote each other.
  static String _candidateId(String artist, String title) {
    final key = '${artist.trim().toLowerCase()}|${title.trim().toLowerCase()}';
    var hash = 0x811c9dc5;
    for (final unit in key.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return 'disc_${hash.toRadixString(16).padLeft(8, '0')}';
  }
}

class _TasteProfile {
  final Map<String, double> longTermArtists;
  final Map<String, double> sessionArtists;
  final Map<String, int> playedArtists;

  const _TasteProfile(
      this.longTermArtists, this.sessionArtists, this.playedArtists);
}
