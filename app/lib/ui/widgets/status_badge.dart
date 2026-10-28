import 'package:flutter/material.dart';

import '../theme/spotless_colors.dart';

/// Pill-shaped status badge showing download/stream/error state.
class StatusBadge extends StatelessWidget {
  final String? status;

  const StatusBadge({super.key, this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'streamable' => ('Stream', SpotlessColors.secondary),
      'missing' => ('Missing', SpotlessColors.warning),
      'failed' => ('Failed', SpotlessColors.error),
      _ => ('', Colors.transparent),
    };
    if (label.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(SpotlessColors.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
