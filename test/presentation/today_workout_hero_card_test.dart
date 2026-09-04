import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/exercise_library_provider.dart';
import 'package:fittin_v2/src/application/services/today_workout_gateway.dart';
import 'package:fittin_v2/src/domain/exercise_library.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:fittin_v2/src/presentation/widgets/today_workout_hero_card.dart';

import '../support/fake_today_workout_gateway.dart';
import '../support/in_memory_database_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ExerciseLibrary exerciseLibrary;

  setUpAll(() async {
    exerciseLibrary = await ExerciseLibraryLoader().load();
  });

  testWidgets('microcycle chooser scrolls within a short 320px viewport', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final baseWorkout = fakePlanTemplate.workoutByIndex(0);
    final workouts = [
      for (var index = 0; index < 12; index++)
        baseWorkout.copyWith(
          id: 'day-${index + 1}',
          name: 'Day ${index + 1}',
          dayLabel: 'Day ${index + 1}',
        ),
    ];
    final container = ProviderContainer(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(
          InMemoryDatabaseRepository(),
        ),
        todayWorkoutGatewayProvider.overrideWithValue(
          FakeTodayWorkoutGateway(),
        ),
        exerciseLibraryProvider.overrideWith((ref) async => exerciseLibrary),
        remainingMicrocycleWorkoutsProvider.overrideWith(
          (ref) async => workouts,
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TodayWorkoutHeroCard(compact: true),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final key in const ['reorder-microcycle', 'share-active-plan']) {
      final action = find.byKey(ValueKey(key));
      expect(tester.getSize(action).width, greaterThanOrEqualTo(44));
      expect(tester.getSize(action).height, greaterThanOrEqualTo(44));
    }
    await tester.tap(find.byKey(const ValueKey('reorder-microcycle')));
    await tester.pumpAndSettle();

    final sheet = find.byKey(const ValueKey('microcycle-schedule-sheet'));
    final list = find.byKey(const ValueKey('microcycle-schedule-list'));
    expect(sheet, findsOneWidget);
    expect(tester.getSize(sheet).height, lessThanOrEqualTo(568 * 0.78));
    final scrollable = find.descendant(
      of: list,
      matching: find.byType(Scrollable),
    );
    expect(
      tester.state<ScrollableState>(scrollable).position.maxScrollExtent,
      greaterThan(0),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashboard hero refreshes after switching the active plan', (
    WidgetTester tester,
  ) async {
    final gateway = _SwitchableTodayWorkoutGateway(
      summary: fakeTodayWorkoutSummary,
      template: fakePlanTemplate,
    );
    final switchedTemplate = fakePlanTemplate.copyWith(
      id: 'template-2',
      phases: [
        fakePlanTemplate.phases.first.copyWith(
          workouts: [
            fakePlanTemplate
                .workoutByIndex(0)
                .copyWith(
                  name: 'Squat & Pull',
                  exercises: [
                    fakePlanTemplate
                        .workoutByIndex(0)
                        .exercises
                        .first
                        .copyWith(name: 'Competition Squat'),
                  ],
                ),
          ],
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(
          InMemoryDatabaseRepository(),
        ),
        todayWorkoutGatewayProvider.overrideWithValue(gateway),
        exerciseLibraryProvider.overrideWith((ref) async => exerciseLibrary),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: TodayWorkoutHeroCard())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Squat'), findsWidgets);
    expect(find.text('Squat Focus'), findsOneWidget);

    gateway.summary = const TodayWorkoutSummary(
      instanceId: 'instance-2',
      workoutId: 'day1',
      workoutName: 'Squat & Pull',
      dayLabel: 'Day 1',
      currentWeekNumber: 2,
      currentDayNumber: 3,
      cycleWeekCount: 12,
      workoutsPerWeek: 4,
      primaryExerciseId: 'day1-squat',
      primaryExerciseName: 'Competition Squat',
      estimatedDurationMinutes: 70,
      exerciseCount: 5,
    );
    gateway.template = switchedTemplate;
    container.refresh(activeTemplateProvider);
    container.refresh(todayWorkoutSummaryProvider);

    await tester.pumpAndSettle();

    expect(find.text('Squat'), findsWidgets);
    expect(find.text('Competition Squat'), findsNothing);
    expect(find.text('Squat & Pull'), findsOneWidget);
  });

  testWidgets('dashboard hero uses canonical Chinese exercise and UI labels', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryDatabaseRepository();
    await repository.saveAppLocale(AppLocale.zh);
    final container = ProviderContainer(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(repository),
        todayWorkoutGatewayProvider.overrideWithValue(
          _SwitchableTodayWorkoutGateway(
            summary: fakeTodayWorkoutSummary,
            template: fakePlanTemplate,
          ),
        ),
        exerciseLibraryProvider.overrideWith((ref) async => exerciseLibrary),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: TodayWorkoutHeroCard())),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('下一次训练'), findsOneWidget);
    expect(find.text('接下来'), findsOneWidget);
    expect(find.text('深蹲'), findsWidgets);
    expect(find.text('Next session'), findsNothing);
    expect(find.text('Up next'), findsNothing);
    expect(find.text('Squat'), findsNothing);
  });

  testWidgets('rapid taps open only one active session route', (
    WidgetTester tester,
  ) async {
    final gateway = _DelayedTodayWorkoutGateway(
      summary: fakeTodayWorkoutSummary,
      template: fakePlanTemplate,
    );
    final observer = _TrackingNavigatorObserver();
    final container = ProviderContainer(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(
          InMemoryDatabaseRepository(),
        ),
        todayWorkoutGatewayProvider.overrideWithValue(gateway),
        exerciseLibraryProvider.overrideWith((ref) async => exerciseLibrary),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          navigatorObservers: [observer],
          home: const Scaffold(body: TodayWorkoutHeroCard()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('Start'));
    await tester.tap(find.text('Start'));
    await tester.pump();

    expect(gateway.sessionLoadCalls, 1);
    gateway.completeSession();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(observer.pushCount, 2);
  });
}

