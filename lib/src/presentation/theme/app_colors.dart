import 'package:flutter/material.dart';

enum AppThemeType { ocean, minimalDark, sunset }

class AppColors {
  // === Deep Ocean Palette ===
  static const Color oceanBackground = Color(0xFF0F172A);
  static const Color oceanSurface = Color(0xFF1E293B);
  static const Color oceanPrimary = Color(0xFF38BDF8); // Sky blue
  static const Color oceanOnPrimary = Color(0xFF0F172A);
  static const Color oceanTextPrimary = Color(0xFFF8FAFC);
  static const Color oceanTextSecondary = Color(0xFF94A3B8);

  // === Minimalist Dark Palette ===
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF111111);
  static const Color darkPrimary = Color(0xFFE5E5E5);
  static const Color darkOnPrimary = Color(0xFF000000);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF888888);

  // === Sunset Warmth Palette ===
  static const Color sunsetBackground = Color(0xFF2C1E16);
  static const Color sunsetSurface = Color(0xFF3B281B);
  static const Color sunsetPrimary = Color(0xFFF9A826); // Warm orange
  static const Color sunsetOnPrimary = Color(0xFF2C1E16);
  static const Color sunsetTextPrimary = Color(0xFFFDE6D5);
  static const Color sunsetTextSecondary = Color(0xFFD3A286);

  static ColorScheme getThemeScheme(AppThemeType type) {
    switch (type) {
      case AppThemeType.ocean:
        return const ColorScheme.dark(
          background: oceanBackground,
          surface: oceanSurface,
          primary: oceanPrimary,
          onPrimary: oceanOnPrimary,
          onBackground: oceanTextPrimary,
          onSurface: oceanTextPrimary,
          outline: oceanTextSecondary,
        );
      case AppThemeType.sunset:
        return const ColorScheme.dark(
          background: sunsetBackground,
          surface: sunsetSurface,
          primary: sunsetPrimary,
          onPrimary: sunsetOnPrimary,
          onBackground: sunsetTextPrimary,
          onSurface: sunsetTextPrimary,
          outline: sunsetTextSecondary,
        );
      case AppThemeType.minimalDark:
      default:
        return const ColorScheme.dark(
          background: darkBackground,
          surface: darkSurface,
          primary: darkPrimary,
          onPrimary: darkOnPrimary,
          onBackground: darkTextPrimary,
          onSurface: darkTextPrimary,
          outline: darkTextSecondary,
        );
    }
  }
}
