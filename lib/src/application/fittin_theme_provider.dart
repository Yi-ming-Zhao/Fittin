import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';

/// Global Fittin theme state — direction + tweaks
class FittinThemeState {
  final FittinDirection direction;
  final FittinAccent accent;
  final FittinBg bg;
  final FittinTypeFamily typeFamily;
  final FittinChartStyle chartStyle;
  final FittinCardStyle cardStyle;
  final FittinDensity density;

  const FittinThemeState({
    this.direction = FittinDirection.editorial,
    this.accent = FittinAccent.bone,
    this.bg = FittinBg.warmBlack,
    this.typeFamily = FittinTypeFamily.editorial,
    this.chartStyle = FittinChartStyle.step,
    this.cardStyle = FittinCardStyle.glass,
    this.density = FittinDensity.comfortable,
  });

  FittinThemeState copyWith({
    FittinDirection? direction,
    FittinAccent? accent,
    FittinBg? bg,
    FittinTypeFamily? typeFamily,
    FittinChartStyle? chartStyle,
    FittinCardStyle? cardStyle,
    FittinDensity? density,
  }) {
    return FittinThemeState(
      direction: direction ?? this.direction,
      accent: accent ?? this.accent,
      bg: bg ?? this.bg,
      typeFamily: typeFamily ?? this.typeFamily,
      chartStyle: chartStyle ?? this.chartStyle,
      cardStyle: cardStyle ?? this.cardStyle,
      density: density ?? this.density,
    );
  }
}

final fittinThemeProvider =
    StateNotifierProvider<FittinThemeNotifier, FittinThemeState>((ref) {
  return FittinThemeNotifier();
});

class FittinThemeNotifier extends StateNotifier<FittinThemeState> {
  FittinThemeNotifier() : super(const FittinThemeState());

  void setDirection(FittinDirection direction) {
    state = state.copyWith(direction: direction);
  }

  void setAccent(FittinAccent accent) {
    state = state.copyWith(accent: accent);
  }

  void setBg(FittinBg bg) {
    state = state.copyWith(bg: bg);
  }

  void setTypeFamily(FittinTypeFamily typeFamily) {
    state = state.copyWith(typeFamily: typeFamily);
  }

  void setChartStyle(FittinChartStyle style) {
    state = state.copyWith(chartStyle: style);
  }

  void setCardStyle(FittinCardStyle style) {
    state = state.copyWith(cardStyle: style);
  }

  void setDensity(FittinDensity density) {
    state = state.copyWith(density: density);
  }

  void applyState(FittinThemeState newState) {
    state = newState;
  }
}

/// Derived provider that resolves the actual FittinTheme from state
final resolvedFittinThemeProvider = Provider<FittinTheme>((ref) {
  final s = ref.watch(fittinThemeProvider);
  return FittinTheme.resolve(
    direction: s.direction,
    accent: s.accent,
    bg: s.bg,
    typeFamily: s.typeFamily,
    chart: s.chartStyle,
    card: s.cardStyle,
    density: s.density,
  );
});
