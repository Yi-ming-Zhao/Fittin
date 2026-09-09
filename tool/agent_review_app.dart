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
import 'package:fittin_v2/src/presentation/screens/free_training_screen.dart';
import 'package:fittin_v2/src/presentation/screens/exercise_library_management_screen.dart';
import 'package:fittin_v2/src/presentation/screens/advanced_analytics_screen.dart';
import 'package:fittin_v2/src/presentation/screens/cardio_screen.dart';
import 'package:fittin_v2/src/presentation/widgets/anatomy_load_map.dart';
import 'package:fittin_v2/src/application/advanced_analytics_provider.dart';
import 'package:fittin_v2/src/domain/exercise_library.dart';
import 'package:fittin_v2/src/presentation/theme/app_styles.dart';
import 'package:fittin_v2/src/presentation/screens/theme_palette_library_screen.dart';
import 'package:fittin_v2/src/presentation/screens/cardio_activity_library_screen.dart';
import 'package:fittin_v2/src/presentation/screens/agent_settings_screen.dart';
import 'package:fittin_v2/src/presentation/screens/about_screen.dart';
import 'package:fittin_v2/src/presentation/screens/plan_editor_screen.dart';
import 'package:fittin_v2/src/presentation/screens/profile_preferences_screen.dart';

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
        appShellTabIndexProvider.overrideWith(
          (ref) => int.tryParse(Uri.base.queryParameters['tab'] ?? '') ?? 2,
        ),
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
        textTheme: AppStyles.getTextTheme(theme.colorScheme),
      ),
      home: switch (Uri.base.queryParameters['screen']) {
        'free' => const FreeTrainingScreen(),
        'library' => const ExerciseLibraryManagementScreen(),
        'advanced' => const AdvancedAnalyticsScreen(),
        'cardio' => const CardioHubScreen(),
        'cardio-library' => const CardioActivityLibraryScreen(),
        'cardio-editor' => const CardioActivityEditorScreen(),
        'exercise-editor' => const CustomExerciseEditorScreen(),
        'palettes' => const ThemePaletteLibraryScreen(),
        'palette-editor' => const CustomPaletteEditorScreen(),
        'agent-settings' => const AgentSettingsScreen(),
        'about' => const AboutScreen(),
        'plan-editor' => const PlanEditorScreen(),
        'preferences' => const ProfilePreferencesScreen(),
        'anatomy' => Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: AnatomyLoadMap(
                overview: MuscleLoadOverview(
                  totalCompletedSets: 48,
                  loads: [
                    for (var i = 0; i < ExerciseMuscle.values.length; i++)
                      MuscleLoadData(
                        muscle: ExerciseMuscle.values[i],
                        weightedCompletedSets: 1 + (i % 5).toDouble(),
                        contributingCompletedSets: 3 + i % 7,
                        normalizedIntensity: (1 + i % 5) / 5,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        _ => const AppShellScreen(),
      },
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
