import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/in_memory_database_repository.dart';

void main() {
  test('locale preference persists in repository', () async {
    final repository = InMemoryDatabaseRepository();

    expect(await repository.fetchAppLocale(), AppLocale.en);

    await repository.saveAppLocale(AppLocale.zh);

    expect(await repository.fetchAppLocale(), AppLocale.zh);
  });

  test('locale changes also persist for the earliest launch frame', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = InMemoryDatabaseRepository();
    final container = ProviderContainer(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(repository),
        appLocaleProvider.overrideWith(
          (ref) => AppLocaleNotifier(
            ref,
            initialLocale: AppLocale.en,
            preferences: preferences,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(appLocaleProvider.notifier).setLocale(AppLocale.zh);

    expect(
      preferences.getString(AppLocaleNotifier.storageKey),
      AppLocale.zh.code,
    );
    expect(await repository.fetchAppLocale(), AppLocale.zh);
  });
}
