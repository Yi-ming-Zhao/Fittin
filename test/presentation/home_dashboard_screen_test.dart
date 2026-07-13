import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/home_dashboard_provider.dart';
import 'package:fittin_v2/src/application/pr_dashboard_provider.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:fittin_v2/src/presentation/screens/home_dashboard_screen.dart';

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
      expect(find.text('Competition Squat'), findsWidgets);
    },
  );

  testWidgets('missing plan error is shown only once', (tester) async {
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

    expect(
      find.textContaining('No active training plan instance'),
      findsOneWidget,
    );
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
}

HomeDashboardData _fakeHomeData() {
  final summary = ExerciseProgressSummary(
    exerciseId: 'squat',
    exerciseName: 'Competition Squat',
    encounterCount: 2,
    currentEstimatedOneRepMax: 125,
    bestEstimatedOneRepMax: 125,
    currentActualOneRepMax: null,
    bestActualOneRepMax: null,
    recentChange: 5,
    totalVolume: 0,
    lastCompletedAt: DateTime(2026, 3, 24),
    isStagnating: false,
    personalRecords: const [],
    estimatedHistory: [
      ExercisePerformancePoint(
        completedAt: DateTime(2026, 3, 10),
        weight: 100,
        reps: 5,
        value: 120,
        isActual: false,
      ),
      ExercisePerformancePoint(
        completedAt: DateTime(2026, 3, 24),
        weight: 105,
        reps: 5,
        value: 125,
        isActual: false,
      ),
    ],
    actualHistory: const [],
  );

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
    sparklineLifts: [summary],
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
