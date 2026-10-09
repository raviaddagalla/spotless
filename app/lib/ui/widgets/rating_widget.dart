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

  @override
  void initState() {
    super.initState();
    _loadRating();
  }

  @override
  void didUpdateWidget(covariant RatingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.songId != widget.songId) {
      _loadRating();
    }
  }

  Future<void> _loadRating() async {
    final repo = context.read<MusicRepository>();
    final rating = await repo.ratingService.getLatestRating(widget.songId);
    if (mounted) {
      setState(() => _currentRating = rating);
    }
  }

  Future<void> _rate(int value) async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _currentRating = value;
    });

    final repo = context.read<MusicRepository>();
    await repo.ratingService.rateSong(widget.songId, value);

    if (mounted) {
      setState(() => _submitting = false);
      widget.onRated?.call(value);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rated $value/10: ${_ratingLabel(value)}'),
          duration: const Duration(milliseconds: 1200),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 16, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            rating != null ? '$rating/10' : 'Unrated',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: rating != null ? Colors.amber : Colors.white54,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
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
                    color: rating != null ? const Color(0xFF1DB954) : Colors.white38,
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
