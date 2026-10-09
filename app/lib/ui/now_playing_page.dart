import 'package:flutter/material.dart' hide RepeatMode;
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../core/audio/audio_engine.dart';
import '../core/db/app_database.dart';
import '../core/services/music_repository.dart';
import '../core/state/player_controller.dart';
import 'lyrics_page.dart';
import 'widgets/album_art.dart';
import 'widgets/rating_widget.dart';
import 'widgets/similar_tracks_sheet.dart';
import 'widgets/status_badge.dart';

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({super.key});

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final song = player.currentSong;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Now Playing'),
        actions: [
          if (song != null) _LikeButton(song: song),
          if (song != null && song.status != 'downloaded')
            IconButton(
              icon: player.downloading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_outlined),
              tooltip: 'Download',
              onPressed: player.downloading ? null : player.downloadCurrent,
            ),
          IconButton(
            icon: const Icon(Icons.queue_music),
            tooltip: 'Queue',
            onPressed: song == null
                ? null
                : () => showModalBottomSheet(
                      context: context,
                      backgroundColor: const Color(0xFF1E1E1E),
                      builder: (_) => const QueueSheet(),
                    ),
          ),
          IconButton(
            icon: const Icon(Icons.lyrics_outlined),
            tooltip: 'Lyrics',
            onPressed: song == null
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LyricsPage()),
                    ),
          ),
          if (song != null)
            IconButton(
              icon: const Icon(Icons.sensors_rounded),
              tooltip: 'Track Radio',
              onPressed: () => SimilarTracksSheet.show(context, song),
            ),
          const _SleepTimerButton(),
        ],
      ),
      body: song == null
          ? const Center(child: Text('Nothing playing'))
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Center(
                            child: AlbumArt(
                              song: song,
                              size: MediaQuery.of(context).size.width - 64,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            song.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            song.artist,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey.shade400),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (song.status == 'streamable')
                                const Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: StatusBadge(status: 'streamable'),
                                ),
                              if (song.status == 'failed' ||
                                  song.status == 'missing')
                                const StatusBadge(status: 'missing'),
                            ],
                          ),
                          if (player.error != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                player.error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: RatingWidget(songId: song.id),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  if (player.downloading) _DownloadProgress(player: player),
                  if (player.loading)
                    const _LoadingBanner()
                  else
                    _SeekBar(
                      position: player.position,
                      duration: player.duration,
                      dragValue: _dragValue,
                      onChanged: (v) => setState(() => _dragValue = v),
                      onChangeEnd: (v) {
                        setState(() => _dragValue = null);
                        player.seek(Duration(milliseconds: v.round()));
                      },
                    ),
                  _Controls(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
    );
  }
}

