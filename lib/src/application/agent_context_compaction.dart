import 'dart:convert';
import '../domain/models/agent_models.dart';
import 'agent_context.dart';
import 'agent_run_protocol.dart';

typedef AgentSummaryWriter =
    Future<String> Function(String previous, String source, int tokenBudget);

class AgentCompactedContext {
  const AgentCompactedContext({
    required this.summary,
    required this.throughMessageId,
    required this.messages,
  });
  final String summary;
  final String? throughMessageId;
  final List<AgentMessage> messages;
  String checkpoint(String conversationId) => jsonEncode({
    'format': 'rolling-context-v1',
    'conversationId': conversationId,
    'throughMessageId': throughMessageId,
    'summary': summary,
  });
}

/// Summarization changes only model context, never the visible transcript or
/// business data. Complete assistant/tool groups are retired together.
class AgentContextCompactor {
  static Future<AgentCompactedContext> prepare({
    required AgentConversation conversation,
    required int contextTokens,
    required String checkpoint,
    required AgentSummaryWriter summarize,
    required Future<void> Function(AgentCompactedContext) onCheckpoint,
  }) async {
    var summary = '';
    String? through;
    try {
      final old = jsonDecode(checkpoint);
      if (old is Map &&
          old['format'] == 'rolling-context-v1' &&
          old['conversationId'] == conversation.id) {
        summary = old['summary'] as String;
        through = old['throughMessageId'] as String?;
      }
    } catch (_) {
      /* Old deterministic summaries are rebuilt from the transcript. */
    }
    var messages = completeAgentToolHistory(
      conversation.messages,
      keepPartialText: false,
    );
    if (through != null) {
      final index = messages.indexWhere((message) => message.id == through);
      if (index >= 0) {
        messages = messages.sublist(index + 1);
      } else {
        summary = '';
        through = null;
      }
    }
    final window = contextTokens < 8192 ? 8192 : contextTokens;
    final budget = ((window - 4096 - 2500) * .75).floor().clamp(1000, window);
    final summaryBudget = (budget ~/ 3).clamp(256, 6000);
    var estimated =
        AgentContextManager.estimate(messages.map((m) => m.toJson()).toList()) +
        AgentContextManager.estimate(summary);
    if (estimated <= budget) {
      return AgentCompactedContext(
        summary: summary,
        throughMessageId: through,
        messages: messages,
      );
    }
    final groups = <List<AgentMessage>>[];
    for (final message in messages) {
      if (message.role != AgentMessageRole.tool || groups.isEmpty) {
        groups.add([]);
      }
      groups.last.add(message);
    }
    var retired = 0;
    for (final group in groups) {
      if (estimated <= budget * .65) break;
      // Large legacy results are streamed through summaries in chunks. This is
      // not a task quota: every chunk is processed, even for very long histories.
      final encoded = jsonEncode(group.map((m) => m.toJson()).toList());
      final chunkCharacters = (budget - summaryBudget).clamp(512, 18000);
      final runes = encoded.runes.toList();
      for (var start = 0; start < runes.length; start += chunkCharacters) {
        final end = (start + chunkCharacters).clamp(0, runes.length);
        summary = await summarize(
          summary,
          String.fromCharCodes(runes.sublist(start, end)),
          summaryBudget,
        );
      }
      retired += group.length;
      through = group.last.id;
      final remaining = messages.sublist(retired);
      estimated =
          AgentContextManager.estimate(
            remaining.map((m) => m.toJson()).toList(),
          ) +
          AgentContextManager.estimate(summary);
      await onCheckpoint(
        AgentCompactedContext(
          summary: summary,
          throughMessageId: through,
          messages: remaining,
        ),
      );
    }
    return AgentCompactedContext(
      summary: summary,
      throughMessageId: through,
      messages: messages.sublist(retired),
    );
  }
}
