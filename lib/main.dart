import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/theme_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/models/app_state_collection.dart';
import 'package:fittin_v2/src/data/models/instance_collection.dart';
import 'package:fittin_v2/src/data/models/template_collection.dart';
import 'package:fittin_v2/src/data/models/workout_log_collection.dart';
import 'package:fittin_v2/src/presentation/screens/app_shell_screen.dart';
import 'package:fittin_v2/src/presentation/theme/app_colors.dart';
import 'package:fittin_v2/src/presentation/theme/app_styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDirectory = await getApplicationDocumentsDirectory();

  final isar = await Isar.open([
    AppStateCollectionSchema,
    TemplateCollectionSchema,
    InstanceCollectionSchema,
    WorkoutLogCollectionSchema,
  ], directory: appDirectory.path);
  final repository = DatabaseRepository(isar);
  await repository.ensureDefaultProgramSeeded();

  runApp(
    ProviderScope(
      overrides: [databaseRepositoryProvider.overrideWithValue(repository)],
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
        scaffoldBackgroundColor: colorScheme.background,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: colorScheme.onBackground,
        ),
      ),
      home: const AppShellScreen(),
    );
  }
}
