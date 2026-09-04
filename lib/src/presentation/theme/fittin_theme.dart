import 'package:fittin_v2/src/presentation/theme/app_typography.dart';
import 'package:fittin_v2/src/domain/models/custom_theme_palette.dart';
import 'package:flutter/material.dart';

/// Stable identifiers persisted for the five curated appearance palettes.
enum FittinPaletteId {
  obsidianBrass,
  midnightCobalt,
  bordeauxVelvet,
  porcelainInk,
  espressoEmber,
  graphiteOrchid,
  inkSaffron,
  oliveManuscript,
}

extension FittinPaletteIdStorage on FittinPaletteId {
  /// Do not change these values without adding a storage migration.
  String get storageKey => switch (this) {
    FittinPaletteId.obsidianBrass => 'obsidianBrass',
    FittinPaletteId.midnightCobalt => 'midnightCobalt',
    FittinPaletteId.bordeauxVelvet => 'bordeauxVelvet',
    FittinPaletteId.porcelainInk => 'porcelainInk',
    FittinPaletteId.espressoEmber => 'espressoEmber',
    FittinPaletteId.graphiteOrchid => 'graphiteOrchid',
    FittinPaletteId.inkSaffron => 'inkSaffron',
    FittinPaletteId.oliveManuscript => 'oliveManuscript',
  };
}

/// Legacy visual controls retained only so existing call sites can migrate
/// incrementally. New UI must select a complete [FittinPaletteId].
enum FittinDirection { editorial, technical, clay }

enum FittinAccent { bone, lime, terracotta, sky, plum, ember }

enum FittinBg { trueBlack, warmBlack, charcoal, warmCharcoal }

enum FittinTypeFamily { editorial, technical, clay, neutral }

enum FittinDensity { comfortable, compact }

enum FittinCardStyle { glass, flat, bordered }

enum FittinChartStyle { step, linear, smooth, area }

/// Complete semantic theme resolved from one curated palette.
///
/// The short `bg`/`fg` names are intentionally preserved for compatibility
/// while screens move to the more descriptive aliases below.
class FittinTheme {
  const FittinTheme({
    required this.paletteId,
    required this.brightness,
    required this.bg,
    required this.bgDeep,
    required this.surface,
    required this.surfaceSolid,
    required this.surfaceHi,
    required this.surfaceSelected,
    required this.fg,
    required this.fgDim,
    required this.fgMuted,
    required this.fgFaint,
    required this.fgInverse,
    required this.borderSubtle,
    required this.border,
    required this.borderHi,
    required this.divider,
    required this.focusRing,
    required this.shadowSoft,
    required this.shadowStrong,
    required this.scrim,
    required this.accent,
    required this.accentInk,
    required this.accentDim,
    required this.accentPressed,
    required this.success,
    required this.successSubtle,
    required this.warning,
    required this.warningSubtle,
    required this.danger,
    required this.dangerSubtle,
    required this.info,
    required this.infoSubtle,
    required this.setCompleted,
    required this.setSkipped,
    required this.setCurrent,
    required this.setUpcoming,
    required this.gestureLog,
    required this.gestureSkip,
    required this.gestureNavigate,
    required this.chartGrid,
    required this.chartAxis,
    required this.chartLabel,
    required this.chartSelection,
    required this.chartTooltip,
    required this.chartSeries,
    required this.anatomyBase,
    required this.anatomyStroke,
    required this.anatomyInactive,
    required this.anatomySelected,
    required this.loadLow,
    required this.loadHigh,
    required this.pressedOverlay,
    required this.selectedOverlay,
    required this.disabledOverlay,
    required this.displayFontFamily,
    required this.uiFontFamily,
    required this.numFontFamily,
    required this.displayWeight,
    required this.numWeight,
    required this.chartStyle,
    required this.radius,
    required this.radiusSm,
    required this.pad,
    required this.gap,
    required this.titleSize,
    required this.rowH,
  });

  final FittinPaletteId paletteId;
  final Brightness brightness;

  // Canvas and surface roles.
  final Color bg;
  final Color bgDeep;
  final Color surface;
  final Color surfaceSolid;
  final Color surfaceHi;
  final Color surfaceSelected;

  // Content roles.
  final Color fg;
  final Color fgDim;
  final Color fgMuted;
  final Color fgFaint;
  final Color fgInverse;

  // Structure and elevation roles.
  final Color borderSubtle;
  final Color border;
  final Color borderHi;
  final Color divider;
  final Color focusRing;
  final Color shadowSoft;
  final Color shadowStrong;
  final Color scrim;

  // Brand interaction roles.
  final Color accent;
  final Color accentInk;
  final Color accentDim;
  final Color accentPressed;

  // Status roles.
  final Color success;
  final Color successSubtle;
  final Color warning;
  final Color warningSubtle;
  final Color danger;
  final Color dangerSubtle;
  final Color info;
  final Color infoSubtle;

