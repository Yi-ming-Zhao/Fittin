import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/domain/plan_start_load_review.dart';
import 'package:fittin_v2/src/domain/rule_engine.dart';

class ProgramEngineDispatcher {
  static ProgramEngine resolve(String engineFamily) {
    switch (engineFamily) {
      case 'linear_tm':
        return const LinearProgramEngine();
      case 'periodized_tm':
        return const PeriodizedProgramEngine();
      default:
        return const LinearProgramEngine();
    }
  }
}

String buildWorkoutScheduleToken(StoredTrainingInstance instance) {
  final engineEntries =
      instance.engineState.entries
          .where((entry) => entry.key != planStartLoadReviewEngineStateKey)
          .toList()
        ..sort((left, right) => left.key.compareTo(right.key));
  final stateEntries = [...instance.states]
    ..sort((left, right) {
      final workoutComparison = left.workoutId.compareTo(right.workoutId);
      return workoutComparison != 0
          ? workoutComparison
          : left.exerciseId.compareTo(right.exerciseId);
    });
  final trainingMaxEntries = instance.trainingMaxProfile.values.entries.toList()
    ..sort((left, right) => left.key.compareTo(right.key));

  return [
    'workout=${instance.currentWorkoutIndex}',
    for (final entry in engineEntries) '${entry.key}=${entry.value}',
    for (final state in stateEntries)
      '${state.workoutId}:${state.exerciseId}:${state.currentStageId}:'
          '${state.baseWeight.toStringAsFixed(6)}:'
          '${state.history.length}:${state.history.join(',')}',
    for (final entry in trainingMaxEntries)
      'tm:${entry.key}=${entry.value.toStringAsFixed(6)}',
  ].join('|');
}

abstract class ProgramEngine {
  const ProgramEngine();

  WorkoutSessionState buildSession({
    required PlanTemplate template,
    required StoredTrainingInstance instance,
    required Workout workout,
    required Map<String, TrainingState> stateByExerciseId,
  });

  ProgramEngineResult conclude({
    required PlanTemplate template,
    required StoredTrainingInstance instance,
    required WorkoutSessionState session,
    required Map<String, TrainingState> stateByExerciseId,
  });
}

class LinearProgramEngine extends ProgramEngine {
  const LinearProgramEngine();

  @override
  WorkoutSessionState buildSession({
    required PlanTemplate template,
    required StoredTrainingInstance instance,
    required Workout workout,
    required Map<String, TrainingState> stateByExerciseId,
  }) {
    return WorkoutSessionState(
      instanceId: instance.instanceId,
      templateId: template.id,
      workoutId: workout.id,
      scheduleToken: buildWorkoutScheduleToken(instance),
      workoutName: workout.name,
      dayLabel: workout.dayLabel,
      estimatedDurationMinutes: workout.estimatedDurationMinutes,
      exercises: [
        for (final exercise in workout.exercises)
          _buildExerciseSession(
            exercise: exercise,
            state: stateByExerciseId[exercise.id]!,
            baseWeight: stateByExerciseId[exercise.id]!.baseWeight,
          ),
      ],
    );
  }

  @override
  ProgramEngineResult conclude({
    required PlanTemplate template,
    required StoredTrainingInstance instance,
    required WorkoutSessionState session,
    required Map<String, TrainingState> stateByExerciseId,
  }) {
    final updatedStates = [...instance.states];
    final logs = <ExerciseLog>[];

    for (final exerciseSession in session.exercises) {
      final currentState = stateByExerciseId[exerciseSession.id]!;
      final templateExercise = template.findExerciseById(exerciseSession.id);
      final stage = templateExercise.stageById(currentState.currentStageId);
      final log = _exerciseLogFromSession(
        stageId: currentState.currentStageId,
        session: exerciseSession,
      );
      logs.add(log);

      final nextState = stage.rules.isEmpty
          ? currentState
          : RuleEngine.evaluateNextWorkout(currentState, log, stage.rules);

      final stateIndex = updatedStates.indexWhere(
        (state) => state.exerciseId == currentState.exerciseId,
      );
      updatedStates[stateIndex] = nextState.copyWith(
        history: [...currentState.history, session.workoutId],
      );
    }

    return ProgramEngineResult(
      nextWorkoutIndex:
          (instance.currentWorkoutIndex + 1) % template.workouts.length,
      updatedStates: updatedStates,
      logs: logs,
      updatedEngineState: instance.engineState,
    );
  }
}

class PeriodizedProgramEngine extends ProgramEngine {
  const PeriodizedProgramEngine();

