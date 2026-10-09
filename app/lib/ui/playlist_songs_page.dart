import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/db/app_database.dart';
import '../core/services/music_repository.dart';
import '../core/state/player_controller.dart';
import 'now_playing_page.dart';
import 'widgets/slidable_song_tile.dart';

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

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final repo = context.read<MusicRepository>();
    final songs = _songs;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          if (songs != null && songs.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.shuffle_rounded),
              tooltip: 'Shuffle play',
              onPressed: () async {
                final list = List.of(songs)..shuffle();
                await player.playQueue(list);
                if (context.mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NowPlayingPage()),
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.play_arrow_rounded),
              tooltip: 'Play all',
              onPressed: () async {
                await player.playQueue(songs);
                if (context.mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NowPlayingPage()),
                  );
                }
              },
            ),
          ],
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : songs == null || songs.isEmpty
                  ? const Center(
                      child: Text('No songs yet — use "Add to playlist" from a '
                          'song menu in the Library.'),
                    )
                  : ReorderableListView.builder(
                      // ignore: deprecated_member_use
                      onReorder: _onReorder,
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        return SlidableSongTile(
                          key: ValueKey(song.id),
                          song: song,
                          isCurrent: player.currentSong?.id == song.id,
                          showStatus: true,
                          onTap: () async {
                            await player.playQueue(songs, startIndex: index);
                            if (context.mounted) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const NowPlayingPage()),
                              );
                            }
                          },
                          trailing: [
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (v) async {
                                if (v == 'remove') {
                                  await repo.removeFromPlaylist(
                                      widget.playlistId, song.id);
                                  _load();
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'remove',
                                  child: Text('Remove from playlist'),
                                ),
                              ],
                            ),
                            ReorderableDragStartListener(
                              index: index,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(Icons.drag_handle_rounded,
                                    color: Colors.white38),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
    );
  }
}
