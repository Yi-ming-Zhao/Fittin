import 'package:fittin_v2/src/application/exercise_library_provider.dart';
import 'package:fittin_v2/src/application/plan_start_load_review_service.dart';
import 'package:fittin_v2/src/data/seeds/seed_utils.dart';
import 'package:fittin_v2/src/domain/exercise_library.dart';
import 'package:fittin_v2/src/domain/exercise_performance_profile.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/domain/one_rep_max.dart';
import 'package:fittin_v2/src/domain/plan_start_load_review.dart';
import 'package:fittin_v2/src/domain/starting_load_estimator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ExerciseLibrary library;

  setUpAll(() async {
    library = await ExerciseLibraryLoader().load();
  });

  test(
    'reviews only missing numeric loads and preserves prescription priority',
    () {
      final template = _reviewTemplate();
      final profiles = const ExercisePerformanceProfileService().build(
        library: library,
        logs: [_benchLog(100)],
      );
      final review = const PlanStartLoadReviewService().build(
        template: template,
        library: library,
        profiles: profiles,
        formula: OneRepMaxFormula.epley,
        localeCode: 'en',
      );

      expect(review.entries, hasLength(5));
      expect(review.catalogVersion, library.catalogVersion);
      expect(review.profileSourceFingerprint, profiles.sourceFingerprint);

      final explicit = _entry(review, 'explicit-row');
      expect(explicit.kind, PlanStartLoadEntryKind.explicitWeight);
      expect(explicit.planWeightKg, 70);
      expect(explicit.recommendation, isNull);

      final trainingMax = _entry(review, 'tm-bench');
      expect(trainingMax.kind, PlanStartLoadEntryKind.trainingMaxPrescription);
      expect(trainingMax.recommendation, isNull);

      final assistance = _entry(review, 'missing-close-grip');
      expect(assistance.kind, PlanStartLoadEntryKind.reviewable);
      expect(assistance.confirmedWeightKg, greaterThan(0));
      expect(assistance.recommendation!.source, StartingLoadSource.anchorRatio);
      expect(assistance.recommendation!.sourceExerciseId, 'bench_press');

      final cable = _entry(review, 'missing-cable');
      expect(cable.kind, PlanStartLoadEntryKind.reviewable);
      expect(cable.confirmedWeightKg, isNull);
      expect(cable.targetRir, 3);
      expect(
        cable.recommendation!.warnings,
        contains(StartingLoadWarningCode.equipmentCalibrationRequired),
      );

      final bodyweight = _entry(review, 'bodyweight-row');
      expect(bodyweight.kind, PlanStartLoadEntryKind.nonNumeric);
      expect(bodyweight.isEditable, isFalse);
      expect(review.editableEntries, hasLength(2));
    },
  );

  test(
    'edited confirmation retains recommendation provenance after JSON reload',
    () {
      final profiles = const ExercisePerformanceProfileService().build(
        library: library,
        logs: [_benchLog(100)],
      );
      final original = const PlanStartLoadReviewService().build(
        template: _reviewTemplate(),
        library: library,
        profiles: profiles,
        formula: OneRepMaxFormula.epley,
        localeCode: 'zh',
      );
      final originalSuggestion = _entry(
        original,
        'missing-close-grip',
      ).recommendation!.suggestedWeightKg;
      final confirmed = original.withConfirmedWeights({
        'missing-close-grip': 72.5,
        'missing-cable': 45,
      });
      final restored = PlanStartLoadReview.fromJson(confirmed.toJson());
      final restoredAssistance = _entry(restored, 'missing-close-grip');

      expect(restoredAssistance.exerciseName, contains('卧推'));
      expect(restoredAssistance.confirmedWeightKg, 72.5);
      expect(restoredAssistance.wasEdited, isTrue);
      expect(
        restoredAssistance.recommendation!.suggestedWeightKg,
        originalSuggestion,
      );
      expect(
        restoredAssistance.recommendation!.sourceWorkoutReference,
        'bench-history',
      );
      expect(
        restoredAssistance.recommendation!.ratioCenter,
        closeTo(0.93, 0.0001),
      );
      expect(restored.profileSourceFingerprint, profiles.sourceFingerprint);
      expect(restored.confirmedOverridesKg, {
        'missing-close-grip': 72.5,
        'missing-cable': 45,
      });

      final engineState = engineStateWithPlanStartLoadReview(const {
        'currentWeekIndex': 0,
      }, restored);
      final reloadedFromInstance = planStartLoadReviewFromEngineState(
        engineState,
      );
      expect(reloadedFromInstance!.toJson(), restored.toJson());
    },
  );

  test(
    'starter states reject overrides for explicit and training-max loads',
    () {
      final template = _reviewTemplate();
      final states = buildStarterStatesForTemplate(
        template,
        trainingMaxProfile: const TrainingMaxProfile({'bench': 100}),
        startingLoadOverridesKg: const {
          'explicit-row': 999,
          'tm-bench': 999,
          'missing-close-grip': 72.5,
        },
      );
      final byId = {for (final state in states) state.exerciseId: state};

      expect(byId['explicit-row']!.baseWeight, 70);
      expect(byId['tm-bench']!.baseWeight, 80);
      expect(byId['missing-close-grip']!.baseWeight, 72.5);
    },
  );
}

