import 'dart:math' as math;
import 'package:flutter/material.dart';

class CustomThemePalette {
  CustomThemePalette({
    required this.id,
    required String name,
    required this.brightness,
    required Map<String, String> colors,
    this.basePaletteKey = 'obsidianBrass',
  }) : name = name.trim(),
       colors = Map.unmodifiable(colors) {
    validate();
  }

  static const requiredColorRoles = {
    'background',
    'surface',
    'foreground',
    'mutedForeground',
    'accent',
    'accentInk',
    'strength',
    'cardio',
    'success',
    'warning',
    'danger',
  };

  static const allowedBasePaletteKeys = {
    'obsidianBrass',
    'midnightCobalt',
    'bordeauxVelvet',
    'porcelainInk',
    'espressoEmber',
    'graphiteOrchid',
    'inkSaffron',
    'oliveManuscript',
  };

  final String id;
  final String name;
  final Brightness brightness;
  final Map<String, String> colors;
  final String basePaletteKey;

  Color color(String role) => parseHexColor(colors[role]!);

  void validate() {
    if (id.trim() != id ||
        !id.startsWith('user-palette:') ||
        id.length == 'user-palette:'.length ||
        id.length > 120) {
      throw const FormatException('Custom palette ID is invalid.');
    }
    if (name.isEmpty ||
        name.length > 48 ||
        RegExp(r'[\u0000-\u001F\u007F]').hasMatch(name)) {
      throw const FormatException('Custom palette name is invalid.');
    }
    if (!allowedBasePaletteKeys.contains(basePaletteKey)) {
      throw const FormatException('Custom palette base is invalid.');
    }
    if (colors.keys.toSet().length != requiredColorRoles.length ||
        !colors.keys.toSet().containsAll(requiredColorRoles)) {
      throw const FormatException(
        'Custom palette must contain exactly the supported color roles.',
      );
    }
    for (final entry in colors.entries) {
      if (entry.value.trim() != entry.value ||
          !RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(entry.value)) {
        throw FormatException(
          'Custom palette colors must be opaque #RRGGBB values: ${entry.key}.',
        );
      }
      final value = parseHexColor(entry.value);
      if (isFittinCyanOrTeal(value)) {
        throw FormatException('Cyan and teal are not allowed: ${entry.key}.');
      }
    }
    _requireContrast('foreground', 'background', 4.5);
    _requireContrast('foreground', 'surface', 4.5);
    _requireContrast('mutedForeground', 'background', 3.0);
    _requireContrast('accent', 'accentInk', 4.5);
    for (final role in const [
      'strength',
      'cardio',
      'success',
      'warning',
      'danger',
    ]) {
      _requireContrast(role, 'surface', 3.0);
    }
    if (colorDistance(color('strength'), color('cardio')) < 0.22) {
      throw const FormatException(
        'Strength and cardio colors must be visually distinct.',
      );
    }
  }

  void _requireContrast(String foreground, String background, double minimum) {
    final ratio = contrastRatio(color(foreground), color(background));
    if (ratio < minimum) {
      throw FormatException(
        '$foreground/$background contrast ${ratio.toStringAsFixed(2)} is below $minimum.',
      );
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'brightness': brightness.name,
    'colors': colors,
    'basePaletteKey': basePaletteKey,
  };

  factory CustomThemePalette.fromJson(Map<String, dynamic> json) =>
      CustomThemePalette(
        id: json['id'] as String,
        name: json['name'] as String,
        brightness: Brightness.values.byName(json['brightness'] as String),
        colors: (json['colors'] as Map).cast<String, String>(),
        basePaletteKey: json['basePaletteKey'] as String? ?? 'obsidianBrass',
      );
}

Color parseHexColor(String source) {
  final normalized = source.trim().replaceFirst('#', '');
  if (!RegExp(r'^[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$').hasMatch(normalized)) {
    throw FormatException('Invalid color value: $source.');
  }
  final value = int.parse(
    normalized.length == 6 ? 'FF$normalized' : normalized,
    radix: 16,
  );
  return Color(value);
}

String colorToHex(Color color) =>
    '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

double contrastRatio(Color first, Color second) {
  final high = math.max(first.computeLuminance(), second.computeLuminance());
  final low = math.min(first.computeLuminance(), second.computeLuminance());
  return (high + 0.05) / (low + 0.05);
}

double colorDistance(Color first, Color second) {
  final dr = first.r - second.r;
  final dg = first.g - second.g;
  final db = first.b - second.b;
  return math.sqrt(dr * dr + dg * dg + db * db) / math.sqrt(3);
}

bool isFittinCyanOrTeal(Color color) {
  final hsl = HSLColor.fromColor(color);
  return hsl.saturation > 0.12 && hsl.hue >= 130 && hsl.hue <= 200;
}
