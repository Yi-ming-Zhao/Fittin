import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/sync_provider.dart';
import 'package:fittin_v2/src/application/supabase_bootstrap.dart';
import 'package:fittin_v2/src/application/theme_provider.dart';
import 'package:fittin_v2/src/bootstrap/local_persistence_bundle.dart';
import 'package:fittin_v2/src/bootstrap/local_persistence_factory.dart';
import 'package:fittin_v2/src/data/progress_repository.dart';
import 'package:fittin_v2/src/data/remote/supabase_remote_repository.dart';
import 'package:fittin_v2/src/data/sync/sync_service.dart';
import 'package:fittin_v2/src/data/web_database_repository.dart';
import 'package:fittin_v2/src/data/web_progress_repository.dart';
import 'package:fittin_v2/src/data/web_sync_service.dart';
import 'package:fittin_v2/src/presentation/screens/app_shell_screen.dart';
import 'package:fittin_v2/src/presentation/theme/app_colors.dart';
import 'package:fittin_v2/src/presentation/theme/app_styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final supabaseBootstrap = await initializeSupabase();
  final persistence = await createLocalPersistence();
  await persistence.databaseRepository.ensureDefaultProgramSeeded();

  runApp(
    ProviderScope(
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
        supabaseBootstrapProvider.overrideWithValue(supabaseBootstrap),
      ],
      child: const FittinApp(),
    ),
  );
}

class FittinApp extends ConsumerWidget {
  const FittinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeType = ref.watch(themeProvider);
    final appLocale = ref.watch(appLocaleProvider);
    final colorScheme = AppColors.getThemeScheme(themeType);

    return MaterialApp(
      title: 'Fittin V2',
      locale: appLocale.locale,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        textTheme: AppStyles.getTextTheme(colorScheme),
        scaffoldBackgroundColor: colorScheme.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: colorScheme.onSurface,
        ),
      ),
      home: const SyncLifecycleGate(child: AppShellScreen()),
    );
  }
}
