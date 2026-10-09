import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/db/app_database.dart';
import '../core/services/music_repository.dart';
import 'playlist_songs_page.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  late Future<List<(Playlist, int)>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<(Playlist, int)>> _load() async {
    final repo = context.read<MusicRepository>();
    final playlists = await repo.playlists();
    final result = <(Playlist, int)>[];
    for (final pl in playlists) {
      result.add((pl, (await repo.playlistSongs(pl.id)).length));
    }
    return result;
  }

  void _reload() {
    setState(() => _future = _load());
  }

  Future<void> _create() async {
    final repo = context.read<MusicRepository>();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final ctl = TextEditingController();
        return AlertDialog(
          title: const Text('New playlist'),
          content: TextField(
            controller: ctl,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'Playlist name'),
            onSubmitted: (v) => Navigator.pop(ctx, v),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, ctl.text),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
    if (name == null || name.trim().isEmpty) return;
    await repo.createPlaylist(name.trim());
    _reload();
  }

  Future<void> _rename(Playlist playlist) async {
    final repo = context.read<MusicRepository>();
    final ctl = TextEditingController(text: playlist.name);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename playlist'),
        content: TextField(
          controller: ctl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Playlist name'),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctl.text),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    await repo.renamePlaylist(playlist.id, name.trim());
    _reload();
  }

  Future<void> _delete(Playlist playlist) async {
    final repo = context.read<MusicRepository>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete playlist?'),
        content: Text('Delete "${playlist.name}"? Songs are not removed from '
            'your library.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await repo.deletePlaylist(playlist.id);
    _reload();
  }

  Future<void> _export(Playlist playlist) async {
    final repo = context.read<MusicRepository>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      final path = await repo.exportPlaylist(playlist.id);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(path, mimeType: 'audio/x-mpegurl')],
          subject: playlist.name,
          text: '${playlist.name} — exported from Spotless',
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New playlist',
            onPressed: _create,
          ),
        ],
      ),
      body: FutureBuilder<List<(Playlist, int)>>(
        future: _future,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final playlists = snap.data!;
          if (playlists.isEmpty) {
            return const Center(
              child: Text('No playlists yet — tap + to create one.'),
            );
          }
          return ListView.builder(
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final (pl, count) = playlists[index];
              return ListTile(
                leading: const Icon(Icons.queue_music),
                title: Text(pl.name),
                subtitle: Text(
                  '$count songs',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (v) {
                    if (v == 'rename') _rename(pl);
                    if (v == 'delete') _delete(pl);
                    if (v == 'export') _export(pl);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'export', child: Text('Export .m3u')),
                    PopupMenuItem(value: 'rename', child: Text('Rename')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PlaylistSongsPage(
                        playlistId: pl.id,
                        name: pl.name,
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
