import 'dart:convert';

import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/sync/sync_models.dart';
import 'package:fittin_v2/src/domain/models/body_metric.dart';
import 'package:fittin_v2/src/domain/models/progress_photo.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:fittin_v2/src/domain/models/workout_log.dart';

String? serializeStoredDateTime(DateTime? value) {
  return value?.toUtc().toIso8601String();
}

DateTime? parseStoredDateTime(Object? value) {
  final stringValue = value as String?;
  return stringValue == null ? null : DateTime.parse(stringValue).toLocal();
}

StoredTemplateRecord storedTemplateRecordFromDoc(
  Map<String, dynamic> doc, {
  required int instanceCount,
}) {
  return StoredTemplateRecord(
    template: PlanTemplate.fromJson(
      jsonDecode(doc['rawJsonPayload'] as String) as Map<String, dynamic>,
    ),
    isBuiltIn: doc['isBuiltIn'] as bool? ?? false,
    sourceTemplateId: doc['sourceTemplateId'] as String?,
    createdAt: parseStoredDateTime(doc['createdAt']) ?? DateTime.now(),
    lastModifiedAt:
        parseStoredDateTime(doc['lastModifiedAt']) ?? DateTime.now(),
    instanceCount: instanceCount,
    ownerUserId: doc['ownerUserId'] as String?,
    deletedAt: parseStoredDateTime(doc['deletedAt']),
    version: doc['version'] as int? ?? 1,
    syncStatus: doc['syncStatusKey'] as String? ?? SyncStatusKeys.localOnly,
    lastSyncedAt: parseStoredDateTime(doc['lastSyncedAt']),
    lastModifiedByDeviceId: doc['lastModifiedByDeviceId'] as String?,
  );
}

StoredTrainingInstance storedTrainingInstanceFromDoc(Map<String, dynamic> doc) {
  final statesJson = (doc['currentStatesJson'] as List? ?? const <dynamic>[])
      .cast<Map>()
      .map((item) => item.cast<String, dynamic>())
      .toList();
  final trainingMaxProfileJson =
      (doc['trainingMaxProfileJson'] as Map?)?.cast<String, dynamic>() ??
      const <String, dynamic>{};
  final engineStateJson =
      (doc['engineStateJson'] as Map?)?.cast<String, dynamic>() ??
      const <String, dynamic>{};

  return StoredTrainingInstance(
    instanceId: doc['instanceId'] as String,
    templateId: doc['templateId'] as String,
    currentWorkoutIndex: doc['currentWorkoutIndex'] as int? ?? 0,
    ownerUserId: doc['ownerUserId'] as String?,
    trainingMaxProfile: trainingMaxProfileJson.isEmpty
        ? TrainingMaxProfile.empty
        : TrainingMaxProfile.fromJson(trainingMaxProfileJson),
    engineState: engineStateJson,
    states: statesJson.map(TrainingState.fromJson).toList(),
    createdAt: parseStoredDateTime(doc['createdAt']),
    updatedAt: parseStoredDateTime(doc['lastModifiedAt']),
    deletedAt: parseStoredDateTime(doc['deletedAt']),
    version: doc['version'] as int? ?? 1,
    syncStatus: doc['syncStatusKey'] as String? ?? SyncStatusKeys.localOnly,
    lastSyncedAt: parseStoredDateTime(doc['lastSyncedAt']),
    lastModifiedByDeviceId: doc['lastModifiedByDeviceId'] as String?,
  );
}

WorkoutLog workoutLogFromDoc(Map<String, dynamic> doc) {
  final log = WorkoutLog.fromJson(
    jsonDecode(doc['rawJsonPayload'] as String) as Map<String, dynamic>,
  );
  return log.logId.isEmpty ? log.copyWith(logId: doc['logId'] as String) : log;
}

BodyMetric bodyMetricFromDoc(Map<String, dynamic> doc) {
  return BodyMetric(
    metricId: doc['metricId'] as String,
    timestamp: parseStoredDateTime(doc['timestamp']) ?? DateTime.now(),
    weightKg: (doc['weightKg'] as num?)?.toDouble(),
    bodyFatPercent: (doc['bodyFatPercent'] as num?)?.toDouble(),
    waistCm: (doc['waistCm'] as num?)?.toDouble(),
    note: doc['note'] as String?,
  );
}

ProgressPhoto progressPhotoFromDoc(Map<String, dynamic> doc) {
  return ProgressPhoto(
    photoId: doc['photoId'] as String,
    timestamp: parseStoredDateTime(doc['timestamp']) ?? DateTime.now(),
    filePath: doc['filePath'] as String? ?? '',
    label: doc['label'] as String?,
    metadataJson: doc['metadataJson'] as String?,
  );
}

Map<String, dynamic> planRowFromTemplateDoc(Map<String, dynamic> doc) {
  return {
    'id': doc['templateId'],
    'user_id': doc['ownerUserId'],
    'name': doc['name'],
    'description': doc['description'],
    'source_plan_id': doc['sourceTemplateId'],
    'is_built_in': doc['isBuiltIn'] ?? false,
    'is_archived': false,
    'raw_json': doc['rawJsonPayload'],
    'created_at': doc['createdAt'],
    'updated_at': doc['lastModifiedAt'],
    'deleted_at': doc['deletedAt'],
    'version': doc['version'],
    'last_modified_by_device_id': doc['lastModifiedByDeviceId'],
  };
}

Map<String, dynamic> workoutLogRowFromDoc(Map<String, dynamic> doc) {
  return {
    'id': doc['logId'],
    'user_id': doc['ownerUserId'],
    'instance_id': doc['instanceId'],
    'workout_id': doc['workoutId'],
    'workout_name': doc['workoutName'],
    'raw_json': doc['rawJsonPayload'],
    'completed_at': doc['completedAt'],
    'created_at': doc['completedAt'],
    'updated_at': doc['completedAt'],
    'deleted_at': doc['deletedAt'],
    'version': doc['version'],
    'last_modified_by_device_id': doc['lastModifiedByDeviceId'],
  };
}

Map<String, dynamic> bodyMetricRowFromDoc(Map<String, dynamic> doc) {
  return {
    'id': doc['metricId'],
    'user_id': doc['ownerUserId'],
    'timestamp': doc['timestamp'],
    'weight_kg': doc['weightKg'],
    'body_fat_percent': doc['bodyFatPercent'],
    'waist_cm': doc['waistCm'],
    'note': doc['note'],
    'created_at': doc['timestamp'],
    'updated_at': doc['timestamp'],
    'deleted_at': doc['deletedAt'],
    'version': doc['version'],
    'last_modified_by_device_id': doc['lastModifiedByDeviceId'],
  };
}

Map<String, dynamic> progressPhotoRowFromDoc(
  Map<String, dynamic> doc, {
  required String storagePath,
}) {
  return {
    'id': doc['photoId'],
    'user_id': doc['ownerUserId'],
    'captured_at': doc['timestamp'],
    'label': doc['label'],
    'storage_path': storagePath,
    'metadata_json': doc['metadataJson'],
    'created_at': doc['timestamp'],
    'updated_at': doc['timestamp'],
    'deleted_at': doc['deletedAt'],
    'version': doc['version'],
    'last_modified_by_device_id': doc['lastModifiedByDeviceId'],
  };
}
