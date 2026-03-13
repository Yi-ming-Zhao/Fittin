import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/presentation/theme/app_colors.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeType>((ref) {
  // We'll default to minimalDark for now.
  // In a real iteration, we'd read this from Isar/SharedPreferences here.
  return ThemeNotifier(AppThemeType.minimalDark);
});

class ThemeNotifier extends StateNotifier<AppThemeType> {
  ThemeNotifier(super.state);

  void setTheme(AppThemeType theme) {
    state = theme;
    // TODO: Persist selection to local DB
  }
}
