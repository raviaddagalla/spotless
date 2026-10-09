import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/state/player_controller.dart';
import 'widgets/synced_lyrics_view.dart';

class LyricsPage extends StatelessWidget {
  const LyricsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final song = player.currentSong;
    final lyrics = player.currentLyrics;

    return Scaffold(
      appBar: AppBar(
        title: Text(song?.title ?? 'Lyrics'),
      ),
      body: lyrics == null
          ? const Center(child: Text('No lyrics for this song'))
          : lyrics.isEmpty
              ? const Center(child: Text('No lyrics for this song'))
              : SyncedLyricsView(lyrics: lyrics),
    );
  }
}
