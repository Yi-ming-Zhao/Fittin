import 'dart:convert';

import 'package:fittin_v2/src/application/agent_chat_protocol.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/agent_mutation_coordinator.dart';
import 'package:fittin_v2/src/application/agent_provider_settings_provider.dart';
import 'package:fittin_v2/src/application/agent_tools.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/data/agent_local_repository.dart';
import 'package:fittin_v2/src/data/remote/agent_model_transport.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final agentHarnessControllerProvider =
    StateNotifierProvider<AgentHarnessController, AgentHarnessState>((ref) {
      return AgentHarnessController(
        ref,
        ownerUserId: ref.watch(currentUserIdProvider),
      );
    });

class AgentStructuredInsight {
  const AgentStructuredInsight({
    required this.title,
    required this.value,
    required this.detail,
  });

  final String title;
  final String value;
  final String detail;
}

class AgentHarnessState {
  const AgentHarnessState({
    this.runState = const AgentRunState(),
    this.conversations = const [],
    this.actions = const [],
    this.insights = const [],
  });

  final AgentRunState runState;
  final List<AgentConversation> conversations;
  final List<AgentActionRecord> actions;
  final List<AgentStructuredInsight> insights;

  AgentHarnessState copyWith({
    AgentRunState? runState,
    List<AgentConversation>? conversations,
    List<AgentActionRecord>? actions,
    List<AgentStructuredInsight>? insights,
  }) => AgentHarnessState(
    runState: runState ?? this.runState,
    conversations: conversations ?? this.conversations,
    actions: actions ?? this.actions,
    insights: insights ?? this.insights,
  );
}

class AgentHarnessController extends StateNotifier<AgentHarnessState> {
  AgentHarnessController(this._ref, {required String? ownerUserId})
    : _ownerUserId = ownerUserId,
      super(const AgentHarnessState()) {
    _initialLoad = _loadLocalState();
  }

  final Ref _ref;
  final String? _ownerUserId;
  late final Future<void> _initialLoad;
  AgentCancellationToken? _cancellationToken;
  String? _lastSubmittedPrompt;
  bool _submissionInFlight = false;
  bool _decisionInFlight = false;
  bool get _isChinese => _ref.read(appLocaleProvider) == AppLocale.zh;

  @override
  void dispose() {
    _cancellationToken?.cancel();
    super.dispose();
  }

  Future<void> _loadLocalState() async {
    final repository = _ref.read(agentLocalRepositoryProvider);
    final conversations = await repository.fetchConversations(
      ownerUserId: _ownerUserId,
    );
    final actions = await repository.fetchActions(ownerUserId: _ownerUserId);
    if (!mounted) return;
    state = state.copyWith(
      conversations: conversations,
      actions: actions,
      runState: state.runState.copyWith(
        conversation: conversations.firstOrNull,
      ),
    );
  }

  Future<void> submit(String rawPrompt) async {
    final prompt = rawPrompt.trim();
    if (prompt.isEmpty || state.runState.isBusy || _submissionInFlight) return;
    _submissionInFlight = true;
    try {
      await _initialLoad;
      if (state.runState.isBusy) return;
      if (state.runState.pendingProposal != null) {
        _fail(
          _isChinese
              ? '请先确认或拒绝待处理的修改，再开始新的请求。'
              : 'Confirm or reject the pending change before starting another request.',
        );
        return;
      }
      await _ref
          .read(agentProviderSettingsControllerProvider.notifier)
          .initialized;
      final settings = _ref.read(agentProviderSettingsControllerProvider);
      if (!settings.isReady) {
        _fail(
          _isChinese
              ? '请先配置并测试 Agent 模型服务。'
              : 'Configure and test an Agent provider first.',
        );
        return;
      }
      final key = await _ref
          .read(agentProviderSettingsStoreProvider)
          .loadApiKey();
      if (key == null || key.isEmpty) {
        _fail(
          _isChinese
              ? 'Agent API Key 已不可用，请重新输入。'
              : 'The Agent API key is no longer available.',
        );
        return;
      }

      final now = DateTime.now();
      var conversation = state.runState.conversation;
      conversation ??= AgentConversation(
        id: const Uuid().v4(),
        title: _titleFor(prompt),
        createdAt: now,
        updatedAt: now,
        messages: const [],
      );
      conversation = _append(
        conversation,
        AgentMessage(
          id: const Uuid().v4(),
          role: AgentMessageRole.user,
          content: prompt,
          createdAt: now,
        ),
      );
      _lastSubmittedPrompt = prompt;
      state = state.copyWith(
        insights: const [],
        runState: AgentRunState(
          phase: AgentRunPhase.connecting,
          conversation: conversation,
        ),
      );
      await _persistConversation(conversation);
      await _run(config: settings.config, apiKey: key);
    } finally {
      _submissionInFlight = false;
    }
  }

