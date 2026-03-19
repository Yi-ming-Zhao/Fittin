import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/supabase_bootstrap.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/models/body_metric_collection.dart';
import 'package:fittin_v2/src/data/models/template_collection.dart';
import 'package:fittin_v2/src/data/models/workout_log_collection.dart';
import 'package:fittin_v2/src/data/remote/supabase_serializers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseRemoteRepositoryProvider = Provider<SupabaseRemoteRepository>((
  ref,
) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseRemoteRepository(client);
});

class SupabaseRemoteRepository {
  SupabaseRemoteRepository(this._client);

  final SupabaseClient? _client;

  bool get isAvailable => _client != null;

  SupabaseClient get _requireClient {
    final client = _client;
    if (client == null) {
      throw StateError('Supabase remote repository is unavailable.');
    }
    return client;
  }

  Future<void> upsertPlan(TemplateCollection collection) async {
    await _requireClient
        .from('plans')
        .upsert(planRowFromCollection(collection));
  }

  Future<void> upsertInstance(StoredTrainingInstance instance) async {
    await _requireClient
        .from('plan_instances')
        .upsert(instanceRowFromStored(instance));
  }

  Future<void> upsertWorkoutLog(WorkoutLogCollection collection) async {
    await _requireClient
        .from('workout_logs')
        .upsert(workoutLogRowFromCollection(collection));
  }

  Future<void> upsertBodyMetric(BodyMetricCollection collection) async {
    await _requireClient
        .from('body_metrics')
        .upsert(bodyMetricRowFromCollection(collection));
  }

  Future<String> uploadProgressPhoto({
    required String userId,
    required String photoId,
    required String localFilePath,
  }) async {
    final storagePath = 'users/$userId/progress_photos/$photoId/original.jpg';
    await _requireClient.storage
        .from('progress-photos')
        .upload(
          storagePath,
          File(localFilePath),
          fileOptions: const FileOptions(upsert: true),
        );
    return storagePath;
  }

  Future<void> upsertProgressPhotoMetadata({
    required ProgressPhotoCollection collection,
    required String storagePath,
  }) async {
    await _requireClient
        .from('progress_photos')
        .upsert(
          progressPhotoRowFromCollection(collection, storagePath: storagePath),
        );
  }

  Future<void> deleteById({required String table, required String id}) async {
    await _requireClient.from(table).delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> fetchRows({
    required String table,
    required String userId,
    String timestampColumn = 'updated_at',
    DateTime? since,
  }) async {
    var query = _requireClient.from(table).select().eq('user_id', userId);
    if (since != null) {
      query = query.gte(timestampColumn, since.toUtc().toIso8601String());
    }
    final rows = await query;
    return (rows as List)
        .cast<Map>()
        .map((row) => row.cast<String, dynamic>())
        .toList();
  }
}
