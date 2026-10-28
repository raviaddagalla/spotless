import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/db/app_database.dart';
import '../theme/spotless_colors.dart';

/// Shows a song's cover: local cached file, then network URL, then a
/// gradient placeholder with the title initials.
///
/// PixelPlayer-inspired: uses [SpotlessColors.radiusMd] for rounded corners
/// and a richer gradient placeholder.
class AlbumArt extends StatelessWidget {
  final SongRow? song;
  final String? title;
  final String? subtitle;
  final String? artPath;
  final String? artUrl;
  final double size;
  final double? borderRadius;

  const AlbumArt({
    super.key,
    this.song,
    this.title,
    this.subtitle,
    this.artPath,
    this.artUrl,
    this.size = 48,
    this.borderRadius,
  });

  String get _title => song?.title ?? title ?? '?';
  String? get _path => song?.albumArtPath ?? artPath;
  String? get _url => song?.albumArtUrl ?? artUrl;

  @override
  Widget build(BuildContext context) {
    final size = this.size;
    final r = borderRadius ?? max(4, size * 0.12);
    final radius = BorderRadius.circular(r);

    Widget? image;
    final path = _path;
    if (path != null && path.isNotEmpty && File(path).existsSync()) {
      image = Image.file(
        File(path),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(radius),
      );
    } else if (_url != null && _url!.isNotEmpty) {
      image = CachedNetworkImage(
        imageUrl: _url!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, _) => _placeholder(radius),
        errorWidget: (_, _, _) => _placeholder(radius),
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: image ?? _placeholder(radius),
    );
  }

  Widget _placeholder(BorderRadius radius) {
    final base = _title.toUpperCase();
    var initials = '';
    for (final w in base.split(RegExp(r'\s+'))) {
      if (w.isNotEmpty) initials += w[0];
      if (initials.length == 2) break;
    }
    if (initials.isEmpty) initials = '♪';
    final hash = _title.hashCode.abs();
    final colors = [
      SpotlessColors.primary,
      const Color(0xFF8D6E63),
      const Color(0xFF5C6BC0),
      const Color(0xFF26A69A),
      const Color(0xFFAB47BC),
      const Color(0xFFEF5350),
      const Color(0xFFFFA726),
      const Color(0xFF29B6F6),
    ];
    final c = colors[hash % colors.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.withValues(alpha: 0.85), c.withValues(alpha: 0.35)],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.3,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
