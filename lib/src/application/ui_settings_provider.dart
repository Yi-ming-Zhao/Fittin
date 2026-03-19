import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import '../data/database_repository.dart';

final uiSettingsProvider = StateNotifierProvider<UISettingsNotifier, double>((ref) {
  return UISettingsNotifier(ref);
});

class UISettingsNotifier extends StateNotifier<double> {
  UISettingsNotifier(this._ref) : super(0.3) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    try {
      final repository = _ref.read(databaseRepositoryProvider);
      final opacity = await repository.fetchGlassOpacity();
      state = opacity;
    } catch (_) {
      // Default to 0.3 if error
      state = 0.3;
    }
  }

  Future<void> updateOpacity(double newValue) async {
    state = newValue;
    try {
      final repository = _ref.read(databaseRepositoryProvider);
      await repository.saveGlassOpacity(newValue);
    } catch (_) {
      // Ignore save error for UI responsiveness
    }
  }
}
