import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../core/db/app_database.dart';
import '../../core/models/song_status.dart';
import '../../core/services/music_repository.dart';
import '../../core/state/player_controller.dart';
import 'playlist_picker.dart';
import 'song_tile.dart';

/// SongTile wrapped in flutter_slidable quick actions (F2):
/// swipe right for Download, swipe left for Play next / Like / Add to
/// playlist. The regular 3-dot [trailing] menu stays available.
class SlidableSongTile extends StatelessWidget {
  final SongRow song;
  final bool isCurrent;
  final bool showStatus;
  final VoidCallback? onTap;
  final List<Widget> trailing;

  const SlidableSongTile({
    super.key,
    required this.song,
    this.isCurrent = false,
    this.showStatus = false,
    this.onTap,
    this.trailing = const [],
  });

  @override
  Widget build(BuildContext context) {
    final repo = context.read<MusicRepository>();
    final player = context.read<PlayerController>();

    return Slidable(
      key: ValueKey('slidable-${song.id}'),
      startActionPane: song.status == SongStatus.downloaded.name
          ? null
          : ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.28,
              children: [
                SlidableAction(
                  backgroundColor: const Color(0xFF1DB954),
                  foregroundColor: Colors.black,
                  icon: Icons.download,
                  label: 'Download',
                  onPressed: (_) async {
                    try {
                      await player.downloadSong(song);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Download finished')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Download failed: $e')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.62,
        children: [
          SlidableAction(
            backgroundColor: const Color(0xFF5C6BC0),
            icon: Icons.playlist_add,
            label: 'Playlist',
            onPressed: (_) async {
              if (context.mounted) await showPlaylistPicker(context, song);
            },
          ),
          SlidableAction(
            backgroundColor: const Color(0xFF1DB954),
            foregroundColor: Colors.black,
            icon: song.likedAt != null ? Icons.favorite : Icons.favorite_border,
            label: song.likedAt != null ? 'Unlike' : 'Like',
            onPressed: (_) async {
              await repo.setLiked(song.id, song.likedAt == null);
            },
          ),
          SlidableAction(
            backgroundColor: const Color(0xFFEF5350),
            icon: Icons.playlist_play,
            label: 'Next',
            onPressed: (_) => player.addNext(song),
          ),
        ],
      ),
      child: SongTile(
        song: song,
        isCurrent: isCurrent,
        showStatus: showStatus,
        onTap: onTap,
        trailing: trailing,
      ),
    );
  }
}
