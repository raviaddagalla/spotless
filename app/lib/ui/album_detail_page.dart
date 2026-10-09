import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/db/app_database.dart';
import '../core/services/music_repository.dart';
import '../core/state/player_controller.dart';
import 'now_playing_page.dart';
import 'widgets/album_art.dart';
import 'widgets/slidable_song_tile.dart';

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
    return Scaffold(
      appBar: AppBar(title: Text(widget.album)),
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
            return const Center(child: Text('No songs in this album.'));
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    AlbumArt(title: widget.album, size: 96),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.album,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.artist,
                            style: TextStyle(color: Colors.grey.shade400),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${songs.length} songs',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade500),
                          ),
                          const SizedBox(height: 8),
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
                                icon: const Icon(Icons.play_arrow),
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
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
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
              ),
            ],
          );
        },
      ),
    );
  }
}