  Future<void> _run({
    required AgentProviderConfig config,
    required String apiKey,
  }) async {
    final token = AgentCancellationToken();
    _cancellationToken = token;
    var conversation = state.runState.conversation!;
    var modelTurns = 0;
    var toolCalls = 0;
    try {
      while (modelTurns < AgentRunLimits.maxModelTurns) {
        token.throwIfCancelled();
        modelTurns += 1;
        final assistantId = const Uuid().v4();
        var assistant = AgentMessage(
          id: assistantId,
          role: AgentMessageRole.assistant,
          createdAt: DateTime.now(),
          isPartial: true,
        );
        conversation = _append(conversation, assistant);
        _setRun(
          phase: AgentRunPhase.streaming,
          conversation: conversation,
          modelTurns: modelTurns,
          toolCalls: toolCalls,
          clearError: true,
        );

        final fragments = <int, _ToolCallBuilder>{};
        await for (final event
            in _ref
                .read(agentModelTransportProvider)
                .streamChat(
                  config: config,
                  apiKey: apiKey,
                  request: AgentChatCompletionRequest(
                    model: config.model,
                    messages: _requestMessages(conversation),
                    tools: _toolDefinitions(),
                    temperature: 0.2,
                  ),
                  cancellationToken: token,
                )) {
          if (event is AgentTextDelta) {
            assistant = assistant.copyWith(
              content: redactAgentSecrets(
                '${assistant.content}${event.text}',
                secrets: [apiKey],
              ),
            );
            conversation = _replaceMessage(conversation, assistant);
            _setRun(
              phase: AgentRunPhase.streaming,
              conversation: conversation,
              modelTurns: modelTurns,
              toolCalls: toolCalls,
            );
          } else if (event is AgentReasoningDelta) {
            assistant = assistant.copyWith(
              reasoningContent: redactAgentSecrets(
                '${assistant.reasoningContent ?? ''}${event.text}',
                secrets: [apiKey],
              ),
            );
          } else if (event is AgentToolCallDelta) {
            fragments
                .putIfAbsent(event.index, _ToolCallBuilder.new)
                .append(event);
          } else if (event is AgentModelFailure) {
            throw AgentTransportException(event.message, code: event.code);
          }
        }
        token.throwIfCancelled();

        final completedCalls = fragments.entries
            .toList()
            .sortedByKey()
            .map((entry) => entry.value.build(entry.key, secrets: [apiKey]))
            .toList();
        assistant = AgentMessage(
          id: assistant.id,
          role: assistant.role,
          createdAt: assistant.createdAt,
          content: assistant.content,
          reasoningContent: assistant.reasoningContent,
          toolCalls: completedCalls,
        );
        conversation = _replaceMessage(conversation, assistant);
        await _persistConversation(conversation);

        if (completedCalls.isEmpty) {
          _setRun(
            phase: AgentRunPhase.completed,
            conversation: conversation,
            modelTurns: modelTurns,
            toolCalls: toolCalls,
            clearTool: true,
          );
          await _reloadLists(conversation);
          return;
        }

        for (final call in completedCalls) {
          token.throwIfCancelled();
          if (toolCalls >= AgentRunLimits.maxToolCalls) {
            throw StateError(
              _isChinese
                  ? 'Agent 已达到本轮工具调用安全上限。'
                  : 'The Agent reached the tool-call safety limit.',
            );
          }
          toolCalls += 1;
          _setRun(
            phase: AgentRunPhase.usingTools,
            conversation: conversation,
            modelTurns: modelTurns,
            toolCalls: toolCalls,
            activeToolName: call.name,
          );
          final arguments = _decodeArguments(call.argumentsJson);
          final result = await _ref
              .read(agentToolRegistryProvider)
              .execute(call.name, arguments);
          token.throwIfCancelled();
          conversation = _append(
            conversation,
            AgentMessage(
              id: const Uuid().v4(),
              role: AgentMessageRole.tool,
              content: result.encoded,
              toolCallId: call.id,
              createdAt: DateTime.now(),
            ),
          );
          if (call.name == 'analyze_training' && !result.isError) {
            state = state.copyWith(
              insights: _analyticsInsights(result.payload),
            );
          }
          final proposal = result.proposal;
          if (proposal != null) {
            await _persistConversation(conversation);
            _setRun(
              phase: AgentRunPhase.awaitingApproval,
              conversation: conversation,
              pendingProposal: proposal,
              modelTurns: modelTurns,
              toolCalls: toolCalls,
              clearTool: true,
            );
            await _reloadLists(conversation);
            return;
          }
        }
        await _persistConversation(conversation);
      }
      throw StateError(
        _isChinese
            ? 'Agent 已达到本轮模型往返安全上限。'
            : 'The Agent reached the model-turn safety limit.',
      );
    } on AgentRequestCancelledException {
      _setRun(
        phase: AgentRunPhase.cancelled,
        conversation: conversation,
        modelTurns: modelTurns,
        toolCalls: toolCalls,
        clearTool: true,
      );
      await _persistConversation(conversation);
    } catch (error) {
      final message = redactAgentSecrets(
        _safeRunError(error),
        secrets: [apiKey],
      );
      _setRun(
        phase: AgentRunPhase.failed,
        conversation: conversation,
        errorMessage: message,
        modelTurns: modelTurns,
        toolCalls: toolCalls,
        clearTool: true,
      );
      await _persistConversation(conversation);
    } finally {
      if (identical(_cancellationToken, token)) _cancellationToken = null;
    }
  }

