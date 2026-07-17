import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/auth_session_store.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/application/sync_provider.dart';
import 'package:fittin_v2/src/application/supabase_bootstrap.dart';
import 'package:fittin_v2/src/application/ui_settings_provider.dart';
import 'package:fittin_v2/src/bootstrap/local_persistence_factory.dart';
import 'package:fittin_v2/src/bootstrap/local_persistence_bundle.dart';
import 'package:fittin_v2/src/data/progress_repository.dart';
import 'package:fittin_v2/src/data/remote/supabase_remote_repository.dart';
import 'package:fittin_v2/src/data/sync/sync_service.dart';
import 'package:fittin_v2/src/data/web_database_repository.dart';
import 'package:fittin_v2/src/data/web_progress_repository.dart';
import 'package:fittin_v2/src/data/web_sync_service.dart';
import 'package:fittin_v2/src/presentation/screens/app_shell_screen.dart';
import 'package:fittin_v2/src/presentation/screens/app_startup_gate.dart';
import 'package:fittin_v2/src/presentation/screens/startup_splash_screen.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/theme/app_styles.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences? preferences;
  try {
    preferences = await SharedPreferences.getInstance();
  } catch (_) {
    // The themed recovery screen remains available if preferences fail again.
  }
  runApp(FittinBootstrapHost(initialPreferences: preferences));
}

class _FittinBootstrapDependencies {
  const _FittinBootstrapDependencies({
    required this.supabaseBootstrap,
    required this.preferences,
    required this.persistence,
    required this.initialLocale,
    required this.initialRecordingMode,
  });

  final SupabaseBootstrapState supabaseBootstrap;
  final SharedPreferences preferences;
  final LocalPersistenceBundle persistence;
  final AppLocale initialLocale;
  final WorkoutRecordingMode initialRecordingMode;
}

Future<_FittinBootstrapDependencies> _initializeApp({
  SharedPreferences? initialPreferences,
  ValueChanged<SharedPreferences>? onPreferencesReady,
  ValueChanged<AppLocale>? onLocaleReady,
}) async {
  final preferences =
      initialPreferences ?? await SharedPreferences.getInstance();
  onPreferencesReady?.call(preferences);
  final persistence = await createLocalPersistence();
  final initialLocale = await persistence.databaseRepository.fetchAppLocale();
  await preferences.setString(AppLocaleNotifier.storageKey, initialLocale.code);
  onLocaleReady?.call(initialLocale);
  await persistence.databaseRepository.ensureDefaultProgramSeeded();
  final supabaseBootstrap = await initializeSupabase();
  final storedRecordingMode = preferences.getString(
    WorkoutRecordingModeNotifier.storageKey,
  );
  final initialRecordingMode =
      storedRecordingMode == WorkoutRecordingMode.traditional.name
      ? WorkoutRecordingMode.traditional
      : WorkoutRecordingMode.card;

  return _FittinBootstrapDependencies(
    supabaseBootstrap: supabaseBootstrap,
    preferences: preferences,
    persistence: persistence,
    initialLocale: initialLocale,
    initialRecordingMode: initialRecordingMode,
  );
}

class FittinBootstrapHost extends StatefulWidget {
  const FittinBootstrapHost({super.key, this.initialPreferences});

  final SharedPreferences? initialPreferences;

  @override
  State<FittinBootstrapHost> createState() => _FittinBootstrapHostState();
}

class _FittinBootstrapHostState extends State<FittinBootstrapHost> {
  late Future<_FittinBootstrapDependencies> _initialization;
  late FittinPaletteId _launchPalette;
  late AppLocale _launchLocale;

  @override
  void initState() {
    super.initState();
    _launchPalette = FittinPaletteRegistry.decode(
      widget.initialPreferences?.getString(FittinThemeNotifier.preferencesKey),
    );
    final storedLocale = widget.initialPreferences?.getString(
      AppLocaleNotifier.storageKey,
    );
    _launchLocale = storedLocale == null
        ? (WidgetsBinding.instance.platformDispatcher.locale.languageCode ==
                  'zh'
              ? AppLocale.zh
              : AppLocale.en)
        : AppLocaleX.fromCode(storedLocale);
    _initialization = _startInitialization();
  }

