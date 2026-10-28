import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/lyrics.dart';
import '../../core/state/player_controller.dart';
import '../theme/spotless_colors.dart';

/// Auto-scrolling synced lyrics view, PixelPlayer-inspired:
/// - Large bold text (22sp active, 20sp inactive)
/// - Active line: full white, bold weight
/// - Inactive lines: semi-transparent, regular weight
/// - Smooth spring scroll centering the active line
///
/// Supports synced mode (timestamp-driven) and static mode (plain text).
class SyncedLyricsView extends StatefulWidget {
  final Lyrics lyrics;
  final bool showSynced;

  const SyncedLyricsView({
    super.key,
    required this.lyrics,
    this.showSynced = true,
  });

  @override
  State<SyncedLyricsView> createState() => _SyncedLyricsViewState();
}

class _SyncedLyricsViewState extends State<SyncedLyricsView> {
  final ScrollController _scroll = ScrollController();
  int _active = -1;
  late final PlayerController _player;
  bool _subscribed = false;

  static const double _lineHeight = 64;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_subscribed) {
      _subscribed = true;
      _player = context.read<PlayerController>();
      _player.addListener(_onPlayerChanged);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _updateActive(_player.position);
      });
    }
  }

  @override
  void didUpdateWidget(covariant SyncedLyricsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lyrics != widget.lyrics) {
      _active = -1;
    }
  }

  @override
  void dispose() {
    if (_subscribed) _player.removeListener(_onPlayerChanged);
    _scroll.dispose();
    super.dispose();
  }

  void _onPlayerChanged() {
    if (!mounted) return;
    _updateActive(_player.position);
  }

  void _updateActive(Duration position) {
    final lines = widget.lyrics.lines;
    if (lines.isEmpty) return;
    var idx = -1;
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].time <= position) {
        idx = i;
      } else {
        break;
      }
    }
    if (idx == _active) return;
    setState(() => _active = idx);
    if (idx >= 0 && _scroll.hasClients) {
      final viewportHeight = _scroll.position.viewportDimension;
      final target =
          max(0.0, idx * _lineHeight - (viewportHeight / 2 - _lineHeight / 2));
      final maxExtent = _scroll.position.maxScrollExtent;
      _scroll.animateTo(
        target.clamp(0.0, maxExtent),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ---- Static (plain text) mode ----
    if (!widget.lyrics.synced || !widget.showSynced) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        children: widget.lyrics.plainText.split('\n').map((l) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l,
              style: const TextStyle(
                fontSize: 20,
                height: 1.6,
                color: Colors.white70,
              ),
            ),
          );
        }).toList(),
      );
    }

    // ---- Synced mode ----
    final lines = widget.lyrics.lines;
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(vertical: 100),
      itemCount: lines.length,
      itemExtent: _lineHeight,
      itemBuilder: (context, index) {
        final active = index == _active;
        final upNext = _active >= 0 &&
            (index == _active + 1 || index == _active + 2);
        return InkWell(
          onTap: () {
            _player.seek(lines[index].time);
            _updateActive(lines[index].time);
          },
          splashColor: Colors.white10,
          highlightColor: Colors.transparent,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            style: TextStyle(
              fontSize: active ? 22 : 20,
              fontWeight: active ? FontWeight.w800 : FontWeight.w400,
              color: active
                  ? SpotlessColors.onSurface
                  : upNext
                      ? SpotlessColors.onSurfaceMedium
                      : SpotlessColors.onSurfaceDim.withValues(alpha: 0.5),
              height: 1.4,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  lines[index].text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
