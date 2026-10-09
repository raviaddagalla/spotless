import '../db/app_database.dart';

/// Representation of a candidate track returned by a recommendation provider.
class RecommendationCandidate {
  final String title;
  final String artist;
  final String? album;
  final int? durationSeconds;
  final String? albumArtUrl;
  final String providerName;
  final String? seedTrackTitle;
  final String? seedArtist;
  final double providerScore; // 0.0 to 1.0
  final SongRow? existingSong;

  const RecommendationCandidate({
    required this.title,
    required this.artist,
    this.album,
    this.durationSeconds,
    this.albumArtUrl,
    required this.providerName,
    this.seedTrackTitle,
    this.seedArtist,
    this.providerScore = 0.5,
    this.existingSong,
  });

  @override
  String toString() => '$artist - $title ($providerName, score: $providerScore)';
}

/// Abstract provider interface for music recommendations.
///
/// Per Specification §17 & §47:
/// - Provides a decoupled interface for Last.fm, Qloo, or local fallback.
/// - Gracefully degrades on network error, rate limit, or missing credentials.
/// - Never crashes the host application.
abstract class RecommendationProvider {
  /// User-friendly name of this provider.
  String get name;

  /// Whether this provider has valid configuration/credentials to be queried.
  bool get isConfigured;

  /// Fetches candidates similar to a specific track.
  Future<List<RecommendationCandidate>> getSimilarTracks({
    required String artist,
    required String title,
    int limit = 15,
  });

  /// Fetches candidates for a list of seed tracks (combining long-term and session seeds).
  Future<List<RecommendationCandidate>> getRecommendationsForSeeds({
    required List<SongRow> longTermSeeds,
    required List<SongRow> sessionSeeds,
    int limit = 20,
  });
}
