import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';

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
}
