import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/sync/sync_models.dart';
import 'package:fittin_v2/src/data/sync/sync_service.dart'
    show SyncConflictException;
import 'package:fittin_v2/src/data/web_database_repository.dart';
import 'package:fittin_v2/src/data/web_local_store.dart';
import 'package:fittin_v2/src/data/web_progress_repository.dart';
import 'package:fittin_v2/src/data/web_sync_service.dart';
import 'package:fittin_v2/src/domain/exercise_library.dart';
import 'package:fittin_v2/src/domain/models/custom_exercise.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';
import 'package:fittin_v2/src/domain/models/user_content.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';

import '../support/fake_supabase_remote_repository.dart';

class _MemoryWebLocalStore extends WebLocalStore {
  final Map<String, Map<String, Map<String, dynamic>>> _records = {};

  @override
  Future<Map<String, dynamic>?> getRecord(String storeName, String key) async {
    final record = _records[storeName]?[key];
    return record == null ? null : Map<String, dynamic>.from(record);
  }

  @override
  Future<List<Map<String, dynamic>>> getAllRecords(String storeName) async {
    return _records[storeName]?.values
            .map((record) => Map<String, dynamic>.from(record))
            .toList() ??
        const [];
  }

  @override
  Future<void> putRecord(
    String storeName,
    String key,
    Map<String, dynamic> value,
  ) async {
    (_records[storeName] ??= {})[key] = Map<String, dynamic>.from(value);
  }

  @override
  Future<void> deleteRecord(String storeName, String key) async {
    _records[storeName]?.remove(key);
  }

  @override
  Future<T> runInTransaction<T>(
    List<String> storeNames,
    Future<T> Function() operation,
  ) async {
    final before = <String, Map<String, Map<String, dynamic>>>{
      for (final storeName in storeNames)
        storeName: {
          for (final entry in (_records[storeName] ?? const {}).entries)
            entry.key: Map<String, dynamic>.from(entry.value),
        },
    };
    try {
      return await operation();
    } on Object {
      for (final storeName in storeNames) {
        _records[storeName] = before[storeName]!;
      }
      rethrow;
    }
  }
}

class _FakeWebRemoteRepository extends FakeSupabaseRemoteRepository {
  final List<Map<String, Object?>> webUpserts = [];

  @override
  Future<void> upsertRow({
    required String table,
    required Map<String, dynamic> row,
  }) async {
    webUpserts.add({'table': table, 'id': row['id']});
  }
}

class _FailingFirstWebPullRemoteRepository extends _FakeWebRemoteRepository {
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

class _PausedWebInstanceRemoteRepository extends _FakeWebRemoteRepository {
  final started = Completer<void>();
  final release = Completer<void>();

