import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/services/music_repository.dart';
import 'album_detail_page.dart';
import 'widgets/album_art.dart';

class AlbumsPage extends StatefulWidget {
  const AlbumsPage({super.key});

  @override
  State<AlbumsPage> createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage> {
  late Future<List<({String album, String artist, int count})>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<MusicRepository>().albums();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Albums')),
      body: FutureBuilder<List<({String album, String artist, int count})>>(
        future: _future,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final albums = snap.data!;
          if (albums.isEmpty) {
            return const Center(child: Text('No albums yet.'));
          }
          return ListView.builder(
            itemCount: albums.length,
            itemBuilder: (context, index) {
              final a = albums[index];
              return ListTile(
                leading: AlbumArt(
                  title: a.album,
                  subtitle: a.artist,
                  size: 48,
                ),
                title: Text(
                  a.album,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${a.artist} · ${a.count} songs',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AlbumDetailPage(
                        album: a.album,
                        artist: a.artist,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
