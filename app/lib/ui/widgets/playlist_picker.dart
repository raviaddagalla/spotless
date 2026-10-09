import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/db/app_database.dart';
import '../../core/services/music_repository.dart';

/// Bottom sheet listing playlists to add [song] into.
Future<void> showPlaylistPicker(BuildContext context, SongRow song) async {
  final repo = context.read<MusicRepository>();
  final playlists = await repo.playlists();
  if (!context.mounted) return;
  final selected = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: const Color(0xFF1E1E1E),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Add "${song.title}" to…',
              textAlign: TextAlign.center,
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final pl in playlists)
                  ListTile(
                    leading: const Icon(Icons.queue_music),
                    title: Text(pl.name),
                    onTap: () => Navigator.pop(ctx, pl.id),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  if (selected == null || !context.mounted) return;
  final name = playlists.firstWhere((p) => p.id == selected).name;
  await repo.addToPlaylist(selected, song);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added to "$name"')),
    );
  }
}
