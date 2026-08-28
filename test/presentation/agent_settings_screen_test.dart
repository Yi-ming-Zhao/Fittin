import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/agent_provider_settings_provider.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/agent_chat_protocol.dart';
import 'package:fittin_v2/src/data/remote/agent_model_transport.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'package:fittin_v2/src/presentation/screens/agent_settings_screen.dart';
import 'package:fittin_v2/src/presentation/screens/profile_settings_screen.dart';

import '../support/in_memory_database_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('provider settings validate, save, mask and clear credentials', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final store = _RecordingSettingsStore();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(
            InMemoryDatabaseRepository(),
          ),
          agentProviderSettingsStoreProvider.overrideWithValue(store),
        ],
        child: const MaterialApp(home: AgentSettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Agent Settings'), findsOneWidget);
    expect(find.text('MODEL PROVIDER'), findsOneWidget);
    expect(find.textContaining('never ordinary preferences'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('agent-base-url-field')),
      'https://example.com/v1',
    );
    await tester.enterText(
      find.byKey(const ValueKey('agent-model-field')),
      'example-model',
    );
    await tester.enterText(
      find.byKey(const ValueKey('agent-api-key-field')),
      'secret-value',
    );

    final save = find.byKey(const ValueKey('agent-save-settings'));
    await tester.scrollUntilVisible(
      save,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(store.key, 'secret-value');
    expect(store.config.baseUrl, 'https://example.com/v1');
    expect(store.config.model, 'example-model');
    expect(find.text('Configuration saved'), findsOneWidget);

    final clear = find.byKey(const ValueKey('agent-clear-settings'));
    await tester.tap(clear);
    await tester.pumpAndSettle();
    expect(store.cleared, isTrue);
    expect(
      tester
          .widget<EditableText>(
            find.descendant(
              of: find.byKey(const ValueKey('agent-api-key-field')),
              matching: find.byType(EditableText),
            ),
          )
          .obscureText,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile exposes Agent settings without revealing API key', (
    tester,
  ) async {
    final store = _RecordingSettingsStore(
      const AgentProviderConfig(
        baseUrl: 'https://example.com/v1',
        model: 'private-model',
        hasApiKey: true,
        toolCallingVerified: true,
      ),
    )..key = 'must-not-appear';

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(
            InMemoryDatabaseRepository(),
          ),
          agentProviderSettingsStoreProvider.overrideWithValue(store),
        ],
        child: const MaterialApp(home: ProfileSettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final entry = find.byKey(const ValueKey('open-agent-settings'));
    await tester.scrollUntilVisible(
      entry,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(entry, findsOneWidget);
    expect(find.textContaining('Ready'), findsOneWidget);
    expect(find.textContaining('must-not-appear'), findsNothing);

    await tester.tap(entry);
    await tester.pumpAndSettle();
    expect(find.byType(AgentSettingsScreen), findsOneWidget);
    expect(find.textContaining('must-not-appear'), findsNothing);
  });

  testWidgets('failed connection test does not claim chat is available', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(
            InMemoryDatabaseRepository(),
          ),
          agentProviderSettingsStoreProvider.overrideWithValue(
            _RecordingSettingsStore(),
          ),
          agentConnectionTesterProvider.overrideWithValue(
            AgentConnectionTester(_FailingTransport()),
          ),
        ],
        child: const MaterialApp(home: AgentSettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('agent-base-url-field')),
      'https://example.com/v1',
    );
    await tester.enterText(
      find.byKey(const ValueKey('agent-model-field')),
      'example-model',
    );
    await tester.enterText(
      find.byKey(const ValueKey('agent-api-key-field')),
      'private-key',
    );
    final testButton = find.byKey(const ValueKey('agent-test-connection'));
    await Scrollable.ensureVisible(
      tester.element(testButton),
      alignment: 0.5,
      duration: Duration.zero,
    );
    await tester.pump();
    await tester.tap(testButton);
    await tester.pumpAndSettle();

    expect(find.text('Provider unavailable.'), findsOneWidget);
    expect(
      find.text('Chat works, but Agent tools are unavailable'),
      findsNothing,
    );
    expect(find.textContaining('private-key'), findsNothing);
  });
}

class _RecordingSettingsStore implements AgentProviderSettingsStore {
  _RecordingSettingsStore([
    this.config = const AgentProviderConfig(baseUrl: '', model: ''),
  ]);

  AgentProviderConfig config;
  String? key;
  bool cleared = false;

  @override
  Future<void> clear() async {
    cleared = true;
    key = null;
    config = const AgentProviderConfig(baseUrl: '', model: '');
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
      hasApiKey: key != null,
      toolCallingVerified: toolCallingVerified,
    );
    return config;
  }
}

class _FailingTransport implements AgentModelTransport {
  @override
  void dispose() {}

  @override
  Stream<AgentModelEvent> stream({
    required AgentProviderConfig config,
    required String apiKey,
    required AgentChatCompletionRequest request,
    AgentCancellationToken? cancellationToken,
  }) async* {
    yield const AgentModelFailure(
      code: 'provider_unavailable',
      message: 'Provider unavailable.',
    );
  }
}
