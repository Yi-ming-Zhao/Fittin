import 'dart:convert';
import 'dart:async';

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
  Future<List<AgentConversation>> fetchConversations({
    String? ownerUserId,
  }) async {
    final rows = await isar.agentConversationCollections.where().findAll();
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
    await isar.writeTxn(() => isar.agentConversationCollections.put(row));
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
  Future<List<AgentActionRecord>> fetchActions({String? ownerUserId}) async {
    final rows = await isar.agentActionCollections.where().findAll();
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
    return result.take(AgentRunLimits.maxStoredActions).toList();
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
    if (Zone.current[agentTransactionZoneKey] == true) {
      await isar.agentActionCollections.put(row);
    } else {
      await isar.writeTxn(() => isar.agentActionCollections.put(row));
    }
  }
}
