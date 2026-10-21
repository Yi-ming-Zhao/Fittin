import 'dart:convert';
import 'package:fittin_v2/src/data/remote/supabase_remote_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  String token(String owner) =>
      'header.${base64Url.encode(utf8.encode(jsonEncode({'sub': owner})))}.signature';
  test(
    'route transfer rejects a switched account token before sending location',
    () async {
      var calls = 0;
      final repository = SupabaseRemoteRepository.http(
        baseUrl: 'https://fittin.test',
        accessTokenLoader: () async => token('bob'),
        httpClient: MockClient((_) async {
          calls++;
          return http.Response('{}', 200);
        }),
      );
      await expectLater(
        repository.privateRouteRequest(
          method: 'PUT',
          id: 'cardio-record:11111111-1111-4111-8111-111111111111',
          suffix: 'manifest',
          expectedOwner: 'alice',
          body: '{}',
        ),
        throwsA(isA<RemoteRepositoryException>()),
      );
      expect(calls, 0);
    },
  );
  test(
    'route refresh rejects a new owner before the authenticated retry',
    () async {
      var calls = 0;
      final repository = SupabaseRemoteRepository.http(
        baseUrl: 'https://fittin.test',
        accessTokenLoader: () async => token('alice'),
        accessTokenRefresher: (_) async => token('bob'),
        httpClient: MockClient((_) async {
          calls++;
          return http.Response('{}', 401);
        }),
      );
      await expectLater(
        repository.privateRouteRequest(
          method: 'GET',
          id: 'cardio-record:11111111-1111-4111-8111-111111111111',
          suffix: 'manifest',
          expectedOwner: 'alice',
        ),
        throwsA(isA<RemoteRepositoryException>()),
      );
      expect(calls, 1);
    },
  );
}
