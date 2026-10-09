import 'package:drift/drift.dart';

@DataClassName('SongRow')
class Songs extends Table {
  /// Primary key: zero-padded file index (e.g. "0000001") or spotify track uri
  /// for playlist-only songs.
  TextColumn get id => text()();

  TextColumn get filename => text().nullable()();
  TextColumn get title => text()();
  TextColumn get artist => text().withDefault(const Constant(''))();
  TextColumn get album => text().nullable()();
  TextColumn get youtubeId => text().nullable()();
  TextColumn get localPath => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('streamable'))();
  IntColumn get durationMs => integer().nullable()();

  TextColumn get albumArtUrl => text().nullable()();
  TextColumn get albumArtPath => text().nullable()();
  BoolColumn get artEmbedded => boolean().withDefault(const Constant(false))();

  // Full spotify metadata (kept for the future recommendation engine).
  TextColumn get trackUri => text().nullable()();
  TextColumn get isrc => text().nullable()();
  IntColumn get trackNumber => integer().nullable()();
  BoolColumn get explicit => boolean().withDefault(const Constant(false))();
  IntColumn get popularity => integer().nullable()();
  TextColumn get genres => text().nullable()();
  RealColumn get danceability => real().nullable()();
  RealColumn get energy => real().nullable()();
  IntColumn get key => integer().nullable()();
  RealColumn get loudness => real().nullable()();
  IntColumn get mode => integer().nullable()();
  RealColumn get speechiness => real().nullable()();
  RealColumn get acousticness => real().nullable()();
  RealColumn get instrumentalness => real().nullable()();
  RealColumn get liveness => real().nullable()();
  RealColumn get valence => real().nullable()();
  RealColumn get tempo => real().nullable()();
  IntColumn get timeSignature => integer().nullable()();
  DateTimeColumn get addedAt => dateTime().nullable()();

  IntColumn get sleepOrder => integer().nullable()();
  IntColumn get noSleepOrder => integer().nullable()();

  DateTimeColumn get lastPlayedAt => dateTime().nullable()();
  IntColumn get playCount => integer().withDefault(const Constant(0))();

  DateTimeColumn get likedAt => dateTime().nullable()();

  TextColumn get resolvedYtTitle => text().nullable()();
  TextColumn get error => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LyricsTable extends Table {
  TextColumn get songId => text()();
  /// 'lrc' (synced) or 'txt' (plain).
  TextColumn get type => text()();
  TextColumn get content => text()();

  @override
  Set<Column> get primaryKey => {songId};
}

class Playlists extends Table {
  /// 'sleep' / 'no_sleep' for the seeded playlists, 'pl_[timestamp]' for user ones.
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PlaylistSong')
class PlaylistSongs extends Table {
  TextColumn get playlistId => text()();
  TextColumn get songId => text()();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {playlistId, songId};
}

@DataClassName('ListeningSession')
class ListeningSessions extends Table {
  TextColumn get id => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get lastActivityAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  /// 'active' or 'completed'
  TextColumn get state => text().withDefault(const Constant('active'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RatingEvent')
class RatingEvents extends Table {
  TextColumn get id => text()();
  TextColumn get songId => text()();
  TextColumn get sessionId => text()();
  /// 1 to 10
  IntColumn get rating => integer()();
  DateTimeColumn get timestamp => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PlaybackEvent')
class PlaybackEvents extends Table {
  TextColumn get id => text()();
  TextColumn get songId => text()();
  TextColumn get sessionId => text()();
  /// 'play_start', 'completed', 'skip', 'replay', 'seek'
  TextColumn get eventType => text()();
  IntColumn get secondsPlayed => integer().nullable()();
  RealColumn get completionPercentage => real().nullable()();
  DateTimeColumn get timestamp => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DiscoveryCandidate')
class DiscoveryCandidates extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get artist => text()();
  TextColumn get album => text().nullable()();
  TextColumn get youtubeId => text().nullable()();
  IntColumn get durationMs => integer().nullable()();
  TextColumn get albumArtUrl => text().nullable()();
  /// 'lastfm', 'qloo', 'local'
  TextColumn get provider => text()();
  TextColumn get seedSongId => text().nullable()();
  TextColumn get sessionId => text().nullable()();
  RealColumn get score => real().withDefault(const Constant(0.0))();
  /// 'candidate', 'streamed', 'promoted', 'rejected'
  TextColumn get status => text().withDefault(const Constant('candidate'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastInteractedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
