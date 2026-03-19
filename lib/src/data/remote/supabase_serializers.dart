import 'dart:convert';

import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/models/body_metric_collection.dart';
import 'package:fittin_v2/src/data/models/instance_collection.dart';
import 'package:fittin_v2/src/data/models/template_collection.dart';
import 'package:fittin_v2/src/data/models/workout_log_collection.dart';
import 'package:fittin_v2/src/data/sync/sync_models.dart';

Map<String, dynamic> planRowFromCollection(TemplateCollection collection) {
  return {
    'id': collection.templateId,
    'user_id': collection.ownerUserId,
    'name': collection.name,
    'description': collection.description,
    'source_plan_id': collection.sourceTemplateId,
    'is_built_in': collection.isBuiltIn,
    'is_archived': false,
    'raw_json': collection.rawJsonPayload,
    'created_at': collection.createdAt.toUtc().toIso8601String(),
    'updated_at': collection.lastModifiedAt.toUtc().toIso8601String(),
    'deleted_at': collection.deletedAt?.toUtc().toIso8601String(),
    'version': collection.version,
    'last_modified_by_device_id': collection.lastModifiedByDeviceId,
  };
}

Map<String, dynamic> instanceRowFromStored(StoredTrainingInstance instance) {
  return {
    'id': instance.instanceId,
    'user_id': instance.ownerUserId,
    'template_id': instance.templateId,
    'current_workout_index': instance.currentWorkoutIndex,
    'current_states_json': jsonEncode(
      instance.states.map((state) => state.toJson()).toList(),
    ),
    'training_max_profile_json': jsonEncode(
      instance.trainingMaxProfile.toJson(),
    ),
    'engine_state_json': jsonEncode(instance.engineState),
    'created_at': instance.createdAt.toUtc().toIso8601String(),
    'updated_at': instance.updatedAt.toUtc().toIso8601String(),
    'deleted_at': instance.deletedAt?.toUtc().toIso8601String(),
    'version': instance.version,
    'last_modified_by_device_id': instance.lastModifiedByDeviceId,
  };
}

Map<String, dynamic> workoutLogRowFromCollection(
  WorkoutLogCollection collection,
) {
  return {
    'id': collection.logId,
    'user_id': collection.ownerUserId,
    'instance_id': collection.instanceId,
    'workout_id': collection.workoutId,
    'workout_name': collection.workoutName,
    'raw_json': collection.rawJsonPayload,
    'completed_at': collection.completedAt.toUtc().toIso8601String(),
    'created_at': collection.completedAt.toUtc().toIso8601String(),
    'updated_at': collection.completedAt.toUtc().toIso8601String(),
    'deleted_at': collection.deletedAt?.toUtc().toIso8601String(),
    'version': collection.version,
    'last_modified_by_device_id': collection.lastModifiedByDeviceId,
  };
}

Map<String, dynamic> bodyMetricRowFromCollection(
  BodyMetricCollection collection,
) {
  return {
    'id': collection.metricId,
    'user_id': collection.ownerUserId,
    'timestamp': collection.timestamp.toUtc().toIso8601String(),
    'weight_kg': collection.weightKg,
    'body_fat_percent': collection.bodyFatPercent,
    'waist_cm': collection.waistCm,
    'note': collection.note,
    'created_at': collection.timestamp.toUtc().toIso8601String(),
    'updated_at': collection.timestamp.toUtc().toIso8601String(),
    'deleted_at': collection.deletedAt?.toUtc().toIso8601String(),
    'version': collection.version,
    'last_modified_by_device_id': collection.lastModifiedByDeviceId,
  };
}

Map<String, dynamic> progressPhotoRowFromCollection(
  ProgressPhotoCollection collection, {
  required String storagePath,
}) {
  return {
    'id': collection.photoId,
    'user_id': collection.ownerUserId,
    'captured_at': collection.timestamp.toUtc().toIso8601String(),
    'label': collection.label,
    'storage_path': storagePath,
    'metadata_json': collection.metadataJson,
    'created_at': collection.timestamp.toUtc().toIso8601String(),
    'updated_at': collection.timestamp.toUtc().toIso8601String(),
    'deleted_at': collection.deletedAt?.toUtc().toIso8601String(),
    'version': collection.version,
    'last_modified_by_device_id': collection.lastModifiedByDeviceId,
  };
}

String syncStatusFromDeletedAt(DateTime? deletedAt) {
  return deletedAt == null
      ? SyncStatusKeys.synced
      : SyncStatusKeys.pendingDelete;
}
