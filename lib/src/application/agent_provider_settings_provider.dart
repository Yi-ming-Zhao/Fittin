import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fittin_v2/src/application/agent_chat_protocol.dart';
import 'package:fittin_v2/src/data/remote/agent_model_transport.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';

enum AgentProviderReadiness { unconfigured, incomplete, unverified, ready }

abstract interface class AgentProviderSettingsStore {
  Future<AgentProviderConfig> load();

  Future<String?> loadApiKey();

  Future<AgentProviderConfig> save({
    required String baseUrl,
    required String model,
    String? apiKey,
    bool toolCallingVerified = false,
  });

  Future<void> clear();
}

abstract interface class AgentSecretStore {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);
}

class FlutterAgentSecretStore implements AgentSecretStore {
  FlutterAgentSecretStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
}

class InMemoryAgentSecretStore implements AgentSecretStore {
  String? value;

  @override
  Future<void> delete(String key) async => value = null;

  @override
  Future<String?> read(String key) async => value;

  @override
  Future<void> write(String key, String value) async => this.value = value;
}

/// Persists non-secret settings in preferences and keeps the key in the
/// platform keychain/keystore. Web deliberately keeps the key in process
/// memory so a refresh forgets it.
class PlatformAgentProviderSettingsStore implements AgentProviderSettingsStore {
  PlatformAgentProviderSettingsStore({
    SharedPreferences? preferences,
    AgentSecretStore? secretStore,
    bool? isWebOverride,
    bool? allowDebugLoopbackHttpOverride,
  }) : _preferences = preferences,
       _secretStore = secretStore ?? FlutterAgentSecretStore(),
       _isWeb = isWebOverride ?? kIsWeb,
       _allowDebugLoopbackHttp =
           allowDebugLoopbackHttpOverride ?? (!kIsWeb && !kReleaseMode);

  static const baseUrlPreferenceKey = 'fittin.agent.provider.baseUrl';
  static const modelPreferenceKey = 'fittin.agent.provider.model';
  static const verifiedPreferenceKey = 'fittin.agent.provider.toolVerified';
  static const apiKeySecureStorageKey = 'fittin.agent.provider.apiKey';

  final SharedPreferences? _preferences;
  final AgentSecretStore _secretStore;
  final bool _isWeb;
  final bool _allowDebugLoopbackHttp;
  String? _webApiKey;

  Future<SharedPreferences> _prefs() async =>
      _preferences ?? SharedPreferences.getInstance();

  @override
  Future<AgentProviderConfig> load() async {
    final preferences = await _prefs();
    final key = await loadApiKey();
    return AgentProviderConfig(
      baseUrl: preferences.getString(baseUrlPreferenceKey) ?? '',
      model: preferences.getString(modelPreferenceKey) ?? '',
      hasApiKey: key != null && key.isNotEmpty,
      toolCallingVerified: preferences.getBool(verifiedPreferenceKey) ?? false,
    );
  }

  @override
  Future<String?> loadApiKey() async {
    if (_isWeb) return _webApiKey;
    final value = await _secretStore.read(apiKeySecureStorageKey);
    return value == null || value.trim().isEmpty ? null : value;
  }

  @override
  Future<AgentProviderConfig> save({
    required String baseUrl,
    required String model,
    String? apiKey,
    bool toolCallingVerified = false,
  }) async {
    final normalizedBase = normalizeAgentProviderBaseUrl(
      baseUrl,
      allowDebugLoopbackHttp: _allowDebugLoopbackHttp,
    ).toString();
    final normalizedModel = model.trim();
    if (normalizedModel.isEmpty) {
      throw const FormatException('Enter a model ID.');
    }

    final preferences = await _prefs();
    var storedKey = await loadApiKey();
    final replacementKey = apiKey?.trim();
    if (replacementKey != null && replacementKey.isNotEmpty) {
      if (_isWeb) {
        _webApiKey = replacementKey;
      } else {
        await _secretStore.write(apiKeySecureStorageKey, replacementKey);
      }
      storedKey = replacementKey;
    }

    await preferences.setString(baseUrlPreferenceKey, normalizedBase);
    await preferences.setString(modelPreferenceKey, normalizedModel);
    await preferences.setBool(verifiedPreferenceKey, toolCallingVerified);
    return AgentProviderConfig(
      baseUrl: normalizedBase,
      model: normalizedModel,
      hasApiKey: storedKey != null && storedKey.isNotEmpty,
      toolCallingVerified: toolCallingVerified,
    );
  }

