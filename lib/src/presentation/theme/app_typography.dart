import 'package:flutter/material.dart';

/// Typography defaults shared by Material and the custom Fittin theme.
abstract final class AppTypography {
  static const cjkFontFamily = 'NotoSansSC';
  static const fontFamilyFallback = <String>[cjkFontFamily];

  static TextStyle withCjkFallback(TextStyle style) {
    final existingFallbacks = style.fontFamilyFallback ?? const <String>[];
    if (existingFallbacks.contains(cjkFontFamily)) {
      return style;
    }
    return style.copyWith(
      fontFamilyFallback: <String>[...existingFallbacks, cjkFontFamily],
    );
  }

  static TextTheme withCjkFallbacks(TextTheme theme) => theme.copyWith(
    displayLarge: _withCjkFallback(theme.displayLarge),
    displayMedium: _withCjkFallback(theme.displayMedium),
    displaySmall: _withCjkFallback(theme.displaySmall),
    headlineLarge: _withCjkFallback(theme.headlineLarge),
    headlineMedium: _withCjkFallback(theme.headlineMedium),
    headlineSmall: _withCjkFallback(theme.headlineSmall),
    titleLarge: _withCjkFallback(theme.titleLarge),
    titleMedium: _withCjkFallback(theme.titleMedium),
    titleSmall: _withCjkFallback(theme.titleSmall),
    bodyLarge: _withCjkFallback(theme.bodyLarge),
    bodyMedium: _withCjkFallback(theme.bodyMedium),
    bodySmall: _withCjkFallback(theme.bodySmall),
    labelLarge: _withCjkFallback(theme.labelLarge),
    labelMedium: _withCjkFallback(theme.labelMedium),
    labelSmall: _withCjkFallback(theme.labelSmall),
  );

  static TextStyle? _withCjkFallback(TextStyle? style) =>
      style == null ? null : withCjkFallback(style);
}
