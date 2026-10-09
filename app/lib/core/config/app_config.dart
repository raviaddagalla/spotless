/// Centralized configuration for the Spotless app.
///
/// All configurable thresholds and weights live here so they can be tuned
/// from a single location rather than being scattered as magic numbers.
class AppConfig {
  const AppConfig._();

  // ---- Session ----

  /// A new session is created when the gap since the last meaningful
  /// activity exceeds this duration.
  static const Duration sessionInactivityThreshold = Duration(hours: 1);

  // ---- Ratings ----

  /// Minimum rating (inclusive).
  static const int ratingMin = 1;

  /// Maximum rating (inclusive).
  static const int ratingMax = 10;

  // ---- Recommendation weights ----

  /// Weight of long-term taste in the final recommendation score.
  static const double longTermWeight = 0.35;

  /// Weight of the current session taste in the final recommendation score.
  static const double sessionWeight = 0.30;

  /// Weight of external recommendation provider scores.
  static const double externalWeight = 0.20;

  /// Bonus for novelty (tracks the user has never heard).
  static const double noveltyBonus = 0.10;

  /// Penalty applied for every recent repetition of a track.
  static const double repetitionPenalty = 0.25;

  /// Penalty applied when the user has given explicit negative feedback.
  static const double negativeFeedbackPenalty = 0.40;

  // ---- Implicit feedback weights ----

  /// How much an explicit rating (1-10) counts relative to implicit signals.
  static const double explicitRatingWeight = 1.0;

  /// Weight of completion percentage as implicit positive signal.
  static const double completionWeight = 0.3;

  /// Weight of a skip event as implicit negative signal.
  static const double skipWeight = 0.2;

  /// Weight of a replay event as implicit positive signal.
  static const double replayWeight = 0.4;

  // ---- Discovery / download promotion ----

  /// Rating at or above which a discovery track becomes eligible for
  /// download promotion.
  static const int downloadPromotionThreshold = 8;

  /// Maximum age of discovery candidates before they are eligible for
  /// cleanup. Candidates that are old, unplayed, skipped, or rated poorly
  /// may be purged after this duration.
  static const Duration discoveryCacheLifetime = Duration(days: 14);

  // ---- Recommendation diversity ----

  /// Maximum number of tracks from a single artist in one recommendation
  /// batch.
  static const int maxTracksPerArtist = 3;

  /// Total candidate pool size requested from external providers.
  static const int recommendationPoolSize = 40;

  /// Number of final recommendations shown to the user after filtering.
  static const int recommendationDisplaySize = 15;

  // ---- Provider settings ----

  /// Timeout for external recommendation API calls.
  static const Duration providerTimeout = Duration(seconds: 15);

  // ---- Canonical search / download ----

  /// Terms whose presence in a YouTube title cause a result to be penalized.
  static const List<String> penalizedTerms = [
    'live',
    'concert',
    'performance',
    'cover',
    'remix',
    'karaoke',
    'instrumental',
    'sped up',
    'slowed',
    'nightcore',
    'fan-made',
    'reaction',
    'compilation',
    'shorts',
    'acoustic version',
    'piano version',
    'unplugged',
  ];

  /// Terms whose presence in a YouTube title cause a result to be strongly
  /// preferred.
  static const List<String> preferredTerms = [
    'official audio',
    'official music',
    'official video',
    'audio',
  ];

  /// Channels whose names suggest official content.
  static const List<String> officialChannelHints = [
    'vevo',
    'records',
    'music',
    'official',
    'entertainment',
  ];

  /// Maximum acceptable duration difference (seconds) between the expected
  /// song duration and a YouTube candidate before penalizing.
  static const int maxDurationDiffSeconds = 30;
}
