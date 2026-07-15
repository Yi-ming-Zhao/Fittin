import 'package:fittin_v2/src/domain/exercise_library.dart';
import 'package:fittin_v2/src/domain/exercise_performance_profile.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/one_rep_max.dart';
import 'package:fittin_v2/src/domain/plan_start_load_review.dart';
import 'package:fittin_v2/src/domain/starting_load_estimator.dart';

class PlanStartLoadReviewService {
  const PlanStartLoadReviewService({
    this.estimator = const StartingLoadEstimator(),
  });

  final StartingLoadEstimator estimator;

  PlanStartLoadReview build({
    required PlanTemplate template,
    required ExerciseLibrary library,
    required ExercisePerformanceProfileProjection profiles,
    required OneRepMaxFormula formula,
    required String localeCode,
  }) {
    final entries = <PlanStartLoadEntry>[];
    final seenOccurrenceIds = <String>{};

    for (final workout in template.workouts) {
      for (final exercise in workout.exercises) {
        if (!seenOccurrenceIds.add(exercise.id)) {
          continue;
        }
        final resolved = library.resolve(
          exerciseId: exercise.exerciseId,
          name: exercise.name,
        );
        final prescription = _firstWorkingPrescription(exercise);
        final targetReps = prescription?.targetReps ?? 0;
        final targetRir = _targetRir(prescription?.targetRpe);
        final shared = (
          exerciseOccurrenceId: exercise.id,
          exerciseDefinitionId: resolved.id,
          exerciseName: resolved.displayName(localeCode),
          targetReps: targetReps,
          targetRir: targetRir,
        );

        if (exercise.initialBaseWeight > 0) {
          entries.add(
            PlanStartLoadEntry(
              exerciseOccurrenceId: shared.exerciseOccurrenceId,
              exerciseDefinitionId: shared.exerciseDefinitionId,
              exerciseName: shared.exerciseName,
              kind: PlanStartLoadEntryKind.explicitWeight,
              planWeightKg: exercise.initialBaseWeight,
              confirmedWeightKg: exercise.initialBaseWeight,
              targetReps: shared.targetReps,
              targetRir: shared.targetRir,
              recommendation: null,
            ),
          );
          continue;
        }

        if (exercise.trainingMaxLift != null || exercise.usesPercent1rm) {
          entries.add(
            PlanStartLoadEntry(
              exerciseOccurrenceId: shared.exerciseOccurrenceId,
              exerciseDefinitionId: shared.exerciseDefinitionId,
              exerciseName: shared.exerciseName,
              kind: PlanStartLoadEntryKind.trainingMaxPrescription,
              planWeightKg: null,
              confirmedWeightKg: null,
              targetReps: shared.targetReps,
              targetRir: shared.targetRir,
              recommendation: null,
            ),
          );
          continue;
        }

        if (resolved.isSelectionSlot ||
            exercise.loadUnit == LoadUnits.bodyweight) {
          entries.add(
            PlanStartLoadEntry(
              exerciseOccurrenceId: shared.exerciseOccurrenceId,
              exerciseDefinitionId: shared.exerciseDefinitionId,
              exerciseName: shared.exerciseName,
              kind: PlanStartLoadEntryKind.nonNumeric,
              planWeightKg: null,
              confirmedWeightKg: null,
              targetReps: shared.targetReps,
              targetRir: shared.targetRir,
              recommendation: null,
            ),
          );
          continue;
        }

        final recommendation = estimator.estimate(
          library: library,
          exercise: resolved,
          profiles: profiles,
          targetReps: targetReps,
          targetRir: targetRir,
          roundingIncrementKg: exercise.roundingIncrement,
          formula: formula,
        );
        final snapshot = PlanStartRecommendationSnapshot.fromRecommendation(
          recommendation,
        );
        entries.add(
          PlanStartLoadEntry(
            exerciseOccurrenceId: shared.exerciseOccurrenceId,
            exerciseDefinitionId: shared.exerciseDefinitionId,
            exerciseName: shared.exerciseName,
            kind: PlanStartLoadEntryKind.reviewable,
            planWeightKg: null,
            confirmedWeightKg: snapshot.suggestedWeightKg,
            targetReps: shared.targetReps,
            targetRir: shared.targetRir,
            recommendation: snapshot,
          ),
        );
      }
    }

    return PlanStartLoadReview(
      templateId: template.id,
      catalogVersion: library.catalogVersion,
      profileFormulaKey: profiles.formula.key,
      profileSourceFingerprint: profiles.sourceFingerprint,
      entries: entries,
    );
  }
}

SetDefinition? _firstWorkingPrescription(Exercise exercise) {
  if (exercise.stages.isEmpty) {
    return null;
  }
  final sets = exercise.stages.first.sets;
  for (final set in sets) {
    if (set.kind != SetKinds.warmup) {
      return set;
    }
  }
  return sets.isEmpty ? null : sets.first;
}

double _targetRir(double? targetRpe) {
  if (targetRpe == null || !targetRpe.isFinite) {
    return 3;
  }
  return (10 - targetRpe).clamp(0, 10).toDouble();
}
