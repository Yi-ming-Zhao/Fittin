import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';

Future<PlanTemplate> loadTemplateAsset({
  required String assetPath,
  required String expectedTemplateId,
}) async {
  final jsonString = await rootBundle.loadString(assetPath);
  final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
  final template = _normalizeSeedTemplate(PlanTemplate.fromJson(jsonMap));
  if (template.id != expectedTemplateId) {
    throw StateError(
      'Unexpected template id "${template.id}". Expected "$expectedTemplateId".',
    );
  }
  return template;
}

PlanTemplate _normalizeSeedTemplate(PlanTemplate template) {
  return template.copyWith(
    phases: [
      for (final phase in template.phases)
        phase.copyWith(
          workouts: [
            for (final workout in phase.workouts)
              workout.copyWith(
                exercises: [
                  for (final exercise in workout.exercises)
                    exercise.copyWith(
                      equipmentType: exercise.isBarbell
                          ? EquipmentTypes.barbell
                          : exercise.equipmentType,
                      trainingMaxLift:
                          exercise.trainingMaxLift ??
                          _inferTrainingMaxLift(exercise),
                    ),
                ],
              ),
          ],
        ),
    ],
  );
}

String? _inferTrainingMaxLift(Exercise exercise) {
  final id = exercise.exerciseId.toLowerCase();
  const benchMapped = {
    'close_grip_bench_press',
    'pause_bench_press',
    'slingshot_bench_press',
    'incline_bench_press',
    'narrow_bench_press',
  };
  if (benchMapped.contains(id)) {
    return 'bench';
  }
  if (id.contains('front_squat') || id.contains('pause_squat')) {
    return 'squat';
  }
  if (id.contains('romanian_deadlift') || id.contains('deficit_deadlift')) {
    return 'deadlift';
  }
  if (id.contains('push_press')) {
    return 'overhead_press';
  }
  return null;
}

List<TrainingState> buildStarterStatesForTemplate(
  PlanTemplate template, {
  TrainingMaxProfile trainingMaxProfile = TrainingMaxProfile.empty,
  Map<String, double> startingLoadOverridesKg = const {},
}) {
  return [
    for (final workout in template.workouts)
      for (final exercise in workout.exercises)
        TrainingState(
          workoutId: workout.id,
          exerciseId: exercise.id,
          exerciseName: exercise.name,
          baseWeight: _resolveStarterBaseWeight(
            template: template,
            exercise: exercise,
            trainingMaxProfile: trainingMaxProfile,
            startingLoadOverrideKg: startingLoadOverridesKg[exercise.id],
          ),
          currentStageId: exercise.stages.first.id,
        ),
  ];
}

Map<String, dynamic> buildInitialEngineState(PlanTemplate template) {
  if (template.engineFamily == 'periodized_tm') {
    final firstWorkout = template.workouts.isEmpty
        ? null
        : template.workouts.first;
    final firstExercise = firstWorkout == null || firstWorkout.exercises.isEmpty
        ? null
        : firstWorkout.exercises.first;
    final cycleLengthWeeks =
        (template.engineConfig['cycleLengthWeeks'] as num?)?.toInt() ??
        firstExercise?.stages.length ??
        1;
    return {
      'currentWeekIndex': 0,
      'currentBlockIndex': 0,
      'cycleLengthWeeks': cycleLengthWeeks,
    };
  }
  return const {};
}

double _resolveStarterBaseWeight({
  required PlanTemplate template,
  required Exercise exercise,
  required TrainingMaxProfile trainingMaxProfile,
  required double? startingLoadOverrideKg,
}) {
  if (exercise.trainingMaxLift != null && trainingMaxProfile.isNotEmpty) {
    final starterPercent = template.engineFamily == 'periodized_tm'
        ? exercise.stages.first.basePercent
        : 1.0;
    final baseWeight =
        trainingMaxProfile.require(exercise.trainingMaxLift!) *
        exercise.trainingMaxMultiplier *
        starterPercent;
    return roundToIncrement(baseWeight, exercise.roundingIncrement);
  }
  if (exercise.initialBaseWeight > 0) {
    return exercise.initialBaseWeight;
  }
  if (startingLoadOverrideKg != null && startingLoadOverrideKg > 0) {
    return startingLoadOverrideKg;
  }
  return exercise.initialBaseWeight;
}
