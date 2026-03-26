import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/models/body_metric_collection.dart';
import 'package:fittin_v2/src/data/models/template_collection.dart';
import 'package:fittin_v2/src/data/models/workout_log_collection.dart';
import 'package:fittin_v2/src/data/remote/supabase_serializers.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';

void main() {
  test('planRowFromCollection maps local metadata into Supabase row shape', () {
    final collection = TemplateCollection()
      ..templateId = 'plan-1'
      ..name = 'Plan'
      ..description = 'Desc'
      ..isBuiltIn = false
      ..sourceTemplateId = 'seed-1'
      ..ownerUserId = 'user-1'
      ..createdAt = DateTime.utc(2026, 1, 1)
      ..lastModifiedAt = DateTime.utc(2026, 1, 2)
      ..version = 3
      ..syncStatusKey = 'pending_upload'
      ..rawJsonPayload = '{"id":"plan-1"}';

    final row = planRowFromCollection(collection);

    expect(row['id'], 'plan-1');
    expect(row['user_id'], 'user-1');
    expect(row['version'], 3);
    expect(row['raw_json'], '{"id":"plan-1"}');
  });

  test('instanceRowFromStored maps training state payloads', () {
    final instance = StoredTrainingInstance(
      instanceId: 'instance-1',
      templateId: 'plan-1',
      currentWorkoutIndex: 2,
      ownerUserId: 'user-1',
      trainingMaxProfile: const TrainingMaxProfile({'squat': 180}),
      engineState: const {'week': 3},
      states: const [
        TrainingState(
          workoutId: 'w1',
          exerciseId: 'squat',
          exerciseName: 'Squat',
          baseWeight: 100,
          currentStageId: 'main',
        ),
      ],
      version: 4,
    );

    final row = instanceRowFromStored(instance);

    expect(row['id'], 'instance-1');
    expect(row['user_id'], 'user-1');
    expect(row['version'], 4);
    expect(row['current_workout_index'], 2);
    expect(row['current_states_json'], contains('squat'));
  });

  test(
    'workoutLogRowFromCollection includes completed timestamp and owner',
    () {
      final collection = WorkoutLogCollection()
        ..logId = 'log-1'
        ..instanceId = 'instance-1'
        ..workoutId = 'w1'
        ..workoutName = 'Day 1'
        ..ownerUserId = 'user-1'
        ..rawJsonPayload = '{"instanceId":"instance-1"}'
        ..completedAt = DateTime.utc(2026, 1, 3)
        ..version = 2
        ..syncStatusKey = 'pending_upload';

      final row = workoutLogRowFromCollection(collection);

      expect(row['id'], 'log-1');
      expect(row['user_id'], 'user-1');
      expect(row['completed_at'], DateTime.utc(2026, 1, 3).toIso8601String());
    },
  );

  test('progressPhotoRowFromCollection includes storage and sync metadata', () {
    final collection = ProgressPhotoCollection()
      ..photoId = 'photo-1'
      ..timestamp = DateTime.utc(2026, 1, 4)
      ..ownerUserId = 'user-1'
      ..filePath = '/tmp/photo.jpg'
      ..label = 'Front'
      ..metadataJson = '{"angle":"front"}'
      ..version = 5
      ..syncStatusKey = 'pending_upload'
      ..lastModifiedByDeviceId = 'device-1';

    final row = progressPhotoRowFromCollection(
      collection,
      storagePath: 'users/user-1/progress_photos/photo-1/original.jpg',
    );

    expect(row['id'], 'photo-1');
    expect(row['user_id'], 'user-1');
    expect(row['storage_path'], contains('photo-1'));
    expect(row['version'], 5);
    expect(row['metadata_json'], '{"angle":"front"}');
  });
}
