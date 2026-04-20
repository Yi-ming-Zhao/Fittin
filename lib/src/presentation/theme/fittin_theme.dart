import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Direction presets — each is a complete set of visual tokens
enum FittinDirection { editorial, technical, clay }

/// Accent color presets
enum FittinAccent { bone, lime, terracotta, sky, plum, ember }

/// Background tone presets
enum FittinBg { trueBlack, warmBlack, charcoal, warmCharcoal }

/// Type family presets
enum FittinTypeFamily { editorial, technical, clay, neutral }

/// Density presets
enum FittinDensity { comfortable, compact }

/// Card style variants
enum FittinCardStyle { glass, flat, bordered }

/// Chart style variants
enum FittinChartStyle { step, linear, smooth, area }

/// Resolved theme tokens — passed to all screen components
class FittinTheme {
  final Color bg;
  final Color bgDeep;
  final Color surface;
  final Color surfaceSolid;
  final Color surfaceHi;
  final Color border;
  final Color borderHi;
  final Color fg;
  final Color fgDim;
  final Color fgMuted;
  final Color fgFaint;
  final Color accent;
  final Color accentInk;
  final Color accentDim;
  final String displayFontFamily;
  final String uiFontFamily;
  final String numFontFamily;
  final FontWeight displayWeight;
  final FontWeight numWeight;
  final FittinChartStyle chartStyle;
  final Color chartStroke;
  final Color chartGrid;
  final Color chartDot;
  final double radius;
  final double radiusSm;
  final double pad;
  final double gap;
  final double titleSize;
  final double rowH;

  const FittinTheme({
    required this.bg,
    required this.bgDeep,
    required this.surface,
    required this.surfaceSolid,
    required this.surfaceHi,
    required this.border,
    required this.borderHi,
    required this.fg,
    required this.fgDim,
    required this.fgMuted,
    required this.fgFaint,
    required this.accent,
    required this.accentInk,
    required this.accentDim,
    required this.displayFontFamily,
    required this.uiFontFamily,
    required this.numFontFamily,
    required this.displayWeight,
    required this.numWeight,
    required this.chartStyle,
    required this.chartStroke,
    required this.chartGrid,
    required this.chartDot,
    required this.radius,
    required this.radiusSm,
    required this.pad,
    required this.gap,
    required this.titleSize,
    required this.rowH,
  });

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

  TextStyle eyebrowStyle() => _font(
        uiFontFamily,
        10,
        FontWeight.w500,
        fgMuted,
        letterSpacing: 1.8,
      );

  TextStyle _font(
    String family,
    double size,
    FontWeight weight,
    Color color, {
    double letterSpacing = 0,
  }) {
    if (family.contains('Fraunces')) {
      return GoogleFonts.fraunces(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );
    }
    if (family.contains('JetBrains Mono')) {
      return GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );
    }
    if (family.contains('Instrument Serif')) {
      return GoogleFonts.instrumentSerif(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );
    }
    if (family.contains('Instrument Sans')) {
      return GoogleFonts.instrumentSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );
    }
    // Default: Inter
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  /// Resolve a theme from a direction + optional tweaks
  static FittinTheme resolve({
    required FittinDirection direction,
    FittinAccent? accent,
    FittinBg? bg,
    FittinTypeFamily? typeFamily,
    FittinChartStyle? chart,
    FittinCardStyle? card,
    FittinDensity? density,
  }) {
    final base = _directions[direction]!;
    final accentTokens = _accents[accent ?? _directionAccent[direction]!]!;
    final bgTokens = _bgs[bg ?? _directionBg[direction]!]!;
    final typeTokens = _typeFamilies[typeFamily ?? _directionType[direction]!]!;
    final densityTokens = _densities[density ?? FittinDensity.comfortable]!;

    return FittinTheme(
      bg: bgTokens.bg,
      bgDeep: bgTokens.bgDeep,
      surface: _withOpacity(base.surface, bgTokens.surfaceOpacity),
      surfaceSolid: bgTokens.surfaceSolid,
      surfaceHi: _withOpacity(base.surfaceHi, 0.7),
      border: _withOpacity(bgTokens.border, 1),
      borderHi: _withOpacity(bgTokens.borderHi, 1),
      fg: bgTokens.fg,
      fgDim: _withOpacity(bgTokens.fg, 0.62),
      fgMuted: _withOpacity(bgTokens.fg, 0.38),
      fgFaint: _withOpacity(bgTokens.fg, 0.16),
      accent: accentTokens.color,
      accentInk: accentTokens.ink,
      accentDim: _withOpacity(accentTokens.color, 0.2),
      displayFontFamily: typeTokens.display,
      uiFontFamily: typeTokens.ui,
      numFontFamily: typeTokens.num,
      displayWeight: base.displayWeight,
      numWeight: base.numWeight,
      chartStyle: chart ?? FittinChartStyle.step,
      chartStroke: accentTokens.color,
      chartGrid: _withOpacity(bgTokens.fg, 0.06),
      chartDot: accentTokens.color,
      radius: base.radius,
      radiusSm: base.radiusSm,
      pad: densityTokens.pad,
      gap: densityTokens.gap,
      titleSize: densityTokens.titleSize,
      rowH: densityTokens.rowH,
    );
  }

  static Color _withOpacity(Color color, double opacity) =>
      color.withValues(alpha: opacity);
}

