export 'agent_local_repository_native.dart'
    if (dart.library.js_interop) 'agent_local_repository_web.dart';

import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final agentLocalRepositoryProvider = Provider<AgentLocalRepository>((ref) {
  return InMemoryAgentLocalRepository();
});

abstract interface class AgentLocalRepository {
  Future<List<AgentConversation>> fetchConversations({String? ownerUserId});

  Future<AgentConversation?> fetchConversation(
    String conversationId, {
    String? ownerUserId,
  });

  Future<void> saveConversation(
    AgentConversation conversation, {
    String? ownerUserId,
  });

  Future<void> deleteConversation(String conversationId, {String? ownerUserId});

  Future<List<AgentActionRecord>> fetchActions({String? ownerUserId});

  Future<AgentActionRecord?> fetchAction(
    String actionId, {
    String? ownerUserId,
  });

  Future<void> saveAction(AgentActionRecord action);
}

class InMemoryAgentLocalRepository implements AgentLocalRepository {
  final Map<String, ({String? owner, AgentConversation value})> _conversations =
      {};
  final Map<String, AgentActionRecord> _actions = {};

  @override
  Future<List<AgentConversation>> fetchConversations({
    String? ownerUserId,
  }) async {
    final values =
        _conversations.values
            .where((entry) => entry.owner == ownerUserId)
            .map((entry) => entry.value)
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return values;
  }

  @override
  Future<AgentConversation?> fetchConversation(
    String conversationId, {
    String? ownerUserId,
  }) async {
    final entry = _conversations[conversationId];
    return entry?.owner == ownerUserId ? entry?.value : null;
  }

  @override
  Future<void> saveConversation(
    AgentConversation conversation, {
    String? ownerUserId,
  }) async {
    _conversations[conversation.id] = (owner: ownerUserId, value: conversation);
  }

  @override
  Future<void> deleteConversation(
    String conversationId, {
    String? ownerUserId,
  }) async {
    if (_conversations[conversationId]?.owner == ownerUserId) {
      _conversations.remove(conversationId);
    }
  }

  @override
  Future<List<AgentActionRecord>> fetchActions({String? ownerUserId}) async {
    final values =
        _actions.values
            .where((action) => action.ownerUserId == ownerUserId)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return values;
  }

  @override
  Future<AgentActionRecord?> fetchAction(
    String actionId, {
    String? ownerUserId,
  }) async {
    final action = _actions[actionId];
    return action?.ownerUserId == ownerUserId ? action : null;
  }

  @override
  Future<void> saveAction(AgentActionRecord action) async {
    _actions[action.id] = action;
  }
}
