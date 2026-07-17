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
    'backend auth converts socket client failures into release guidance',
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
}
