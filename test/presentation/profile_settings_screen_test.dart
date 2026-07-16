import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/application/ui_settings_provider.dart';
import 'package:fittin_v2/src/presentation/screens/about_screen.dart';
import 'package:fittin_v2/src/presentation/screens/profile_settings_screen.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/in_memory_database_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('profile settings screen reflects locale changes to Chinese', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryDatabaseRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: ProfileSettingsScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(
      find.text('Account, language, weight tools, and interface preferences.'),
      findsOneWidget,
    );
    expect(find.text('English interface'), findsOneWidget);

    final cardMode = find.byKey(const ValueKey('recording-mode-card'));
    await tester.scrollUntilVisible(
      cardMode,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Card logger'), findsOneWidget);
    expect(find.text('卡片记录'), findsNothing);

    await ProviderScope.containerOf(
      tester.element(find.byType(ProfileSettingsScreen)),
    ).read(appLocaleProvider.notifier).setLocale(AppLocale.zh);
    await tester.pumpAndSettle();

    expect(
      ProviderScope.containerOf(
        tester.element(find.byType(ProfileSettingsScreen)),
      ).read(appLocaleProvider),
      AppLocale.zh,
    );
    expect(find.text('卡片记录'), findsOneWidget);
    expect(find.text('Card logger'), findsNothing);
  });

  testWidgets('profile settings exposes the set type guide entry', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryDatabaseRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: ProfileSettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final guideButton = find.byKey(const ValueKey('open-set-type-guide'));
    await tester.scrollUntilVisible(
      guideButton,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(guideButton, findsOneWidget);
    expect(find.text('Training Set Guide'), findsOneWidget);
  });

  testWidgets('appearance section localizes its complete theme description', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = InMemoryDatabaseRepository();
    final semantics = tester.ensureSemantics();
    await tester.binding.setSurfaceSize(const Size(390, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(repository),
          fittinThemePreferencesProvider.overrideWithValue(preferences),
        ],
        child: const MaterialApp(home: ProfileSettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final appearanceHeading = find.text('APPEARANCE');
    await tester.scrollUntilVisible(
      appearanceHeading,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(
      find.text(
        'One complete theme updates backgrounds, cards, text, lines, charts, and interaction feedback together.',
      ),
      findsOneWidget,
    );
    expect(find.text('Current appearance: Obsidian Brass'), findsOneWidget);
    expect(
      find.text('Swipe horizontally to compare all five palettes.'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Obsidian Brass theme preview, selected'),
      findsOneWidget,
    );

    await ProviderScope.containerOf(
      tester.element(find.byType(ProfileSettingsScreen)),
    ).read(appLocaleProvider.notifier).setLocale(AppLocale.zh);
    await tester.pumpAndSettle();

    expect(find.text('外观'), findsOneWidget);
    expect(find.text('一套完整主题会同时更新背景、卡片、文字、线条、图表和操作反馈。'), findsOneWidget);
    expect(find.text('当前外观：黑曜黄铜'), findsOneWidget);
    expect(find.text('横向滑动比较全部 5 套配色。'), findsOneWidget);
    expect(find.bySemanticsLabel('黑曜黄铜 主题预览，已选择'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets(
    'all appearance previews are reachable and select live at 390px',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = InMemoryDatabaseRepository();
      final semantics = tester.ensureSemantics();
      await tester.binding.setSurfaceSize(const Size(390, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseRepositoryProvider.overrideWithValue(repository),
            fittinThemePreferencesProvider.overrideWithValue(preferences),
          ],
          child: const MaterialApp(home: ProfileSettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final paletteList = find.byKey(const ValueKey('appearance-palette-list'));
      await tester.scrollUntilVisible(
        paletteList,
        220,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      final horizontalScrollable = find.descendant(
        of: paletteList,
        matching: find.byType(Scrollable),
      );

      for (final paletteId in FittinPaletteRegistry.ids) {
        final preview = find.byKey(
          ValueKey('appearance-palette-${paletteId.storageKey}'),
        );
        await tester.scrollUntilVisible(
          preview,
          180,
          scrollable: horizontalScrollable,
          maxScrolls: 10,
        );
        await tester.pumpAndSettle();

        final rect = tester.getRect(preview);
        expect(rect.width, greaterThanOrEqualTo(48));
        expect(rect.height, greaterThanOrEqualTo(48));
        expect(rect.left, greaterThanOrEqualTo(0));
        expect(rect.right, lessThanOrEqualTo(390));
      }

      final context = tester.element(find.byType(ProfileSettingsScreen));
      final container = ProviderScope.containerOf(context);
      final before = container.read(resolvedFittinThemeProvider);
      final espresso = find.byKey(
        ValueKey(
          'appearance-palette-${FittinPaletteId.espressoEmber.storageKey}',
        ),
      );
      await tester.tap(espresso);
      await tester.pumpAndSettle();

      expect(
        container.read(fittinThemeProvider),
        FittinPaletteId.espressoEmber,
      );
      expect(
        container.read(resolvedFittinThemeProvider).accent,
        isNot(before.accent),
      );
      expect(find.text('Current appearance: Espresso Ember'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Espresso Ember theme preview, selected'),
        findsOneWidget,
      );
      expect(
        tester
            .getSemantics(espresso)
            .getSemanticsData()
            .flagsCollection
            .isSelected,
        isTrue,
      );
      semantics.dispose();
    },
  );

  testWidgets('profile settings opens the account screen', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryDatabaseRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: ProfileSettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final accountButton = find.byKey(const ValueKey('open-account-screen'));
    await tester.tap(accountButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byType(ProfileSettingsScreen), findsNothing);
    expect(find.text('Backend Not Configured'), findsOneWidget);
    expect(find.byKey(const ValueKey('dashboard-header-back')), findsOneWidget);
  });

  testWidgets(
    'profile settings root screen does not show a dashboard back button',
    (WidgetTester tester) async {
      final repository = InMemoryDatabaseRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseRepositoryProvider.overrideWithValue(repository)],
          child: const MaterialApp(home: ProfileSettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('dashboard-header-back')), findsNothing);
    },
  );

  testWidgets(
    'profile settings opens profile preferences and saves display name',
    (WidgetTester tester) async {
      final repository = InMemoryDatabaseRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseRepositoryProvider.overrideWithValue(repository)],
          child: const MaterialApp(home: ProfileSettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final profileButton = find.byKey(
        const ValueKey('open-profile-preferences'),
      );
      await tester.scrollUntilVisible(
        profileButton,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(profileButton.first);
      await tester.pumpAndSettle();
      await tester.tap(profileButton.first);
      await tester.pumpAndSettle();

      expect(find.text('Profile Preferences'), findsOneWidget);

      final displayNameField = find.byKey(
        const ValueKey('profile-display-name-field'),
      );
      await tester.scrollUntilVisible(
        displayNameField,
        220,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(displayNameField, 'Alex');
      await tester.tap(find.byKey(const ValueKey('save-profile-display-name')));
      await tester.pumpAndSettle();

      expect(await repository.fetchHomeDisplayName(), 'Alex');
    },
  );

  testWidgets('profile settings changes the workout recording mode', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final repository = InMemoryDatabaseRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: ProfileSettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(ProfileSettingsScreen));
    expect(
      ProviderScope.containerOf(context).read(workoutRecordingModeProvider),
      WorkoutRecordingMode.card,
    );

    final traditional = find.byKey(
      const ValueKey('recording-mode-traditional'),
    );
    await tester.scrollUntilVisible(
      traditional,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(traditional);
    await tester.pumpAndSettle();
    await tester.tap(traditional);
    await tester.pumpAndSettle();

    expect(
      ProviderScope.containerOf(context).read(workoutRecordingModeProvider),
      WorkoutRecordingMode.traditional,
    );
  });

  testWidgets('profile settings exposes the about entry', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryDatabaseRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: ProfileSettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final aboutButton = find.byKey(const ValueKey('open-about-screen'));
    await tester.scrollUntilVisible(
      aboutButton,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(aboutButton, findsOneWidget);
    expect(find.text('ABOUT'), findsOneWidget);
    expect(find.text('About Fittin'), findsOneWidget);
  });

  testWidgets('profile settings opens the about screen', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryDatabaseRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: ProfileSettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final aboutButton = find.byKey(const ValueKey('open-about-screen'));
    await tester.scrollUntilVisible(
      aboutButton,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(aboutButton);
    await tester.pumpAndSettle();
    await tester.tap(aboutButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(AboutScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('dashboard-header-back')), findsOneWidget);
  });
}
