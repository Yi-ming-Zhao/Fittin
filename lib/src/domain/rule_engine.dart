import 'dart:convert';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';

class RuleEngine {
  /// Parses JSON string to PlanTemplate object.
  static PlanTemplate parseTemplate(String jsonString) {
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return PlanTemplate.fromJson(jsonMap);
  }

  /// Calculates the next session state based on current state, log, and rules.
  static TrainingState evaluateNextWorkout(
    TrainingState currentState,
    ExerciseLog todayLog,
    List<ProgressionRule> rules,
  ) {
    final workingSets = todayLog.sets.where((set) => set.role == 'working');
    final hasFailed = workingSets.any(
      (set) => !set.isCompleted || set.completedReps < set.targetReps,
    );

    // 2. Evaluate rules
    for (final rule in rules) {
      if (_conditionMatches(rule.condition, hasFailed)) {
        return _applyActions(currentState, rule.actions);
      }
    }

    // Return unmodified state if no matching rule is found
    return currentState;
  }

  static bool _conditionMatches(String condition, bool hasFailed) {
    // A simplified condition evaluator.
    if (condition == 'on_failure' && hasFailed) return true;
    if (condition == 'on_success' && !hasFailed) return true;

    // Support variables like '${failed_sets} == 0' or '${failed_sets} > 0'
    if (condition.contains('\${failed_sets} == 0') && !hasFailed) return true;
    if (condition.contains('\${failed_sets} > 0') && hasFailed) return true;

    return false;
  }

  static TrainingState _applyActions(
    TrainingState state,
    List<RuleAction> actions,
  ) {
    double newWeight = state.baseWeight;
    String newStageId = state.currentStageId;

    for (final action in actions) {
      switch (action.type) {
        case 'ADD_WEIGHT':
          newWeight += (action.amount ?? 0.0);
          break;
        case 'MULTIPLY_WEIGHT':
          newWeight *= (action.multiplier ?? 1.0);
          break;
        case 'JUMP_TO_STAGE':
          if (action.targetStageId != null) {
            newStageId = action.targetStageId!;
          }
          break;
        case 'STAY_STAGE':
          // keep the same stage
          break;
      }
    }

    return state.copyWith(baseWeight: newWeight, currentStageId: newStageId);
  }
}