  @override
  WorkoutSessionState buildSession({
    required PlanTemplate template,
    required StoredTrainingInstance instance,
    required Workout workout,
    required Map<String, TrainingState> stateByExerciseId,
  }) {
    return WorkoutSessionState(
      instanceId: instance.instanceId,
      templateId: template.id,
      workoutId: workout.id,
      scheduleToken: buildWorkoutScheduleToken(instance),
      workoutName: workout.name,
      dayLabel: workout.dayLabel,
      estimatedDurationMinutes: workout.estimatedDurationMinutes,
      exercises: [
        for (final exercise in workout.exercises)
          _buildExerciseSession(
            exercise: exercise,
            state: stateByExerciseId[exercise.id]!,
            baseWeight: _resolvePeriodizedBaseWeight(
              exercise: exercise,
              state: stateByExerciseId[exercise.id]!,
              trainingMaxProfile: instance.trainingMaxProfile,
            ),
          ),
      ],
    );
  }

  @override
  ProgramEngineResult conclude({
    required PlanTemplate template,
    required StoredTrainingInstance instance,
    required WorkoutSessionState session,
    required Map<String, TrainingState> stateByExerciseId,
  }) {
    final updatedStates = [...instance.states];
    final logs = <ExerciseLog>[];

    for (final exerciseSession in session.exercises) {
      final currentState = stateByExerciseId[exerciseSession.id]!;
      final exercise = template.findExerciseById(exerciseSession.id);
      final currentStage = exercise.stageById(currentState.currentStageId);
      final currentStageIndex = exercise.stages.indexOf(currentStage);
      final nextStageIndex = currentStageIndex + 1 < exercise.stages.length
          ? currentStageIndex + 1
          : currentStageIndex;
      final nextStage = exercise.stages[nextStageIndex];

      final log = _exerciseLogFromSession(
        stageId: currentState.currentStageId,
        session: exerciseSession,
      );
      logs.add(log);

      final progressedState = currentStage.rules.isEmpty
          ? currentState
          : RuleEngine.evaluateNextWorkout(
              currentState,
              log,
              currentStage.rules,
            );

      final stateIndex = updatedStates.indexWhere(
        (state) => state.exerciseId == currentState.exerciseId,
      );
      updatedStates[stateIndex] = currentState.copyWith(
        baseWeight: exercise.trainingMaxLift == null
            ? progressedState.baseWeight
            : _resolveStageBaseWeight(
                exercise: exercise,
                stage: nextStage,
                trainingMaxProfile: instance.trainingMaxProfile,
              ),
        currentStageId: nextStage.id,
        history: [...currentState.history, session.workoutId],
      );
    }

    final rawWeekIndex =
        (instance.engineState['currentWeekIndex'] as num?)?.toInt() ?? 0;
    final completedWeek =
        instance.currentWorkoutIndex == template.workouts.length - 1;
    final nextWeekIndex = completedWeek ? rawWeekIndex + 1 : rawWeekIndex;
    final cycleLengthWeeks =
        (instance.engineState['cycleLengthWeeks'] as num?)?.toInt() ??
        template.workoutByIndex(0).exercises.first.stages.length;

    return ProgramEngineResult(
      nextWorkoutIndex:
          (instance.currentWorkoutIndex + 1) % template.workouts.length,
      updatedStates: updatedStates,
      logs: logs,
      updatedEngineState: {
        ...instance.engineState,
        'currentWeekIndex': nextWeekIndex,
        'currentBlockIndex': nextWeekIndex ~/ cycleLengthWeeks,
        'cycleLengthWeeks': cycleLengthWeeks,
      },
    );
  }
}

class ProgramEngineResult {
  const ProgramEngineResult({
    required this.nextWorkoutIndex,
    required this.updatedStates,
    required this.logs,
    required this.updatedEngineState,
  });

  final int nextWorkoutIndex;
  final List<TrainingState> updatedStates;
  final List<ExerciseLog> logs;
  final Map<String, dynamic> updatedEngineState;
}

ExerciseSessionState _buildExerciseSession({
  required Exercise exercise,
  required TrainingState state,
  required double baseWeight,
}) {
  final stage = exercise.stageById(state.currentStageId);
  return ExerciseSessionState(
    id: exercise.id,
    exerciseId: exercise.exerciseId,
    exerciseName: exercise.name,
    tier: exercise.tier,
    restSeconds: exercise.restSeconds,
    stageId: stage.id,
    displayLoadUnit:
        exercise.loadUnit == LoadUnits.bodyweight ||
            exercise.loadUnit == LoadUnits.cableStack ||
            exercise.loadUnit == LoadUnits.percent1rm
        ? exercise.loadUnit
        : LoadUnits.kg,
    showsPlateBreakdown: exercise.isBarbell,
    sets: [
      for (var index = 0; index < stage.sets.length; index++)
        _buildSessionSet(
          id: '${exercise.id}-$index',
          definition: stage.sets[index],
          baseWeight: baseWeight,
          roundingIncrement: exercise.roundingIncrement,
        ),
    ],
  );
}

