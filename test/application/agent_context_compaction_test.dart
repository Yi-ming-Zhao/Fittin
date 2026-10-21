import 'dart:convert';
import 'package:fittin_v2/src/application/agent_context_compaction.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'rolling compaction retires complete tool pairs and resumes its checkpoint',
    () async {
      final now = DateTime.utc(2026);
      final messages = <AgentMessage>[
        AgentMessage(
          id: 'goal',
          role: AgentMessageRole.user,
          createdAt: now,
          content:
              'Change the plan; avoid squats; retain committed operations.',
        ),
        for (var i = 0; i < 20; i++) ...[
          AgentMessage(
            id: 'assistant-$i',
            role: AgentMessageRole.assistant,
            createdAt: now,
            toolCalls: [
              AgentToolCall(
                id: 'tool-$i',
                name: 'get_plan',
                argumentsJson: '{}',
              ),
            ],
          ),
          AgentMessage(
            id: 'result-$i',
            role: AgentMessageRole.tool,
            toolCallId: 'tool-$i',
            createdAt: now,
            content: jsonEncode({
              'targetId': 'plan-$i',
              'data': List.filled(300, 'exercise ').join(),
            }),
          ),
        ],
      ];
      final conversation = AgentConversation(
        id: 'conversation',
        title: 'Plan',
        createdAt: now,
        updatedAt: now,
        messages: messages,
      );
      final checkpoints = <String>[];
      var calls = 0;
      Future<String> summarize(
        String previous,
        String source,
        int budget,
      ) async {
        calls++;
        return jsonEncode({
          'goal': 'Change plan',
          'constraints': ['avoid squats'],
          'unfinishedSteps': ['revise'],
          'decisions': [],
          'completedActions': [],
          'entityIds': ['plan-0'],
        });
      }

      final result = await AgentContextCompactor.prepare(
        conversation: conversation,
        contextTokens: 8192,
        checkpoint: '',
        summarize: summarize,
        onCheckpoint: (state) async =>
            checkpoints.add(state.checkpoint(conversation.id)),
      );
      expect(calls, greaterThan(1));
      expect(checkpoints, isNotEmpty);
      expect(result.summary, contains('avoid squats'));
      final toolCalls = result.messages
          .expand((m) => m.toolCalls)
          .map((call) => call.id)
          .toSet();
      final toolResults = result.messages
          .where((m) => m.role == AgentMessageRole.tool)
          .map((m) => m.toolCallId)
          .toSet();
      expect(toolCalls, toolResults);
      expect(conversation.messages, hasLength(41));
      final before = calls;
      final restored = await AgentContextCompactor.prepare(
        conversation: conversation,
        contextTokens: 8192,
        checkpoint: result.checkpoint(conversation.id),
        summarize: summarize,
        onCheckpoint: (_) async {},
      );
      expect(calls, before);
      expect(
        restored.messages.map((m) => m.id),
        result.messages.map((m) => m.id),
      );
      expect(restored.summary, result.summary);
    },
  );

  test(
    'oversized instructions are processed in full rather than silently cut off',
    () async {
      final now = DateTime.utc(2026);
      final source = 'BEGIN ${List.filled(20000, '深蹲').join()} END';
      final fragments = <String>[];
      final conversation = AgentConversation(
        id: 'long',
        title: 'Long',
        createdAt: now,
        updatedAt: now,
        messages: [
          AgentMessage(
            id: 'user',
            role: AgentMessageRole.user,
            createdAt: now,
            content: source,
          ),
        ],
      );
      final result = await AgentContextCompactor.prepare(
        conversation: conversation,
        contextTokens: 8192,
        checkpoint: '',
        summarize: (old, fragment, _) async {
          fragments.add(fragment);
          return '{"goal":"long task"}';
        },
        onCheckpoint: (_) async {},
      );
      expect(fragments.length, greaterThan(2));
      expect(fragments.join(), contains(source));
      expect(result.throughMessageId, 'user');
      expect(result.messages, isEmpty);
    },
  );
}
