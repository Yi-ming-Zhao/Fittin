import 'package:fittin_v2/src/presentation/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('bundles the compact CJK fallback font for offline UI copy', (
    tester,
  ) async {
    final font = await rootBundle.load('assets/fonts/NotoSansSC-AppSubset.ttf');
    final license = await rootBundle.loadString(
      'assets/fonts/OFL-NotoSansSC.txt',
    );

    expect(font.lengthInBytes, inInclusiveRange(200000, 500000));
    expect(license, contains('SIL OPEN FONT LICENSE Version 1.1'));
  });

  test('applies the bundled CJK fallback to Material text roles', () {
    const sourceTheme = TextTheme(
      displayLarge: TextStyle(fontFamilyFallback: <String>['Display']),
      headlineMedium: TextStyle(),
      titleSmall: TextStyle(),
      bodyMedium: TextStyle(),
      labelLarge: TextStyle(),
    );
    final theme = AppTypography.withCjkFallbacks(sourceTheme);

    for (final style in <TextStyle?>[
      theme.displayLarge,
      theme.headlineMedium,
      theme.titleSmall,
      theme.bodyMedium,
      theme.labelLarge,
    ]) {
      expect(style?.fontFamilyFallback, contains(AppTypography.cjkFontFamily));
    }
    expect(theme.displayLarge?.fontFamilyFallback, <String>[
      'Display',
      AppTypography.cjkFontFamily,
    ]);
  });

  test('CJK fallback preserves the primary family fallback', () {
    const style = TextStyle(fontFamilyFallback: <String>['Inter']);

    expect(AppTypography.withCjkFallback(style).fontFamilyFallback, <String>[
      'Inter',
      AppTypography.cjkFontFamily,
    ]);
  });
}
