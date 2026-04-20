import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';

/// StepChart — stepped/linear/smooth/area variants
/// Replaces smooth red spline with data-forward stepped chart
class StepChart extends StatelessWidget {
  const StepChart(
    this.theme,
    this.data, {
    super.key,
    this.width = 300,
    this.height = 120,
    this.showDots = true,
    this.showGrid = true,
    this.yLabels,
  });

  final FittinTheme theme;
  final List<double> data;
  final double width;
  final double height;
  final bool showDots;
  final bool showGrid;
  final List<String>? yLabels;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return SizedBox(width: width, height: height);

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _StepChartPainter(
          data: data,
          theme: theme,
          showDots: showDots,
          showGrid: showGrid,
          yLabels: yLabels,
        ),
      ),
    );
  }
}

class _StepChartPainter extends CustomPainter {
  _StepChartPainter({
    required this.data,
    required this.theme,
    required this.showDots,
    required this.showGrid,
    this.yLabels,
  });

  final List<double> data;
  final FittinTheme theme;
  final bool showDots;
  final bool showGrid;
  final List<String>? yLabels;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const pad = 8.0;
    final innerW = size.width - pad * 2;
    final innerH = size.height - pad * 2;

    final maxVal = data.reduce(math.max);
    final minVal = data.reduce(math.min);
    final range = (maxVal - minVal).abs() < 0.001 ? 1.0 : maxVal - minVal;

    double xFor(int i) => pad + (data.length <= 1 ? innerW / 2 : i / (data.length - 1)) * innerW;
    double yFor(double v) => pad + innerH - ((v - minVal) / range) * innerH;

    // Grid lines at 0%, 33%, 66%, 100%
    if (showGrid) {
      final gridPaint = Paint()
        ..color = theme.chartGrid
        ..strokeWidth = 0.5;

      for (final t in [0.0, 0.33, 0.66, 1.0]) {
        final y = pad + innerH * t;
        canvas.drawLine(Offset(pad, y), Offset(size.width - pad, y), gridPaint);
      }

      // Y-axis labels
      if (yLabels != null) {
        for (var i = 0; i < yLabels!.length; i++) {
          final t = i / (yLabels!.length - 1);
          final y = pad + innerH * t + 4;
          final textPainter = TextPainter(
            text: TextSpan(
              text: yLabels![i],
              style: TextStyle(
                color: theme.fgMuted,
                fontSize: 9,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(canvas, Offset(4, y - 4));
        }
      }
    }

    // Build path based on chart style
    final path = Path();
    final style = theme.chartStyle;

    for (var i = 0; i < data.length; i++) {
      final px = xFor(i);
      final py = yFor(data[i]);

      if (i == 0) {
        path.moveTo(px, py);
      } else {
        final prevPx = xFor(i - 1);
        final prevPy = yFor(data[i - 1]);

        if (style == FittinChartStyle.linear) {
          path.lineTo(px, py);
        } else if (style == FittinChartStyle.smooth) {
          // Catmull-Rom-like smooth curve
          final cpX = prevPx + (px - prevPx) / 2;
          path.cubicTo(cpX, prevPy, cpX, py, px, py);
        } else {
          // Step (default): horizontal, then vertical, then horizontal
          final midX = prevPx + (px - prevPx) / 2;
          path.lineTo(midX, prevPy);
          path.lineTo(midX, py);
          path.lineTo(px, py);
        }
      }
    }

    // Area fill for 'area' style
    if (style == FittinChartStyle.area) {
      final areaPath = Path.from(path)
        ..lineTo(xFor(data.length - 1), size.height - pad)
        ..lineTo(xFor(0), size.height - pad)
        ..close();
      canvas.drawPath(
        areaPath,
        Paint()..color = theme.chartStroke.withValues(alpha: 0.1),
      );
    }

    // Draw line
    canvas.drawPath(
      path,
      Paint()
        ..color = theme.chartStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.square
        ..strokeJoin = StrokeJoin.miter,
    );

    // Draw dots at first, middle, last
    if (showDots) {
      final dotIndices = <int>[];
      if (data.length == 1) {
        dotIndices.add(0);
      } else {
        dotIndices.add(0);
        dotIndices.add(data.length ~/ 2);
        dotIndices.add(data.length - 1);
      }

      for (final i in dotIndices) {
        final px = xFor(i);
        final py = yFor(data[i]);

        // bg-colored center to create "ring" effect
        canvas.drawCircle(
          Offset(px, py),
          2.5,
          Paint()..color = theme.bg,
        );
        canvas.drawCircle(
          Offset(px, py),
          2.5,
          Paint()
            ..color = theme.chartDot
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StepChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.theme != theme;
  }
}

/// Compact sparkline — line only, no dots, no grid
class Sparkline extends StatelessWidget {
  const Sparkline(
    this.theme,
    this.data, {
    super.key,
    this.width = 80,
    this.height = 24,
  });

  final FittinTheme theme;
  final List<double> data;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return SizedBox(width: width, height: height);
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _StepChartPainter(
          data: data,
          theme: theme,
          showDots: false,
          showGrid: false,
        ),
      ),
    );
  }
}
