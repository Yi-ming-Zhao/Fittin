import 'dart:math';
import 'package:flutter/material.dart';

class StrengthLevelRing extends StatelessWidget {
  final double percentage; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color baseColor;
  final Color activeColor;

  const StrengthLevelRing({
    super.key,
    required this.percentage,
    this.size = 120,
    this.strokeWidth = 12,
    this.baseColor = Colors.white12,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StrengthRingPainter(
          percentage: percentage,
          strokeWidth: strokeWidth,
          baseColor: baseColor,
          activeColor: activeColor,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(percentage * 100).toInt()}%',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Overall Level',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StrengthRingPainter extends CustomPainter {
  final double percentage;
  final double strokeWidth;
  final Color baseColor;
  final Color activeColor;

  _StrengthRingPainter({
    required this.percentage,
    required this.strokeWidth,
    required this.baseColor,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - strokeWidth) / 2;

    // Draw background track
    final trackPaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawCircle(center, radius, trackPaint);

    if (percentage <= 0.0) return;

    // Clean arc — no glow, thin accent stroke
    final rect = Rect.fromCircle(center: center, radius: radius);
    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * percentage,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _StrengthRingPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
