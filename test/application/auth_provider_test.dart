import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/auth_session_store.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../support/fake_auth_repository.dart';

void main() {
  test('currentUserIdProvider reflects auth stream restoration', () async {
    final repository = FakeAuthRepository(
      initialUser: const AuthUser(
        id: 'restored-user',
        email: 'restored@test.dev',
      ),
    );
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final restored = await container.read(authStateProvider.future);

    expect(restored?.id, 'restored-user');
    expect(container.read(currentUserIdProvider), 'restored-user');
  });

  test('auth controller sign out delegates to repository', () async {
    final repository = FakeAuthRepository();
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container
        .read(authControllerProvider.notifier)
        .signIn(email: 'user@test.dev', password: 'password123');
    await container.read(authControllerProvider.notifier).signOut();

    expect(repository.signedOut, isTrue);
  });

  test(
    'backend auth converts socket client failures into unavailable guidance',
    () async {
      final repository = BackendAuthRepository(
        baseUrl: 'http://127.0.0.1:8081',
        sessionStore: InMemoryAuthSessionStore(),
        httpClient: MockClient((request) async {
          throw http.ClientException(
            'ClientException with SocketException: Connection refused',
            request.url,
          );
        }),
      );

      await expectLater(
        repository.signIn(email: 'user@test.dev', password: 'password123'),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            backendUnavailableMessage,
          ),
        ),
      );
    },
  );

  test('HTML gateway failures become an unavailable message', () async {
    final repository = BackendAuthRepository(
      baseUrl: 'https://api.example.test',
      sessionStore: InMemoryAuthSessionStore(),
      httpClient: MockClient(
        (request) async => http.Response(
          '<html><h1>502 Bad Gateway</h1></html>',
          502,
          headers: {'content-type': 'text/html'},
        ),
      ),
    );

    await expectLater(
      repository.signIn(email: 'user@test.dev', password: 'password123'),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          backendUnavailableMessage,
        ),
      ),
    );
  });

  test('sign-in normalizes email before sending it to the backend', () async {
    Map<String, dynamic>? requestBody;
    final repository = BackendAuthRepository(
      baseUrl: 'https://api.example.test',
      sessionStore: InMemoryAuthSessionStore(),
      httpClient: MockClient((request) async {
        requestBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          '{"accessToken":"token","user":{"id":"user-1","email":"person@example.com"}}',
          200,
        );
      }),
    );

    await repository.signIn(
      email: '  Person@Example.COM ',
      password: 'existing-password',
    );

    expect(requestBody?['email'], 'person@example.com');
  });

  test('sign-up rejects short passwords before a network request', () async {
    var requests = 0;
    final repository = BackendAuthRepository(
      baseUrl: 'https://api.example.test',
      sessionStore: InMemoryAuthSessionStore(),
      httpClient: MockClient((request) async {
        requests += 1;
        return http.Response('{}', 500);
      }),
    );

    await expectLater(
      repository.signUp(email: 'person@example.com', password: 'short'),
      throwsA(isA<StateError>()),
    );
    expect(requests, 0);
  });

  test('auth controller removes the Bad state prefix', () async {
    final controller = AuthController(
      UnavailableAuthRepository('Authentication is temporarily unavailable.'),
    );
    addTearDown(controller.dispose);

    final success = await controller.signIn(
      email: 'user@test.dev',
      password: 'password123',
    );

    expect(success, isFalse);
    expect(
      controller.state.errorMessage,
      'Authentication is temporarily unavailable.',
    );
  });

  test('session restore is single-flight across concurrent callers', () async {
    final store = InMemoryAuthSessionStore();
    await store.saveAccessToken('stored-token');
    final response = Completer<http.Response>();
    var requestCount = 0;
    final repository = BackendAuthRepository(
      baseUrl: 'https://api.example.test',
      sessionStore: store,
      httpClient: MockClient((request) {
        requestCount += 1;
        return response.future;
      }),
    );

    final first = repository.currentUser();
    final second = repository.currentUser();
    await Future<void>.delayed(Duration.zero);

    expect(requestCount, 1);
    response.complete(
      http.Response(
        '{"accessToken":"stored-token","user":{"id":"user-1","email":"user@example.test"}}',
        200,
      ),
    );

    expect((await first)?.id, 'user-1');
    expect((await second)?.id, 'user-1');
    expect(requestCount, 1);
  });

  test(
    'transient session restore failures preserve the stored token',
    () async {
      final store = InMemoryAuthSessionStore();
      await store.saveAccessToken('stored-token');
      final repository = BackendAuthRepository(
        baseUrl: 'https://api.example.test',
        sessionStore: store,
        httpClient: MockClient((request) async => http.Response('', 503)),
      );

      await expectLater(repository.currentUser(), throwsA(isA<StateError>()));

      expect(await store.loadAccessToken(), 'stored-token');
    },
  );

  test(
    'transient session restore keeps the cached user scope available',
    () async {
      final store = InMemoryAuthSessionStore();
      await store.saveAccessToken('stored-token');
      await store.saveCachedUser(
        const CachedAuthUser(id: 'offline-user', email: 'offline@example.test'),
      );
      final repository = BackendAuthRepository(
        baseUrl: 'https://api.example.test',
        sessionStore: store,
        httpClient: MockClient((request) async => http.Response('', 503)),
      );

      final user = await repository.currentUser();

      expect(user?.id, 'offline-user');
      expect(await store.loadAccessToken(), 'stored-token');
    },
  );

  test(
    'legacy JWT restores its user scope during an offline upgrade',
    () async {
      String segment(Map<String, Object> value) =>
          base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
      final token =
          '${segment({'alg': 'HS256', 'typ': 'JWT'})}.'
          '${segment({'sub': 'legacy-user', 'email': 'legacy@example.test'})}.'
          'signature';
      final store = InMemoryAuthSessionStore();
      await store.saveAccessToken(token);
      final repository = BackendAuthRepository(
        baseUrl: 'https://api.example.test',
        sessionStore: store,
        httpClient: MockClient((request) async => http.Response('', 503)),
      );

      final user = await repository.currentUser();

      expect(user?.id, 'legacy-user');
      expect((await store.loadCachedUser())?.id, 'legacy-user');
    },
  );

  test('unauthorized session restore clears the stored token', () async {
    final store = InMemoryAuthSessionStore();
    await store.saveAccessToken('expired-token');
    await store.saveCachedUser(const CachedAuthUser(id: 'expired-user'));
    final repository = BackendAuthRepository(
      baseUrl: 'https://api.example.test',
      sessionStore: store,
      httpClient: MockClient((request) async => http.Response('', 401)),
    );

    expect(await repository.currentUser(), isNull);
    expect(await store.loadAccessToken(), isNull);
    expect(await store.loadCachedUser(), isNull);
  });

  test('sign-in negotiates refresh v2 and persists native refresh', () async {
    final store = InMemoryAuthSessionStore();
    late http.Request captured;
    final accessToken = _testJwt(
      expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 15)),
    );
    final repository = BackendAuthRepository(
      baseUrl: 'https://api.example.test',
      sessionStore: store,
      httpClient: MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'accessToken': accessToken,
            'refreshToken': 'session.refresh-one',
            'hasRefreshToken': true,
            'user': {'id': 'user-1', 'email': 'person@example.com'},
          }),
          200,
        );
      }),
    );

    await repository.signIn(
      email: 'person@example.com',
      password: 'existing-password',
    );

    expect(captured.headers['x-fittin-auth-version'], '2');
    expect(captured.headers['x-fittin-auth-platform'], 'native');
    expect(captured.headers['x-fittin-device-id'], isNotEmpty);
    expect(await store.loadAccessToken(), accessToken);
    expect(await store.loadRefreshToken(), 'session.refresh-one');
  });

  test(
    'expired access refresh is single-flight and rotates credentials',
    () async {
      final store = InMemoryAuthSessionStore();
      await store.saveAccessToken(
        _testJwt(
          expiresAt: DateTime.now().toUtc().subtract(
            const Duration(minutes: 1),
          ),
        ),
      );
      await store.saveRefreshToken('session.refresh-old');
      await store.saveCachedUser(
        const CachedAuthUser(id: 'user-1', email: 'person@example.com'),
      );
      final response = Completer<http.Response>();
      var refreshRequests = 0;
      final refreshedAccess = _testJwt(
        expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 15)),
      );
      final repository = BackendAuthRepository(
        baseUrl: 'https://api.example.test',
        sessionStore: store,
        httpClient: MockClient((request) {
          expect(request.url.path, '/v1/auth/refresh');
          expect(
            (jsonDecode(request.body) as Map<String, dynamic>)['refreshToken'],
            'session.refresh-old',
          );
          refreshRequests += 1;
          return response.future;
        }),
      );

      final first = repository.currentAccessToken();
      final second = repository.currentAccessToken();
      await Future<void>.delayed(Duration.zero);
      expect(refreshRequests, 1);
      response.complete(
        http.Response(
          jsonEncode({
            'accessToken': refreshedAccess,
            'refreshToken': 'session.refresh-new',
            'hasRefreshToken': true,
            'user': {'id': 'user-1', 'email': 'person@example.com'},
          }),
          200,
        ),
      );

      expect(await first, refreshedAccess);
      expect(await second, refreshedAccess);
      expect(refreshRequests, 1);
      expect(await store.loadRefreshToken(), 'session.refresh-new');
    },
  );

  test('cached refresh session restores immediately while offline', () async {
    final store = InMemoryAuthSessionStore();
    await store.saveAccessToken(
      _testJwt(
        expiresAt: DateTime.now().toUtc().subtract(const Duration(minutes: 1)),
      ),
    );
    await store.saveRefreshToken('session.refresh-old');
    await store.saveCachedUser(
      const CachedAuthUser(id: 'offline-user', email: 'offline@example.test'),
    );
    final response = Completer<http.Response>();
    var requests = 0;
    final repository = BackendAuthRepository(
      baseUrl: 'https://api.example.test',
      sessionStore: store,
      httpClient: MockClient((request) {
        requests += 1;
        return response.future;
      }),
    );

    final user = await repository.currentUser().timeout(
      const Duration(milliseconds: 100),
    );

    expect(user?.id, 'offline-user');
    await Future<void>.delayed(Duration.zero);
    expect(requests, 1);
    response.complete(http.Response('<html>offline</html>', 503));
    await Future<void>.delayed(Duration.zero);
    expect((await store.loadCachedUser())?.id, 'offline-user');
  });

  test('a stale failed access token does not rotate refresh twice', () async {
    final store = InMemoryAuthSessionStore();
    final oldAccess = _testJwt(
      expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 15)),
    );
    final freshAccess = _testJwt(
      expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 30)),
    );
    await store.saveAccessToken(oldAccess);
    await store.saveRefreshToken('session.refresh-old');
    await store.saveCachedUser(const CachedAuthUser(id: 'user-1'));
    var refreshRequests = 0;
    final repository = BackendAuthRepository(
      baseUrl: 'https://api.example.test',
      sessionStore: store,
      httpClient: MockClient((request) async {
        refreshRequests += 1;
        return http.Response(
          jsonEncode({
            'accessToken': freshAccess,
            'refreshToken': 'session.refresh-new',
            'hasRefreshToken': true,
            'user': {'id': 'user-1'},
          }),
          200,
        );
      }),
    );

    expect(await repository.currentAccessToken(), oldAccess);
    expect(
      await repository.refreshAccessToken(failedAccessToken: oldAccess),
      freshAccess,
    );
    expect(
      await repository.refreshAccessToken(failedAccessToken: oldAccess),
      freshAccess,
    );
    expect(refreshRequests, 1);
  });

  test('legacy access session bootstraps refresh credentials once', () async {
    final store = InMemoryAuthSessionStore();
    final legacyAccess = _testJwt(
      expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
    );
    await store.saveAccessToken(legacyAccess);
    await store.saveCachedUser(
      const CachedAuthUser(id: 'legacy-user', email: 'legacy@example.test'),
    );
    var requests = 0;
    final repository = BackendAuthRepository(
      baseUrl: 'https://api.example.test',
      sessionStore: store,
      httpClient: MockClient((request) async {
        requests += 1;
        expect(request.method, 'GET');
        expect(request.url.path, '/v1/auth/session');
        expect(request.headers['x-fittin-auth-version'], '2');
        return http.Response(
          jsonEncode({
            'accessToken': legacyAccess,
            'refreshToken': 'legacy-session.refresh',
            'hasRefreshToken': true,
            'user': {'id': 'legacy-user', 'email': 'legacy@example.test'},
          }),
          200,
        );
      }),
    );

    expect((await repository.currentUser())?.id, 'legacy-user');
    expect(await store.loadRefreshToken(), 'legacy-session.refresh');
    expect(requests, 1);
  });

  test(
    'transient malformed refresh response preserves cached session',
    () async {
      final store = InMemoryAuthSessionStore();
      final expiredAccess = _testJwt(
        expiresAt: DateTime.now().toUtc().subtract(const Duration(minutes: 1)),
      );
      await store.saveAccessToken(expiredAccess);
      await store.saveRefreshToken('session.refresh-old');
      await store.saveCachedUser(
        const CachedAuthUser(id: 'offline-user', email: 'offline@example.test'),
      );
      final repository = BackendAuthRepository(
        baseUrl: 'https://api.example.test',
        sessionStore: store,
        httpClient: MockClient(
          (request) async => http.Response('<html>bad gateway</html>', 502),
        ),
      );

      await expectLater(
        repository.currentAccessToken(),
        throwsA(isA<StateError>()),
      );

      expect(await store.loadAccessToken(), expiredAccess);
      expect(await store.loadRefreshToken(), 'session.refresh-old');
      expect((await store.loadCachedUser())?.id, 'offline-user');
    },
  );

  test(
    'native refresh rejects a successful response without rotation',
    () async {
      final store = InMemoryAuthSessionStore();
      final expiredAccess = _testJwt(
        expiresAt: DateTime.now().toUtc().subtract(const Duration(minutes: 1)),
      );
      await store.saveAccessToken(expiredAccess);
      await store.saveRefreshToken('session.refresh-old');
      await store.saveCachedUser(const CachedAuthUser(id: 'user-1'));
      final repository = BackendAuthRepository(
        baseUrl: 'https://api.example.test',
        sessionStore: store,
        httpClient: MockClient(
          (request) async => http.Response(
            jsonEncode({
              'accessToken': _testJwt(
                expiresAt: DateTime.now().toUtc().add(
                  const Duration(minutes: 15),
                ),
              ),
              'hasRefreshToken': true,
              'user': {'id': 'user-1'},
            }),
            200,
          ),
        ),
      );

      await expectLater(
        repository.currentAccessToken(),
        throwsA(isA<StateError>()),
      );
      expect(await store.loadAccessToken(), expiredAccess);
      expect(await store.loadRefreshToken(), 'session.refresh-old');
    },
  );

  test('definitive refresh revocation clears the persisted session', () async {
    final store = InMemoryAuthSessionStore();
    await store.saveAccessToken(
      _testJwt(
        expiresAt: DateTime.now().toUtc().subtract(const Duration(minutes: 1)),
      ),
    );
    await store.saveRefreshToken('session.refresh-old');
    await store.saveCachedUser(const CachedAuthUser(id: 'revoked-user'));
    final repository = BackendAuthRepository(
      baseUrl: 'https://api.example.test',
      sessionStore: store,
      httpClient: MockClient(
        (request) async =>
            http.Response('{"error":"revoked","code":"session_revoked"}', 401),
      ),
    );

    expect(await repository.currentAccessToken(), isNull);
    expect(await store.loadAccessToken(), isNull);
    expect(await store.loadRefreshToken(), isNull);
    expect(await store.loadCachedUser(), isNull);
  });

  test('explicit sign-out clears access, refresh, and cached user', () async {
    final store = InMemoryAuthSessionStore();
    await store.saveAccessToken('current-access');
    await store.saveRefreshToken('session.refresh-current');
    await store.saveCachedUser(const CachedAuthUser(id: 'user-1'));
    late http.Request captured;
    final repository = BackendAuthRepository(
      baseUrl: 'https://api.example.test',
      sessionStore: store,
      httpClient: MockClient((request) async {
        captured = request;
        return http.Response('{"ok":true}', 200);
      }),
    );

    await repository.signOut();

    expect(captured.url.path, '/v1/auth/sign-out');
    expect(captured.headers['authorization'], 'Bearer current-access');
    expect(await store.loadAccessToken(), isNull);
    expect(await store.loadRefreshToken(), isNull);
    expect(await store.loadCachedUser(), isNull);
  });

  test('sign-out prevents a pending restore from signing back in', () async {
    final store = InMemoryAuthSessionStore();
    await store.saveAccessToken('current-access');
    await store.saveCachedUser(const CachedAuthUser(id: 'user-1'));
    final sessionResponse = Completer<http.Response>();
    final repository = BackendAuthRepository(
      baseUrl: 'https://api.example.test',
      sessionStore: store,
      httpClient: MockClient((request) {
        if (request.url.path == '/v1/auth/session') {
          return sessionResponse.future;
        }
        expect(request.url.path, '/v1/auth/sign-out');
        return Future.value(http.Response('{"ok":true}', 200));
      }),
    );

    final pendingRestore = repository.currentUser();
    await Future<void>.delayed(Duration.zero);
    await repository.signOut();
    sessionResponse.complete(
      http.Response(
        '{"accessToken":"restored-access","user":{"id":"user-1"}}',
        200,
      ),
    );

    expect(await pendingRestore, isNull);
    expect(await store.loadAccessToken(), isNull);
    expect(await store.loadCachedUser(), isNull);
  });

  test(
    'successful legacy sign-in drops another account refresh token',
    () async {
      final store = InMemoryAuthSessionStore();
      await store.saveAccessToken('old-access');
      await store.saveRefreshToken('old-account.refresh');
      await store.saveCachedUser(const CachedAuthUser(id: 'old-user'));
      final repository = BackendAuthRepository(
        baseUrl: 'https://api.example.test',
        sessionStore: store,
        httpClient: MockClient(
          (request) async => http.Response(
            '{"accessToken":"new-access","user":{"id":"new-user"}}',
            200,
          ),
        ),
      );

      expect(
        (await repository.signIn(
          email: 'new@example.test',
          password: 'existing-password',
        )).id,
        'new-user',
      );
      expect(await store.loadAccessToken(), 'new-access');
      expect(await store.loadRefreshToken(), isNull);
      expect((await store.loadCachedUser())?.id, 'new-user');
    },
  );

  test('clearing a session preserves the stable device id', () async {
    final store = InMemoryAuthSessionStore();
    final before = await store.loadOrCreateDeviceId();
    await store.saveAccessToken('access');
    await store.saveRefreshToken('refresh');

    await store.clear();

    expect(await store.loadOrCreateDeviceId(), before);
  });
}

String _testJwt({required DateTime expiresAt}) {
  String segment(Map<String, Object> value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  return '${segment({'alg': 'HS256', 'typ': 'JWT'})}.'
      '${segment({'sub': 'user-1', 'email': 'person@example.com', 'exp': expiresAt.millisecondsSinceEpoch ~/ 1000})}.'
      'signature';
}