// ─── Internal token maps ───────────────────────────────────────────────────

final _directionAccent = {
  FittinDirection.editorial: FittinAccent.bone,
  FittinDirection.technical: FittinAccent.lime,
  FittinDirection.clay: FittinAccent.terracotta,
};

final _directionBg = {
  FittinDirection.editorial: FittinBg.warmBlack,
  FittinDirection.technical: FittinBg.trueBlack,
  FittinDirection.clay: FittinBg.warmCharcoal,
};

final _directionType = {
  FittinDirection.editorial: FittinTypeFamily.editorial,
  FittinDirection.technical: FittinTypeFamily.technical,
  FittinDirection.clay: FittinTypeFamily.clay,
};

/// Base tokens per direction (without bg/accent variations)
final _directions = {
  FittinDirection.editorial: _DirectionTokens(
    surface: const Color(0xFF1C1A18),
    surfaceHi: const Color(0xFF282620),
    displayWeight: FontWeight.w400,
    numWeight: FontWeight.w400,
    radius: 20,
    radiusSm: 12,
  ),
  FittinDirection.technical: _DirectionTokens(
    surface: const Color(0xFF121412),
    surfaceHi: const Color(0xFF1C201C),
    displayWeight: FontWeight.w500,
    numWeight: FontWeight.w500,
    radius: 16,
    radiusSm: 8,
  ),
  FittinDirection.clay: _DirectionTokens(
    surface: const Color(0xFF241E1A),
    surfaceHi: const Color(0xFF302824),
    displayWeight: FontWeight.w400,
    numWeight: FontWeight.w500,
    radius: 22,
    radiusSm: 14,
  ),
};

final _accents = {
  FittinAccent.bone: _AccentTokens(
    color: const Color(0xFFF3ECE0),
    ink: const Color(0xFF0C0B0A),
  ),
  FittinAccent.lime: _AccentTokens(
    color: const Color(0xFFA8B89C),
    ink: const Color(0xFF0A0B0A),
  ),
  FittinAccent.terracotta: _AccentTokens(
    color: const Color(0xFFC4734F),
    ink: const Color(0xFF1B1512),
  ),
  FittinAccent.sky: _AccentTokens(
    color: const Color(0xFF7BAFD4),
    ink: const Color(0xFF091017),
  ),
  FittinAccent.plum: _AccentTokens(
    color: const Color(0xFFB87AA8),
    ink: const Color(0xFF1A0F18),
  ),
  FittinAccent.ember: _AccentTokens(
    color: const Color(0xFFD4734A),
    ink: const Color(0xFF180806),
  ),
};

