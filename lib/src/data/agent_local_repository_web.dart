import 'package:fittin_v2/src/data/agent_local_repository.dart';
import 'package:fittin_v2/src/data/web_local_store.dart';
import 'package:fittin_v2/src/data/web_storage_models.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';

class WebAgentLocalRepository implements AgentLocalRepository {
  const WebAgentLocalRepository(this.store);

  final WebLocalStore store;

  @override
  Future<List<AgentConversation>> fetchConversations({
    String? ownerUserId,
  }) async {
    final docs = await store.getAllRecords(WebStoreNames.agentConversations);
    final result =
        docs
            .where((doc) => doc['ownerUserId'] == ownerUserId)
            .map(agentConversationFromDoc)
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return result;
  }

  @override
  Future<AgentConversation?> fetchConversation(
    String conversationId, {
    String? ownerUserId,
  }) async {
    final doc = await store.getRecord(
      WebStoreNames.agentConversations,
      conversationId,
    );
    if (doc == null || doc['ownerUserId'] != ownerUserId) return null;
    return agentConversationFromDoc(doc);
  }

  @override
  Future<void> saveConversation(
    AgentConversation conversation, {
    String? ownerUserId,
  }) {
    return store.putRecord(
      WebStoreNames.agentConversations,
      conversation.id,
      agentConversationDoc(conversation, ownerUserId: ownerUserId),
    );
  }

  @override
  Future<void> deleteConversation(
    String conversationId, {
    String? ownerUserId,
  }) async {
    final existing = await fetchConversation(
      conversationId,
      ownerUserId: ownerUserId,
    );
    if (existing == null) return;
    await store.deleteRecord(WebStoreNames.agentConversations, conversationId);
  }

  @override
  Future<List<AgentActionRecord>> fetchActions({String? ownerUserId}) async {
    final docs = await store.getAllRecords(WebStoreNames.agentActions);
    final result =
        docs
            .where((doc) => doc['ownerUserId'] == ownerUserId)
            .map(agentActionFromDoc)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result.take(AgentRunLimits.maxStoredActions).toList();
  }

  @override
  Future<AgentActionRecord?> fetchAction(
    String actionId, {
    String? ownerUserId,
  }) async {
    final doc = await store.getRecord(WebStoreNames.agentActions, actionId);
    if (doc == null || doc['ownerUserId'] != ownerUserId) return null;
    return agentActionFromDoc(doc);
  }

  @override
  Future<void> saveAction(AgentActionRecord action) {
    return store.putRecord(
      WebStoreNames.agentActions,
      action.id,
      agentActionDoc(action),
    );
  }
}
