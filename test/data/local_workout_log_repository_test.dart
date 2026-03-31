import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/local/local_workout_log_repository.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';

import '../support/in_memory_database_repository.dart';

void main() {
  test(
    'updating the latest workout log rewrites progression when snapshots exist',
    () async {
      final repository = InMemoryDatabaseRepository();
      final template = _buildTemplate();
      await repository.saveTemplate(template);

      final preState = TrainingState(
        workoutId: 'day-1',
        exerciseId: 'squat-session',
        exerciseName: 'Squat',
        baseWeight: 100,
        currentStageId: 'stage-1',
      );
      final currentInstance = StoredTrainingInstance(
        instanceId: 'instance-1',
        templateId: template.id,
        currentWorkoutIndex: 0,
        states: [preState.copyWith(baseWeight: 102.5)],
      );
      await repository.saveInstance(currentInstance);

      final log = _buildLog(
        completedAt: DateTime(2026, 3, 31, 10),
        completedReps: 5,
        preState: preState,
        postState: preState.copyWith(baseWeight: 102.5),
        logId: 'log-latest',
      );
      await repository.logWorkout(log);

      final container = ProviderContainer(
        overrides: [databaseRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final repo = container.read(localWorkoutLogRepositoryProvider);
      final result = await repo.updateWorkoutLog(
        log.copyWith(
          exercises: [
            log.exercises.first.copyWith(
              sets: [
                log.exercises.first.sets.first.copyWith(
                  completedReps: 3,
                  isCompleted: false,
                ),
              ],
            ),
          ],
        ),
      );

      expect(result.progressionRewritten, isTrue);
      final updatedLog = await repository.fetchWorkoutLogById('log-latest');
      expect(updatedLog?.exercises.first.sets.first.completedReps, 3);
      final updatedInstance = await repository.fetchInstance('instance-1');
      expect(updatedInstance?.states.first.baseWeight, 100);
    },
  );

  test('updating an older workout log does not rewrite progression', () async {
    final repository = InMemoryDatabaseRepository();
    final template = _buildTemplate();
    await repository.saveTemplate(template);

    final preState = TrainingState(
      workoutId: 'day-1',
      exerciseId: 'squat-session',
      exerciseName: 'Squat',
      baseWeight: 100,
      currentStageId: 'stage-1',
    );
    await repository.saveInstance(
      StoredTrainingInstance(
        instanceId: 'instance-1',
        templateId: template.id,
        currentWorkoutIndex: 0,
        states: [preState.copyWith(baseWeight: 102.5)],
      ),
    );

    await repository.logWorkout(
      _buildLog(
        completedAt: DateTime(2026, 3, 30, 10),
        completedReps: 5,
        preState: preState,
        postState: preState.copyWith(baseWeight: 102.5),
        logId: 'log-older',
      ),
    );
    await repository.logWorkout(
      _buildLog(
        completedAt: DateTime(2026, 3, 31, 10),
        completedReps: 5,
        preState: preState,
        postState: preState.copyWith(baseWeight: 102.5),
        logId: 'log-latest',
      ),
    );

    final container = ProviderContainer(
      overrides: [databaseRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final repo = container.read(localWorkoutLogRepositoryProvider);
    final olderLog = (await repository.fetchWorkoutLogById('log-older'))!;
    final result = await repo.updateWorkoutLog(
      olderLog.copyWith(
        exercises: [
          olderLog.exercises.first.copyWith(
            sets: [
              olderLog.exercises.first.sets.first.copyWith(completedReps: 1),
            ],
          ),
        ],
      ),
    );

    expect(result.progressionRewritten, isFalse);
    final updatedInstance = await repository.fetchInstance('instance-1');
    expect(updatedInstance?.states.first.baseWeight, 102.5);
  });
}

PlanTemplate _buildTemplate() {
  return const PlanTemplate(
    id: 'template-1',
    name: 'Test Plan',
    description: 'desc',
    engineFamily: 'linear_tm',
    phases: [
      Phase(
        id: 'phase-1',
        name: 'Phase 1',
        workouts: [
          Workout(
            id: 'day-1',
            name: 'Workout 1',
            dayLabel: 'Day 1',
            estimatedDurationMinutes: 45,
            exercises: [
              Exercise(
                id: 'squat-session',
                exerciseId: 'squat',
                name: 'Squat',
                initialBaseWeight: 100,
                tier: 'T1',
                restSeconds: 180,
                stages: [
                  SetScheme(
                    id: 'stage-1',
                    name: '3x5',
                    sets: [
                      SetDefinition(
                        targetReps: 5,
                        intensity: 1,
                        kind: 'working',
                      ),
                    ],
                    rules: [
                      ProgressionRule(
                        condition: 'on_success',
                        actions: [RuleAction(type: 'ADD_WEIGHT', amount: 2.5)],
                      ),
                      ProgressionRule(
                        condition: 'on_failure',
                        actions: [RuleAction(type: 'STAY_STAGE')],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

WorkoutLog _buildLog({
  required DateTime completedAt,
  required int completedReps,
  required TrainingState preState,
  required TrainingState postState,
  required String logId,
}) {
  return WorkoutLog(
    logId: logId,
    instanceId: 'instance-1',
    workoutId: 'day-1',
    workoutName: 'Workout 1',
    dayLabel: 'Day 1',
    completedAt: completedAt,
    exercises: [
      ExerciseLog(
        exerciseId: 'squat-session',
        exerciseName: 'Squat',
        stageId: 'stage-1',
        sets: [
          SetLog(
            role: 'working',
            targetReps: 5,
            completedReps: completedReps,
            targetWeight: 100,
            weight: 100,
            isCompleted: true,
          ),
        ],
      ),
    ],
    preConclusionSnapshot: WorkoutProgressionSnapshot(
      templateId: 'template-1',
      currentWorkoutIndex: 0,
      trainingMaxProfile: TrainingMaxProfile.empty,
      engineState: const {},
      states: [preState],
    ),
    postConclusionSnapshot: WorkoutProgressionSnapshot(
      templateId: 'template-1',
      currentWorkoutIndex: 0,
      trainingMaxProfile: TrainingMaxProfile.empty,
      engineState: const {},
      states: [postState],
    ),
  );
}
