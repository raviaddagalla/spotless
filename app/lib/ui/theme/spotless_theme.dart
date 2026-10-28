import 'package:flutter/material.dart';

import 'spotless_colors.dart';
import 'spotless_typography.dart';

/// Central [ThemeData] factory for Spotless.
///
/// Produces a Material 3 dark theme whose [ColorScheme] is either the
/// static deep-navy baseline or a dynamic scheme generated from
/// album-art colors (passed in via [colorScheme]).
abstract final class SpotlessTheme {
  /// Builds the theme.  Pass [colorScheme] from [DynamicThemeProvider] to
  /// enable album-art-derived dynamic theming; otherwise the static
  /// Spotless green accent is used.
  static ThemeData of({ColorScheme? colorScheme}) {
    final scheme = colorScheme ?? _defaultScheme;
    final textTheme = SpotlessTypography.textTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      textTheme: textTheme,

      // ---- scaffolds ----
      scaffoldBackgroundColor: SpotlessColors.background,

      // ---- app bar ----
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineMedium?.copyWith(
          color: SpotlessColors.onSurface,
        ),
        iconTheme: const IconThemeData(color: SpotlessColors.onSurface),
      ),

      // ---- navigation bar (bottom) ----
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: SpotlessColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primary.withValues(alpha: 0.18),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpotlessColors.radiusFull),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            color: active ? scheme.primary : SpotlessColors.onSurfaceDim,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return IconThemeData(
            color: active ? scheme.primary : SpotlessColors.onSurfaceDim,
            size: 24,
          );
        }),
        height: 72,
      ),

      // ---- cards ----
      cardTheme: CardThemeData(
        color: SpotlessColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpotlessColors.radiusLg),
        ),
        margin: EdgeInsets.zero,
      ),

      // ---- bottom sheets ----
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: SpotlessColors.surfaceHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(SpotlessColors.radiusXl),
          ),
        ),
      ),

      // ---- dialogs ----
      dialogTheme: DialogThemeData(
        backgroundColor: SpotlessColors.surfaceHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpotlessColors.radiusXl),
        ),
      ),

      // ---- chips ----
      chipTheme: ChipThemeData(
        backgroundColor: SpotlessColors.surface,
        selectedColor: scheme.primary.withValues(alpha: 0.2),
        surfaceTintColor: Colors.transparent,
        side: const BorderSide(color: SpotlessColors.outline, width: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpotlessColors.radiusFull),
        ),
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // ---- slider ----
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: SpotlessColors.outline,
        thumbColor: scheme.primary,
        overlayColor: scheme.primary.withValues(alpha: 0.12),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
        trackHeight: 3,
      ),

      // ---- filled button ----
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(scheme.primary),
          foregroundColor: const WidgetStatePropertyAll(SpotlessColors.onPrimary),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SpotlessColors.radiusFull),
            ),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
        ),
      ),

      // ---- text button ----
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(scheme.primary),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
        ),
      ),

      // ---- icon button ----
      iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(
          iconColor: WidgetStatePropertyAll(SpotlessColors.onSurface),
        ),
      ),

      // ---- floating action button ----
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: SpotlessColors.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpotlessColors.radiusFull),
        ),
      ),

      // ---- list tile ----
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpotlessColors.radiusMd),
        ),
        iconColor: SpotlessColors.onSurfaceMedium,
      ),

      // ---- snackbar ----
      snackBarTheme: SnackBarThemeData(
        backgroundColor: SpotlessColors.surfaceTop,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: SpotlessColors.onSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpotlessColors.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ---- divider ----
      dividerTheme: const DividerThemeData(
        color: SpotlessColors.outline,
        thickness: 0.5,
      ),

      // ---- popup menu ----
      popupMenuTheme: PopupMenuThemeData(
        color: SpotlessColors.surfaceHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpotlessColors.radiusMd),
        ),
      ),

      // ---- tab bar ----
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.primary,
        unselectedLabelColor: SpotlessColors.onSurfaceDim,
        labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: textTheme.labelLarge,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: scheme.primary, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
      ),

      // ---- progress indicators ----
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: SpotlessColors.outline,
      ),
    );
  }

  static final ColorScheme _defaultScheme = ColorScheme.fromSeed(
    seedColor: SpotlessColors.primary,
    brightness: Brightness.dark,
    surface: SpotlessColors.surface,
  );
}
