import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';

/// A fixed/adjustable dumbbell, deliberately not a barbell plate prescription.
class DumbbellWeightPreview extends StatelessWidget {
  const DumbbellWeightPreview({
    super.key,
    required this.theme,
    required this.weight,
    required this.unit,
    required this.perHand,
    required this.isChinese,
  });
  final FittinTheme theme;
  final double weight;
  final String unit;
  final bool perHand;
  final bool isChinese;

  @override
  Widget build(BuildContext context) {
    final value = weight.toStringAsFixed(
      weight == weight.roundToDouble() ? 0 : 1,
    );
    final label = perHand
        ? (isChinese ? '每只哑铃' : 'PER DUMBBELL')
        : (isChinese ? '合计负重' : 'COMBINED LOAD');
    final displayUnit = unit == 'lbs' ? 'lb' : unit;
    return Semantics(
      key: const ValueKey('dumbbell-weight-preview'),
      label: '$label $value $displayUnit',
      child: LayoutBuilder(
        builder: (context, constraints) {
          return FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: 240,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 0,
                    left: 20,
                    right: 20,
                    height: 64,
                    child: CustomPaint(painter: _DumbbellPainter(theme)),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Text(
                      '$value $displayUnit · $label',
                      style: theme.uiStyle(12, theme.fgDim, FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DumbbellPainter extends CustomPainter {
  _DumbbellPainter(this.theme);
  final FittinTheme theme;
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: size.width * .55, height: 12),
        const Radius.circular(5),
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.fgMuted, theme.fg, theme.fgMuted],
        ).createShader(Rect.fromLTWH(0, center.dy - 6, size.width, 12)),
    );
    for (var i = -5; i <= 5; i++) {
      canvas.drawLine(
        Offset(center.dx + i * 5, center.dy - 4),
        Offset(center.dx + i * 5 - 3, center.dy + 4),
        Paint()
          ..color = theme.bg.withValues(alpha: .3)
          ..strokeWidth = 1,
      );
    }
    for (final x in [size.width * .25, size.width * .75]) {
      final path = Path();
      for (var i = 0; i < 6; i++) {
        final angle = math.pi / 3 * i + math.pi / 6;
        final point = Offset(
          x + math.cos(angle) * 26,
          center.dy + math.sin(angle) * 28,
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [theme.surfaceHi, theme.surface],
          ).createShader(path.getBounds()),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = theme.fgMuted
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      canvas.drawCircle(
        Offset(x, center.dy),
        13,
        Paint()..color = theme.accent.withValues(alpha: .16),
      );
      canvas.drawCircle(Offset(x, center.dy), 5, Paint()..color = theme.accent);
    }
  }

  @override
  bool shouldRepaint(covariant _DumbbellPainter oldDelegate) =>
      oldDelegate.theme != theme;
}
