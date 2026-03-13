import 'package:fittin_v2/src/domain/models/training_plan.dart';

class TemplateValidationResult {
  TemplateValidationResult(this.errors);

  final List<String> errors;

  bool get isValid => errors.isEmpty;
}

class TemplateValidation {
  static const supportedActionTypes = {
    'ADD_WEIGHT',
    'JUMP_TO_STAGE',
    'STAY_STAGE',
    'MULTIPLY_WEIGHT',
  };

  static TemplateValidationResult validate(PlanTemplate template) {
    final errors = <String>[];
    if (template.name.trim().isEmpty) {
      errors.add('Template name is required.');
    }

    if (template.phases.isEmpty || template.workouts.isEmpty) {
      errors.add('At least one workout is required.');
      return TemplateValidationResult(errors);
    }

    for (final workout in template.workouts) {
      final workoutLabel = workout.name.trim().isEmpty ? workout.id : workout.name;
      if (workout.name.trim().isEmpty) {
        errors.add('Workout "$workoutLabel" must have a name.');
      }
      if (workout.exercises.isEmpty) {
        errors.add('Workout "$workoutLabel" must contain at least one exercise.');
      }

      for (final exercise in workout.exercises) {
        final exerciseLabel = exercise.name.trim().isEmpty ? exercise.id : exercise.name;
        if (exercise.name.trim().isEmpty) {
          errors.add('Exercise "$exerciseLabel" must have a name.');
        }
        if (exercise.stages.isEmpty) {
          errors.add('Exercise "$exerciseLabel" must contain at least one stage.');
          continue;
        }

        final stageIds = exercise.stages.map((stage) => stage.id).toSet();
        for (final stage in exercise.stages) {
          final stageLabel = stage.name.trim().isEmpty ? stage.id : stage.name;
          if (stage.name.trim().isEmpty) {
            errors.add(
              'Stage "$stageLabel" in exercise "$exerciseLabel" must have a name.',
            );
          }
          if (stage.sets.isEmpty) {
            errors.add(
              'Stage "$stageLabel" in exercise "$exerciseLabel" must contain sets.',
            );
            continue;
          }

          final workingSets = stage.sets.where((set) => set.kind == 'working');
          if (workingSets.isEmpty) {
            errors.add(
              'Stage "$stageLabel" in exercise "$exerciseLabel" must contain at least one working set.',
            );
          }

          for (final set in stage.sets) {
            if (set.targetReps <= 0) {
              errors.add(
                'Stage "$stageLabel" in exercise "$exerciseLabel" has a set with invalid reps.',
              );
            }
            if (set.intensity <= 0) {
              errors.add(
                'Stage "$stageLabel" in exercise "$exerciseLabel" has a set with invalid intensity.',
              );
            }
            if (set.kind != 'working' && set.kind != 'warmup') {
              errors.add(
                'Stage "$stageLabel" in exercise "$exerciseLabel" has a set with invalid role.',
              );
            }
          }

          for (final rule in stage.rules) {
            for (final action in rule.actions) {
              if (!supportedActionTypes.contains(action.type)) {
                errors.add(
                  'Stage "$stageLabel" in exercise "$exerciseLabel" uses unsupported action "${action.type}".',
                );
              }
              if (action.type == 'JUMP_TO_STAGE' &&
                  (action.targetStageId == null ||
                      !stageIds.contains(action.targetStageId))) {
                errors.add(
                  'Stage "$stageLabel" in exercise "$exerciseLabel" jumps to an unknown stage.',
                );
              }
            }
          }
        }
      }
    }

    return TemplateValidationResult(errors);
  }
}
