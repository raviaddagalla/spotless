import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/config/app_config.dart';
import '../core/db/app_database.dart';
import '../core/services/music_repository.dart';
import '../core/state/player_controller.dart';
import 'theme/spotless_colors.dart';

/// Developer / Diagnostics screen as specified in Specification §50.
class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  ListeningSession? _session;
  int _sessionRatingsCount = 0;
  int _sessionEventsCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDiagnostics();
  }

  Future<void> _loadDiagnostics() async {
    final repo = context.read<MusicRepository>();
    final session = await repo.sessionManager.getActiveSession();
    int ratings = 0;
    int events = 0;
    if (session != null) {
      ratings = (await repo.sessionManager.getSessionRatings(session.id)).length;
      events = (await repo.sessionManager.getSessionPlaybackEvents(session.id)).length;
    }
    if (mounted) {
      setState(() {
        _session = session;
        _sessionRatingsCount = ratings;
        _sessionEventsCount = events;
        _loading = false;
      });
    }
  }

  String _fmtDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final song = player.currentSong;
    final lyrics = player.currentLyrics;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostics & Debug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDiagnostics,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _card(
                  context,
                  title: 'Current Playback',
                  icon: Icons.play_circle_outline_rounded,
                  children: [
                    _row('Track', song != null ? '${song.artist} - ${song.title}' : 'None'),
                    _row('ID', song?.id ?? '—'),
                    _row('Status', song?.status ?? '—'),
                    _row('Position', '${_fmtDuration(player.position)} / ${_fmtDuration(player.duration)}'),
                    _row('Playing State', player.playing ? 'Playing' : 'Paused'),
                    _row('Processing', player.processingState.name),
                    _row('Audio Source', player.isStreaming ? 'YouTube Stream' : 'Local File (${song?.filename ?? ""})'),
                    _row('Shuffle Mode', player.shuffleMode.name.toUpperCase()),
                    _row('Repeat Mode', player.repeat.name.toUpperCase()),
                  ],
                ),
                const SizedBox(height: 16),
                _card(
                  context,
                  title: 'Active Listening Session (Spec §1-§10)',
                  icon: Icons.timer_outlined,
                  children: [
                    _row('Session ID', _session?.id ?? 'No active session (idle)'),
                    _row('State', _session?.state ?? '—'),
                    _row('Started At', _session != null ? _session!.startedAt.toLocal().toString() : '—'),
                    _row('Last Activity', _session != null ? _session!.lastActivityAt.toLocal().toString() : '—'),
                    _row('Inactivity Threshold', '${AppConfig.sessionInactivityThreshold.inHours} hour (Configurable)'),
                    _row('Time-of-day Model', 'DISABLED (Spec §45 strict compliance)'),
                    _row('Ratings In Session', '$_sessionRatingsCount explicit ratings'),
                    _row('Playback Events', '$_sessionEventsCount implicit events'),
                  ],
                ),
                const SizedBox(height: 16),
                _card(
                  context,
                  title: 'Recommendation & Discovery (Spec §17-§24)',
                  icon: Icons.auto_awesome_outlined,
                  children: [
                    _row('Providers', 'Last.fm, Qloo, Local Features'),
                    _row('Diversity Cap', '${AppConfig.maxTracksPerArtist} tracks max per artist'),
                    _row('Download Threshold', 'Rating >= ${AppConfig.downloadPromotionThreshold}/10'),
                    _row('Novelty Weight', '${AppConfig.noveltyBonus}'),
                    _row('Session Weight', '${AppConfig.sessionWeight}'),
                    _row('Long-term Weight', '${AppConfig.longTermWeight}'),
                    _row('Repetition Penalty', '${AppConfig.repetitionPenalty}'),
                  ],
                ),
                const SizedBox(height: 16),
                _card(
                  context,
                  title: 'Lyrics Synchronization (Spec §29-§32)',
                  icon: Icons.lyrics_outlined,
                  children: [
                    _row('Has Lyrics', lyrics != null && !lyrics.isEmpty ? 'Yes' : 'No'),
                    _row('Type', lyrics != null && lyrics.synced ? 'Synchronized LRC (Tap-to-seek active)' : 'Plain text'),
                    _row('Line Count', lyrics != null ? '${lyrics.lines.length} lines' : '0'),
                    _row('Matching', 'Duration & metadata matched (lrclib)'),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _card(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      color: SpotlessColors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SpotlessColors.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const Divider(height: 20, color: Colors.white12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