  // Workout-state and gesture roles.
  final Color setCompleted;
  final Color setSkipped;
  final Color setCurrent;
  final Color setUpcoming;
  final Color gestureLog;
  final Color gestureSkip;
  final Color gestureNavigate;

  // Data visualization roles.
  final Color chartGrid;
  final Color chartAxis;
  final Color chartLabel;
  final Color chartSelection;
  final Color chartTooltip;
  final List<Color> chartSeries;

  // Anatomy and training-load roles.
  final Color anatomyBase;
  final Color anatomyStroke;
  final Color anatomyInactive;
  final Color anatomySelected;
  final Color loadLow;
  final Color loadHigh;

  // Generic interaction overlays.
  final Color pressedOverlay;
  final Color selectedOverlay;
  final Color disabledOverlay;

  // Typography, shape, and density tokens.
  final String displayFontFamily;
  final String uiFontFamily;
  final String numFontFamily;
  final FontWeight displayWeight;
  final FontWeight numWeight;
  final FittinChartStyle chartStyle;
  final double radius;
  final double radiusSm;
  final double pad;
  final double gap;
  final double titleSize;
  final double rowH;

  Color get canvas => bg;
  Color get canvasDeep => bgDeep;
  Color get surfaceElevated => surfaceHi;
  Color get textPrimary => fg;
  Color get textSecondary => fgDim;
  Color get textMuted => fgMuted;
  Color get textDisabled => fgFaint;
  Color get textInverse => fgInverse;

  /// Compatibility aliases for chart call sites being migrated separately.
  Color get chartStroke => chartSeries.first;
  Color get chartDot => chartSelection;
  Color get strengthSeries => chartSeries.first;
  Color get cardioSeries => chartSeries[1];

  /// Material widgets and custom Fittin widgets resolve from this same object.
  ColorScheme get colorScheme {
    final onSupportingColor = brightness == Brightness.dark
        ? bgDeep
        : fgInverse;

    return ColorScheme(
      brightness: brightness,
      primary: accent,
      onPrimary: accentInk,
      primaryContainer: accentDim,
      onPrimaryContainer: fg,
      primaryFixed: accent,
      primaryFixedDim: accentPressed,
      onPrimaryFixed: accentInk,
      onPrimaryFixedVariant: accentInk,
      secondary: chartSeries[1],
      onSecondary: onSupportingColor,
      secondaryContainer: surfaceSelected,
      onSecondaryContainer: fg,
      secondaryFixed: chartSeries[1],
      secondaryFixedDim: chartSeries[1],
      onSecondaryFixed: onSupportingColor,
      onSecondaryFixedVariant: onSupportingColor,
      tertiary: info,
      onTertiary: onSupportingColor,
      tertiaryContainer: infoSubtle,
      onTertiaryContainer: fg,
      tertiaryFixed: info,
      tertiaryFixedDim: info,
      onTertiaryFixed: onSupportingColor,
      onTertiaryFixedVariant: onSupportingColor,
      error: danger,
      onError: brightness == Brightness.dark ? bgDeep : fgInverse,
      errorContainer: dangerSubtle,
      onErrorContainer: fg,
      surface: surfaceSolid,
      onSurface: fg,
      surfaceDim: bgDeep,
      surfaceBright: surfaceHi,
      surfaceContainerLowest: bgDeep,
      surfaceContainerLow: surface,
      surfaceContainer: surfaceSolid,
      surfaceContainerHigh: surfaceHi,
      surfaceContainerHighest: surfaceSelected,
      onSurfaceVariant: fgDim,
      outline: borderHi,
      outlineVariant: border,
      shadow: shadowStrong,
      scrim: scrim,
      inverseSurface: fg,
      onInverseSurface: bg,
      inversePrimary: accentPressed,
      surfaceTint: Colors.transparent,
    );
  }

  /// Opaque, user-facing roles checked by palette guard tests.
  Map<String, Color> get themeableColors => {
    'canvas': bg,
    'canvasDeep': bgDeep,
    'surface': surface,
    'surfaceSolid': surfaceSolid,
    'surfaceElevated': surfaceHi,
    'surfaceSelected': surfaceSelected,
    'textPrimary': fg,
    'textSecondary': fgDim,
    'textMuted': fgMuted,
    'textDisabled': fgFaint,
    'textInverse': fgInverse,
    'borderSubtle': borderSubtle,
    'border': border,
    'borderStrong': borderHi,
    'divider': divider,
    'focusRing': focusRing,
    'accent': accent,
    'onAccent': accentInk,
    'accentContainer': accentDim,
    'accentPressed': accentPressed,
    'success': success,
    'successSubtle': successSubtle,
    'warning': warning,
    'warningSubtle': warningSubtle,
    'danger': danger,
    'dangerSubtle': dangerSubtle,
    'info': info,
    'infoSubtle': infoSubtle,
    'setCompleted': setCompleted,
    'setSkipped': setSkipped,
    'setCurrent': setCurrent,
    'setUpcoming': setUpcoming,
    'gestureLog': gestureLog,
    'gestureSkip': gestureSkip,
    'gestureNavigate': gestureNavigate,
    'chartGrid': chartGrid,
    'chartAxis': chartAxis,
    'chartLabel': chartLabel,
    'chartSelection': chartSelection,
    'chartTooltip': chartTooltip,
    for (var index = 0; index < chartSeries.length; index++)
      'chartSeries${index + 1}': chartSeries[index],
    'anatomyBase': anatomyBase,
    'anatomyStroke': anatomyStroke,
    'anatomyInactive': anatomyInactive,
    'anatomySelected': anatomySelected,
    'loadLow': loadLow,
    'loadHigh': loadHigh,
  };

