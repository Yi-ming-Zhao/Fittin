import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/supabase_bootstrap.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/models/body_metric_collection.dart';
import 'package:fittin_v2/src/data/models/template_collection.dart';
import 'package:fittin_v2/src/data/models/workout_log_collection.dart';
import 'package:fittin_v2/src/data/remote/local_file_reader.dart';
import 'package:fittin_v2/src/data/remote/supabase_serializers.dart';

final supabaseRemoteRepositoryProvider = Provider<SupabaseRemoteRepository>((
  ref,
) {
  final bootstrap = ref.watch(supabaseBootstrapProvider);
  if (!bootstrap.isConfigured) {
    return SupabaseRemoteRepository.unavailable();
  }
  return SupabaseRemoteRepository.http(
    baseUrl: bootstrap.url,
    accessTokenLoader: () => ref.read(authRepositoryProvider).currentAccessToken(),
  );
});

typedef AccessTokenLoader = Future<String?> Function();

class SupabaseRemoteRepository {
  SupabaseRemoteRepository.unavailable()
    : _baseUrl = null,
      _httpClient = null,
      _accessTokenLoader = null;

  SupabaseRemoteRepository.http({
    required String baseUrl,
    required AccessTokenLoader accessTokenLoader,
    http.Client? httpClient,
  }) : _baseUrl = baseUrl,
       _httpClient = httpClient ?? http.Client(),
       _accessTokenLoader = accessTokenLoader;

  final String? _baseUrl;
  final http.Client? _httpClient;
  final AccessTokenLoader? _accessTokenLoader;

  bool get isAvailable => _baseUrl != null;

  String get _requireBaseUrl {
    final baseUrl = _baseUrl;
    if (baseUrl == null) {
      throw StateError('Remote repository is unavailable.');
    }
    return baseUrl;
  }

  http.Client get _requireClient {
    final client = _httpClient;
    if (client == null) {
      throw StateError('Remote repository is unavailable.');
    }
    return client;
  }

  Future<void> upsertPlan(TemplateCollection collection) async {
    await upsertRow(
      table: 'plans',
      row: planRowFromCollection(collection),
    );
  }

  Future<void> upsertInstance(StoredTrainingInstance instance) async {
    await upsertRow(
      table: 'plan_instances',
      row: instanceRowFromStored(instance),
    );
  }

  Future<void> upsertWorkoutLog(WorkoutLogCollection collection) async {
    await upsertRow(
      table: 'workout_logs',
      row: workoutLogRowFromCollection(collection),
    );
  }

  Future<void> upsertBodyMetric(BodyMetricCollection collection) async {
    await upsertRow(
      table: 'body_metrics',
      row: bodyMetricRowFromCollection(collection),
    );
  }

  Future<String> uploadProgressPhoto({
    required String userId,
    required String photoId,
    required String localFilePath,
  }) async {
    final bytes = await readLocalFileBytes(localFilePath);
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_requireBaseUrl/v1/files/progress-photos'),
    );
    request.headers.addAll(await _headers());
    request.fields['userId'] = userId;
    request.fields['photoId'] = photoId;
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: '$photoId.jpg',
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final payload = _decodeJson(response);
    _ensureSuccess(response, payload);
    final storagePath = payload['storagePath'] as String?;
    if (storagePath == null || storagePath.isEmpty) {
      throw StateError('Backend file upload did not return storagePath.');
    }
    return storagePath;
  }

  Future<void> upsertProgressPhotoMetadata({
    required ProgressPhotoCollection collection,
    required String storagePath,
  }) async {
    await upsertRow(
      table: 'progress_photos',
      row: progressPhotoRowFromCollection(collection, storagePath: storagePath),
    );
  }

  Future<void> deleteById({required String table, required String id}) async {
    final response = await _requireClient.delete(
      Uri.parse('$_requireBaseUrl/v1/sync/$table/$id'),
      headers: await _headers(),
    );
    _ensureSuccess(response, _decodeJson(response));
  }

  Future<void> upsertRow({
    required String table,
    required Map<String, dynamic> row,
  }) async {
    final response = await _requireClient.post(
      Uri.parse('$_requireBaseUrl/v1/sync/upsert/$table'),
      headers: await _headers(),
      body: jsonEncode(row),
    );
    _ensureSuccess(response, _decodeJson(response));
  }

  Future<List<Map<String, dynamic>>> fetchRows({
    required String table,
    required String userId,
    String timestampColumn = 'updated_at',
    DateTime? since,
  }) async {
    final uri = Uri.parse(
      '$_requireBaseUrl/v1/sync/$table',
    ).replace(
      queryParameters: {
        'userId': userId,
        'timestampColumn': timestampColumn,
        if (since != null) 'since': since.toUtc().toIso8601String(),
      },
    );
    final response = await _requireClient.get(uri, headers: await _headers());
    final payload = _decodeJson(response);
    _ensureSuccess(response, payload);
    final rows = payload['rows'];
    if (rows is! List) {
      return const [];
    }
    return rows
        .cast<Map>()
        .map((row) => row.cast<String, dynamic>())
        .toList();
  }

  Future<Map<String, String>> _headers() async {
    final token = await _accessTokenLoader?.call();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decodeJson(http.Response response) {
    if (response.body.isEmpty) {
      return const {};
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return {'rows': decoded};
  }

  void _ensureSuccess(http.Response response, Map<String, dynamic> payload) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    final message =
        payload['error'] as String? ??
        payload['message'] as String? ??
        'Backend request failed with status ${response.statusCode}.';
    throw StateError(message);
  }
}
