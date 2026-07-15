import 'package:fittin_v2/src/application/exercise_library_provider.dart';
import 'package:fittin_v2/src/domain/exercise_library.dart';
import 'package:fittin_v2/src/domain/exercise_performance_profile.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/domain/one_rep_max.dart';
import 'package:fittin_v2/src/domain/starting_load_estimator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ExerciseLibrary library;
  const profileService = ExercisePerformanceProfileService();
  const estimator = StartingLoadEstimator();

  setUpAll(() async {
    library = await ExerciseLibraryLoader().load();
  });

  test('preserves explicit load without rounding or estimating', () {
    final profiles = profileService.build(library: library, logs: const []);
    final recommendation = estimator.estimate(
      library: library,
      exercise: library.resolve(name: 'Lat Pulldown'),
      profiles: profiles,
      targetReps: 10,
      existingWeightKg: 53.2,
    );

    expect(recommendation.weightKg, 53.2);
    expect(recommendation.rawWeightKg, 53.2);
    expect(recommendation.isAutomaticEstimate, isFalse);
    expect(recommendation.provenance.source, StartingLoadSource.existingWeight);
    expect(recommendation.safetyFactor, 1);
    expect(recommendation.warnings, isEmpty);
  });

  test('same-exercise observed RM wins and includes target RIR', () {
    final profiles = _profiles(
      library,
      exerciseId: 'squat',
      name: 'Squat',
      sets: [_set(5, 100)],
    );
    final recommendation = estimator.estimate(
      library: library,
      exercise: library.resolve(name: '深蹲'),
      profiles: profiles,
      targetReps: 3,
      targetRir: 2,
    );

    expect(recommendation.effectiveReps, 5);
    expect(recommendation.rawWeightKg, 100);
    expect(recommendation.safetyFactor, 0.95);
    expect(recommendation.weightKg, 95);
    expect(recommendation.confidence, PerformanceConfidence.high);
    expect(
      recommendation.provenance.source,
      StartingLoadSource.sameExerciseObservedRm,
    );
    expect(recommendation.provenance.sourceObservedReps, 5);
    expect(recommendation.provenance.sourceSet!.completedReps, 5);
    expect(recommendation.provenance.conversionFormula, isNull);
  });

  test('actual single precedes formula-derived same-exercise capacity', () {
    final profiles = _profiles(
      library,
      exerciseId: 'squat',
      name: 'Squat',
      sets: [_set(1, 100), _set(3, 95)],
    );
    final recommendation = estimator.estimate(
      library: library,
      exercise: library.resolve(name: 'Squat'),
      profiles: profiles,
      targetReps: 5,
      targetRir: 0,
      formula: OneRepMaxFormula.epley,
    );

    expect(recommendation.rawWeightKg, closeTo(85.7142, 0.0001));
    expect(recommendation.weightKg, 80);
    expect(
      recommendation.provenance.source,
      StartingLoadSource.sameExerciseActualOneRepMax,
    );
    expect(recommendation.provenance.sourceValueKg, 100);
    expect(recommendation.provenance.conversionFormula, OneRepMaxFormula.epley);
    expect(
      recommendation.warnings,
      contains(StartingLoadWarningCode.formulaBasedConversion),
    );
  });

  test('same-exercise estimated 1RM carries formula and lower confidence', () {
    final profiles = _profiles(
      library,
      exerciseId: 'overhead_press',
      name: 'Overhead Press',
      sets: [_set(5, 60)],
    );
    final recommendation = estimator.estimate(
      library: library,
      exercise: library.resolve(name: 'Overhead Press'),
      profiles: profiles,
      targetReps: 8,
      targetRir: 0,
      formula: OneRepMaxFormula.epley,
    );

    expect(recommendation.rawWeightKg, closeTo(55.2631, 0.0001));
    expect(recommendation.weightKg, 47.5);
    expect(recommendation.confidence, PerformanceConfidence.medium);
    expect(
      recommendation.provenance.source,
      StartingLoadSource.sameExerciseEstimatedOneRepMax,
    );
    expect(recommendation.provenance.sourceFormula, OneRepMaxFormula.epley);
    expect(
      recommendation.warnings,
      contains(StartingLoadWarningCode.estimatedOneRepMaxSource),
    );
  });

  test(
    'anchor ratio applies target reps, confidence safety, and round-down',
    () {
      final profiles = _profiles(
        library,
        exerciseId: 'squat',
        name: 'Squat',
        sets: [_set(1, 200)],
      );
      final recommendation = estimator.estimate(
        library: library,
        exercise: library.resolve(name: 'High-Bar Squat'),
        profiles: profiles,
        targetReps: 5,
        targetRir: 1,
        formula: OneRepMaxFormula.epley,
      );

      expect(recommendation.rawWeightKg, closeTo(150, 0.0001));
      expect(recommendation.safetyFactor, 0.85);
      expect(recommendation.weightKg, 127.5);
      expect(recommendation.confidence, PerformanceConfidence.low);
      expect(recommendation.provenance.source, StartingLoadSource.anchorRatio);
      expect(recommendation.provenance.sourceExerciseId, 'squat');
      expect(recommendation.provenance.sourceValueKg, 200);
      expect(recommendation.provenance.anchorFamily, StrengthFamily.squat);
      expect(recommendation.provenance.ratioCenter, 0.9);
      expect(recommendation.provenance.ratioLower, 0.8);
      expect(recommendation.provenance.ratioUpper, 0.98);
      expect(recommendation.provenance.catalogVersion, library.catalogVersion);
      expect(
        recommendation.warnings,
        containsAll([
          StartingLoadWarningCode.catalogRatioPrior,
          StartingLoadWarningCode.ratioRangeIsNotGuarantee,
          StartingLoadWarningCode.lowConfidence,
        ]),
      );
    },
  );

  test('machine and cable values require same-equipment calibration', () {
    final profiles = _profiles(
      library,
      exerciseId: 'lat_pulldown',
      name: 'Lat Pulldown',
      displayLoadUnit: LoadUnits.cableStack,
      sets: [_set(10, 60)],
    );
    final exercise = library.resolve(name: 'Lat Pulldown');

    final blocked = estimator.estimate(
      library: library,
      exercise: exercise,
      profiles: profiles,
      targetReps: 10,
      targetRir: 0,
    );
    expect(blocked.hasNumericLoad, isFalse);
    expect(
      blocked.warnings,
      contains(StartingLoadWarningCode.equipmentCalibrationRequired),
    );

    final calibrated = estimator.estimate(
      library: library,
      exercise: exercise,
      profiles: profiles,
      targetReps: 10,
      targetRir: 0,
      equipmentCalibrationConfirmed: true,
    );
    expect(calibrated.weightKg, 50);
    expect(calibrated.confidence, PerformanceConfidence.low);
    expect(
      calibrated.provenance.source,
      StartingLoadSource.sameExerciseObservedRm,
    );
    expect(
      calibrated.warnings,
      containsAll([
        StartingLoadWarningCode.equipmentSpecificLoad,
        StartingLoadWarningCode.lowConfidence,
      ]),
    );
  });

  test('bodyweight-only exercise never receives a numeric kg suggestion', () {
    final profiles = _profiles(
      library,
      exerciseId: 'pull_up',
      name: 'Pull-Up',
      displayLoadUnit: LoadUnits.bodyweight,
      sets: [_set(5, 20)],
    );
    final recommendation = estimator.estimate(
      library: library,
      exercise: library.resolve(name: 'Pull-Up'),
      profiles: profiles,
      targetReps: 5,
    );

    expect(recommendation.hasNumericLoad, isFalse);
    expect(
      recommendation.warnings,
      contains(StartingLoadWarningCode.bodyweightLoadUnsupported),
    );
  });

  test('custom cable history also requires equipment calibration', () {
    final profiles = _profiles(
      library,
      exerciseId: 'custom:oldgymstackrow',
      name: 'Old Gym Stack Row',
      displayLoadUnit: LoadUnits.cableStack,
      sets: [_set(10, 50)],
    );
    final recommendation = estimator.estimate(
      library: library,
      exercise: library.resolve(
        exerciseId: 'custom:oldgymstackrow',
        name: 'Old Gym Stack Row',
      ),
      profiles: profiles,
      targetReps: 10,
    );

    expect(recommendation.hasNumericLoad, isFalse);
    expect(
      recommendation.warnings,
      contains(StartingLoadWarningCode.equipmentCalibrationRequired),
    );
  });

  test(
    'high target reps need an exact observed RM instead of extrapolation',
    () {
      final withoutExact = _profiles(
        library,
        exerciseId: 'barbell_row',
        name: 'Barbell Row',
        sets: [_set(8, 80)],
      );
      final exercise = library.resolve(name: 'Barbell Row');
      final blocked = estimator.estimate(
        library: library,
        exercise: exercise,
        profiles: withoutExact,
        targetReps: 12,
        targetRir: 0,
      );
      expect(blocked.hasNumericLoad, isFalse);
      expect(
        blocked.warnings,
        contains(StartingLoadWarningCode.targetRepsOutsideFormulaRange),
      );

      final withExact = _profiles(
        library,
        exerciseId: 'barbell_row',
        name: 'Barbell Row',
        sets: [_set(12, 60)],
      );
      final suggested = estimator.estimate(
        library: library,
        exercise: exercise,
        profiles: withExact,
        targetReps: 12,
        targetRir: 0,
      );
      expect(suggested.rawWeightKg, 60);
      expect(suggested.weightKg, 55);
      expect(
        suggested.provenance.source,
        StartingLoadSource.sameExerciseObservedRm,
      );
    },
  );

  test('fractional RIR rounds effective reps upward conservatively', () {
    final profiles = _profiles(
      library,
      exerciseId: 'bench_press',
      name: 'Bench Press',
      sets: [_set(5, 100)],
    );
    final recommendation = estimator.estimate(
      library: library,
      exercise: library.resolve(name: 'Bench Press'),
      profiles: profiles,
      targetReps: 4,
      targetRir: 0.5,
    );

    expect(recommendation.effectiveReps, 5);
    expect(recommendation.weightKg, 95);
    expect(
      recommendation.warnings,
      contains(StartingLoadWarningCode.fractionalRirRoundedUp),
    );
  });

  test('missing effort defaults to a conservative three reps in reserve', () {
    final profiles = _profiles(
      library,
      exerciseId: 'squat',
      name: 'Squat',
      sets: [_set(8, 80)],
    );
    final recommendation = estimator.estimate(
      library: library,
      exercise: library.resolve(name: 'Squat'),
      profiles: profiles,
      targetReps: 5,
    );

    expect(recommendation.targetRir, 3);
    expect(recommendation.effectiveReps, 8);
    expect(recommendation.rawWeightKg, 80);
  });

  test(
    'missing same-exercise and anchor data returns structured no-estimate',
    () {
      final profiles = profileService.build(library: library, logs: const []);
      final recommendation = estimator.estimate(
        library: library,
        exercise: library.resolve(name: 'Close-Grip Bench Press'),
        profiles: profiles,
        targetReps: 8,
        targetRir: 0,
      );

      expect(recommendation.hasNumericLoad, isFalse);
      expect(recommendation.confidence, PerformanceConfidence.unavailable);
      expect(recommendation.provenance.source, StartingLoadSource.unavailable);
      expect(
        recommendation.warnings,
        containsAll([
          StartingLoadWarningCode.noSameExerciseData,
          StartingLoadWarningCode.noAnchorData,
        ]),
      );
    },
  );
}

ExercisePerformanceProfileProjection _profiles(
  ExerciseLibrary library, {
  required String exerciseId,
  required String name,
  String displayLoadUnit = LoadUnits.kg,
  required List<SetLog> sets,
}) {
  return const ExercisePerformanceProfileService().build(
    library: library,
    logs: [
      WorkoutLog(
        logId: 'source-log',
        instanceId: 'instance',
        workoutId: 'day-1',
        workoutName: 'Day 1',
        dayLabel: 'Day 1',
        completedAt: DateTime(2026, 6, 1),
        exercises: [
          ExerciseLog(
            exerciseId: 'occurrence-$exerciseId',
            exerciseDefinitionId: exerciseId,
            exerciseName: name,
            stageId: 'stage',
            displayLoadUnit: displayLoadUnit,
            sets: sets,
          ),
        ],
      ),
    ],
  );
}

SetLog _set(int reps, double weight) {
  return SetLog(
    role: 'working',
    targetReps: reps,
    completedReps: reps,
    targetWeight: weight,
    weight: weight,
    isCompleted: true,
  );
}
