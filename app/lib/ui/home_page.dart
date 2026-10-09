import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/db/app_database.dart';
import '../core/services/music_repository.dart';
import '../core/state/player_controller.dart';
import 'playlist_songs_page.dart';
import 'widgets/song_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<SongRow>> _recent;
  late Future<List<SongRow>> _forYou;
  late Future<List<(Playlist, int)>> _playlists;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final repo = context.read<MusicRepository>();
    _recent = repo.recent();
    _forYou = repo.forYou(15);
    _playlists = _loadPlaylists(repo);
  }

  Future<List<(Playlist, int)>> _loadPlaylists(MusicRepository repo) async {
    final list = await repo.playlists();
    final res = <(Playlist, int)>[];
    for (final pl in list) {
      final count = (await repo.playlistSongs(pl.id)).length;
      res.add((pl, count));
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(_reload);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FutureBuilder<List<SongRow>>(
            future: _recent,
            builder: (context, snap) {
              final songs = snap.data ?? const [];
              if (songs.isEmpty) return const SizedBox.shrink();
              return _section(
                context,
                'Recently played',
                _SongCardRow(
                  songs: songs,
                  loadAll: () => context.read<MusicRepository>().recent(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          FutureBuilder<List<(Playlist, int)>>(
            future: _playlists,
            builder: (context, snap) {
              final playlists = snap.data ?? const [];
              if (playlists.isEmpty) return const SizedBox.shrink();
              final colors = [
                const Color(0xFF5C6BC0),
                const Color(0xFFEF5350),
                const Color(0xFF26A69A),
                const Color(0xFFFFA726),
                const Color(0xFFAB47BC),
              ];
              return _section(
                context,
                'Playlists',
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: playlists.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final (pl, count) = playlists[index];
                      final color = colors[index % colors.length];
                      return SizedBox(
                        width: 180,
                        child: Material(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PlaylistSongsPage(
                                  playlistId: pl.id,
                                  name: pl.name,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Icon(Icons.queue_music_rounded,
                                      color: color, size: 28),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          pl.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          '$count songs',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          FutureBuilder<List<SongRow>>(
            future: _forYou,
            builder: (context, snap) {
              final songs = snap.data ?? const [];
              if (songs.isEmpty) return const SizedBox.shrink();
              return _section(
                context,
                'For you',
                _SongCardRow(
                  songs: songs,
                  loadAll: () => context.read<MusicRepository>().forYou(15),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        child,
      ],
    );
  }
}

/// Horizontal scrollable row of [SongCard]s (F5). Tapping a card plays the
/// whole section starting at that song.
class _SongCardRow extends StatelessWidget {
  final List<SongRow> songs;
  final Future<List<SongRow>> Function() loadAll;

  const _SongCardRow({required this.songs, required this.loadAll});

  void _play(BuildContext context, SongRow song) {
    final player = context.read<PlayerController>();
    loadAll().then((all) async {
      final idx = all.indexWhere((x) => x.id == song.id);
      await player.playQueue(all, startIndex: idx < 0 ? 0 : idx);
      if (context.mounted) {
        Navigator.of(context).pushNamed('now_playing');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 182,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: songs.take(10).length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final song = songs[index];
          return SongCard(song: song, onTap: () => _play(context, song));
        },
      ),
    );
  }
}
