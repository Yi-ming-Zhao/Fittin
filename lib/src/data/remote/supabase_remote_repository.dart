import 'dart:async';
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
import 'package:fittin_v2/src/data/remote/progress_photo_cache.dart';
import 'package:fittin_v2/src/data/remote/supabase_serializers.dart';

final supabaseRemoteRepositoryProvider = Provider<SupabaseRemoteRepository>((
  ref,
) {
  final bootstrap = ref.watch(supabaseBootstrapProvider);
  if (!bootstrap.isConfigured) {
    return SupabaseRemoteRepository.unavailable();
  }
  final repository = SupabaseRemoteRepository.http(
    baseUrl: bootstrap.url,
    accessTokenLoader: () =>
        ref.read(authRepositoryProvider).currentAccessToken(),
  );
  ref.onDispose(repository.dispose);
  return repository;
});

typedef AccessTokenLoader = Future<String?> Function();

class SupabaseRemoteRepository {
  SupabaseRemoteRepository.unavailable()
    : _baseUrl = null,
      _httpClient = null,
      _accessTokenLoader = null,
      _ownsClient = false;

  SupabaseRemoteRepository.http({
    required String baseUrl,
    required AccessTokenLoader accessTokenLoader,
    http.Client? httpClient,
  }) : _baseUrl = baseUrl,
       _httpClient = httpClient ?? http.Client(),
       _accessTokenLoader = accessTokenLoader,
       _ownsClient = httpClient == null;

  final String? _baseUrl;
  final http.Client? _httpClient;
  final AccessTokenLoader? _accessTokenLoader;
  final bool _ownsClient;
  static const requestTimeout = Duration(seconds: 12);

  bool get isAvailable => _baseUrl != null;

  void dispose() {
    if (_ownsClient) {
      _httpClient?.close();
    }
  }

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
    await upsertRow(table: 'plans', row: planRowFromCollection(collection));
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
      http.MultipartFile.fromBytes('file', bytes, filename: '$photoId.jpg'),
    );

    final response = await _sendMultipart(request);
    final payload = _decodeJson(response);
    _ensureSuccess(response, payload);
    final storagePath = payload['storagePath'] as String?;
    if (storagePath == null || storagePath.isEmpty) {
      throw StateError('Backend file upload did not return storagePath.');
    }
    return storagePath;
  }

  Future<List<int>> downloadProgressPhoto(String photoId) async {
    final headers = await _headers(contentType: false);
    final response = await _guardRequest(
      () => _requireClient.get(
        Uri.parse('$_requireBaseUrl/v1/files/progress-photos/$photoId'),
        headers: headers,
      ),
    );
    final payload = _decodeJson(response);
    _ensureSuccess(response, payload);
    return response.bodyBytes;
  }

  Future<String> downloadProgressPhotoToLocal(String photoId) async {
    final bytes = await downloadProgressPhoto(photoId);
    return cacheProgressPhotoBytes(photoId, bytes);
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

  Future<void> deleteById({
    required String table,
    required String id,
    int? version,
    String? deviceId,
  }) async {
    final headers = await _headers();
    final response = await _guardRequest(
      () => _requireClient.delete(
        Uri.parse('$_requireBaseUrl/v1/sync/$table/$id').replace(
          queryParameters: {
            if (version != null) 'version': '$version',
            if (deviceId != null && deviceId.isNotEmpty) 'deviceId': deviceId,
          },
        ),
        headers: headers,
      ),
    );
    _ensureSuccess(response, _decodeJson(response));
  }

  Future<void> upsertRow({
    required String table,
    required Map<String, dynamic> row,
  }) async {
    final headers = await _headers();
    final response = await _guardRequest(
      () => _requireClient.post(
        Uri.parse('$_requireBaseUrl/v1/sync/upsert/$table'),
        headers: headers,
        body: jsonEncode(row),
      ),
    );
    _ensureSuccess(response, _decodeJson(response));
  }

  Future<List<Map<String, dynamic>>> fetchRows({
    required String table,
    required String userId,
    String timestampColumn = 'updated_at',
    DateTime? since,
  }) async {
    final results = <Map<String, dynamic>>[];
    String? cursorUpdatedAt;
    String? cursorId;
    do {
      final uri = Uri.parse('$_requireBaseUrl/v1/sync/$table').replace(
        queryParameters: {
          'userId': userId,
          'timestampColumn': timestampColumn,
          'limit': '200',
          if (since != null) 'since': since.toUtc().toIso8601String(),
          if (cursorUpdatedAt != null) 'cursorUpdatedAt': cursorUpdatedAt,
          if (cursorId != null) 'cursorId': cursorId,
        },
      );
      final headers = await _headers();
      final response = await _guardRequest(
        () => _requireClient.get(uri, headers: headers),
      );
      final payload = _decodeJson(response);
      _ensureSuccess(response, payload);
      final rows = payload['rows'];
      if (rows is List) {
        results.addAll(
          rows.cast<Map>().map((row) => row.cast<String, dynamic>()),
        );
      }
      final nextCursor = payload['nextCursor'];
      if (payload['hasMore'] == true && nextCursor is Map) {
        cursorUpdatedAt = nextCursor['updatedAt'] as String?;
        cursorId = nextCursor['id'] as String?;
        if (cursorUpdatedAt == null || cursorId == null) {
          throw const RemoteRepositoryException(
            'Backend returned an invalid sync cursor.',
          );
        }
      } else {
        cursorUpdatedAt = null;
        cursorId = null;
      }
    } while (cursorUpdatedAt != null);
    return results;
  }

  Future<Map<String, String>> _headers({bool contentType = true}) async {
    final token = await _accessTokenLoader?.call();
    return {
      if (contentType) 'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decodeJson(http.Response response) {
    if (response.body.isEmpty) {
      return const {};
    }
    final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      return const {};
    }
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
    throw RemoteRepositoryException(
      message,
      statusCode: response.statusCode,
      code: payload['code'] as String?,
    );
  }

  Future<http.Response> _guardRequest(
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request().timeout(requestTimeout);
    } on TimeoutException {
      throw const RemoteRepositoryException(
        'Backend request timed out. Your local changes are still queued.',
        code: 'request_timeout',
      );
    } on http.ClientException {
      throw const RemoteRepositoryException(
        'Backend is unreachable. Your local changes are still queued.',
        code: 'network_unavailable',
      );
    }
  }

  Future<http.Response> _sendMultipart(http.MultipartRequest request) async {
    try {
      final streamed = await _requireClient
          .send(request)
          .timeout(requestTimeout);
      return await http.Response.fromStream(streamed).timeout(requestTimeout);
    } on TimeoutException {
      throw const RemoteRepositoryException(
        'Photo upload timed out. It will be retried.',
        code: 'request_timeout',
      );
    } on http.ClientException {
      throw const RemoteRepositoryException(
        'Backend is unreachable. The photo remains local.',
        code: 'network_unavailable',
      );
    }
  }
}

class RemoteRepositoryException implements Exception {
  const RemoteRepositoryException(this.message, {this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  bool get isConflict => statusCode == 409 || code == 'sync_conflict';

  @override
  String toString() => message;
}
