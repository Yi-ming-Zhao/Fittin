import 'dart:math' as math;
import 'models/cardio_recording.dart';

/// Display-only approximate WGS84 -> GCJ02 conversion. Never used for measured
/// distance or persisted coordinates. Adapted from wandergis/coordtransform,
/// MIT, copyright (c) 2015 记忆的残骸; see assets/licenses/coordtransform.txt.
math.Point<double> cardioMapCoordinate(double longitude, double latitude) {
  if (!(longitude > 73.66 &&
      longitude < 135.05 &&
      latitude > 3.86 &&
      latitude < 53.55)) {
    return math.Point(longitude, latitude);
  }
  final x = longitude - 105, y = latitude - 35;
  final wave =
      (20 * math.sin(6 * x * math.pi) + 20 * math.sin(2 * x * math.pi)) * 2 / 3;
  var dy =
      -100 +
      2 * x +
      3 * y +
      .2 * y * y +
      .1 * x * y +
      .2 * math.sqrt(x.abs()) +
      wave;
  dy += (20 * math.sin(y * math.pi) + 40 * math.sin(y / 3 * math.pi)) * 2 / 3;
  dy +=
      (160 * math.sin(y / 12 * math.pi) + 320 * math.sin(y * math.pi / 30)) *
      2 /
      3;
  var dx =
      300 +
      x +
      2 * y +
      .1 * x * x +
      .1 * x * y +
      .1 * math.sqrt(x.abs()) +
      wave;
  dx += (20 * math.sin(x * math.pi) + 40 * math.sin(x / 3 * math.pi)) * 2 / 3;
  dx +=
      (150 * math.sin(x / 12 * math.pi) + 300 * math.sin(x / 30 * math.pi)) *
      2 /
      3;
  final radians = latitude / 180 * math.pi;
  final magic = 1 - .00669342162296594323 * math.pow(math.sin(radians), 2);
  final root = math.sqrt(magic);
  dy =
      dy *
      180 /
      ((6378245 * (1 - .00669342162296594323)) / (magic * root) * math.pi);
  dx = dx * 180 / (6378245 / root * math.cos(radians) * math.pi);
  return math.Point(longitude + dx, latitude + dy);
}

class CardioMapViewport {
  CardioMapViewport({required this.center, required this.zoom})
    : _centerWorld = _world(center);
  final RoutePoint center;
  final int zoom;
  final math.Point<double> _centerWorld;
  static const width = 600.0, height = 360.0;

  static math.Point<double> _world(RoutePoint point) {
    if (!point.isValid) {
      throw const FormatException('Unsupported map coordinate');
    }
    final p = cardioMapCoordinate(point.longitude, point.latitude);
    final sin = math.sin(p.y.clamp(-85.05112878, 85.05112878) * math.pi / 180);
    return math.Point(
      (p.x + 180) / 360,
      .5 - math.log((1 + sin) / (1 - sin)) / (4 * math.pi),
    );
  }

  math.Point<double> project(RoutePoint point) {
    final world = _world(point);
    var dx = world.x - _centerWorld.x;
    if (dx > .5) dx -= 1;
    if (dx < -.5) dx += 1;
    // AMap /v3/staticmap scale=1 uses 512 world pixels at level zero.
    // Verified against provider-rendered paths; using 256 halves the overlay.
    final scale = 512.0 * math.pow(2, zoom);
    return math.Point(
      width / 2 + dx * scale,
      height / 2 + (world.y - _centerWorld.y) * scale,
    );
  }

  List<List<math.Point<double>>> segments(List<RoutePoint> points) {
    final result = <List<math.Point<double>>>[];
    int? previous;
    for (final point in points) {
      if (!point.isValid) {
        previous = null;
        continue;
      }
      if (previous != point.segment) result.add([]);
      result.last.add(project(point));
      previous = point.segment;
    }
    return result;
  }

  factory CardioMapViewport.fit(List<RoutePoint> route, {int? zoom}) {
    final points = route.where((p) => p.isValid).toList();
    if (points.isEmpty) throw const FormatException('No valid map points');
    final anchor = points.first.longitude;
    double unwrap(double lon) => anchor + ((lon - anchor + 540) % 360) - 180;
    final longitudes = points.map((p) => unwrap(p.longitude));
    final latitudes = points.map((p) => p.latitude);
    final longitude =
        (longitudes.reduce(math.min) + longitudes.reduce(math.max)) / 2;
    final center = RoutePoint(
      latitude: (latitudes.reduce(math.min) + latitudes.reduce(math.max)) / 2,
      longitude: (longitude + 540) % 360 - 180,
      timestamp: points.last.timestamp,
    );
    if (zoom != null) {
      return CardioMapViewport(center: center, zoom: zoom.clamp(3, 17));
    }
    for (var level = 17; level >= 3; level--) {
      final viewport = CardioMapViewport(center: center, zoom: level);
      if (level == 3 ||
          points.every((p) {
            final pixel = viewport.project(p);
            return pixel.x >= 42 &&
                pixel.x <= width - 42 &&
                pixel.y >= 42 &&
                pixel.y <= height - 42;
          })) {
        return viewport;
      }
    }
    throw StateError('Map fit failed');
  }
}