  TextStyle displayStyle([double? fontSize, Color? color]) => _font(
    displayFontFamily,
    fontSize ?? titleSize,
    displayWeight,
    color ?? fg,
    letterSpacing: displayFontFamily.contains('Mono') ? -0.5 : -1,
  );

  TextStyle uiStyle([double? fontSize, Color? color, FontWeight? weight]) =>
      _font(
        uiFontFamily,
        fontSize ?? 14,
        weight ?? FontWeight.w400,
        color ?? fg,
      );

  TextStyle numStyle([double? fontSize, Color? color]) => _font(
    numFontFamily,
    fontSize ?? 16,
    numWeight,
    color ?? fg,
    letterSpacing: numFontFamily.contains('Mono') ? -0.5 : -1.5,
  );

  TextStyle eyebrowStyle() =>
      _font(uiFontFamily, 10, FontWeight.w500, fgMuted, letterSpacing: 1.8);

  TextStyle _font(
    String family,
    double size,
    FontWeight weight,
    Color color, {
    double letterSpacing = 0,
  }) {
    final axisRange = switch (family) {
      'Instrument Sans' => (400.0, 700.0),
      'JetBrains Mono' => (100.0, 800.0),
      'Instrument Serif' => null,
      _ => (100.0, 900.0),
    };
    final style = TextStyle(
      fontFamily: family,
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      fontVariations: axisRange == null
          ? null
          : [
              FontVariation(
                'wght',
                weight.value
                    .toDouble()
                    .clamp(axisRange.$1, axisRange.$2)
                    .toDouble(),
              ),
            ],
    );
    return AppTypography.withCjkFallback(style);
  }

  /// Legacy resolver. New code must use [FittinPaletteRegistry.themeOf].
  static FittinTheme resolve({
    required FittinDirection direction,
    FittinAccent? accent,
    FittinBg? bg,
    FittinTypeFamily? typeFamily,
    FittinChartStyle? chart,
    FittinCardStyle? card,
    FittinDensity? density,
  }) {
    final paletteId = switch (direction) {
      FittinDirection.editorial => FittinPaletteId.obsidianBrass,
      FittinDirection.technical => FittinPaletteId.midnightCobalt,
      FittinDirection.clay => FittinPaletteId.espressoEmber,
    };
    return FittinPaletteRegistry.themeOf(paletteId);
  }
}

/// Registry of complete, curated palettes. This is the only palette lookup
/// used by runtime theme state.
abstract final class FittinPaletteRegistry {
  static const FittinPaletteId defaultId = FittinPaletteId.obsidianBrass;

  static final Map<FittinPaletteId, FittinTheme> entries = Map.unmodifiable({
    FittinPaletteId.obsidianBrass: _obsidianBrass,
    FittinPaletteId.midnightCobalt: _midnightCobalt,
    FittinPaletteId.bordeauxVelvet: _bordeauxVelvet,
    FittinPaletteId.porcelainInk: _porcelainInk,
    FittinPaletteId.espressoEmber: _espressoEmber,
    FittinPaletteId.graphiteOrchid: _graphiteOrchid,
    FittinPaletteId.inkSaffron: _inkSaffron,
    FittinPaletteId.oliveManuscript: _oliveManuscript,
  });

  static List<FittinPaletteId> get ids => List.unmodifiable(entries.keys);

  static FittinTheme themeOf(FittinPaletteId id) => entries[id]!;

  static FittinPaletteId decode(String? storedValue) {
    for (final id in FittinPaletteId.values) {
      if (id.storageKey == storedValue) return id;
    }
    return defaultId;
  }
}

