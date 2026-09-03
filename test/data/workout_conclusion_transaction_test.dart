import 'dart:io';

import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/models/sync_queue_collection.dart';
import 'package:fittin_v2/src/data/models/workout_log_collection.dart';
import 'package:fittin_v2/src/data/sync/sync_models.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../support/isar_test_helper.dart';

class _FailAfterInstanceSaveRepository extends DatabaseRepository {
  _FailAfterInstanceSaveRepository(super.isar);

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

  late Isar isar;
  late Directory directory;
  late _FailAfterInstanceSaveRepository repository;

  setUp(() async {
    final store = await openTestIsar('workout_conclusion_transaction_test');
    isar = store.isar;
    directory = store.directory;
    repository = _FailAfterInstanceSaveRepository(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });

  test(
    'conclusion rolls back every store and concurrent retry is idempotent',
    () async {
      const ownerUserId = 'owner-a';
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
        await repository.fetchWorkoutLogById(
          log.logId,
          ownerUserId: ownerUserId,
        ),
        isNull,
      );
      expect(
        (await repository.fetchInstance(
          before.instanceId,
        ))?.currentWorkoutIndex,
        0,
      );
      expect(await isar.syncQueueCollections.where().count(), 0);

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
      final storedInstance = await repository.fetchInstance(before.instanceId);
      final storedLog = await isar.workoutLogCollections.getByLogId(log.logId);
      final queue = await isar.syncQueueCollections.where().findAll();
      expect(storedInstance?.currentWorkoutIndex, 1);
      expect(storedInstance?.version, 2);
      expect(storedLog?.version, 1);
      expect(queue, hasLength(2));
      expect(queue.map((item) => item.entityType).toSet(), {
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
