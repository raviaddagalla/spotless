import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/db/app_database.dart';
import '../core/services/music_repository.dart';
import '../core/state/player_controller.dart';
import 'now_playing_page.dart';
import 'theme/spotless_colors.dart';
import 'widgets/album_art.dart';
import 'widgets/slidable_song_tile.dart';

/// Album detail page with a PixelPlayer-style collapsing header showing
/// large album art, title/artist, song count, and play/shuffle actions.
class AlbumDetailPage extends StatefulWidget {
  final String album;
  final String artist;

  const AlbumDetailPage({
    super.key,
    required this.album,
    required this.artist,
  });

  @override
  State<AlbumDetailPage> createState() => _AlbumDetailPageState();
}

class _AlbumDetailPageState extends State<AlbumDetailPage> {
  late Future<List<SongRow>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<MusicRepository>().songsByAlbum(widget.album);
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final theme = Theme.of(context);

    return Scaffold(
      body: FutureBuilder<List<SongRow>>(
        future: _future,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final songs = snap.data!;
          if (songs.isEmpty) {
            return Scaffold(
              appBar: AppBar(title: Text(widget.album)),
              body: const Center(child: Text('No songs in this album.')),
            );
          }
          return CustomScrollView(
            slivers: [
              // ---- Collapsing header ----
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                stretch: true,
                backgroundColor: SpotlessColors.background,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Album art background (blurred)
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.3,
                          child: AlbumArt(
                            title: widget.album,
                            artPath: songs.first.albumArtPath,
                            artUrl: songs.first.albumArtUrl,
                            size: 400,
                          ),
                        ),
                      ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              SpotlessColors.background,
                            ],
                          ),
                        ),
                      ),
                      // Content
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      SpotlessColors.radiusMd),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      SpotlessColors.radiusMd),
                                  child: AlbumArt(
                                    title: widget.album,
                                    artPath: songs.first.albumArtPath,
                                    artUrl: songs.first.albumArtUrl,
                                    size: 140,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.album,
                                      style: theme.textTheme.headlineSmall,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.artist,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: SpotlessColors.onSurfaceMedium,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${songs.length} songs',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: SpotlessColors.onSurfaceDim,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        FilledButton.icon(
                                          onPressed: () async {
                                            await player.playQueue(songs);
                                            if (context.mounted) {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const NowPlayingPage(),
                                                ),
                                              );
                                            }
                                          },
                                          icon:
                                              const Icon(Icons.play_arrow),
                                          label: const Text('Play'),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton.filledTonal(
                                          icon: const Icon(Icons.shuffle),
                                          tooltip: 'Shuffle',
                                          onPressed: () async {
                                            await player.playQueue(songs);
                                            player.setShuffle(true);
                                            if (context.mounted) {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const NowPlayingPage(),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---- Song list ----
              SliverList.builder(
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  return SlidableSongTile(
                    song: song,
                    isCurrent: player.currentSong?.id == song.id,
                    showStatus: true,
                    onTap: () async {
                      await player.playQueue(songs, startIndex: index);
                      if (context.mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const NowPlayingPage(),
                          ),
                        );
                      }
                    },
                  );
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
    );
  }
}
