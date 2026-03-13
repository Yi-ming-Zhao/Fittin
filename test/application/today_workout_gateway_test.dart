import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/data/seeds/gzclp_seed.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/domain/rule_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'builds workbook-seeded day 1 summary data and exercise order',
    () async {
      final template = await GzclpSeed.loadTemplate();
      final workout = template.workoutByIndex(0);

      expect(workout.dayLabel, 'Day 1');
      expect(workout.name, 'Squat Focus');
      expect(workout.estimatedDurationMinutes, 55);
      expect(workout.exercises.length, 4);
      expect(workout.exercises.map((exercise) => exercise.name).toList(), [
        'Squat',
        'Barbell Row',
        'Lat Pulldowns',
        'Bicep Curls',
      ]);
      expect(workout.exercises.first.stages.first.sets.first.kind, 'warmup');
    },
  );

  test('seeded progression encodes squat success and bench failure', () async {
    final template = await GzclpSeed.loadTemplate();
    final states = GzclpSeed.buildStarterStates(template);

    final squatState = states.firstWhere(
      (state) => state.exerciseId == 'day1-squat',
    );
    final squatStage = template
        .findExerciseById('day1-squat')
        .stageById(squatState.currentStageId);
    final nextSquat = RuleEngine.evaluateNextWorkout(
      squatState,
      ExerciseLog(
        exerciseId: squatState.exerciseId,
        exerciseName: squatState.exerciseName,
        stageId: squatState.currentStageId,
        sets: [
          for (final set in squatStage.sets.where(
            (set) => set.kind == 'working',
          ))
            SetLog(
              role: set.kind,
              targetReps: set.targetReps,
              completedReps: set.targetReps,
              targetWeight: squatState.baseWeight,
              weight: squatState.baseWeight,
              isAmrap: set.isAmrap,
              isCompleted: true,
            ),
        ],
      ),
      squatStage.rules,
    );

    expect(nextSquat.baseWeight, 140.0);
    expect(nextSquat.currentStageId, 't1-3x5');

    final benchState = states.firstWhere(
      (state) => state.exerciseId == 'day2-bench',
    );
    final benchStage = template
        .findExerciseById('day2-bench')
        .stageById(benchState.currentStageId);
    final nextBench = RuleEngine.evaluateNextWorkout(
      benchState,
      ExerciseLog(
        exerciseId: benchState.exerciseId,
        exerciseName: benchState.exerciseName,
        stageId: benchState.currentStageId,
        sets: [
          SetLog(
            role: 'working',
            targetReps: 5,
            completedReps: 5,
            targetWeight: benchState.baseWeight,
            weight: benchState.baseWeight,
            isCompleted: true,
          ),
          SetLog(
            role: 'working',
            targetReps: 5,
            completedReps: 3,
            targetWeight: benchState.baseWeight,
            weight: benchState.baseWeight,
            isCompleted: true,
          ),
        ],
      ),
      benchStage.rules,
    );

    expect(nextBench.baseWeight, 85.0);
    expect(nextBench.currentStageId, 't1-4x3');
  });
}
