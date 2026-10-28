import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/db/app_database.dart';
import '../core/services/music_repository.dart';
import '../core/state/player_controller.dart';
import 'now_playing_page.dart';
import 'theme/spotless_colors.dart';
import 'widgets/album_art.dart';
import 'widgets/slidable_song_tile.dart';

/// Redesigned playlist details page with hero header, play/shuffle actions,
/// and smooth reorderable drag-and-drop tracklist.
class PlaylistSongsPage extends StatefulWidget {
  final String playlistId;
  final String name;

  const PlaylistSongsPage({
    super.key,
    required this.playlistId,
    required this.name,
  });

  @override
  State<PlaylistSongsPage> createState() => _PlaylistSongsPageState();
}

class _PlaylistSongsPageState extends State<PlaylistSongsPage> {
  List<SongRow>? _songs;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rows = await context
          .read<MusicRepository>()
          .playlistSongRows(widget.playlistId);
      if (mounted) {
        setState(() {
          _songs = List.of(rows);
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    final list = _songs;
    if (list == null) return;
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final song = list.removeAt(oldIndex);
      list.insert(newIndex, song);
    });
    final repo = context.read<MusicRepository>();
    await repo.reorderPlaylistSong(widget.playlistId, oldIndex, newIndex);
  }

  Future<void> _playQueue(List<SongRow> songs, {int startIndex = 0, bool shuffle = false}) async {
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
    final repo = context.read<MusicRepository>();
    final theme = Theme.of(context);
    final songs = _songs;

    return Scaffold(
      backgroundColor: SpotlessColors.background,
      appBar: AppBar(
        title: Text(
          widget.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    'Error: $_error',
                    style: const TextStyle(color: SpotlessColors.error),
                  ),
                )
              : songs == null || songs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.queue_music_rounded,
                            size: 64,
                            color: SpotlessColors.onSurfaceDim,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Playlist is empty',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: SpotlessColors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              'Add songs to this playlist from the track menu in your library or search results.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: SpotlessColors.onSurfaceMedium,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.only(bottom: 120),
                      // ignore: deprecated_member_use
                      onReorder: _onReorder,
                      header: _buildHeader(songs, theme),
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        return SlidableSongTile(
                          key: ValueKey(song.id),
                          song: song,
                          isCurrent: player.currentSong?.id == song.id,
                          showStatus: true,
                          onTap: () => _playQueue(songs, startIndex: index),
                          trailing: [
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                color: SpotlessColors.onSurfaceMedium,
                              ),
                              onSelected: (v) async {
                                if (v == 'remove') {
                                  await repo.removeFromPlaylist(
                                    widget.playlistId,
                                    song.id,
                                  );
                                  _load();
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'remove',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        size: 20,
                                        color: SpotlessColors.error,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Remove from playlist',
                                        style: TextStyle(
                                          color: SpotlessColors.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            ReorderableDragStartListener(
                              index: index,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(
                                  Icons.drag_handle_rounded,
                                  color: SpotlessColors.onSurfaceDim,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
    );
  }

  Widget _buildHeader(List<SongRow> songs, ThemeData theme) {
    final firstSongWithArt = songs.firstWhere(
      (s) =>
          (s.albumArtPath != null && s.albumArtPath!.isNotEmpty) ||
          (s.albumArtUrl != null && s.albumArtUrl!.isNotEmpty),
      orElse: () => songs.first,
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SpotlessColors.surfaceContainer,
        borderRadius: BorderRadius.circular(SpotlessColors.radiusLg),
        border: Border.all(
          color: SpotlessColors.surfaceContainerHighest.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(SpotlessColors.radiusMd),
                child: AlbumArt(
                  title: widget.name,
                  artPath: firstSongWithArt.albumArtPath,
                  artUrl: firstSongWithArt.albumArtUrl,
                  size: 90,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PLAYLIST',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${songs.length} ${songs.length == 1 ? 'track' : 'tracks'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: SpotlessColors.onSurfaceMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _playQueue(songs),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Play All'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _playQueue(songs, shuffle: true),
                  icon: const Icon(Icons.shuffle_rounded),
                  label: const Text('Shuffle'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
