import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/ui_settings_provider.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
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
    expect(find.text('SET 1 / 2'), findsWidgets);
    expect(find.byType(Scrollable), findsNothing);

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

  testWidgets('card logger navigates horizontally and resolves vertically', (
    WidgetTester tester,
  ) async {
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
    expect(find.text('Tap for exact weight'), findsNothing);

    await _swipeCard(tester, card, const Offset(64, 0));
    var workout = container.read(activeSessionProvider).activeWorkout!;
    expect(workout.exercises.first.currentSetIndex, 0);

    await _swipeCard(tester, card, const Offset(-64, 0));
    workout = container.read(activeSessionProvider).activeWorkout!;
    expect(workout.exercises.first.currentSetIndex, 1);
    expect(workout.exercises.first.sets.first.isCompleted, false);
    expect(workout.exercises.first.sets.first.isSkipped, false);
    expect(workout.exercises.first.sets[1].isCompleted, false);
    expect(workout.exercises.first.sets[1].isSkipped, false);

    await _swipeCard(tester, card, const Offset(-64, 0));
    workout = container.read(activeSessionProvider).activeWorkout!;
    expect(workout.exercises.first.currentSetIndex, 1);

    await _swipeCard(tester, card, const Offset(64, 0));
    workout = container.read(activeSessionProvider).activeWorkout!;
    expect(workout.exercises.first.currentSetIndex, 0);

    await _swipeCard(tester, card, const Offset(0, -64));
    workout = container.read(activeSessionProvider).activeWorkout!;
    expect(workout.exercises.first.sets.first.isCompleted, true);
    expect(workout.exercises.first.sets.first.isSkipped, false);
    expect(workout.exercises.first.currentSetIndex, 1);

    await _swipeCard(tester, card, const Offset(0, 64));
    workout = container.read(activeSessionProvider).activeWorkout!;
    expect(workout.exercises.first.sets[1].isSkipped, true);
    expect(workout.exercises.first.sets[1].isCompleted, false);
  });

  testWidgets('short high velocity fling moves to the next set', (
    WidgetTester tester,
  ) async {
    final harness = await _pumpTrackedCardSession(tester);

    await _flingCard(tester, const Offset(-28, 0));
    await tester.pump(const Duration(milliseconds: 220));

    final workout = harness.container
        .read(activeSessionProvider)
        .activeWorkout!;
    expect(workout.exercises.first.currentSetIndex, 1);
    expect(harness.notifier.selectSetCalls, 1);
  });

  testWidgets('short high velocity fling moves to the previous set', (
    WidgetTester tester,
  ) async {
    final firstExercise = fakeWorkoutSessionState.exercises.first;
    final harness = await _pumpTrackedCardSession(
      tester,
      session: fakeWorkoutSessionState.copyWith(
        exercises: [
          firstExercise.copyWith(currentSetIndex: 1),
          ...fakeWorkoutSessionState.exercises.skip(1),
        ],
      ),
    );

    await _flingCard(tester, const Offset(28, 0));
    await tester.pump(const Duration(milliseconds: 220));

    final workout = harness.container
        .read(activeSessionProvider)
        .activeWorkout!;
    expect(workout.exercises.first.currentSetIndex, 0);
    expect(harness.notifier.selectSetCalls, 1);
  });

  testWidgets('short high velocity fling records the current set once', (
    WidgetTester tester,
  ) async {
    final harness = await _pumpTrackedCardSession(tester);

    await _flingCard(tester, const Offset(0, -28));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 450));

    final workout = harness.container
        .read(activeSessionProvider)
        .activeWorkout!;
    expect(workout.exercises.first.sets.first.isCompleted, true);
    expect(workout.exercises.first.sets.first.isSkipped, false);
    expect(harness.notifier.completeSetCalls, 1);
  });

  testWidgets('short high velocity fling skips the current set once', (
    WidgetTester tester,
  ) async {
    final harness = await _pumpTrackedCardSession(tester);

    await _flingCard(tester, const Offset(0, 28));
    await tester.pump(const Duration(milliseconds: 220));

    final workout = harness.container
        .read(activeSessionProvider)
        .activeWorkout!;
    expect(workout.exercises.first.sets.first.isSkipped, true);
    expect(workout.exercises.first.sets.first.isCompleted, false);
    expect(harness.notifier.cancelSetCalls, 1);
  });

  testWidgets('short drag held before release is not treated as a fling', (
    WidgetTester tester,
  ) async {
    final harness = await _pumpTrackedCardSession(tester);
    final card = find.byKey(const ValueKey('active-set-card'));
    final gesture = await tester.startGesture(tester.getCenter(card));
    await gesture.moveBy(
      const Offset(0, -28),
      timeStamp: const Duration(milliseconds: 10),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await gesture.up(timeStamp: const Duration(milliseconds: 510));
    await tester.pump(const Duration(milliseconds: 220));

    final workout = harness.container
        .read(activeSessionProvider)
        .activeWorkout!;
    expect(workout.exercises.first.sets.first.isCompleted, false);
    expect(workout.exercises.first.currentSetIndex, 0);
    expect(harness.notifier.completeSetCalls, 0);
  });

  testWidgets('locked vertical drag is not replaced by release velocity', (
    WidgetTester tester,
  ) async {
    final harness = await _pumpTrackedCardSession(tester);
    final card = find.byKey(const ValueKey('active-set-card'));
    final gesture = await tester.startGesture(tester.getCenter(card));
    await gesture.moveBy(
      const Offset(0, -30),
      timeStamp: const Duration(milliseconds: 5),
    );
    await gesture.moveBy(
      const Offset(0, -20),
      timeStamp: const Duration(milliseconds: 10),
    );
    await gesture.moveBy(
      const Offset(100, 0),
      timeStamp: const Duration(milliseconds: 20),
    );
    await gesture.up(timeStamp: const Duration(milliseconds: 21));
    await tester.pump(const Duration(milliseconds: 220));

    final workout = harness.container
        .read(activeSessionProvider)
        .activeWorkout!;
    expect(workout.exercises.first.sets.first.isCompleted, true);
    expect(workout.exercises.first.currentSetIndex, 1);
    expect(harness.notifier.completeSetCalls, 1);
    expect(harness.notifier.selectSetCalls, 0);
  });

  testWidgets('up fling commits local completion within 200 milliseconds', (
    WidgetTester tester,
  ) async {
    final harness = await _pumpTrackedCardSession(tester);

    await _dragCardWithoutSettling(tester, const Offset(0, -64));
    await tester.pump(const Duration(milliseconds: 200));

    final workout = harness.container
        .read(activeSessionProvider)
        .activeWorkout!;
    expect(workout.exercises.first.sets.first.isCompleted, true);
    expect(workout.exercises.first.currentSetIndex, 1);
    expect(harness.notifier.completeSetCalls, 1);
  });

  testWidgets('restarting completion animation does not drop swipe commands', (
    WidgetTester tester,
  ) async {
    final harness = await _pumpTrackedCardSession(tester);

    await _dragCardWithoutSettling(tester, const Offset(0, -64));
    await tester.pump(const Duration(milliseconds: 200));
    await _dragCardWithoutSettling(tester, const Offset(0, -64));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 450));

    final workout = harness.container
        .read(activeSessionProvider)
        .activeWorkout!;
    expect(harness.notifier.completeSetCalls, 2);
    expect(workout.exercises.first.sets.first.isCompleted, true);
    expect(workout.exercises.first.sets[1].isCompleted, true);
  });

  testWidgets('one swipe dispatches exactly one completion command', (
    WidgetTester tester,
  ) async {
    final harness = await _pumpTrackedCardSession(tester);

    await _dragCardWithoutSettling(tester, const Offset(0, -64));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 450));

    final workout = harness.container
        .read(activeSessionProvider)
        .activeWorkout!;
    expect(harness.notifier.completeSetCalls, 1);
    expect(workout.exercises.first.sets.first.isCompleted, true);
    expect(workout.exercises.first.sets[1].isCompleted, false);
  });

  testWidgets('card controls remain tappable with four-way pan gestures', (
    WidgetTester tester,
  ) async {
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
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('current-weight-editor')));
    await tester.pumpAndSettle();
    expect(find.text('Enter Weight'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Enter Weight'), findsNothing);
  });

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

  testWidgets('barbell graphic uses stable calibrated plate identities', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final firstExercise = fakeWorkoutSessionState.exercises.first;
    final session = fakeWorkoutSessionState.copyWith(
      exercises: [
        firstExercise.copyWith(
          showsPlateBreakdown: true,
          sets: [
            firstExercise.sets.first.copyWith(targetWeight: 135, weight: 135),
            ...firstExercise.sets.skip(1),
          ],
        ),
        ...fakeWorkoutSessionState.exercises.skip(1),
      ],
    );
    final container = await _sessionContainer(
      WorkoutRecordingMode.card,
      session: session,
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ActiveSessionScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(_findPlateWidgets('25.0'), findsNWidgets(4));
    expect(_findPlateWidgets('5.0'), findsNWidgets(2));
    expect(_findPlateWidgets('2.5'), findsNWidgets(2));
  });
}

