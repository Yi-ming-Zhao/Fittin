import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:fittin_v2/src/data/cardio_online_map.dart';
import 'package:fittin_v2/src/domain/models/cardio_recording.dart';

void main() {
  final point = RoutePoint(
    latitude: 39.9,
    longitude: 116.4,
    timestamp: DateTime.utc(2026),
  );
  CardioOnlineMap service(
    Future<http.Response> Function(http.Request) handler, {
    Future<String?> Function()? token,
    Future<String?> Function(String)? refresh,
  }) => CardioOnlineMap(
    backendBaseUrl: 'https://fittin.example/api',
    accessTokenLoader: token ?? () async => 'session-token',
    accessTokenRefresher: refresh,
    clientFactory: () => MockClient(handler),
  );

  test(
    'only single point to authenticated Fittin endpoint, no provider key',
    () async {
      final s = service((r) async {
        expect(r.url.toString(), 'https://fittin.example/api/v1/maps/area');
        expect(r.method, 'POST');
        expect(r.followRedirects, isFalse);
        expect(r.headers['Authorization'], 'Bearer session-token');
        expect(jsonDecode(r.body), {
          'latitude': 39.9,
          'longitude': 116.4,
          'zoom': 15,
        });
        return http.Response.bytes(
          [137, 80, 78, 71],
          200,
          headers: {'content-type': 'image/png'},
        );
      });
      expect(await s.load(point: point), [137, 80, 78, 71]);
    },
  );
  test('anonymous, invalid point and stale owner never send', () async {
    var calls = 0;
    final s = service((_) async {
      calls++;
      return http.Response('', 500);
    }, token: () async => null);
    await expectLater(
      s.load(point: point),
      throwsA(isA<CardioMapUnavailable>()),
    );
    await expectLater(
      s.load(point: point, zoom: 18),
      throwsA(isA<CardioMapUnavailable>()),
    );
    final stale = service((_) async {
      calls++;
      return http.Response('', 500);
    });
    await expectLater(
      stale.load(point: point, isCurrent: () => false),
      throwsA(isA<CardioMapUnavailable>()),
    );
    expect(calls, 0);
  });
  test('expired auth retries once with refreshed token', () async {
    var calls = 0, refreshes = 0;
    final s = service(
      (r) async {
        if (++calls == 1) return http.Response('', 401);
        expect(r.headers['Authorization'], 'Bearer refreshed');
        return http.Response.bytes(
          [1],
          200,
          headers: {'content-type': 'image/png'},
        );
      },
      refresh: (token) async {
        refreshes++;
        expect(token, 'session-token');
        return 'refreshed';
      },
    );
    expect(await s.load(point: point), [1]);
    expect(calls, 2);
    expect(refreshes, 1);
  });
  test('owner change while refreshing prevents retry', () async {
    var current = true, calls = 0;
    final s = service(
      (_) async {
        calls++;
        return http.Response('', 401);
      },
      refresh: (_) async {
        current = false;
        return 'new';
      },
    );
    await expectLater(
      s.load(point: point, isCurrent: () => current),
      throwsA(isA<CardioMapUnavailable>()),
    );
    expect(calls, 1);
  });
  for (final code in [302, 401, 429, 500]) {
    test('HTTP $code redacted', () async {
      final s = service((_) async => http.Response('sensitive error', code));
      await expectLater(
        s.load(point: point),
        throwsA(predicate((e) => e.toString() == 'Online map unavailable')),
      );
    });
  }
  test('non-images and oversized responses rejected', () async {
    for (final large in [false, true]) {
      final s = service(
        (_) async => http.Response(
          large ? 'a' * (2 * 1024 * 1024 + 1) : '{}',
          200,
          headers: {'content-type': large ? 'image/png' : 'application/json'},
        ),
      );
      await expectLater(
        s.load(point: point),
        throwsA(isA<CardioMapUnavailable>()),
      );
    }
  });
}
