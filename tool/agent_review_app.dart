// Isolated, synthetic-data Web QA entrypoint. Never shipped by lib/main.dart.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/agent_provider_settings_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/data/agent_local_repository.dart';
import 'package:fittin_v2/src/data/agent_local_repository_web.dart';
import 'package:fittin_v2/src/data/progress_repository.dart';
import 'package:fittin_v2/src/data/remote/agent_model_transport.dart';
import 'package:fittin_v2/src/data/web_database_repository.dart';
import 'package:fittin_v2/src/data/web_local_store.dart';
import 'package:fittin_v2/src/data/web_progress_repository.dart';
import 'package:fittin_v2/src/data/seeds/shenshi_five_day_seed.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'package:fittin_v2/src/presentation/app_shell_navigation.dart';
import 'package:fittin_v2/src/presentation/screens/app_shell_screen.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await WebLocalStore.open(
    databaseName: 'fittin_agent_synthetic_qa_v3',
  );
  final database = WebDatabaseRepository(store);
  if (await database.fetchActiveInstance() == null) {
    final plan = await ShenshiFiveDaySeed.loadTemplate();
    await database.saveTemplate(plan, isBuiltIn: true);
    await database.activateTemplate(plan.id);
  }
  final locale = Uri.base.queryParameters['lang'] == 'en'
      ? AppLocale.en
      : AppLocale.zh;
  final palette = FittinPaletteRegistry.decode(
    Uri.base.queryParameters['theme'],
  );
  runApp(
    ProviderScope(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(database),
        progressRepositoryProvider.overrideWithValue(
          WebProgressRepository(store),
        ),
        agentLocalRepositoryProvider.overrideWithValue(
          WebAgentLocalRepository(store),
        ),
        appLocaleProvider.overrideWith(
          (ref) => AppLocaleNotifier(ref, initialLocale: locale),
        ),
        resolvedFittinThemeProvider.overrideWithValue(
          FittinPaletteRegistry.themeOf(palette),
        ),
        appShellTabIndexProvider.overrideWith((ref) => 2),
        agentProviderSettingsStoreProvider.overrideWithValue(
          _ReviewSettingsStore(),
        ),
        agentModelTransportProvider.overrideWithValue(
          WebRelayAgentModelTransport(
            backendBaseUrl: Uri.base.origin,
            accessTokenLoader: () async => 'synthetic-qa-session',
          ),
        ),
      ],
      child: const _ReviewApp(),
    ),
  );
}

class _ReviewApp extends ConsumerWidget {
  const _ReviewApp();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(resolvedFittinThemeProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fittin synthetic QA',
      locale: ref.watch(appLocaleProvider).locale,
      supportedLocales: const [Locale('zh'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: theme.colorScheme,
        scaffoldBackgroundColor: theme.bg,
      ),
      home: const AppShellScreen(),
    );
  }
}

class _ReviewSettingsStore implements AgentProviderSettingsStore {
  AgentProviderConfig config = const AgentProviderConfig(
    baseUrl: 'https://synthetic.provider.invalid/v1',
    model: 'synthetic-openai',
    hasApiKey: true,
    toolCallingVerified: true,
  );
  @override
  Future<AgentProviderConfig> load() async => config;
  @override
  Future<String?> loadApiKey() async =>
      config.hasApiKey ? 'synthetic-qa-key' : null;
  @override
  Future<void> clear() async {
    config = const AgentProviderConfig(baseUrl: '', model: '');
  }

  @override
  Future<AgentProviderConfig> save({
    required String baseUrl,
    required String model,
    String? apiKey,
    bool toolCallingVerified = false,
    int contextWindowTokens = 32768,
    AgentProviderCapabilityProfile? capabilities,
  }) async {
    return config = AgentProviderConfig(
      baseUrl: baseUrl,
      model: model,
      hasApiKey: true,
      toolCallingVerified: toolCallingVerified,
      contextWindowTokens: contextWindowTokens,
      capabilities: capabilities,
    );
  }
}
