import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/ui_settings_provider.dart';
import 'package:fittin_v2/src/presentation/screens/profile_settings_screen.dart';
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

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -700));
    await tester.pumpAndSettle();
    final guideButton = find.byKey(const ValueKey('open-set-type-guide'));
    expect(guideButton, findsOneWidget);
    expect(find.text('Training Set Guide'), findsOneWidget);
  });

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
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(traditional);
    await tester.pumpAndSettle();

    expect(
      ProviderScope.containerOf(context).read(workoutRecordingModeProvider),
      WorkoutRecordingMode.traditional,
    );
  });
}
