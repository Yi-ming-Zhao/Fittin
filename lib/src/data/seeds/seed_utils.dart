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
  final template = PlanTemplate.fromJson(jsonMap);
  if (template.id != expectedTemplateId) {
    throw StateError(
      'Unexpected template id "${template.id}". Expected "$expectedTemplateId".',
    );
  }
  return template;
}

List<TrainingState> buildStarterStatesForTemplate(
  PlanTemplate template, {
  TrainingMaxProfile trainingMaxProfile = TrainingMaxProfile.empty,
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
          ),
          currentStageId: exercise.stages.first.id,
        ),
  ];
}

Map<String, dynamic> buildInitialEngineState(PlanTemplate template) {
  if (template.engineFamily == 'periodized_tm') {
    final firstWorkout = template.workouts.isEmpty ? null : template.workouts.first;
    final firstExercise =
        firstWorkout == null || firstWorkout.exercises.isEmpty
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
}) {
  if (exercise.trainingMaxLift == null || trainingMaxProfile.isEmpty) {
    return exercise.initialBaseWeight;
  }

  final starterPercent = template.engineFamily == 'periodized_tm'
      ? exercise.stages.first.basePercent
      : 1.0;
  final baseWeight =
      trainingMaxProfile.require(exercise.trainingMaxLift!) *
      exercise.trainingMaxMultiplier *
      starterPercent;
  return roundToIncrement(baseWeight, exercise.roundingIncrement);
}
