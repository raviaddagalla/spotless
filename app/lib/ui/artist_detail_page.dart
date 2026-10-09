import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/db/app_database.dart';
import '../core/services/music_repository.dart';
import '../core/state/player_controller.dart';
import 'now_playing_page.dart';
import 'widgets/slidable_song_tile.dart';

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

  Future<void> _playAll() async {
    final player = context.read<PlayerController>();
    final songs = await _future;
    if (!mounted) return;
    await player.playQueue(songs);
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NowPlayingPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.artist),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            tooltip: 'Play all',
            onPressed: _playAll,
          ),
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Shuffle all',
            onPressed: () async {
              final player = context.read<PlayerController>();
              final navigator = Navigator.of(context);
              final songs = await context
                  .read<MusicRepository>()
                  .songsByArtist(widget.artist);
              if (!mounted) return;
              await player.playQueue(songs);
              player.setShuffle(true);
              if (mounted) {
                navigator.push(
                  MaterialPageRoute(builder: (_) => const NowPlayingPage()),
                );
              }
            },
          ),
        ],
      ),
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
            return const Center(child: Text('No songs by this artist.'));
          }
          String? lastAlbum;
          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              final album = song.album ?? '';
              final header = album != lastAlbum ? album : null;
              lastAlbum = album;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (header != null && header.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(
                        header,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(color: Colors.grey.shade400),
                      ),
                    ),
                  SlidableSongTile(
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
