import 'dart:ui' as ui;
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
    this.color = Colors.blueAccent,
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

      // Draw Progress Bar
      final progress = (entry.currentSets / entry.targetSets).clamp(0.0, 1.5);
      if (progress > 0) {
        final fillWidth = barWidth * progress.clamp(0.0, 1.0);
        final progressRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(textSpace, y, fillWidth, barHeight),
          const Radius.circular(7),
        );
        
        // Gradient fill
        final gradient = ui.Gradient.linear(
          Offset(textSpace, y),
          Offset(textSpace + fillWidth, y),
          [entry.color.withValues(alpha: 0.5), entry.color],
        );
        canvas.drawRRect(
          progressRect,
          Paint()..shader = gradient,
        );
        
        // Neon outer glow
        canvas.drawRRect(
          progressRect,
          Paint()
            ..color = entry.color.withValues(alpha: 0.12 + 0.1 * progress)
            ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 5),
        );

        // White core highlight for completed bars
        if (progress >= 1.0) {
          canvas.drawRRect(
            progressRect,
            Paint()
              ..color = Colors.white.withValues(alpha: 0.08)
              ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 3),
          );
        }
      }

      // Draw Counter (e.g., 8/10) with emphasis
      final isComplete = entry.currentSets >= entry.targetSets;
      final counterPainter = TextPainter(
        text: TextSpan(
          text: '${entry.currentSets.toInt()}/${entry.targetSets.toInt()}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isComplete 
                ? entry.color.withValues(alpha: 0.9) 
                : Colors.white.withValues(alpha: 0.35),
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
