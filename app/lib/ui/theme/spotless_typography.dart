import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography scale for Spotless, inspired by PixelPlayer's bold
/// hero headings, clean body text, and muted captions.
///
/// Uses Google Font "Inter" for excellent readability on mobile screens,
/// with weight variations from Regular (400) through Black (900).
abstract final class SpotlessTypography {
  /// Build the complete [TextTheme] for the Spotless app.
  static TextTheme textTheme() {
    final base = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return base.copyWith(
      // ---- Display ----
      // Used for hero sections like "Your Mix" on Home.
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 52,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.5,
        height: 1.05,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        height: 1.1,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.15,
      ),

      // ---- Headline ----
      // Screen titles: "Library", "Now Playing".
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),

      // ---- Title ----
      // Section headers, card titles.
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),

      // ---- Body ----
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),

      // ---- Label ----
      // Badges, chips, nav bar labels.
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }
}
