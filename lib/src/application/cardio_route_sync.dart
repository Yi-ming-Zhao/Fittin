import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/cardio_recording_store.dart';
import '../data/remote/supabase_remote_repository.dart';
import '../domain/models/cardio_recording.dart';
import 'agent_owner_scope.dart';
import 'cardio_recording_provider.dart';

abstract interface class CardioRouteRemote {
  Future<Map<String, dynamic>> list({String? after});
  Future<Map<String, dynamic>?> manifest(String id);
  Future<List<int>> chunk(String id, String hash);
  Future<void> uploadChunk(String id, String hash, String data);
  Future<Map<String, dynamic>> commit(String id, Map<String, dynamic> data);
  Future<void> delete(String id, int version);
}

class BackendCardioRouteRemote implements CardioRouteRemote {
  const BackendCardioRouteRemote(this.repository, this.owner);
  final SupabaseRemoteRepository repository;
  final String owner;
  @override
  Future<Map<String, dynamic>> list({String? after}) async {
    final response = await repository.privateRouteRequest(
      method: 'GET',
      id: '',
      suffix: '',
      expectedOwner: owner,
      after: after,
    );
    return (jsonDecode(response.body) as Map).cast();
  }

  @override
  Future<Map<String, dynamic>?> manifest(String id) async {
    final response = await repository.privateRouteRequest(
      method: 'GET',
      id: id,
      suffix: 'manifest',
      expectedOwner: owner,
    );
    return response.statusCode == 404
        ? null
        : (jsonDecode(response.body) as Map).cast();
  }

  @override
  Future<List<int>> chunk(String id, String hash) async {
    final response = await repository.privateRouteRequest(
      method: 'GET',
      id: id,
      suffix: 'chunks/$hash',
      expectedOwner: owner,
    );
    if (response.statusCode == 404) {
      throw const FormatException('Cloud route segment unavailable.');
    }
    return response.bodyBytes;
  }

  @override
  Future<void> uploadChunk(String id, String hash, String data) async {
    await repository.privateRouteRequest(
      method: 'PUT',
      id: id,
      suffix: 'chunks/$hash',
      expectedOwner: owner,
      body: data,
    );
  }

  @override
  Future<Map<String, dynamic>> commit(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await repository.privateRouteRequest(
      method: 'PUT',
      id: id,
      suffix: 'manifest',
      expectedOwner: owner,
      body: jsonEncode(data),
    );
    return (jsonDecode(response.body) as Map).cast();
  }

  @override
  Future<void> delete(String id, int version) async {
    await repository.privateRouteRequest(
      method: 'DELETE',
      id: id,
      suffix: 'manifest',
      expectedOwner: owner,
      version: version,
    );
  }
}

final cardioRouteSyncProvider = Provider<CardioRouteSync?>((ref) {
  final scope = ref.watch(agentOwnerScopeProvider);
  final owner = scope.ownerUserId;
  if (owner == null) return null;
  var alive = true;
  ref.onDispose(() => alive = false);
  return CardioRouteSync(
    local: ref.watch(cardioRecordingStoreProvider),
    remote: BackendCardioRouteRemote(
      ref.watch(supabaseRemoteRepositoryProvider),
      owner,
    ),
    owner: owner,
    checkOwner: () {
      if (!alive || ref.read(agentOwnerScopeProvider).epoch != scope.epoch) {
        throw StateError('Account changed during route transfer.');
      }
    },
  );
});

/// The caller must show separate upload/download/delete consent. Merely
/// constructing this service or opening a route never transmits coordinates.
class CardioRouteSync {
  const CardioRouteSync({
    required this.local,
    required this.remote,
    required this.owner,
    required this.checkOwner,
  });
  final CardioRecordingStore local;
  final CardioRouteRemote remote;
  final String owner;
  final void Function() checkOwner;

  Future<Map<String, dynamic>> list({String? after}) async {
    checkOwner();
    final result = await remote.list(after: after);
    checkOwner();
    return result;
  }

  Future<void> upload(
    String id, {
    required int expectedLocalRevision,
    required int expectedCloudVersion,
  }) async {
    checkOwner();
    final saved = await local.read(id, ownerUserId: owner);
    if (saved == null ||
        saved.revision != expectedLocalRevision ||
        saved.session.phase != CardioRecordingPhase.finished ||
        saved.chunkCount == 0) {
      throw const CardioRecordingConflict();
    }
    final hashes = <String>[];
    await for (final points in local.route(id, ownerUserId: owner)) {
      checkOwner();
      final data = jsonEncode({
        'points': points.map((p) => p.toJson()).toList(),
      });
      final hash = sha256.convert(utf8.encode(data)).toString();
      await remote.uploadChunk(id, hash, data);
      hashes.add(hash);
    }
    checkOwner();
    if ((await local.read(id, ownerUserId: owner))?.revision !=
        saved.revision) {
      throw const CardioRecordingConflict();
    }
    final session = saved.session.toJson()..remove('ownerUserId');
    await remote.commit(id, {
      'expectedVersion': expectedCloudVersion,
      'session': session,
      'chunks': hashes,
    });
    checkOwner();
  }

  Future<void> download(String id, {required int expectedCloudVersion}) async {
    checkOwner();
    final manifest = await remote.manifest(id);
    if (manifest == null ||
        manifest['deleted'] == true ||
        manifest['version'] != expectedCloudVersion) {
      throw const CardioRecordingConflict();
    }
    final session = CardioRecordingSession.fromJson({
      ...Map<String, dynamic>.from(manifest['session'] as Map),
      'ownerUserId': owner,
    });
    session.validate();
    if (session.id != id || session.phase != CardioRecordingPhase.finished) {
      throw const FormatException('Invalid cloud route identity.');
    }
    final hashes = List<String>.from(manifest['chunks'] as List);
    if (hashes.isEmpty || hashes.length > 256) {
      throw const FormatException('Invalid cloud route segments.');
    }
    final points = <RoutePoint>[];
    for (final hash in hashes) {
      checkOwner();
      if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(hash)) {
        throw const FormatException('Invalid segment digest.');
      }
      final bytes = await remote.chunk(id, hash);
      if (bytes.length > 256 * 1024 ||
          sha256.convert(bytes).toString() != hash) {
        throw const FormatException('Cloud route integrity check failed.');
      }
      final data = jsonDecode(utf8.decode(bytes)) as Map;
      final rows = data['points'] as List;
      if (rows.isEmpty || rows.length > 500) {
        throw const FormatException('Invalid route segment.');
      }
      for (final row in rows) {
        final point = RoutePoint.fromJson(
          Map<String, dynamic>.from(row as Map),
        );
        if (!point.isValid || point.segment < 0) {
          throw const FormatException('Invalid route position.');
        }
        points.add(point);
      }
    }
    if ((await remote.manifest(id))?['version'] != expectedCloudVersion) {
      throw const CardioRecordingConflict();
    }
    checkOwner();
    // Never overwrite another local recording or partially save a download.
    await local.documents.transaction(() async {
      checkOwner();
      if (await local.read(id, ownerUserId: owner) != null) {
        throw const CardioRecordingConflict();
      }
      await local.checkpoint(
        session,
        expectedRevision: 0,
        batchId: 'cloud:$expectedCloudVersion',
        points: points,
      );
    });
  }

  Future<void> delete(String id, {required int expectedCloudVersion}) async {
    checkOwner();
    await remote.delete(id, expectedCloudVersion);
    checkOwner();
  }
}