  @override
  Future<void> upsertInstance(instance) async {
    if (!started.isCompleted) started.complete();
    await release.future;
    await super.upsertInstance(instance);
  }
}

void main() {
  late WebDatabaseRepository databaseRepository;
  late WebProgressRepository progressRepository;
  late _FakeWebRemoteRepository remoteRepository;
  late WebSyncService syncService;

  setUp(() {
    final store = _MemoryWebLocalStore();
    databaseRepository = WebDatabaseRepository(store);
    progressRepository = WebProgressRepository(store);
    remoteRepository = _FakeWebRemoteRepository();
    syncService = WebSyncService(
      databaseRepository: databaseRepository,
      progressRepository: progressRepository,
      remoteRepository: remoteRepository,
      ownerUserId: 'user-123',
    );
  });

  test('Web user-content batch rolls back on a CAS conflict', () async {
    const existingId = 'user-exercise:web-existing';
    const newId = 'user-exercise:web-new';
    final existing = UserContentDocument(
      id: existingId,
      kind: UserContentKind.customExercise,
      ownerUserId: 'user-123',
      payload: _exercisePayload(existingId, 'Existing'),
    );
    final newDocument = UserContentDocument(
      id: newId,
      kind: UserContentKind.customExercise,
      ownerUserId: 'user-123',
      payload: _exercisePayload(newId, 'New'),
    );
    await databaseRepository.saveUserContent(existing);

    await expectLater(
      databaseRepository.saveUserContentsAtomically(
        [newDocument, existing],
        expectedVersions: const {newId: 0, existingId: 0},
      ),
      throwsStateError,
    );

    expect(
      await databaseRepository.fetchUserContent(newId, ownerUserId: 'user-123'),
      isNull,
    );
    expect(
      (await databaseRepository.fetchUserContent(
        existingId,
        ownerUserId: 'user-123',
      ))?.version,
      1,
    );
  });

  test('Web sync pushes and hydrates validated user content', () async {
    const localId = 'user-exercise:web-local';
    await databaseRepository.saveUserContent(
      UserContentDocument(
        id: localId,
        kind: UserContentKind.customExercise,
        ownerUserId: 'user-123',
        payload: _exercisePayload(localId, 'Web local'),
      ),
      deviceId: 'web-device',
    );

    await syncService.synchronize();

    expect(
      remoteRepository.webUpserts,
      contains(
        allOf(
          containsPair('table', 'user_content'),
          containsPair('id', localId),
        ),
      ),
    );
    final uploaded = await databaseRepository.fetchUserContentOfKind(
      localId,
      kind: UserContentKind.customExercise,
      ownerUserId: 'user-123',
    );
    expect(uploaded?.syncStatus, SyncStatusKeys.synced);

    const remoteId = 'user-exercise:web-remote';
    remoteRepository.rowsByTable['user_content'] = [
      _remoteUserContentRow(
        id: remoteId,
        payload: _exercisePayload(remoteId, 'Web remote'),
      ),
    ];
    await syncService.synchronize();

    final hydrated = await databaseRepository.fetchUserContentOfKind(
      remoteId,
      kind: UserContentKind.customExercise,
      ownerUserId: 'user-123',
    );
    expect(hydrated?.payload['nameEn'], 'Web remote');
    expect(hydrated?.syncStatus, SyncStatusKeys.synced);
  });

  test('Web sync retains pending user content after divergence', () async {
    const id = 'user-exercise:web-conflict';
    await databaseRepository.saveUserContent(
      UserContentDocument(
        id: id,
        kind: UserContentKind.customExercise,
        ownerUserId: 'user-123',
        payload: _exercisePayload(id, 'Web local edit'),
      ),
      deviceId: 'web-device',
    );
    remoteRepository.rowsByTable['user_content'] = [
      _remoteUserContentRow(
        id: id,
        payload: _exercisePayload(id, 'Web remote edit'),
      ),
    ];

    await expectLater(
      syncService.synchronize(),
      throwsA(isA<SyncConflictException>()),
    );

    final retained = await databaseRepository.fetchUserContentOfKind(
      id,
      kind: UserContentKind.customExercise,
      ownerUserId: 'user-123',
    );
    expect(retained?.payload['nameEn'], 'Web local edit');
    expect(retained?.syncStatus, SyncStatusKeys.conflict);
    expect(
      remoteRepository.webUpserts.where((row) => row['id'] == id),
      isEmpty,
    );
  });

  test(
    'claims web logs and active plan before the first remote pull',
    () async {
      await _seedLocalPowerbuildingData(databaseRepository);
      final failingRemote = _FailingFirstWebPullRemoteRepository();
      syncService = WebSyncService(
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

  test('keeps a claimed web active plan when remote instances exist', () async {
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
  });

  test(
    'late Web upload success preserves a newer workout conclusion and queue',
    () async {
      const ownerUserId = 'user-123';
      final remote = _PausedWebInstanceRemoteRepository();
      syncService = WebSyncService(
        databaseRepository: databaseRepository,
        progressRepository: progressRepository,
        remoteRepository: remote,
        ownerUserId: ownerUserId,
      );
      await databaseRepository.saveInstance(
        StoredTrainingInstance(
          instanceId: 'instance-concurrent',
          templateId: 'template-concurrent',
          currentWorkoutIndex: 0,
          ownerUserId: ownerUserId,
          states: const [],
          engineState: const {'week': 0},
        ),
        deviceId: 'device-local',
      );
      final before = (await databaseRepository.fetchInstance(
        'instance-concurrent',
      ))!;
      final after = before.copyWith(
        currentWorkoutIndex: 1,
        engineState: const {'week': 1},
      );
      final log = WorkoutLog(
        logId: 'conclusion-concurrent',
        instanceId: before.instanceId,
        workoutId: 'workout-a',
        workoutName: 'Workout A',
        dayLabel: 'Day 1',
        completedAt: DateTime.utc(2026, 9, 4),
        exercises: const [],
        preConclusionSnapshot: _snapshot(before),
        postConclusionSnapshot: _snapshot(after),
      );

      final synchronization = syncService.synchronize();
      await remote.started.future;
      expect(
        await databaseRepository.commitWorkoutConclusion(
          logRecord: log,
          expectedInstance: before,
          postInstance: after,
          ownerUserId: ownerUserId,
        ),
        isTrue,
      );
      remote.release.complete();
      await synchronization;

      final stored = await databaseRepository.fetchInstance(before.instanceId);
      final queue = await databaseRepository.store.getAllRecords(
        WebStoreNames.syncQueue,
      );
      expect(stored?.currentWorkoutIndex, 1);
      expect(stored?.version, 2);
      expect(stored?.syncStatus, SyncStatusKeys.pendingUpload);
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

Future<void> _seedLocalPowerbuildingData(
  WebDatabaseRepository repository,
) async {
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

Map<String, dynamic> _exercisePayload(String id, String name) {
  return CustomExerciseDefinition(
    id: id,
    nameEn: name,
    nameZhCn: name,
    movement: ExerciseMovement.squat,
    equipment: ExerciseEquipment.barbell,
    loadSemantics: ExerciseLoadSemantics.totalExternal,
    primaryMuscles: const [ExerciseMuscle.quadriceps],
    secondaryMuscles: const [ExerciseMuscle.glutes],
    tags: const ['test'],
  ).toJson();
}

Map<String, dynamic> _remoteUserContentRow({
  required String id,
  required Map<String, dynamic> payload,
}) {
  return {
    'id': id,
    'user_id': 'user-123',
    'kind': UserContentKind.customExercise.name,
    'payload_json': jsonEncode(payload),
    'created_at': '2026-09-04T01:00:00.000Z',
    'updated_at': '2026-09-04T02:00:00.000Z',
    'deleted_at': null,
    'version': 1,
    'last_modified_by_device_id': 'remote-device',
  };
}
