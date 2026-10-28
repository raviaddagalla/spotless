import 'package:flutter/material.dart';

import '../../core/db/app_database.dart';
import '../theme/spotless_colors.dart';
import 'album_art.dart';

/// Compact horizontal card: square art with title/artist below.
/// Used in horizontal carousels on the Home page.
class SongCard extends StatelessWidget {
  final SongRow song;
  final VoidCallback? onTap;

  const SongCard({super.key, required this.song, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 144,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SpotlessColors.radiusMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(SpotlessColors.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(SpotlessColors.radiusMd),
                  child: AlbumArt(song: song, size: 144),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  song.artist,
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
      ),
    );
  }
}
