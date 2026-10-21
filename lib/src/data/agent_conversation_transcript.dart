import '../domain/models/agent_models.dart';
import 'agent_business_transaction.dart';
import 'agent_local_repository.dart';
import 'package:uuid/uuid.dart';

/// Local-only, additive history paging. Legacy conversation payloads remain
/// readable; the first new save moves their messages into bounded documents.
class AgentConversationTranscript {
  static const pageSize = 50;
  String? _conversationId;
  String? _owner;
  List<AgentMessage> _committed = const [];

  Future<void> save(
    AgentLocalRepository repository,
    AgentConversation conversation, {
    required String? ownerUserId,
  }) async {
    final cached = _conversationId == conversation.id && _owner == ownerUserId
        ? _committed
        : const <AgentMessage>[];
    final messages = conversation.messages;
    final count = (messages.length + pageSize - 1) ~/ pageSize;
    final kind = agentConversationPageKind(conversation.id);
    final nextToken = const Uuid().v4();
    await AgentBusinessTransaction(repository).run(() async {
      final previous = await repository.readDocument(
        'conversationTranscript',
        conversation.id,
        ownerUserId: ownerUserId,
      );
      for (var page = 0; page < count; page++) {
        final start = page * pageSize;
        final end = (start + pageSize).clamp(0, messages.length);
        var unchanged = (start + pageSize).clamp(0, cached.length) == end;
        for (var i = start; unchanged && i < end; i++) {
          unchanged = identical(cached[i], messages[i]);
        }
        // Cache is only valid for the exact index previously committed by us.
        unchanged = unchanged && previous?['writeToken'] == _savedToken;
        if (unchanged) continue;
        await repository.saveDocument(kind, '$page', {
          'conversationId': conversation.id,
          'messages': [for (var i = start; i < end; i++) messages[i].toJson()],
        }, ownerUserId: ownerUserId);
      }
      final oldCount = previous?['pageCount'] as int? ?? 0;
      for (var page = count; page < oldCount; page++) {
        await repository.deleteDocument(
          kind,
          '$page',
          ownerUserId: ownerUserId,
        );
      }
      await repository.saveDocument('conversationTranscript', conversation.id, {
        'format': 1,
        'messageCount': messages.length,
        'pageCount': count,
        'writeToken': nextToken,
        'updatedAt': conversation.updatedAt.toUtc().toIso8601String(),
      }, ownerUserId: ownerUserId);
      await repository.saveConversation(
        conversation.copyWith(messages: const []),
        ownerUserId: ownerUserId,
      );
    });
    // Never advance the page cache on transaction failure.
    _conversationId = conversation.id;
    _owner = ownerUserId;
    _committed = List.of(messages);
    _savedToken = nextToken;
  }

  String? _savedToken;

  static Future<AgentConversation> read(
    AgentLocalRepository repository,
    AgentConversation header, {
    required String? ownerUserId,
    int offset = 0,
    int? limit,
  }) => AgentBusinessTransaction(repository).run(() async {
    final index = await repository.readDocument(
      'conversationTranscript',
      header.id,
      ownerUserId: ownerUserId,
    );
    if (index == null) {
      return limit == null && offset == 0
          ? header
          : header.copyWith(
              messages: header.messages
                  .skip(offset)
                  .take(limit ?? header.messages.length)
                  .toList(),
            );
    }
    final total = index['messageCount'];
    final count = index['pageCount'];
    if (index['format'] != 1 ||
        total is! int ||
        count is! int ||
        total < 0 ||
        count != (total + pageSize - 1) ~/ pageSize ||
        offset < 0 ||
        (limit != null && limit < 0)) {
      throw const FormatException('Invalid conversation transcript index.');
    }
    final start = offset.clamp(0, total);
    final end = limit == null ? total : (start + limit).clamp(0, total);
    final messages = <AgentMessage>[];
    for (var page = start ~/ pageSize; page * pageSize < end; page++) {
      final doc = await repository.readDocument(
        agentConversationPageKind(header.id),
        '$page',
        ownerUserId: ownerUserId,
      );
      final rows = doc?['messages'];
      if (doc?['conversationId'] != header.id ||
          rows is! List ||
          rows.length != (total - page * pageSize).clamp(0, pageSize)) {
        throw const FormatException('Missing conversation transcript page.');
      }
      for (var i = 0; i < rows.length; i++) {
        final position = page * pageSize + i;
        if (position >= start && position < end) {
          messages.add(AgentMessage.fromJson((rows[i] as Map).cast()));
        }
      }
    }
    return header.copyWith(messages: messages);
  });
}
