

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/db/app_database.dart';
import '../core/services/music_repository.dart';
import '../core/state/player_controller.dart';
import 'debug_page.dart';
import 'discovery_page.dart';
import 'playlist_songs_page.dart';
import 'settings_page.dart';
import 'widgets/album_art.dart';
import 'widgets/gradient_top_bar.dart';
import 'widgets/section_header.dart';
import 'widgets/song_card.dart';
import 'theme/spotless_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<SongRow>> _recent;
  late Future<List<SongRow>> _forYou;
  late Future<List<(Playlist, int)>> _playlists;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final repo = context.read<MusicRepository>();
    _recent = repo.recent();
    _forYou = repo.forYou(15);
    _playlists = _loadPlaylists(repo);
  }

  Future<List<(Playlist, int)>> _loadPlaylists(MusicRepository repo) async {
    final list = await repo.playlists();
    final res = <(Playlist, int)>[];
    for (final pl in list) {
      final count = (await repo.playlistSongs(pl.id)).length;
      res.add((pl, count));
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(_reload);
      },
      child: CustomScrollView(
        slivers: [
          // ---- Gradient header with actions ----
          SliverToBoxAdapter(
            child: GradientTopBar(
              actions: [
                IconButton(
                  icon: const Icon(Icons.bug_report_outlined, size: 22),
                  tooltip: 'Diagnostics',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DebugPage()),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, size: 22),
                  tooltip: 'Settings',
                  onPressed: () =>
                      Navigator.of(context).pushNamed(SettingsPage.route),
                ),
              ],
            ),
          ),

          // ---- "Your Mix" Hero Section ----
          SliverToBoxAdapter(
            child: FutureBuilder<List<SongRow>>(
              future: _forYou,
              builder: (context, snap) {
                final songs = snap.data ?? const [];
                return _YourMixHero(
                  songs: songs,
                  onPlay: () {
                    if (songs.isNotEmpty) {
                      final player = context.read<PlayerController>();
                      player.playQueue(songs).then((_) {
                        if (context.mounted) {
                          Navigator.of(context).pushNamed('now_playing');
                        }
                      });
                    }
                  },
                  onDiscover: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DiscoveryPage()),
                  ),
                );
              },
            ),
          ),

          // ---- Recently played ----
          SliverToBoxAdapter(
            child: FutureBuilder<List<SongRow>>(
              future: _recent,
              builder: (context, snap) {
                final songs = snap.data ?? const [];
                if (songs.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Recently played'),
                      _SongCardRow(
                        songs: songs,
                        loadAll: () =>
                            context.read<MusicRepository>().recent(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ---- Playlists ----
          SliverToBoxAdapter(
            child: FutureBuilder<List<(Playlist, int)>>(
              future: _playlists,
              builder: (context, snap) {
                final playlists = snap.data ?? const [];
                if (playlists.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Playlists'),
                      SizedBox(
                        height: 88,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: playlists.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final (pl, count) = playlists[index];
                            return _PlaylistChip(
                              playlist: pl,
                              count: count,
                              index: index,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ---- For You ----
          SliverToBoxAdapter(
            child: FutureBuilder<List<SongRow>>(
              future: _forYou,
              builder: (context, snap) {
                final songs = snap.data ?? const [];
                if (songs.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: 'For you',
                        actionLabel: 'Discover',
                        onAction: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const DiscoveryPage()),
                        ),
                      ),
                      _SongCardRow(
                        songs: songs,
                        loadAll: () =>
                            context.read<MusicRepository>().forYou(15),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom padding so content doesn't hide behind mini player
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// "Your Mix" Hero Section — PixelPlayer-inspired
// ====================================================================

class _YourMixHero extends StatelessWidget {
  final List<SongRow> songs;
  final VoidCallback onPlay;
  final VoidCallback onDiscover;

  const _YourMixHero({
    required this.songs,
    required this.onPlay,
    required this.onDiscover,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Large bold headline
          Text(
            'Your\nMix',
            style: theme.textTheme.displayLarge,
          ),
          const SizedBox(height: 4),
          Text(
            "Today's mix for you",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: SpotlessColors.onSurfaceMedium,
            ),
          ),
          const SizedBox(height: 20),

          // Album art collage + play button row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Collage
              if (songs.length >= 3)
                Expanded(child: _ArtCollage(songs: songs))
              else
                const Expanded(child: SizedBox(height: 160)),

              const SizedBox(width: 16),

              // Play FAB
              _PlayFab(onTap: onPlay, color: scheme.primary),
            ],
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// Overlapping rounded album art collage, inspired by PixelPlayer Home.
class _ArtCollage extends StatelessWidget {
  final List<SongRow> songs;

  const _ArtCollage({required this.songs});

  @override
  Widget build(BuildContext context) {
    // Show up to 3 overlapping album art images.
    final arts = songs.take(3).toList();
    return SizedBox(
      height: 160,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (arts.isNotEmpty)
            Positioned(
              left: 0,
              top: 20,
              child: _RoundedArt(song: arts[0], size: 80),
            ),
          if (arts.length > 1)
            Positioned(
              left: 60,
              top: 0,
              child: _RoundedArt(song: arts[1], size: 120),
            ),
          if (arts.length > 2)
            Positioned(
              left: 150,
              top: 50,
              child: _RoundedArt(song: arts[2], size: 72),
            ),
        ],
      ),
    );
  }
}

class _RoundedArt extends StatelessWidget {
  final SongRow song;
  final double size;

  const _RoundedArt({required this.song, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.3),
        child: AlbumArt(song: song, size: size),
      ),
    );
  }
}

class _PlayFab extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;

  const _PlayFab({required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.22),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Icon(
          Icons.play_arrow_rounded,
          size: 38,
          color: color,
        ),
      ),
    );
  }
}

// ====================================================================
// Playlist Chip (rounded card)
// ====================================================================

class _PlaylistChip extends StatelessWidget {
  final Playlist playlist;
  final int count;
  final int index;

  const _PlaylistChip({
    required this.playlist,
    required this.count,
    required this.index,
  });

  static const _colors = [
    Color(0xFF5C6BC0),
    Color(0xFFEF5350),
    Color(0xFF26A69A),
    Color(0xFFFFA726),
    Color(0xFFAB47BC),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[index % _colors.length];
    final theme = Theme.of(context);

    return SizedBox(
      width: 180,
      child: Material(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(SpotlessColors.radiusLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(SpotlessColors.radiusLg),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PlaylistSongsPage(
                playlistId: playlist.id,
                name: playlist.name,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(Icons.queue_music_rounded, color: color, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        playlist.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        '$count songs',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: SpotlessColors.onSurfaceDim,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// Song Card Row (horizontal scroll)
// ====================================================================

/// Horizontal scrollable row of [SongCard]s. Tapping a card plays the
/// whole section starting at that song.
class _SongCardRow extends StatelessWidget {
  final List<SongRow> songs;
  final Future<List<SongRow>> Function() loadAll;

  const _SongCardRow({required this.songs, required this.loadAll});

  void _play(BuildContext context, SongRow song) {
    final player = context.read<PlayerController>();
    loadAll().then((all) async {
      final idx = all.indexWhere((x) => x.id == song.id);
      await player.playQueue(all, startIndex: idx < 0 ? 0 : idx);
      if (context.mounted) {
        Navigator.of(context).pushNamed('now_playing');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 192,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: songs.take(10).length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final song = songs[index];
          return SongCard(song: song, onTap: () => _play(context, song));
        },
      ),
    );
  }
}