FittinTheme _darkPalette({
  required FittinPaletteId id,
  required Color bg,
  required Color bgDeep,
  required Color surface,
  required Color surfaceSolid,
  required Color surfaceHi,
  required Color surfaceSelected,
  required Color fg,
  required Color fgDim,
  required Color fgMuted,
  required Color fgFaint,
  required Color borderSubtle,
  required Color border,
  required Color borderHi,
  required Color accent,
  required Color accentInk,
  required Color accentDim,
  required Color accentPressed,
  required Color success,
  required Color successSubtle,
  required Color warning,
  required Color warningSubtle,
  required Color danger,
  required Color dangerSubtle,
  required Color info,
  required Color infoSubtle,
  required List<Color> chartSeries,
  required Color anatomyBase,
  required Color anatomyStroke,
  required Color anatomyInactive,
  required Color anatomySelected,
  required Color loadLow,
  required Color loadHigh,
  String displayFontFamily = 'Fraunces',
  String numFontFamily = 'Fraunces',
}) => FittinTheme(
  paletteId: id,
  brightness: Brightness.dark,
  bg: bg,
  bgDeep: bgDeep,
  surface: surface,
  surfaceSolid: surfaceSolid,
  surfaceHi: surfaceHi,
  surfaceSelected: surfaceSelected,
  fg: fg,
  fgDim: fgDim,
  fgMuted: fgMuted,
  fgFaint: fgFaint,
  fgInverse: bgDeep,
  borderSubtle: borderSubtle,
  border: border,
  borderHi: borderHi,
  divider: borderSubtle,
  focusRing: accent,
  shadowSoft: const Color(0x52000000),
  shadowStrong: const Color(0xA6000000),
  scrim: const Color(0xC2000000),
  accent: accent,
  accentInk: accentInk,
  accentDim: accentDim,
  accentPressed: accentPressed,
  success: success,
  successSubtle: successSubtle,
  warning: warning,
  warningSubtle: warningSubtle,
  danger: danger,
  dangerSubtle: dangerSubtle,
  info: info,
  infoSubtle: infoSubtle,
  setCompleted: success,
  setSkipped: danger,
  setCurrent: accent,
  setUpcoming: fgMuted,
  gestureLog: success,
  gestureSkip: danger,
  gestureNavigate: info,
  chartGrid: borderSubtle,
  chartAxis: borderHi,
  chartLabel: fgDim,
  chartSelection: accent,
  chartTooltip: surfaceHi,
  chartSeries: List.unmodifiable(chartSeries),
  anatomyBase: anatomyBase,
  anatomyStroke: anatomyStroke,
  anatomyInactive: anatomyInactive,
  anatomySelected: anatomySelected,
  loadLow: loadLow,
  loadHigh: loadHigh,
  pressedOverlay: const Color(0x14FFFFFF),
  selectedOverlay: accent.withValues(alpha: 0.14),
  disabledOverlay: const Color(0x0FFFFFFF),
  displayFontFamily: displayFontFamily,
  uiFontFamily: 'Inter',
  numFontFamily: numFontFamily,
  displayWeight: FontWeight.w500,
  numWeight: FontWeight.w500,
  chartStyle: FittinChartStyle.smooth,
  radius: 18,
  radiusSm: 10,
  pad: 18,
  gap: 12,
  titleSize: 30,
  rowH: 50,
);

final _obsidianBrass = _darkPalette(
  id: FittinPaletteId.obsidianBrass,
  bg: const Color(0xFF090806),
  bgDeep: const Color(0xFF050403),
  surface: const Color(0xFF12100D),
  surfaceSolid: const Color(0xFF171512),
  surfaceHi: const Color(0xFF211E19),
  surfaceSelected: const Color(0xFF2B251C),
  fg: const Color(0xFFF7F1E5),
  fgDim: const Color(0xFFC9C0B1),
  fgMuted: const Color(0xFF9A9082),
  fgFaint: const Color(0xFF736B61),
  borderSubtle: const Color(0xFF332F28),
  border: const Color(0xFF4E473B),
  borderHi: const Color(0xFF9A845E),
  accent: const Color(0xFFD8B56B),
  accentInk: const Color(0xFF181108),
  accentDim: const Color(0xFF3B3020),
  accentPressed: const Color(0xFFC29D54),
  success: const Color(0xFF91C979),
  successSubtle: const Color(0xFF21351C),
  warning: const Color(0xFFE0B45E),
  warningSubtle: const Color(0xFF3C2E16),
  danger: const Color(0xFFE07B72),
  dangerSubtle: const Color(0xFF40201D),
  info: const Color(0xFFA58AD5),
  infoSubtle: const Color(0xFF2B2340),
  chartSeries: const [
    Color(0xFFD8B56B),
    Color(0xFFA58AD5),
    Color(0xFFE07B91),
    Color(0xFF7396CE),
    Color(0xFFDF8B55),
    Color(0xFF9AC06B),
  ],
  anatomyBase: const Color(0xFF2A2621),
  anatomyStroke: const Color(0xFF8B7F70),
  anatomyInactive: const Color(0xFF403A32),
  anatomySelected: const Color(0xFFF0C879),
  loadLow: const Color(0xFF6E4D3A),
  loadHigh: const Color(0xFFF19A57),
);