  Future<void> stop() async {
    _cancellationToken?.cancel();
  }

  Future<void> retry() async {
    if (state.runState.isBusy || state.runState.phase != AgentRunPhase.failed) {
      return;
    }
    final conversation = state.runState.conversation;
    final prompt = _lastSubmittedPrompt;
    if (conversation == null || prompt == null) return;
    final cleaned = _conversationForRetry(conversation);
    state = state.copyWith(
      runState: AgentRunState(
        phase: AgentRunPhase.connecting,
        conversation: cleaned,
      ),
    );
    final settings = _ref.read(agentProviderSettingsControllerProvider);
    final key = await _ref
        .read(agentProviderSettingsStoreProvider)
        .loadApiKey();
    if (!settings.isReady || key == null) {
      _fail(
        _isChinese
            ? 'Agent 模型服务已不可用。'
            : 'The Agent provider is no longer available.',
      );
      return;
    }
    await _run(config: settings.config, apiKey: key);
  }

  Future<void> newConversation() async {
    await _initialLoad;
    if (state.runState.isBusy || state.runState.pendingProposal != null) return;
    state = state.copyWith(insights: const [], runState: const AgentRunState());
  }

  Future<void> openConversation(String conversationId) async {
    await _initialLoad;
    if (state.runState.isBusy || state.runState.pendingProposal != null) return;
    final conversation = await _ref
        .read(agentLocalRepositoryProvider)
        .fetchConversation(conversationId, ownerUserId: _ownerUserId);
    if (conversation == null) return;
    state = state.copyWith(
      insights: const [],
      runState: AgentRunState(
        phase: AgentRunPhase.completed,
        conversation: conversation,
      ),
    );
  }

