import 'package:fittin_v2/src/application/exercise_library_provider.dart';
import 'package:fittin_v2/src/domain/exercise_library.dart';
import 'package:fittin_v2/src/domain/exercise_performance_profile.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/domain/one_rep_max.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ExerciseLibrary library;

  setUpAll(() async {
    library = await ExerciseLibraryLoader().load();
  });

  test(
    'canonical ID wins and legacy IDs and names remain resolver fallbacks',
    () {
      final projection = const ExercisePerformanceProfileService().build(
        library: library,
        logs: [
          _log(
            logId: 'canonical',
            date: DateTime(2026, 1, 1),
            exercise: _exercise(
              occurrenceId: 'day-1-main',
              definitionId: 'bench_press',
              name: '深蹲',
              sets: [_set(5, 100)],
            ),
          ),
          _log(
            logId: 'legacy-name',
            date: DateTime(2026, 1, 2),
            exercise: _exercise(
              occurrenceId: 'day-2-main',
              name: 'Back Squat',
              sets: [_set(5, 120)],
            ),
          ),
          _log(
            logId: 'legacy-id',
            date: DateTime(2026, 1, 3),
            exercise: _exercise(
              occurrenceId: 'conventional_deadlift',
              name: 'Untranslated movement',
              sets: [_set(3, 160)],
            ),
          ),
        ],
      );

      expect(projection.profiles.keys, ['bench_press', 'deadlift', 'squat']);
      expect(projection['bench_press']!.observedRepMax(5)!.weightKg, 100);
      expect(projection['squat']!.observedRepMax(5)!.weightKg, 120);
      expect(projection['deadlift']!.observedRepMax(3)!.weightKg, 160);
    },
  );

  test(
    'projects observed RMs, actual singles, estimated 1RM, and provenance',
    () {
      final projection = const ExercisePerformanceProfileService().build(
        library: library,
        formula: OneRepMaxFormula.epley,
        logs: [
          _log(
            logId: 'workout-log-1',
            date: DateTime(2026, 2, 4, 18, 30),
            exercise: _exercise(
              occurrenceId: 'squat-day-1',
              definitionId: 'squat',
              name: 'Squat',
              sets: [
                _set(5, 100),
                _set(20, 60),
                _set(1, 125),
                _set(5, 140, completed: false),
                _set(0, 200),
                _set(3, 0),
              ],
            ),
          ),
        ],
      );

      final profile = projection['squat']!;
      expect(profile.observedRepMaxByReps.keys, [1, 5, 20]);
      expect(profile.observedRepMax(20)!.weightKg, 60);
      expect(profile.actualOneRepMax!.valueKg, 125);
      expect(profile.actualOneRepMax!.formula, isNull);
      expect(profile.actualOneRepMax!.isActual, isTrue);
      expect(profile.actualOneRepMax!.source.logId, 'workout-log-1');
      expect(profile.actualOneRepMax!.source.setIndex, 2);
      expect(profile.actualOneRepMax!.source.workoutReference, 'workout-log-1');
      expect(profile.estimatedOneRepMax!.valueKg, closeTo(116.6667, 0.0001));
      expect(profile.estimatedOneRepMax!.formula, OneRepMaxFormula.epley);
      expect(
        profile.estimatedOneRepMax!.confidence,
        PerformanceConfidence.medium,
      );
      expect(profile.estimatedOneRepMax!.source.completedReps, 5);
    },
  );

  test(
    'high-rep and bodyweight records stay observed without becoming e1RM',
    () {
      final projection = const ExercisePerformanceProfileService().build(
        library: library,
        logs: [
          _log(
            logId: 'pullups',
            date: DateTime(2026, 3, 1),
            exercise: _exercise(
              occurrenceId: 'pull-up-occurrence',
              definitionId: 'pull_up',
              name: 'Pull-Up',
              displayLoadUnit: LoadUnits.bodyweight,
              sets: [_set(1, 20), _set(15, 10)],
            ),
          ),
          _log(
            logId: 'squat-high-rep',
            date: DateTime(2026, 3, 2),
            exercise: _exercise(
              occurrenceId: 'squat-occurrence',
              definitionId: 'squat',
              name: 'Squat',
              sets: [_set(15, 80)],
            ),
          ),
        ],
      );

      final pullUp = projection['pull_up']!;
      expect(pullUp.observedRepMaxByReps.keys, [1, 15]);
      expect(pullUp.isBodyweightOnly, isTrue);
      expect(pullUp.requiresEquipmentCalibration, isFalse);
      expect(pullUp.actualOneRepMax, isNull);
      expect(pullUp.estimatedOneRepMax, isNull);
      expect(projection['squat']!.observedRepMax(15)!.weightKg, 80);
      expect(projection['squat']!.estimatedOneRepMax, isNull);
    },
  );

  test(
    'equal bests choose deterministic latest provenance in any input order',
    () {
      final older = _log(
        logId: 'older',
        date: DateTime(2026, 4, 1),
        exercise: _exercise(
          occurrenceId: 'bench-a',
          definitionId: 'bench_press',
          name: 'Bench',
          sets: [_set(5, 100)],
        ),
      );
      final newer = _log(
        logId: 'newer',
        date: DateTime(2026, 4, 8),
        exercise: _exercise(
          occurrenceId: 'bench-b',
          definitionId: 'bench_press',
          name: '卧推',
          sets: [_set(5, 100)],
        ),
      );
      const service = ExercisePerformanceProfileService();

      final forward = service.build(library: library, logs: [older, newer]);
      final reversed = service.build(library: library, logs: [newer, older]);

      for (final projection in [forward, reversed]) {
        final profile = projection['bench_press']!;
        expect(profile.observedRepMax(5)!.source.logId, 'newer');
        expect(profile.estimatedOneRepMax!.source.logId, 'newer');
        expect(profile.sourceDisplayName, '卧推');
      }
      expect(forward.sourceFingerprint, reversed.sourceFingerprint);
      expect(forward.sourceFingerprint, matches(RegExp(r'^[0-9a-f]{8}$')));
    },
  );

  test(
    'custom identities normalize deterministically and never merge together',
    () {
      final projection = const ExercisePerformanceProfileService().build(
        library: library,
        logs: [
          _log(
            logId: 'custom-a',
            date: DateTime(2026, 5, 1),
            exercise: _exercise(
              occurrenceId: 'row-1',
              name: 'Jefferson Curl',
              sets: [_set(8, 40)],
            ),
          ),
          _log(
            logId: 'custom-a-alias',
            date: DateTime(2026, 5, 2),
            exercise: _exercise(
              occurrenceId: 'row-2',
              name: 'jefferson-curl',
              sets: [_set(8, 45)],
            ),
          ),
          _log(
            logId: 'custom-b',
            date: DateTime(2026, 5, 3),
            exercise: _exercise(
              occurrenceId: 'row-3',
              name: 'Zercher Good Morning',
              sets: [_set(8, 50)],
            ),
          ),
        ],
      );

      expect(projection.profiles, hasLength(2));
      expect(
        projection['custom:jeffersoncurl']!.observedRepMax(8)!.weightKg,
        45,
      );
      expect(
        projection['custom:zerchergoodmorning']!.observedRepMax(8)!.weightKg,
        50,
      );
    },
  );
}

WorkoutLog _log({
  required String logId,
  required DateTime date,
  required ExerciseLog exercise,
}) {
  return WorkoutLog(
    logId: logId,
    instanceId: 'instance',
    workoutId: 'workout-$logId',
    workoutName: 'Workout $logId',
    dayLabel: 'Day',
    completedAt: date,
    exercises: [exercise],
  );
}

ExerciseLog _exercise({
  required String occurrenceId,
  String definitionId = '',
  required String name,
  String displayLoadUnit = LoadUnits.kg,
  required List<SetLog> sets,
}) {
  return ExerciseLog(
    exerciseId: occurrenceId,
    exerciseDefinitionId: definitionId,
    exerciseName: name,
    stageId: 'stage',
    displayLoadUnit: displayLoadUnit,
    sets: sets,
  );
}

SetLog _set(int reps, double weight, {bool completed = true}) {
  return SetLog(
    role: 'working',
    targetReps: reps,
    completedReps: reps,
    targetWeight: weight,
    weight: weight,
    isCompleted: completed,
  );
}
