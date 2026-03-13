import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/plan_library_provider.dart';

enum AppLocale { en, zh }

extension AppLocaleX on AppLocale {
  String get code => this == AppLocale.zh ? 'zh' : 'en';

  Locale get locale => Locale(code);

  String get nativeLabel => this == AppLocale.zh ? '中文' : 'English';

  static AppLocale fromCode(String? code) {
    return code == 'zh' ? AppLocale.zh : AppLocale.en;
  }
}

final appLocaleProvider =
    StateNotifierProvider<AppLocaleNotifier, AppLocale>((ref) {
      return AppLocaleNotifier(ref);
    });

class AppLocaleNotifier extends StateNotifier<AppLocale> {
  AppLocaleNotifier(this._ref) : super(AppLocale.en) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final repository = _ref.read(databaseRepositoryProvider);
    final locale = await repository.fetchAppLocale();
    if (mounted) {
      state = locale;
    }
  }

  Future<void> setLocale(AppLocale locale) async {
    if (state == locale) {
      return;
    }
    state = locale;
    await _ref.read(databaseRepositoryProvider).saveAppLocale(locale);
    _ref.invalidate(planLibraryItemsProvider);
    _ref.invalidate(todayWorkoutSummaryProvider);
    _ref.invalidate(activeTemplateProvider);
    _ref.invalidate(activeSessionProvider);
  }
}
