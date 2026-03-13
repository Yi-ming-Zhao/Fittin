import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/domain/one_rep_max.dart';
import 'package:fittin_v2/src/presentation/screens/progress_analytics_screen.dart';

import '../support/in_memory_database_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('analytics screen renders exercise progress and formula picker', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryDatabaseRepository();
    await repository.logWorkout(
      WorkoutLog(
        instanceId: 'a',
        workoutId: 'day1',
        workoutName: 'Day 1',
        dayLabel: 'Day 1',
        completedAt: DateTime(2026, 1, 1),
        exercises: [
          const ExerciseLog(
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
        ],
        child: const MaterialApp(home: ProgressAnalyticsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Progress Analytics'), findsOneWidget);
    expect(find.text('Squat'), findsWidgets);
    expect(find.text('Epley'), findsOneWidget);

    await tester.tap(find.text('Epley'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Brzycki').last);
    await tester.pumpAndSettle();

    expect(
      ProviderScope.containerOf(
        tester.element(find.byType(ProgressAnalyticsScreen)),
      ).read(analyticsFormulaProvider),
      OneRepMaxFormula.brzycki,
    );
  });
}
