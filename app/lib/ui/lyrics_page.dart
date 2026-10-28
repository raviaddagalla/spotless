import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/state/player_controller.dart';
import 'theme/dynamic_theme_provider.dart';
import 'theme/spotless_colors.dart';
import 'widgets/synced_lyrics_view.dart';
import 'widgets/wavy_slider.dart';

/// Full-screen immersive Lyrics page, inspired by PixelPlayer screenshot 4.
///
/// Features:
/// - Dynamic gradient background from album art
/// - Synced/Static toggle pills
/// - Large bold text with active-line highlighting
/// - Floating play/pause FAB
/// - Bottom wavy seek bar with time labels
class LyricsPage extends StatefulWidget {
  const LyricsPage({super.key});

  @override
  State<LyricsPage> createState() => _LyricsPageState();
}

class _LyricsPageState extends State<LyricsPage> {
  bool _showSynced = true;

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final dynamic_ = context.watch<DynamicThemeProvider>();
    final lyrics = player.currentLyrics;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: SpotlessColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: SpotlessColors.immersiveGradient(dynamic_.dominant),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ---- Top bar ----
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_rounded, size: 20),
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      child: Text(
                        'Lyrics',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(width: 48), // balance the back button
                  ],
                ),
              ),

              // ---- Synced / Static toggle ----
              if (lyrics != null && lyrics.synced)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 48, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: _TogglePill(
                          label: 'Synced',
                          selected: _showSynced,
                          onTap: () => setState(() => _showSynced = true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _TogglePill(
                          label: 'Static',
                          selected: !_showSynced,
                          onTap: () => setState(() => _showSynced = false),
                        ),
                      ),
                    ],
                  ),
                ),

              // ---- Lyrics content ----
              Expanded(
                child: lyrics == null || lyrics.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lyrics_outlined,
                              size: 48,
                              color: SpotlessColors.onSurfaceDim,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No lyrics for this song',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: SpotlessColors.onSurfaceMedium,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : SyncedLyricsView(
                        lyrics: lyrics,
                        showSynced: _showSynced,
                      ),
              ),

              // ---- Floating play/pause ----
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.8),
                  borderRadius:
                      BorderRadius.circular(SpotlessColors.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    player.playing
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 32,
                    color: scheme.onPrimaryContainer,
                  ),
                  onPressed: player.togglePlayPause,
                ),
              ),

              // ---- Bottom seek bar ----
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 4),
                child: Column(
                  children: [
                    WavySlider(
                      position: player.position,
                      duration: player.duration,
                      isPlaying: player.playing,
                      onSeek: (d) => player.seek(d),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              const SizedBox(height: 8),
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

class _TogglePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TogglePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primaryContainer.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(SpotlessColors.radiusFull),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected
                    ? scheme.onPrimaryContainer
                    : SpotlessColors.onSurfaceMedium,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
        ),
      ),
    );
  }
}
