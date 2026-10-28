import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/services/music_repository.dart';
import 'album_detail_page.dart';
import 'theme/spotless_colors.dart';
import 'widgets/album_art.dart';

/// Grid/list of albums with large art and rounded card containers.
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
    final theme = Theme.of(context);

    return FutureBuilder<List<({String album, String artist, int count})>>(
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
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.album_outlined, size: 48,
                    color: SpotlessColors.onSurfaceDim),
                const SizedBox(height: 12),
                Text('No albums yet.',
                    style: TextStyle(color: SpotlessColors.onSurfaceMedium)),
              ],
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.78,
          ),
          itemCount: albums.length,
          itemBuilder: (context, index) {
            final a = albums[index];
            return Material(
              color: SpotlessColors.surface,
              borderRadius: BorderRadius.circular(SpotlessColors.radiusMd),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: AlbumArt(
                        title: a.album,
                        subtitle: a.artist,
                        size: 200,
                        borderRadius: 0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
                      child: Text(
                        a.album,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                      child: Text(
                        '${a.artist} · ${a.count} songs',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: SpotlessColors.onSurfaceDim,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
