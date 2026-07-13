import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/presentation/theme/app_colors.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';

void main() {
  test('theme accents never fall back to cyan or teal', () {
    for (final themeType in AppThemeType.values) {
      final scheme = AppColors.getThemeScheme(themeType);
      for (final color in [
        scheme.primary,
        scheme.secondary,
        scheme.secondaryContainer,
        scheme.tertiary,
        scheme.tertiaryContainer,
      ]) {
        expect(_isCyanOrTeal(color), false);
      }
    }

    for (final accent in FittinAccent.values) {
      final theme = FittinTheme.resolve(
        direction: FittinDirection.editorial,
        accent: accent,
      );
      expect(_isCyanOrTeal(theme.accent), false);
    }
  });
}

bool _isCyanOrTeal(Color color) {
  final hsl = HSLColor.fromColor(color);
  return hsl.saturation > 0.12 && hsl.hue >= 130 && hsl.hue <= 200;
}
