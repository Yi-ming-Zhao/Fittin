import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/domain/rule_engine.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';

void main() {
  group('RuleEngine.evaluateNextWorkout', () {
    final rules = [
      const ProgressionRule(
        condition: '\${failed_sets} == 0',
        actions: [
          RuleAction(type: 'ADD_WEIGHT', amount: 2.5),
          RuleAction(type: 'STAY_STAGE'),
        ],
      ),
      const ProgressionRule(
        condition: '\${failed_sets} > 0',
        actions: [RuleAction(type: 'JUMP_TO_STAGE', targetStageId: 'stage_2')],
      ),
    ];

    test('Success -> weight ++ (2.5kg)', () {
      const currentState = TrainingState(
        workoutId: 'day1',
        exerciseId: 'squat',
        exerciseName: 'Squat',
        baseWeight: 100.0,
        currentStageId: 'stage_1',
      );

      // All targets met!
      const log = ExerciseLog(
        exerciseId: 'squat',
        exerciseName: 'Squat',
        stageId: 'stage_1',
        sets: [
          SetLog(
            role: 'working',
            targetReps: 5,
            completedReps: 5,
            targetWeight: 100,
            weight: 100,
            isCompleted: true,
          ),
          SetLog(
            role: 'working',
            targetReps: 5,
            completedReps: 6,
            targetWeight: 100,
            weight: 100,
            isCompleted: true,
          ),
        ],
      );

      final nextState = RuleEngine.evaluateNextWorkout(
        currentState,
        log,
        rules,
      );
      expect(nextState.baseWeight, 102.5);
      expect(nextState.currentStageId, 'stage_1');
    });

    test('Failure -> stage jump to stage_2', () {
      const currentState = TrainingState(
        workoutId: 'day1',
        exerciseId: 'squat',
        exerciseName: 'Squat',
        baseWeight: 100.0,
        currentStageId: 'stage_1',
      );

      // Second set failed.
      const log = ExerciseLog(
        exerciseId: 'squat',
        exerciseName: 'Squat',
        stageId: 'stage_1',
        sets: [
          SetLog(
            role: 'working',
            targetReps: 5,
            completedReps: 5,
            targetWeight: 100,
            weight: 100,
            isCompleted: true,
          ),
          SetLog(
            role: 'working',
            targetReps: 5,
            completedReps: 3,
            targetWeight: 100,
            weight: 100,
            isCompleted: true,
          ),
        ],
      );

      final nextState = RuleEngine.evaluateNextWorkout(
        currentState,
        log,
        rules,
      );
      expect(nextState.baseWeight, 100.0);
      expect(nextState.currentStageId, 'stage_2');
    });
  });
}
