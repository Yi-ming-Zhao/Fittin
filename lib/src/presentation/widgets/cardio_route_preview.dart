import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/cardio_recording_provider.dart';
import '../../domain/models/cardio_recording.dart';

/// Offline route overview, not a map: gaps are never joined. Online map loading
/// must not own the position stream or affect recording persistence.
class CardioRoutePreview extends ConsumerStatefulWidget {
  const CardioRoutePreview({
    super.key,
    required this.session,
    required this.chinese,
  });
  final CardioRecordingSession session;
  final bool chinese;
  @override
  ConsumerState<CardioRoutePreview> createState() => _CardioRoutePreviewState();
}

class _CardioRoutePreviewState extends ConsumerState<CardioRoutePreview> {
  final List<RoutePoint> _points = [];
  int _chunks = 0;
  bool _loading = false, _failed = false, _reload = false;
  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    if (!mounted) return;
    if (_loading) {
      _reload = true;
      return;
    }
    _loading = true;
    try {
      final store = ref.read(cardioRecordingStoreProvider);
      await for (final chunk in store.route(
        widget.session.id,
        ownerUserId: widget.session.ownerUserId,
        fromChunk: _chunks,
      )) {
        if (!mounted) return;
        _points.addAll(chunk);
        _chunks++;
        // Decimate display geometry only. Full fidelity data stays in storage.
        if (_points.length > 4000) {
          final reduced = <RoutePoint>[];
          for (var i = 0; i < _points.length; i++) {
            if (i == 0 ||
                i == _points.length - 1 ||
                i.isEven ||
                _points[i].segment != _points[i - 1].segment ||
                _points[i].segment != _points[i + 1].segment) {
              reduced.add(_points[i]);
            }
          }
          _points
            ..clear()
            ..addAll(reduced);
        }
      }
      _failed = false;
    } catch (_) {
      _failed = true;
    } finally {
      _loading = false;
      if (mounted) setState(() {});
      if (_reload && mounted) {
        _reload = false;
        await _load();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(localCardioSessionsProvider, (_, __) => _load());
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: widget.chinese
          ? '本机路线示意图，定位中断处断开'
          : 'Local route overview; location gaps are separated',
      child: Container(
        height: 180,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            if (_points.length >= 2)
              Positioned.fill(
                child: CustomPaint(
                  painter: _RoutePainter(
                    List.of(_points),
                    colors.primary,
                    colors.onSurfaceVariant,
                  ),
                ),
              )
            else
              Center(
                child: Text(
                  _failed
                      ? (widget.chinese ? '路线暂不可读取' : 'Route unavailable')
                      : (widget.chinese
                            ? '等待已保存的路线'
                            : 'Waiting for saved route'),
                ),
              ),
            Positioned(
              left: 14,
              bottom: 12,
              child: Text(
                widget.chinese
                    ? '本机路线 · 非在线地图'
                    : 'Local route · offline overview',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  _RoutePainter(this.points, this.color, this.markerColor);
  final List<RoutePoint> points;
  final Color color, markerColor;
  @override
  void paint(Canvas canvas, Size size) {
    final cosine = math.cos(points.first.latitude * math.pi / 180);
    final coords = points
        .map((p) => Offset(p.longitude * cosine, -p.latitude))
        .toList();
    final minX = coords.map((p) => p.dx).reduce(math.min),
        maxX = coords.map((p) => p.dx).reduce(math.max);
    final minY = coords.map((p) => p.dy).reduce(math.min),
        maxY = coords.map((p) => p.dy).reduce(math.max);
    final scale = math.min(
      (size.width - 48) / math.max(maxX - minX, .00001),
      (size.height - 64) / math.max(maxY - minY, .00001),
    );
    final offset = Offset(
      (size.width - (maxX - minX) * scale) / 2,
      (size.height - 24 - (maxY - minY) * scale) / 2,
    );
    Offset point(int i) =>
        Offset((coords[i].dx - minX) * scale, (coords[i].dy - minY) * scale) +
        offset;
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final p = point(i);
      if (i == 0 || points[i].segment != points[i - 1].segment) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(point(0), 4, Paint()..color = markerColor);
    canvas.drawCircle(point(points.length - 1), 5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_RoutePainter old) =>
      old.points.length != points.length ||
      old.points.last.timestamp != points.last.timestamp ||
      old.color != color;
}