  @override
  Future<void> clear() async {
    final preferences = await _prefs();
    if (_isWeb) {
      _webApiKey = null;
    } else {
      await _secretStore.delete(apiKeySecureStorageKey);
    }
    await preferences.remove(baseUrlPreferenceKey);
    await preferences.remove(modelPreferenceKey);
    await preferences.remove(verifiedPreferenceKey);
  }
}

class AgentConnectionTestResult {
  const AgentConnectionTestResult({
    required this.chatCapable,
    required this.toolCallingSupported,
    this.errorMessage,
  });

  const AgentConnectionTestResult.failed(this.errorMessage)
    : chatCapable = false,
      toolCallingSupported = false;

  final bool chatCapable;
  final bool toolCallingSupported;
  final String? errorMessage;

  bool get succeeded => chatCapable && errorMessage == null;
}

class AgentConnectionTester {
  const AgentConnectionTester(this._transport);

  final AgentModelTransport _transport;

  Future<AgentConnectionTestResult> test({
    required AgentProviderConfig config,
    required String apiKey,
    AgentCancellationToken? cancellationToken,
  }) async {
    var receivedValidEvent = false;
    final toolNames = <int, String>{};
    await for (final event in _transport.stream(
      config: config,
      apiKey: apiKey,
      cancellationToken: cancellationToken,
      request: AgentChatCompletionRequest(
        model: config.model,
        messages: const [
          AgentChatMessagePayload(
            role: 'system',
            content: 'Call the required ping function exactly once.',
          ),
          AgentChatMessagePayload(role: 'user', content: 'Ping.'),
        ],
        tools: const [
          AgentChatToolDefinition(
            name: 'ping',
            description: 'Verifies that function calling is available.',
            parameters: {
              'type': 'object',
              'properties': <String, dynamic>{},
              'additionalProperties': false,
            },
          ),
        ],
        toolChoice: const {
          'type': 'function',
          'function': {'name': 'ping'},
        },
      ),
    )) {
      if (event is AgentModelFailure) {
        return AgentConnectionTestResult.failed(
          _boundedSettingsMessage(
            redactAgentSecrets(event.message, secrets: [apiKey]),
          ),
        );
      }
      receivedValidEvent = true;
      if (event is AgentToolCallDelta && event.name != null) {
        toolNames[event.index] = '${toolNames[event.index] ?? ''}${event.name}';
      }
    }
    final supportsTools = toolNames.values.any((name) => name == 'ping');
    return AgentConnectionTestResult(
      chatCapable: receivedValidEvent,
      toolCallingSupported: supportsTools,
      errorMessage: receivedValidEvent
          ? null
          : 'The provider returned no completion events.',
    );
  }
}

class AgentProviderSettingsState {
  const AgentProviderSettingsState({
    this.config = const AgentProviderConfig(baseUrl: '', model: ''),
    this.isLoading = true,
    this.isSaving = false,
    this.isTesting = false,
    this.lastTest,
    this.errorMessage,
  });

  final AgentProviderConfig config;
  final bool isLoading;
  final bool isSaving;
  final bool isTesting;
  final AgentConnectionTestResult? lastTest;
  final String? errorMessage;

  AgentProviderReadiness get readiness {
    if (config.baseUrl.isEmpty && config.model.isEmpty && !config.hasApiKey) {
      return AgentProviderReadiness.unconfigured;
    }
    if (!config.isReady) return AgentProviderReadiness.incomplete;
    return config.toolCallingVerified
        ? AgentProviderReadiness.ready
        : AgentProviderReadiness.unverified;
  }

  bool get isReady => readiness == AgentProviderReadiness.ready;

