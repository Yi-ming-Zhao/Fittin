import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/models/body_metric_collection.dart';
import 'package:fittin_v2/src/data/models/sync_queue_collection.dart';
import 'package:fittin_v2/src/data/progress_repository.dart';
import 'package:fittin_v2/src/data/sync/sync_models.dart';
import 'package:fittin_v2/src/data/sync/sync_service.dart';
import 'package:fittin_v2/src/domain/models/body_metric.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';

import '../support/fake_supabase_remote_repository.dart';
import '../support/isar_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Isar isar;
  late Directory directory;
  late DatabaseRepository databaseRepository;
  late ProgressRepository progressRepository;
  late FakeSupabaseRemoteRepository remoteRepository;
  late SyncService syncService;

  setUp(() async {
    final testStore = await openTestIsar('sync_service_test');
    isar = testStore.isar;
    directory = testStore.directory;
    databaseRepository = DatabaseRepository(isar);
    progressRepository = ProgressRepository(isar);
    remoteRepository = FakeSupabaseRemoteRepository();
    syncService = SyncService(
      databaseRepository: databaseRepository,
      progressRepository: progressRepository,
      remoteRepository: remoteRepository,
      ownerUserId: 'user-123',
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });

  test('synchronize merges first-login local data and reconciles remote rows', () async {
    final localTemplate = PlanTemplate(
      id: 'local-template',
      name: 'Local Template',
      description: 'Saved before login',
      phases: const [],
    );
    await databaseRepository.saveTemplate(localTemplate);
    await databaseRepository.saveInstance(
      StoredTrainingInstance(
        instanceId: 'local-instance',
        templateId: 'local-template',
        currentWorkoutIndex: 0,
        states: const [
          TrainingState(
            workoutId: 'w1',
            exerciseId: 'e1',
            exerciseName: 'Squat',
            baseWeight: 100,
            currentStageId: 'stage-a',
          ),
        ],
        trainingMaxProfile: const TrainingMaxProfile({'squat': 150}),
        engineState: const {'wave': 1},
      ),
    );
    await databaseRepository.logWorkout(
      WorkoutLog(
        instanceId: 'local-instance',
        workoutId: 'w1',
        workoutName: 'Workout A',
        dayLabel: 'Day 1',
        completedAt: DateTime(2026, 3, 19, 9),
        exercises: const [
          ExerciseLog(
            exerciseId: 'e1',
            exerciseName: 'Squat',
            stageId: 'stage-a',
            sets: [
              SetLog(
                role: 'work',
                targetReps: 5,
                completedReps: 5,
                targetWeight: 100,
                weight: 100,
                isCompleted: true,
              ),
            ],
          ),
        ],
      ),
    );
    await progressRepository.saveBodyMetric(
      BodyMetric(
        metricId: 'metric-local',
        timestamp: DateTime(2026, 3, 19, 8),
        weightKg: 81.5,
      ),
    );

    remoteRepository.rowsByTable['plans'] = [
      {
        'id': 'remote-template',
        'user_id': 'user-123',
        'name': 'Remote Template',
        'description': 'Pulled from cloud',
        'source_plan_id': null,
        'is_built_in': false,
        'raw_json': '{"id":"remote-template","name":"Remote Template","description":"Pulled from cloud","phases":[],"workouts":[]}',
        'created_at': '2026-03-18T09:00:00.000Z',
        'updated_at': '2026-03-18T09:00:00.000Z',
        'deleted_at': null,
        'version': 1,
        'last_modified_by_device_id': 'device-remote',
      },
    ];
    remoteRepository.rowsByTable['plan_instances'] = [
      {
        'id': 'remote-instance',
        'user_id': 'user-123',
        'template_id': 'remote-template',
        'current_workout_index': 1,
        'current_states_json': '[{"workoutId":"rw1","exerciseId":"re1","exerciseName":"Bench","baseWeight":70.0,"currentStageId":"stage-1","history":[]}]',
        'training_max_profile_json': '{"bench":90.0}',
        'engine_state_json': '{"wave":2}',
        'created_at': '2026-03-18T10:00:00.000Z',
        'updated_at': '2026-03-18T10:00:00.000Z',
        'deleted_at': null,
        'version': 1,
        'last_modified_by_device_id': 'device-remote',
      },
    ];
    remoteRepository.rowsByTable['workout_logs'] = [
      {
        'id': 'remote-instance_rw1_1710820800000',
        'user_id': 'user-123',
        'instance_id': 'remote-instance',
        'workout_id': 'rw1',
        'workout_name': 'Remote Workout',
        'raw_json': '{"instanceId":"remote-instance","workoutId":"rw1","workoutName":"Remote Workout","dayLabel":"Day R","completedAt":"2026-03-18T12:00:00.000Z","exercises":[]}',
        'completed_at': '2026-03-18T12:00:00.000Z',
        'deleted_at': null,
        'version': 1,
        'last_modified_by_device_id': 'device-remote',
      },
    ];
    remoteRepository.rowsByTable['body_metrics'] = [
      {
        'id': 'metric-remote',
        'user_id': 'user-123',
        'timestamp': '2026-03-18T07:00:00.000Z',
        'weight_kg': 79.3,
        'body_fat_percent': null,
        'waist_cm': null,
        'note': 'Remote note',
        'deleted_at': null,
        'version': 1,
        'last_modified_by_device_id': 'device-remote',
      },
    ];

    await syncService.synchronize();

    final pushedTables = remoteRepository.upserts
        .map((entry) => entry['table'])
        .toSet();
    final templates = await databaseRepository.fetchTemplates(
      ownerUserId: 'user-123',
    );
    final remoteInstance = await databaseRepository.fetchInstance(
      'remote-instance',
    );
    final logs = await databaseRepository.fetchAllWorkoutLogs(
      ownerUserId: 'user-123',
    );
    final metrics = await progressRepository.fetchBodyMetrics(
      ownerUserId: 'user-123',
    );
    final remainingQueue = await isar.syncQueueCollections.where().findAll();

    expect(
      pushedTables,
      containsAll({
        'plans',
        'plan_instances',
        'workout_logs',
        'body_metrics',
      }),
    );
    expect(
      templates.map((record) => record.template.id),
      containsAll(['local-template', 'remote-template']),
    );
    expect(remoteInstance, isNotNull);
    expect(logs.map((log) => log.workoutId), containsAll(['w1', 'rw1']));
    expect(
      metrics.map((metric) => metric.metricId),
      containsAll(['metric-local', 'metric-remote']),
    );
    expect(remainingQueue, isEmpty);
  });

  test('synchronize propagates soft deletes for body metrics', () async {
    await progressRepository.saveBodyMetric(
      BodyMetric(
        metricId: 'metric-delete',
        timestamp: DateTime(2026, 3, 19, 14),
        weightKg: 80.2,
      ),
      ownerUserId: 'user-123',
    );
    await progressRepository.deleteBodyMetric('metric-delete');

    await syncService.synchronize();

    final collection = await isar.bodyMetricCollections
        .filter()
        .metricIdEqualTo('metric-delete')
        .findFirst();
    final queue = await isar.syncQueueCollections
        .getByQueueKey('${SyncEntityTypes.bodyMetric}:metric-delete');

    expect(
      remoteRepository.deletes.any(
        (entry) =>
            entry['table'] == 'body_metrics' &&
            entry['id'] == 'metric-delete',
      ),
      isTrue,
    );
    expect(collection?.deletedAt, isNotNull);
    expect(collection?.syncStatusKey, SyncStatusKeys.synced);
    expect(queue, isNull);
  });
}
