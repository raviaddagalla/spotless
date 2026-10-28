import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/db/app_database.dart';
import '../core/services/music_repository.dart';
import '../core/state/player_controller.dart';
import 'now_playing_page.dart';
import 'theme/spotless_colors.dart';
import 'widgets/album_art.dart';
import 'widgets/slidable_song_tile.dart';

/// Immersive artist detail screen with collapsing header, artist avatar,
/// song count, play/shuffle actions, and grouped album tracklist.
class ArtistDetailPage extends StatefulWidget {
  final String artist;

  const ArtistDetailPage({super.key, required this.artist});

  @override
  State<ArtistDetailPage> createState() => _ArtistDetailPageState();
}

class _ArtistDetailPageState extends State<ArtistDetailPage> {
  late Future<List<SongRow>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<MusicRepository>().songsByArtist(widget.artist);
  }

  Future<void> _playSongs(List<SongRow> songs, {int startIndex = 0, bool shuffle = false}) async {
    final player = context.read<PlayerController>();
    final list = shuffle ? (List.of(songs)..shuffle()) : songs;
    await player.playQueue(list, startIndex: shuffle ? 0 : startIndex);
    if (shuffle) {
      player.setShuffle(true);
    }
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NowPlayingPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: SpotlessColors.background,
      body: FutureBuilder<List<SongRow>>(
        future: _future,
        builder: (context, snap) {
          if (snap.hasError) {
            return Scaffold(
              appBar: AppBar(title: Text(widget.artist)),
              body: Center(
                child: Text(
                  'Error: ${snap.error}',
                  style: const TextStyle(color: SpotlessColors.error),
                ),
              ),
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final songs = snap.data!;
          if (songs.isEmpty) {
            return Scaffold(
              appBar: AppBar(title: Text(widget.artist)),
              body: const Center(
                child: Text(
                  'No songs found for this artist.',
                  style: TextStyle(color: SpotlessColors.onSurfaceMedium),
                ),
              ),
            );
          }

          final firstSongWithArt = songs.firstWhere(
            (s) =>
                (s.albumArtPath != null && s.albumArtPath!.isNotEmpty) ||
                (s.albumArtUrl != null && s.albumArtUrl!.isNotEmpty),
            orElse: () => songs.first,
          );

          return CustomScrollView(
            slivers: [
              // Collapsing hero header
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                stretch: true,
                backgroundColor: SpotlessColors.background,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsetsDirectional.only(
                    start: 56,
                    bottom: 16,
                    end: 16,
                  ),
                  title: Text(
                    widget.artist,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: SpotlessColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Blurred art backdrop
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.25,
                          child: AlbumArt(
                            title: widget.artist,
                            artPath: firstSongWithArt.albumArtPath,
                            artUrl: firstSongWithArt.albumArtUrl,
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
                              SpotlessColors.background.withValues(alpha: 0.8),
                              SpotlessColors.background,
                            ],
                            stops: const [0.0, 0.65, 1.0],
                          ),
                        ),
                      ),
                      // Header details
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 60),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Circular artist avatar
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                                    width: 2,
                                  ),
                                ),
                                child: ClipOval(
                                  child: AlbumArt(
                                    title: widget.artist,
                                    artPath: firstSongWithArt.albumArtPath,
                                    artUrl: firstSongWithArt.albumArtUrl,
                                    size: 110,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              // Artist info and quick actions
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ARTIST',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.artist,
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${songs.length} ${songs.length == 1 ? 'song' : 'songs'} in library',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: SpotlessColors.onSurfaceMedium,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        FilledButton.icon(
                                          onPressed: () => _playSongs(songs),
                                          icon: const Icon(Icons.play_arrow_rounded),
                                          label: const Text('Play'),
                                          style: FilledButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 10,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton.filledTonal(
                                          icon: const Icon(Icons.shuffle_rounded),
                                          tooltip: 'Shuffle',
                                          onPressed: () => _playSongs(songs, shuffle: true),
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

              // Tracklist with album groupings
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final song = songs[index];
                      final prevAlbum = index > 0 ? songs[index - 1].album : null;
                      final currentAlbum = song.album;
                      final isNewAlbum = index == 0 || currentAlbum != prevAlbum;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isNewAlbum &&
                              currentAlbum != null &&
                              currentAlbum.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.album_outlined,
                                    size: 16,
                                    color: theme.colorScheme.primary.withValues(alpha: 0.8),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      currentAlbum,
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        color: SpotlessColors.onSurfaceMedium,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          SlidableSongTile(
                            song: song,
                            isCurrent: player.currentSong?.id == song.id,
                            showStatus: true,
                            onTap: () => _playSongs(songs, startIndex: index),
                          ),
                        ],
                      );
                    },
                    childCount: songs.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
