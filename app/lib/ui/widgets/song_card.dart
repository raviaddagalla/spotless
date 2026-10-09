import 'package:flutter/material.dart';

import '../../core/db/app_database.dart';
import 'album_art.dart';

/// Compact horizontal card (Spotify-style): square art with title/artist
/// below. Used by horizontal sections on the Home page.
class SongCard extends StatelessWidget {
  final SongRow song;
  final VoidCallback? onTap;

  const SongCard({super.key, required this.song, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AlbumArt(song: song, size: 132),
            const SizedBox(height: 6),
            Text(
              song.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            Text(
              song.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }
}
