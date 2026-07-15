import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/exercise_library_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/domain/exercise_library.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/presentation/screens/advanced_analytics_screen.dart';

import '../support/in_memory_database_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ExerciseLibrary exerciseLibrary;

  setUpAll(() async {
    exerciseLibrary = await ExerciseLibraryLoader().load();
  });

  testWidgets('advanced analytics drills into a recorded day', (
    WidgetTester tester,
  ) async {
    final now = DateTime.now();
    final recordedDate = DateTime(now.year, now.month, now.day, 10);
    final recordedDay = DateTime(now.year, now.month, now.day);
    final repository = InMemoryDatabaseRepository();
    await repository.saveTemplate(
      PlanTemplate(
        id: 'template-1',
        name: 'Plan',
        description: 'desc',
        engineFamily: 'linear_tm',
        phases: const [],
      ),
    );
    await repository.saveInstance(
      StoredTrainingInstance(
        instanceId: 'instance-1',
        templateId: 'template-1',
        currentWorkoutIndex: 0,
        createdAt: DateTime(2026, 5, 1),
        updatedAt: DateTime(2026, 5, 1),
        states: const [],
      ),
    );
    await repository.saveActiveInstanceId('instance-1');
    await repository.logWorkout(
      WorkoutLog(
        instanceId: 'instance-1',
        workoutId: 'day-1',
        workoutName: 'Lower A',
        dayLabel: 'Day 1',
        completedAt: recordedDate,
        exercises: const [
          ExerciseLog(
            exerciseId: 'squat',
            exerciseName: 'Squat',
            stageId: 'stage-1',
            sets: [
              SetLog(
                role: 'working',
                targetReps: 5,
                completedReps: 5,
                targetWeight: 100,
                weight: 100,
                isCompleted: true,
              ),
            ],
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(repository),
          exerciseLibraryProvider.overrideWith((ref) async => exerciseLibrary),
        ],
        child: const MaterialApp(home: AdvancedAnalyticsScreen()),
      ),
    );
    await _pumpAnalytics(tester);

    expect(find.textContaining('Consistency'), findsOneWidget);

    final recordedDayCell = find.byKey(
      ValueKey('consistency-day-${recordedDay.toIso8601String()}'),
    );
    final dayCell = tester.widget<InkWell>(recordedDayCell);
    dayCell.onTap!.call();
    await tester.pumpAndSettle();

    expect(find.text('Workout Record Details'), findsOneWidget);
    expect(find.text('Lower A'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete this workout record?'), findsOneWidget);
    expect(await repository.fetchAllWorkoutLogs(), hasLength(1));

    await tester.tap(find.byKey(const ValueKey('confirm-delete-workout')));
    await tester.pumpAndSettle();

    expect(
      find.text('No workout records available for that day.'),
      findsOneWidget,
    );
    expect(await repository.fetchAllWorkoutLogs(), isEmpty);
  });

  testWidgets('advanced analytics localizes labels in Chinese', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryDatabaseRepository();
    await repository.saveAppLocale(AppLocale.zh);
    await repository.logWorkout(
      WorkoutLog(
        instanceId: 'zh-instance',
        workoutId: 'zh-day',
        workoutName: '下肢训练',
        dayLabel: '第1天',
        completedAt: DateTime.now(),
        exercises: const [
          ExerciseLog(
            exerciseId: 'zh-squat-occurrence',
            exerciseDefinitionId: 'squat',
            exerciseName: 'Squat',
            stageId: 'working',
            sets: [
              SetLog(
                role: 'working',
                targetReps: 5,
                completedReps: 5,
                targetWeight: 100,
                weight: 100,
                isCompleted: true,
              ),
            ],
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(repository),
          exerciseLibraryProvider.overrideWith((ref) async => exerciseLibrary),
        ],
        child: const MaterialApp(home: AdvancedAnalyticsScreen()),
      ),
    );
    await _pumpAnalytics(tester);

    expect(find.text('训练一致性'), findsOneWidget);
    expect(find.text('按周'), findsOneWidget);

    await tester.tap(find.text('从计划开始'));
    await tester.pumpAndSettle();
    expect(find.text('第1周'), findsOneWidget);
    expect(find.text('W1'), findsNothing);

    final verticalScroll = _verticalScrollable();
    final muscleLoadTitle = find.text('肌群已完成组贡献');
    await _scrollUntilBuiltAndVisible(
      tester,
      target: muscleLoadTitle,
      scrollable: verticalScroll,
    );
    final muscleChartSemantics = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          (widget.properties.label ?? '').contains('股四头肌'),
    );
    expect(muscleChartSemantics, findsOneWidget);
    expect(
      (tester.widget<Semantics>(muscleChartSemantics).properties.label ?? ''),
      isNot(contains('Quadriceps')),
    );

    final anatomy = find.byKey(const ValueKey('anatomy-front-diagram'));
    await _scrollUntilBuiltAndVisible(
      tester,
      target: anatomy,
      scrollable: verticalScroll,
    );
    expect(find.text('解剖负荷图'), findsOneWidget);
    expect(find.text('正面'), findsOneWidget);
    expect(find.text('ANATOMICAL LOAD MAP'), findsNothing);
    expect(find.text('Front'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('month calendar navigates to an older recorded workout', (
    WidgetTester tester,
  ) async {
    final now = DateTime.now();
    final historicalDate = DateTime(now.year, now.month - 1, 12, 9);
    final historicalDay = DateTime(
      historicalDate.year,
      historicalDate.month,
      historicalDate.day,
    );
    final repository = InMemoryDatabaseRepository();
    await repository.logWorkout(
      WorkoutLog(
        instanceId: 'instance-1',
        workoutId: 'historical-day',
        workoutName: 'Historical Session',
        dayLabel: 'History',
        completedAt: historicalDate,
        exercises: const [
          ExerciseLog(
            exerciseId: 'squat',
            exerciseName: 'Squat',
            stageId: 'stage-1',
            sets: [
              SetLog(
                role: 'working',
                targetReps: 5,
                completedReps: 5,
                targetWeight: 100,
                weight: 100,
                isCompleted: true,
              ),
            ],
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(repository),
          exerciseLibraryProvider.overrideWith((ref) async => exerciseLibrary),
        ],
        child: const MaterialApp(home: AdvancedAnalyticsScreen()),
      ),
    );
    await _pumpAnalytics(tester);

    await tester.tap(find.text('Month'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('calendar-previous-month')));
    await tester.pumpAndSettle();

    final historicalCell = find.byKey(
      ValueKey('calendar-day-${historicalDay.toIso8601String()}'),
    );
    expect(historicalCell, findsOneWidget);
    expect(tester.widget<InkWell>(historicalCell).onTap, isNotNull);

    await tester.tap(historicalCell);
    await tester.pumpAndSettle();
    expect(find.text('Historical Session'), findsOneWidget);
  });

  for (final viewport in const [Size(390, 926), Size(390, 568)]) {
    testWidgets(
      'advanced analytics remains scrollable at ${viewport.width.toInt()}x${viewport.height.toInt()}',
      (tester) async {
        _setViewport(tester, viewport);
        final repository = InMemoryDatabaseRepository();
        await repository.logWorkout(
          WorkoutLog(
            instanceId: 'instance-mobile',
            workoutId: 'day-mobile',
            workoutName: 'Mobile Session',
            dayLabel: 'Day 1',
            completedAt: DateTime(2026, 3, 18, 9),
            exercises: const [
              ExerciseLog(
                exerciseId: 'squat-mobile-occurrence',
                exerciseDefinitionId: 'squat',
                exerciseName: 'Squat',
                stageId: 'stage-1',
                sets: [
                  SetLog(
                    role: 'working',
                    targetReps: 5,
                    completedReps: 5,
                    targetWeight: 100,
                    weight: 100,
                    isCompleted: true,
                  ),
                ],
              ),
            ],
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseRepositoryProvider.overrideWithValue(repository),
              exerciseLibraryProvider.overrideWith(
                (ref) async => exerciseLibrary,
              ),
            ],
            child: const MaterialApp(home: AdvancedAnalyticsScreen()),
          ),
        );
        await _pumpAnalytics(tester);

        expect(find.text('Trends & Analytics'), findsOneWidget);
        expect(find.text('Training Consistency'), findsOneWidget);

        final verticalScroll = _verticalScrollable();
        final position = tester.state<ScrollableState>(verticalScroll).position;
        expect(position.maxScrollExtent, greaterThan(0));

        final anatomy = find.byKey(const ValueKey('anatomy-front-diagram'));
        await _scrollUntilBuiltAndVisible(
          tester,
          target: anatomy,
          scrollable: verticalScroll,
        );
        expect(anatomy, findsOneWidget);
        final anatomyRect = tester.getRect(anatomy);
        expect(anatomyRect.top, lessThan(viewport.height));
        expect(anatomyRect.bottom, greaterThan(0));
        expect(position.pixels, greaterThan(0));
        expect(tester.takeException(), isNull);
      },
    );
  }
}

Future<void> _pumpAnalytics(WidgetTester tester) async {
  for (var attempt = 0; attempt < 20; attempt++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty) {
      return;
    }
  }
  expect(find.byType(CircularProgressIndicator), findsNothing);
}

void _setViewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Finder _verticalScrollable() {
  return find
      .byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      )
      .first;
}

Future<void> _scrollUntilBuiltAndVisible(
  WidgetTester tester, {
  required Finder target,
  required Finder scrollable,
}) async {
  for (var attempt = 0; attempt < 14; attempt++) {
    if (target.evaluate().isNotEmpty) {
      await tester.scrollUntilVisible(target, 220, scrollable: scrollable);
      await tester.pump();
      return;
    }
    await tester.drag(scrollable, const Offset(0, -280));
    await tester.pump();
  }
}
