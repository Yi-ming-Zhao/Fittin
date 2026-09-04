import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/agent_context.dart';
import 'package:fittin_v2/src/application/agent_memory.dart';
import 'package:fittin_v2/src/application/agent_tool_input.dart';
import 'package:fittin_v2/src/data/agent_local_repository.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'package:fittin_v2/src/domain/models/agent_runtime.dart';

void main() {
  test(
    'compaction preserves the original goal, decisions and complete tool pairs',
    () {
      final now = DateTime.now();
      final messages = [
        AgentMessage(
          id: 'goal',
          role: AgentMessageRole.user,
          createdAt: now,
          content: 'Train three times a week; avoid squats',
        ),
      ];
      for (var i = 0; i < 24; i++) {
        messages.add(
          AgentMessage(
            id: 'a$i',
            role: AgentMessageRole.assistant,
            createdAt: now,
            toolCalls: [
              AgentToolCall(id: 't$i', name: 'get_plan', argumentsJson: '{}'),
            ],
          ),
        );
        messages.add(
          AgentMessage(
            id: 'r$i',
            role: AgentMessageRole.tool,
            createdAt: now,
            toolCallId: 't$i',
            content: i == 0
                ? jsonEncode({
                    'status': 'committed',
                    'targetId': 'plan-stable',
                    'operationId': 'op',
                  })
                : List.filled(2000, '数').join(),
          ),
        );
      }
      final snapshot = AgentContextManager.build(messages);
      expect(snapshot.compacted, true);
      expect(snapshot.summary, contains('avoid squats'));
      expect(snapshot.summary, contains('plan-stable'));
      final calls = snapshot.messages
          .expand((m) => m.toolCalls)
          .map((c) => c.id)
          .toSet();
      final results = snapshot.messages
          .where((m) => m.role == AgentMessageRole.tool)
          .map((m) => m.toolCallId)
          .toSet();
      expect(results, calls);
      expect(snapshot.estimatedTokens, lessThan(32768 - 4096));
    },
  );
  test(
    'small configured windows keep output space and reject oversized instructions',
    () {
      final snapshot = AgentContextManager.build([
        AgentMessage(
          id: 'q',
          role: AgentMessageRole.user,
          createdAt: DateTime.now(),
          content: 'Analyze 7 days',
        ),
      ], contextTokens: 8192);
      expect(snapshot.messages, hasLength(1));
      expect(
        () => AgentContextManager.build([
          AgentMessage(
            id: 'q',
            role: AgentMessageRole.user,
            createdAt: DateTime.now(),
            content: List.filled(40000, 'x').join(),
          ),
        ], contextTokens: 8192),
        throwsFormatException,
      );
    },
  );
  test(
    'approval result stays bounded while retaining the complete local diff',
    () {
      final changes = List.generate(
        500,
        (index) => AgentMutationChange(
          path:
              'plan / workouts ${index + 1} / exercises 1 / sets 1 / targetReps',
          before: 'Not set',
          after: '12',
        ),
      );
      final decision = AgentApprovalDecision(
        operationId: 'large-plan',
        outcome: AgentApprovalOutcome.committed,
        action: AgentActionRecord(
          id: 'large-plan',
          ownerUserId: 'test-owner',
          toolName: 'propose_create_plan',
          title: 'Create plan',
          targetType: 'plan',
          targetId: 'home-three-day',
          beforeJson: 'null',
          afterJson: '{}',
          afterDigest: 'digest',
          createdAt: DateTime(2026, 9, 6),
        ),
        changes: changes,
      );
      final modelResult = decision.toModelJson();

      expect(changes, hasLength(500));
      expect(modelResult['changeCount'], 500);
      expect(modelResult['actualChanges'], hasLength(12));
      expect(modelResult['changesTruncated'], true);
      expect(utf8.encode(jsonEncode(modelResult)).length, lessThan(6000));
    },
  );
  test(
    'memory only captures allowed explicit preferences, never secrets or health data',
    () {
      expect(
        AgentPreferenceExtractor.extract(
          '我每周训练3天。体重80kg，医生诊断高血压。',
          'c',
        ).single.value,
        '我每周训练3天',
      );
      expect(
        AgentPreferenceExtractor.extract('体重80kg，腰围90，可能有糖尿病', 'c'),
        isEmpty,
      );
      expect(
        AgentPreferenceExtractor.extract('api_key=sk-secret 我每周训练3天', 'c'),
        isEmpty,
      );
      expect(AgentPreferenceExtractor.isAllowed('health', 'diabetes'), false);
      expect(AgentPreferenceExtractor.isAllowed('time', '我每次只有900分钟'), false);
      for (final text in [
        '朋友说我每周训练3天',
        '“我每周训练3天”只是例子',
        '不是我每周训练3天',
        '如果我每周训练3天',
        '我每周训练3天？',
        '我每周训练3天不是事实',
      ]) {
        expect(
          AgentPreferenceExtractor.extract(text, 'c'),
          isEmpty,
          reason: text,
        );
      }
    },
  );
  test(
    'memory deduplicates, edits, deletes, disables and isolates owners',
    () async {
      final repo = InMemoryAgentLocalRepository();
      final a = AgentMemoryController(repo, 'a');
      final b = AgentMemoryController(repo, 'b');
      addTearDown(a.dispose);
      addTearDown(b.dispose);
      await a.capture('我每周训练3天', 'c1');
      await a.capture('我每周训练4天', 'c2');
      expect(a.state.items, hasLength(1));
      await a.edit(a.state.items.single, '我每周训练5天');
      expect(a.state.items.single.value, contains('5'));
      await b.reload();
      expect(b.state.items, isEmpty);
      await a.setEnabled(false);
      await a.capture('我只有哑铃', 'c3');
      expect(a.state.items, hasLength(1));
      await a.clear();
      expect(a.state.items, isEmpty);
    },
  );
  test(
    'runtime stores prune diagnostics and retain owner boundaries',
    () async {
      final repo = InMemoryAgentLocalRepository();
      for (var i = 0; i < 215; i++) {
        await repo.saveDocument('diagnostic', '$i', {
          'updatedAt': DateTime(
            2026,
            1,
            1,
          ).add(Duration(seconds: i)).toIso8601String(),
        }, ownerUserId: 'a');
      }
      expect(
        await repo.listDocuments('diagnostic', ownerUserId: 'a', limit: 1000),
        hasLength(200),
      );
      expect(await repo.listDocuments('diagnostic', ownerUserId: 'b'), isEmpty);
      expect(
        await repo.listDocuments(
          'diagnostic',
          ownerUserId: 'a',
          offset: 190,
          limit: 20,
        ),
        hasLength(10),
      );
    },
  );
  test('local schema rejects internal fields even inside free-form values', () {
    for (final field in [
      'ownerUserId',
      'version',
      'preConclusionSnapshot',
      'postConclusionSnapshot',
      'syncStatusKey',
      'deletedAt',
    ]) {
      expect(
        () => AgentToolInput.validate(
          {
            'edits': [
              {
                'value': {field: 1},
              },
            ],
          },
          {'type': 'object'},
        ),
        throwsFormatException,
      );
    }
  });
}
