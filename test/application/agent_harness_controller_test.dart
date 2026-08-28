import 'dart:convert';
import 'dart:async';

import 'package:fittin_v2/src/application/agent_chat_protocol.dart';
import 'package:fittin_v2/src/application/agent_harness_controller.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/agent_provider_settings_provider.dart';
import 'package:fittin_v2/src/application/agent_tools.dart';
import 'package:fittin_v2/src/data/agent_local_repository.dart';
import 'package:fittin_v2/src/data/remote/agent_model_transport.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'DeepSeek tool continuation survives a saved conversation reopen',
    () async {
      var requests = 0;
      final transport = NativeAgentModelTransport(
        client: MockClient((request) async {
          final body = jsonDecode(request.body) as Map;
          final messages = body['messages'] as List;
          requests += 1;
          if (requests > 1) {
            final assistant = messages.cast<Map>().firstWhere(
              (message) => message['role'] == 'assistant',
            );
            if (assistant['reasoning_content'] !=
                'Read local summary [REDACTED]') {
              return http.Response(
                '{"error":{"message":"Missing reasoning_content"}}',
                400,
              );
            }
            expect(
              messages.last['content'],
              isNot(contains('secret-test-key')),
            );
          }
          return http.Response(
            jsonEncode({
              'choices': [
                {
                  'message': requests == 1
                      ? {
                          'role': 'assistant',
                          'content': '',
                          'reasoning_content':
                              'Read local summary secret-test-key',
                          'tool_calls': [
                            {
                              'id': 'call_summary',
                              'type': 'function',
                              'function': {
                                'name': 'read_summary',
                                'arguments': '{}',
                              },
                            },
                          ],
                        }
                      : {
                          'role': 'assistant',
                          'content': 'Two workouts this week.',
                          'reasoning_content': 'Summarize the result',
                        },
                  'finish_reason': requests == 1 ? 'tool_calls' : 'stop',
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      final container = _container(
        transport: transport,
        tools: _FakeTools(
          AgentToolResult(payload: const {'completedWorkouts': 2}),
        ),
        settingsStore: _DeepSeekSettingsStore(),
      );
      addTearDown(container.dispose);
      final controller = container.read(
        agentHarnessControllerProvider.notifier,
      );
      await controller.submit('How did I train?');
      expect(
        container.read(agentHarnessControllerProvider).runState.phase,
        AgentRunPhase.completed,
      );
      final saved =
          (await container
                  .read(agentLocalRepositoryProvider)
                  .fetchConversations())
              .single;
      final firstAssistant = saved.messages.firstWhere(
        (message) => message.role == AgentMessageRole.assistant,
      );
      expect(firstAssistant.reasoningContent, 'Read local summary [REDACTED]');
      expect(firstAssistant.content, isEmpty);
      expect(jsonEncode(saved.toJson()), isNot(contains('secret-test-key')));

      await controller.openConversation(saved.id);
      await controller.submit('Continue the analysis');
      expect(requests, 3);
      expect(
        container.read(agentHarnessControllerProvider).runState.phase,
        AgentRunPhase.completed,
      );
    },
  );

  test(
    'streams assistant content and keeps the completed conversation',
    () async {
      final container = _container(
        transport: _ScriptedTransport([
          const AgentTextDelta('Your '),
          const AgentTextDelta('summary'),
          const AgentModelCompleted(finishReason: 'stop'),
        ]),
      );
      addTearDown(container.dispose);

      await container
          .read(agentHarnessControllerProvider.notifier)
          .submit('Analyze my training');

      final state = container.read(agentHarnessControllerProvider);
      expect(state.runState.phase, AgentRunPhase.completed);
      expect(
        state.runState.conversation!.messages.last.content,
        'Your summary',
      );
      expect(state.conversations, hasLength(1));
    },
  );

  test('redacts a provider key echoed across streamed chunks', () async {
    final container = _container(
      transport: _ScriptedTransport([
        const AgentTextDelta('Do not show secret-'),
        const AgentTextDelta('test-key here'),
        const AgentModelCompleted(finishReason: 'stop'),
      ]),
    );
    addTearDown(container.dispose);

    await container
        .read(agentHarnessControllerProvider.notifier)
        .submit('Check privacy');

    final visible = container
        .read(agentHarnessControllerProvider)
        .runState
        .conversation!
        .messages
        .last
        .content;
    expect(visible, isNot(contains('secret-test-key')));
    expect(visible, contains('[REDACTED]'));
  });

  test('executes read tool locally before the second model turn', () async {
    final transport = _TurnTransport([
      [
        const AgentToolCallDelta(
          index: 0,
          id: 'call_1',
          name: 'read_summary',
          argumentsDelta: '{}',
        ),
        const AgentModelCompleted(finishReason: 'tool_calls'),
      ],
      [
        const AgentTextDelta('Two workouts this week.'),
        const AgentModelCompleted(finishReason: 'stop'),
      ],
    ]);
    final tools = _FakeTools(
      AgentToolResult(payload: const {'completedWorkouts': 2}),
    );
    final container = _container(transport: transport, tools: tools);
    addTearDown(container.dispose);

    await container
        .read(agentHarnessControllerProvider.notifier)
        .submit('How did I train?');

    expect(tools.calls, ['read_summary']);
    expect(transport.requests, hasLength(2));
    expect(
      transport.requests.last.messages.any(
        (message) =>
            message.role == 'tool' &&
            jsonDecode(message.content!)['completedWorkouts'] == 2,
      ),
      isTrue,
    );
    expect(
      container
          .read(agentHarnessControllerProvider)
          .runState
          .conversation!
          .messages
          .last
          .content,
      'Two workouts this week.',
    );
    final stored = await container
        .read(agentLocalRepositoryProvider)
        .fetchConversations();
    final persistedTool = stored.single.messages.firstWhere(
      (message) => message.role == AgentMessageRole.tool,
    );
    expect(persistedTool.content, isNot(contains('completedWorkouts')));
  });

  test('stops on a mutation proposal without writing', () async {
    final proposal = AgentMutationProposal(
      operationId: 'op-1',
      toolName: 'propose_create_body_metric',
      title: 'Add weight',
      summary: 'Preview',
      argumentsJson: '{}',
      targetType: 'body_metric',
      targetId: 'metric-1',
      expectedDigest: agentPayloadDigest(null),
      changes: const [
        AgentMutationChange(path: 'weightKg', before: 'None', after: '80'),
      ],
      createdAt: DateTime.now(),
    );
    final container = _container(
      transport: _ScriptedTransport([
        const AgentToolCallDelta(
          index: 0,
          id: 'call-1',
          name: 'propose_create_body_metric',
          argumentsDelta: '{}',
        ),
        const AgentModelCompleted(finishReason: 'tool_calls'),
      ]),
      tools: _FakeTools(
        AgentToolResult(
          payload: const {'status': 'pending'},
          proposal: proposal,
        ),
      ),
    );
    addTearDown(container.dispose);

    await container
        .read(agentHarnessControllerProvider.notifier)
        .submit('Record 80 kg');

    final run = container.read(agentHarnessControllerProvider).runState;
    expect(run.phase, AgentRunPhase.awaitingApproval);
    expect(run.pendingProposal?.operationId, 'op-1');
  });

  test('assembles interleaved fragmented tool names and arguments', () async {
    final transport = _TurnTransport([
      [
        const AgentToolCallDelta(
          index: 1,
          id: 'call-2',
          name: 'read_',
          argumentsDelta: '{"page":',
        ),
        const AgentToolCallDelta(
          index: 0,
          id: 'call-1',
          name: 'read_',
          argumentsDelta: '{"page":',
        ),
        const AgentToolCallDelta(
          index: 1,
          name: 'summary',
          argumentsDelta: '2}',
        ),
        const AgentToolCallDelta(
          index: 0,
          name: 'summary',
          argumentsDelta: '1}',
        ),
        const AgentModelCompleted(finishReason: 'tool_calls'),
      ],
      [
        const AgentTextDelta('Done'),
        const AgentModelCompleted(finishReason: 'stop'),
      ],
    ]);
    final tools = _FakeTools(AgentToolResult(payload: const {'ok': true}));
    final container = _container(transport: transport, tools: tools);
    addTearDown(container.dispose);

    await container
        .read(agentHarnessControllerProvider.notifier)
        .submit('Read two pages');

    expect(tools.calls, ['read_summary', 'read_summary']);
    expect(tools.arguments, [
      {'page': 1},
      {'page': 2},
    ]);
  });

  test('never starts more than eight model turns', () async {
    final transport = _TurnTransport(
      List.generate(
        AgentRunLimits.maxModelTurns,
        (index) => [
          AgentToolCallDelta(
            index: 0,
            id: 'call-$index',
            name: 'read_summary',
            argumentsDelta: '{}',
          ),
          const AgentModelCompleted(finishReason: 'tool_calls'),
        ],
      ),
    );
    final tools = _FakeTools(AgentToolResult(payload: const {'ok': true}));
    final container = _container(transport: transport, tools: tools);
    addTearDown(container.dispose);

    await container
        .read(agentHarnessControllerProvider.notifier)
        .submit('Keep reading');

    final run = container.read(agentHarnessControllerProvider).runState;
    expect(run.phase, AgentRunPhase.failed);
    expect(run.modelTurns, AgentRunLimits.maxModelTurns);
    expect(transport.requests, hasLength(AgentRunLimits.maxModelTurns));
  });

  test(
    'executes at most twelve tool calls and reports a bounded count',
    () async {
      final events = <AgentModelEvent>[
        for (var index = 0; index <= AgentRunLimits.maxToolCalls; index += 1)
          AgentToolCallDelta(
            index: index,
            id: 'call-$index',
            name: 'read_summary',
            argumentsDelta: '{}',
          ),
        const AgentModelCompleted(finishReason: 'tool_calls'),
      ];
      final tools = _FakeTools(AgentToolResult(payload: const {'ok': true}));
      final container = _container(
        transport: _ScriptedTransport(events),
        tools: tools,
      );
      addTearDown(container.dispose);

      await container
          .read(agentHarnessControllerProvider.notifier)
          .submit('Call too many tools');

      final run = container.read(agentHarnessControllerProvider).runState;
      expect(run.phase, AgentRunPhase.failed);
      expect(run.toolCalls, AgentRunLimits.maxToolCalls);
      expect(tools.calls, hasLength(AgentRunLimits.maxToolCalls));
    },
  );

  test('fast duplicate submit starts only one run', () async {
    final loadGate = Completer<void>();
    final store = _ReadySettingsStore(loadGate: loadGate);
    final transport = _ScriptedTransport([
      const AgentTextDelta('One response'),
      const AgentModelCompleted(finishReason: 'stop'),
    ]);
    final container = _container(transport: transport, settingsStore: store);
    addTearDown(container.dispose);
    final controller = container.read(agentHarnessControllerProvider.notifier);

    final first = controller.submit('First');
    final second = controller.submit('Second');
    loadGate.complete();
    await Future.wait([first, second]);

    expect(transport.requests, hasLength(1));
    final userMessages = container
        .read(agentHarnessControllerProvider)
        .runState
        .conversation!
        .messages
        .where((message) => message.role == AgentMessageRole.user);
    expect(userMessages.map((message) => message.content), ['First']);
  });

  test('stop keeps partial output and performs no tool call', () async {
    final transport = _CancellableTransport();
    final tools = _FakeTools(AgentToolResult(payload: const {'ok': true}));
    final container = _container(transport: transport, tools: tools);
    addTearDown(container.dispose);
    final controller = container.read(agentHarnessControllerProvider.notifier);

    final submission = controller.submit('Slow request');
    await transport.partialDelivered.future;
    await controller.stop();
    await submission;

    final run = container.read(agentHarnessControllerProvider).runState;
    expect(run.phase, AgentRunPhase.cancelled);
    expect(run.conversation!.messages.last.content, 'Partial answer');
    expect(run.conversation!.messages.last.isPartial, isTrue);
    expect(tools.calls, isEmpty);
  });

  test(
    'stop during a local tool prevents a later proposal from surfacing',
    () async {
      final proposal = AgentMutationProposal(
        operationId: 'op-after-stop',
        toolName: 'propose_create_body_metric',
        title: 'Add metric',
        summary: 'Preview',
        argumentsJson: '{}',
        targetType: 'body_metric',
        targetId: 'metric-after-stop',
        expectedDigest: agentPayloadDigest(null),
        changes: const [],
        createdAt: DateTime.now(),
      );
      final tools = _BlockingProposalTools(proposal);
      final container = _container(
        transport: _ScriptedTransport([
          const AgentToolCallDelta(
            index: 0,
            id: 'call-after-stop',
            name: 'propose_create_body_metric',
            argumentsDelta: '{}',
          ),
          const AgentModelCompleted(finishReason: 'tool_calls'),
        ]),
        tools: tools,
      );
      addTearDown(container.dispose);
      final controller = container.read(
        agentHarnessControllerProvider.notifier,
      );

      final submission = controller.submit('Add then stop');
      await tools.started.future;
      await controller.stop();
      tools.release.complete();
      await submission;

      final run = container.read(agentHarnessControllerProvider).runState;
      expect(run.phase, AgentRunPhase.cancelled);
      expect(run.pendingProposal, isNull);
    },
  );

  test(
    'retry removes the entire failed tool sequence after the last user',
    () async {
      final transport = _TurnTransport([
        [
          const AgentToolCallDelta(
            index: 0,
            id: 'broken-call',
            name: 'read_summary',
            argumentsDelta: '{',
          ),
          const AgentModelCompleted(finishReason: 'tool_calls'),
        ],
        [
          const AgentTextDelta('Recovered'),
          const AgentModelCompleted(finishReason: 'stop'),
        ],
      ]);
      final tools = _FakeTools(AgentToolResult(payload: const {'ok': true}));
      final container = _container(transport: transport, tools: tools);
      addTearDown(container.dispose);
      final controller = container.read(
        agentHarnessControllerProvider.notifier,
      );

      await controller.submit('Try once');
      expect(
        container.read(agentHarnessControllerProvider).runState.phase,
        AgentRunPhase.failed,
      );
      await controller.retry();

      expect(transport.requests, hasLength(2));
      final retryMessages = transport.requests.last.messages;
      expect(retryMessages.map((message) => message.role), ['system', 'user']);
      final storedMessages = container
          .read(agentHarnessControllerProvider)
          .runState
          .conversation!
          .messages;
      expect(storedMessages.map((message) => message.role), [
        AgentMessageRole.user,
        AgentMessageRole.assistant,
      ]);
      expect(storedMessages.last.content, 'Recovered');
    },
  );

  test(
    'pending approval cannot be hidden by starting a new conversation',
    () async {
      final proposal = AgentMutationProposal(
        operationId: 'op-lock',
        toolName: 'propose_create_body_metric',
        title: 'Add weight',
        summary: 'Preview',
        argumentsJson: '{}',
        targetType: 'body_metric',
        targetId: 'metric-lock',
        expectedDigest: agentPayloadDigest(null),
        changes: const [],
        createdAt: DateTime.now(),
      );
      final container = _container(
        transport: _ScriptedTransport([
          const AgentToolCallDelta(
            index: 0,
            id: 'call-lock',
            name: 'propose_create_body_metric',
            argumentsDelta: '{}',
          ),
          const AgentModelCompleted(finishReason: 'tool_calls'),
        ]),
        tools: _FakeTools(
          AgentToolResult(payload: const {}, proposal: proposal),
        ),
      );
      addTearDown(container.dispose);
      final controller = container.read(
        agentHarnessControllerProvider.notifier,
      );

      await controller.submit('Add a metric');
      final conversationId = container
          .read(agentHarnessControllerProvider)
          .runState
          .conversation!
          .id;
      await controller.newConversation();

      final run = container.read(agentHarnessControllerProvider).runState;
      expect(run.conversation!.id, conversationId);
      expect(run.pendingProposal?.operationId, 'op-lock');
      expect(run.phase, AgentRunPhase.awaitingApproval);
    },
  );
}

ProviderContainer _container({
  required AgentModelTransport transport,
  AgentToolRegistry? tools,
  AgentProviderSettingsStore? settingsStore,
}) {
  final store = settingsStore ?? _ReadySettingsStore();
  return ProviderContainer(
    overrides: [
      appLocaleProvider.overrideWith(
        (ref) => AppLocaleNotifier(ref, initialLocale: AppLocale.en),
      ),
      agentLocalRepositoryProvider.overrideWithValue(
        InMemoryAgentLocalRepository(),
      ),
      agentProviderSettingsStoreProvider.overrideWithValue(store),
      agentModelTransportProvider.overrideWithValue(transport),
      agentConnectionTesterProvider.overrideWithValue(
        AgentConnectionTester(transport),
      ),
      if (tools != null) agentToolRegistryProvider.overrideWithValue(tools),
    ],
  );
}

class _ReadySettingsStore implements AgentProviderSettingsStore {
  _ReadySettingsStore({this.loadGate});

  final Completer<void>? loadGate;

  @override
  Future<void> clear() async {}

  @override
  Future<AgentProviderConfig> load() async {
    await loadGate?.future;
    return const AgentProviderConfig(
      baseUrl: 'https://provider.example/v1',
      model: 'test-model',
      hasApiKey: true,
      toolCallingVerified: true,
    );
  }

  @override
  Future<String?> loadApiKey() async => 'secret-test-key';

  @override
  Future<AgentProviderConfig> save({
    required String baseUrl,
    required String model,
    String? apiKey,
    bool toolCallingVerified = false,
  }) async => AgentProviderConfig(
    baseUrl: baseUrl,
    model: model,
    hasApiKey: true,
    toolCallingVerified: toolCallingVerified,
  );
}

class _DeepSeekSettingsStore extends _ReadySettingsStore {
  @override
  Future<AgentProviderConfig> load() async => const AgentProviderConfig(
    baseUrl: 'https://api.deepseek.com/v1',
    model: 'deepseek-reasoner',
    hasApiKey: true,
    toolCallingVerified: true,
  );
}

class _ScriptedTransport implements AgentModelTransport {
  _ScriptedTransport(this.events);

  final List<AgentModelEvent> events;
  final List<AgentChatCompletionRequest> requests = [];

  @override
  void dispose() {}

  @override
  Stream<AgentModelEvent> stream({
    required AgentProviderConfig config,
    required String apiKey,
    required AgentChatCompletionRequest request,
    AgentCancellationToken? cancellationToken,
  }) {
    requests.add(request);
    return Stream.fromIterable(events);
  }
}

class _CancellableTransport implements AgentModelTransport {
  final partialDelivered = Completer<void>();

  @override
  void dispose() {}

  @override
  Stream<AgentModelEvent> stream({
    required AgentProviderConfig config,
    required String apiKey,
    required AgentChatCompletionRequest request,
    AgentCancellationToken? cancellationToken,
  }) async* {
    yield const AgentTextDelta('Partial answer');
    partialDelivered.complete();
    await cancellationToken!.whenCancelled;
    throw const AgentRequestCancelledException();
  }
}

class _TurnTransport implements AgentModelTransport {
  _TurnTransport(this.turns);

  final List<List<AgentModelEvent>> turns;
  final List<AgentChatCompletionRequest> requests = [];
  var index = 0;

  @override
  void dispose() {}

  @override
  Stream<AgentModelEvent> stream({
    required AgentProviderConfig config,
    required String apiKey,
    required AgentChatCompletionRequest request,
    AgentCancellationToken? cancellationToken,
  }) {
    requests.add(request);
    return Stream.fromIterable(turns[index++]);
  }
}

class _FakeTools implements AgentToolRegistry {
  _FakeTools(this.result);

  final AgentToolResult result;
  final List<String> calls = [];
  final List<Map<String, dynamic>> arguments = [];

  @override
  List<Map<String, dynamic>> get definitions => const [
    {
      'type': 'function',
      'function': {
        'name': 'read_summary',
        'description': 'read',
        'parameters': {'type': 'object'},
      },
    },
  ];

  @override
  Future<AgentToolResult> execute(
    String name,
    Map<String, dynamic> arguments,
  ) async {
    calls.add(name);
    this.arguments.add(arguments);
    return result;
  }
}

class _BlockingProposalTools implements AgentToolRegistry {
  _BlockingProposalTools(this.proposal);

  final AgentMutationProposal proposal;
  final started = Completer<void>();
  final release = Completer<void>();

  @override
  List<Map<String, dynamic>> get definitions => const [
    {
      'type': 'function',
      'function': {
        'name': 'propose_create_body_metric',
        'description': 'propose',
        'parameters': {'type': 'object'},
      },
    },
  ];

  @override
  Future<AgentToolResult> execute(
    String name,
    Map<String, dynamic> arguments,
  ) async {
    started.complete();
    await release.future;
    return AgentToolResult(payload: const {}, proposal: proposal);
  }
}
