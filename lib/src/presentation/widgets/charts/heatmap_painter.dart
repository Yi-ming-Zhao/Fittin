import 'package:flutter/material.dart';

class HeatmapPainter extends CustomPainter {
  final Map<DateTime, double> activityData; // Date -> Intensity (0..1)
  final Color activeColor;
  final int daysToShow;

  HeatmapPainter({
    required this.activityData,
    this.activeColor = Colors.greenAccent,
    this.daysToShow = 91, // 13 weeks
  });

  @override
  void paint(Canvas canvas, Size size) {
    const columns = 13;
    const rows = 7;
    const spacing = 3.0;
    
    final itemWidth = (size.width - (columns - 1) * spacing) / columns;
    final itemHeight = (size.height - (rows - 1) * spacing) / rows;
    final double side = itemWidth < itemHeight ? itemWidth : itemHeight;
    final cornerRadius = side * 0.2;

    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: daysToShow - 1));

    final basePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < daysToShow; i++) {
      final date = startDate.add(Duration(days: i));
      final col = i ~/ 7;
      final row = i % 7;

      final x = col * (side + spacing);
      final y = row * (side + spacing);

      final cleanDate = DateTime(date.year, date.month, date.day);
      final intensity = activityData[cleanDate] ?? 0.0;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, side, side),
        Radius.circular(cornerRadius),
      );

      if (intensity > 0) {
        // Base cell fill with intensity-driven opacity
        final activePaint = Paint()
          ..color = activeColor.withValues(alpha: 0.15 + 0.85 * intensity.clamp(0.0, 1.0))
          ..style = PaintingStyle.fill;
        canvas.drawRRect(rect, activePaint);
        
        // Neon outer glow for active days
        if (intensity > 0.4) {
          canvas.drawRRect(
            rect,
            Paint()
              ..color = activeColor.withValues(alpha: 0.15 * intensity)
              ..maskFilter = MaskFilter.blur(BlurStyle.outer, 3.0 + intensity * 3.0),
          );
        }

        // Inner ember glow for peak days
        if (intensity > 0.8) {
          canvas.drawRRect(
            rect,
            Paint()
              ..color = Colors.white.withValues(alpha: 0.15)
              ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 2),
          );
        }
      } else {
        canvas.drawRRect(rect, basePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant HeatmapPainter oldDelegate) {
    return oldDelegate.activityData != activityData;
  }
}
