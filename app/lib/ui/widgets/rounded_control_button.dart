import 'package:flutter/material.dart';

import '../theme/spotless_colors.dart';

/// PixelPlayer-style rounded-rectangle control button used for
/// Previous / Play-Pause / Next in the Now Playing screen.
///
/// The play/pause button gets a larger, lighter variant; previous/next
/// are smaller with a more subtle tint.
class RoundedControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final bool isPrimary;
  final Color? color;

  const RoundedControlButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 64,
    this.isPrimary = false,
    this.color,
  });

  /// Convenience constructor for the large play/pause button.
  const RoundedControlButton.playPause({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
  })  : size = 72,
        isPrimary = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bgColor = color ??
        (isPrimary
            ? scheme.primary.withValues(alpha: 0.25)
            : SpotlessColors.surfaceTop.withValues(alpha: 0.6));
    final iconColor = isPrimary ? scheme.primary : SpotlessColors.onSurface;
    final iconSize = isPrimary ? size * 0.5 : size * 0.45;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(isPrimary ? 24 : 20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        splashColor: scheme.primary.withValues(alpha: 0.15),
        highlightColor: Colors.transparent,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Icon(icon, size: iconSize, color: iconColor),
          ),
        ),
      ),
    );
  }
}
