import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/services/today_workout_gateway.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/seeds/gzclp_seed.dart';
import 'package:fittin_v2/src/data/sync/sync_models.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:fittin_v2/src/domain/rule_engine.dart';

import '../support/fake_today_workout_gateway.dart';
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

class _FailOnceInstanceSaveRepository extends InMemoryDatabaseRepository {
  bool failNextInstanceSave = false;

  @override
  Future<void> saveInstance(
    StoredTrainingInstance data, {
    String? syncStatus,
    String? deviceId,
  }) async {
    if (failNextInstanceSave) {
      failNextInstanceSave = false;
      throw StateError('temporary instance save failure');
    }
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
              firstSet.copyWith(completedRpe: 8.0, isCompleted: true),
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

  test(
    'conclusion rejects a session after the active workout advanced',
    () async {
      final repository = InMemoryDatabaseRepository();
      final template = await GzclpSeed.loadTemplate();
      final originalInstance = StoredTrainingInstance(
        instanceId: 'stale-session-instance',
        templateId: template.id,
        currentWorkoutIndex: 0,
        states: GzclpSeed.buildStarterStates(template),
      );
      await repository.saveTemplate(template, isBuiltIn: true);
      await repository.saveInstance(originalInstance);
      await repository.saveActiveInstanceId(originalInstance.instanceId);
      final gateway = DatabaseTodayWorkoutGateway(repository);
      final staleSession = await gateway.loadTodayWorkoutSession();

      await repository.saveInstance(
        originalInstance.copyWith(currentWorkoutIndex: 1),
      );

      await expectLater(
        gateway.concludeWorkoutSession(staleSession),
        throwsA(isA<StateError>()),
      );
      expect(
        (await repository.fetchInstance(
          originalInstance.instanceId,
        ))?.currentWorkoutIndex,
        1,
      );
      expect(
        await repository.fetchWorkoutLogs(originalInstance.instanceId),
        isEmpty,
      );
    },
  );

  test('schedule matching still validates prescription for equal tokens', () {
    final changedPrescription = fakeWorkoutSessionState.copyWith(
      exercises: [
        fakeWorkoutSessionState.exercises.first.copyWith(
          sets: [
            fakeWorkoutSessionState.exercises.first.sets.first.copyWith(
              targetReps:
                  fakeWorkoutSessionState
                      .exercises
                      .first
                      .sets
                      .first
                      .targetReps +
                  1,
            ),
            ...fakeWorkoutSessionState.exercises.first.sets.skip(1),
          ],
        ),
        ...fakeWorkoutSessionState.exercises.skip(1),
      ],
    );

    expect(
      workoutSessionMatchesSchedule(
        fakeWorkoutSessionState,
        changedPrescription,
      ),
      isFalse,
    );
  });

  test('conclusion retry upserts one deterministic workout log', () async {
    final repository = _FailOnceInstanceSaveRepository();
    final template = await GzclpSeed.loadTemplate();
    final instance = StoredTrainingInstance(
      instanceId: 'retry-conclusion-instance',
      templateId: template.id,
      currentWorkoutIndex: 0,
      states: GzclpSeed.buildStarterStates(template),
    );
    await repository.saveTemplate(template, isBuiltIn: true);
    await repository.saveInstance(instance);
    await repository.saveActiveInstanceId(instance.instanceId);
    final gateway = DatabaseTodayWorkoutGateway(repository);
    final session = await gateway.loadTodayWorkoutSession();
    repository.failNextInstanceSave = true;

    await expectLater(
      gateway.concludeWorkoutSession(session),
      throwsA(isA<StateError>()),
    );
    expect(
      await repository.fetchWorkoutLogs(instance.instanceId),
      hasLength(1),
    );
    expect(
      (await repository.fetchInstance(
        instance.instanceId,
      ))?.currentWorkoutIndex,
      0,
    );

    await gateway.concludeWorkoutSession(session);

    final logs = await repository.fetchWorkoutLogs(instance.instanceId);
    expect(logs, hasLength(1));
    expect(logs.single.logId, isNotEmpty);
    expect(
      (await repository.fetchInstance(
        instance.instanceId,
      ))?.currentWorkoutIndex,
      1,
    );
  });
}
