import 'dart:async';

import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/app_startup_provider.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/sync_provider.dart';
import 'package:fittin_v2/src/data/sync/sync_service.dart';
import 'package:fittin_v2/src/presentation/screens/app_startup_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/in_memory_database_repository.dart';
import '../support/fake_auth_repository.dart';

class _PendingSyncService implements SyncService {
  final completion = Completer<void>();
  int calls = 0;

  @override
  Future<void> synchronize() async {
    calls += 1;
    await completion.future;
  }
}

void main() {
  testWidgets('keeps the shell hidden until hydration and validation settle', (
    tester,
  ) async {
    final hydration = Completer<SyncControllerState>();
    final validation = Completer<void>();
    var validationStarted = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(
            InMemoryDatabaseRepository(),
          ),
          startupMinimumDurationProvider.overrideWithValue(Duration.zero),
          startupTimeoutProvider.overrideWithValue(const Duration(minutes: 1)),
          initialUserHydrationProvider.overrideWith((ref) => hydration.future),
          initialHomeValidationProvider.overrideWith((ref) {
            validationStarted = true;
            return validation.future;
          }),
        ],
        child: const MaterialApp(
          home: AppStartupGate(child: Scaffold(body: Text('ready-shell'))),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('startup-splash')), findsOneWidget);
    expect(find.text('ready-shell'), findsNothing);
    expect(validationStarted, isFalse);

    hydration.complete(
      const SyncControllerState(
        stage: SyncStage.synced,
        activeUserId: 'user-1',
      ),
    );
    await tester.pump();

    expect(validationStarted, isTrue);
    expect(find.text('ready-shell'), findsNothing);

    validation.complete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 260));

    expect(find.text('ready-shell'), findsOneWidget);
    expect(find.byKey(const ValueKey('startup-splash')), findsNothing);
  });

  testWidgets('startup failure can retry without mounting the shell early', (
    tester,
  ) async {
    final retryResult = Completer<AppStartupReadiness>();
    var attempts = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(
            InMemoryDatabaseRepository(),
          ),
          appStartupReadinessProvider.overrideWith((ref) {
            attempts += 1;
            if (attempts == 1) {
              return Future<AppStartupReadiness>.error(
                StateError('network unavailable'),
              );
            }
            return retryResult.future;
          }),
        ],
        child: const MaterialApp(
          home: AppStartupGate(child: Scaffold(body: Text('ready-shell'))),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const ValueKey('startup-retry')), findsOneWidget);
    expect(find.text('ready-shell'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('startup-retry')));
    await tester.pump();
    expect(attempts, 2);
    expect(find.text('ready-shell'), findsNothing);

    retryResult.complete(const AppStartupReadiness());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 260));

    expect(find.text('ready-shell'), findsOneWidget);
  });

  testWidgets('bounded startup timeout exposes both recovery actions', (
    tester,
  ) async {
    final hydration = Completer<SyncControllerState>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(
            InMemoryDatabaseRepository(),
          ),
          startupMinimumDurationProvider.overrideWithValue(Duration.zero),
          startupTimeoutProvider.overrideWithValue(
            const Duration(milliseconds: 10),
          ),
          initialUserHydrationProvider.overrideWith((ref) => hydration.future),
          initialHomeValidationProvider.overrideWith((ref) async {}),
        ],
        child: const MaterialApp(
          home: AppStartupGate(child: Scaffold(body: Text('ready-shell'))),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('ready-shell'), findsNothing);
    expect(find.byKey(const ValueKey('startup-retry')), findsNothing);

    await tester.pump(const Duration(milliseconds: 11));
    await tester.pump();

    expect(find.byKey(const ValueKey('startup-retry')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('startup-continue-local')),
      findsOneWidget,
    );
    expect(find.text('ready-shell'), findsNothing);
  });

  testWidgets('startup failure offers an explicit local continuation', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(
            InMemoryDatabaseRepository(),
          ),
          appStartupReadinessProvider.overrideWith(
            (ref) => Future<AppStartupReadiness>.error(
              StateError('network unavailable'),
            ),
          ),
        ],
        child: const MaterialApp(
          home: AppStartupGate(child: Scaffold(body: Text('local-shell'))),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('startup-continue-local')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 260));

    expect(find.text('local-shell'), findsOneWidget);
  });

  testWidgets('sign-in hides the old scope until user hydration settles', (
    tester,
  ) async {
    final authRepository = FakeAuthRepository();
    final syncService = _PendingSyncService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(
            InMemoryDatabaseRepository(),
          ),
          authRepositoryProvider.overrideWithValue(authRepository),
          syncServiceProvider.overrideWithValue(syncService),
          startupMinimumDurationProvider.overrideWithValue(Duration.zero),
          startupTimeoutProvider.overrideWithValue(const Duration(minutes: 1)),
          initialHomeValidationProvider.overrideWith((ref) async {}),
        ],
        child: const MaterialApp(
          home: AppStartupGate(child: Scaffold(body: Text('ready-shell'))),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('ready-shell'), findsOneWidget);

    await authRepository.signIn(
      email: 'user@example.test',
      password: 'password123',
    );
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const ValueKey('startup-splash')), findsOneWidget);
    expect(find.text('ready-shell'), findsNothing);
    expect(syncService.calls, 1);

    syncService.completion.complete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 260));

    expect(find.text('ready-shell'), findsOneWidget);
  });

  testWidgets('reduced motion keeps the startup mark static', (tester) async {
    final pending = Completer<AppStartupReadiness>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(
            InMemoryDatabaseRepository(),
          ),
          appStartupReadinessProvider.overrideWith((ref) => pending.future),
        ],
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: AppStartupGate(child: SizedBox()),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('startup-barbell-mark')), findsOneWidget);
    pending.complete(const AppStartupReadiness());
  });

  for (final viewport in const [Size(390, 926), Size(390, 568)]) {
    testWidgets(
      'startup content remains centered at ${viewport.width.toInt()}x${viewport.height.toInt()}',
      (tester) async {
        tester.view.physicalSize = viewport;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final pending = Completer<AppStartupReadiness>();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseRepositoryProvider.overrideWithValue(
                InMemoryDatabaseRepository(),
              ),
              appStartupReadinessProvider.overrideWith((ref) => pending.future),
            ],
            child: const MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(disableAnimations: true),
                child: AppStartupGate(child: SizedBox()),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final content = tester.getRect(
          find.byKey(const ValueKey('startup-content')),
        );
        expect(content.center.dy, closeTo(viewport.height / 2, 1));
        expect(content.left, greaterThanOrEqualTo(24));
        expect(content.right, lessThanOrEqualTo(viewport.width - 24));

        pending.complete(const AppStartupReadiness());
      },
    );
  }
}
