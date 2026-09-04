@TestOn('browser')
library;

import 'dart:convert';

import 'package:fittin_v2/src/application/auth_http_client.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/auth_session_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Web auth client includes HttpOnly refresh cookies', () {
    final client = createAuthHttpClient();
    addTearDown(client.close);

    expect(client, isA<BrowserClient>());
    expect((client as BrowserClient).withCredentials, isTrue);
  });

  test('Web store persists only a refresh-cookie marker', () async {
    SharedPreferences.setMockInitialValues(const {});
    final preferences = await SharedPreferences.getInstance();
    final store = PlatformAuthSessionStore(preferences);

    await store.saveRefreshToken('plaintext-refresh-secret');

    expect(await store.loadRefreshToken(), webRefreshCookieMarker);
    expect(
      preferences.getString('fittin.auth.refreshToken'),
      webRefreshCookieMarker,
    );
    expect(
      preferences.getKeys().map(preferences.get),
      isNot(contains('plaintext-refresh-secret')),
    );
  });

  test('legacy Web access token bootstraps the cookie session', () async {
    SharedPreferences.setMockInitialValues({
      'fittin.auth.accessToken': 'legacy-access',
      'fittin.auth.userId': 'legacy-user',
      'fittin.auth.userEmail': 'legacy@example.test',
    });
    final preferences = await SharedPreferences.getInstance();
    final store = PlatformAuthSessionStore(preferences);
    late http.Request captured;
    final repository = BackendAuthRepository(
      baseUrl: 'https://api.example.test',
      sessionStore: store,
      httpClient: MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'accessToken': 'short-access',
            'hasRefreshToken': true,
            'user': {'id': 'legacy-user', 'email': 'legacy@example.test'},
          }),
          200,
        );
      }),
    );

    expect((await repository.currentUser())?.id, 'legacy-user');
    expect(captured.url.path, '/v1/auth/session');
    expect(captured.headers['x-fittin-auth-platform'], 'web');
    expect(captured.headers['authorization'], 'Bearer legacy-access');
    expect(await store.loadAccessToken(), 'short-access');
    expect(await store.loadRefreshToken(), webRefreshCookieMarker);
  });

  test('Web refresh sends no credential in JSON or local storage', () async {
    SharedPreferences.setMockInitialValues({
      'fittin.auth.accessToken': 'expired-access',
      'fittin.auth.refreshToken': webRefreshCookieMarker,
      'fittin.auth.userId': 'user-1',
    });
    final preferences = await SharedPreferences.getInstance();
    final store = PlatformAuthSessionStore(preferences);
    late http.Request captured;
    final repository = BackendAuthRepository(
      baseUrl: 'https://api.example.test',
      sessionStore: store,
      httpClient: MockClient((request) async {
        captured = request;
        return http.Response(
          '{"accessToken":"fresh-access","hasRefreshToken":true,'
          '"user":{"id":"user-1"}}',
          200,
        );
      }),
    );

    expect(
      await repository.refreshAccessToken(failedAccessToken: 'expired-access'),
      'fresh-access',
    );
    expect(captured.url.path, '/v1/auth/refresh');
    expect(captured.headers['x-fittin-auth-platform'], 'web');
    expect(jsonDecode(captured.body), isEmpty);
    expect(await store.loadRefreshToken(), webRefreshCookieMarker);
  });
}
