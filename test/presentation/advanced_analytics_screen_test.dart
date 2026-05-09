import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/presentation/screens/advanced_analytics_screen.dart';

import '../support/in_memory_database_repository.dart';

void main() {
  testWidgets('advanced analytics drills into a recorded day', (
    WidgetTester tester,
  ) async {
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
        completedAt: DateTime(2026, 5, 4, 10),
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
        overrides: [databaseRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: AdvancedAnalyticsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Consistency'), findsOneWidget);

    final recordedDay = find.byKey(
      const ValueKey('consistency-day-2026-05-04T00:00:00.000'),
    );
    final dayCell = tester.widget<InkWell>(recordedDay);
    dayCell.onTap!.call();
    await tester.pumpAndSettle();

    expect(find.text('Workout Record Details'), findsOneWidget);
    expect(find.text('Lower A'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
  });

  testWidgets('advanced analytics localizes labels in Chinese', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryDatabaseRepository();
    await repository.saveAppLocale(AppLocale.zh);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: AdvancedAnalyticsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('训练一致性'), findsOneWidget);
    expect(find.text('按周'), findsOneWidget);
  });
}
