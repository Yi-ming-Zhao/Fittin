import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/models/sync_queue_collection.dart';
import 'package:fittin_v2/src/data/sync/sync_models.dart';
import 'package:fittin_v2/src/domain/exercise_library.dart';
import 'package:fittin_v2/src/domain/models/cardio.dart';
import 'package:fittin_v2/src/domain/models/custom_exercise.dart';
import 'package:fittin_v2/src/domain/models/user_content.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/isar_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'user content uses owner isolation, CAS, soft deletion and sync queue',
    () async {
      final opened = await openTestIsar('user_content_repository');
      addTearDown(() async {
        await opened.isar.close(deleteFromDisk: true);
        await opened.directory.delete(recursive: true);
      });
      final repository = DatabaseRepository(opened.isar);
      final created = await repository.saveUserContent(
        UserContentDocument(
          id: 'user-exercise:test',
          kind: UserContentKind.customExercise,
          ownerUserId: 'user-a',
          payload: _exercise('Test').toJson(),
        ),
      );

      expect(created.version, 1);
      expect(created.syncStatus, SyncStatusKeys.pendingUpload);
      expect(
        await repository.fetchUserContent(created.id, ownerUserId: 'user-b'),
        isNull,
      );
      expect(
        await opened.isar.syncQueueCollections.getByQueueKey(
          '${SyncEntityTypes.userContent}:${created.id}',
        ),
        isNotNull,
      );

      await expectLater(
        repository.saveUserContent(
          created.copyWith(payload: _exercise('Stale').toJson()),
          expectedVersion: 0,
        ),
        throwsStateError,
      );
      final unchanged = await repository.fetchUserContent(
        created.id,
        ownerUserId: 'user-a',
      );
      expect(unchanged!.payload['nameEn'], 'Test');
      expect(unchanged.version, 1);

      final updated = await repository.saveUserContent(
        created.copyWith(payload: _exercise('Updated').toJson()),
        expectedVersion: 1,
      );
      expect(updated.version, 2);
      await repository.deleteUserContent(
        created.id,
        kind: created.kind,
        ownerUserId: 'user-a',
        expectedVersion: 2,
      );
      expect(
        await repository.fetchUserContent(created.id, ownerUserId: 'user-a'),
        isNull,
      );
      final deleted = await repository.fetchUserContent(
        created.id,
        ownerUserId: 'user-a',
        includeDeleted: true,
      );
      expect(deleted!.version, 3);
      expect(deleted.syncStatus, SyncStatusKeys.pendingDelete);

      await expectLater(
        repository.saveRemoteUserContent(
          UserContentDocument(
            id: 'user-exercise:remote-invalid',
            kind: UserContentKind.customExercise,
            ownerUserId: 'user-a',
            payload: {
              ..._exercise('Remote').toJson(),
              'id': 'user-exercise:remote-invalid',
              'syncStatus': 'injected',
            },
          ),
        ),
        throwsFormatException,
      );
      expect(
        await repository.fetchUserContent(
          'user-exercise:remote-invalid',
          ownerUserId: 'user-a',
        ),
        isNull,
      );
    },
  );

  test('adding the user-content Isar schema preserves existing data', () async {
    final old = await openTestIsar(
      'user_content_migration',
      includeUserContent: false,
    );
    final oldRepository = DatabaseRepository(old.isar);
    await oldRepository.saveHomeDisplayName('Existing user');
    await old.isar.close();

    final upgraded = await openTestIsar(
      'user_content_migration',
      existingDirectory: old.directory,
    );
    addTearDown(() async {
      await upgraded.isar.close(deleteFromDisk: true);
      await old.directory.delete(recursive: true);
    });
    final repository = DatabaseRepository(upgraded.isar);
    expect(await repository.fetchHomeDisplayName(), 'Existing user');
    await repository.saveUserContent(
      UserContentDocument(
        id: 'cardio-record:migrated',
        kind: UserContentKind.cardioRecord,
        payload: CardioRecord(
          id: 'cardio-record:migrated',
          activityTypeId: 'cardio:running',
          activityName: 'Running',
          startedAt: DateTime(2026, 9, 5),
          metrics: const {CardioMetricKey.durationSeconds: 1800},
        ).toJson(),
      ),
    );
    expect(
      (await repository.fetchUserContents(
        UserContentKind.cardioRecord,
      )).single.id,
      'cardio-record:migrated',
    );
  });

  test(
    'atomic user-content batch rolls back every row on a CAS conflict',
    () async {
      final opened = await openTestIsar('user_content_atomic_batch');
      addTearDown(() async {
        await opened.isar.close(deleteFromDisk: true);
        await opened.directory.delete(recursive: true);
      });
      final repository = DatabaseRepository(opened.isar);
      final existing = UserContentDocument(
        id: 'user-exercise:existing',
        kind: UserContentKind.customExercise,
        ownerUserId: 'user-a',
        payload: _exerciseWithId('user-exercise:existing', 'Existing').toJson(),
      );
      await repository.saveUserContent(existing);
      final newDocument = UserContentDocument(
        id: 'user-exercise:new',
        kind: UserContentKind.customExercise,
        ownerUserId: 'user-a',
        payload: _exerciseWithId('user-exercise:new', 'New').toJson(),
      );

      await expectLater(
        repository.saveUserContentsAtomically(
          [newDocument, existing],
          expectedVersions: {newDocument.id: 0, existing.id: 0},
        ),
        throwsStateError,
      );

      expect(
        await repository.fetchUserContent(
          newDocument.id,
          ownerUserId: 'user-a',
        ),
        isNull,
      );
      expect(
        (await repository.fetchUserContent(
          existing.id,
          ownerUserId: 'user-a',
        ))?.version,
        1,
      );
    },
  );
}

CustomExerciseDefinition _exercise(String name) => CustomExerciseDefinition(
  id: 'user-exercise:test',
  nameEn: name,
  nameZhCn: name,
  movement: ExerciseMovement.horizontalPull,
  equipment: ExerciseEquipment.cable,
  loadSemantics: ExerciseLoadSemantics.cableStack,
  primaryMuscles: const [ExerciseMuscle.upperBack],
  secondaryMuscles: const [ExerciseMuscle.biceps],
  tags: const ['back'],
);

CustomExerciseDefinition _exerciseWithId(String id, String name) =>
    CustomExerciseDefinition(
      id: id,
      nameEn: name,
      nameZhCn: name,
      movement: ExerciseMovement.horizontalPull,
      equipment: ExerciseEquipment.cable,
      loadSemantics: ExerciseLoadSemantics.cableStack,
      primaryMuscles: const [ExerciseMuscle.upperBack],
      secondaryMuscles: const [ExerciseMuscle.biceps],
      tags: const ['back'],
    );
