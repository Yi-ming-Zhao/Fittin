import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/advanced_analytics_provider.dart';
import 'package:fittin_v2/src/application/exercise_library_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/domain/exercise_library.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ExerciseLibrary exerciseLibrary;

  setUpAll(() async {
    exerciseLibrary = await ExerciseLibraryLoader().load();
  });

  test('buildAdvancedAnalytics groups logs and uses real muscle weights', () {
    final logs = [
      _log(DateTime(2026, 3, 2, 10)),
      _log(DateTime(2026, 3, 4, 10)),
      _log(DateTime(2026, 3, 14, 10)),
    ];

    final data = buildAdvancedAnalytics(
      logs: logs,
      exerciseLibrary: exerciseLibrary,
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
      weekSections
          .expand((section) => section.days)
          .where((day) => day.hasActivity),
      isNotEmpty,
    );
    expect(monthSections.length, greaterThanOrEqualTo(4));
    expect(planSections.first.label, 'W1');
    expect(
      planSections
          .expand((section) => section.days)
          .where((day) => day.hasActivity),
      hasLength(3),
    );
    expect(data.muscleLoad.totalCompletedSets, 3);
    expect(
      data.muscleLoad
          .forMuscle(ExerciseMuscle.quadriceps)!
          .weightedCompletedSets,
      closeTo(1.2, 0.0001),
    );
    expect(
      data.muscleLoad.forMuscle(ExerciseMuscle.glutes)!.weightedCompletedSets,
      closeTo(0.9, 0.0001),
    );
    expect(
      data.muscleLoad.forMuscle(ExerciseMuscle.quadriceps)!.normalizedIntensity,
      1,
    );
    expect(data.muscleLoad.loads.first.muscle, ExerciseMuscle.quadriceps);
    expect(data.recordedDates, [
      DateTime(2026, 3, 2),
      DateTime(2026, 3, 4),
      DateTime(2026, 3, 14),
    ]);
    expect(data.earliestRecordedDate, DateTime(2026, 3, 2));
    expect(data.latestRecordedDate, DateTime(2026, 3, 14));
    expect(data.recordFor(DateTime(2026, 3, 4, 23))?.logs, hasLength(1));
  });

  test(
    'muscle aggregation prefers canonical id and falls back to legacy id/name',
    () {
      final overview = aggregateMuscleLoad(
        exerciseLibrary: exerciseLibrary,
        logs: [
          WorkoutLog(
            instanceId: 'instance-1',
            workoutId: 'day-1',
            workoutName: 'Mixed',
            dayLabel: 'Day 1',
            completedAt: DateTime(2026, 3, 2),
            exercises: const [
              ExerciseLog(
                exerciseId: 'occurrence-with-no-catalog-match',
                exerciseDefinitionId: 'bench_press',
                exerciseName: 'Squat',
                stageId: 'stage-1',
                sets: [_completedSet],
              ),
              ExerciseLog(
                exerciseId: 'competition_squat',
                exerciseName: 'Unknown legacy label',
                stageId: 'stage-1',
                sets: [_completedSet],
              ),
              ExerciseLog(
                exerciseId: 'old-occurrence-id',
                exerciseName: 'Barbell Curl',
                stageId: 'stage-1',
                sets: [_completedSet],
              ),
            ],
          ),
        ],
      );

      expect(overview.totalCompletedSets, 3);
      expect(
        overview.forMuscle(ExerciseMuscle.chest)!.weightedCompletedSets,
        closeTo(0.45, 0.0001),
      );
      expect(
        overview.forMuscle(ExerciseMuscle.quadriceps)!.weightedCompletedSets,
        closeTo(0.4, 0.0001),
      );
      expect(
        overview.forMuscle(ExerciseMuscle.biceps)!.weightedCompletedSets,
        closeTo(0.75, 0.0001),
      );
    },
  );

  test('incomplete and skipped sets are excluded and period is honored', () {
    final included = WorkoutLog(
      instanceId: 'instance-1',
      workoutId: 'included',
      workoutName: 'Included',
      dayLabel: 'Day 1',
      completedAt: DateTime(2026, 3, 15),
      exercises: const [
        ExerciseLog(
          exerciseId: 'bench-occurrence',
          exerciseDefinitionId: 'bench_press',
          exerciseName: 'Bench Press',
          stageId: 'stage-1',
          sets: [
            _completedSet,
            SetLog(
              role: 'working',
              targetReps: 5,
              completedReps: 5,
              targetWeight: 100,
              weight: 100,
            ),
            SetLog(
              role: 'working',
              targetReps: 5,
              completedReps: 0,
              targetWeight: 100,
              weight: 100,
              isCompleted: true,
            ),
          ],
        ),
      ],
    );
    final excludedByPeriod = _log(DateTime(2026, 1, 1));

    final overview = aggregateMuscleLoad(
      logs: [excludedByPeriod, included],
      exerciseLibrary: exerciseLibrary,
      period: AnalyticsDateRange(
        startInclusive: DateTime(2026, 3, 1),
        endInclusive: DateTime(2026, 3, 31, 23, 59, 59),
      ),
    );

    expect(overview.totalCompletedSets, 1);
    expect(
      overview.forMuscle(ExerciseMuscle.chest)!.weightedCompletedSets,
      closeTo(0.45, 0.0001),
    );
    expect(overview.forMuscle(ExerciseMuscle.quadriceps), isNull);
  });
}

const _completedSet = SetLog(
  role: 'working',
  targetReps: 5,
  completedReps: 5,
  targetWeight: 100,
  weight: 100,
  isCompleted: true,
);

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
        sets: [_completedSet],
      ),
    ],
  );
}
