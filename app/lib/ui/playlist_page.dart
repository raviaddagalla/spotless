import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/db/app_database.dart';
import '../core/services/music_repository.dart';
import '../core/state/player_controller.dart';
import 'now_playing_page.dart';
import 'widgets/song_tile.dart';

class PlaylistPage extends StatelessWidget {
  final String playlist;

  const PlaylistPage({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    final isSleep = playlist == 'sleep';
    return Scaffold(
      appBar: AppBar(
        title: Text(isSleep ? 'Sleep' : 'No Sleep'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Shuffle play',
            onPressed: () async {
              final repo = context.read<MusicRepository>();
              final controller = context.read<PlayerController>();
              final songs = await repo.playlist(playlist);
              final list = List.of(songs)..shuffle();
              await controller.playQueue(list);
              if (context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NowPlayingPage()),
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<SongRow>>(
        future: context.read<MusicRepository>().playlist(playlist),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final songs = snap.data!;
          final player = context.watch<PlayerController>();
          return ListView.builder(
            itemCount: songs.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: FilledButton.icon(
                    onPressed: () async {
                      await player.playQueue(songs);
                      if (context.mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const NowPlayingPage()),
                        );
                      }
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: Text('Play ${songs.length} songs'),
                  ),
                );
              }
              final song = songs[index - 1];
              return SongTile(
                song: song,
                isCurrent: player.currentSong?.id == song.id,
                onTap: () async {
                  await player.playQueue(songs, startIndex: index - 1);
                  if (context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NowPlayingPage()),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