final _midnightCobalt = _darkPalette(
  id: FittinPaletteId.midnightCobalt,
  bg: const Color(0xFF070A12),
  bgDeep: const Color(0xFF03050B),
  surface: const Color(0xFF0C1220),
  surfaceSolid: const Color(0xFF101829),
  surfaceHi: const Color(0xFF18243A),
  surfaceSelected: const Color(0xFF233351),
  fg: const Color(0xFFF4F7FF),
  fgDim: const Color(0xFFC5CDE0),
  fgMuted: const Color(0xFF929DB8),
  fgFaint: const Color(0xFF69748F),
  borderSubtle: const Color(0xFF25324B),
  border: const Color(0xFF3A4B6A),
  borderHi: const Color(0xFF829DD0),
  accent: const Color(0xFF8FB4FF),
  accentInk: const Color(0xFF071020),
  accentDim: const Color(0xFF1C335C),
  accentPressed: const Color(0xFF76A0EF),
  success: const Color(0xFF91C97B),
  successSubtle: const Color(0xFF20351E),
  warning: const Color(0xFFE8B85E),
  warningSubtle: const Color(0xFF3A2D16),
  danger: const Color(0xFFEA817A),
  dangerSubtle: const Color(0xFF401E21),
  info: const Color(0xFFC6A7FF),
  infoSubtle: const Color(0xFF30264F),
  chartSeries: const [
    Color(0xFF8FB4FF),
    Color(0xFFC6A7FF),
    Color(0xFFF095B1),
    Color(0xFFE7B35E),
    Color(0xFF8FC478),
    Color(0xFFDE8560),
  ],
  anatomyBase: const Color(0xFF20283A),
  anatomyStroke: const Color(0xFF8290AD),
  anatomyInactive: const Color(0xFF34415B),
  anatomySelected: const Color(0xFFA9C4FF),
  loadLow: const Color(0xFF574766),
  loadHigh: const Color(0xFFE18475),
  displayFontFamily: 'JetBrains Mono',
  numFontFamily: 'JetBrains Mono',
);

final _bordeauxVelvet = _darkPalette(
  id: FittinPaletteId.bordeauxVelvet,
  bg: const Color(0xFF10070A),
  bgDeep: const Color(0xFF080305),
  surface: const Color(0xFF190B10),
  surfaceSolid: const Color(0xFF211117),
  surfaceHi: const Color(0xFF301820),
  surfaceSelected: const Color(0xFF43202B),
  fg: const Color(0xFFFCEFF2),
  fgDim: const Color(0xFFD7C2C7),
  fgMuted: const Color(0xFFA8878F),
  fgFaint: const Color(0xFF7A5F67),
  borderSubtle: const Color(0xFF3B222A),
  border: const Color(0xFF56313D),
  borderHi: const Color(0xFFB27684),
  accent: const Color(0xFFE3A3AF),
  accentInk: const Color(0xFF2B0C14),
  accentDim: const Color(0xFF4A2630),
  accentPressed: const Color(0xFFCF8C99),
  success: const Color(0xFFA5C77C),
  successSubtle: const Color(0xFF29351D),
  warning: const Color(0xFFD7B978),
  warningSubtle: const Color(0xFF3A2F1C),
  danger: const Color(0xFFEA7A83),
  dangerSubtle: const Color(0xFF471E27),
  info: const Color(0xFFB49DDB),
  infoSubtle: const Color(0xFF332744),
  chartSeries: const [
    Color(0xFFE3A3AF),
    Color(0xFFD7B978),
    Color(0xFFB49DDB),
    Color(0xFFE58162),
    Color(0xFF8EA9D6),
    Color(0xFFA6C47C),
  ],
  anatomyBase: const Color(0xFF362127),
  anatomyStroke: const Color(0xFF9A747D),
  anatomyInactive: const Color(0xFF57313C),
  anatomySelected: const Color(0xFFF1B7C0),
  loadLow: const Color(0xFF70414B),
  loadHigh: const Color(0xFFE98B72),
  displayFontFamily: 'Instrument Serif',
  numFontFamily: 'Instrument Sans',
);

