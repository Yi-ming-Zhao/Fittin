import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:fittin_v2/src/data/cardio_online_map.dart';
import 'package:fittin_v2/src/domain/models/cardio_recording.dart';

void main() {
  final key = 'a' * 32;
  final point = RoutePoint(
    latitude: 39.9,
    longitude: 116.4,
    timestamp: DateTime.utc(2026),
  );
  test('converts WGS84 then displays one point, never sends a route', () async {
    final requests = <http.Request>[];
    final service = CardioOnlineMap(
      clientFactory: () => MockClient((request) async {
        requests.add(request);
        expect(request.url.scheme, 'https');
        expect(request.url.host, 'restapi.amap.com');
        expect(request.followRedirects, isFalse);
        if (requests.length == 1) {
          expect(request.url.queryParameters['coordsys'], 'gps');
          expect(request.url.queryParameters['locations'], '116.4,39.9');
          return http.Response(
            jsonEncode({'status': '1', 'locations': '116.406,39.901'}),
            200,
          );
        }
        expect(request.url.queryParameters['location'], '116.406,39.901');
        expect(request.url.queryParameters.containsKey('paths'), isFalse);
        return http.Response.bytes(
          [137, 80, 78, 71],
          200,
          headers: {'content-type': 'image/png'},
        );
      }),
    );
    expect(await service.load(key: key, point: point), [137, 80, 78, 71]);
    expect(requests, hasLength(2));
  });
  test('invalid key or coordinates make no request', () async {
    final service = CardioOnlineMap(
      clientFactory: () => throw StateError('unexpected network'),
    );
    await expectLater(
      service.load(key: 'invalid', point: point),
      throwsA(isA<CardioMapUnavailable>()),
    );
    await expectLater(
      service.load(
        key: key,
        point: RoutePoint(
          latitude: 91,
          longitude: 0,
          timestamp: point.timestamp,
        ),
      ),
      throwsA(isA<CardioMapUnavailable>()),
    );
  });
  for (final code in [302, 401, 429, 500]) {
    test('HTTP $code is redacted and not retried', () async {
      var calls = 0;
      final service = CardioOnlineMap(
        clientFactory: () => MockClient((_) async {
          calls++;
          return http.Response(
            key,
            code,
            headers: {'location': 'https://example.invalid/$key'},
          );
        }),
      );
      await expectLater(
        service.load(key: key, point: point),
        throwsA(
          predicate((error) => error.toString() == 'Online map unavailable'),
        ),
      );
      expect(calls, 1);
    });
  }
  test('owner change cancels before second provider request', () async {
    var calls = 0;
    final service = CardioOnlineMap(
      clientFactory: () => MockClient((_) async {
        calls++;
        return http.Response('{"status":"1","locations":"116.4,39.9"}', 200);
      }),
    );
    await expectLater(
      service.load(key: key, point: point, isCurrent: () => false),
      throwsA(isA<CardioMapUnavailable>()),
    );
    expect(calls, 1);
  });
  test(
    'provider quota JSON and excessive responses are not shown as map',
    () async {
      for (final large in [false, true]) {
        var calls = 0;
        final service = CardioOnlineMap(
          clientFactory: () => MockClient((_) async {
            if (++calls == 1) {
              return http.Response(
                '{"status":"1","locations":"116.4,39.9"}',
                200,
              );
            }
            return http.Response(
              large ? 'a' * (2 * 1024 * 1024 + 1) : '{"error":"$key"}',
              200,
              headers: {
                'content-type': large ? 'image/png' : 'application/json',
              },
            );
          }),
        );
        await expectLater(
          service.load(key: key, point: point),
          throwsA(isA<CardioMapUnavailable>()),
        );
      }
    },
  );
}
