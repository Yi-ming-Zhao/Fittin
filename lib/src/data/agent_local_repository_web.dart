import 'package:fittin_v2/src/data/agent_local_repository.dart';
import 'package:fittin_v2/src/data/web_local_store.dart';
import 'package:fittin_v2/src/data/web_storage_models.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'agent_conversation_transcript.dart';

class WebAgentLocalRepository implements AgentLocalRepository {
  const WebAgentLocalRepository(this.store);

  final WebLocalStore store;

  String _storeFor(String kind) => switch (kind) {
    _ when agentIsTranscriptPage(kind) => WebStoreNames.agentCheckpoints,
    'run' || 'turn' => WebStoreNames.agentRuns,
    'checkpoint' ||
    'streamTail' ||
    'conversationTranscript' => WebStoreNames.agentCheckpoints,
    'diagnostic' => WebStoreNames.agentDiagnostics,
    _ => WebStoreNames.agentMemory,
  };

  @override
  Future<Map<String, dynamic>?> readDocument(
    String kind,
    String id, {
    String? ownerUserId,
  }) async {
    final row = await store.getRecord(
      _storeFor(kind),
      agentDocumentKey(kind, id, ownerUserId),
    );
    return row == null || row['ownerUserId'] != ownerUserId
        ? null
        : (row['payload'] as Map).cast();
  }

  @override
  Future<List<Map<String, dynamic>>> listDocuments(
    String kind, {
    String? ownerUserId,
    int offset = 0,
    int limit = 50,
  }) async {
    final rows =
        (await store.getAllRecords(_storeFor(kind)))
            .where((r) => r['ownerUserId'] == ownerUserId && r['kind'] == kind)
            .toList()
          ..sort((a, b) => '${b['updatedAt']}'.compareTo('${a['updatedAt']}'));
    return rows
        .skip(offset)
        .take(limit.clamp(1, 1000))
        .map((r) => (r['payload'] as Map).cast<String, dynamic>())
        .toList();
  }

  @override
  Future<void> saveDocument(
    String kind,
    String id,
    Map<String, dynamic> payload, {
    String? ownerUserId,
  }) async {
    final name = _storeFor(kind);
    await store.runInTransaction([name], () async {
      await store.putRecord(name, agentDocumentKey(kind, id, ownerUserId), {
        'ownerUserId': ownerUserId,
        'kind': kind,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
        'payload': {...payload, 'id': id},
      });
      if (agentIsTranscriptPage(kind)) return;
      final rows = await listDocuments(
        kind,
        ownerUserId: ownerUserId,
        limit: 1000,
      );
      for (final row in rows.skip(agentDocumentRetention(kind))) {
        await deleteDocument(
          kind,
          row['id'] as String,
          ownerUserId: ownerUserId,
        );
      }
    });
  }

  @override
  Future<void> deleteDocument(String kind, String id, {String? ownerUserId}) =>
      store.runInTransaction([_storeFor(kind)], () async {
        if (kind == 'checkpoint' || kind == 'conversationTranscript') {
          final checkpoint = await readDocument(
            kind,
            id,
            ownerUserId: ownerUserId,
          );
          final pages =
              checkpoint?[kind == 'checkpoint'
                      ? 'transcriptPageCount'
                      : 'pageCount']
                  as int? ??
              0;
          for (var page = 0; page < pages; page++) {
            await store.deleteRecord(
              _storeFor(kind),
              agentDocumentKey(
                kind == 'checkpoint'
                    ? agentCheckpointPageKind(id)
                    : agentConversationPageKind(id),
                '$page',
                ownerUserId,
              ),
            );
          }
        }
        await store.deleteRecord(
          _storeFor(kind),
          agentDocumentKey(kind, id, ownerUserId),
        );
      });

  @override
  Future<List<AgentConversation>> fetchConversations({
    String? ownerUserId,
    int offset = 0,
    int limit = 50,
  }) async {
    final docs = await store.getAllRecords(WebStoreNames.agentConversations);
    final result =
        docs
            .where((doc) => doc['ownerUserId'] == ownerUserId)
            .map(agentConversationFromDoc)
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return result.skip(offset).take(limit).toList();
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
    return AgentConversationTranscript.read(
      this,
      agentConversationFromDoc(doc),
      ownerUserId: ownerUserId,
    );
  }

  @override
  Future<void> saveConversation(
    AgentConversation conversation, {
    String? ownerUserId,
  }) async {
    return store.runInTransaction(
      [WebStoreNames.agentConversations, WebStoreNames.agentCheckpoints],
      () async {
        if (conversation.messages.isNotEmpty) {
          await deleteDocument(
            'conversationTranscript',
            conversation.id,
            ownerUserId: ownerUserId,
          );
        }
        await store.putRecord(
          WebStoreNames.agentConversations,
          conversation.id,
          agentConversationDoc(conversation, ownerUserId: ownerUserId),
        );
        final expired = await fetchConversations(
          ownerUserId: ownerUserId,
          offset: 100,
          limit: 1000000,
        );
        for (final old in expired) {
          await store.deleteRecord(WebStoreNames.agentConversations, old.id);
          await deleteDocument(
            'conversationTranscript',
            old.id,
            ownerUserId: ownerUserId,
          );
        }
      },
    );
  }

  @override
  Future<void> deleteConversation(
    String conversationId, {
    String? ownerUserId,
  }) async {
    await store.runInTransaction(
      [WebStoreNames.agentConversations, WebStoreNames.agentCheckpoints],
      () async {
        final existing = await store.getRecord(
          WebStoreNames.agentConversations,
          conversationId,
        );
        if (existing == null || existing['ownerUserId'] != ownerUserId) return;
        await store.deleteRecord(
          WebStoreNames.agentConversations,
          conversationId,
        );
        await deleteDocument(
          'conversationTranscript',
          conversationId,
          ownerUserId: ownerUserId,
        );
      },
    );
  }

  @override
  Future<List<AgentActionRecord>> fetchActions({
    String? ownerUserId,
    int offset = 0,
    int limit = 50,
  }) async {
    final docs = await store.getAllRecords(WebStoreNames.agentActions);
    final result =
        docs
            .where((doc) => doc['ownerUserId'] == ownerUserId)
            .map(agentActionFromDoc)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result.skip(offset).take(limit).toList();
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
  Future<void> saveAction(AgentActionRecord action) async {
    return store.runInTransaction([WebStoreNames.agentActions], () async {
      await store.putRecord(
        WebStoreNames.agentActions,
        action.id,
        agentActionDoc(action),
      );
      final old = await fetchActions(
        ownerUserId: action.ownerUserId,
        offset: AgentRunLimits.maxStoredActions,
        limit: 1000000,
      );
      for (final row in old) {
        await store.deleteRecord(WebStoreNames.agentActions, row.id);
      }
    });
  }
}
