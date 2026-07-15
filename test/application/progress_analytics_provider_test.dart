import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/exercise_library_provider.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/domain/one_rep_max.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  test(
    'canonical resolver merges new global IDs and legacy occurrence/name records',
    () async {
      final library = await ExerciseLibraryLoader().load();
      final logs = [
        _singleExerciseLog(
          completedAt: DateTime(2026, 2, 1),
          occurrenceId: 'bench-day-1',
          canonicalId: 'bench_press',
          name: 'Legacy display that must not win',
          weight: 80,
        ),
        _singleExerciseLog(
          completedAt: DateTime(2026, 2, 8),
          occurrenceId: 'bench-day-2',
          name: 'Bench',
          weight: 82.5,
        ),
        _singleExerciseLog(
          completedAt: DateTime(2026, 2, 15),
          occurrenceId: 'another-plan-bench',
          name: '杠铃卧推',
          weight: 85,
        ),
      ];

      final overview = buildProgressAnalytics(
        logs,
        OneRepMaxFormula.epley,
        exerciseLibrary: library,
        localeCode: 'zh',
      );

      expect(overview.exerciseSummaries, hasLength(1));
      final bench = overview.exerciseSummaries.single;
      expect(bench.exerciseId, 'bench_press');
      expect(bench.exerciseName, '卧推');
      expect(bench.encounterCount, 3);
      expect(bench.estimatedHistory, hasLength(3));
    },
  );
}

WorkoutLog _singleExerciseLog({
  required DateTime completedAt,
  required String occurrenceId,
  String canonicalId = '',
  required String name,
  required double weight,
}) {
  return WorkoutLog(
    instanceId: 'instance',
    workoutId: 'workout-${completedAt.day}',
    workoutName: 'Workout',
    dayLabel: 'Day',
    completedAt: completedAt,
    exercises: [
      ExerciseLog(
        exerciseId: occurrenceId,
        exerciseDefinitionId: canonicalId,
        exerciseName: name,
        stageId: 'working',
        sets: [
          SetLog(
            role: 'working',
            targetReps: 5,
            completedReps: 5,
            targetWeight: weight,
            weight: weight,
            isCompleted: true,
          ),
        ],
      ),
    ],
  );
}
