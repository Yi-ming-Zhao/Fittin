import 'dart:convert';
import 'dart:async';
import 'models/agent_runtime_collection.dart';

import 'package:fittin_v2/src/data/agent_local_repository.dart';
import 'package:fittin_v2/src/data/models/agent_action_collection.dart';
import 'package:fittin_v2/src/data/models/agent_conversation_collection.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'package:fittin_v2/src/data/agent_transaction_context.dart';
import 'package:isar/isar.dart';

class IsarAgentLocalRepository implements AgentLocalRepository {
  const IsarAgentLocalRepository(this.isar);

  final Isar isar;

  @override
  Future<Map<String, dynamic>?> readDocument(
    String kind,
    String id, {
    String? ownerUserId,
  }) async {
    final row = await isar.agentRuntimeCollections.getByDocumentKey(
      agentDocumentKey(kind, id, ownerUserId),
    );
    return row == null || row.ownerUserId != ownerUserId
        ? null
        : (jsonDecode(row.payload) as Map).cast();
  }

  @override
  Future<List<Map<String, dynamic>>> listDocuments(
    String kind, {
    String? ownerUserId,
    int offset = 0,
    int limit = 50,
  }) async {
    final rows = await isar.agentRuntimeCollections
        .filter()
        .ownerUserIdEqualTo(ownerUserId)
        .kindEqualTo(kind)
        .sortByUpdatedAtDesc()
        .offset(offset)
        .limit(limit.clamp(1, 1000))
        .findAll();
    return rows
        .map((row) => (jsonDecode(row.payload) as Map).cast<String, dynamic>())
        .toList();
  }

  @override
  Future<void> saveDocument(
    String kind,
    String id,
    Map<String, dynamic> payload, {
    String? ownerUserId,
  }) async {
    Future<void> write() async {
      final key = agentDocumentKey(kind, id, ownerUserId);
      final existing = await isar.agentRuntimeCollections.getByDocumentKey(key);
      final row = AgentRuntimeCollection()
        ..id = existing?.id ?? Isar.autoIncrement
        ..documentKey = key
        ..ownerUserId = ownerUserId
        ..kind = kind
        ..documentId = id
        ..updatedAt = DateTime.now()
        ..payload = jsonEncode({...payload, 'id': id});
      await isar.agentRuntimeCollections.put(row);
      final expired = await isar.agentRuntimeCollections
          .filter()
          .ownerUserIdEqualTo(ownerUserId)
          .kindEqualTo(kind)
          .sortByUpdatedAtDesc()
          .offset(agentDocumentRetention(kind))
          .findAll();
      await isar.agentRuntimeCollections.deleteAll(
        expired.map((r) => r.id).toList(),
      );
    }

    if (Zone.current[agentTransactionZoneKey] == true) {
      await write();
    } else {
      await isar.writeTxn(write);
    }
  }

  @override
  Future<void> deleteDocument(
    String kind,
    String id, {
    String? ownerUserId,
  }) async {
    Future<void> remove() async {
      await isar.agentRuntimeCollections.deleteByDocumentKey(
        agentDocumentKey(kind, id, ownerUserId),
      );
    }

    if (Zone.current[agentTransactionZoneKey] == true) {
      await remove();
    } else {
      await isar.writeTxn(remove);
    }
  }

  @override
  Future<List<AgentConversation>> fetchConversations({
    String? ownerUserId,
    int offset = 0,
    int limit = 50,
  }) async {
    final rows = await isar.agentConversationCollections
        .filter()
        .ownerUserIdEqualTo(ownerUserId)
        .sortByUpdatedAtDesc()
        .offset(offset)
        .limit(limit)
        .findAll();
    final result =
        rows
            .where((row) => row.ownerUserId == ownerUserId)
            .map(
              (row) => AgentConversation.fromJson(
                jsonDecode(row.rawJsonPayload) as Map<String, dynamic>,
              ),
            )
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return result;
  }

  @override
  Future<AgentConversation?> fetchConversation(
    String conversationId, {
    String? ownerUserId,
  }) async {
    final row = await isar.agentConversationCollections.getByConversationId(
      conversationId,
    );
    if (row == null || row.ownerUserId != ownerUserId) return null;
    return AgentConversation.fromJson(
      jsonDecode(row.rawJsonPayload) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> saveConversation(
    AgentConversation conversation, {
    String? ownerUserId,
  }) async {
    final existing = await isar.agentConversationCollections
        .getByConversationId(conversation.id);
    final row = AgentConversationCollection()
      ..id = existing?.id ?? Isar.autoIncrement
      ..conversationId = conversation.id
      ..ownerUserId = ownerUserId
      ..title = conversation.title
      ..createdAt = conversation.createdAt
      ..updatedAt = conversation.updatedAt
      ..rawJsonPayload = jsonEncode(conversation.toJson());
    Future<void> write() async {
      await isar.agentConversationCollections.put(row);
      final old = await isar.agentConversationCollections
          .filter()
          .ownerUserIdEqualTo(ownerUserId)
          .sortByUpdatedAtDesc()
          .offset(100)
          .findAll();
      await isar.agentConversationCollections.deleteAll(
        old.map((r) => r.id).toList(),
      );
    }

    if (Zone.current[agentTransactionZoneKey] == true) {
      await write();
    } else {
      await isar.writeTxn(write);
    }
  }

  @override
  Future<void> deleteConversation(
    String conversationId, {
    String? ownerUserId,
  }) async {
    final row = await isar.agentConversationCollections.getByConversationId(
      conversationId,
    );
    if (row == null || row.ownerUserId != ownerUserId) return;
    await isar.writeTxn(() => isar.agentConversationCollections.delete(row.id));
  }

  @override
  Future<List<AgentActionRecord>> fetchActions({
    String? ownerUserId,
    int offset = 0,
    int limit = 50,
  }) async {
    final rows = await isar.agentActionCollections
        .filter()
        .ownerUserIdEqualTo(ownerUserId)
        .sortByCreatedAtDesc()
        .offset(offset)
        .limit(limit)
        .findAll();
    final result =
        rows
            .where((row) => row.ownerUserId == ownerUserId)
            .map(
              (row) => AgentActionRecord.fromJson(
                jsonDecode(row.rawJsonPayload) as Map<String, dynamic>,
              ),
            )
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  @override
  Future<AgentActionRecord?> fetchAction(
    String actionId, {
    String? ownerUserId,
  }) async {
    final row = await isar.agentActionCollections.getByActionId(actionId);
    if (row == null || row.ownerUserId != ownerUserId) return null;
    return AgentActionRecord.fromJson(
      jsonDecode(row.rawJsonPayload) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> saveAction(AgentActionRecord action) async {
    final existing = await isar.agentActionCollections.getByActionId(action.id);
    final row = AgentActionCollection()
      ..id = existing?.id ?? Isar.autoIncrement
      ..actionId = action.id
      ..ownerUserId = action.ownerUserId
      ..statusKey = action.status.name
      ..createdAt = action.createdAt
      ..undoneAt = action.undoneAt
      ..rawJsonPayload = jsonEncode(action.toJson());
    Future<void> write() async {
      await isar.agentActionCollections.put(row);
      final old = await isar.agentActionCollections
          .filter()
          .ownerUserIdEqualTo(action.ownerUserId)
          .sortByCreatedAtDesc()
          .offset(AgentRunLimits.maxStoredActions)
          .findAll();
      await isar.agentActionCollections.deleteAll(
        old.map((r) => r.id).toList(),
      );
    }

    if (Zone.current[agentTransactionZoneKey] == true) {
      await write();
    } else {
      await isar.writeTxn(write);
    }
  }
}
