import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/music_repository.dart';

/// 10-point rating widget supporting instant tapping and persistent history.
///
/// Per Specification §12:
/// - Provides an intuitive visual UI (1 to 10 stars).
/// - Fast selection without requiring text input.
/// - Persists every rating event with active session association.
class RatingWidget extends StatefulWidget {
  final String songId;
  final bool compact;
  final ValueChanged<int>? onRated;

  const RatingWidget({
    super.key,
    required this.songId,
    this.compact = false,
    this.onRated,
  });

  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  int? _currentRating;
  bool _submitting = false;
  int _loadRequest = 0;

  @override
  void initState() {
    super.initState();
    _loadRating();
  }

  @override
  void didUpdateWidget(covariant RatingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.songId != widget.songId) {
      // Don't show the previous song's rating while the new lookup runs.
      setState(() {
        _currentRating = null;
        _submitting = false;
      });
      _loadRating();
    }
  }

  Future<void> _loadRating() async {
    final request = ++_loadRequest;
    final songId = widget.songId;
    final repo = context.read<MusicRepository>();
    try {
      final rating = await repo.ratingService.getLatestRating(songId);
      if (mounted && request == _loadRequest && widget.songId == songId) {
        setState(() => _currentRating = rating);
      }
    } catch (_) {
      // A failed lookup leaves the widget unrated; rating still works.
    }
  }

  Future<void> _rate(int value) async {
    if (_submitting) return;
    final songId = widget.songId;
    setState(() {
      _submitting = true;
      _currentRating = value;
    });

    final repo = context.read<MusicRepository>();
    try {
      await repo.ratingService.rateSong(songId, value);
      if (!mounted || widget.songId != songId) return;
      setState(() => _submitting = false);
      widget.onRated?.call(value);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rated $value/10: ${_ratingLabel(value)}'),
          duration: const Duration(milliseconds: 1200),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted || widget.songId != songId) return;
      setState(() {
        _submitting = false;
        _currentRating = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save rating: $e')),
      );
    }
  }

  /// Compact mode is used inside dense discovery cards. It opens the full
  /// 10-star control instead of being a dead, non-interactive label.
  Future<void> _openCompactRating() async {
    if (_submitting) return;
    final rated = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: RatingWidget(
          songId: widget.songId,
          onRated: (value) => Navigator.of(ctx).pop(value),
        ),
      ),
    );
    if (rated != null && mounted) {
      setState(() => _currentRating = rated);
      widget.onRated?.call(rated);
    }
  }

  static String _ratingLabel(int r) {
    return switch (r) {
      10 => 'Masterpiece ★★★★★',
      9 => 'Incredible',
      8 => 'Great track',
      7 => 'Good',
      6 => 'Decent',
      5 => 'Average',
      4 => 'Mediocre',
      3 => 'Poor',
      2 => 'Bad',
      1 => 'Dislike',
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final rating = _currentRating;

    if (widget.compact) {
      return InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: _openCompactRating,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                rating != null ? '$rating/10' : 'Rate',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: rating != null ? Colors.amber : Colors.white54,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Rating',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            Text(
              rating != null ? '$rating / 10 • ${_ratingLabel(rating)}' : 'Tap star to rate (1–10)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: rating != null ? Theme.of(context).colorScheme.primary : Colors.white38,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(10, (index) {
              final starValue = index + 1;
              final filled = rating != null && starValue <= rating;
              return GestureDetector(
                onTap: () => _rate(starValue),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
                  child: Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 28,
                    color: filled ? Colors.amber : Colors.white30,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
