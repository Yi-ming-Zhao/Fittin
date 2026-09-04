import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/domain/models/custom_theme_palette.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:flutter/material.dart';
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

    expect(notifier.state, FittinPaletteId.bordeauxVelvet.storageKey);
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
      expect(firstLaunch.state, FittinPaletteId.midnightCobalt.storageKey);

      await firstLaunch.setPalette(FittinPaletteId.espressoEmber);
      final restarted = FittinThemeNotifier(preferences: preferences);
      expect(restarted.state, FittinPaletteId.espressoEmber.storageKey);
    },
  );

  test(
    'custom-looking stored value is retained for async resolution',
    () async {
      SharedPreferences.setMockInitialValues({
        FittinThemeNotifier.preferencesKey:
            'future-palette-that-does-not-exist',
      });
      final preferences = await SharedPreferences.getInstance();

      final notifier = FittinThemeNotifier(preferences: preferences);

      expect(notifier.state, 'future-palette-that-does-not-exist');
    },
  );

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

  test('custom palette is cached for splash and first ready frame', () async {
    final preferences = await SharedPreferences.getInstance();
    final notifier = FittinThemeNotifier(preferences: preferences);

    await notifier.setCustomPalette(_customPalette);

    expect(notifier.state, _customPalette.id);
    expect(
      FittinThemeNotifier.cachedCustomPalette(preferences)?.toJson(),
      _customPalette.toJson(),
    );
    expect(
      FittinThemeNotifier.resolveStoredTheme(preferences).accent,
      _customPalette.color('accent'),
    );

    final container = ProviderContainer(
      overrides: [
        fittinThemePreferencesProvider.overrideWithValue(preferences),
      ],
    );
    addTearDown(container.dispose);
    expect(
      container.read(resolvedFittinThemeProvider).accent,
      _customPalette.color('accent'),
    );
  });

  test('invalid custom launch cache safely falls back', () async {
    SharedPreferences.setMockInitialValues({
      FittinThemeNotifier.preferencesKey: 'user-palette:broken',
      FittinThemeNotifier.cachedCustomPaletteKey: '{not-json',
    });
    final preferences = await SharedPreferences.getInstance();

    expect(
      FittinThemeNotifier.resolveStoredTheme(preferences).paletteId,
      FittinPaletteRegistry.defaultId,
    );
  });
}

final _customPalette = CustomThemePalette(
  id: 'user-palette:launch-cache',
  name: 'Ember Archive',
  brightness: Brightness.dark,
  colors: const {
    'background': '#111111',
    'surface': '#1B1B1B',
    'foreground': '#F5F1E8',
    'mutedForeground': '#B8B0A2',
    'accent': '#D6A94E',
    'accentInk': '#111111',
    'strength': '#E05D44',
    'cardio': '#8B6FD6',
    'success': '#72A85F',
    'warning': '#E4A93B',
    'danger': '#D95C65',
  },
);
