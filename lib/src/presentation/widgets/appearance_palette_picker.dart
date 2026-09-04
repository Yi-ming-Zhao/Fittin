import 'dart:async';

import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/application/user_content_provider.dart';
import 'package:fittin_v2/src/domain/models/custom_theme_palette.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/screens/theme_palette_library_screen.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppearancePalettePicker extends ConsumerWidget {
  const AppearancePalettePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context, ref);
    final theme = ref.watch(resolvedFittinThemeProvider);
    final selectedKey = ref.watch(fittinThemeProvider);
    final customPalettes =
        ref.watch(customThemePalettesProvider).valueOrNull ?? const [];
    final palettes = <_AppearancePaletteOption>[
      for (final id in FittinPaletteRegistry.ids)
        _AppearancePaletteOption(
          key: id.storageKey,
          theme: FittinPaletteRegistry.themeOf(id),
          name: strings.paletteName(id),
          description: strings.paletteDescription(id),
          builtInId: id,
        ),
      for (final palette in customPalettes)
        _AppearancePaletteOption(
          key: palette.id,
          theme: themeFromCustomPalette(palette),
          name: palette.name,
          description: strings.isChinese
              ? '你的自定义语义配色'
              : 'Your custom semantic palette',
          customPalette: palette,
        ),
    ];
    final selectedOption = palettes
        .where((option) => option.key == selectedKey)
        .firstOrNull;
    final selectedName =
        selectedOption?.name ??
        strings.paletteName(FittinPaletteRegistry.defaultId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.appearanceDescription,
          style: theme.uiStyle(14, theme.fgDim).copyWith(height: 1.45),
        ),
        const SizedBox(height: 14),
        Semantics(
          liveRegion: true,
          label: strings.selectedPaletteLabel(selectedName),
          child: ExcludeSemantics(
            child: Container(
              key: const ValueKey('appearance-current-palette'),
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.surfaceSolid,
                borderRadius: BorderRadius.circular(theme.radiusSm),
                border: Border.all(color: theme.borderSubtle),
              ),
              child: Row(
                children: [
                  Icon(Icons.palette_outlined, size: 18, color: theme.accent),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      strings.selectedPaletteLabel(selectedName),
                      style: theme
                          .uiStyle(13, theme.fg, FontWeight.w700)
                          .copyWith(height: 1.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Icon(Icons.swipe_rounded, size: 17, color: theme.fgMuted),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                strings.appearanceCompareHint,
                style: theme.uiStyle(12, theme.fgMuted),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 212,
          child: ListView.separated(
            key: const ValueKey('appearance-palette-list'),
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.only(right: 20),
            itemCount: palettes.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final option = palettes[index];
              final selected = option.key == selectedKey;

              return _PalettePreviewTile(
                key: ValueKey('appearance-palette-${option.key}'),
                theme: option.theme,
                name: option.name,
                description: option.description,
                semanticsLabel: strings.palettePreviewSemantics(
                  option.name,
                  selected: selected,
                ),
                selected: selected,
                onTap: () => unawaited(
                  option.builtInId != null
                      ? ref
                            .read(fittinThemeProvider.notifier)
                            .setPalette(option.builtInId!)
                      : ref
                            .read(fittinThemeProvider.notifier)
                            .setCustomPalette(option.customPalette!),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ThemePaletteLibraryScreen(),
              ),
            ),
            icon: const Icon(Icons.tune_rounded),
            label: Text(
              strings.isChinese ? '管理与创建配色' : 'Manage and create palettes',
            ),
          ),
        ),
      ],
    );
  }
}

class _AppearancePaletteOption {
  const _AppearancePaletteOption({
    required this.key,
    required this.theme,
    required this.name,
    required this.description,
    this.builtInId,
    this.customPalette,
  });

  final String key;
  final FittinTheme theme;
  final String name;
  final String description;
  final FittinPaletteId? builtInId;
  final CustomThemePalette? customPalette;
}

class _PalettePreviewTile extends StatelessWidget {
  const _PalettePreviewTile({
    super.key,
    required this.theme,
    required this.name,
    required this.description,
    required this.semanticsLabel,
    required this.selected,
    required this.onTap,
  });

  final FittinTheme theme;
  final String name;
  final String description;
  final String semanticsLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final previewColors = [
      theme.bg,
      theme.surfaceSolid,
      theme.accent,
      theme.fg,
      ...theme.chartSeries.take(2),
    ];

    return Semantics(
      button: true,
      selected: selected,
      label: semanticsLabel,
      onTap: onTap,
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              width: 224,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: theme.bg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? theme.accent : theme.border,
                  width: selected ? 2 : 1,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: theme.accent.withValues(alpha: 0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme
                              .uiStyle(14, theme.fg, FontWeight.w800)
                              .copyWith(height: 1.15),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected ? theme.accent : theme.surfaceSolid,
                          border: Border.all(
                            color: selected ? theme.accent : theme.borderHi,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: selected
                            ? Icon(
                                Icons.check_rounded,
                                size: 17,
                                color: theme.accentInk,
                              )
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.uiStyle(11, theme.fgDim).copyWith(height: 1.3),
                  ),
                  const Spacer(),
                  _PaletteComposition(theme: theme),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (var index = 0; index < previewColors.length; index++)
                        Expanded(
                          child: Container(
                            height: 8,
                            margin: EdgeInsets.only(
                              right: index == previewColors.length - 1 ? 0 : 4,
                            ),
                            decoration: BoxDecoration(
                              color: previewColors[index],
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: theme.borderSubtle,
                                width: 0.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}

class _PaletteComposition extends StatelessWidget {
  const _PaletteComposition({required this.theme});

  final FittinTheme theme;

  @override
  Widget build(BuildContext context) {
    final series = theme.chartSeries;
    return Container(
      height: 70,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: theme.surfaceSolid,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: theme.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              height: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.surfaceHi,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.fg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 55,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.fgMuted,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 30,
                    height: 6,
                    decoration: BoxDecoration(
                      color: theme.accent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            flex: 4,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var index = 0; index < 4; index++) ...[
                  Expanded(
                    child: Container(
                      height: [18.0, 33.0, 25.0, 43.0][index],
                      decoration: BoxDecoration(
                        color: series[index % series.length],
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  if (index != 3) const SizedBox(width: 3),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