SessionSetState _buildSessionSet({
  required String id,
  required SetDefinition definition,
  required double baseWeight,
  required double roundingIncrement,
}) {
  final targetWeight = roundToIncrement(
    baseWeight * _resolveSetIntensity(definition),
    roundingIncrement,
  );
  return SessionSetState(
    id: id,
    role: definition.kind,
    targetReps: definition.targetReps,
    completedReps: definition.targetReps,
    targetWeight: targetWeight,
    weight: targetWeight,
    targetRpe: definition.targetRpe,
    isAmrap: definition.isAmrap,
  );
}

double _resolvePeriodizedBaseWeight({
  required Exercise exercise,
  required TrainingState state,
  required TrainingMaxProfile trainingMaxProfile,
}) {
  if (exercise.trainingMaxLift == null) {
    return state.baseWeight;
  }
  final stage = exercise.stageById(state.currentStageId);
  return _resolveStageBaseWeight(
    exercise: exercise,
    stage: stage,
    trainingMaxProfile: trainingMaxProfile,
  );
}

double _resolveStageBaseWeight({
  required Exercise exercise,
  required SetScheme stage,
  required TrainingMaxProfile trainingMaxProfile,
}) {
  if (exercise.trainingMaxLift == null || trainingMaxProfile.isEmpty) {
    return exercise.initialBaseWeight;
  }
  return roundToIncrement(
    trainingMaxProfile.require(exercise.trainingMaxLift!) *
        exercise.trainingMaxMultiplier *
        stage.basePercent,
    exercise.roundingIncrement,
  );
}

ExerciseLog _exerciseLogFromSession({
  required String stageId,
  required ExerciseSessionState session,
}) {
  return ExerciseLog(
    exerciseId: session.id,
    exerciseDefinitionId: session.exerciseId,
    exerciseName: session.exerciseName,
    stageId: stageId,
    displayLoadUnit: session.displayLoadUnit,
    sets: [
      for (final set in session.sets)
        SetLog(
          role: set.role,
          targetReps: set.targetReps,
          completedReps: set.completedReps,
          targetWeight: set.targetWeight,
          weight: set.weight,
          targetRpe: set.targetRpe,
          completedRpe: set.isCompleted
              ? set.completedRpe ?? set.targetRpe
              : set.completedRpe,
          isAmrap: set.isAmrap,
          isCompleted: set.isCompleted,
        ),
    ],
  );
}

double _resolveSetIntensity(SetDefinition definition) {
  final targetRpe = definition.targetRpe;
  final usesRpePrescription =
      targetRpe != null &&
      (definition.intensity <= 0.001 || definition.intensity == 1.0);
  if (!usesRpePrescription) {
    return definition.intensity;
  }

  final rpeHalfStep = (targetRpe * 2).round().clamp(13, 20);
  final reps = definition.targetReps.clamp(1, 12).toInt();
  return _rpeLoadPercentages[rpeHalfStep]![reps - 1];
}

// TSA Intermediate Approach 2.0 workbook, Reference!F9:R16.
const _rpeLoadPercentages = <int, List<double>>{
  20: [
    1.0,
    0.955,
    0.922,
    0.892,
    0.863,
    0.837,
    0.811,
    0.786,
    0.762,
    0.739,
    0.707,
    0.68,
  ],
  19: [
    0.978,
    0.939,
    0.907,
    0.878,
    0.85,
    0.824,
    0.799,
    0.774,
    0.751,
    0.723,
    0.694,
    0.667,
  ],
  18: [
    0.955,
    0.922,
    0.892,
    0.863,
    0.837,
    0.811,
    0.786,
    0.762,
    0.739,
    0.707,
    0.68,
    0.653,
  ],
  17: [
    0.939,
    0.907,
    0.878,
    0.85,
    0.824,
    0.799,
    0.774,
    0.751,
    0.723,
    0.694,
    0.667,
    0.64,
  ],
  16: [
    0.922,
    0.892,
    0.863,
    0.837,
    0.811,
    0.786,
    0.762,
    0.739,
    0.707,
    0.68,
    0.653,
    0.626,
  ],
  15: [
    0.907,
    0.878,
    0.85,
    0.824,
    0.799,
    0.774,
    0.751,
    0.723,
    0.694,
    0.667,
    0.64,
    0.613,
  ],
  14: [
    0.892,
    0.863,
    0.837,
    0.811,
    0.786,
    0.762,
    0.739,
    0.707,
    0.68,
    0.653,
    0.626,
    0.599,
  ],
  13: [
    0.878,
    0.85,
    0.824,
    0.799,
    0.774,
    0.751,
    0.723,
    0.694,
    0.667,
    0.64,
    0.613,
    0.586,
  ],
};