  Future<void> deleteConversation(String conversationId) async {
    await _initialLoad;
    if (state.runState.isBusy || state.runState.pendingProposal != null) return;
    final owner = _ownerUserId;
    await _ref
        .read(agentLocalRepositoryProvider)
        .deleteConversation(conversationId, ownerUserId: owner);
    final conversations = await _ref
        .read(agentLocalRepositoryProvider)
        .fetchConversations(ownerUserId: owner);
    final active = state.runState.conversation?.id == conversationId
        ? conversations.firstOrNull
        : state.runState.conversation;
    state = state.copyWith(
      conversations: conversations,
      runState: AgentRunState(
        phase: active == null ? AgentRunPhase.idle : AgentRunPhase.completed,
        conversation: active,
      ),
    );
  }

  Future<void> confirmProposal(String operationId) async {
    if (_decisionInFlight) return;
    final proposal = state.runState.pendingProposal;
    if (proposal == null || proposal.operationId != operationId) return;
    _decisionInFlight = true;
    try {
      await _ref.read(agentMutationCoordinatorProvider).confirm(proposal);
      final conversation = _append(
        state.runState.conversation!,
        AgentMessage(
          id: const Uuid().v4(),
          role: AgentMessageRole.assistant,
          content: _isChinese
              ? '修改已在本机应用，可在操作历史中撤销。'
              : 'Change applied locally. You can undo it from action history.',
          createdAt: DateTime.now(),
        ),
      );
      await _persistConversation(conversation);
      state = state.copyWith(
        runState: state.runState.copyWith(
          phase: AgentRunPhase.completed,
          conversation: conversation,
          clearProposal: true,
          clearError: true,
        ),
      );
      await _reloadLists(conversation);
    } catch (error) {
      _setRun(
        phase: AgentRunPhase.failed,
        errorMessage: _safeRunError(error),
        clearProposal: true,
      );
    } finally {
      _decisionInFlight = false;
    }
  }

  Future<void> rejectProposal(String operationId) async {
    if (_decisionInFlight) return;
    final proposal = state.runState.pendingProposal;
    if (proposal == null || proposal.operationId != operationId) return;
    _decisionInFlight = true;
    try {
      final conversation = _append(
        state.runState.conversation!,
        AgentMessage(
          id: const Uuid().v4(),
          role: AgentMessageRole.assistant,
          content: _isChinese
              ? '已取消修改，没有数据被更改。'
              : 'Change cancelled. No data was modified.',
          createdAt: DateTime.now(),
        ),
      );
      await _persistConversation(conversation);
      _setRun(
        phase: AgentRunPhase.completed,
        conversation: conversation,
        clearProposal: true,
        clearError: true,
      );
    } finally {
      _decisionInFlight = false;
    }
  }

  Future<void> undoAction(String actionId) async {
    try {
      await _ref.read(agentMutationCoordinatorProvider).undo(actionId);
      await _reloadLists(state.runState.conversation);
    } catch (error) {
      _fail(_safeRunError(error));
    }
  }

  List<AgentChatMessagePayload> _requestMessages(
    AgentConversation conversation,
  ) => [
    const AgentChatMessagePayload(role: 'system', content: _systemPrompt),
    for (final message in conversation.messages)
      if (!message.isPartial)
        AgentChatMessagePayload(
          role: message.role.name,
          content: message.content.isEmpty ? null : message.content,
          reasoningContent: message.reasoningContent,
          toolCallId: message.toolCallId,
          toolCalls: [
            for (final call in message.toolCalls)
              {
                'id': call.id,
                'type': 'function',
                'function': {
                  'name': call.name,
                  'arguments': call.argumentsJson,
                },
              },
          ],
        ),
  ];

  List<AgentChatToolDefinition> _toolDefinitions() {
    return _ref.read(agentToolRegistryProvider).definitions.map((raw) {
      final function = (raw['function'] as Map).cast<String, dynamic>();
      return AgentChatToolDefinition(
        name: function['name'] as String,
        description: function['description'] as String,
        parameters: (function['parameters'] as Map).cast<String, dynamic>(),
      );
    }).toList();
  }

  Future<void> _persistConversation(AgentConversation conversation) {
    return _ref
        .read(agentLocalRepositoryProvider)
        .saveConversation(
          _conversationForStorage(conversation),
          ownerUserId: _ownerUserId,
        );
  }

