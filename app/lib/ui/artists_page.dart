import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/services/music_repository.dart';
import 'artist_detail_page.dart';
import 'theme/spotless_colors.dart';

/// Grid/list of artists with circular avatar and song count.
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
    final scheme = Theme.of(context).colorScheme;

    return FutureBuilder<List<({String name, int count})>>(
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
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_outline, size: 48,
                    color: SpotlessColors.onSurfaceDim),
                const SizedBox(height: 12),
                Text('No artists yet.',
                    style: TextStyle(color: SpotlessColors.onSurfaceMedium)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: artists.length,
          itemBuilder: (context, index) {
            final a = artists[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: SpotlessColors.surface,
                borderRadius: BorderRadius.circular(SpotlessColors.radiusMd),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: scheme.primary.withValues(alpha: 0.15),
                  child: Text(
                    a.name.isEmpty ? '?' : a.name[0].toUpperCase(),
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                title: Text(a.name, style: Theme.of(context).textTheme.titleSmall),
                subtitle: Text(
                  '${a.count} songs',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: SpotlessColors.onSurfaceDim,
                      ),
                ),
                trailing: Icon(Icons.chevron_right,
                    color: SpotlessColors.onSurfaceDim),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SpotlessColors.radiusMd),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ArtistDetailPage(artist: a.name),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