final _porcelainInk = FittinTheme(
  paletteId: FittinPaletteId.porcelainInk,
  brightness: Brightness.light,
  bg: const Color(0xFFF3EEE5),
  bgDeep: const Color(0xFFE7DFD2),
  surface: const Color(0xFFF7F2EA),
  surfaceSolid: const Color(0xFFFBF8F2),
  surfaceHi: const Color(0xFFFFFFFF),
  surfaceSelected: const Color(0xFFF2DED7),
  fg: const Color(0xFF211D19),
  fgDim: const Color(0xFF514A43),
  fgMuted: const Color(0xFF746A61),
  fgFaint: const Color(0xFF938A81),
  fgInverse: const Color(0xFFFFFFFF),
  borderSubtle: const Color(0xFFDDD3C5),
  border: const Color(0xFFC6B9A9),
  borderHi: const Color(0xFF756657),
  divider: const Color(0xFFDDD3C5),
  focusRing: const Color(0xFF9E3A32),
  shadowSoft: const Color(0x29000000),
  shadowStrong: const Color(0x52000000),
  scrim: const Color(0x8F18130F),
  accent: const Color(0xFF9E3A32),
  accentInk: const Color(0xFFFFFFFF),
  accentDim: const Color(0xFFF0D8D2),
  accentPressed: const Color(0xFF832D27),
  success: const Color(0xFF376B37),
  successSubtle: const Color(0xFFDCEAD6),
  warning: const Color(0xFF80510C),
  warningSubtle: const Color(0xFFF1E3C1),
  danger: const Color(0xFFA33335),
  dangerSubtle: const Color(0xFFF1D6D4),
  info: const Color(0xFF294873),
  infoSubtle: const Color(0xFFD8E0EC),
  setCompleted: const Color(0xFF376B37),
  setSkipped: const Color(0xFFA33335),
  setCurrent: const Color(0xFF9E3A32),
  setUpcoming: const Color(0xFF766D64),
  gestureLog: const Color(0xFF376B37),
  gestureSkip: const Color(0xFFA33335),
  gestureNavigate: const Color(0xFF294873),
  chartGrid: const Color(0xFFDDD3C5),
  chartAxis: const Color(0xFF756657),
  chartLabel: const Color(0xFF514A43),
  chartSelection: const Color(0xFF9E3A32),
  chartTooltip: const Color(0xFFFFFFFF),
  chartSeries: const [
    Color(0xFF9E3A32),
    Color(0xFF294873),
    Color(0xFF734783),
    Color(0xFF94600F),
    Color(0xFF6F5C48),
    Color(0xFF5C7633),
  ],
  anatomyBase: const Color(0xFFE4D9CB),
  anatomyStroke: const Color(0xFF756657),
  anatomyInactive: const Color(0xFFC8B9A8),
  anatomySelected: const Color(0xFF9E3A32),
  loadLow: const Color(0xFFD7AE84),
  loadHigh: const Color(0xFFB53F32),
  pressedOverlay: const Color(0x14000000),
  selectedOverlay: const Color(0x1F9E3A32),
  disabledOverlay: const Color(0x0F000000),
  displayFontFamily: 'Instrument Serif',
  uiFontFamily: 'Instrument Sans',
  numFontFamily: 'Instrument Sans',
  displayWeight: FontWeight.w500,
  numWeight: FontWeight.w600,
  chartStyle: FittinChartStyle.smooth,
  radius: 18,
  radiusSm: 10,
  pad: 18,
  gap: 12,
  titleSize: 30,
  rowH: 50,
);

final _espressoEmber = _darkPalette(
  id: FittinPaletteId.espressoEmber,
  bg: const Color(0xFF100B08),
  bgDeep: const Color(0xFF090604),
  surface: const Color(0xFF17100B),
  surfaceSolid: const Color(0xFF20150F),
  surfaceHi: const Color(0xFF2D1E16),
  surfaceSelected: const Color(0xFF3C2619),
  fg: const Color(0xFFF7EBDD),
  fgDim: const Color(0xFFD0BEAA),
  fgMuted: const Color(0xFF9D8874),
  fgFaint: const Color(0xFF746252),
  borderSubtle: const Color(0xFF3B2A20),
  border: const Color(0xFF5A4030),
  borderHi: const Color(0xFFAC7B59),
  accent: const Color(0xFFE98A52),
  accentInk: const Color(0xFF261006),
  accentDim: const Color(0xFF4A281A),
  accentPressed: const Color(0xFFD7743F),
  success: const Color(0xFF9BC878),
  successSubtle: const Color(0xFF27351D),
  warning: const Color(0xFFE4B55D),
  warningSubtle: const Color(0xFF3C2D15),
  danger: const Color(0xFFE37B70),
  dangerSubtle: const Color(0xFF421F1A),
  info: const Color(0xFFBFA4D8),
  infoSubtle: const Color(0xFF332641),
  chartSeries: const [
    Color(0xFFE98A52),
    Color(0xFFBFA4D8),
    Color(0xFFE4B55D),
    Color(0xFFD7788B),
    Color(0xFF88A5D1),
    Color(0xFF9BC878),
  ],
  anatomyBase: const Color(0xFF33231A),
  anatomyStroke: const Color(0xFF997765),
  anatomyInactive: const Color(0xFF52392B),
  anatomySelected: const Color(0xFFF2A06E),
  loadLow: const Color(0xFF704333),
  loadHigh: const Color(0xFFF17C4B),
  displayFontFamily: 'Fraunces',
  numFontFamily: 'Instrument Sans',
);

