import 'package:fittin_v2/src/application/agent_chat_protocol.dart';
import 'package:fittin_v2/src/application/agent_provider_settings_provider.dart';
import 'package:fittin_v2/src/data/remote/agent_model_transport.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('native store persists key only through secure storage', () async {
    final preferences = await SharedPreferences.getInstance();
    final secrets = InMemoryAgentSecretStore();
    final first = PlatformAgentProviderSettingsStore(
      preferences: preferences,
      secretStore: secrets,
      isWebOverride: false,
    );

    final saved = await first.save(
      baseUrl: 'https://provider.example/v1/',
      model: 'model-a',
      apiKey: 'private-key',
    );

    expect(saved.hasApiKey, isTrue);
    expect(preferences.getKeys(), isNot(contains('private-key')));
    expect(preferences.getString('fittin.agent.provider.apiKey'), isNull);
    final restored = await PlatformAgentProviderSettingsStore(
      preferences: preferences,
      secretStore: secrets,
      isWebOverride: false,
    ).load();
    expect(restored.baseUrl, 'https://provider.example/v1');
    expect(restored.model, 'model-a');
    expect(restored.hasApiKey, isTrue);
  });

  test('Web refresh retains provider fields but forgets key', () async {
    final preferences = await SharedPreferences.getInstance();
    final first = PlatformAgentProviderSettingsStore(
      preferences: preferences,
      secretStore: InMemoryAgentSecretStore(),
      isWebOverride: true,
    );
    await first.save(
      baseUrl: 'https://provider.example/v1',
      model: 'model-a',
      apiKey: 'ephemeral-key',
    );
    expect((await first.load()).hasApiKey, isTrue);

    final afterRefresh = PlatformAgentProviderSettingsStore(
      preferences: preferences,
      secretStore: InMemoryAgentSecretStore(),
      isWebOverride: true,
    );
    final restored = await afterRefresh.load();

    expect(restored.baseUrl, 'https://provider.example/v1');
    expect(restored.model, 'model-a');
    expect(restored.hasApiKey, isFalse);
  });

  test(
    'editing provider settings invalidates prior tool verification',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final store = PlatformAgentProviderSettingsStore(
        preferences: preferences,
        secretStore: InMemoryAgentSecretStore(),
        isWebOverride: false,
      );
      await store.save(
        baseUrl: 'https://provider.example/v1',
        model: 'model-a',
        apiKey: 'key',
        toolCallingVerified: true,
      );

      final changed = await store.save(
        baseUrl: 'https://provider.example/v1',
        model: 'model-b',
      );

      expect(changed.hasApiKey, isTrue);
      expect(changed.toolCallingVerified, isFalse);
    },
  );

  test('clear removes ordinary settings and the secure key', () async {
    final preferences = await SharedPreferences.getInstance();
    final secrets = InMemoryAgentSecretStore();
    final store = PlatformAgentProviderSettingsStore(
      preferences: preferences,
      secretStore: secrets,
      isWebOverride: false,
    );
    await store.save(
      baseUrl: 'https://provider.example/v1',
      model: 'model-a',
      apiKey: 'key',
    );

    await store.clear();

    expect(await secrets.read('fittin.agent.provider.apiKey'), isNull);
    final cleared = await store.load();
    expect(cleared.baseUrl, isEmpty);
    expect(cleared.model, isEmpty);
    expect(cleared.hasApiKey, isFalse);
  });

  test('forced ping test distinguishes chat from tool compatibility', () async {
    final transport = _FakeTransport((request) async* {
      expect(request.toolChoice, {
        'type': 'function',
        'function': {'name': 'ping'},
      });
      yield const AgentTextDelta('I cannot call tools.');
      yield const AgentModelCompleted(finishReason: 'stop');
    });
    final result = await AgentConnectionTester(transport).test(
      config: const AgentProviderConfig(
        baseUrl: 'https://provider.example/v1',
        model: 'model-a',
        hasApiKey: true,
      ),
      apiKey: 'key',
    );

    expect(result.chatCapable, isTrue);
    expect(result.toolCallingSupported, isFalse);
  });

  test(
    'settings controller becomes ready only after a real ping tool call',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final store = PlatformAgentProviderSettingsStore(
        preferences: preferences,
        secretStore: InMemoryAgentSecretStore(),
        isWebOverride: false,
      );
      final transport = _FakeTransport((request) async* {
        yield const AgentToolCallDelta(
          index: 0,
          id: 'call_ping',
          name: 'ping',
          argumentsDelta: '{}',
        );
        yield const AgentModelCompleted(finishReason: 'tool_calls');
      });
      final controller = AgentProviderSettingsController(
        store,
        AgentConnectionTester(transport),
      );
      addTearDown(controller.dispose);

      final result = await controller.testConnection(
        baseUrl: 'https://provider.example/v1',
        model: 'model-a',
        apiKey: 'key',
      );

      expect(result.toolCallingSupported, isTrue);
      expect(controller.state.readiness, AgentProviderReadiness.ready);
      expect(controller.state.config.toolCallingVerified, isTrue);
    },
  );

  test('connection errors never expose the supplied API key', () async {
    final preferences = await SharedPreferences.getInstance();
    final store = PlatformAgentProviderSettingsStore(
      preferences: preferences,
      secretStore: InMemoryAgentSecretStore(),
      isWebOverride: false,
    );
    final transport = _FakeTransport((request) async* {
      throw const AgentTransportException(
        'Bearer super-secret was rejected.',
        code: 'provider_auth_failed',
      );
    });
    final controller = AgentProviderSettingsController(
      store,
      AgentConnectionTester(transport),
    );
    addTearDown(controller.dispose);

    final result = await controller.testConnection(
      baseUrl: 'https://provider.example/v1',
      model: 'model-a',
      apiKey: 'super-secret',
    );

    expect(result.errorMessage, isNot(contains('super-secret')));
    expect(controller.state.errorMessage, contains('[REDACTED]'));
  });

  test('stream failure events are bounded and redact the API key', () async {
    final transport = _FakeTransport((request) async* {
      yield AgentModelFailure(
        code: 'provider_error',
        message: 'key=super-secret ${List.filled(700, 'x').join()}',
      );
    });

    final result = await AgentConnectionTester(transport).test(
      config: const AgentProviderConfig(
        baseUrl: 'https://provider.example/v1',
        model: 'model-a',
        hasApiKey: true,
      ),
      apiKey: 'super-secret',
    );

    expect(result.errorMessage, isNot(contains('super-secret')));
    expect(result.errorMessage, contains('[REDACTED]'));
    expect(result.errorMessage!.length, lessThanOrEqualTo(501));
  });

  test('redaction preserves JSON shape and covers snake-case key names', () {
    expect(
      redactAgentSecrets('{"api_key":"secret"}'),
      '{"api_key":"[REDACTED]"}',
    );
    expect(
      redactAgentSecrets('{"apiKey":"secret"}'),
      '{"apiKey":"[REDACTED]"}',
    );
  });
}

typedef _FakeStream =
    Stream<AgentModelEvent> Function(AgentChatCompletionRequest request);

class _FakeTransport implements AgentModelTransport {
  _FakeTransport(this._stream);

  final _FakeStream _stream;

  @override
  Stream<AgentModelEvent> stream({
    required AgentProviderConfig config,
    required String apiKey,
    required AgentChatCompletionRequest request,
    AgentCancellationToken? cancellationToken,
  }) => _stream(request);

  @override
  void dispose() {}
}
