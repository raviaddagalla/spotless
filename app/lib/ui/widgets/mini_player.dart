import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/player_controller.dart';
import '../now_playing_page.dart';
import 'album_art.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final song = player.currentSong;
    if (song == null || player.queueEnded) return const SizedBox.shrink();

    return Material(
      color: const Color(0xFF1E1E1E),
      child: GestureDetector(
        // F11: swipe left/right to skip next/previous.
        behavior: HitTestBehavior.opaque,
        onHorizontalDragEnd: (details) {
          final v = details.primaryVelocity ?? 0;
          if (v < -300) {
            player.next();
          } else if (v > 300) {
            player.previous();
          }
        },
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NowPlayingPage()),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 2,
                child: LinearProgressIndicator(
                  value: player.duration.inMilliseconds > 0
                      ? player.position.inMilliseconds /
                          player.duration.inMilliseconds
                      : 0,
                  color: const Color(0xFF1DB954),
                  backgroundColor: Colors.transparent,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    AlbumArt(song: song, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        player.playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 32,
                      ),
                      onPressed:
                          player.loading ? null : player.togglePlayPause,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
