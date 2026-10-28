import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/db/app_database.dart';
import '../../core/services/discovery_service.dart';
import '../../core/services/music_repository.dart';
import '../../core/state/player_controller.dart';
import '../theme/spotless_colors.dart';
import 'rating_widget.dart';

/// Bottom sheet displaying track-based radio and similar recommendations.
///
/// Per Specification §18 & §22:
/// - Takes a seed track from the user's library or playback session.
/// - Queries external recommendation providers (Last.fm, Qloo) and local acoustic features.
/// - Streams recommendations with ratings and 1-tap download promotion.
class SimilarTracksSheet extends StatefulWidget {
  final SongRow seedTrack;

  const SimilarTracksSheet({super.key, required this.seedTrack});

  static Future<void> show(BuildContext context, SongRow seedTrack) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: SpotlessColors.surfaceHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(SpotlessColors.radiusXl)),
      ),
      builder: (_) => SimilarTracksSheet(seedTrack: seedTrack),
    );
  }

  @override
  State<SimilarTracksSheet> createState() => _SimilarTracksSheetState();
}

class _SimilarTracksSheetState extends State<SimilarTracksSheet> {
  List<ScoredDiscoveryTrack>? _candidates;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSimilarTracks();
  }

  Future<void> _loadSimilarTracks() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final repo = context.read<MusicRepository>();
      final results = await repo.discoveryService.discoverSimilarTo(
        widget.seedTrack,
        limit: 15,
      );
      if (mounted) {
        setState(() {
          _candidates = results;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _playAll(PlayerController player) async {
    if (_candidates == null || _candidates!.isEmpty) return;
    final songRows = _candidates!.map((c) => c.toSongRow()).toList();
    await player.playQueue(songRows);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Playing Radio for "${widget.seedTrack.title}" (${songRows.length} tracks)'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _promote(ScoredDiscoveryTrack track) async {
    final repo = context.read<MusicRepository>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      await repo.discoveryService.promoteCandidate(track);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Added "${track.title}" to library! Downloading...'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      final songRow = track.toSongRow();
      await repo.downloadSong(songRow);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Downloaded "${track.title}" for offline listening!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _showRateDialog(ScoredDiscoveryTrack track) async {
    final messenger = ScaffoldMessenger.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        title: Text(
          'Rate "${track.title}"',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'by ${track.artist}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            RatingWidget(
              songId: track.id,
              onRated: (r) {
                Navigator.of(ctx).pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Rated "${track.title}" $r/10!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                if (r >= 8) {
                  _promote(track);
                }
              },
            ),
            const SizedBox(height: 12),
            const Text(
              '★ Rating 8+ will automatically promote and download this track to your library!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: SpotlessColors.primary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 16, 12),
              child: Row(
                children: [
                  const Icon(Icons.radio_rounded, color: SpotlessColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Track Radio',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${widget.seedTrack.title} • ${widget.seedTrack.artist}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_candidates != null && _candidates!.isNotEmpty)
                    FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 20),
                      label: const Text('Play All'),
                      onPressed: () => _playAll(player),
                    ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white12),

            // Content
            Expanded(
              child: _loading
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Generating Track Radio...', style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    )
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
                                const SizedBox(height: 12),
                                Text('Error: $_error', textAlign: TextAlign.center),
                                const SizedBox(height: 12),
                                FilledButton(
                                  onPressed: _loadSimilarTracks,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _candidates == null || _candidates!.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.music_off_rounded, size: 48, color: Colors.white38),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'No similar tracks found',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Try configuring Last.fm or Qloo keys in Settings, or add more acoustic metadata to your library.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: _candidates!.length,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemBuilder: (context, index) {
                                final track = _candidates![index];
                                final isCurrent = player.currentSong?.title.toLowerCase() ==
                                        track.title.toLowerCase() &&
                                    player.currentSong?.artist.toLowerCase() ==
                                        track.artist.toLowerCase();

                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  color: const Color(0xFF222222),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: isCurrent
                                        ? const BorderSide(color: SpotlessColors.primary, width: 1.5)
                                        : BorderSide.none,
                                  ),
                                  child: ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: track.albumArtUrl != null
                                          ? CachedNetworkImage(
                                              imageUrl: track.albumArtUrl!,
                                              width: 44,
                                              height: 44,
                                              fit: BoxFit.cover,
                                              errorWidget: (_, _, _) => Container(
                                                width: 44,
                                                height: 44,
                                                color: Colors.white12,
                                                child: const Icon(Icons.music_note, color: Colors.white38),
                                              ),
                                            )
                                          : Container(
                                              width: 44,
                                              height: 44,
                                              color: Colors.white12,
                                              child: const Icon(Icons.music_note, color: Colors.white38),
                                            ),
                                    ),
                                    title: Text(
                                      track.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isCurrent ? SpotlessColors.primary : Colors.white,
                                      ),
                                    ),
                                    subtitle: Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            track.artist,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: Colors.white10,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            track.provider,
                                            style: const TextStyle(fontSize: 10, color: Colors.white54),
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.star_outline_rounded, size: 20),
                                          tooltip: 'Rate track',
                                          onPressed: () => _showRateDialog(track),
                                        ),
                                        if (track.existingSong == null ||
                                            track.existingSong?.status != 'downloaded')
                                          IconButton(
                                            icon: const Icon(Icons.download_for_offline_outlined, size: 20),
                                            tooltip: 'Promote & Download',
                                            onPressed: () => _promote(track),
                                          ),
                                        IconButton(
                                          icon: Icon(
                                            isCurrent && player.playing
                                                ? Icons.pause_circle_filled_rounded
                                                : Icons.play_circle_fill_rounded,
                                            color: SpotlessColors.primary,
                                            size: 28,
                                          ),
                                          onPressed: () async {
                                            if (isCurrent) {
                                              await player.togglePlayPause();
                                            } else {
                                              await player.playQueue([track.toSongRow()]);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                    onTap: () async {
                                      await player.playQueue([track.toSongRow()]);
                                    },
                                  ),
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