Finder _findPlateWidgets(String weight) {
  return find.byWidgetPredicate((widget) {
    final key = widget.key;
    return key is ValueKey<String> &&
        key.value.startsWith('barbell-plate-kg-') &&
        key.value.endsWith('-$weight');
  });
}

Future<void> _swipeCard(WidgetTester tester, Finder card, Offset offset) async {
  final gesture = await tester.startGesture(tester.getCenter(card));
  await gesture.moveBy(offset);
  await tester.pump();
  await gesture.up();
  await tester.pumpAndSettle(
    const Duration(milliseconds: 50),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 3),
  );
}

Future<void> _flingCard(WidgetTester tester, Offset offset) {
  return tester.fling(
    find.byKey(const ValueKey('active-set-card')),
    offset,
    2400,
  );
}

Future<void> _dragCardWithoutSettling(
  WidgetTester tester,
  Offset offset,
) async {
  final card = find.byKey(const ValueKey('active-set-card'));
  final gesture = await tester.startGesture(tester.getCenter(card));
  await gesture.moveBy(offset);
  await tester.pump();
  await gesture.up();
}

Future<_TrackedCardHarness> _pumpTrackedCardSession(
  WidgetTester tester, {
  WorkoutSessionState? session,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final repository = InMemoryDatabaseRepository();
  final container = ProviderContainer(
    overrides: [
      workoutRecordingModeProvider.overrideWith(
        (ref) => WorkoutRecordingModeNotifier(
          initialMode: WorkoutRecordingMode.card,
          loadPersisted: false,
        ),
      ),
      databaseRepositoryProvider.overrideWithValue(repository),
      todayWorkoutGatewayProvider.overrideWithValue(
        FakeTodayWorkoutGateway(session: session),
      ),
      activeSessionProvider.overrideWith(_TrackingActiveSessionNotifier.new),
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
  await tester.pump(const Duration(milliseconds: 50));
  expect(find.byKey(const ValueKey('active-set-card')), findsOneWidget);

  return _TrackedCardHarness(
    container,
    container.read(activeSessionProvider.notifier)
        as _TrackingActiveSessionNotifier,
  );
}

class _TrackedCardHarness {
  const _TrackedCardHarness(this.container, this.notifier);

  final ProviderContainer container;
  final _TrackingActiveSessionNotifier notifier;
}

class _TrackingActiveSessionNotifier extends ActiveSessionNotifier {
  _TrackingActiveSessionNotifier(super.ref);

  int selectSetCalls = 0;
  int completeSetCalls = 0;
  int cancelSetCalls = 0;

  @override
  void selectSet(int setIndex) {
    selectSetCalls += 1;
    super.selectSet(setIndex);
  }

  @override
  void completeSet(int setIndex) {
    completeSetCalls += 1;
    super.completeSet(setIndex);
  }

  @override
  void cancelSet(int setIndex) {
    cancelSetCalls += 1;
    super.cancelSet(setIndex);
  }
}

Future<ProviderContainer> _sessionContainer(
  WorkoutRecordingMode mode, {
  WorkoutSessionState? session,
}) async {
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
      todayWorkoutGatewayProvider.overrideWithValue(
        FakeTodayWorkoutGateway(session: session),
      ),
    ],
  );
  await container.read(activeSessionProvider.notifier).startOrResumeSession();
  return container;
}
