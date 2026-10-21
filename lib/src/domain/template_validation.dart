import 'package:fittin_v2/src/domain/models/training_plan.dart';

class TemplateValidationResult {
  TemplateValidationResult(this.errors, [this.issues = const []]);

  final List<String> errors;
  final List<TemplateValidationIssue> issues;

  bool get isValid => errors.isEmpty;
}

class TemplateValidationIssue {
  const TemplateValidationIssue(
    this.message,
    this.workoutId,
    this.exerciseId,
    this.stageId,
  );
  final String message;
  final String? workoutId, exerciseId, stageId;
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
    final issues = <TemplateValidationIssue>[];
    String? workoutId, exerciseId, stageId;
    void addError(String message) {
      errors.add(message);
      issues.add(
        TemplateValidationIssue(message, workoutId, exerciseId, stageId),
      );
    }

    if (template.name.trim().isEmpty) {
      addError('Template name is required.');
    }

    if (!PlanScheduleModes.supported.contains(template.scheduleMode)) {
      addError('Template schedule mode is invalid.');
    }

    if (template.phases.isEmpty || template.workouts.isEmpty) {
      addError('At least one workout is required.');
      return TemplateValidationResult(errors, issues);
    }

    for (final workout in template.workouts) {
      workoutId = workout.id;
      exerciseId = null;
      stageId = null;
      final workoutLabel = workout.name.trim().isEmpty
          ? workout.id
          : workout.name;
      if (workout.name.trim().isEmpty) {
        addError('Workout "$workoutLabel" must have a name.');
      }
      if (workout.exercises.isEmpty) {
        addError('Workout "$workoutLabel" must contain at least one exercise.');
      }

      for (final exercise in workout.exercises) {
        exerciseId = exercise.id;
        stageId = null;
        final exerciseLabel = exercise.name.trim().isEmpty
            ? exercise.id
            : exercise.name;
        if (exercise.name.trim().isEmpty) {
          addError('Exercise "$exerciseLabel" must have a name.');
        }
        if (!LoadUnits.supported.contains(exercise.loadUnit)) {
          addError('Exercise "$exerciseLabel" uses an unsupported load unit.');
        }
        if (exercise.stages.isEmpty) {
          addError(
            'Exercise "$exerciseLabel" must contain at least one stage.',
          );
          continue;
        }

        final stageIds = exercise.stages.map((stage) => stage.id).toSet();
        for (final stage in exercise.stages) {
          stageId = stage.id;
          final stageLabel = stage.name.trim().isEmpty ? stage.id : stage.name;
          if (stage.name.trim().isEmpty) {
            addError(
              'Stage "$stageLabel" in exercise "$exerciseLabel" must have a name.',
            );
          }
          if (stage.sets.isEmpty) {
            addError(
              'Stage "$stageLabel" in exercise "$exerciseLabel" must contain sets.',
            );
            continue;
          }

          final workingSets = stage.sets.where((set) => set.kind == 'working');
          if (workingSets.isEmpty) {
            addError(
              'Stage "$stageLabel" in exercise "$exerciseLabel" must contain at least one working set.',
            );
          }

          for (final set in stage.sets) {
            if (set.targetReps <= 0) {
              addError(
                'Stage "$stageLabel" in exercise "$exerciseLabel" has a set with invalid reps.',
              );
            }
            if (set.intensity <= 0) {
              addError(
                'Stage "$stageLabel" in exercise "$exerciseLabel" has a set with invalid intensity.',
              );
            }
            if (set.kind != 'working' && set.kind != 'warmup') {
              addError(
                'Stage "$stageLabel" in exercise "$exerciseLabel" has a set with invalid role.',
              );
            }
            if (!SetTypes.supported.contains(set.resolvedSetType)) {
              addError(
                'Stage "$stageLabel" in exercise "$exerciseLabel" has a set with invalid type.',
              );
            }
            if (set.kind == SetKinds.warmup &&
                set.resolvedSetType != SetTypes.warmupSet) {
              addError(
                'Stage "$stageLabel" in exercise "$exerciseLabel" has a warmup set with an invalid set type.',
              );
            }
            if (set.kind == SetKinds.working &&
                set.resolvedSetType == SetTypes.warmupSet) {
              addError(
                'Stage "$stageLabel" in exercise "$exerciseLabel" has a working set marked as warmup.',
              );
            }
          }

          for (final rule in stage.rules) {
            for (final action in rule.actions) {
              if (!supportedActionTypes.contains(action.type)) {
                addError(
                  'Stage "$stageLabel" in exercise "$exerciseLabel" uses unsupported action "${action.type}".',
                );
              }
              if (action.type == 'JUMP_TO_STAGE' &&
                  (action.targetStageId == null ||
                      !stageIds.contains(action.targetStageId))) {
                addError(
                  'Stage "$stageLabel" in exercise "$exerciseLabel" jumps to an unknown stage.',
                );
              }
            }
          }
        }
      }
    }

    return TemplateValidationResult(errors, issues);
  }
}