final _graphiteOrchid = _darkPalette(
  id: FittinPaletteId.graphiteOrchid,
  bg: const Color(0xFF0D0D12),
  bgDeep: const Color(0xFF07070A),
  surface: const Color(0xFF15151C),
  surfaceSolid: const Color(0xFF1B1B24),
  surfaceHi: const Color(0xFF262532),
  surfaceSelected: const Color(0xFF342F42),
  fg: const Color(0xFFF5F1F7),
  fgDim: const Color(0xFFC8C0CC),
  fgMuted: const Color(0xFF958C9D),
  fgFaint: const Color(0xFF706878),
  borderSubtle: const Color(0xFF302E39),
  border: const Color(0xFF484452),
  borderHi: const Color(0xFF8C809B),
  accent: const Color(0xFFC6A0DF),
  accentInk: const Color(0xFF1D1026),
  accentDim: const Color(0xFF3B2948),
  accentPressed: const Color(0xFFB58BCD),
  success: const Color(0xFF9AC57B),
  successSubtle: const Color(0xFF26351F),
  warning: const Color(0xFFE1B565),
  warningSubtle: const Color(0xFF3C2E19),
  danger: const Color(0xFFE27B82),
  dangerSubtle: const Color(0xFF421F26),
  info: const Color(0xFF91A8D8),
  infoSubtle: const Color(0xFF242C45),
  chartSeries: const [
    Color(0xFFC6A0DF),
    Color(0xFFE1A45F),
    Color(0xFFE68199),
    Color(0xFF91A8D8),
    Color(0xFFA6C27B),
    Color(0xFFD6C17B),
  ],
  anatomyBase: const Color(0xFF292731),
  anatomyStroke: const Color(0xFF8F8799),
  anatomyInactive: const Color(0xFF403C4B),
  anatomySelected: const Color(0xFFD4AFE9),
  loadLow: const Color(0xFF65455F),
  loadHigh: const Color(0xFFE48377),
  displayFontFamily: 'Instrument Serif',
  numFontFamily: 'Instrument Sans',
);

final _inkSaffron = _darkPalette(
  id: FittinPaletteId.inkSaffron,
  bg: const Color(0xFF090A0E),
  bgDeep: const Color(0xFF040509),
  surface: const Color(0xFF11131A),
  surfaceSolid: const Color(0xFF171A22),
  surfaceHi: const Color(0xFF222631),
  surfaceSelected: const Color(0xFF332E20),
  fg: const Color(0xFFF4F1E9),
  fgDim: const Color(0xFFC8C2B4),
  fgMuted: const Color(0xFF918B80),
  fgFaint: const Color(0xFF69655E),
  borderSubtle: const Color(0xFF2D3038),
  border: const Color(0xFF444854),
  borderHi: const Color(0xFF8E8D86),
  accent: const Color(0xFFE2B85D),
  accentInk: const Color(0xFF201708),
  accentDim: const Color(0xFF40351F),
  accentPressed: const Color(0xFFCCA34C),
  success: const Color(0xFF96C176),
  successSubtle: const Color(0xFF24331C),
  warning: const Color(0xFFE4AF58),
  warningSubtle: const Color(0xFF3C2B16),
  danger: const Color(0xFFE07970),
  dangerSubtle: const Color(0xFF401E1B),
  info: const Color(0xFFA58AD0),
  infoSubtle: const Color(0xFF2B2340),
  chartSeries: const [
    Color(0xFFE2B85D),
    Color(0xFFA58AD0),
    Color(0xFFE07C72),
    Color(0xFF899FCB),
    Color(0xFF99BD73),
    Color(0xFFD68B57),
  ],
  anatomyBase: const Color(0xFF26272B),
  anatomyStroke: const Color(0xFF87888D),
  anatomyInactive: const Color(0xFF3B3D44),
  anatomySelected: const Color(0xFFF0C56D),
  loadLow: const Color(0xFF615047),
  loadHigh: const Color(0xFFE3885B),
  displayFontFamily: 'JetBrains Mono',
  numFontFamily: 'JetBrains Mono',
);

final _oliveManuscript = _darkPalette(
  id: FittinPaletteId.oliveManuscript,
  bg: const Color(0xFF0D0E09),
  bgDeep: const Color(0xFF070804),
  surface: const Color(0xFF15170F),
  surfaceSolid: const Color(0xFF1C1F15),
  surfaceHi: const Color(0xFF282C1D),
  surfaceSelected: const Color(0xFF353A24),
  fg: const Color(0xFFF2F0E1),
  fgDim: const Color(0xFFC5C2AD),
  fgMuted: const Color(0xFF918F7C),
  fgFaint: const Color(0xFF6C6A5B),
  borderSubtle: const Color(0xFF303326),
  border: const Color(0xFF484C38),
  borderHi: const Color(0xFF8D906E),
  accent: const Color(0xFFBEC17A),
  accentInk: const Color(0xFF171907),
  accentDim: const Color(0xFF373A20),
  accentPressed: const Color(0xFFA8AC63),
  success: const Color(0xFF8FC271),
  successSubtle: const Color(0xFF23341B),
  warning: const Color(0xFFD9B15F),
  warningSubtle: const Color(0xFF392D16),
  danger: const Color(0xFFD97870),
  dangerSubtle: const Color(0xFF3D1F1B),
  info: const Color(0xFFAA8FC9),
  infoSubtle: const Color(0xFF2E2540),
  chartSeries: const [
    Color(0xFFBEC17A),
    Color(0xFFD58662),
    Color(0xFFAA8FC9),
    Color(0xFFD2AF65),
    Color(0xFF879AC1),
    Color(0xFFD47A86),
  ],
  anatomyBase: const Color(0xFF292B20),
  anatomyStroke: const Color(0xFF898B72),
  anatomyInactive: const Color(0xFF414431),
  anatomySelected: const Color(0xFFD0D38A),
  loadLow: const Color(0xFF5C5140),
  loadHigh: const Color(0xFFD9855C),
);

