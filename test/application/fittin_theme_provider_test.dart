import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('palette update is immediate and persists its stable key', () async {
    final preferences = await SharedPreferences.getInstance();
    final notifier = FittinThemeNotifier(preferences: preferences);

    final persistence = notifier.setPalette(FittinPaletteId.bordeauxVelvet);

    expect(notifier.state, FittinPaletteId.bordeauxVelvet);
    await persistence;
    expect(
      preferences.getString(FittinThemeNotifier.preferencesKey),
      'bordeauxVelvet',
    );
  });

  test(
    'valid palette is restored synchronously on simulated restart',
    () async {
      SharedPreferences.setMockInitialValues({
        FittinThemeNotifier.preferencesKey: 'midnightCobalt',
      });
      final preferences = await SharedPreferences.getInstance();

      final firstLaunch = FittinThemeNotifier(preferences: preferences);
      expect(firstLaunch.state, FittinPaletteId.midnightCobalt);

      await firstLaunch.setPalette(FittinPaletteId.espressoEmber);
      final restarted = FittinThemeNotifier(preferences: preferences);
      expect(restarted.state, FittinPaletteId.espressoEmber);
    },
  );

  test('unknown stored value falls back to Obsidian Brass', () async {
    SharedPreferences.setMockInitialValues({
      FittinThemeNotifier.preferencesKey: 'future-palette-that-does-not-exist',
    });
    final preferences = await SharedPreferences.getInstance();

    final notifier = FittinThemeNotifier(preferences: preferences);

    expect(notifier.state, FittinPaletteId.obsidianBrass);
  });

  test(
    'provider and resolved theme update from the same palette state',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          fittinThemePreferencesProvider.overrideWithValue(preferences),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(resolvedFittinThemeProvider).paletteId,
        FittinPaletteId.obsidianBrass,
      );

      final persistence = container
          .read(fittinThemeProvider.notifier)
          .setPalette(FittinPaletteId.porcelainInk);

      expect(
        container.read(resolvedFittinThemeProvider).paletteId,
        FittinPaletteId.porcelainInk,
      );
      expect(
        container.read(resolvedFittinThemeProvider).colorScheme.primary,
        container.read(resolvedFittinThemeProvider).accent,
      );
      await persistence;
    },
  );
}
