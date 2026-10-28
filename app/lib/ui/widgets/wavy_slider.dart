import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/spotless_colors.dart';

/// PixelPlayer-inspired sinusoidal seek bar.
///
/// Draws a wavy (sine-wave) line for the played portion and a straight
/// line for the remaining duration.  Supports drag-to-seek.
class WavySlider extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;
  final bool isPlaying;
  final Color? activeColor;
  final Color? inactiveColor;

  const WavySlider({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
    this.isPlaying = false,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<WavySlider> createState() => _WavySliderState();
}

class _WavySliderState extends State<WavySlider>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveAnim;
  double? _dragFraction;

  @override
  void initState() {
    super.initState();
    _waveAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isPlaying) _waveAnim.repeat();
  }

  @override
  void didUpdateWidget(covariant WavySlider old) {
    super.didUpdateWidget(old);
    if (widget.isPlaying && !_waveAnim.isAnimating) {
      _waveAnim.repeat();
    } else if (!widget.isPlaying && _waveAnim.isAnimating) {
      _waveAnim.stop();
    }
  }

  @override
  void dispose() {
    _waveAnim.dispose();
    super.dispose();
  }

  double get _fraction {
    if (_dragFraction != null) return _dragFraction!;
    final totalMs = widget.duration.inMilliseconds;
    if (totalMs <= 0) return 0;
    return (widget.position.inMilliseconds / totalMs).clamp(0.0, 1.0);
  }

  void _handleDragStart(DragStartDetails details, double width) {
    final frac = (details.localPosition.dx / width).clamp(0.0, 1.0);
    setState(() => _dragFraction = frac);
  }

  void _handleDragUpdate(DragUpdateDetails details, double width) {
    final frac = (details.localPosition.dx / width).clamp(0.0, 1.0);
    setState(() => _dragFraction = frac);
  }

  void _handleDragEnd(DragEndDetails _) {
    if (_dragFraction != null) {
      final ms = (_dragFraction! * widget.duration.inMilliseconds).round();
      widget.onSeek(Duration(milliseconds: ms));
    }
    setState(() => _dragFraction = null);
  }

  void _handleTap(TapUpDetails details, double width) {
    final frac = (details.localPosition.dx / width).clamp(0.0, 1.0);
    final ms = (frac * widget.duration.inMilliseconds).round();
    widget.onSeek(Duration(milliseconds: ms));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final activeColor = widget.activeColor ?? scheme.primary;
    final inactiveColor =
        widget.inactiveColor ?? SpotlessColors.onSurfaceDim.withValues(alpha: 0.3);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          onHorizontalDragStart: (d) => _handleDragStart(d, width),
          onHorizontalDragUpdate: (d) => _handleDragUpdate(d, width),
          onHorizontalDragEnd: _handleDragEnd,
          onTapUp: (d) => _handleTap(d, width),
          child: SizedBox(
            height: 40,
            width: width,
            child: AnimatedBuilder(
              animation: _waveAnim,
              builder: (context, _) {
                return CustomPaint(
                  size: Size(width, 40),
                  painter: _WavyPainter(
                    fraction: _fraction,
                    wavePhase: _waveAnim.value * 2 * math.pi,
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                    isDragging: _dragFraction != null,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _WavyPainter extends CustomPainter {
  final double fraction;
  final double wavePhase;
  final Color activeColor;
  final Color inactiveColor;
  final bool isDragging;

  _WavyPainter({
    required this.fraction,
    required this.wavePhase,
    required this.activeColor,
    required this.inactiveColor,
    required this.isDragging,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final splitX = size.width * fraction;

    // ---- inactive track (straight line) ----
    final inactivePaint = Paint()
      ..color = inactiveColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(splitX, cy),
      Offset(size.width, cy),
      inactivePaint,
    );

    // ---- active track (wavy line) ----
    if (splitX > 0) {
      final activePaint = Paint()
        ..color = activeColor
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      const amplitude = 6.0;
      const frequency = 0.035; // waves per pixel

      path.moveTo(0, cy);
      for (double x = 0; x <= splitX; x += 1) {
        final y = cy + amplitude * math.sin(frequency * x * 2 * math.pi + wavePhase);
        path.lineTo(x, y);
      }

      canvas.drawPath(path, activePaint);
    }

    // ---- thumb ----
    final thumbRadius = isDragging ? 8.0 : 6.0;
    final thumbY = splitX > 0
        ? cy +
            6.0 *
                math.sin(
                    0.035 * splitX * 2 * math.pi + wavePhase)
        : cy;

    final thumbPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(splitX, thumbY), thumbRadius, thumbPaint);

    // White border on thumb
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(splitX, thumbY), thumbRadius, borderPaint);
  }

  @override
  bool shouldRepaint(_WavyPainter old) =>
      old.fraction != fraction ||
      old.wavePhase != wavePhase ||
      old.isDragging != isDragging;
}
