import 'dart:io';

import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../core/db/app_database.dart';
import '../../core/services/music_repository.dart';
import '../../core/state/player_controller.dart';
import 'spotless_colors.dart';

/// Watches the current playing song and extracts a [ColorScheme] from its
/// album art.  Widgets higher in the tree (typically [SpotlessApp]) listen
/// to this notifier and rebuild [MaterialApp]'s theme accordingly, giving
/// the entire app a PixelPlayer-style dynamic color treatment.
class DynamicThemeProvider extends ChangeNotifier {
  final MusicRepository repo;
  final PlayerController player;

  ColorScheme _scheme = _fallbackScheme;
  Color _dominant = SpotlessColors.surface;

  /// Last song ID whose art was extracted, to avoid redundant re-extraction.
  String? _lastSongId;

  DynamicThemeProvider({
    required this.repo,
    required this.player,
  }) {
    player.addListener(_onPlayerChanged);
    // Trigger initial extraction if something is already playing.
    _onPlayerChanged();
  }

  // ---- public getters ----

  /// The dynamically-derived color scheme (or fallback).
  ColorScheme get scheme => _scheme;

  /// The dominant color extracted from the current song's album art.
  Color get dominant => _dominant;

  // ---- lifecycle ----

  @override
  void dispose() {
    player.removeListener(_onPlayerChanged);
    super.dispose();
  }

  // ---- internal ----

  void _onPlayerChanged() {
    final song = player.currentSong;
    if (song == null) {
      _reset();
      return;
    }
    if (song.id == _lastSongId) return;
    _lastSongId = song.id;
    _extractColors(song);
  }

  Future<void> _extractColors(SongRow song) async {
    try {
      final artPath = await repo.coverFor(song);

      ImageProvider? provider;
      if (artPath != null && artPath.isNotEmpty && File(artPath).existsSync()) {
        provider = FileImage(File(artPath));
      } else if (song.albumArtUrl != null && song.albumArtUrl!.isNotEmpty) {
        provider = NetworkImage(song.albumArtUrl!);
      }

      if (provider == null) {
        _reset();
        return;
      }

      final palette = await PaletteGenerator.fromImageProvider(
        provider,
        maximumColorCount: 16,
        timeout: const Duration(seconds: 5),
      );

      // Pick the dominant color; prefer the vibrant variant if available.
      _dominant = palette.vibrantColor?.color ??
          palette.dominantColor?.color ??
          SpotlessColors.primary;

      _scheme = ColorScheme.fromSeed(
        seedColor: _dominant,
        brightness: Brightness.dark,
        surface: SpotlessColors.surface,
      );

      notifyListeners();
    } catch (e) {
      debugPrint('[DynamicThemeProvider] palette extraction failed: $e');
      _reset();
    }
  }

  void _reset() {
    if (_scheme == _fallbackScheme && _dominant == SpotlessColors.surface) return;
    _scheme = _fallbackScheme;
    _dominant = SpotlessColors.surface;
    _lastSongId = null;
    notifyListeners();
  }

  static final ColorScheme _fallbackScheme = ColorScheme.fromSeed(
    seedColor: SpotlessColors.primary,
    brightness: Brightness.dark,
    surface: SpotlessColors.surface,
  );
}
