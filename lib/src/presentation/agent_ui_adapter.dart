import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/agent_harness_controller.dart';
import '../domain/models/agent_models.dart';
import '../domain/models/agent_runtime.dart';

/// Presentation-ready metric emitted by the Agent orchestration layer.
///
/// The UI deliberately keeps this shape small: analytics code remains in the
/// application layer and only hands formatted, bounded results to the screen.
class AgentInsightCardData {
  const AgentInsightCardData({
    required this.title,
    required this.value,
    required this.detail,
  });

  final String title;
  final String value;
  final String detail;
}

class AgentUiState {
  const AgentUiState({
    this.runState = const AgentRunState(),
    this.conversations = const [],
    this.actions = const [],
    this.insights = const [],
    this.events = const [],
    this.hasMoreHistory = false,
  });

  final AgentRunState runState;
  final List<AgentConversation> conversations;
  final List<AgentActionRecord> actions;
  final List<AgentInsightCardData> insights;
  final List<AgentRunEvent> events;
  final bool hasMoreHistory;
}

/// Bridge point for the application Agent runner.
///
/// Network, tool, and persistence implementations live outside presentation.
/// Until the runner is wired, the default bridge is inert and the provider can
/// be overridden in tests or by the application composition root.
abstract interface class AgentUiBridge {
  Future<void> submit(String prompt);
  Future<void> stop();
  Future<void> retry();
  Future<void> openConversation(String conversationId);
  Future<void> newConversation();
  Future<void> deleteConversation(String conversationId);
  Future<void> confirmProposal(String operationId);
  Future<void> rejectProposal(String operationId);
  Future<void> undoAction(String actionId);
  Future<void> loadMoreHistory();
}

class HarnessAgentUiBridge implements AgentUiBridge {
  const HarnessAgentUiBridge(this._controller);

  final AgentHarnessController _controller;

  @override
  Future<void> confirmProposal(String operationId) =>
      _controller.confirmProposal(operationId);

  @override
  Future<void> deleteConversation(String conversationId) =>
      _controller.deleteConversation(conversationId);

  @override
  Future<void> newConversation() => _controller.newConversation();

  @override
  Future<void> openConversation(String conversationId) =>
      _controller.openConversation(conversationId);

  @override
  Future<void> rejectProposal(String operationId) =>
      _controller.rejectProposal(operationId);

  @override
  Future<void> retry() => _controller.retry();

  @override
  Future<void> stop() => _controller.stop();

  @override
  Future<void> submit(String prompt) => _controller.steer(prompt);

  @override
  Future<void> undoAction(String actionId) => _controller.undoAction(actionId);

  @override
  Future<void> loadMoreHistory() => _controller.loadMoreHistory();
}

final agentUiStateProvider = Provider<AgentUiState>((ref) {
  final harness = ref.watch(agentHarnessControllerProvider);
  return AgentUiState(
    runState: harness.runState,
    conversations: harness.conversations,
    actions: harness.actions,
    events: harness.events,
    hasMoreHistory: harness.hasMoreHistory,
    insights: [
      for (final insight in harness.insights)
        AgentInsightCardData(
          title: insight.title,
          value: insight.value,
          detail: insight.detail,
        ),
    ],
  );
});

final agentUiBridgeProvider = Provider<AgentUiBridge>((ref) {
  return HarnessAgentUiBridge(
    ref.watch(agentHarnessControllerProvider.notifier),
  );
});