PlanStartLoadEntry _entry(PlanStartLoadReview review, String id) {
  return review.entries.singleWhere(
    (entry) => entry.exerciseOccurrenceId == id,
  );
}

PlanTemplate _reviewTemplate() {
  return PlanTemplate(
    id: 'review-template',
    name: 'Review Template',
    description: 'Starting load review',
    engineFamily: 'linear_tm',
    requiredTrainingMaxKeys: const ['bench'],
    phases: [
      Phase(
        id: 'phase',
        name: 'Phase',
        workouts: [
          Workout(
            id: 'day',
            name: 'Day',
            exercises: [
              _exercise(
                id: 'explicit-row',
                exerciseId: 'barbell_row',
                name: 'Barbell Row',
                initialWeight: 70,
              ),
              _exercise(
                id: 'tm-bench',
                exerciseId: 'bench_press',
                name: 'Bench Press',
                trainingMaxLift: 'bench',
                trainingMaxMultiplier: 0.8,
              ),
              _exercise(
                id: 'missing-close-grip',
                exerciseId: 'close_grip_bench_press',
                name: 'Close-Grip Bench Press',
                targetRpe: 8,
              ),
              _exercise(
                id: 'missing-cable',
                exerciseId: 'lat_pulldown',
                name: 'Lat Pulldown',
                loadUnit: LoadUnits.cableStack,
              ),
              _exercise(
                id: 'bodyweight-row',
                exerciseId: 'pull_up',
                name: 'Pull-Up',
                loadUnit: LoadUnits.bodyweight,
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

Exercise _exercise({
  required String id,
  required String exerciseId,
  required String name,
  double initialWeight = 0,
  String? trainingMaxLift,
  double trainingMaxMultiplier = 1,
  String loadUnit = LoadUnits.kg,
  double? targetRpe,
}) {
  return Exercise(
    id: id,
    exerciseId: exerciseId,
    name: name,
    initialBaseWeight: initialWeight,
    trainingMaxLift: trainingMaxLift,
    trainingMaxMultiplier: trainingMaxMultiplier,
    loadUnit: loadUnit,
    stages: [
      SetScheme(
        id: 'stage-$id',
        name: 'Stage',
        sets: [
          SetDefinition(targetReps: 5, intensity: 1, targetRpe: targetRpe),
        ],
        rules: const [],
      ),
    ],
  );
}

WorkoutLog _benchLog(double weight) {
  return WorkoutLog(
    logId: 'bench-history',
    instanceId: 'old-instance',
    workoutId: 'old-day',
    workoutName: 'Old Day',
    dayLabel: 'Day',
    completedAt: DateTime(2026, 1, 1),
    exercises: [
      ExerciseLog(
        exerciseId: 'old-bench-occurrence',
        exerciseDefinitionId: 'bench_press',
        exerciseName: 'Bench Press',
        stageId: 'stage',
        sets: [
          SetLog(
            role: 'working',
            targetReps: 1,
            completedReps: 1,
            targetWeight: weight,
            weight: weight,
            isCompleted: true,
          ),
        ],
      ),
    ],
  );
}
