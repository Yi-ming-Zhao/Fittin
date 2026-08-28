import 'dart:convert';
import '../domain/models/agent_models.dart';
import 'agent_run_protocol.dart';

class AgentContextSnapshot {
  const AgentContextSnapshot({
    required this.goal,
    required this.instructions,
    required this.completedActions,
    required this.messages,
    required this.estimatedTokens,
    this.compacted = false,
  });
  final String goal;
  final List<String> instructions;
  final List<Map<String, dynamic>> completedActions;
  final List<AgentMessage> messages;
  final int estimatedTokens;
  final bool compacted;
  String get summary => jsonEncode({
    'goal': goal,
    'userInstructions': instructions,
    'completedActions': completedActions,
    'readPolicy':
        'Historical reads may be stale. Read current entities again before proposing changes.',
  });
}

abstract final class AgentContextManager {
  static int estimate(Object? value) =>
      (utf8.encode(jsonEncode(value)).length / 3).ceil();

  static AgentContextSnapshot build(
    List<AgentMessage> input, {
    int contextTokens = 32768,
    int fixedTokens = 2500,
  }) {
    final normalized = completeAgentToolHistory(input, keepPartialText: false);
    final users = normalized
        .where((m) => m.role == AgentMessageRole.user)
        .toList();
    final goal = users.isEmpty ? '' : users.first.content;
    final actions = <Map<String, dynamic>>[];
    for (final message in normalized.where(
      (m) => m.role == AgentMessageRole.tool,
    )) {
      try {
        final result = jsonDecode(message.content);
        if (result is Map &&
            [
              'committed',
              'rejected',
              'conflicted',
            ].contains(result['status'])) {
          actions.add({
            for (final key in [
              'status',
              'operationId',
              'targetId',
              'targetType',
              'afterDigest',
            ])
              if (result[key] != null) key: result[key],
          });
        }
      } catch (_) {
        /* Legacy tool text is not an instruction. */
      }
    }
    final budget =
        ((contextTokens.clamp(8192, 262144) - 4096 - fixedTokens) * .75)
            .floor();
    if (estimate(normalized.map((m) => m.toJson()).toList()) <= budget) {
      return AgentContextSnapshot(
        goal: goal,
        instructions: const [],
        completedActions: actions,
        messages: normalized,
        estimatedTokens:
            estimate(normalized.map((m) => m.toJson()).toList()) + fixedTokens,
      );
    }
    // Keep user requirements verbatim rather than inventing a lossy semantic summary.
    // If requirements alone exceed the budget, ask for a smaller task.
    final instructions = users.skip(1).map((m) => m.content).toSet().toList();
    final summaryTokens = estimate({
      'goal': goal,
      'instructions': instructions,
      'actions': actions,
    });
    if (summaryTokens > budget ~/ 2) {
      throw const FormatException(
        'The task instructions exceed the context budget. Start a focused conversation or increase the context limit.',
      );
    }
    final groups = <List<AgentMessage>>[];
    for (final message in normalized) {
      if (message.role != AgentMessageRole.tool || groups.isEmpty) {
        groups.add([]);
      }
      groups.last.add(message);
    }
    final kept = <List<AgentMessage>>[];
    var tokens = summaryTokens + fixedTokens;
    for (final group in groups.reversed) {
      final size = estimate(group.map((m) => m.toJson()).toList());
      if (tokens + size > budget + fixedTokens) break;
      kept.insert(0, group);
      tokens += size;
    }
    if (kept.isEmpty ||
        !kept.expand((g) => g).any((m) => m.role == AgentMessageRole.user)) {
      if (users.isNotEmpty) kept.insert(0, [users.last]);
    }
    if (estimate(kept.expand((g) => g).map((m) => m.toJson()).toList()) +
            summaryTokens >
        budget) {
      throw const FormatException(
        'The latest tool result is too large. Read a smaller page and retry.',
      );
    }
    return AgentContextSnapshot(
      goal: goal,
      instructions: instructions,
      completedActions: actions,
      messages: kept.expand((g) => g).toList(),
      estimatedTokens: tokens,
      compacted: true,
    );
  }
}
