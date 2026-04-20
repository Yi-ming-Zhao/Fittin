import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';

/// Fittin Ring — thin circular progress indicator
/// Replaces glowing white ring with clean accent stroke
class FittinRing extends StatelessWidget {
  const FittinRing(
    this.theme, {
    super.key,
    required this.value,
    required this.max,
    this.size = 120,
    this.strokeWidth = 2,
    this.child,
  });

  final FittinTheme theme;
  final double value;
  final double max;
  final double size;
  final double strokeWidth;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _FittinRingPainter(
          value: value,
          max: max,
          theme: theme,
          strokeWidth: strokeWidth,
        ),
        child: child != null
            ? Center(child: child)
            : null,
      ),
    );
  }
}

class _FittinRingPainter extends CustomPainter {
  _FittinRingPainter({
    required this.value,
    required this.max,
    required this.theme,
    required this.strokeWidth,
  });

  final double value;
  final double max;
  final FittinTheme theme;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - strokeWidth;

    // Background track
    final trackPaint = Paint()
      ..color = theme.fgFaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawCircle(center, r, trackPaint);

    // Progress arc
    final pct = (value / max).clamp(0.0, 1.0);
    if (pct <= 0) return;

    final arcPaint = Paint()
      ..color = theme.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      -math.pi / 2,
      2 * math.pi * pct,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FittinRingPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.max != max ||
        oldDelegate.theme != theme;
  }
}
