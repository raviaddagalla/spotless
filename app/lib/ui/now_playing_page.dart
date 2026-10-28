import 'package:flutter/material.dart' hide RepeatMode;
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../core/audio/audio_engine.dart';
import '../core/db/app_database.dart';
import '../core/services/music_repository.dart';
import '../core/state/player_controller.dart';
import 'lyrics_page.dart';
import 'theme/dynamic_theme_provider.dart';
import 'theme/spotless_colors.dart';
import 'widgets/album_art.dart';
import 'widgets/rating_widget.dart';
import 'widgets/rounded_control_button.dart';
import 'widgets/similar_tracks_sheet.dart';
import 'widgets/status_badge.dart';
import 'widgets/wavy_slider.dart';

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({super.key});

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final song = player.currentSong;
    final dynamic_ = context.watch<DynamicThemeProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: SpotlessColors.background,
      body: song == null
          ? const Center(child: Text('Nothing playing'))
          : Container(
              decoration: BoxDecoration(
                gradient: SpotlessColors.immersiveGradient(dynamic_.dominant),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // ---- Top bar ----
                    _TopBar(song: song),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),

                            // ---- Album Art ----
                            Hero(
                              tag: 'album-art-${song.id}',
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      SpotlessColors.radiusLg),
                                  boxShadow: [
                                    BoxShadow(
                                      color: dynamic_.dominant
                                          .withValues(alpha: 0.4),
                                      blurRadius: 40,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      SpotlessColors.radiusLg),
                                  child: AlbumArt(
                                    song: song,
                                    size:
                                        MediaQuery.of(context).size.width - 80,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // ---- Song title / artist ----
                            Text(
                              song.title,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              song.artist,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: SpotlessColors.onSurfaceMedium,
                                  ),
                            ),

                            // ---- Status badges ----
                            if (song.status == 'streamable' ||
                                song.status == 'failed' ||
                                song.status == 'missing')
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: StatusBadge(status: song.status),
                              ),

                            // ---- Error message ----
                            if (player.error != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  player.error!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: SpotlessColors.error),
                                ),
                              ),

                            const SizedBox(height: 24),

                            // ---- Rating ----
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(
                                    SpotlessColors.radiusLg),
                              ),
                              child: RatingWidget(songId: song.id),
                            ),

                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),

                    // ---- Download progress ----
                    if (player.downloading)
                      _DownloadProgress(player: player),

                    // ---- Wavy seek bar ----
                    if (player.loading)
                      const _LoadingBanner()
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          children: [
                            WavySlider(
                              position: player.position,
                              duration: player.duration,
                              isPlaying: player.playing,
                              onSeek: (d) => player.seek(d),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _fmt(player.position),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: SpotlessColors.onSurfaceDim,
                                        ),
                                  ),
                                  Text(
                                    _fmt(player.duration),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: SpotlessColors.onSurfaceDim,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 12),

                    // ---- Playback controls (pill buttons) ----
                    _Controls(),

                    const SizedBox(height: 12),

                    // ---- Bottom toggle row ----
                    _BottomToggleRow(),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

// ====================================================================
// Top bar
// ====================================================================

class _TopBar extends StatelessWidget {
  final SongRow song;

  const _TopBar({required this.song});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 30),
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Text(
              'Now Playing',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: SpotlessColors.onSurfaceMedium,
                  ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.lyrics_outlined, size: 22),
            tooltip: 'Lyrics',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LyricsPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.queue_music_rounded, size: 22),
            tooltip: 'Queue',
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const QueueSheet(),
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// Playback controls — PixelPlayer pill buttons
// ====================================================================

class _Controls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RoundedControlButton(
            icon: Icons.skip_previous_rounded,
            size: 60,
            onPressed: () => player.previous(),
          ),
          const SizedBox(width: 20),
          RoundedControlButton.playPause(
            icon: player.loading
                ? Icons.hourglass_top_rounded
                : player.playing
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
            onPressed: player.loading ? null : player.togglePlayPause,
          ),
          const SizedBox(width: 20),
          RoundedControlButton(
            icon: Icons.skip_next_rounded,
            size: 60,
            onPressed: () => player.next(),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// Bottom toggle row (shuffle, repeat, like, sleep, radio)
// ====================================================================

class _BottomToggleRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final song = player.currentSong;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(SpotlessColors.radiusFull),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Shuffle
          _ToggleIcon(
            icon: player.shuffleMode == ShuffleMode.smart
                ? Icons.auto_awesome_rounded
                : Icons.shuffle_rounded,
            active: player.shuffleMode != ShuffleMode.off,
            onPressed: () => player.cycleShuffleMode(),
            tooltip: switch (player.shuffleMode) {
              ShuffleMode.off => 'Shuffle: Off',
              ShuffleMode.normal => 'Shuffle: Normal',
              ShuffleMode.smart => 'Smart Shuffle',
            },
          ),

          // Repeat
          _ToggleIcon(
            icon: player.repeat == RepeatMode.one
                ? Icons.repeat_one_rounded
                : Icons.repeat_rounded,
            active: player.repeat != RepeatMode.off,
            onPressed: () {
              final next = switch (player.repeat) {
                RepeatMode.off => RepeatMode.all,
                RepeatMode.all => RepeatMode.one,
                RepeatMode.one => RepeatMode.off,
              };
              player.setRepeat(next);
            },
            tooltip: 'Repeat',
          ),

          // Like
          if (song != null) _LikeToggle(song: song),

          // Sleep timer
          const _SleepTimerButton(),

          // Track radio
          if (song != null)
            _ToggleIcon(
              icon: Icons.sensors_rounded,
              active: false,
              onPressed: () => SimilarTracksSheet.show(context, song),
              tooltip: 'Track Radio',
            ),
        ],
      ),
    );
  }
}