class _TrackingNavigatorObserver extends NavigatorObserver {
  int pushCount = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushCount += 1;
    super.didPush(route, previousRoute);
  }
}

class _DelayedTodayWorkoutGateway extends _SwitchableTodayWorkoutGateway {
  _DelayedTodayWorkoutGateway({
    required super.summary,
    required super.template,
  });

  final Completer<WorkoutSessionState> _session = Completer();
  int sessionLoadCalls = 0;

  @override
  Future<WorkoutSessionState> loadTodayWorkoutSession() {
    sessionLoadCalls += 1;
    return _session.future;
  }

  void completeSession() {
    if (!_session.isCompleted) {
      _session.complete(fakeWorkoutSessionState);
    }
  }
}

class _SwitchableTodayWorkoutGateway implements TodayWorkoutGateway {
  _SwitchableTodayWorkoutGateway({
    required this.summary,
    required this.template,
  });

  TodayWorkoutSummary summary;
  PlanTemplate template;

  @override
  Future<void> concludeWorkoutSession(WorkoutSessionState session) async {}

  @override
  Future<PlanTemplate> importSharedTemplate(PlanTemplate template) async {
    return template;
  }

  @override
  Future<PlanTemplate> loadActiveTemplate() async => template;

  @override
  Future<TodayWorkoutSummary> loadTodayWorkoutSummary() async => summary;

  @override
  Future<WorkoutSessionState> loadTodayWorkoutSession() async {
    return fakeWorkoutSessionState;
  }

  @override
  Future<List<Workout>> loadRemainingMicrocycleWorkouts() async =>
      template.workouts;

  @override
  Future<void> reorderTodayWorkout(String workoutId) async {}
}
