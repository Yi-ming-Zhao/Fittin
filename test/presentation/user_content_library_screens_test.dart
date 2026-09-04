import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/exercise_library_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/domain/exercise_library.dart';
import 'package:fittin_v2/src/presentation/screens/cardio_activity_library_screen.dart';
import 'package:fittin_v2/src/presentation/screens/exercise_library_management_screen.dart';
import 'package:fittin_v2/src/presentation/screens/theme_palette_library_screen.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/in_memory_database_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ExerciseLibrary exerciseLibrary;

  setUpAll(() async {
    exerciseLibrary = await ExerciseLibraryLoader().load();
  });

  Future<void> pumpScreen(
    WidgetTester tester,
    Widget screen, {
    Size size = const Size(320, 568),
    AppLocale locale = AppLocale.en,
    double textScale = 1,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = InMemoryDatabaseRepository();
    await repository.saveAppLocale(locale);
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(repository),
          exerciseLibraryProvider.overrideWith((ref) async => exerciseLibrary),
          fittinThemePreferencesProvider.overrideWithValue(preferences),
        ],
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: screen,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('exercise library and editor remain usable at 320px', (
    tester,
  ) async {
    await pumpScreen(tester, const ExerciseLibraryManagementScreen());

    expect(find.text('Exercise library'), findsOneWidget);
    expect(find.text('Search name, equipment, muscle, or tag'), findsOneWidget);
    expect(find.byTooltip('New exercise'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('New exercise'));
    await tester.pumpAndSettle();
    expect(find.text('New custom exercise'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cardio library exposes typed built-ins and custom editor', (
    tester,
  ) async {
    await pumpScreen(tester, const CardioActivityLibraryScreen());

    expect(find.text('Cardio activity library'), findsOneWidget);
    expect(find.text('Running'), findsOneWidget);
    expect(find.text('Incline walking'), findsOneWidget);
    expect(find.byTooltip('New activity'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('New activity'));
    await tester.pumpAndSettle();
    expect(find.text('New cardio activity'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('palette library shows all restrained built-ins and editor', (
    tester,
  ) async {
    await pumpScreen(tester, const ThemePaletteLibraryScreen());

    expect(find.text('Palette library'), findsOneWidget);
    expect(find.byTooltip('New palette'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('New palette'));
    await tester.pumpAndSettle();
    expect(find.text('New palette'), findsWidgets);
    expect(find.text('Palette name'), findsOneWidget);
    expect(tester.takeException(), isNull);

    Navigator.of(tester.element(find.byType(CustomPaletteEditorScreen))).pop();
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -360));
    await tester.pumpAndSettle();
    expect(find.text('Obsidian Brass'), findsOneWidget);
    final porcelainLabel = tester.widget<Text>(find.text('Porcelain Ink'));
    expect(
      porcelainLabel.style?.color,
      FittinPaletteRegistry.themeOf(FittinPaletteId.obsidianBrass).fg,
    );
    expect(tester.takeException(), isNull);
  });

  for (final entry in <(String, Widget)>[
    ('exercise library', const ExerciseLibraryManagementScreen()),
    ('cardio library', const CardioActivityLibraryScreen()),
    ('palette library', const ThemePaletteLibraryScreen()),
  ]) {
    testWidgets('${entry.$1} supports large Chinese text at 320px', (
      tester,
    ) async {
      await pumpScreen(tester, entry.$2, locale: AppLocale.zh, textScale: 1.6);

      expect(find.byType(DashboardScreenHeader), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('exercise editor remains reachable above the mobile keyboard', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const ExerciseLibraryManagementScreen(),
      textScale: 1.6,
    );
    await tester.tap(find.byTooltip('New exercise'));
    await tester.pumpAndSettle();
    expect(find.byType(CustomExerciseEditorScreen), findsOneWidget);

    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    addTearDown(tester.view.resetViewInsets);
    await tester.showKeyboard(find.byType(TextFormField).first);
    await tester.pump();

    final save = find.byType(PremiumPrimaryButton);
    final verticalScroll = find
        .descendant(
          of: find.byType(CustomExerciseEditorScreen),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Scrollable &&
                widget.axisDirection == AxisDirection.down,
          ),
        )
        .first;
    for (var attempt = 0; attempt < 20 && save.evaluate().isEmpty; attempt++) {
      await tester.drag(verticalScroll, const Offset(0, -240));
      await tester.pump();
    }
    expect(save, findsOneWidget);
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    final media = MediaQuery.of(
      tester.element(find.byType(CustomExerciseEditorScreen)),
    );
    expect(
      tester.getRect(save).bottom,
      lessThanOrEqualTo(media.size.height - media.viewInsets.bottom),
    );
    expect(tester.takeException(), isNull);
  });
}
