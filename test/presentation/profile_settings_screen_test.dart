import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/application/ui_settings_provider.dart';
import 'package:fittin_v2/src/presentation/screens/profile_hub_screen.dart';
import 'package:fittin_v2/src/presentation/screens/profile_preferences_screen.dart';
import 'package:fittin_v2/src/presentation/screens/profile_settings_screen.dart';
import 'package:fittin_v2/src/presentation/screens/set_type_guide_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/in_memory_database_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpProfile(
    WidgetTester tester, {
    Size size = const Size(390, 568),
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
          fittinThemePreferencesProvider.overrideWithValue(preferences),
        ],
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: const ProfileSettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('profile root is a compact six-category information hub', (
    tester,
  ) async {
    await pumpProfile(tester);

    expect(find.text('My Fittin'), findsOneWidget);
    expect(find.byKey(const ValueKey('profile-category-account')), findsOne);
    expect(find.byKey(const ValueKey('profile-category-training')), findsOne);
    expect(find.byKey(const ValueKey('profile-category-appearance')), findsOne);
    expect(find.byKey(const ValueKey('profile-category-agent')), findsOne);
    expect(find.byKey(const ValueKey('profile-category-privacy')), findsOne);
    expect(find.byKey(const ValueKey('profile-category-about')), findsOne);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile hub remains usable in Chinese with large text', (
    tester,
  ) async {
    await pumpProfile(
      tester,
      size: const Size(320, 568),
      locale: AppLocale.zh,
      textScale: 1.6,
    );

    expect(find.text('我的'), findsWidgets);
    final about = find.byKey(const ValueKey('profile-category-about'));
    await tester.scrollUntilVisible(about, 220);
    expect(about, findsOneWidget);
    for (final key in const [
      'profile-category-account',
      'profile-category-training',
      'profile-category-appearance',
      'profile-category-agent',
      'profile-category-privacy',
      'profile-category-about',
    ]) {
      expect(
        tester.getSize(find.byKey(ValueKey(key))).height,
        greaterThanOrEqualTo(44),
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('appearance details contain language, palettes and visuals', (
    tester,
  ) async {
    await pumpProfile(tester, size: const Size(390, 844));
    await tester.tap(find.byKey(const ValueKey('profile-category-appearance')));
    await tester.pumpAndSettle();

    expect(find.byType(AppearanceSettingsScreen), findsOneWidget);
    expect(find.text('Appearance & language'), findsOneWidget);
    expect(find.byKey(const ValueKey('locale-en')), findsOneWidget);
    expect(find.byKey(const ValueKey('locale-zh')), findsOneWidget);
    expect(find.text('Current appearance: Obsidian Brass'), findsOneWidget);

    await ProviderScope.containerOf(
      tester.element(find.byType(AppearanceSettingsScreen)),
    ).read(appLocaleProvider.notifier).setLocale(AppLocale.zh);
    await tester.pumpAndSettle();
    expect(find.text('外观与语言'), findsOneWidget);
    expect(find.text('当前外观：黑曜黄铜'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('training details group logger and both editable libraries', (
    tester,
  ) async {
    await pumpProfile(tester, size: const Size(320, 568));
    await tester.tap(find.byKey(const ValueKey('profile-category-training')));
    await tester.pumpAndSettle();

    expect(find.byType(TrainingSettingsScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('recording-mode-card')), findsOneWidget);
    final exercise = find.byKey(const ValueKey('open-exercise-library'));
    await tester.scrollUntilVisible(exercise, 220);
    expect(exercise, findsOneWidget);
    expect(find.byKey(const ValueKey('open-cardio-library')), findsOneWidget);

    final context = tester.element(find.byType(TrainingSettingsScreen));
    expect(
      ProviderScope.containerOf(context).read(workoutRecordingModeProvider),
      WorkoutRecordingMode.card,
    );
    await tester.tap(find.byKey(const ValueKey('recording-mode-traditional')));
    await tester.pumpAndSettle();
    expect(
      ProviderScope.containerOf(context).read(workoutRecordingModeProvider),
      WorkoutRecordingMode.traditional,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('account category opens account and profile choices', (
    tester,
  ) async {
    await pumpProfile(tester);
    await tester.tap(find.byKey(const ValueKey('profile-category-account')));
    await tester.pumpAndSettle();

    expect(find.byType(AccountAndProfileScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('open-account-screen')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('open-profile-preferences')),
      findsOneWidget,
    );
  });

  testWidgets('profile preference actions stack at 320px with large text', (
    tester,
  ) async {
    await pumpProfile(
      tester,
      size: const Size(320, 568),
      locale: AppLocale.zh,
      textScale: 1.6,
    );
    await tester.tap(find.byKey(const ValueKey('profile-category-account')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('open-profile-preferences')));
    await tester.pumpAndSettle();

    expect(find.byType(ProfilePreferencesScreen), findsOneWidget);
    expect(
      find.byKey(const ValueKey('profile-preference-actions-stacked')),
      findsOneWidget,
    );
    final save = tester.getRect(
      find.byKey(const ValueKey('save-profile-display-name')),
    );
    final clear = tester.getRect(
      find.byKey(const ValueKey('clear-profile-display-name')),
    );
    expect(clear.top, greaterThan(save.bottom));
    expect(save.height, greaterThanOrEqualTo(44));
    expect(clear.height, greaterThanOrEqualTo(44));
    expect(tester.takeException(), isNull);
  });

  testWidgets('deep set-type guide remains reachable at 320px large Chinese', (
    tester,
  ) async {
    await pumpProfile(
      tester,
      size: const Size(320, 568),
      locale: AppLocale.zh,
      textScale: 1.6,
    );
    await tester.tap(find.byKey(const ValueKey('profile-category-training')));
    await tester.pumpAndSettle();

    final guideLink = find.byKey(const ValueKey('open-set-type-guide'));
    final trainingScroll = find
        .descendant(
          of: find.byType(TrainingSettingsScreen),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Scrollable &&
                widget.axisDirection == AxisDirection.down,
          ),
        )
        .first;
    await tester.scrollUntilVisible(guideLink, 180, scrollable: trainingScroll);
    await tester.tap(guideLink);
    await tester.pumpAndSettle();

    expect(find.byType(SetTypeGuideScreen), findsOneWidget);
    final pageScroll = find.byKey(const ValueKey('dashboard-page-scroll'));
    expect(pageScroll, findsOneWidget);
    expect(
      tester
          .state<ScrollableState>(
            find
                .descendant(of: pageScroll, matching: find.byType(Scrollable))
                .first,
          )
          .position
          .maxScrollExtent,
      greaterThan(0),
    );
    expect(tester.takeException(), isNull);
  });
}
