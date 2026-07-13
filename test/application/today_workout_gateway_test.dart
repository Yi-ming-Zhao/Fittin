import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/services/today_workout_gateway.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/seeds/gzclp_seed.dart';
import 'package:fittin_v2/src/data/sync/sync_models.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/domain/rule_engine.dart';

import '../support/in_memory_database_repository.dart';

class _TrackingDatabaseRepository extends InMemoryDatabaseRepository {
  String? lastInstanceSyncStatus;

  @override
  Future<void> saveInstance(
    StoredTrainingInstance data, {
    String? syncStatus,
    String? deviceId,
  }) async {
    lastInstanceSyncStatus = syncStatus;
    await super.saveInstance(data, syncStatus: syncStatus, deviceId: deviceId);
  }
}

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

  test(
    'conclusion persists and exposes the next workout before cloud sync',
    () async {
      const ownerUserId = 'signed-in-user';
      final repository = _TrackingDatabaseRepository();
      final template = await GzclpSeed.loadTemplate();
      await repository.saveTemplate(template, isBuiltIn: true);
      await repository.saveInstance(
        StoredTrainingInstance(
          instanceId: 'signed-in-instance',
          templateId: template.id,
          currentWorkoutIndex: 0,
          ownerUserId: ownerUserId,
          trainingMaxProfile: const TrainingMaxProfile({
            'squat': 180,
            'bench': 110,
            'deadlift': 220,
            'overhead_press': 70,
          }),
          states: GzclpSeed.buildStarterStates(template),
        ),
        syncStatus: SyncStatusKeys.synced,
      );
      await repository.saveActiveInstanceIdForUser(
        'signed-in-instance',
        ownerUserId,
      );
      final gateway = DatabaseTodayWorkoutGateway(
        repository,
        ownerUserId: ownerUserId,
      );

      final before = await gateway.loadTodayWorkoutSummary();
      final session = await gateway.loadTodayWorkoutSession();
      final firstExercise = session.exercises.first;
      final firstSet = firstExercise.sets.first;
      final completedSession = session.copyWith(
        exercises: [
          firstExercise.copyWith(
            sets: [
              firstSet.copyWith(
                targetRpe: 8.0,
                completedRpe: null,
                isCompleted: true,
              ),
              ...firstExercise.sets.skip(1),
            ],
          ),
          ...session.exercises.skip(1),
        ],
      );

      await gateway.concludeWorkoutSession(completedSession);

      final storedInstance = await repository.fetchInstance(
        'signed-in-instance',
      );
      final after = await gateway.loadTodayWorkoutSummary();
      final logs = await repository.fetchWorkoutLogs(
        'signed-in-instance',
        ownerUserId: ownerUserId,
      );

      expect(before.currentDayNumber, 1);
      expect(storedInstance?.currentWorkoutIndex, 1);
      expect(repository.lastInstanceSyncStatus, SyncStatusKeys.pendingUpload);
      expect(after.currentDayNumber, 2);
      expect(after.workoutId, template.workoutByIndex(1).id);
      expect(logs.single.exercises.first.sets.first.completedRpe, 8.0);
    },
  );
}
