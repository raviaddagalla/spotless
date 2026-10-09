import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/db/app_database.dart';
import '../core/models/song_status.dart';
import '../core/services/music_repository.dart';
import '../core/state/player_controller.dart';
import 'albums_page.dart';
import 'artists_page.dart';
import 'liked_songs_page.dart';
import 'now_playing_page.dart';
import 'playlists_page.dart';
import 'search_page.dart';
import 'widgets/playlist_picker.dart';
import 'widgets/rating_widget.dart';
import 'widgets/similar_tracks_sheet.dart';
import 'widgets/slidable_song_tile.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  String? _status;
  bool _offlineOnly = false;

  @override
  void initState() {
    super.initState();
    context.read<MusicRepository>().offlineOnly().then((v) {
      if (mounted) setState(() => _offlineOnly = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<MusicRepository>();
    final player = context.watch<PlayerController>();

    return StatusFilter(
      status: _status,
      setStatus: (s) => setState(() => _status = s),
      child: Column(
        children: [
          const _LibraryActions(),
          _StatusFilterBar(
            offlineOnly: _offlineOnly,
            onOfflineToggle: (v) async {
              setState(() => _offlineOnly = v);
              await repo.setOfflineOnly(v);
            },
          ),
          Expanded(
            child: StreamBuilder<List<SongRow>>(
              stream: repo.watchSongs(
                status: _status,
                offlineOnly: _offlineOnly,
              ),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final songs = snap.data!;
                if (songs.isEmpty) {
                  return Center(
                    child: Text(
                      _offlineOnly
                          ? 'Nothing downloaded yet — tap the download icon '
                              'on a song or search YouTube.'
                          : 'No songs — scan your library in Settings.',
                      textAlign: TextAlign.center,
                    ),
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
                        if (context.mounted) _openNowPlaying(context);
                      },
                      trailing: [_SongMenu(song: song)],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openNowPlaying(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NowPlayingPage()),
    );
  }
}

class _LibraryActions extends StatelessWidget {
  const _LibraryActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.queue_music,
                  label: 'Playlists',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PlaylistsPage()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  icon: Icons.favorite,
                  label: 'Liked Songs',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LikedSongsPage()),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.person_outline,
                  label: 'Artists',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ArtistsPage()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  icon: Icons.album_outlined,
                  label: 'Albums',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AlbumsPage()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E1E1E),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF1DB954)),
              const SizedBox(height: 6),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _SongMenu extends StatelessWidget {
  final SongRow song;

  const _SongMenu({required this.song});

  @override
  Widget build(BuildContext context) {
    final player = context.read<PlayerController>();
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) async {
        switch (value) {
          case 'play':
            await player.playQueue([song]);
          case 'next':
            await player.addNext(song);
          case 'download':
            await _download(context, player, song);
          case 'like':
            await context.read<MusicRepository>().setLiked(song.id, true);
          case 'unlike':
            await context.read<MusicRepository>().setLiked(song.id, false);
          case 'playlist':
            if (context.mounted) await showPlaylistPicker(context, song);
          case 'youtube':
            if (context.mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SearchPage(initialQuery: song.title),
                ),
              );
            }
          case 'similar':
            final repo = context.read<MusicRepository>();
            final similar = await repo.similarTo(song, 15);
            if (context.mounted) await player.playQueue(similar);
          case 'radio':
            if (context.mounted) await SimilarTracksSheet.show(context, song);
          case 'rate':
            if (context.mounted) await _rateSong(context, song);
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'play', child: Text('Play')),
        const PopupMenuItem(value: 'next', child: Text('Play next')),
        if (song.status != SongStatus.downloaded.name)
          const PopupMenuItem(value: 'download', child: Text('Download')),
        const PopupMenuItem(value: 'playlist', child: Text('Add to playlist')),
        const PopupMenuItem(value: 'radio', child: Text('Track Radio')),
        const PopupMenuItem(value: 'rate', child: Text('Rate track (1–10)')),
        if (song.likedAt != null)
          const PopupMenuItem(value: 'unlike', child: Text('Unlike'))
        else
          const PopupMenuItem(value: 'like', child: Text('Like')),
        const PopupMenuItem(value: 'youtube', child: Text('Find on YouTube')),
        const PopupMenuItem(value: 'similar', child: Text('Play similar')),
      ],
    );
  }

  Future<void> _rateSong(BuildContext context, SongRow song) async {
    final messenger = ScaffoldMessenger.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        title: Text(
          'Rate "${song.title}"',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'by ${song.artist}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            RatingWidget(
              songId: song.id,
              onRated: (r) {
                Navigator.of(ctx).pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Rated "${song.title}" $r/10!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              '1 = Dislike strongly, 10 = Masterpiece',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _download(
      BuildContext context, PlayerController player, SongRow song) async {
    if (!context.mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Download?'),
        content: Text('Download "${song.title}" for offline playback?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Download'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await player.downloadSong(song);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download finished')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    }
  }
}

class _StatusFilterBar extends StatelessWidget {
  final bool offlineOnly;
  final ValueChanged<bool> onOfflineToggle;

  const _StatusFilterBar({
    required this.offlineOnly,
    required this.onOfflineToggle,
  });

  @override
  Widget build(BuildContext context) {
    final selected = StatusFilter.of(context)?.status;
    final chips = <(String?, String)>[
      (null, 'All'),
      (SongStatus.downloaded.name, 'Downloaded'),
      (SongStatus.streamable.name, 'Streamable'),
      (SongStatus.missing.name, 'Missing'),
      (SongStatus.failed.name, 'Failed'),
    ];
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          for (final (value, label) in chips)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(label),
                selected: selected == value,
                onSelected: (_) => StatusFilter.of(context)?.setStatus(value),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              avatar: Icon(
                offlineOnly ? Icons.cloud_off : Icons.cloud_outlined,
                size: 18,
              ),
              label: const Text('Offline'),
              selected: offlineOnly,
              tooltip: 'Show only downloaded songs',
              onSelected: onOfflineToggle,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tiny inherited widget so chips and the list share the selected status
/// without extra state plumbing.
class StatusFilter extends InheritedWidget {
  final String? status;
  final ValueChanged<String?> setStatus;

  const StatusFilter({
    super.key,
    required this.status,
    required this.setStatus,
    required super.child,
  });

  static StatusFilter? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<StatusFilter>();

  @override
  bool updateShouldNotify(StatusFilter oldWidget) => oldWidget.status != status;
}
