import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/web_database_repository.dart';
import 'package:fittin_v2/src/data/web_local_store.dart';
import 'package:fittin_v2/src/data/web_progress_repository.dart';
import 'package:fittin_v2/src/data/web_sync_service.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';
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
