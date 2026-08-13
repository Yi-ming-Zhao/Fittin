import 'package:fittin_v2/src/data/agent_local_repository.dart';
import 'package:fittin_v2/src/data/agent_local_repository_web.dart';
import 'package:fittin_v2/src/data/sync/sync_models.dart';
import 'package:fittin_v2/src/data/web_local_store.dart';
import 'package:fittin_v2/src/data/web_storage_models.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'package:fittin_v2/src/domain/models/body_metric.dart';

/// Commits a body-metric mutation, its sync row, and the Agent audit record in
/// one IndexedDB transaction.
class AgentAtomicMutationWriter {
  const AgentAtomicMutationWriter(this.repository);

  final AgentLocalRepository repository;

  bool get supportsBodyMetrics => repository is WebAgentLocalRepository;

  Future<void> writeBodyMetric({
    required BodyMetric? metric,
    required String metricId,
    required String? ownerUserId,
    required AgentActionRecord action,
    required bool delete,
  }) async {
    final local = repository;
    if (local is! WebAgentLocalRepository) {
      throw StateError('Atomic body metric storage is unavailable.');
    }
    final store = local.store;
    final existing = await store.getRecord(WebStoreNames.bodyMetrics, metricId);
    final now = DateTime.now();
    final resolvedOwner = existing?['ownerUserId'] as String? ?? ownerUserId;
    final syncStatus = delete
        ? SyncStatusKeys.pendingDelete
        : _syncStatus(resolvedOwner);
    final bodyDoc = <String, dynamic>{
      'metricId': metricId,
      'timestamp': serializeStoredDateTime(
        metric?.timestamp ?? parseStoredDateTime(existing?['timestamp']) ?? now,
      ),
      'ownerUserId': resolvedOwner,
      'weightKg': metric?.weightKg ?? existing?['weightKg'],
      'bodyFatPercent': metric?.bodyFatPercent ?? existing?['bodyFatPercent'],
      'waistCm': metric?.waistCm ?? existing?['waistCm'],
      'note': metric?.note ?? existing?['note'],
      'deletedAt': delete ? serializeStoredDateTime(now) : null,
      'lastSyncedAt': existing?['lastSyncedAt'],
      'version': (existing?['version'] as int? ?? 0) + 1,
      'syncStatusKey': syncStatus,
      'lastModifiedByDeviceId': existing?['lastModifiedByDeviceId'],
    };
    final queueKey = '${SyncEntityTypes.bodyMetric}:$metricId';
    final existingQueue = await store.getRecord(
      WebStoreNames.syncQueue,
      queueKey,
    );
    final mutations = <WebStoreMutation>[
      WebStoreMutation.put(WebStoreNames.bodyMetrics, metricId, bodyDoc),
      if (syncStatus != SyncStatusKeys.localOnly &&
          syncStatus != SyncStatusKeys.synced)
        WebStoreMutation.put(WebStoreNames.syncQueue, queueKey, {
          'queueKey': queueKey,
          'ownerUserId': resolvedOwner,
          'entityType': SyncEntityTypes.bodyMetric,
          'entityId': metricId,
          'operationType': delete
              ? SyncOperationTypes.delete
              : SyncOperationTypes.upsert,
          'createdAt':
              existingQueue?['createdAt'] ?? serializeStoredDateTime(now),
          'updatedAt': serializeStoredDateTime(now),
        }),
      WebStoreMutation.put(
        WebStoreNames.agentActions,
        action.id,
        agentActionDoc(action),
      ),
    ];
    await store.applyMutations(mutations);
  }

  static String _syncStatus(String? ownerUserId) => ownerUserId == null
      ? SyncStatusKeys.localOnly
      : SyncStatusKeys.pendingUpload;
}