  Future<_FittinBootstrapDependencies> _startInitialization() {
    return _initializeApp(
      initialPreferences: widget.initialPreferences,
      onPreferencesReady: (preferences) {
        if (!mounted) return;
        final palette = FittinPaletteRegistry.decode(
          preferences.getString(FittinThemeNotifier.preferencesKey),
        );
        if (palette != _launchPalette) {
          setState(() => _launchPalette = palette);
        }
      },
      onLocaleReady: (locale) {
        if (mounted && locale != _launchLocale) {
          setState(() => _launchLocale = locale);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_FittinBootstrapDependencies>(
      future: _initialization,
      builder: (context, snapshot) {
        final dependencies = snapshot.data;
        if (dependencies != null) {
          return _buildReadyApp(dependencies);
        }

        final theme = FittinPaletteRegistry.themeOf(_launchPalette);
        final strings = AppStrings.fromLocale(_launchLocale);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: theme.colorScheme,
            textTheme: AppStyles.getTextTheme(theme.colorScheme),
            scaffoldBackgroundColor: theme.bg,
          ),
          home: StartupSplashScreen(
            theme: theme,
            strings: strings,
            hasError: snapshot.hasError,
            onRetry: snapshot.hasError
                ? () => setState(() => _initialization = _startInitialization())
                : null,
          ),
        );
      },
    );
  }

  Widget _buildReadyApp(_FittinBootstrapDependencies dependencies) {
    final persistence = dependencies.persistence;

    return ProviderScope(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(
          persistence.databaseRepository,
        ),
        progressRepositoryProvider.overrideWithValue(
          persistence.progressRepository,
        ),
        if (persistence.webDatabaseRepository != null &&
            persistence.webProgressRepository != null)
          syncServiceProvider.overrideWith((ref) {
            return WebSyncService(
              databaseRepository:
                  persistence.webDatabaseRepository! as WebDatabaseRepository,
              progressRepository:
                  persistence.webProgressRepository! as WebProgressRepository,
              remoteRepository: ref.watch(supabaseRemoteRepositoryProvider),
              ownerUserId: ref.watch(currentUserIdProvider),
            );
          }),
        authSessionStoreProvider.overrideWithValue(
          SharedPreferencesAuthSessionStore(dependencies.preferences),
        ),
        fittinThemePreferencesProvider.overrideWithValue(
          dependencies.preferences,
        ),
        supabaseBootstrapProvider.overrideWithValue(
          dependencies.supabaseBootstrap,
        ),
        appLocaleProvider.overrideWith(
          (ref) => AppLocaleNotifier(
            ref,
            initialLocale: dependencies.initialLocale,
            preferences: dependencies.preferences,
          ),
        ),
        workoutRecordingModeProvider.overrideWith(
          (ref) => WorkoutRecordingModeNotifier(
            initialMode: dependencies.initialRecordingMode,
            loadPersisted: false,
          ),
        ),
      ],
      child: const FittinApp(),
    );
  }
}

class FittinApp extends ConsumerWidget {
  const FittinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fittinTheme = ref.watch(resolvedFittinThemeProvider);
    final appLocale = ref.watch(appLocaleProvider);
    final colorScheme = fittinTheme.colorScheme;

    return MaterialApp(
      title: 'Fittin V2',
      debugShowCheckedModeBanner: false,
      themeAnimationDuration: Duration.zero,
      locale: appLocale.locale,
      supportedLocales: const [Locale('en'), Locale('zh')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        textTheme: AppStyles.getTextTheme(colorScheme),
        scaffoldBackgroundColor: fittinTheme.bg,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: colorScheme.onSurface,
        ),
      ),
      home: const AppStartupGate(
        child: SyncLifecycleGate(
          performInitialSync: false,
          child: AppShellScreen(),
        ),
      ),
    );
  }
}
