import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/ui_settings_provider.dart';
import 'package:fittin_v2/src/presentation/screens/active_session_screen.dart';

import '../support/fake_today_workout_gateway.dart';
import '../support/in_memory_database_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('active session screen renders compact workout console', (
    WidgetTester tester,
  ) async {
    final gateway = FakeTodayWorkoutGateway();
    final container = ProviderContainer(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(
          InMemoryDatabaseRepository(),
        ),
        todayWorkoutGatewayProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(container.dispose);

    await container.read(activeSessionProvider.notifier).startOrResumeSession();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ActiveSessionScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Squat'), findsOneWidget);
    expect(find.text('Set 1 / 2'), findsOneWidget);

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Conclude Workout'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm workout conclusion?'), findsOneWidget);
    expect(gateway.concludedSession, isNull);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(gateway.concludedSession, isNull);

    await tester.tap(find.text('Conclude Workout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Conclude Workout').last);
    await tester.pumpAndSettle();
    expect(gateway.concludedSession, isNotNull);
  });

  testWidgets(
    'card logger completes left and cancels down with centered fallback',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = await _sessionContainer(WorkoutRecordingMode.card);
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: ActiveSessionScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      final card = find.byKey(const ValueKey('active-set-card'));
      final complete = find.byKey(const ValueKey('complete-current-set'));
      expect(card, findsOneWidget);
      expect(complete, findsOneWidget);
      expect(
        tester.getCenter(complete).dx,
        closeTo(tester.getSize(find.byType(Scaffold)).width / 2, 24),
      );

      final leftGesture = await tester.startGesture(
        tester.getTopRight(card) + const Offset(-36, 44),
      );
      await leftGesture.moveBy(const Offset(-40, 0));
      await tester.pump();
      await leftGesture.moveBy(const Offset(-240, 0));
      await leftGesture.up();
      await tester.pumpAndSettle(
        const Duration(milliseconds: 50),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 3),
      );
      var workout = container.read(activeSessionProvider).activeWorkout!;
      expect(workout.exercises.first.sets.first.isCompleted, true);
      expect(workout.exercises.first.currentSetIndex, 1);

      final downGesture = await tester.startGesture(
        tester.getTopLeft(card) + const Offset(36, 44),
      );
      await downGesture.moveBy(const Offset(0, 40));
      await tester.pump();
      await downGesture.moveBy(const Offset(0, 220));
      await downGesture.up();
      await tester.pumpAndSettle(
        const Duration(milliseconds: 50),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 3),
      );
      workout = container.read(activeSessionProvider).activeWorkout!;
      expect(workout.exercises.first.sets[1].isSkipped, true);
      expect(workout.exercises.first.sets[1].isCompleted, false);
    },
  );

  testWidgets('traditional logger opens exact weight entry on tap', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = await _sessionContainer(WorkoutRecordingMode.traditional);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ActiveSessionScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(
      find.byKey(const ValueKey('traditional-set-logger')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('active-set-card')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('current-weight-editor')));
    await tester.pumpAndSettle();
    expect(find.text('Enter Weight'), findsOneWidget);
  });
}

Future<ProviderContainer> _sessionContainer(WorkoutRecordingMode mode) async {
  final container = ProviderContainer(
    overrides: [
      workoutRecordingModeProvider.overrideWith(
        (ref) => WorkoutRecordingModeNotifier(
          initialMode: mode,
          loadPersisted: false,
        ),
      ),
      databaseRepositoryProvider.overrideWithValue(
        InMemoryDatabaseRepository(),
      ),
      todayWorkoutGatewayProvider.overrideWithValue(FakeTodayWorkoutGateway()),
    ],
  );
  await container.read(activeSessionProvider.notifier).startOrResumeSession();
  return container;
}
