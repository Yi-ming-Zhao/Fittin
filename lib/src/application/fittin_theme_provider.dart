import 'dart:convert';

import 'package:fittin_v2/src/domain/models/custom_theme_palette.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:fittin_v2/src/application/user_content_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared preference instance loaded before the production ProviderScope.
///
/// The nullable fallback keeps isolated widget tests usable; production always
/// overrides this provider in `main` so theme restoration is synchronous.
final fittinThemePreferencesProvider = Provider<SharedPreferences?>((ref) {
  return null;
});

final fittinThemeProvider = StateNotifierProvider<FittinThemeNotifier, String>((
  ref,
) {
  return FittinThemeNotifier(
    preferences: ref.watch(fittinThemePreferencesProvider),
  );
});

class FittinThemeNotifier extends StateNotifier<String> {
  FittinThemeNotifier({SharedPreferences? preferences})
    : _preferences = preferences,
      super(
        preferences?.getString(preferencesKey) ??
            FittinPaletteRegistry.defaultId.storageKey,
      );

  static const String preferencesKey = 'fittin.appearance.palette';
  static const String cachedCustomPaletteKey =
      'fittin.appearance.cached-custom-palette';

  final SharedPreferences? _preferences;

  /// Applies immediately, then persists without delaying visible feedback.
  Future<void> setPalette(FittinPaletteId paletteId) async {
    await setPaletteKey(paletteId.storageKey);
  }

  /// Selects a custom palette and keeps a validated launch-safe copy.
  ///
  /// The canonical palette still lives in the local user-content repository;
  /// this small cache only prevents the splash and first ready frame from
  /// flashing the default palette while that repository opens.
  Future<void> setCustomPalette(CustomThemePalette palette) async {
    state = palette.id;
    final preferences = _preferences;
    if (preferences == null) return;
    await Future.wait([
      preferences.setString(preferencesKey, palette.id),
      preferences.setString(
        cachedCustomPaletteKey,
        jsonEncode(palette.toJson()),
      ),
    ]);
  }

  Future<void> setPaletteKey(String paletteKey) async {
    state = paletteKey;
    await _preferences?.setString(preferencesKey, paletteKey);
  }

  static CustomThemePalette? cachedCustomPalette(
    SharedPreferences? preferences,
  ) {
    final encoded = preferences?.getString(cachedCustomPaletteKey);
    if (encoded == null || encoded.isEmpty) return null;
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map) return null;
      return CustomThemePalette.fromJson(decoded.cast<String, dynamic>());
    } on Object {
      return null;
    }
  }

  static FittinTheme resolveStoredTheme(SharedPreferences? preferences) {
    final selected = preferences?.getString(preferencesKey);
    for (final id in FittinPaletteRegistry.ids) {
      if (id.storageKey == selected) return FittinPaletteRegistry.themeOf(id);
    }
    final cached = cachedCustomPalette(preferences);
    if (cached != null && cached.id == selected) {
      return themeFromCustomPalette(cached);
    }
    return FittinPaletteRegistry.themeOf(FittinPaletteRegistry.defaultId);
  }
}

/// Resolved semantic tokens used by all product surfaces and Material theme.
final resolvedFittinThemeProvider = Provider<FittinTheme>((ref) {
  final selectedKey = ref.watch(fittinThemeProvider);
  for (final id in FittinPaletteRegistry.ids) {
    if (id.storageKey == selectedKey) {
      return FittinPaletteRegistry.themeOf(id);
    }
  }
  final palettes = ref.watch(customThemePalettesProvider).valueOrNull;
  if (palettes != null) {
    for (final palette in palettes) {
      if (palette.id == selectedKey) return themeFromCustomPalette(palette);
    }
  }
  final cached = FittinThemeNotifier.cachedCustomPalette(
    ref.watch(fittinThemePreferencesProvider),
  );
  if (cached != null && cached.id == selectedKey) {
    return themeFromCustomPalette(cached);
  }
  return FittinPaletteRegistry.themeOf(FittinPaletteRegistry.defaultId);
});
