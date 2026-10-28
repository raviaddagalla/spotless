import 'package:flutter/material.dart';

/// Static color palette for Spotless, inspired by PixelPlayer's deep-navy
/// dark mode. Dynamic album-art-derived colors are managed separately by
/// [DynamicThemeProvider]; these constants serve as the baseline/fallback.
abstract final class SpotlessColors {
  // ---- base surface tones (deep navy / charcoal) ----

  /// Deepest background, used for scaffolds.
  static const Color background = Color(0xFF0D1117);

  /// Slightly elevated surface (cards, bottom sheets).
  static const Color surface = Color(0xFF161B22);

  /// Higher-elevation surface (mini-player, modals).
  static const Color surfaceHigh = Color(0xFF1C2333);

  /// Highest-elevation surface (dialogs, popups).
  static const Color surfaceTop = Color(0xFF242D3D);

  /// Material 3 container aliases
  static const Color surfaceContainer = surface;
  static const Color surfaceContainerHigh = surfaceHigh;
  static const Color surfaceContainerHighest = surfaceTop;

  /// Very subtle surface variant for borders / dividers.
  static const Color outline = Color(0xFF2D3748);

  // ---- primary accent (Spotless green — kept for brand continuity) ----

  static const Color primary = Color(0xFF1DB954);
  static const Color primaryDim = Color(0xFF169C46);
  static const Color onPrimary = Color(0xFF000000);

  // ---- secondary / tertiary ----

  /// Blue-tinted accent (used for info badges, secondary actions).
  static const Color secondary = Color(0xFF7C8FFF);

  /// Warm accent for warnings / ratings.
  static const Color tertiary = Color(0xFFFFB74D);

  // ---- text / on-surface ----

  static const Color onSurface = Color(0xFFE6EDF3);
  static const Color onSurfaceMedium = Color(0xFFA8B2C0);
  static const Color onSurfaceDim = Color(0xFF6B7B8D);

  // ---- status indicators ----

  static const Color error = Color(0xFFFF5252);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFB74D);

  // ---- opacity tokens for glass effects ----

  static const double glassOpacity = 0.65;
  static const double overlayLight = 0.08;
  static const double overlayMedium = 0.15;
  static const double overlayHeavy = 0.30;

  // ---- corner radii ----

  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 28.0;
  static const double radiusFull = 100.0;

  // ---- helpers ----

  /// Builds a vertical gradient from the dominant color fading into the
  /// background, used as the "immersive" backdrop on Now Playing / Lyrics.
  static LinearGradient immersiveGradient(Color dominant) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        dominant.withValues(alpha: 0.85),
        dominant.withValues(alpha: 0.45),
        background,
      ],
      stops: const [0.0, 0.45, 1.0],
    );
  }

  /// Builds a subtle top-down gradient for screen headers.
  static LinearGradient headerGradient(Color dominant) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        dominant.withValues(alpha: 0.35),
        Colors.transparent,
      ],
    );
  }

  /// Mini-player / card tinted glass background.
  static Color glassSurface(Color tint) {
    return Color.lerp(surfaceHigh, tint, 0.25)!.withValues(alpha: glassOpacity);
  }
}
