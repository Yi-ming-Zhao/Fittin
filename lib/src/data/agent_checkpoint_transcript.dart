import '../domain/models/agent_models.dart';
import '../domain/models/agent_runtime.dart';
import 'agent_local_repository.dart';
import 'agent_business_transaction.dart';

/// Checkpoints reference local message pages instead of duplicating an entire
/// transcript at every state transition. The enclosing business transaction
/// commits pages, run state, approval state and diagnostics together.
class AgentCheckpointTranscript {
  static const pageSize = 50;
  String? _runId;
  String? _owner;
  List<AgentMessage> _committed = const [];

  Future<Map<String, dynamic>> write(
    AgentLocalRepository repository,
    AgentCheckpoint checkpoint, {
    required String? ownerUserId,
  }) async {
    final messages = checkpoint.conversation.messages;
    final runId = checkpoint.run.id;
    final cached = _runId == runId && _owner == ownerUserId
        ? _committed
        : const <AgentMessage>[];
    final pageCount = (messages.length + pageSize - 1) ~/ pageSize;
    final kind = agentCheckpointPageKind(runId);
    for (var page = 0; page < pageCount; page++) {
      final start = page * pageSize;
      final end = (start + pageSize).clamp(0, messages.length);
      var unchanged = (start + pageSize).clamp(0, cached.length) == end;
      for (var i = start; unchanged && i < end; i++) {
        unchanged = identical(cached[i], messages[i]);
      }
      if (unchanged) continue;
      await repository.saveDocument(kind, '$page', {
        'conversationId': checkpoint.conversation.id,
        'messages': [for (var i = start; i < end; i++) messages[i].toJson()],
      }, ownerUserId: ownerUserId);
    }
    // Shrinking is unusual (e.g. protocol repair), but must not leave stale
    // sensitive message pages reachable after the new checkpoint commits.
    final previous = await repository.readDocument(
      'checkpoint',
      runId,
      ownerUserId: ownerUserId,
    );
    final oldCount = previous?['transcriptPageCount'] as int? ?? 0;
    for (var page = pageCount; page < oldCount; page++) {
      await repository.deleteDocument(kind, '$page', ownerUserId: ownerUserId);
    }
    return {
      ...checkpoint.toJson(includeMessages: false),
      'transcriptFormat': 1,
      'transcriptPageCount': pageCount,
      'transcriptMessageCount': messages.length,
    };
  }

  /// Call only after the enclosing transaction succeeds. A failed transaction
  /// must never cause a subsequent retry to skip pages that were rolled back.
  void committed(AgentCheckpoint checkpoint, {required String? ownerUserId}) {
    _runId = checkpoint.run.id;
    _owner = ownerUserId;
    _committed = List.of(checkpoint.conversation.messages);
  }

  static Future<AgentCheckpoint> read(
    AgentLocalRepository repository,
    Map<String, dynamic> document, {
    required String? ownerUserId,
  }) async {
    final run = AgentRunRecord.fromJson((document['run'] as Map).cast());
    if (run.ownerUserId != ownerUserId) {
      throw const FormatException('Checkpoint ownership mismatch.');
    }
    return AgentBusinessTransaction(repository).run(() async {
      // Re-read the index under the same lock as its pages. A different Web
      // tab must not make us combine an old index with newly written pages.
      final current = await repository.readDocument(
        'checkpoint',
        run.id,
        ownerUserId: ownerUserId,
      );
      return _readPages(
        repository,
        current ?? document,
        ownerUserId: ownerUserId,
      );
    });
  }

  static Future<AgentCheckpoint> _readPages(
    AgentLocalRepository repository,
    Map<String, dynamic> document, {
    required String? ownerUserId,
  }) async {
    final checkpoint = AgentCheckpoint.fromJson(document);
    if (checkpoint.run.ownerUserId != ownerUserId) {
      throw const FormatException('Checkpoint ownership mismatch.');
    }
    if (document['transcriptFormat'] == null) return checkpoint;
    if (document['transcriptFormat'] != 1) {
      throw const FormatException('Unsupported checkpoint transcript.');
    }
    final count = document['transcriptMessageCount'];
    final pages = document['transcriptPageCount'];
    if (count is! int ||
        pages is! int ||
        count < 0 ||
        pages != (count + pageSize - 1) ~/ pageSize) {
      throw const FormatException('Invalid checkpoint transcript index.');
    }
    final messages = <AgentMessage>[];
    for (var page = 0; page < pages; page++) {
      final data = await repository.readDocument(
        agentCheckpointPageKind(checkpoint.run.id),
        '$page',
        ownerUserId: ownerUserId,
      );
      final rows = data?['messages'];
      final expected = (count - page * pageSize).clamp(0, pageSize);
      if (data?['conversationId'] != checkpoint.conversation.id ||
          rows is! List ||
          rows.length != expected) {
        throw const FormatException('Missing checkpoint transcript page.');
      }
      messages.addAll(
        rows.map((row) => AgentMessage.fromJson((row as Map).cast())),
      );
    }
    return AgentCheckpoint(
      run: checkpoint.run,
      conversation: checkpoint.conversation.copyWith(messages: messages),
      proposal: checkpoint.proposal,
      pendingToolCallId: checkpoint.pendingToolCallId,
      errorCode: checkpoint.errorCode,
      errorMessage: checkpoint.errorMessage,
      contextSummary: checkpoint.contextSummary,
      steering: checkpoint.steering,
    );
  }
}
