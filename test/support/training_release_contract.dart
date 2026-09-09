import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/local/local_workout_log_repository.dart';
import 'package:fittin_v2/src/domain/microcycle_schedule.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> verifyTrainingReleaseTransaction({
  required DatabaseRepository database,
  required void Function() failNextDelete,
  required Future<int> Function() queueCount,
}) async {
  const owner = 'release-owner';
  const template = PlanTemplate(
    id: 'release-template',
    name: 'Release test',
    description: '',
    phases: [
      Phase(
        id: 'phase',
        name: 'Phase',
        workouts: [
          Workout(id: 'legs', name: 'Legs', exercises: []),
          Workout(id: 'chest', name: 'Chest', exercises: []),
        ],
      ),
    ],
  );
  await database.saveTemplate(template, ownerUserId: owner);
  await database.saveInstance(
    StoredTrainingInstance(
      instanceId: 'release-instance',
      templateId: template.id,
      ownerUserId: owner,
      currentWorkoutIndex: 1,
      states: const [],
    ),
  );
  await database.saveActiveInstanceIdForUser('release-instance', owner);
  final log = WorkoutLog(
    logId: 'release-log',
    instanceId: 'release-instance',
    workoutId: 'legs',
    workoutName: 'Legs',
    dayLabel: 'Day 1',
    completedAt: DateTime.utc(2026, 9, 8),
    exercises: const [],
  );
  await database.logWorkout(log, ownerUserId: owner);
  final before = (await database.fetchInstance('release-instance'))!;
  final beforeQueue = await queueCount();
  final history = LocalWorkoutLogRepository(
    repository: database,
    ownerUserId: owner,
  );
  failNextDelete();
  await expectLater(
    history.deleteWorkoutLog(log.logId, expectedLog: log, releaseToPlan: true),
    throwsStateError,
  );
  expect(
    await database.fetchWorkoutLogById(log.logId, ownerUserId: owner),
    log,
  );
  final unchanged = (await database.fetchInstance('release-instance'))!;
  expect(unchanged.version, before.version);
  expect(unchanged.engineState, before.engineState);
  expect(await queueCount(), beforeQueue);

  await history.deleteWorkoutLog(
    log.logId,
    expectedLog: log,
    releaseToPlan: true,
  );
  final released = (await database.fetchInstance('release-instance'))!;
  expect(released.currentWorkoutIndex, 1);
  expect(releasedWorkoutQueue(released), ['legs']);
  expect(
    await database.fetchWorkoutLogById(log.logId, ownerUserId: owner),
    isNull,
  );
  await expectLater(
    history.deleteWorkoutLog(log.logId, expectedLog: log, releaseToPlan: true),
    throwsStateError,
  );
  expect(
    releasedWorkoutQueue((await database.fetchInstance('release-instance'))!),
    ['legs'],
  );
}
