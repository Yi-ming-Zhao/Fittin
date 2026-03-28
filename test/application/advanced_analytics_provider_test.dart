import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/advanced_analytics_provider.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/domain/one_rep_max.dart';

void main() {
  test('buildAdvancedAnalytics groups logs by week, month, and plan start', () {
    final logs = [
      _log(DateTime(2026, 3, 2, 10)),
      _log(DateTime(2026, 3, 4, 10)),
      _log(DateTime(2026, 3, 14, 10)),
    ];

    final overview = buildProgressAnalytics(logs, OneRepMaxFormula.epley);
    final data = buildAdvancedAnalytics(
      logs: logs,
      overview: overview,
      activeInstance: StoredTrainingInstance(
        instanceId: 'instance-1',
        templateId: 'template-1',
        currentWorkoutIndex: 0,
        createdAt: DateTime(2026, 3, 1),
        updatedAt: DateTime(2026, 3, 1),
        states: const [],
      ),
      now: DateTime(2026, 3, 20),
    );

    final weekSections = data.sectionsByRange[ConsistencyRange.week]!;
    final monthSections = data.sectionsByRange[ConsistencyRange.month]!;
    final planSections = data.sectionsByRange[ConsistencyRange.plan]!;

    expect(
      weekSections.expand((section) => section.days).where((day) => day.hasActivity),
      isNotEmpty,
    );
    expect(monthSections.length, greaterThanOrEqualTo(4));
    expect(planSections.first.label, 'W1');
    expect(
      planSections.expand((section) => section.days).where((day) => day.hasActivity),
      hasLength(3),
    );
  });
}

WorkoutLog _log(DateTime completedAt) {
  return WorkoutLog(
    instanceId: 'instance-1',
    workoutId: 'day-${completedAt.day}',
    workoutName: 'Workout ${completedAt.day}',
    dayLabel: 'Day ${completedAt.day}',
    completedAt: completedAt,
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
  );
}