  AgentProviderSettingsState copyWith({
    AgentProviderConfig? config,
    bool? isLoading,
    bool? isSaving,
    bool? isTesting,
    AgentConnectionTestResult? lastTest,
    String? errorMessage,
    bool clearLastTest = false,
    bool clearError = false,
  }) => AgentProviderSettingsState(
    config: config ?? this.config,
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
    isTesting: isTesting ?? this.isTesting,
    lastTest: clearLastTest ? null : lastTest ?? this.lastTest,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}

class AgentProviderSettingsController
    extends StateNotifier<AgentProviderSettingsState> {
  AgentProviderSettingsController(this._store, this._tester)
    : super(const AgentProviderSettingsState()) {
    _initialLoad = _load();
  }

  final AgentProviderSettingsStore _store;
  final AgentConnectionTester _tester;
  late final Future<void> _initialLoad;

  Future<void> get initialized => _initialLoad;

  Future<void> _load() async {
    try {
      final config = await _store.load();
      if (mounted) {
        state = state.copyWith(
          config: config,
          isLoading: false,
          clearError: true,
        );
      }
    } catch (error) {
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _settingsError(error),
        );
      }
    }
  }

  Future<bool> save({
    required String baseUrl,
    required String model,
    String? apiKey,
  }) async {
    await _initialLoad;
    state = state.copyWith(
      isSaving: true,
      clearError: true,
      clearLastTest: true,
    );
    try {
      final config = await _store.save(
        baseUrl: baseUrl,
        model: model,
        apiKey: apiKey,
      );
      if (mounted) {
        state = state.copyWith(config: config, isSaving: false);
      }
      return true;
    } catch (error) {
      if (mounted) {
        state = state.copyWith(
          isSaving: false,
          errorMessage: _settingsError(error, apiKey: apiKey),
        );
      }
      return false;
    }
  }

  Future<void> clear() async {
    await _initialLoad;
    try {
      await _store.clear();
      if (mounted) {
        state = const AgentProviderSettingsState(isLoading: false);
      }
    } catch (error) {
      if (mounted) state = state.copyWith(errorMessage: _settingsError(error));
    }
  }

  Future<AgentConnectionTestResult> testConnection({
    String? baseUrl,
    String? model,
    String? apiKey,
    AgentCancellationToken? cancellationToken,
  }) async {
    await _initialLoad;
    state = state.copyWith(
      isTesting: true,
      clearError: true,
      clearLastTest: true,
    );
    final candidateKey = apiKey?.trim().isNotEmpty == true
        ? apiKey!.trim()
        : await _store.loadApiKey();
    try {
      if (candidateKey == null || candidateKey.isEmpty) {
        throw const FormatException('Enter an API key.');
      }
      final candidate = AgentProviderConfig(
        baseUrl: normalizeAgentProviderBaseUrl(
          baseUrl ?? state.config.baseUrl,
          allowDebugLoopbackHttp: !kIsWeb && !kReleaseMode,
        ).toString(),
        model: (model ?? state.config.model).trim(),
        hasApiKey: true,
      );
      if (candidate.model.isEmpty) {
        throw const FormatException('Enter a model ID.');
      }

      final result = await _tester.test(
        config: candidate,
        apiKey: candidateKey,
        cancellationToken: cancellationToken,
      );
      final saved = await _store.save(
        baseUrl: candidate.baseUrl,
        model: candidate.model,
        apiKey: candidateKey,
        toolCallingVerified: result.toolCallingSupported,
      );
      if (mounted) {
        state = state.copyWith(
          config: saved,
          isTesting: false,
          lastTest: result,
          errorMessage: result.errorMessage,
          clearError: result.errorMessage == null,
        );
      }
      return result;
    } catch (error) {
      final message = _settingsError(error, apiKey: candidateKey);
      final result = AgentConnectionTestResult.failed(message);
      if (mounted) {
        state = state.copyWith(
          isTesting: false,
          lastTest: result,
          errorMessage: message,
        );
      }
      return result;
    }
  }
}

String _settingsError(Object error, {String? apiKey}) {
  final raw = switch (error) {
    FormatException(:final message) => message,
    AgentTransportException(:final message) => message,
    _ => 'Unable to update Agent provider settings.',
  };
  return _boundedSettingsMessage(
    redactAgentSecrets(raw, secrets: [if (apiKey != null) apiKey]),
  );
}

String _boundedSettingsMessage(String value) {
  final normalized = value.replaceAll(RegExp(r'[\r\n\t]+'), ' ').trim();
  if (normalized.isEmpty) return 'The provider connection test failed.';
  return normalized.length <= 500
      ? normalized
      : '${normalized.substring(0, 500)}…';
}

final agentProviderSettingsStoreProvider = Provider<AgentProviderSettingsStore>(
  (ref) {
    return PlatformAgentProviderSettingsStore();
  },
);

final agentConnectionTesterProvider = Provider<AgentConnectionTester>((ref) {
  return AgentConnectionTester(ref.watch(agentModelTransportProvider));
});

final agentProviderSettingsControllerProvider =
    StateNotifierProvider<
      AgentProviderSettingsController,
      AgentProviderSettingsState
    >((ref) {
      return AgentProviderSettingsController(
        ref.watch(agentProviderSettingsStoreProvider),
        ref.watch(agentConnectionTesterProvider),
      );
    });
