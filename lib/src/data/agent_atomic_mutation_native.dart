import 'dart:convert';
import 'dart:async';

import 'package:fittin_v2/src/data/agent_local_repository.dart';
import 'package:fittin_v2/src/data/models/agent_action_collection.dart';
import 'package:fittin_v2/src/data/models/body_metric_collection.dart';
import 'package:fittin_v2/src/data/models/sync_queue_collection.dart';
import 'package:fittin_v2/src/data/sync/sync_models.dart';
import 'package:fittin_v2/src/data/agent_transaction_context.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'package:fittin_v2/src/domain/models/body_metric.dart';
import 'package:isar/isar.dart';

/// Commits a body-metric mutation, its sync row, and the Agent audit record in
/// one Isar transaction. More complex mutation groups retain compensation and
/// digest/idempotency guards in the coordinator.
class AgentAtomicMutationWriter {
  const AgentAtomicMutationWriter(this.repository);

  final AgentLocalRepository repository;

  bool get supportsBodyMetrics => repository is IsarAgentLocalRepository;

  Future<void> writeBodyMetric({
    required BodyMetric? metric,
    required String metricId,
    required String? ownerUserId,
    required AgentActionRecord action,
    required bool delete,
  }) async {
    final local = repository;
    if (local is! IsarAgentLocalRepository) {
      throw StateError('Atomic body metric storage is unavailable.');
    }
    final isar = local.isar;
    final existing = await isar.bodyMetricCollections
        .filter()
        .metricIdEqualTo(metricId)
        .findFirst();
    final now = DateTime.now();
    final bodyRow = BodyMetricCollection()
      ..id = existing?.id ?? Isar.autoIncrement
      ..metricId = metricId
      ..timestamp = metric?.timestamp ?? existing?.timestamp ?? now
      ..ownerUserId = existing?.ownerUserId ?? ownerUserId
      ..weightKg = delete ? existing?.weightKg : metric?.weightKg
      ..bodyFatPercent = delete
          ? existing?.bodyFatPercent
          : metric?.bodyFatPercent
      ..waistCm = delete ? existing?.waistCm : metric?.waistCm
      ..note = delete ? existing?.note : metric?.note
      ..deletedAt = delete ? now : null
      ..lastSyncedAt = existing?.lastSyncedAt
      ..version = (existing?.version ?? 0) + 1
      ..syncStatusKey = delete
          ? SyncStatusKeys.pendingDelete
          : _syncStatus(ownerUserId)
      ..lastModifiedByDeviceId = existing?.lastModifiedByDeviceId;
    final queueKey = '${SyncEntityTypes.bodyMetric}:$metricId';
    final existingQueue = await isar.syncQueueCollections.getByQueueKey(
      queueKey,
    );
    final queue = SyncQueueCollection()
      ..id = existingQueue?.id ?? Isar.autoIncrement
      ..queueKey = queueKey
      ..ownerUserId = bodyRow.ownerUserId
      ..entityType = SyncEntityTypes.bodyMetric
      ..entityId = metricId
      ..operationType = delete
          ? SyncOperationTypes.delete
          : SyncOperationTypes.upsert
      ..createdAt = existingQueue?.createdAt ?? now
      ..updatedAt = now;
    final existingAction = await isar.agentActionCollections.getByActionId(
      action.id,
    );
    final actionRow = AgentActionCollection()
      ..id = existingAction?.id ?? Isar.autoIncrement
      ..actionId = action.id
      ..ownerUserId = action.ownerUserId
      ..statusKey = action.status.name
      ..createdAt = action.createdAt
      ..undoneAt = action.undoneAt
      ..rawJsonPayload = jsonEncode(action.toJson());
    Future<void> writeRows() async {
      await isar.bodyMetricCollections.put(bodyRow);
      if (bodyRow.syncStatusKey != SyncStatusKeys.localOnly &&
          bodyRow.syncStatusKey != SyncStatusKeys.synced) {
        await isar.syncQueueCollections.put(queue);
      }
      await isar.agentActionCollections.put(actionRow);
    }

    if (Zone.current[agentTransactionZoneKey] == true) {
      await writeRows();
    } else {
      await isar.writeTxn(writeRows);
    }
  }

  static String _syncStatus(String? ownerUserId) => ownerUserId == null
      ? SyncStatusKeys.localOnly
      : SyncStatusKeys.pendingUpload;
}
