import 'package:flutter/material.dart';

import '../../core/db/app_database.dart';
import '../../core/models/song_status.dart';
import '../theme/spotless_colors.dart';
import 'album_art.dart';
import 'status_badge.dart';

/// One row in a song list: art, title/artist, optional status badge and
/// trailing actions. PixelPlayer-style larger album art with rounded corners.
class SongTile extends StatelessWidget {
  final SongRow song;
  final bool isCurrent;
  final VoidCallback? onTap;
  final List<Widget> trailing;
  final bool showStatus;

  const SongTile({
    super.key,
    required this.song,
    this.isCurrent = false,
    this.onTap,
    this.trailing = const [],
    this.showStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
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
              // Album art with optional "now playing" indicator
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(SpotlessColors.radiusSm),
                    child: AlbumArt(song: song, size: 48),
                  ),
                  if (isCurrent)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.graphic_eq,
                            size: 10, color: Colors.black),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // Title / artist
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight:
                            isCurrent ? FontWeight.w700 : FontWeight.w500,
                        color: isCurrent ? scheme.primary : null,
                      ),
                    ),
                    if (song.artist.isNotEmpty) ...[
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
                  ],
                ),
              ),

              // Status badge
              if (showStatus && song.status != SongStatus.downloaded.name)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: StatusBadge(status: song.status),
                ),

              // Trailing actions
              ...trailing,
            ],
          ),
        ),
      ),
    );
  }
}
