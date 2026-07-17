import 'dart:async';

import 'package:fittin_v2/src/application/app_startup_provider.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/sync_provider.dart';
import 'package:fittin_v2/src/data/sync/sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_auth_repository.dart';

class _ControlledSyncService implements SyncService {
  _ControlledSyncService({this.failure});

  final Object? failure;
  int calls = 0;

  @override
  Future<void> synchronize() async {
    calls += 1;
    if (failure != null) {
      throw failure!;
    }
  }
}

void main() {
  test('restored user hydrates once before startup becomes ready', () async {
    final service = _ControlledSyncService();
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          FakeAuthRepository(
            initialUser: const AuthUser(
              id: 'restored-user',
              email: 'restored@test.dev',
            ),
          ),
        ),
        syncServiceProvider.overrideWithValue(service),
        startupMinimumDurationProvider.overrideWithValue(Duration.zero),
        startupTimeoutProvider.overrideWithValue(const Duration(minutes: 1)),
        initialHomeValidationProvider.overrideWith((ref) async {}),
      ],
    );
    addTearDown(container.dispose);

    final readiness = await container.read(appStartupReadinessProvider.future);

    expect(readiness.degraded, isFalse);
    expect(readiness.userId, 'restored-user');
    expect(service.calls, 1);
    expect(container.read(currentUserIdProvider), 'restored-user');
    expect(container.read(syncControllerProvider).stage, SyncStage.synced);
    expect(
      container.read(syncControllerProvider).activeUserId,
      'restored-user',
    );
  });

  test(
    'signed-out startup resolves from local state without syncing',
    () async {
      final service = _ControlledSyncService(
        failure: StateError('signed-out startup must not touch the network'),
      );
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          syncServiceProvider.overrideWithValue(service),
          startupMinimumDurationProvider.overrideWithValue(Duration.zero),
          startupTimeoutProvider.overrideWithValue(const Duration(minutes: 1)),
          initialHomeValidationProvider.overrideWith((ref) async {}),
        ],
      );
      addTearDown(container.dispose);

      final readiness = await container.read(
        appStartupReadinessProvider.future,
      );

      expect(readiness.degraded, isFalse);
      expect(readiness.userId, isNull);
      expect(service.calls, 0);
      expect(container.read(currentUserIdProvider), isNull);
      expect(container.read(syncControllerProvider).stage, SyncStage.idle);
    },
  );

  test(
    'failed hydration remains ready when local home validation succeeds',
    () async {
      final service = _ControlledSyncService(
        failure: Exception('cloud unavailable'),
      );
      var validationCalls = 0;
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            FakeAuthRepository(
              initialUser: const AuthUser(
                id: 'offline-user',
                email: 'offline@test.dev',
              ),
            ),
          ),
          syncServiceProvider.overrideWithValue(service),
          startupMinimumDurationProvider.overrideWithValue(Duration.zero),
          startupTimeoutProvider.overrideWithValue(const Duration(minutes: 1)),
          initialHomeValidationProvider.overrideWith((ref) async {
            validationCalls += 1;
          }),
        ],
      );
      addTearDown(container.dispose);

      final readiness = await container.read(
        appStartupReadinessProvider.future,
      );

      expect(readiness.degraded, isTrue);
      expect(service.calls, 1);
      expect(validationCalls, 1);
      expect(
        container.read(syncControllerProvider).stage,
        SyncStage.retryNeeded,
      );
    },
  );

  test('startup coordinator bounds unresolved hydration', () async {
    final hydration = Completer<SyncControllerState>();
    final container = ProviderContainer(
      overrides: [
        startupMinimumDurationProvider.overrideWithValue(Duration.zero),
        startupTimeoutProvider.overrideWithValue(
          const Duration(milliseconds: 1),
        ),
        initialUserHydrationProvider.overrideWith((ref) => hydration.future),
        initialHomeValidationProvider.overrideWith((ref) async {}),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(appStartupReadinessProvider.future),
      throwsA(isA<TimeoutException>()),
    );
  });
}