FittinTheme themeFromCustomPalette(CustomThemePalette palette) {
  palette.validate();
  final baseId = FittinPaletteRegistry.decode(palette.basePaletteKey);
  final base = FittinPaletteRegistry.themeOf(baseId);
  final dark = palette.brightness == Brightness.dark;
  final bg = palette.color('background');
  final surface = palette.color('surface');
  final fg = palette.color('foreground');
  final fgMuted = palette.color('mutedForeground');
  final accent = palette.color('accent');
  final accentInk = palette.color('accentInk');
  final strength = palette.color('strength');
  final cardio = palette.color('cardio');
  final success = palette.color('success');
  final warning = palette.color('warning');
  final danger = palette.color('danger');
  Color mix(Color left, Color right, double amount) =>
      Color.lerp(left, right, amount)!;
  final surfaceHi = mix(surface, fg, dark ? 0.09 : 0.045);
  final border = mix(surface, fg, dark ? 0.22 : 0.18);
  final borderHi = mix(surface, fg, dark ? 0.48 : 0.54);
  return FittinTheme(
    paletteId: baseId,
    brightness: palette.brightness,
    bg: bg,
    bgDeep: mix(bg, dark ? Colors.black : fg, dark ? 0.35 : 0.06),
    surface: mix(bg, surface, 0.72),
    surfaceSolid: surface,
    surfaceHi: surfaceHi,
    surfaceSelected: mix(surface, accent, dark ? 0.18 : 0.10),
    fg: fg,
    fgDim: mix(fgMuted, fg, 0.30),
    fgMuted: fgMuted,
    fgFaint: mix(fgMuted, bg, 0.28),
    fgInverse: accentInk,
    borderSubtle: mix(surface, fg, dark ? 0.13 : 0.10),
    border: border,
    borderHi: borderHi,
    divider: mix(surface, fg, dark ? 0.13 : 0.10),
    focusRing: accent,
    shadowSoft: Colors.black.withValues(alpha: dark ? 0.32 : 0.12),
    shadowStrong: Colors.black.withValues(alpha: dark ? 0.68 : 0.28),
    scrim: Colors.black.withValues(alpha: dark ? 0.76 : 0.54),
    accent: accent,
    accentInk: accentInk,
    accentDim: mix(surface, accent, dark ? 0.22 : 0.14),
    accentPressed: mix(accent, accentInk, dark ? 0.12 : 0.16),
    success: success,
    successSubtle: mix(surface, success, dark ? 0.20 : 0.12),
    warning: warning,
    warningSubtle: mix(surface, warning, dark ? 0.20 : 0.12),
    danger: danger,
    dangerSubtle: mix(surface, danger, dark ? 0.20 : 0.12),
    info: cardio,
    infoSubtle: mix(surface, cardio, dark ? 0.18 : 0.10),
    setCompleted: success,
    setSkipped: danger,
    setCurrent: accent,
    setUpcoming: fgMuted,
    gestureLog: success,
    gestureSkip: danger,
    gestureNavigate: cardio,
    chartGrid: mix(surface, fg, dark ? 0.13 : 0.10),
    chartAxis: borderHi,
    chartLabel: mix(fgMuted, fg, 0.30),
    chartSelection: accent,
    chartTooltip: surfaceHi,
    chartSeries: [strength, cardio, accent, warning, danger, success],
    anatomyBase: mix(surface, fg, dark ? 0.08 : 0.12),
    anatomyStroke: borderHi,
    anatomyInactive: border,
    anatomySelected: accent,
    loadLow: mix(surface, strength, dark ? 0.28 : 0.18),
    loadHigh: strength,
    pressedOverlay: fg.withValues(alpha: dark ? 0.08 : 0.06),
    selectedOverlay: accent.withValues(alpha: dark ? 0.14 : 0.10),
    disabledOverlay: fg.withValues(alpha: 0.05),
    displayFontFamily: base.displayFontFamily,
    uiFontFamily: base.uiFontFamily,
    numFontFamily: base.numFontFamily,
    displayWeight: base.displayWeight,
    numWeight: base.numWeight,
    chartStyle: base.chartStyle,
    radius: base.radius,
    radiusSm: base.radiusSm,
    pad: base.pad,
    gap: base.gap,
    titleSize: base.titleSize,
    rowH: base.rowH,
  );
}
