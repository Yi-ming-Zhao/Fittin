import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/supabase_bootstrap.dart';
import 'package:fittin_v2/src/presentation/screens/account_screen.dart';

import '../support/fake_auth_repository.dart';
import '../support/in_memory_database_repository.dart';

void main() {
  testWidgets('account screen signs in from the entry form', (
    WidgetTester tester,
  ) async {
    final authRepository = FakeAuthRepository();
    final repository = InMemoryDatabaseRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(repository),
          authRepositoryProvider.overrideWithValue(authRepository),
          supabaseBootstrapProvider.overrideWithValue(
            const SupabaseBootstrapState.configured(
              url: 'https://example.supabase.co',
              anonKey: 'anon-key',
            ),
          ),
        ],
        child: const MaterialApp(home: AccountScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('account-email-field')),
      'user@test.dev',
    );
    await tester.enterText(
      find.byKey(const ValueKey('account-password-field')),
      'password123',
    );
    await tester.tap(find.byKey(const ValueKey('submit-account-auth')));
    await tester.pumpAndSettle();

    expect(authRepository.signInCalls, 1);
    expect(find.text('user@test.dev'), findsOneWidget);
    expect(find.byKey(const ValueKey('sign-out-button')), findsOneWidget);
  });

  testWidgets('account screen can create an account from the entry form', (
    WidgetTester tester,
  ) async {
    final authRepository = FakeAuthRepository();
    final repository = InMemoryDatabaseRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(repository),
          authRepositoryProvider.overrideWithValue(authRepository),
          supabaseBootstrapProvider.overrideWithValue(
            const SupabaseBootstrapState.configured(
              url: 'https://example.supabase.co',
              anonKey: 'anon-key',
            ),
          ),
        ],
        child: const MaterialApp(home: AccountScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('account-email-field')),
      'new-user@test.dev',
    );
    await tester.enterText(
      find.byKey(const ValueKey('account-password-field')),
      'password123',
    );
    await tester.tap(find.byKey(const ValueKey('submit-account-auth')));
    await tester.pumpAndSettle();

    expect(authRepository.signUpCalls, 1);
    expect(find.text('new-user@test.dev'), findsOneWidget);
    expect(find.byKey(const ValueKey('sign-out-button')), findsOneWidget);
  });

  testWidgets('account screen restores a signed-in session and can sign out', (
    WidgetTester tester,
  ) async {
    final authRepository = FakeAuthRepository(
      initialUser: const AuthUser(
        id: 'restored-user',
        email: 'restored@test.dev',
      ),
    );
    final repository = InMemoryDatabaseRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(repository),
          authRepositoryProvider.overrideWithValue(authRepository),
          supabaseBootstrapProvider.overrideWithValue(
            const SupabaseBootstrapState.configured(
              url: 'https://example.supabase.co',
              anonKey: 'anon-key',
            ),
          ),
        ],
        child: const MaterialApp(home: AccountScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('restored@test.dev'), findsOneWidget);
    expect(find.byKey(const ValueKey('retry-sync-button')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('sign-out-button')));
    await tester.pumpAndSettle();

    expect(authRepository.signedOut, isTrue);
    expect(find.byKey(const ValueKey('account-email-field')), findsOneWidget);
  });
}
