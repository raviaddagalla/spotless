import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/db/app_database.dart';
import '../core/models/song_status.dart';
import '../core/services/music_repository.dart';
import '../core/state/player_controller.dart';
import 'albums_page.dart';
import 'artists_page.dart';
import 'now_playing_page.dart';
import 'playlists_page.dart';
import 'search_page.dart';
import 'settings_page.dart';
import 'theme/spotless_colors.dart';
import 'widgets/album_art.dart';
import 'widgets/gradient_top_bar.dart';
import 'widgets/playlist_picker.dart';
import 'widgets/rating_widget.dart';
import 'widgets/similar_tracks_sheet.dart';

/// PixelPlayer-inspired Library screen with a horizontal tab bar
/// (Songs / Albums / Artists / Playlists) and a Shuffle FAB.
class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  bool _offlineOnly = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
    context.read<MusicRepository>().offlineOnly().then((v) {
      if (mounted) setState(() => _offlineOnly = v);
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<MusicRepository>();
    final player = context.watch<PlayerController>();

    return Scaffold(
      // No AppBar — we use gradient top bar + TabBar.
      body: Column(
        children: [
          // ---- Gradient header with title + settings ----
          GradientTopBar(
            title: 'Library',
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, size: 22),
                tooltip: 'Settings',
                onPressed: () =>
                    Navigator.of(context).pushNamed(SettingsPage.route),
              ),
            ],
          ),

          // ---- Tab bar ----
          Container(
            color: SpotlessColors.background,
            child: TabBar(
              controller: _tab,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              tabs: const [
                Tab(text: 'SONGS'),
                Tab(text: 'ALBUMS'),
                Tab(text: 'ARTISTS'),
                Tab(text: 'PLAYLISTS'),
              ],
            ),
          ),

          // ---- Filter / sort row ----
          _FilterRow(
            offlineOnly: _offlineOnly,
            onOfflineToggle: (v) async {
              setState(() => _offlineOnly = v);
              await repo.setOfflineOnly(v);
            },
          ),

          // ---- Tab content ----
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _SongsTab(offlineOnly: _offlineOnly),
                const AlbumsPage(),
                const ArtistsPage(),
                const PlaylistsPage(),
              ],
            ),
          ),
        ],
      ),

      // ---- Shuffle FAB ----
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'lib-shuffle',
        onPressed: () async {
          final songs = await repo
              .watchSongs(offlineOnly: _offlineOnly)
              .first;
          if (songs.isNotEmpty && context.mounted) {
            final shuffled = List<SongRow>.from(songs)..shuffle();
            await player.playQueue(shuffled);
            if (context.mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NowPlayingPage()),
              );
            }
          }
        },
        icon: const Icon(Icons.shuffle_rounded),
        label: const Text('Shuffle'),
      ),
    );
  }
}

// ====================================================================
// Songs Tab
// ====================================================================

class _SongsTab extends StatelessWidget {
  final bool offlineOnly;

  const _SongsTab({required this.offlineOnly});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<MusicRepository>();
    final player = context.watch<PlayerController>();

    return StreamBuilder<List<SongRow>>(
      stream: repo.watchSongs(offlineOnly: offlineOnly),
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
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.library_music_outlined,
                    size: 56,
                    color: SpotlessColors.onSurfaceDim,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    offlineOnly
                        ? 'Nothing downloaded yet — tap the download icon '
                            'on a song or search YouTube.'
                        : 'No songs — scan your library in Settings.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: SpotlessColors.onSurfaceMedium),
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];
            return _LibrarySongTile(
              song: song,
              isCurrent: player.currentSong?.id == song.id,
              onTap: () async {
                await player.playQueue(songs, startIndex: index);
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
    );
  }
}

// ====================================================================
// Library Song Tile (PixelPlayer style — larger art, darker card bg)
// ====================================================================

class _LibrarySongTile extends StatelessWidget {
  final SongRow song;
  final bool isCurrent;
  final VoidCallback onTap;

  const _LibrarySongTile({
    required this.song,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: isCurrent
            ? scheme.primary.withValues(alpha: 0.08)
            : SpotlessColors.surface,
        borderRadius: BorderRadius.circular(SpotlessColors.radiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SpotlessColors.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(SpotlessColors.radiusMd),
                child: AlbumArt(song: song, size: 52),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: isCurrent ? scheme.primary : null,
                        fontWeight:
                            isCurrent ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: SpotlessColors.onSurfaceMedium,
                      ),
                    ),
                  ],
                ),
              ),
              _SongMenu(song: song),
            ],
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// Filter row
// ====================================================================

class _FilterRow extends StatelessWidget {
  final bool offlineOnly;
  final ValueChanged<bool> onOfflineToggle;

  const _FilterRow({
    required this.offlineOnly,
    required this.onOfflineToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          FilterChip(
            avatar: Icon(
              offlineOnly ? Icons.cloud_off : Icons.cloud_outlined,
              size: 16,
            ),
            label: const Text('Offline'),
            selected: offlineOnly,
            tooltip: 'Show only downloaded songs',
            onSelected: onOfflineToggle,
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// Song overflow menu (same actions as before, restyled)
// ====================================================================

class _SongMenu extends StatelessWidget {
  final SongRow song;

  const _SongMenu({required this.song});

  @override
  Widget build(BuildContext context) {
    final player = context.read<PlayerController>();
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: SpotlessColors.onSurfaceDim),
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
