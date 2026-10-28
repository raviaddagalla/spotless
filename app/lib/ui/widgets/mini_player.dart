import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/player_controller.dart';
import '../now_playing_page.dart';
import '../theme/dynamic_theme_provider.dart';
import '../theme/spotless_colors.dart';
import 'album_art.dart';

/// Frosted-glass pill mini-player inspired by PixelPlayer.
///
/// Sits above the NavigationBar, shows album art, title/artist,
/// play/pause and next buttons, with a thin progress bar at the bottom.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final song = player.currentSong;
    if (song == null) return const SizedBox.shrink();

    final dynamic_ = context.watch<DynamicThemeProvider>();
    final scheme = Theme.of(context).colorScheme;
    final progress = player.duration.inMilliseconds > 0
        ? (player.position.inMilliseconds / player.duration.inMilliseconds)
            .clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NowPlayingPage()),
      ),
      onHorizontalDragEnd: (d) {
        if (d.primaryVelocity == null) return;
        if (d.primaryVelocity! < -200) player.next();
        if (d.primaryVelocity! > 200) player.previous();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: SpotlessColors.glassSurface(dynamic_.dominant),
          borderRadius: BorderRadius.circular(SpotlessColors.radiusLg),
          boxShadow: [
            BoxShadow(
              color: dynamic_.dominant.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ---- Main content row ----
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 6, 6),
              child: Row(
                children: [
                  // Album art
                  Hero(
                    tag: 'album-art-${song.id}',
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(SpotlessColors.radiusMd),
                      child: AlbumArt(song: song, size: 44),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title / artist
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          song.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: SpotlessColors.onSurfaceMedium,
                              ),
                        ),
                      ],
                    ),
                  ),

                  // Play / Pause
                  _MiniButton(
                    icon: player.loading
                        ? Icons.hourglass_top_rounded
                        : player.playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                    onPressed:
                        player.loading ? null : player.togglePlayPause,
                    color: scheme.primary,
                  ),

                  // Next
                  _MiniButton(
                    icon: Icons.skip_next_rounded,
                    onPressed: () => player.next(),
                  ),
                ],
              ),
            ),

            // ---- Thin progress bar ----
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(SpotlessColors.radiusLg),
              ),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 2.5,
                backgroundColor: Colors.white.withValues(alpha: 0.06),
                valueColor: AlwaysStoppedAnimation(scheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;

  const _MiniButton({
    required this.icon,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 26),
      color: color ?? SpotlessColors.onSurface,
      onPressed: onPressed,
      splashRadius: 22,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    );
  }
}
