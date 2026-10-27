import 'package:flutter/material.dart';
import '../../domain/cardio_map_projection.dart';
import '../../domain/models/cardio_recording.dart';

class CardioMapRouteOverlay extends StatelessWidget {
  const CardioMapRouteOverlay({
    super.key,
    required this.viewport,
    required this.points,
  });
  final CardioMapViewport viewport;
  final List<RoutePoint> points;
  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: CustomPaint(
      painter: _MapRoutePainter(
        viewport,
        points,
        Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}

class _MapRoutePainter extends CustomPainter {
  _MapRoutePainter(this.viewport, this.points, this.color);
  final CardioMapViewport viewport;
  final List<RoutePoint> points;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.scale(
      size.width / CardioMapViewport.width,
      size.height / CardioMapViewport.height,
    );
    final segments = viewport.segments(points);
    final path = Path();
    for (final segment in segments) {
      for (var i = 0; i < segment.length; i++) {
        final p = segment[i];
        if (i == 0) {
          path.moveTo(p.x, p.y);
        } else {
          path.lineTo(p.x, p.y);
        }
      }
    }
    final pen = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      path,
      pen
        ..color = Colors.white
        ..strokeWidth = 10,
    );
    canvas.drawPath(
      path,
      pen
        ..color = color
        ..strokeWidth = 6,
    );
    if (segments.isNotEmpty) {
      void marker(Offset point, String label) {
        canvas.drawCircle(point, 19, Paint()..color = Colors.white);
        canvas.drawCircle(point, 16, Paint()..color = color);
        final text = TextPainter(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color:
                  ThemeData.estimateBrightnessForColor(color) == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        text.paint(canvas, point - Offset(text.width / 2, text.height / 2));
      }

      final first = segments.first.first, last = segments.last.last;
      marker(Offset(first.x, first.y), 'S');
      marker(Offset(last.x, last.y), 'E');
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MapRoutePainter old) =>
      old.viewport != viewport || old.points != points || old.color != color;
}
