import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/domain/one_rep_max.dart';

void main() {
  test('buildProgressAnalytics separates estimated and actual 1RM', () {
    final logs = [
      WorkoutLog(
        instanceId: 'a',
        workoutId: 'day1',
        workoutName: 'Day 1',
        dayLabel: 'Day 1',
        completedAt: DateTime(2026, 1, 1),
        exercises: [
          ExerciseLog(
            exerciseId: 'squat',
            exerciseName: 'Squat',
            stageId: 'stage-1',
            sets: const [
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
      WorkoutLog(
        instanceId: 'a',
        workoutId: 'day2',
        workoutName: 'Day 2',
        dayLabel: 'Day 2',
        completedAt: DateTime(2026, 1, 8),
        exercises: [
          ExerciseLog(
            exerciseId: 'squat',
            exerciseName: 'Squat',
            stageId: 'stage-2',
            sets: const [
              SetLog(
                role: 'working',
                targetReps: 1,
                completedReps: 1,
                targetWeight: 120,
                weight: 120,
                isCompleted: true,
              ),
            ],
          ),
        ],
      ),
    ];

    final overview = buildProgressAnalytics(logs, OneRepMaxFormula.epley);
    final squat = overview.exerciseSummaries.single;

    expect(squat.currentActualOneRepMax, 120);
    expect(squat.bestActualOneRepMax, 120);
    expect(squat.bestEstimatedOneRepMax, greaterThan(116));
    expect(squat.personalRecords, contains('1RM PR'));
  });
}
