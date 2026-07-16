import 'dart:io';

import 'package:fittin_v2/src/presentation/theme/domain_color_palettes.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Fittin palette registry', () {
    test('contains exactly five complete palettes with stable identifiers', () {
      expect(FittinPaletteRegistry.ids, FittinPaletteId.values);
      expect(FittinPaletteRegistry.entries, hasLength(5));

      for (final entry in FittinPaletteRegistry.entries.entries) {
        final theme = entry.value;
        expect(theme.paletteId, entry.key);
        expect(theme.chartSeries, hasLength(6));
        expect(theme.themeableColors, hasLength(greaterThanOrEqualTo(50)));
        expect(theme.themeableColors.values, everyElement(isA<Color>()));
      }
    });

    test('stable storage keys decode and unknown values safely fall back', () {
      expect(FittinPaletteId.values.map((id) => id.storageKey), [
        'obsidianBrass',
        'midnightCobalt',
        'bordeauxVelvet',
        'porcelainInk',
        'espressoEmber',
      ]);
      for (final id in FittinPaletteId.values) {
        expect(FittinPaletteRegistry.decode(id.storageKey), id);
      }
      expect(
        FittinPaletteRegistry.decode('retired-theme'),
        FittinPaletteId.obsidianBrass,
      );
      expect(FittinPaletteRegistry.decode(null), FittinPaletteId.obsidianBrass);
    });
  });

  group('Palette guardrails', () {
    for (final entry in FittinPaletteRegistry.entries.entries) {
      final id = entry.key;
      final theme = entry.value;

      test('${id.storageKey} meets contrast requirements', () {
        expect(_contrast(theme.fg, theme.bg), greaterThanOrEqualTo(4.5));
        expect(_contrast(theme.fg, theme.surfaceHi), greaterThanOrEqualTo(4.5));
        expect(
          _contrast(theme.accentInk, theme.accent),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrast(theme.fgDim, theme.surfaceSolid),
          greaterThanOrEqualTo(3),
        );
        expect(
          _contrast(theme.borderHi, theme.surfaceSolid),
          greaterThanOrEqualTo(3),
        );
        expect(_contrast(theme.chartAxis, theme.bg), greaterThanOrEqualTo(3));
        expect(_contrast(theme.accent, theme.bg), greaterThanOrEqualTo(3));
      });

      test('${id.storageKey} contains no cyan or teal theme colors', () {
        for (final colorEntry in theme.themeableColors.entries) {
          expect(
            _isCyanOrTeal(colorEntry.value),
            false,
            reason: '${id.storageKey}.${colorEntry.key} is cyan/teal',
          );
        }
        for (final colorEntry in _materialColorRoles(
          theme.colorScheme,
        ).entries) {
          expect(
            _isCyanOrTeal(colorEntry.value),
            false,
            reason: '${id.storageKey}.material.${colorEntry.key} is cyan/teal',
          );
        }
      });

      test('${id.storageKey} keeps Material and Fittin roles synchronized', () {
        final scheme = theme.colorScheme;
        expect(scheme.brightness, theme.brightness);
        expect(scheme.primary, theme.accent);
        expect(scheme.onPrimary, theme.accentInk);
        expect(scheme.primaryContainer, theme.accentDim);
        expect(scheme.primaryFixed, theme.accent);
        expect(scheme.primaryFixedDim, theme.accentPressed);
        expect(scheme.secondaryFixed, theme.chartSeries[1]);
        expect(scheme.tertiaryFixed, theme.info);
        expect(scheme.surface, theme.surfaceSolid);
        expect(scheme.surfaceDim, theme.bgDeep);
        expect(scheme.surfaceBright, theme.surfaceHi);
        expect(scheme.onSurface, theme.fg);
        expect(scheme.onSurfaceVariant, theme.fgDim);
        expect(scheme.outline, theme.borderHi);
        expect(scheme.outlineVariant, theme.border);
        expect(scheme.error, theme.danger);
        expect(scheme.errorContainer, theme.dangerSubtle);
        expect(scheme.shadow, theme.shadowStrong);
        expect(scheme.scrim, theme.scrim);
      });
    }
  });

  test('fixed domain palettes remain explicit and theme-independent', () {
    expect(OlympicEquipmentPalette.plate25, const Color(0xFFB94A48));
    expect(OlympicEquipmentPalette.plate20, const Color(0xFF416F9F));
    expect(OlympicEquipmentPalette.plate15, const Color(0xFFC3A74A));
    expect(OlympicEquipmentPalette.plate10, const Color(0xFF4E7A45));
    expect(ExportPalette.canvas, Colors.white);
    expect(ExportPalette.ink, const Color(0xFF111111));
    expect(ExportPalette.qrForeground, Colors.black);
    expect(ExportPalette.qrBackground, Colors.white);
  });

  test(
    'native and web launch surfaces avoid a platform-default white flash',
    () {
      final androidColor = File(
        'android/app/src/main/res/values/colors.xml',
      ).readAsStringSync();
      final androidLaunch = File(
        'android/app/src/main/res/drawable/launch_background.xml',
      ).readAsStringSync();
      final android31 = File(
        'android/app/src/main/res/values-v31/styles.xml',
      ).readAsStringSync();
      final iosLaunch = File(
        'ios/Runner/Base.lproj/LaunchScreen.storyboard',
      ).readAsStringSync();
      final iosMain = File(
        'ios/Runner/Base.lproj/Main.storyboard',
      ).readAsStringSync();
      final webIndex = File('web/index.html').readAsStringSync();

      expect(androidColor, contains('#090806'));
      expect(androidLaunch, contains('@color/launch_background'));
      expect(android31, contains('android:windowSplashScreenBackground'));
      expect(iosLaunch, contains('red="0.03529411765"'));
      expect(iosMain, contains('red="0.03529411765"'));
      expect(webIndex, contains('flutter.fittin.appearance.palette'));
      expect(webIndex, contains("palette === 'porcelainInk'"));
      expect(webIndex, contains('#F3EEE5'));
      expect(webIndex, contains('#090806'));
    },
  );
}

