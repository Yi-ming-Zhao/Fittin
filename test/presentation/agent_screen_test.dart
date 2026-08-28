import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/agent_provider_settings_provider.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'package:fittin_v2/src/presentation/agent_ui_adapter.dart';
import 'package:fittin_v2/src/presentation/screens/agent_screen.dart';

import '../support/in_memory_database_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('failed empty and tool-only replies render only the error', (
    tester,
  ) async {
    final now = DateTime(2026, 8, 28);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(
            InMemoryDatabaseRepository(),
          ),
          agentProviderSettingsStoreProvider.overrideWithValue(
            _MemorySettingsStore(
              const AgentProviderConfig(
                baseUrl: 'https://example.com',
                model: 'test',
                hasApiKey: true,
                toolCallingVerified: true,
              ),
            ),
          ),
          agentUiStateProvider.overrideWithValue(
            AgentUiState(
              runState: AgentRunState(
                phase: AgentRunPhase.failed,
                errorMessage: 'Connection lost',
                conversation: AgentConversation(
                  id: 'failure',
                  title: 'Failure',
                  createdAt: now,
                  updatedAt: now,
                  messages: [
                    AgentMessage(
                      id: 'empty',
                      role: AgentMessageRole.assistant,
                      createdAt: now,
                      content: '   ',
                      isPartial: true,
                    ),
                    AgentMessage(
                      id: 'tool-only',
                      role: AgentMessageRole.assistant,
                      createdAt: now,
                      toolCalls: const [
                        AgentToolCall(
                          id: 'call',
                          name: 'get_plan',
                          argumentsJson: '{}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          agentUiBridgeProvider.overrideWithValue(_RecordingBridge()),
        ],
        child: const MaterialApp(home: AgentScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('agent-error-card')), findsOneWidget);
    expect(find.text('Connection lost'), findsOneWidget);
    expect(find.byKey(const ValueKey('agent-message-empty')), findsNothing);
    expect(find.byKey(const ValueKey('agent-message-tool-only')), findsNothing);
    expect(find.byKey(const ValueKey('agent-insight-card')), findsNothing);
  });

  testWidgets('shows bilingual configuration empty state', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final store = _MemorySettingsStore();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(
            InMemoryDatabaseRepository(),
          ),
          agentProviderSettingsStoreProvider.overrideWithValue(store),
        ],
        child: const MaterialApp(home: AgentScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('agent-configuration-empty-state')),
      findsOneWidget,
    );
    expect(find.text('Connect your model'), findsOneWidget);
    expect(find.byKey(const ValueKey('agent-composer')), findsNothing);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(AgentScreen)),
    );
    await container.read(appLocaleProvider.notifier).setLocale(AppLocale.zh);
    await tester.pumpAndSettle();

    expect(find.text('连接你的模型'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'renders conversation, tool, insight, proposal and action surfaces',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final bridge = _RecordingBridge();
      final now = DateTime(2026, 8, 13, 10, 30);
      final proposal = AgentMutationProposal(
        operationId: 'proposal-1',
        toolName: 'revise_plan',
        title: 'Add a deload week',
        summary: 'Reduce working volume before the next block.',
        argumentsJson: '{}',
        targetType: 'plan',
        targetId: 'plan-1',
        expectedDigest: 'digest',
        changes: const [
          AgentMutationChange(
            path: 'Week 5 / Squat',
            before: '4 sets @ 80%',
            after: '3 sets @ 65%',
          ),
        ],
        progressionEffect: 'Current week and completed workouts stay intact.',
        createdAt: now,
      );
      final conversation = AgentConversation(
        id: 'conversation-1',
        title: 'Deload review',
        createdAt: now,
        updatedAt: now,
        messages: [
          AgentMessage(
            id: 'message-1',
            role: AgentMessageRole.user,
            createdAt: now,
            content: 'Review my fatigue.',
          ),
          AgentMessage(
            id: 'message-2',
            role: AgentMessageRole.assistant,
            createdAt: now,
            content: 'Volume rose while estimated strength flattened.',
          ),
        ],
      );
      final state = AgentUiState(
        runState: AgentRunState(
          phase: AgentRunPhase.awaitingApproval,
          conversation: conversation,
          pendingProposal: proposal,
          activeToolName: 'analyze_training_load',
        ),
        conversations: [conversation],
        insights: const [
          AgentInsightCardData(
            title: 'Eight-week volume',
            value: '+18%',
            detail: 'Lower-body work rose faster than recovery markers.',
          ),
        ],
        actions: [
          AgentActionRecord(
            id: 'action-1',
            ownerUserId: 'owner',
            toolName: 'update_body_metric',
            title: 'Updated body weight',
            targetType: 'body_metric',
            targetId: 'metric-1',
            beforeJson: '{}',
            afterJson: '{}',
            afterDigest: 'after',
            createdAt: now,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseRepositoryProvider.overrideWithValue(
              InMemoryDatabaseRepository(),
            ),
            agentProviderSettingsStoreProvider.overrideWithValue(
              _MemorySettingsStore(
                const AgentProviderConfig(
                  baseUrl: 'https://example.com/v1',
                  model: 'example-model',
                  hasApiKey: true,
                  toolCallingVerified: true,
                ),
              ),
            ),
            agentUiStateProvider.overrideWithValue(state),
            agentUiBridgeProvider.overrideWithValue(bridge),
          ],
          child: const MaterialApp(home: AgentScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Review my fatigue.'), findsOneWidget);
      expect(find.byKey(const ValueKey('agent-tool-status')), findsOneWidget);
      expect(find.byKey(const ValueKey('agent-insight-card')), findsNothing);
      expect(
        find.byKey(const ValueKey('agent-mutation-proposal')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('agent-composer')), findsOneWidget);

      await tester.ensureVisible(
        find.byKey(const ValueKey('agent-confirm-proposal')),
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('agent-confirm-proposal')));
      await tester.pump();
      expect(bridge.confirmed, ['proposal-1']);

      await tester.ensureVisible(find.text('Undo'));
      await tester.pump();
      await tester.tap(find.text('Undo'));
      await tester.pump();
      expect(bridge.undone, ['action-1']);

      await tester.enterText(
        find.byKey(const ValueKey('agent-composer-field')),
        'Analyze my bench press',
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('agent-send')));
      await tester.pump();
      expect(bridge.prompts, ['Analyze my bench press']);
      expect(tester.takeException(), isNull);
    },
  );
}

class _MemorySettingsStore implements AgentProviderSettingsStore {
  _MemorySettingsStore([
    this.config = const AgentProviderConfig(baseUrl: '', model: ''),
  ]);

  AgentProviderConfig config;
  String? key;

  @override
  Future<void> clear() async {
    config = const AgentProviderConfig(baseUrl: '', model: '');
    key = null;
  }

  @override
  Future<AgentProviderConfig> load() async => config;

  @override
  Future<String?> loadApiKey() async => key;

  @override
  Future<AgentProviderConfig> save({
    required String baseUrl,
    required String model,
    String? apiKey,
    bool toolCallingVerified = false,
    int contextWindowTokens = 32768,
    AgentProviderCapabilityProfile? capabilities,
  }) async {
    if (apiKey?.isNotEmpty ?? false) key = apiKey;
    config = AgentProviderConfig(
      baseUrl: baseUrl,
      model: model,
      hasApiKey: key != null || config.hasApiKey,
      toolCallingVerified: toolCallingVerified,
    );
    return config;
  }
}

class _RecordingBridge implements AgentUiBridge {
  final prompts = <String>[];
  final confirmed = <String>[];
  final undone = <String>[];

  @override
  Future<void> confirmProposal(String operationId) async {
    confirmed.add(operationId);
  }

  @override
  Future<void> deleteConversation(String conversationId) async {}

  @override
  Future<void> newConversation() async {}

  @override
  Future<void> openConversation(String conversationId) async {}

  @override
  Future<void> rejectProposal(String operationId) async {}

  @override
  Future<void> retry() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> submit(String prompt) async => prompts.add(prompt);

  @override
  Future<void> undoAction(String actionId) async => undone.add(actionId);

  @override
  Future<void> loadMoreHistory() async {}
}
