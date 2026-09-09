import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/application/exercise_library_provider.dart';
import 'package:fittin_v2/src/domain/exercise_library.dart';
import 'package:fittin_v2/src/presentation/screens/free_training_screen.dart';
import '../support/in_memory_database_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ExerciseLibrary library;
  setUpAll(() async => library = await ExerciseLibraryLoader().load());
  for (final size in const [
    Size(320, 568),
    Size(390, 568),
    Size(390, 844),
    Size(390, 926),
    Size(1200, 900),
  ]) {
    for (final locale in [AppLocale.en, AppLocale.zh]) {
      testWidgets('FreeTrainingScreen ${size.width}x${size.height} $locale', (
        tester,
      ) async {
        SharedPreferences.setMockInitialValues({});
        final preferences = await SharedPreferences.getInstance();
        final database = InMemoryDatabaseRepository();
        await database.saveAppLocale(locale);
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseRepositoryProvider.overrideWithValue(database),
              fittinThemePreferencesProvider.overrideWithValue(preferences),
              exerciseLibraryProvider.overrideWith((ref) async => library),
            ],
            child: const MaterialApp(home: FreeTrainingScreen()),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final add = find.byKey(const ValueKey('free-training-add-exercise'));
        await tester.scrollUntilVisible(
          add,
          150,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        expect(tester.getSize(add).height, greaterThanOrEqualTo(44));
        await tester.tap(add);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('exercise-catalog-sheet-frame')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}
