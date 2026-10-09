import 'package:flutter/material.dart';

import '../../core/db/app_database.dart';
import '../../core/models/song_status.dart';
import 'album_art.dart';
import 'status_badge.dart';

/// One row in a song list: art, title/artist, optional status badge and
/// trailing actions.
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
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          AlbumArt(song: song, size: 48),
          if (isCurrent)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Color(0xFF1DB954),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.graphic_eq, size: 10, color: Colors.black),
              ),
            ),
        ],
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
          color: isCurrent ? const Color(0xFF1DB954) : null,
        ),
      ),
      subtitle: song.artist.isEmpty
          ? null
          : Text(
              song.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showStatus && song.status != SongStatus.downloaded.name)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: StatusBadge(status: song.status),
            ),
          ...trailing,
        ],
      ),
    );
  }
}