Map<String, Color> _materialColorRoles(ColorScheme scheme) => {
  'primary': scheme.primary,
  'onPrimary': scheme.onPrimary,
  'primaryContainer': scheme.primaryContainer,
  'onPrimaryContainer': scheme.onPrimaryContainer,
  'primaryFixed': scheme.primaryFixed,
  'primaryFixedDim': scheme.primaryFixedDim,
  'onPrimaryFixed': scheme.onPrimaryFixed,
  'onPrimaryFixedVariant': scheme.onPrimaryFixedVariant,
  'secondary': scheme.secondary,
  'onSecondary': scheme.onSecondary,
  'secondaryContainer': scheme.secondaryContainer,
  'onSecondaryContainer': scheme.onSecondaryContainer,
  'secondaryFixed': scheme.secondaryFixed,
  'secondaryFixedDim': scheme.secondaryFixedDim,
  'onSecondaryFixed': scheme.onSecondaryFixed,
  'onSecondaryFixedVariant': scheme.onSecondaryFixedVariant,
  'tertiary': scheme.tertiary,
  'onTertiary': scheme.onTertiary,
  'tertiaryContainer': scheme.tertiaryContainer,
  'onTertiaryContainer': scheme.onTertiaryContainer,
  'tertiaryFixed': scheme.tertiaryFixed,
  'tertiaryFixedDim': scheme.tertiaryFixedDim,
  'onTertiaryFixed': scheme.onTertiaryFixed,
  'onTertiaryFixedVariant': scheme.onTertiaryFixedVariant,
  'error': scheme.error,
  'onError': scheme.onError,
  'errorContainer': scheme.errorContainer,
  'onErrorContainer': scheme.onErrorContainer,
  'surface': scheme.surface,
  'onSurface': scheme.onSurface,
  'surfaceDim': scheme.surfaceDim,
  'surfaceBright': scheme.surfaceBright,
  'surfaceContainerLowest': scheme.surfaceContainerLowest,
  'surfaceContainerLow': scheme.surfaceContainerLow,
  'surfaceContainer': scheme.surfaceContainer,
  'surfaceContainerHigh': scheme.surfaceContainerHigh,
  'surfaceContainerHighest': scheme.surfaceContainerHighest,
  'onSurfaceVariant': scheme.onSurfaceVariant,
  'outline': scheme.outline,
  'outlineVariant': scheme.outlineVariant,
  'shadow': scheme.shadow,
  'scrim': scheme.scrim,
  'inverseSurface': scheme.inverseSurface,
  'onInverseSurface': scheme.onInverseSurface,
  'inversePrimary': scheme.inversePrimary,
  'surfaceTint': scheme.surfaceTint,
};

double _contrast(Color foreground, Color background) {
  final light = foreground.computeLuminance();
  final dark = background.computeLuminance();
  final lighter = light > dark ? light : dark;
  final darker = light > dark ? dark : light;
  return (lighter + 0.05) / (darker + 0.05);
}

bool _isCyanOrTeal(Color color) {
  final hsl = HSLColor.fromColor(color);
  return hsl.saturation > 0.12 && hsl.hue >= 130 && hsl.hue <= 200;
}