final _bgs = {
  FittinBg.trueBlack: _BgTokens(
    bg: const Color(0xFF000000),
    bgDeep: const Color(0xFF000000),
    surfaceSolid: const Color(0xFF0E0E0E),
    surfaceOpacity: 0.6,
    border: const Color(0xFFFFFFFF),
    borderHi: const Color(0xFFFFFFFF),
    fg: const Color(0xFFE8ECE4),
  ),
  FittinBg.warmBlack: _BgTokens(
    bg: const Color(0xFF0C0B0A),
    bgDeep: const Color(0xFF070605),
    surfaceSolid: const Color(0xFF161412),
    surfaceOpacity: 0.55,
    border: const Color(0xFFF5F5E6),
    borderHi: const Color(0xFFF5F5E6),
    fg: const Color(0xFFF3ECE0),
  ),
  FittinBg.charcoal: _BgTokens(
    bg: const Color(0xFF141416),
    bgDeep: const Color(0xFF0A0A0C),
    surfaceSolid: const Color(0xFF1A1A1C),
    surfaceOpacity: 0.55,
    border: const Color(0xFFFFFFFF),
    borderHi: const Color(0xFFFFFFFF),
    fg: const Color(0xFFE8E8EC),
  ),
  FittinBg.warmCharcoal: _BgTokens(
    bg: const Color(0xFF141110),
    bgDeep: const Color(0xFF0C0A09),
    surfaceSolid: const Color(0xFF1E1A17),
    surfaceOpacity: 0.55,
    border: const Color(0xFFE8DCC8),
    borderHi: const Color(0xFFE8DCC8),
    fg: const Color(0xFFECE2D0),
  ),
};

final _typeFamilies = {
  FittinTypeFamily.editorial: _TypeTokens(
    display: 'Fraunces',
    ui: 'Inter',
    num: 'Fraunces',
  ),
  FittinTypeFamily.technical: _TypeTokens(
    display: 'JetBrains Mono',
    ui: 'Inter',
    num: 'JetBrains Mono',
  ),
  FittinTypeFamily.clay: _TypeTokens(
    display: 'Instrument Serif',
    ui: 'Instrument Sans',
    num: 'Instrument Sans',
  ),
  FittinTypeFamily.neutral: _TypeTokens(
    display: 'Inter',
    ui: 'Inter',
    num: 'Inter',
  ),
};

final _densities = {
  FittinDensity.comfortable: _DensityTokens(
    pad: 20,
    gap: 16,
    titleSize: 34,
    rowH: 56,
  ),
  FittinDensity.compact: _DensityTokens(
    pad: 14,
    gap: 10,
    titleSize: 28,
    rowH: 44,
  ),
};

// ─── Token helper classes ─────────────────────────────────────────────────

class _DirectionTokens {
  final Color surface;
  final Color surfaceHi;
  final FontWeight displayWeight;
  final FontWeight numWeight;
  final double radius;
  final double radiusSm;

  const _DirectionTokens({
    required this.surface,
    required this.surfaceHi,
    required this.displayWeight,
    required this.numWeight,
    required this.radius,
    required this.radiusSm,
  });
}

class _AccentTokens {
  final Color color;
  final Color ink;

  const _AccentTokens({required this.color, required this.ink});
}

class _BgTokens {
  final Color bg;
  final Color bgDeep;
  final Color surfaceSolid;
  final double surfaceOpacity;
  final Color border;
  final Color borderHi;
  final Color fg;

  const _BgTokens({
    required this.bg,
    required this.bgDeep,
    required this.surfaceSolid,
    required this.surfaceOpacity,
    required this.border,
    required this.borderHi,
    required this.fg,
  });
}

class _TypeTokens {
  final String display;
  final String ui;
  final String num;

  const _TypeTokens({
    required this.display,
    required this.ui,
    required this.num,
  });
}

class _DensityTokens {
  final double pad;
  final double gap;
  final double titleSize;
  final double rowH;

  const _DensityTokens({
    required this.pad,
    required this.gap,
    required this.titleSize,
    required this.rowH,
  });
}
