import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/home_dashboard_provider.dart';
import 'package:fittin_v2/src/application/pr_dashboard_provider.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:fittin_v2/src/presentation/screens/home_dashboard_screen.dart';
import 'package:fittin_v2/src/presentation/widgets/charts/step_chart.dart';
import 'package:fittin_v2/src/presentation/widgets/fittin_primitives.dart';
import 'package:fittin_v2/src/presentation/widgets/today_workout_hero_card.dart';

import '../support/fake_today_workout_gateway.dart';
import '../support/in_memory_database_repository.dart';

void main() {
  testWidgets(
    'home dashboard shows prototype meta row, workout hero, and removes avatar',
    (tester) async {
      final repository = InMemoryDatabaseRepository();
      final fakeGateway = FakeTodayWorkoutGateway();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseRepositoryProvider.overrideWithValue(repository),
            todayWorkoutGatewayProvider.overrideWithValue(fakeGateway),
            homeDashboardDataProvider.overrideWith(
              (ref) async => _fakeHomeData(),
            ),
          ],
          child: const MaterialApp(home: HomeDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Week 2'), findsWidgets);
      expect(find.textContaining('Day 3'), findsWidgets);
      expect(find.byIcon(Icons.person_outline), findsNothing);
      expect(find.text('Squat e1RM'), findsOneWidget);
    },
  );

  testWidgets('missing plan shows a stable plan selection action', (
    tester,
  ) async {
    final repository = InMemoryDatabaseRepository();
    final fakeGateway = FakeTodayWorkoutGateway();
    final failure = StateError(
      'No active training plan instance. Open Plan Library to start one.',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(repository),
          todayWorkoutGatewayProvider.overrideWithValue(fakeGateway),
          todayWorkoutSummaryProvider.overrideWith(
            (ref) async => throw failure,
          ),
          homeDashboardDataProvider.overrideWith((ref) async => throw failure),
        ],
        child: const MaterialApp(home: HomeDashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Choose a training plan'), findsOneWidget);
    expect(find.byKey(const ValueKey('choose-training-plan')), findsOneWidget);
    expect(find.text('Unable to load workout'), findsNothing);
    expect(
      find.textContaining('No active training plan instance'),
      findsNothing,
    );
  });

  testWidgets('home dashboard keeps affected UI copy in Chinese', (
    tester,
  ) async {
    final repository = InMemoryDatabaseRepository();
    final fakeGateway = FakeTodayWorkoutGateway();
    await repository.saveAppLocale(AppLocale.zh);
    final container = ProviderContainer(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(repository),
        todayWorkoutGatewayProvider.overrideWithValue(fakeGateway),
        homeDashboardDataProvider.overrideWith((ref) async => _fakeHomeData()),
      ],
    );
    addTearDown(container.dispose);
    await container.read(appLocaleProvider.notifier).setLocale(AppLocale.zh);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HomeDashboardScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('第2周 · 第3天'), findsWidgets);
    expect(find.text('周期'), findsOneWidget);
    expect(find.text('三大项力量记录'), findsOneWidget);
    expect(find.text('切换计划'), findsOneWidget);
    expect(find.text('查看全部 PR'), findsOneWidget);
    expect(find.text('Switch plan'), findsNothing);
    expect(find.text('See all PRs'), findsNothing);
    expect(find.text('BIG THREE HISTORY'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('today dashboard fits a phone viewport without vertical scroll', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = InMemoryDatabaseRepository();
    final fakeGateway = FakeTodayWorkoutGateway();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(repository),
          todayWorkoutGatewayProvider.overrideWithValue(fakeGateway),
          homeDashboardDataProvider.overrideWith(
            (ref) async => _fakeHomeData(),
          ),
        ],
        child: const MaterialApp(home: HomeDashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byKey(const ValueKey('today-cycle-card'))),
      tester.getSize(find.byKey(const ValueKey('today-e1rm-card'))),
    );
    final verticalScrollables = tester
        .widgetList<Scrollable>(find.byType(Scrollable))
        .where(
          (widget) =>
              (widget.axisDirection == AxisDirection.down ||
                  widget.axisDirection == AxisDirection.up) &&
              widget.physics is! NeverScrollableScrollPhysics,
        );
    expect(verticalScrollables, isEmpty);
    expect(
      tester
          .getBottomRight(find.byKey(const ValueKey('today-quick-action-1')))
          .dy,
      lessThanOrEqualTo(770),
    );
  });

  testWidgets(
    'Big Three e1RM pages swipe and reflow on short and tall phones',
    (tester) async {
      tester.view.physicalSize = const Size(390, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = InMemoryDatabaseRepository();
      final fakeGateway = FakeTodayWorkoutGateway();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseRepositoryProvider.overrideWithValue(repository),
            todayWorkoutGatewayProvider.overrideWithValue(fakeGateway),
            homeDashboardDataProvider.overrideWith(
              (ref) async => _fakeHomeData(),
            ),
          ],
          child: const MaterialApp(home: HomeDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final pager = find.byKey(const ValueKey('home-e1rm-pager'));
      expect(
        tester
            .widget<TodayWorkoutHeroCard>(find.byType(TodayWorkoutHeroCard))
            .compact,
        isTrue,
      );
      final compactCycleHeight = tester
          .getSize(find.byKey(const ValueKey('today-cycle-card')))
          .height;
      final compactActivityHeight = tester
          .getSize(find.byKey(const ValueKey('today-activity-card')))
          .height;
      await tester.ensureVisible(pager);
      expect(tester.takeException(), isNull);
      expect(find.text('Squat e1RM'), findsOneWidget);
      expect(
        tester
            .widget<FittinBigNum>(
              find.byKey(const ValueKey('home-e1rm-value-squat')),
            )
            .value,
        '125.0',
      );

      await tester.drag(pager, const Offset(-130, 0));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Bench e1RM'), findsOneWidget);
      expect(
        tester
            .widget<FittinBigNum>(
              find.byKey(const ValueKey('home-e1rm-value-bench_press')),
            )
            .value,
        '92.5',
      );
      expect(find.text('+2.5 kg'), findsOneWidget);

      await tester.drag(pager, const Offset(-130, 0));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Deadlift e1RM'), findsOneWidget);
      expect(
        tester
            .widget<FittinBigNum>(
              find.byKey(const ValueKey('home-e1rm-value-deadlift')),
            )
            .value,
        '165.0',
      );
      expect(find.text('-2.5 kg'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('home-e1rm-indicator-squat')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Squat e1RM'), findsOneWidget);
      expect(
        tester
            .widget<FittinBigNum>(
              find.byKey(const ValueKey('home-e1rm-value-squat')),
            )
            .value,
        '125.0',
      );
      expect(find.byType(Sparkline), findsNothing);
      expect(find.byType(StepChart), findsNothing);

      tester.view.physicalSize = const Size(390, 926);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester
            .widget<TodayWorkoutHeroCard>(find.byType(TodayWorkoutHeroCard))
            .compact,
        isFalse,
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('today-cycle-card'))).height,
        greaterThan(compactCycleHeight),
      );
      expect(
        tester
            .getSize(find.byKey(const ValueKey('today-activity-card')))
            .height,
        greaterThan(compactActivityHeight),
      );
      expect(
        tester
            .getBottomRight(find.byKey(const ValueKey('today-quick-action-1')))
            .dy,
        lessThanOrEqualTo(926),
      );
    },
  );
}

