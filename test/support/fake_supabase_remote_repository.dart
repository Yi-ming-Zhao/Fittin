import 'package:fittin_v2/src/data/models/body_metric_collection.dart';
import 'package:fittin_v2/src/data/models/template_collection.dart';
import 'package:fittin_v2/src/data/models/workout_log_collection.dart';
import 'package:fittin_v2/src/data/remote/supabase_remote_repository.dart';

class FakeSupabaseRemoteRepository extends SupabaseRemoteRepository {
  FakeSupabaseRemoteRepository() : super(null);

  final List<Map<String, Object?>> upserts = [];
  final List<Map<String, String>> deletes = [];
  final Map<String, List<Map<String, dynamic>>> rowsByTable = {};
  final List<Map<String, String>> uploads = [];

  @override
  bool get isAvailable => true;

  @override
  Future<void> upsertPlan(TemplateCollection collection) async {
    upserts.add({
      'table': 'plans',
      'id': collection.templateId,
      'ownerUserId': collection.ownerUserId,
    });
  }

  @override
  Future<void> upsertInstance(instance) async {
    upserts.add({
      'table': 'plan_instances',
      'id': instance.instanceId,
      'ownerUserId': instance.ownerUserId,
    });
  }

  @override
  Future<void> upsertWorkoutLog(WorkoutLogCollection collection) async {
    upserts.add({
      'table': 'workout_logs',
      'id': collection.logId,
      'ownerUserId': collection.ownerUserId,
    });
  }

  @override
  Future<void> upsertBodyMetric(BodyMetricCollection collection) async {
    upserts.add({
      'table': 'body_metrics',
      'id': collection.metricId,
      'ownerUserId': collection.ownerUserId,
    });
  }

  @override
  Future<String> uploadProgressPhoto({
    required String userId,
    required String photoId,
    required String localFilePath,
  }) async {
    uploads.add({
      'userId': userId,
      'photoId': photoId,
      'localFilePath': localFilePath,
    });
    return 'users/$userId/progress_photos/$photoId/original.jpg';
  }

  @override
  Future<void> upsertProgressPhotoMetadata({
    required collection,
    required String storagePath,
  }) async {
    upserts.add({
      'table': 'progress_photos',
      'id': collection.photoId,
      'ownerUserId': collection.ownerUserId,
      'storagePath': storagePath,
    });
  }

  @override
  Future<void> deleteById({required String table, required String id}) async {
    deletes.add({'table': table, 'id': id});
  }

  @override
  Future<List<Map<String, dynamic>>> fetchRows({
    required String table,
    required String userId,
    String timestampColumn = 'updated_at',
    DateTime? since,
  }) async {
    return rowsByTable[table] ?? const [];
  }
}
