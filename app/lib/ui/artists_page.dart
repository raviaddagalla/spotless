import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/services/music_repository.dart';
import 'artist_detail_page.dart';

class ArtistsPage extends StatefulWidget {
  const ArtistsPage({super.key});

  @override
  State<ArtistsPage> createState() => _ArtistsPageState();
}

class _ArtistsPageState extends State<ArtistsPage> {
  late Future<List<({String name, int count})>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<MusicRepository>().artists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artists')),
      body: FutureBuilder<List<({String name, int count})>>(
        future: _future,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final artists = snap.data!;
          if (artists.isEmpty) {
            return const Center(child: Text('No artists yet.'));
          }
          return ListView.builder(
            itemCount: artists.length,
            itemBuilder: (context, index) {
              final a = artists[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF1DB954).withValues(alpha: 0.2),
                  child: Text(
                    a.name.isEmpty
                        ? '?'
                        : a.name[0].toUpperCase(),
                    style: const TextStyle(color: Color(0xFF1DB954)),
                  ),
                ),
                title: Text(a.name),
                subtitle: Text(
                  '${a.count} songs',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ArtistDetailPage(artist: a.name),
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