HomeDashboardData _fakeHomeData() {
  final summaries = [
    _fakeSummary(
      id: 'squat',
      name: 'Competition Squat',
      previous: 120,
      current: 125,
      date: DateTime(2026, 3, 24),
    ),
    _fakeSummary(
      id: 'bench_press',
      name: 'Bench Press',
      previous: 90,
      current: 92.5,
      date: DateTime(2026, 3, 25),
    ),
    _fakeSummary(
      id: 'deadlift',
      name: 'Deadlift',
      previous: 167.5,
      current: 165,
      date: DateTime(2026, 3, 26),
    ),
  ];
  final summary = summaries.first;

  return HomeDashboardData(
    greetingPeriod: HomeGreetingPeriod.morning,
    displayName: 'Alex',
    todayWorkout: TodayWorkoutSummary(
      instanceId: 'instance-1',
      workoutId: 'day-3',
      workoutName: 'Bench Peak',
      dayLabel: 'Day 3',
      currentWeekNumber: 2,
      currentDayNumber: 3,
      cycleWeekCount: 8,
      workoutsPerWeek: 4,
      primaryExerciseId: 'bench',
      primaryExerciseName: 'Bench Press',
      estimatedDurationMinutes: 80,
      exerciseCount: 5,
    ),
    weekProgress: 0.5,
    cycleProgress: 0.3125,
    sparklineLifts: summaries,
    milestones: [
      PRMilestone(
        date: DateTime(2026, 3, 28),
        exerciseId: 'squat',
        exerciseName: 'Competition Squat',
        type: PRMilestoneType.estimated,
        label: 'New e1RM PR',
        value: 125,
        summary: summary,
      ),
    ],
    hasUnreadMilestones: true,
  );
}

ExerciseProgressSummary _fakeSummary({
  required String id,
  required String name,
  required double previous,
  required double current,
  required DateTime date,
}) {
  return ExerciseProgressSummary(
    exerciseId: id,
    exerciseName: name,
    encounterCount: 2,
    currentEstimatedOneRepMax: current,
    bestEstimatedOneRepMax: previous > current ? previous : current,
    currentActualOneRepMax: null,
    bestActualOneRepMax: null,
    recentChange: current - previous,
    totalVolume: 0,
    lastCompletedAt: date,
    isStagnating: false,
    personalRecords: const [],
    estimatedHistory: [
      ExercisePerformancePoint(
        completedAt: date.subtract(const Duration(days: 14)),
        weight: previous,
        reps: 1,
        value: previous,
        isActual: false,
      ),
      ExercisePerformancePoint(
        completedAt: date,
        weight: current,
        reps: 1,
        value: current,
        isActual: false,
      ),
    ],
    actualHistory: const [],
  );
}
