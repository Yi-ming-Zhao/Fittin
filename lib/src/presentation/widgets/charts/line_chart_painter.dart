import 'package:flutter/material.dart';

class LineChartDataset {
  final List<Offset> points; // Normalized 0..1 relative to the chart area
  final Color color;
  final String label;

  LineChartDataset({
    required this.points,
    required this.color,
    required this.label,
  });
}

class LineChartPainter extends CustomPainter {
  final List<LineChartDataset> datasets;
  final int horizontalGridLines;
  final int verticalGridLines;
  final bool showGlow;

  LineChartPainter({
    required this.datasets,
    this.horizontalGridLines = 5,
    this.verticalGridLines = 4,
    this.showGlow = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (datasets.isEmpty) return;

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;
 
    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..strokeWidth = 1;
 
    // Draw horizontal grid lines
    for (int i = 0; i <= horizontalGridLines; i++) {
      final y = size.height * (i / horizontalGridLines);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), i % 2 == 0 ? gridPaint : dashPaint);
    }
 
    for (final dataset in datasets) {
      if (dataset.points.isEmpty) continue;
 
      final path = Path();
 
      for (int i = 0; i < dataset.points.length; i++) {
        final point = dataset.points[i];
        final x = point.dx * size.width;
        final y = (1 - point.dy) * size.height;
 
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          final prevPoint = dataset.points[i - 1];
          final prevX = prevPoint.dx * size.width;
          final prevY = (1 - prevPoint.dy) * size.height;
 
          final controlPoint1 = Offset(prevX + (x - prevX) / 2, prevY);
          final controlPoint2 = Offset(prevX + (x - prevX) / 2, y);
 
          path.cubicTo(
            controlPoint1.dx, controlPoint1.dy,
            controlPoint2.dx, controlPoint2.dy,
            x, y,
          );
        }
      }
 
      // Draw shadow/glow (Outer soft glow)
      if (showGlow) {
        canvas.drawPath(
          path,
          Paint()
            ..color = dataset.color.withValues(alpha: 0.15)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 14
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
        );
        // Inner neon glow
        canvas.drawPath(
          path,
          Paint()
            ..color = dataset.color.withValues(alpha: 0.4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }
 
      // Draw primary line
      canvas.drawPath(
        path,
        Paint()
          ..color = dataset.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
 
      // Draw data points with glow
      for (final point in dataset.points) {
        final x = point.dx * size.width;
        final y = (1 - point.dy) * size.height;
        
        // Point shadow
        canvas.drawCircle(
          Offset(x, y), 
          6, 
          Paint()..color = Colors.black.withValues(alpha: 0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)
        );
        
        // Outer ring
        canvas.drawCircle(Offset(x, y), 4.5, Paint()..color = dataset.color);
        // Inner core
        canvas.drawCircle(Offset(x, y), 2.5, Paint()..color = Colors.white);
      }
    }
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) {
    return oldDelegate.datasets != datasets;
  }
}
