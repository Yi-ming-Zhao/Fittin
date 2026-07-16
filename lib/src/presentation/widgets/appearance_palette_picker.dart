import 'dart:async';

import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppearancePalettePicker extends ConsumerWidget {
  const AppearancePalettePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context, ref);
    final theme = ref.watch(resolvedFittinThemeProvider);
    final selectedPalette = ref.watch(fittinThemeProvider);
    final palettes = FittinPaletteRegistry.ids;

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
          label: strings.selectedPaletteLabel(
            strings.paletteName(selectedPalette),
          ),
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
                      strings.selectedPaletteLabel(
                        strings.paletteName(selectedPalette),
                      ),
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
              final paletteId = palettes[index];
              final previewTheme = FittinPaletteRegistry.themeOf(paletteId);
              final selected = paletteId == selectedPalette;
              final name = strings.paletteName(paletteId);

              return _PalettePreviewTile(
                key: ValueKey('appearance-palette-${paletteId.storageKey}'),
                theme: previewTheme,
                name: name,
                description: strings.paletteDescription(paletteId),
                semanticsLabel: strings.palettePreviewSemantics(
                  name,
                  selected: selected,
                ),
                selected: selected,
                onTap: () => unawaited(
                  ref.read(fittinThemeProvider.notifier).setPalette(paletteId),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
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
