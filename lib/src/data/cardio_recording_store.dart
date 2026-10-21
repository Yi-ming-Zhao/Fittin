import 'dart:convert';

import '../domain/models/cardio_recording.dart';

/// Deliberately separate from synced user content and Agent document stores.
abstract interface class CardioLocalDocuments {
  Future<T> transaction<T>(Future<T> Function() action);
  Future<Map<String, dynamic>?> read(String key);
  Future<void> put(String key, Map<String, dynamic> value);
  Future<void> delete(String key);
  Future<List<Map<String, dynamic>>> list(String prefix);
}

class StoredCardioSession {
  const StoredCardioSession(this.session, this.revision, this.chunkCount);
  final CardioRecordingSession session;
  final int revision, chunkCount;
}

class CardioRecordingConflict implements Exception {
  const CardioRecordingConflict();
}

class CardioRecordingStore {
  const CardioRecordingStore(this.documents);
  final CardioLocalDocuments documents;

  String _owner(String? owner) =>
      base64Url.encode(utf8.encode(jsonEncode(owner)));
  String _sessionKey(String? owner, String id) =>
      'session/${_owner(owner)}/${Uri.encodeComponent(id)}';
  String _chunkKey(String? owner, String id, int chunk) =>
      'route/${_owner(owner)}/${Uri.encodeComponent(id)}/$chunk';

  Future<StoredCardioSession?> read(
    String id, {
    required String? ownerUserId,
  }) async {
    final doc = await documents.read(_sessionKey(ownerUserId, id));
    if (doc == null) return null;
    final session = CardioRecordingSession.fromJson(
      Map<String, dynamic>.from(doc['session'] as Map),
    );
    if (session.ownerUserId != ownerUserId || session.id != id) {
      throw const FormatException('Invalid recording ownership.');
    }
    session.validate();
    return StoredCardioSession(
      session,
      doc['revision'] as int,
      doc['chunks'] as int,
    );
  }

  /// Revision zero creates a session. A repeated batch ID is idempotent, while
  /// a different stale writer is rejected inside the same storage transaction.
  Future<StoredCardioSession> checkpoint(
    CardioRecordingSession session, {
    required int expectedRevision,
    required String batchId,
    List<RoutePoint> points = const [],
  }) {
    session.validate();
    if (batchId.isEmpty ||
        points.any((point) => !point.isValid || point.segment < 0)) {
      throw const FormatException('Invalid recording batch.');
    }
    // Detach before entering an asynchronous transaction: timer callbacks must
    // not mutate the snapshot while it is waiting for the database write lock.
    final snapshot =
        jsonDecode(jsonEncode(session.toJson())) as Map<String, dynamic>;
    final route = points.map((point) => point.toJson()).toList();
    return documents.transaction(() async {
      final key = _sessionKey(session.ownerUserId, session.id);
      final old = await documents.read(key);
      if (old?['lastBatchId'] == batchId) {
        return (await read(session.id, ownerUserId: session.ownerUserId))!;
      }
      if ((old?['revision'] ?? 0) != expectedRevision) {
        throw const CardioRecordingConflict();
      }
      if (old == null && session.phase != CardioRecordingPhase.finished) {
        final others = await list(ownerUserId: session.ownerUserId);
        if (others.any(
          (entry) => entry.session.phase != CardioRecordingPhase.finished,
        )) {
          throw const CardioRecordingConflict();
        }
      }
      var chunks = old?['chunks'] as int? ?? 0;
      // A delayed write may accumulate more than one chunk. Keep the complete
      // buffered batch atomic, but never create an oversized route document.
      for (var offset = 0; offset < route.length; offset += 500) {
        await documents.put(
          _chunkKey(session.ownerUserId, session.id, chunks),
          {
            'points': route.sublist(
              offset,
              (offset + 500).clamp(0, route.length),
            ),
          },
        );
        chunks++;
      }
      await documents.put(key, {
        'session': snapshot,
        'revision': expectedRevision + 1,
        'chunks': chunks,
        'lastBatchId': batchId,
      });
      return StoredCardioSession(
        CardioRecordingSession.fromJson(snapshot),
        expectedRevision + 1,
        chunks,
      );
    });
  }

  Future<List<StoredCardioSession>> list({required String? ownerUserId}) async {
    final docs = await documents.list('session/${_owner(ownerUserId)}/');
    final result = <StoredCardioSession>[];
    for (final doc in docs) {
      final session = CardioRecordingSession.fromJson(
        Map<String, dynamic>.from(doc['session'] as Map),
      );
      if (session.ownerUserId != ownerUserId) continue;
      session.validate();
      result.add(
        StoredCardioSession(
          session,
          doc['revision'] as int,
          doc['chunks'] as int,
        ),
      );
    }
    result.sort((a, b) => b.session.startedAt.compareTo(a.session.startedAt));
    return result;
  }

  Stream<List<RoutePoint>> route(
    String id, {
    required String? ownerUserId,
    int fromChunk = 0,
  }) async* {
    final stored = await read(id, ownerUserId: ownerUserId);
    if (stored == null) return;
    for (
      var i = fromChunk.clamp(0, stored.chunkCount);
      i < stored.chunkCount;
      i++
    ) {
      final doc = await documents.read(_chunkKey(ownerUserId, id, i));
      if (doc == null) {
        throw const FormatException('Missing local route segment.');
      }
      yield (doc['points'] as List)
          .map(
            (point) =>
                RoutePoint.fromJson(Map<String, dynamic>.from(point as Map)),
          )
          .toList();
    }
  }

  Future<void> delete(
    String id, {
    required String? ownerUserId,
    required int expectedRevision,
  }) => documents.transaction(() async {
    final stored = await read(id, ownerUserId: ownerUserId);
    if (stored == null) return;
    if (stored.revision != expectedRevision) {
      throw const CardioRecordingConflict();
    }
    for (var i = 0; i < stored.chunkCount; i++) {
      await documents.delete(_chunkKey(ownerUserId, id, i));
    }
    await documents.delete(_sessionKey(ownerUserId, id));
  });
}