class _SleepTimerButton extends StatelessWidget {
  const _SleepTimerButton();

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final active = player.sleepTimerActive;
    final remaining = player.sleepRemaining;
    return IconButton(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.bedtime_outlined,
            color: active ? const Color(0xFF1DB954) : null,
          ),
          if (remaining != null && remaining > Duration.zero)
            Positioned(
              right: -6,
              top: -4,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFF1DB954),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _fmt(remaining),
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
        ],
      ),
      tooltip: active ? 'Sleep timer on' : 'Sleep timer',
      onPressed: () => _showTimerSheet(context, player),
    );
  }

  void _showTimerSheet(BuildContext context, PlayerController player) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Sleep timer',
                style: Theme.of(ctx).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            for (final (label, duration) in [
              ('5 minutes', const Duration(minutes: 5)),
              ('10 minutes', const Duration(minutes: 10)),
              ('15 minutes', const Duration(minutes: 15)),
              ('30 minutes', const Duration(minutes: 30)),
              ('1 hour', const Duration(hours: 1)),
            ])
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: Text(label),
                onTap: () {
                  player.startSleepTimer(duration);
                  Navigator.pop(ctx);
                },
              ),
            ListTile(
              leading: const Icon(Icons.music_note_outlined),
              title: const Text('End of current song'),
              onTap: () {
                player.startSleepAfterCurrent();
                Navigator.pop(ctx);
              },
            ),
            if (player.sleepTimerActive)
              ListTile(
                leading: const Icon(Icons.stop_circle_outlined),
                title: const Text('Turn off timer'),
                textColor: Colors.redAccent,
                onTap: () {
                  player.cancelSleepTimer();
                  Navigator.pop(ctx);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _LikeButton extends StatefulWidget {
  final SongRow song;

  const _LikeButton({required this.song});

  @override
  State<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<_LikeButton> {
  bool? _liked;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final liked = await context.read<MusicRepository>().isLiked(widget.song.id);
    if (mounted) setState(() => _liked = liked);
  }

  @override
  Widget build(BuildContext context) {
    final liked = _liked ?? widget.song.likedAt != null;
    return IconButton(
      icon: Icon(
        liked ? Icons.favorite : Icons.favorite_border,
        color: liked ? const Color(0xFF1DB954) : null,
      ),
      tooltip: liked ? 'Unlike' : 'Like',
      onPressed: () async {
        final next = !liked;
        setState(() => _liked = next);
        await context.read<MusicRepository>().setLiked(widget.song.id, next);
      },
    );
  }
}

class _LoadingBanner extends StatelessWidget {
  const _LoadingBanner();

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final label = switch (player.processingState) {
      ProcessingState.buffering => 'Buffering…',
      ProcessingState.loading => 'Loading…',
      _ => player.isStreaming ? 'Resolving from YouTube…' : 'Loading…',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}

class _DownloadProgress extends StatelessWidget {
  final PlayerController player;

  const _DownloadProgress({required this.player});

  @override
  Widget build(BuildContext context) {
    final pct = (player.downloadProgress * 100).clamp(0, 100).round();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          LinearProgressIndicator(value: player.downloadProgress),
          const SizedBox(height: 6),
          Text(
            'Downloading… $pct%',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SeekBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final double? dragValue;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  const _SeekBar({
    required this.position,
    required this.duration,
    required this.dragValue,
    required this.onChanged,
    required this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    final maxMs = duration.inMilliseconds.toDouble().clamp(1, double.infinity).toDouble();
    final value =
        (dragValue ?? position.inMilliseconds.toDouble()).clamp(0, maxMs).toDouble();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Slider(
            value: value,
            max: maxMs,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_fmt(value)),
                Text(_fmt(maxMs)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double ms) {
    final d = Duration(milliseconds: ms.round());
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

class _Controls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ShuffleButton(),
          IconButton(
            iconSize: 44,
            icon: const Icon(Icons.skip_previous_rounded),
            onPressed: () => player.previous(),
          ),
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: Color(0xFF1DB954),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              iconSize: 40,
              color: Colors.black,
              icon: Icon(
                player.loading
                    ? Icons.hourglass_top
                    : player.playing
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
              ),
              onPressed: player.loading ? null : player.togglePlayPause,
            ),
          ),
          IconButton(
            iconSize: 44,
            icon: const Icon(Icons.skip_next_rounded),
            onPressed: () => player.next(),
          ),
          _RepeatButton(),
        ],
      ),
    );
  }
}

class _ShuffleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final mode = player.shuffleMode;
    return IconButton(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            mode == ShuffleMode.smart
                ? Icons.auto_awesome_rounded
                : Icons.shuffle_rounded,
            color: mode != ShuffleMode.off
                ? const Color(0xFF1DB954)
                : Colors.white60,
          ),
          if (mode == ShuffleMode.smart)
            Positioned(
              right: -3,
              top: -3,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF1DB954),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      tooltip: switch (mode) {
        ShuffleMode.off => 'Shuffle: Off',
        ShuffleMode.normal => 'Shuffle: Normal',
        ShuffleMode.smart => 'Smart Shuffle: On',
      },
      onPressed: () => player.cycleShuffleMode(),
    );
  }
}

class _RepeatButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final mode = player.repeat;
    final (icon, active) = switch (mode) {
      RepeatMode.off => (Icons.repeat, false),
      RepeatMode.all => (Icons.repeat, true),
      RepeatMode.one => (Icons.repeat_one, true),
    };
    return _IconToggle(
      icon: icon,
      active: active,
      onPressed: () {
        final next = switch (mode) {
          RepeatMode.off => RepeatMode.all,
          RepeatMode.all => RepeatMode.one,
          RepeatMode.one => RepeatMode.off,
        };
        player.setRepeat(next);
      },
    );
  }
}

class _IconToggle extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onPressed;

  const _IconToggle({
    required this.icon,
    required this.active,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      color: active ? const Color(0xFF1DB954) : Colors.grey.shade500,
      onPressed: onPressed,
    );
  }
}

class QueueSheet extends StatelessWidget {
  const QueueSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final queue = player.queue;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'Queue',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 12),
                  if (player.shuffleMode == ShuffleMode.smart)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1DB954).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1DB954), width: 1),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, size: 12, color: Color(0xFF1DB954)),
                          SizedBox(width: 4),
                          Text(
                            'Smart Shuffle',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1DB954),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (player.shuffleMode == ShuffleMode.normal)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shuffle, size: 12, color: Colors.white70),
                          SizedBox(width: 4),
                          Text(
                            'Shuffle',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ReorderableListView.builder(
                buildDefaultDragHandles: false,
                onReorderItem: (oldIndex, newIndex) async {
                  await player.moveQueueItem(oldIndex, newIndex);
                },
                itemCount: queue.length,
                itemBuilder: (context, index) {
                  final song = queue[index];
                  final current = index == player.currentIndex;
                  return ListTile(
                    key: ValueKey('q-${song.id}-$index'),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ReorderableDragStartListener(
                          index: index,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.drag_handle,
                              size: 20,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                        AlbumArt(song: song, size: 40),
                      ],
                    ),
                    title: Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight:
                            current ? FontWeight.w700 : FontWeight.w500,
                        color: current
                            ? const Color(0xFF1DB954)
                            : null,
                      ),
                    ),
                    subtitle: Text(
                      song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => player.removeAt(index),
                    ),
                    onTap: () => player.jumpTo(index),
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
