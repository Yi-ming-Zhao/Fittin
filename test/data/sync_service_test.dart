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
import 'package:fittin_v2/src/domain/models/progress_photo.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';

import '../support/fake_supabase_remote_repository.dart';
import '../support/isar_test_helper.dart';

class _FlakySupabaseRemoteRepository extends FakeSupabaseRemoteRepository {
  bool failNextUpsert = true;

  @override
  Future<void> upsertBodyMetric(BodyMetricCollection collection) async {
    if (failNextUpsert) {
      failNextUpsert = false;
      throw Exception('Network timeout');
    }
    await super.upsertBodyMetric(collection);
  }
}

class _FailingFirstPullRemoteRepository extends FakeSupabaseRemoteRepository {
  bool _hasFailed = false;

  @override
  Future<List<Map<String, dynamic>>> fetchRows({
    required String table,
    required String userId,
    String timestampColumn = 'updated_at',
    DateTime? since,
  }) async {
    if (!_hasFailed) {
      _hasFailed = true;
      throw Exception('Remote pull failed');
    }
    return super.fetchRows(
      table: table,
      userId: userId,
      timestampColumn: timestampColumn,
      since: since,
    );
  }
}

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
    await progressRepository.saveProgressPhoto(
      ProgressPhoto(
        photoId: 'photo-local',
        timestamp: DateTime(2026, 3, 19, 8, 30),
        filePath: '/tmp/local-progress.jpg',
        label: 'Front',
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
    remoteRepository.rowsByTable['progress_photos'] = [
      {
        'id': 'photo-remote',
        'user_id': 'user-123',
        'captured_at': '2026-03-18T06:30:00.000Z',
        'label': 'Back',
        'storage_path': 'users/user-123/progress_photos/photo-remote/original.jpg',
        'metadata_json': '{"angle":"back"}',
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
    final activeInstance = await databaseRepository
        .fetchActiveInstanceForUser('user-123');
    final logs = await databaseRepository.fetchAllWorkoutLogs(
      ownerUserId: 'user-123',
    );
    final metrics = await progressRepository.fetchBodyMetrics(
      ownerUserId: 'user-123',
    );
    final photos = await progressRepository.fetchProgressPhotos(
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
        'progress_photos',
      }),
    );
    expect(remoteRepository.uploads, hasLength(1));
    expect(
      templates.map((record) => record.template.id),
      containsAll(['local-template', 'remote-template']),
    );
    expect(remoteInstance, isNotNull);
    expect(activeInstance?.instanceId, 'remote-instance');
    expect(logs.map((log) => log.workoutId), containsAll(['w1', 'rw1']));
    expect(
      metrics.map((metric) => metric.metricId),
      containsAll(['metric-local', 'metric-remote']),
    );
    expect(
      photos.map((photo) => photo.photoId),
      containsAll(['photo-local', 'photo-remote']),
    );
    expect(
      photos.firstWhere((photo) => photo.photoId == 'photo-remote').filePath,
      'users/user-123/progress_photos/photo-remote/original.jpg',
    );
    expect(remainingQueue, isEmpty);
  });

  test(
    'claims local logs and active plan before the first remote pull',
    () async {
      await _seedLocalPowerbuildingData(databaseRepository);
      final failingRemote = _FailingFirstPullRemoteRepository();
      syncService = SyncService(
        databaseRepository: databaseRepository,
        progressRepository: progressRepository,
        remoteRepository: failingRemote,
        ownerUserId: 'user-123',
      );

      await expectLater(syncService.synchronize(), throwsException);

      final active = await databaseRepository.fetchActiveInstanceForUser(
        'user-123',
      );
      final logs = await databaseRepository.fetchAllWorkoutLogs(
        ownerUserId: 'user-123',
      );

      expect(active?.instanceId, 'user-123-local-powerbuilding-instance');
      expect(active?.templateId, 'powerbuilding-4day-12week');
      expect(logs, hasLength(1));
      expect(logs.single.instanceId, active?.instanceId);
    },
  );

  test(
    'keeps a claimed local active plan when remote instances exist',
    () async {
      await _seedLocalPowerbuildingData(databaseRepository);
      remoteRepository.rowsByTable['plan_instances'] = [
        _remoteInstanceRow(
          id: 'remote-newer-instance',
          templateId: 'remote-other-template',
        ),
      ];

      await syncService.synchronize();

      final active = await databaseRepository.fetchActiveInstanceForUser(
        'user-123',
      );
      final remoteInstance = await databaseRepository.fetchInstance(
        'remote-newer-instance',
      );

      expect(active?.instanceId, 'user-123-local-powerbuilding-instance');
      expect(active?.templateId, 'powerbuilding-4day-12week');
      expect(remoteInstance, isNotNull);
    },
  );

  test('synchronize replays queued changes after a retryable failure', () async {
    final flakyRemote = _FlakySupabaseRemoteRepository();
    syncService = SyncService(
      databaseRepository: databaseRepository,
      progressRepository: progressRepository,
      remoteRepository: flakyRemote,
      ownerUserId: 'user-123',
    );

    await progressRepository.saveBodyMetric(
      BodyMetric(
        metricId: 'metric-retry',
        timestamp: DateTime(2026, 3, 20, 7),
        weightKg: 82.1,
      ),
      ownerUserId: 'user-123',
    );

    await expectLater(syncService.synchronize(), throwsException);

    final queuedAfterFailure = await isar.syncQueueCollections.where().findAll();
    final metricAfterFailure = await isar.bodyMetricCollections
        .filter()
        .metricIdEqualTo('metric-retry')
        .findFirst();

    expect(queuedAfterFailure, hasLength(1));
    expect(metricAfterFailure?.syncStatusKey, SyncStatusKeys.pendingUpload);

    await syncService.synchronize();

    final queuedAfterRetry = await isar.syncQueueCollections.where().findAll();
    final metricAfterRetry = await isar.bodyMetricCollections
        .filter()
        .metricIdEqualTo('metric-retry')
        .findFirst();

    expect(flakyRemote.upserts.where((entry) => entry['table'] == 'body_metrics'), hasLength(1));
    expect(queuedAfterRetry, isEmpty);
    expect(metricAfterRetry?.syncStatusKey, SyncStatusKeys.synced);
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

  test('synchronize preserves local conflicts for newer pending progress data', () async {
    await progressRepository.saveBodyMetric(
      BodyMetric(
        metricId: 'metric-conflict',
        timestamp: DateTime(2026, 3, 19, 18),
        weightKg: 82.0,
      ),
      ownerUserId: 'user-123',
    );

    final localMetric = await isar.bodyMetricCollections
        .filter()
        .metricIdEqualTo('metric-conflict')
        .findFirst();
    expect(localMetric, isNotNull);
    localMetric!
      ..syncStatusKey = SyncStatusKeys.conflict
      ..version = 2;
    await isar.writeTxn(() async {
      await isar.bodyMetricCollections.put(localMetric);
      await isar.syncQueueCollections.clear();
    });

    remoteRepository.rowsByTable['body_metrics'] = [
      {
        'id': 'metric-conflict',
        'user_id': 'user-123',
        'timestamp': '2026-03-19T09:00:00.000Z',
        'weight_kg': 79.0,
        'body_fat_percent': null,
        'waist_cm': null,
        'note': 'Older remote value',
        'deleted_at': null,
        'version': 1,
        'last_modified_by_device_id': 'device-remote',
      },
    ];

    await syncService.synchronize();

    final conflictedMetric = await isar.bodyMetricCollections
        .filter()
        .metricIdEqualTo('metric-conflict')
        .findFirst();

    expect(conflictedMetric?.syncStatusKey, SyncStatusKeys.conflict);
    expect(conflictedMetric?.weightKg, 82.0);
  });
}

Future<void> _seedLocalPowerbuildingData(DatabaseRepository repository) async {
  const instanceId = 'local-powerbuilding-instance';
  await repository.saveInstance(
    StoredTrainingInstance(
      instanceId: instanceId,
      templateId: 'powerbuilding-4day-12week',
      currentWorkoutIndex: 2,
      states: const [],
      trainingMaxProfile: const TrainingMaxProfile({
        'squat': 180,
        'bench': 110,
        'deadlift': 220,
      }),
      engineState: const {},
    ),
  );
  await repository.saveActiveInstanceId(instanceId);
  await repository.logWorkout(
    WorkoutLog(
      instanceId: instanceId,
      workoutId: 'power-day-1',
      workoutName: 'Power Day 1',
      dayLabel: 'W1D1',
      completedAt: DateTime(2026, 7, 13, 9),
      exercises: const [],
    ),
  );
}

Map<String, dynamic> _remoteInstanceRow({
  required String id,
  required String templateId,
}) {
  return {
    'id': id,
    'user_id': 'user-123',
    'template_id': templateId,
    'current_workout_index': 4,
    'current_states_json': '[]',
    'training_max_profile_json': '{}',
    'engine_state_json': '{}',
    'created_at': '2026-07-13T01:00:00.000Z',
    'updated_at': '2026-07-13T02:00:00.000Z',
    'deleted_at': null,
    'version': 1,
    'last_modified_by_device_id': 'remote-device',
  };
}
