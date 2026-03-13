import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';

import '../support/in_memory_database_repository.dart';

void main() {
  test('locale preference persists in repository', () async {
    final repository = InMemoryDatabaseRepository();

    expect(await repository.fetchAppLocale(), AppLocale.en);

    await repository.saveAppLocale(AppLocale.zh);

    expect(await repository.fetchAppLocale(), AppLocale.zh);
  });
}
