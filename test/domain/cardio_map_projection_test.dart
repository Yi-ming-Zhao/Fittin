import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/domain/cardio_map_projection.dart';
import 'package:fittin_v2/src/domain/models/cardio_recording.dart';

RoutePoint point(
  double lon,
  double lat, {
  int segment = 0,
  String system = 'WGS84',
}) => RoutePoint(
  latitude: lat,
  longitude: lon,
  timestamp: DateTime.utc(2026),
  segment: segment,
  coordinateSystem: system,
);

void main() {
  test(
    'AMap scale=1 pixel calibration matches provider-drawn reference path',
    () {
      final route = [
        point(116.39, 39.9),
        point(116.394, 39.904),
        point(116.4, 39.903),
        point(116.404, 39.907),
      ];
      final view = CardioMapViewport.fit(route);
      expect(view.zoom, 14);
      expect(view.project(route.first).x, closeTo(136.8112, .01));
      expect(view.project(route.first).y, closeTo(286.4002, .01));
    },
  );
  test('display conversion matches reference and does not offset London', () {
    final gcj = cardioMapCoordinate(116.404, 39.915);
    expect(gcj.x, closeTo(116.41024449916938, 1e-8));
    expect(gcj.y, closeTo(39.91640428150164, 1e-8));
    expect(cardioMapCoordinate(-.12, 51.5).x, -.12);
    expect(cardioMapCoordinate(-.12, 51.5).y, 51.5);
  });
  test('map center, zoom and fitted bounds use the same projection', () {
    final route = [point(116.39, 39.9), point(116.41, 39.92)];
    final view = CardioMapViewport.fit(route);
    expect(view.project(view.center).x, 300);
    expect(view.project(view.center).y, 180);
    for (final p in route) {
      final xy = view.project(p);
      expect(xy.x, inInclusiveRange(42, 558));
      expect(xy.y, inInclusiveRange(42, 318));
    }
    final zoom = CardioMapViewport(center: view.center, zoom: view.zoom + 1);
    expect(
      zoom.project(route.first).x - 300,
      closeTo(2 * (view.project(route.first).x - 300), 1e-8),
    );
  });
  test(
    'gaps and invalid coordinate systems do not create connecting lines',
    () {
      final route = [
        point(116.4, 39.9),
        point(116.401, 39.9),
        point(116.402, 39.9, segment: 1),
        point(116.403, 39.9, system: 'BD09'),
        point(116.404, 39.9, segment: 1),
      ];
      final view = CardioMapViewport.fit(route);
      expect(view.segments(route).map((s) => s.length), [2, 1, 1]);
      expect(() => view.project(route[3]), throwsFormatException);
    },
  );
  test('antimeridian uses short span and single point fits safely', () {
    final route = [point(179.999, 20), point(-179.999, 20)];
    final view = CardioMapViewport.fit(route);
    expect(
      (view.project(route[0]).x - view.project(route[1]).x).abs(),
      lessThan(516),
    );
    expect(view.zoom, greaterThan(10));
    expect(CardioMapViewport.fit([route.first]).zoom, 17);
    expect(() => CardioMapViewport.fit([]), throwsFormatException);
  });
}
