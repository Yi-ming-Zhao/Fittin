@TestOn('browser')
library;

import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/sync/sync_models.dart';
import 'package:fittin_v2/src/data/web_database_repository.dart';
import 'package:fittin_v2/src/data/web_local_store.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:flutter_test/flutter_test.dart';

class _FailAfterWebInstanceSaveRepository extends WebDatabaseRepository {
  _FailAfterWebInstanceSaveRepository(super.store);

  bool failAfterNextInstanceSave = false;

  @override
  Future<void> saveInstance(
    StoredTrainingInstance data, {
    String? syncStatus,
    String? deviceId,
  }) async {
    await super.saveInstance(data, syncStatus: syncStatus, deviceId: deviceId);
    if (failAfterNextInstanceSave) {
      failAfterNextInstanceSave = false;
      throw StateError('injected after instance and sync queue writes');
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Web conclusion rolls back every store and concurrent retry is idempotent',
    () async {
      const ownerUserId = 'owner-a';
      final store = await WebLocalStore.open(
        databaseName:
            'fittin_workout_conclusion_${DateTime.now().microsecondsSinceEpoch}',
      );
      addTearDown(store.close);
      final repository = _FailAfterWebInstanceSaveRepository(store);
      final before = StoredTrainingInstance(
        instanceId: 'instance-a',
        templateId: 'template-a',
        currentWorkoutIndex: 0,
        ownerUserId: ownerUserId,
        engineState: const {'week': 0},
        states: const [
          TrainingState(
            workoutId: 'workout-a',
            exerciseId: 'squat',
            exerciseName: 'Squat',
            baseWeight: 100,
            currentStageId: 'stage-a',
          ),
        ],
      );
      final after = before.copyWith(
        currentWorkoutIndex: 1,
        engineState: const {'week': 1},
        states: const [
          TrainingState(
            workoutId: 'workout-a',
            exerciseId: 'squat',
            exerciseName: 'Squat',
            baseWeight: 105,
            currentStageId: 'stage-a',
          ),
        ],
      );
      final log = WorkoutLog(
        logId: 'conclusion-a',
        instanceId: before.instanceId,
        workoutId: 'workout-a',
        workoutName: 'Workout A',
        dayLabel: 'Day 1',
        completedAt: DateTime.utc(2026, 9, 4),
        exercises: const [],
        preConclusionSnapshot: _snapshot(before),
        postConclusionSnapshot: _snapshot(after),
      );
      await repository.saveInstance(before, syncStatus: SyncStatusKeys.synced);

      repository.failAfterNextInstanceSave = true;
      await expectLater(
        repository.commitWorkoutConclusion(
          logRecord: log,
          expectedInstance: before,
          postInstance: after,
          ownerUserId: ownerUserId,
        ),
        throwsStateError,
      );

      expect(
        await store.getRecord(WebStoreNames.workoutLogs, log.logId),
        isNull,
      );
      expect(
        (await repository.fetchInstance(
          before.instanceId,
        ))?.currentWorkoutIndex,
        0,
      );
      expect(await store.getAllRecords(WebStoreNames.syncQueue), isEmpty);

      final results = await Future.wait([
        repository.commitWorkoutConclusion(
          logRecord: log,
          expectedInstance: before,
          postInstance: after,
          ownerUserId: ownerUserId,
        ),
        repository.commitWorkoutConclusion(
          logRecord: log,
          expectedInstance: before,
          postInstance: after,
          ownerUserId: ownerUserId,
        ),
      ]);

      expect(results.where((committed) => committed), hasLength(1));
      expect(results.where((committed) => !committed), hasLength(1));
      final instanceDoc = (await store.getRecord(
        WebStoreNames.instances,
        before.instanceId,
      ))!;
      final logDoc = (await store.getRecord(
        WebStoreNames.workoutLogs,
        log.logId,
      ))!;
      final queue = await store.getAllRecords(WebStoreNames.syncQueue);
      expect(instanceDoc['currentWorkoutIndex'], 1);
      expect(instanceDoc['version'], 2);
      expect(logDoc['version'], 1);
      expect(queue, hasLength(2));
      expect(queue.map((item) => item['entityType']).toSet(), {
        SyncEntityTypes.instance,
        SyncEntityTypes.workoutLog,
      });
    },
  );
}

WorkoutProgressionSnapshot _snapshot(StoredTrainingInstance instance) {
  return WorkoutProgressionSnapshot(
    templateId: instance.templateId,
    currentWorkoutIndex: instance.currentWorkoutIndex,
    trainingMaxProfile: instance.trainingMaxProfile,
    engineState: instance.engineState,
    states: instance.states,
  );
}
