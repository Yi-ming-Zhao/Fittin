import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared preference instance loaded before the production ProviderScope.
///
/// The nullable fallback keeps isolated widget tests usable; production always
/// overrides this provider in `main` so theme restoration is synchronous.
final fittinThemePreferencesProvider = Provider<SharedPreferences?>((ref) {
  return null;
});

final fittinThemeProvider =
    StateNotifierProvider<FittinThemeNotifier, FittinPaletteId>((ref) {
      return FittinThemeNotifier(
        preferences: ref.watch(fittinThemePreferencesProvider),
      );
    });

class FittinThemeNotifier extends StateNotifier<FittinPaletteId> {
  FittinThemeNotifier({SharedPreferences? preferences})
    : _preferences = preferences,
      super(
        FittinPaletteRegistry.decode(preferences?.getString(preferencesKey)),
      );

  static const String preferencesKey = 'fittin.appearance.palette';

  final SharedPreferences? _preferences;

  /// Applies immediately, then persists without delaying visible feedback.
  Future<void> setPalette(FittinPaletteId paletteId) async {
    state = paletteId;
    await _preferences?.setString(preferencesKey, paletteId.storageKey);
  }
}

/// Resolved semantic tokens used by all product surfaces and Material theme.
final resolvedFittinThemeProvider = Provider<FittinTheme>((ref) {
  return FittinPaletteRegistry.themeOf(ref.watch(fittinThemeProvider));
});
