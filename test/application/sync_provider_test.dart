import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/sync_provider.dart';
import 'package:fittin_v2/src/application/sync_refresh_provider.dart';
import 'package:fittin_v2/src/application/supabase_bootstrap.dart';
import 'package:fittin_v2/src/data/sync/sync_service.dart';

import '../support/fake_auth_repository.dart';
import '../support/in_memory_database_repository.dart';

class _TrackingSyncController extends SyncController {
  _TrackingSyncController(super.ref);

  final List<bool> recoveryCalls = [];
  int clearCalls = 0;

  @override
  Future<void> synchronizeWithRecovery({bool hydrate = false}) async {
    recoveryCalls.add(hydrate);
    state = state.copyWith(
      stage: hydrate ? SyncStage.hydrating : SyncStage.syncing,
      activeUserId: 'tracked-user',
      clearError: true,
    );
  }

  @override
  void clearForSignedOutUser() {
    clearCalls += 1;
    super.clearForSignedOutUser();
  }
}

class _SuccessfulSyncService implements SyncService {
  int calls = 0;

  @override
  Future<void> synchronize() async {
    calls += 1;
  }
}

class _FailingAfterHydrationSyncService implements SyncService {
  int calls = 0;

  @override
  Future<void> synchronize() async {
    calls += 1;
    throw Exception('Remote push failed after local hydration');
  }
}

void main() {
  test('successful synchronization refreshes cached data providers', () async {
    final service = _SuccessfulSyncService();
    final container = ProviderContainer(
      overrides: [
        currentUserIdProvider.overrideWithValue('sync-user'),
        syncServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(syncRefreshProvider), 0);

    await container.read(syncControllerProvider.notifier).synchronize();

    expect(service.calls, 1);
    expect(container.read(syncRefreshProvider), 1);
  });

  test(
    'failed synchronization still refreshes locally hydrated data',
    () async {
      final service = _FailingAfterHydrationSyncService();
      final container = ProviderContainer(
        overrides: [
          currentUserIdProvider.overrideWithValue('sync-user'),
          syncServiceProvider.overrideWithValue(service),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(syncControllerProvider.notifier)
          .synchronizeWithRecovery(hydrate: true);

      expect(service.calls, 1);
      expect(container.read(syncRefreshProvider), 1);
      expect(
        container.read(syncControllerProvider).stage,
        SyncStage.retryNeeded,
      );
    },
  );

  testWidgets(
    'sync lifecycle gate hydrates restored sessions and syncs on resume',
    (WidgetTester tester) async {
      final authRepository = FakeAuthRepository(
        initialUser: const AuthUser(
          id: 'tracked-user',
          email: 'restore@test.dev',
        ),
      );
      final repository = InMemoryDatabaseRepository();
      late _TrackingSyncController tracker;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseRepositoryProvider.overrideWithValue(repository),
            authRepositoryProvider.overrideWithValue(authRepository),
            syncControllerProvider.overrideWith((ref) {
              tracker = _TrackingSyncController(ref);
              return tracker;
            }),
            supabaseBootstrapProvider.overrideWithValue(
              const SupabaseBootstrapState.configured(
                url: 'https://example.supabase.co',
                anonKey: 'anon-key',
              ),
            ),
          ],
          child: const MaterialApp(
            home: SyncLifecycleGate(child: Scaffold(body: Text('sync-child'))),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tracker.recoveryCalls, [true]);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      expect(tracker.recoveryCalls, [true, false]);
    },
  );

  testWidgets(
    'sync lifecycle gate reacts to sign-in and sign-out transitions',
    (WidgetTester tester) async {
      final authRepository = FakeAuthRepository();
      final repository = InMemoryDatabaseRepository();
      late _TrackingSyncController tracker;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseRepositoryProvider.overrideWithValue(repository),
            authRepositoryProvider.overrideWithValue(authRepository),
            syncControllerProvider.overrideWith((ref) {
              tracker = _TrackingSyncController(ref);
              return tracker;
            }),
            supabaseBootstrapProvider.overrideWithValue(
              const SupabaseBootstrapState.configured(
                url: 'https://example.supabase.co',
                anonKey: 'anon-key',
              ),
            ),
          ],
          child: const MaterialApp(
            home: SyncLifecycleGate(child: Scaffold(body: Text('sync-child'))),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tracker.clearCalls, greaterThanOrEqualTo(1));

      await authRepository.signIn(
        email: 'user@test.dev',
        password: 'password123',
      );
      await tester.pumpAndSettle();

      expect(tracker.recoveryCalls, [true]);

      await authRepository.signOut();
      await tester.pumpAndSettle();

      expect(tracker.clearCalls, greaterThanOrEqualTo(2));
    },
  );
}
