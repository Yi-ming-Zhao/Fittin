export 'agent_local_repository_native.dart'
    if (dart.library.js_interop) 'agent_local_repository_web.dart';

import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'agent_conversation_transcript.dart';

final agentLocalRepositoryProvider = Provider<AgentLocalRepository>((ref) {
  return InMemoryAgentLocalRepository();
});

abstract interface class AgentLocalRepository {
  Future<Map<String, dynamic>?> readDocument(
    String kind,
    String id, {
    String? ownerUserId,
  });
  Future<List<Map<String, dynamic>>> listDocuments(
    String kind, {
    String? ownerUserId,
    int offset = 0,
    int limit = 50,
  });
  Future<void> saveDocument(
    String kind,
    String id,
    Map<String, dynamic> payload, {
    String? ownerUserId,
  });
  Future<void> deleteDocument(String kind, String id, {String? ownerUserId});
  Future<List<AgentConversation>> fetchConversations({
    String? ownerUserId,
    int offset = 0,
    int limit = 50,
  });

  Future<AgentConversation?> fetchConversation(
    String conversationId, {
    String? ownerUserId,
  });

  Future<void> saveConversation(
    AgentConversation conversation, {
    String? ownerUserId,
  });

  Future<void> deleteConversation(String conversationId, {String? ownerUserId});

  Future<List<AgentActionRecord>> fetchActions({
    String? ownerUserId,
    int offset = 0,
    int limit = 50,
  });

  Future<AgentActionRecord?> fetchAction(
    String actionId, {
    String? ownerUserId,
  });

  Future<void> saveAction(AgentActionRecord action);
}

class InMemoryAgentLocalRepository implements AgentLocalRepository {
  final Map<String, Map<String, dynamic>> _documents = {};
  @override
  Future<Map<String, dynamic>?> readDocument(
    String kind,
    String id, {
    String? ownerUserId,
  }) async => _documents[agentDocumentKey(kind, id, ownerUserId)];
  @override
  Future<List<Map<String, dynamic>>> listDocuments(
    String kind, {
    String? ownerUserId,
    int offset = 0,
    int limit = 50,
  }) async {
    final prefix = agentDocumentKey(kind, '', ownerUserId);
    final rows =
        _documents.entries
            .where((e) => e.key.startsWith(prefix))
            .map((e) => e.value)
            .toList()
          ..sort((a, b) => '${b['updatedAt']}'.compareTo('${a['updatedAt']}'));
    return rows.skip(offset).take(limit).toList();
  }

  @override
  Future<void> saveDocument(
    String kind,
    String id,
    Map<String, dynamic> payload, {
    String? ownerUserId,
  }) async {
    _documents[agentDocumentKey(kind, id, ownerUserId)] = {
      ...payload,
      'id': id,
    };
    if (agentIsTranscriptPage(kind)) return;
    final rows = await listDocuments(
      kind,
      ownerUserId: ownerUserId,
      limit: 10000,
    );
    for (final row in rows.skip(agentDocumentRetention(kind))) {
      await deleteDocument(kind, row['id'] as String, ownerUserId: ownerUserId);
    }
  }

  @override
  Future<void> deleteDocument(
    String kind,
    String id, {
    String? ownerUserId,
  }) async {
    if (kind == 'checkpoint' || kind == 'conversationTranscript') {
      final prefix = agentDocumentKey(
        kind == 'checkpoint'
            ? agentCheckpointPageKind(id)
            : agentConversationPageKind(id),
        '',
        ownerUserId,
      );
      _documents.removeWhere((key, _) => key.startsWith(prefix));
    }
    _documents.remove(agentDocumentKey(kind, id, ownerUserId));
  }

  final Map<String, ({String? owner, AgentConversation value})> _conversations =
      {};
  final Map<String, AgentActionRecord> _actions = {};

  @override
  Future<List<AgentConversation>> fetchConversations({
    String? ownerUserId,
    int offset = 0,
    int limit = 50,
  }) async {
    final values =
        _conversations.values
            .where((entry) => entry.owner == ownerUserId)
            .map((entry) => entry.value)
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return values.skip(offset).take(limit).toList();
  }

  @override
  Future<AgentConversation?> fetchConversation(
    String conversationId, {
    String? ownerUserId,
  }) async {
    final entry = _conversations[conversationId];
    if (entry == null || entry.owner != ownerUserId) return null;
    return AgentConversationTranscript.read(
      this,
      entry.value,
      ownerUserId: ownerUserId,
    );
  }

  @override
  Future<void> saveConversation(
    AgentConversation conversation, {
    String? ownerUserId,
  }) async {
    if (conversation.messages.isNotEmpty) {
      await deleteDocument(
        'conversationTranscript',
        conversation.id,
        ownerUserId: ownerUserId,
      );
    }
    _conversations[conversation.id] = (owner: ownerUserId, value: conversation);
    final old = await fetchConversations(
      ownerUserId: ownerUserId,
      offset: 100,
      limit: 1000000,
    );
    for (final row in old) {
      await deleteConversation(row.id, ownerUserId: ownerUserId);
    }
  }

  @override
  Future<void> deleteConversation(
    String conversationId, {
    String? ownerUserId,
  }) async {
    if (_conversations[conversationId]?.owner == ownerUserId) {
      _conversations.remove(conversationId);
      await deleteDocument(
        'conversationTranscript',
        conversationId,
        ownerUserId: ownerUserId,
      );
    }
  }

  @override
  Future<List<AgentActionRecord>> fetchActions({
    String? ownerUserId,
    int offset = 0,
    int limit = 50,
  }) async {
    final values =
        _actions.values
            .where((action) => action.ownerUserId == ownerUserId)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return values.skip(offset).take(limit).toList();
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
    final old = await fetchActions(
      ownerUserId: action.ownerUserId,
      offset: AgentRunLimits.maxStoredActions,
      limit: 1000000,
    );
    for (final row in old) {
      _actions.remove(row.id);
    }
  }
}

String agentDocumentKey(String kind, String id, String? owner) =>
    '${owner == null ? 'guest' : 'user:${Uri.encodeComponent(owner)}'}:$kind:$id';

String agentCheckpointPageKind(String runId) =>
    'checkpointPages:${Uri.encodeComponent(runId)}';

String agentConversationPageKind(String id) =>
    'conversationPages:${Uri.encodeComponent(id)}';
bool agentIsTranscriptPage(String kind) =>
    kind.startsWith('checkpointPages:') ||
    kind.startsWith('conversationPages:');

int agentDocumentRetention(String kind) => switch (kind) {
  'memory' => 50,
  'diagnostic' => 200,
  'turn' => 800,
  'preference' => 1,
  _ => 100,
};
