import 'package:flutter/material.dart';

class MuscleVolumeData {
  final String label;
  final double currentSets;
  final double targetSets;
  final Color color;

  MuscleVolumeData({
    required this.label,
    required this.currentSets,
    required this.targetSets,
    this.color = const Color(0xFF999933),
  });
}

class MuscleDistributionPainter extends CustomPainter {
  final List<MuscleVolumeData> data;

  MuscleDistributionPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const barHeight = 14.0;
    const spacing = 26.0;
    const textSpace = 90.0;

    final labelStyle = const TextStyle(
      color: Colors.white54,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );

    for (int i = 0; i < data.length; i++) {
      final entry = data[i];
      final y = i * (barHeight + spacing);

      // Draw Label
      final textPainter = TextPainter(
        text: TextSpan(text: entry.label.toUpperCase(), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(0, y + 1));

      // Draw Background Bar (subtle glass)
      final barWidth = size.width - textSpace - 40;
      final barRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(textSpace, y, barWidth, barHeight),
        const Radius.circular(7),
      );
      canvas.drawRRect(
        barRect,
        Paint()..color = Colors.white.withValues(alpha: 0.04),
      );

      // Muted categorical color, kept flat so magnitude remains the focus.
      final progress = (entry.currentSets / entry.targetSets).clamp(0.0, 1.5);
      if (progress > 0) {
        final fillWidth = barWidth * progress.clamp(0.0, 1.0);
        final progressRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(textSpace, y, fillWidth, barHeight),
          const Radius.circular(7),
        );

        canvas.drawRRect(
          progressRect,
          Paint()..color = entry.color.withValues(alpha: 0.78),
        );
      }

      // Show the actual weighted completed-set contribution. The bar itself is
      // normalized to the highest muscle in the displayed period.
      final formattedSets =
          entry.currentSets == entry.currentSets.roundToDouble()
          ? entry.currentSets.toStringAsFixed(0)
          : entry.currentSets.toStringAsFixed(1);
      final counterPainter = TextPainter(
        text: TextSpan(
          text: formattedSets,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: entry.color.withValues(alpha: 0.9),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      counterPainter.paint(
        canvas,
        Offset(size.width - counterPainter.width, y + 1),
      );
    }
  }

  @override
  bool shouldRepaint(covariant MuscleDistributionPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
