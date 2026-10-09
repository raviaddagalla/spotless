import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Songs,
  LyricsTable,
  Playlists,
  PlaylistSongs,
  ListeningSessions,
  RatingEvents,
  PlaybackEvents,
  DiscoveryCandidates,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'spotless'));
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // `m.database` is only typed as GeneratedDatabase; the table
            // getters live on AppDatabase itself (in scope here via `this`).
            final db = this;
            await m.createTable(playlists);
            await m.createTable(playlistSongs);
            await m.addColumn(songs, songs.likedAt);
            // Seed the classic playlists from the imported CSV ordering.
            // Go through drift's typed API (not raw SQL) so the DateTime is
            // stored in whatever representation the configured storage
            // backend actually uses (unix-epoch INTEGER here), instead of a
            // bare string literal that cannot be parsed back into a DateTime.
            await db.into(db.playlists).insert(
                  PlaylistsCompanion.insert(
                    id: 'sleep',
                    name: 'Sleep',
                    createdAt: DateTime(2026, 1, 1),
                  ),
                );
            await db.into(db.playlists).insert(
                  PlaylistsCompanion.insert(
                    id: 'no_sleep',
                    name: 'No Sleep',
                    createdAt: DateTime(2026, 1, 1),
                  ),
                );
            await m.database.customStatement(
              "INSERT INTO playlist_songs (playlist_id, song_id, position) "
              "SELECT 'sleep', id, sleep_order FROM songs "
              "WHERE sleep_order IS NOT NULL ORDER BY sleep_order",
            );
            await m.database.customStatement(
              "INSERT INTO playlist_songs (playlist_id, song_id, position) "
              "SELECT 'no_sleep', id, no_sleep_order FROM songs "
              "WHERE no_sleep_order IS NOT NULL ORDER BY no_sleep_order",
            );
          }
          if (from < 3) {
            await m.createTable(listeningSessions);
            await m.createTable(ratingEvents);
            await m.createTable(playbackEvents);
            await m.createTable(discoveryCandidates);
          }
        },
      );
}
