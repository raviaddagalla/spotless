import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/db/app_database.dart';
import '../core/services/music_repository.dart';
import '../core/state/player_controller.dart';
import 'now_playing_page.dart';
import 'widgets/slidable_song_tile.dart';

class LikedSongsPage extends StatefulWidget {
  const LikedSongsPage({super.key});

  @override
  State<LikedSongsPage> createState() => _LikedSongsPageState();
}

class _LikedSongsPageState extends State<LikedSongsPage> {
  late Future<List<SongRow>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<MusicRepository>().likedSongs();
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final repo = context.read<MusicRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('Liked Songs')),
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
            return const Center(
              child: Text('Nothing liked yet — tap the heart on any song.'),
            );
          }
          return ListView.builder(
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
                      MaterialPageRoute(builder: (_) => const NowPlayingPage()),
                    );
                  }
                },
                trailing: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (v) async {
                      if (v == 'unlike') {
                        await repo.setLiked(song.id, false);
                        if (!mounted) return;
                        setState(() => _future = repo.likedSongs());
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'unlike', child: Text('Unlike')),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
