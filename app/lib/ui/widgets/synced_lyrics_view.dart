import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/lyrics.dart';
import '../../core/state/player_controller.dart';

/// Auto-scrolling synced lyrics view (Spotify style): the active line is
/// centered and highlighted; plain text falls back to a static list.
class SyncedLyricsView extends StatefulWidget {
  final Lyrics lyrics;

  const SyncedLyricsView({super.key, required this.lyrics});

  @override
  State<SyncedLyricsView> createState() => _SyncedLyricsViewState();
}

class _SyncedLyricsViewState extends State<SyncedLyricsView> {
  final ScrollController _scroll = ScrollController();
  int _active = -1;
  late final PlayerController _player;
  bool _subscribed = false;

  static const double _lineHeight = 46;

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
      final target = max(0.0, idx * _lineHeight - (240 / 2 - _lineHeight / 2));
      final maxExtent = _scroll.position.maxScrollExtent;
      _scroll.animateTo(
        target.clamp(0.0, maxExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.lyrics.synced) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: widget.lyrics.plainText.split('\n').map((l) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              l,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          );
        }).toList(),
      );
    }

    final lines = widget.lyrics.lines;
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(vertical: 120),
      itemCount: lines.length,
      itemExtent: _lineHeight,
      itemBuilder: (context, index) {
        final active = index == _active;
        final upNext = _active >= 0 && (index == _active + 1 || index == _active + 2);
        return InkWell(
          onTap: () {
            _player.seek(lines[index].time);
            _updateActive(lines[index].time);
          },
          splashColor: Colors.white10,
          highlightColor: Colors.transparent,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 16,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              color: active
                  ? const Color(0xFF1DB954)
                  : upNext
                      ? Colors.white
                      : Colors.white38,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  lines[index].text,
                  textAlign: TextAlign.center,
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