  static AgentConversation _conversationForStorage(
    AgentConversation conversation,
  ) => conversation.copyWith(
    messages: [
      for (final message in conversation.messages)
        if (message.role == AgentMessageRole.tool)
          AgentMessage(
            id: message.id,
            role: message.role,
            createdAt: message.createdAt,
            content: _compactToolResult(message.content),
            toolCallId: message.toolCallId,
          )
        else
          message,
    ],
  );

  static String _compactToolResult(String source) {
    try {
      final decoded = jsonDecode(source);
      if (decoded is Map) {
        final error = decoded['error'];
        if (error is Map) {
          return jsonEncode({
            'status': 'error',
            'code': error['code'] ?? 'tool_failed',
          });
        }
        if (decoded['status'] == 'pending_user_approval') {
          return jsonEncode({
            'status': 'pending_user_approval',
            'operationId': decoded['operationId'],
            'title': decoded['title'],
            'summary': decoded['summary'],
          });
        }
      }
    } catch (_) {}
    return '{"status":"completed","detail":"Local result omitted from stored history."}';
  }

  Future<void> _reloadLists(AgentConversation? active) async {
    final owner = _ownerUserId;
    final repository = _ref.read(agentLocalRepositoryProvider);
    final conversations = await repository.fetchConversations(
      ownerUserId: owner,
    );
    final actions = await repository.fetchActions(ownerUserId: owner);
    if (!mounted) return;
    state = state.copyWith(
      conversations: conversations,
      actions: actions,
      runState: active == null
          ? state.runState
          : state.runState.copyWith(conversation: active),
    );
  }

  void _setRun({
    required AgentRunPhase phase,
    AgentConversation? conversation,
    AgentMutationProposal? pendingProposal,
    String? activeToolName,
    String? errorMessage,
    int? modelTurns,
    int? toolCalls,
    bool clearProposal = false,
    bool clearTool = false,
    bool clearError = false,
  }) {
    if (!mounted) return;
    state = state.copyWith(
      runState: state.runState.copyWith(
        phase: phase,
        conversation: conversation,
        pendingProposal: pendingProposal,
        activeToolName: activeToolName,
        errorMessage: errorMessage,
        modelTurns: modelTurns,
        toolCalls: toolCalls,
        clearProposal: clearProposal,
        clearTool: clearTool,
        clearError: clearError,
      ),
    );
  }

  void _fail(String message) {
    _setRun(
      phase: AgentRunPhase.failed,
      errorMessage: message,
      clearTool: true,
    );
  }

  static AgentConversation _append(
    AgentConversation conversation,
    AgentMessage message,
  ) {
    final messages = [...conversation.messages, message];
    final trimmed = messages.length <= AgentRunLimits.maxConversationMessages
        ? messages
        : messages.sublist(
            messages.length - AgentRunLimits.maxConversationMessages,
          );
    return conversation.copyWith(messages: trimmed, updatedAt: DateTime.now());
  }

  static AgentConversation _replaceMessage(
    AgentConversation conversation,
    AgentMessage replacement,
  ) => conversation.copyWith(
    messages: [
      for (final message in conversation.messages)
        if (message.id == replacement.id) replacement else message,
    ],
    updatedAt: DateTime.now(),
  );

  static AgentConversation _conversationForRetry(
    AgentConversation conversation,
  ) {
    final lastUserIndex = conversation.messages.lastIndexWhere(
      (message) => message.role == AgentMessageRole.user,
    );
    return conversation.copyWith(
      messages: lastUserIndex < 0
          ? const []
          : conversation.messages.sublist(0, lastUserIndex + 1),
      updatedAt: DateTime.now(),
    );
  }

  static Map<String, dynamic> _decodeArguments(String source) {
    final decoded = jsonDecode(source.isEmpty ? '{}' : source);
    if (decoded is! Map) throw const FormatException('Invalid tool arguments.');
    return decoded.cast<String, dynamic>();
  }