class _ToggleIcon extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onPressed;
  final String tooltip;

  const _ToggleIcon({
    required this.icon,
    required this.active,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      icon: Icon(icon, size: 22),
      color: active ? scheme.primary : SpotlessColors.onSurfaceDim,
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}

class _LikeToggle extends StatefulWidget {
  final SongRow song;

  const _LikeToggle({required this.song});

  @override
  State<_LikeToggle> createState() => _LikeToggleState();
}

class _LikeToggleState extends State<_LikeToggle> {
  bool? _liked;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final liked = await context.read<MusicRepository>().isLiked(widget.song.id);
    if (mounted) setState(() => _liked = liked);
  }

  @override
  Widget build(BuildContext context) {
    final liked = _liked ?? widget.song.likedAt != null;
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      icon: Icon(
        liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        size: 22,
      ),
      color: liked ? scheme.primary : SpotlessColors.onSurfaceDim,
      tooltip: liked ? 'Unlike' : 'Like',
      onPressed: () async {
        final next = !liked;
        setState(() => _liked = next);
        await context.read<MusicRepository>().setLiked(widget.song.id, next);
      },
    );
  }
}

// ====================================================================
// Sleep Timer Button
// ====================================================================

class _SleepTimerButton extends StatelessWidget {
  const _SleepTimerButton();

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final active = player.sleepTimerActive;
    final remaining = player.sleepRemaining;
    final scheme = Theme.of(context).colorScheme;

    return IconButton(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.bedtime_outlined,
            size: 22,
            color: active ? scheme.primary : SpotlessColors.onSurfaceDim,
          ),
          if (remaining != null && remaining > Duration.zero)
            Positioned(
              right: -8,
              top: -6,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _fmt(remaining),
                  style: TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                    color: scheme.onPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
      tooltip: active ? 'Sleep timer on' : 'Sleep timer',
      onPressed: () => _showTimerSheet(context, player),
    );
  }

  void _showTimerSheet(BuildContext context, PlayerController player) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Sleep timer',
                style: Theme.of(ctx)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            for (final (label, duration) in [
              ('5 minutes', const Duration(minutes: 5)),
              ('10 minutes', const Duration(minutes: 10)),
              ('15 minutes', const Duration(minutes: 15)),
              ('30 minutes', const Duration(minutes: 30)),
              ('1 hour', const Duration(hours: 1)),
            ])
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: Text(label),
                onTap: () {
                  player.startSleepTimer(duration);
                  Navigator.pop(ctx);
                },
              ),
            ListTile(
              leading: const Icon(Icons.music_note_outlined),
              title: const Text('End of current song'),
              onTap: () {
                player.startSleepAfterCurrent();
                Navigator.pop(ctx);
              },
            ),
            if (player.sleepTimerActive)
              ListTile(
                leading: const Icon(Icons.stop_circle_outlined),
                title: const Text('Turn off timer'),
                textColor: SpotlessColors.error,
                onTap: () {
                  player.cancelSleepTimer();
                  Navigator.pop(ctx);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ====================================================================
// Loading / Download progress
// ====================================================================

class _LoadingBanner extends StatelessWidget {
  const _LoadingBanner();

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final label = switch (player.processingState) {
      ProcessingState.buffering => 'Buffering…',
      ProcessingState.loading => 'Loading…',
      _ => player.isStreaming ? 'Resolving from YouTube…' : 'Loading…',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SpotlessColors.onSurfaceDim,
                  )),
        ],
      ),
    );
  }
}

class _DownloadProgress extends StatelessWidget {
  final PlayerController player;

  const _DownloadProgress({required this.player});

  @override
  Widget build(BuildContext context) {
    final pct = (player.downloadProgress * 100).clamp(0, 100).round();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
      child: Column(
        children: [
          LinearProgressIndicator(value: player.downloadProgress),
          const SizedBox(height: 6),
          Text(
            'Downloading… $pct%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SpotlessColors.onSurfaceDim,
                ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// Queue Sheet
// ====================================================================

class QueueSheet extends StatelessWidget {
  const QueueSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final queue = player.queue;
    final scheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, _) {
        return Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'Queue',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 12),
                  if (player.shuffleMode == ShuffleMode.smart)
                    _ShuffleBadge(
                      label: 'Smart Shuffle',
                      icon: Icons.auto_awesome,
                      color: scheme.primary,
                    )
                  else if (player.shuffleMode == ShuffleMode.normal)
                    _ShuffleBadge(
                      label: 'Shuffle',
                      icon: Icons.shuffle,
                      color: SpotlessColors.onSurfaceMedium,
                    ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ReorderableListView.builder(
                buildDefaultDragHandles: false,
                onReorderItem: (oldIndex, newIndex) async {
                  await player.moveQueueItem(oldIndex, newIndex);
                },
                itemCount: queue.length,
                itemBuilder: (context, index) {
                  final song = queue[index];
                  final current = index == player.currentIndex;
                  return ListTile(
                    key: ValueKey('q-${song.id}-$index'),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ReorderableDragStartListener(
                          index: index,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.drag_handle,
                              size: 20,
                              color: SpotlessColors.onSurfaceDim,
                            ),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                              SpotlessColors.radiusSm),
                          child: AlbumArt(song: song, size: 40),
                        ),
                      ],
                    ),
                    title: Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight:
                            current ? FontWeight.w700 : FontWeight.w500,
                        color: current ? scheme.primary : null,
                      ),
                    ),
                    subtitle: Text(
                      song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => player.removeAt(index),
                    ),
                    onTap: () => player.jumpTo(index),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ShuffleBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _ShuffleBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(SpotlessColors.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
