import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/services/discovery_service.dart';
import '../core/services/music_repository.dart';
import '../core/state/player_controller.dart';
import 'now_playing_page.dart';
import 'widgets/rating_widget.dart';

/// Stream-first Discovery screen.
///
/// Per Specification §18-§24:
/// - Recommendations are initially streamed, NOT automatically downloaded.
/// - Shows candidates recommended from long-term taste + current session seeds.
/// - Allows explicit 1-10 rating on discovery candidates.
/// - Candidates with strong positive feedback can be promoted to permanent downloads.
class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({super.key});

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  List<ScoredDiscoveryTrack>? _candidates;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final repo = context.read<MusicRepository>();
    try {
      final tracks = await repo.discoveryService.discoverPersonalized(limit: 20);
      if (mounted) {
        setState(() {
          _candidates = tracks;
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
          content: Text('Downloaded "${track.title}"!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Promotion/download failed: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Music'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh recommendations',
            onPressed: _loading ? null : _loadRecommendations,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Finding fresh recommendations...',
                      style: TextStyle(color: Colors.white70)),
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
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.redAccent),
                        const SizedBox(height: 16),
                        Text('Discovery error: $_error',
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _loadRecommendations,
                          child: const Text('Try Again'),
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
                            const Icon(Icons.travel_explore_rounded,
                                size: 56, color: Color(0xFF1DB954)),
                            const SizedBox(height: 16),
                            const Text(
                              'No recommendations yet',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Listen to a few songs in your library or configure Last.fm / Qloo in Settings to kickstart discovery.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white60),
                            ),
                            const SizedBox(height: 20),
                            FilledButton.icon(
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Check for Recommendations'),
                              onPressed: _loadRecommendations,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      itemCount: _candidates!.length,
                      itemBuilder: (context, index) {
                        final track = _candidates![index];
                        final isPlayingThis =
                            player.currentSong?.title.toLowerCase() ==
                                    track.title.toLowerCase() &&
                                player.currentSong?.artist.toLowerCase() ==
                                    track.artist.toLowerCase();

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          color: const Color(0xFF1E1E1E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: isPlayingThis
                                ? const BorderSide(
                                    color: Color(0xFF1DB954), width: 1.5)
                                : BorderSide.none,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: track.albumArtUrl != null
                                          ? CachedNetworkImage(
                                              imageUrl: track.albumArtUrl!,
                                              width: 52,
                                              height: 52,
                                              fit: BoxFit.cover,
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(
                                                width: 52,
                                                height: 52,
                                                color: Colors.white10,
                                                child: const Icon(
                                                    Icons.music_note,
                                                    color: Colors.white38),
                                              ),
                                            )
                                          : Container(
                                              width: 52,
                                              height: 52,
                                              color: Colors.white10,
                                              child: const Icon(
                                                  Icons.music_note,
                                                  color: Colors.white38),
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            track.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                              color: isPlayingThis
                                                  ? const Color(0xFF1DB954)
                                                  : Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            track.artist,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white60,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.white12,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  track.provider,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white70,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Match: ${(track.score * 100).toInt()}%',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white38,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isPlayingThis && player.playing
                                            ? Icons.pause_circle_filled_rounded
                                            : Icons.play_circle_fill_rounded,
                                        color: const Color(0xFF1DB954),
                                        size: 40,
                                      ),
                                      tooltip: 'Stream this track',
                                      onPressed: () async {
                                        if (isPlayingThis) {
                                          player.togglePlayPause();
                                        } else {
                                          await player
                                              .playSong(track.toSongRow());
                                          if (context.mounted) {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const NowPlayingPage(),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const Divider(
                                    height: 16, color: Colors.white10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    RatingWidget(
                                      songId: track.id,
                                      compact: true,
                                      onRated: (rating) {
                                        if (rating >= 8) {
                                          _promote(track);
                                        }
                                      },
                                    ),
                                    TextButton.icon(
                                      icon: const Icon(Icons.download_rounded,
                                          size: 18),
                                      label: const Text('Add & Download'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white70,
                                      ),
                                      onPressed: () => _promote(track),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