  List<AgentStructuredInsight> _analyticsInsights(
    Map<String, dynamic> payload,
  ) => [
    AgentStructuredInsight(
      title: _isChinese ? '完成训练' : 'Completed workouts',
      value: '${payload['completedWorkouts'] ?? 0}',
      detail: _isChinese
          ? '统计范围：最近 ${payload['rangeDays'] ?? 90} 天。'
          : 'Across the selected ${payload['rangeDays'] ?? 90}-day range.',
    ),
    AgentStructuredInsight(
      title: _isChinese ? '训练容量' : 'Training volume',
      value: _compactNumber(payload['volume']),
      detail: _isChinese
          ? '${payload['trainingDays'] ?? 0} 个有效训练日。'
          : '${payload['trainingDays'] ?? 0} active training days.',
    ),
    AgentStructuredInsight(
      title: _isChinese ? '近期 PR' : 'Recent PRs',
      value: '${(payload['recentPrs'] as List?)?.length ?? 0}',
      detail: _isChinese
          ? '依据已完成的训练记录在本机计算。'
          : 'Calculated locally from completed workout records.',
    ),
  ];

  static String _compactNumber(Object? value) {
    final number = (value as num?)?.toDouble() ?? 0;
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}m';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}k';
    return number.toStringAsFixed(0);
  }

  static String _titleFor(String prompt) {
    final singleLine = prompt.replaceAll(RegExp(r'\s+'), ' ').trim();
    return singleLine.length <= 36
        ? singleLine
        : '${singleLine.substring(0, 36)}…';
  }

  String _safeRunError(Object error) {
    final source = switch (error) {
      AgentTransportException(:final message) => message,
      AgentMutationConflict(:final message) => message,
      FormatException(:final message) => message,
      StateError(:final message) => message,
      _ => _isChinese ? 'Agent 请求失败。' : 'The Agent request failed.',
    };
    final localized = _isChinese ? _localizeOwnedError(source) : source;
    return localized.length <= 500
        ? localized
        : '${localized.substring(0, 500)}…';
  }

  static String _localizeOwnedError(String source) => switch (source) {
    'This proposal expired. Ask the Agent to generate it again.' =>
      '这个修改预览已过期，请让 Agent 重新生成。',
    'The target changed on this or another device. Generate a fresh proposal.' =>
      '目标数据已在本机或其他设备上改变，请重新生成修改预览。',
    'This action cannot be undone.' => '该操作无法撤销。',
    'The target changed after this action. Undo was safely refused.' =>
      '该操作之后目标数据又发生了变化，已安全拒绝撤销。',
    'Training progress changed after this preview. Generate a fresh proposal.' =>
      '训练进度在生成预览后发生了变化，请重新生成修改预览。',
    'Agent action not found.' => '找不到 Agent 操作记录。',
    'This change is too large to keep a safe undo snapshot. Split it into smaller changes.' =>
      '这次修改太大，无法安全保留撤销快照。请拆分为更小的修改。',
    _ => source,
  };
}

class _ToolCallBuilder {
  String? id;
  var name = '';
  var arguments = '';

  void append(AgentToolCallDelta delta) {
    id ??= delta.id;
    if (delta.name != null) name += delta.name!;
    arguments += delta.argumentsDelta;
  }

  AgentToolCall build(int index, {Iterable<String> secrets = const []}) {
    if (name.isEmpty) throw const FormatException('Tool name is missing.');
    return AgentToolCall(
      id: id ?? 'tool-call-$index-${const Uuid().v4()}',
      name: name,
      argumentsJson: arguments.isEmpty
          ? '{}'
          : redactAgentSecrets(arguments, secrets: secrets),
    );
  }
}

extension on List<MapEntry<int, _ToolCallBuilder>> {
  List<MapEntry<int, _ToolCallBuilder>> sortedByKey() =>
      this..sort((a, b) => a.key.compareTo(b.key));
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

const _systemPrompt = '''
You are Fittin's in-app training assistant. Help the user understand their own
training and body-metric data, and make precise, conservative improvements.
Use tools to read facts; never invent plan state, records, personal records or
measurements. Prefer local aggregate analytics over requesting large raw data.
Every write must use a propose_* tool and must stop for explicit user approval.
Never claim a proposal has been applied. Do not request or expose API keys,
authentication, account settings, app settings, progress photos or photo
metadata. Keep answers useful, concise and in the user's language.
''';
