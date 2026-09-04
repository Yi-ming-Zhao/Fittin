import 'dart:async';

import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/application/user_content_provider.dart';
import 'package:fittin_v2/src/domain/models/custom_theme_palette.dart';
import 'package:fittin_v2/src/domain/models/user_content.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemePaletteLibraryScreen extends ConsumerWidget {
  const ThemePaletteLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context, ref);
    final theme = ref.watch(resolvedFittinThemeProvider);
    final palettes = ref.watch(customThemePalettesProvider);
    final selectedKey = ref.watch(fittinThemeProvider);
    return DashboardPageScaffold(
      layout: DashboardPageLayout.detail,
      children: [
        DashboardScreenHeader(
          eyebrow: strings.isChinese ? '外观' : 'APPEARANCE',
          title: strings.isChinese ? '配色方案库' : 'Palette library',
          subtitle: strings.isChinese
              ? '系统配色不可改写；你可以创建语义化配色，背景、文字、线条和图表会一起更新。'
              : 'Built-ins stay immutable. Custom semantic palettes update backgrounds, type, lines, and charts together.',
          showBackButton: true,
          trailing: IconButton.filledTonal(
            tooltip: strings.isChinese ? '新建配色' : 'New palette',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const CustomPaletteEditorScreen(),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
          ),
        ),
        const SizedBox(height: 20),
        DashboardSectionLabel(
          label: strings.isChinese ? '我的配色' : 'MY PALETTES',
        ),
        const SizedBox(height: 10),
        palettes.when(
          data: (items) => items.isEmpty
              ? DashboardSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.isChinese
                            ? '还没有自定义配色'
                            : 'No custom palettes yet',
                        style: theme.uiStyle(15, theme.fg, FontWeight.w700),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        strings.isChinese
                            ? '从任一系统方案开始，只调整真正影响体验的语义颜色。'
                            : 'Start from any built-in and adjust only meaningful semantic colors.',
                        style: theme
                            .uiStyle(13, theme.fgDim)
                            .copyWith(height: 1.4),
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CustomPaletteEditorScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.add_rounded),
                        label: Text(
                          strings.isChinese ? '创建第一套' : 'Create palette',
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    for (final palette in items) ...[
                      _CustomPaletteRow(
                        palette: palette,
                        selected: selectedKey == palette.id,
                        onSelect: () => unawaited(
                          ref
                              .read(fittinThemeProvider.notifier)
                              .setCustomPalette(palette),
                        ),
                        onEdit: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                CustomPaletteEditorScreen(existing: palette),
                          ),
                        ),
                        onCopy: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                CustomPaletteEditorScreen(seedPalette: palette),
                          ),
                        ),
                        onDelete: () => _delete(context, ref, palette),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text(error.toString()),
        ),
        const SizedBox(height: 20),
        DashboardSectionLabel(
          label: strings.isChinese ? '系统配色' : 'BUILT-IN PALETTES',
        ),
        const SizedBox(height: 10),
        for (final id in FittinPaletteRegistry.ids) ...[
          _BuiltInPaletteRow(
            id: id,
            selected: selectedKey == id.storageKey,
            onSelect: () => unawaited(
              ref.read(fittinThemeProvider.notifier).setPalette(id),
            ),
            onCopy: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CustomPaletteEditorScreen(seedBase: id),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    CustomThemePalette palette,
  ) async {
    final strings = AppStrings.of(context, ref);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          strings.isChinese
              ? '删除“${palette.name}”？'
              : 'Delete “${palette.name}”?',
        ),
        content: Text(
          strings.isChinese
              ? '删除会正常同步；如果正在使用它，将切回黑曜黄铜。'
              : 'The deletion will sync. If active, Obsidian Brass will be restored.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(strings.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final document = ref
        .read(customThemePaletteDocumentsProvider)
        .valueOrNull
        ?.where((item) => item.id == palette.id)
        .firstOrNull;
    if (ref.read(fittinThemeProvider) == palette.id) {
      await ref
          .read(fittinThemeProvider.notifier)
          .setPalette(FittinPaletteRegistry.defaultId);
    }
    await ref
        .read(userContentServiceProvider)
        .delete(
          palette.id,
          UserContentKind.customThemePalette,
          expectedVersion: document?.version,
        );
  }
}

class CustomPaletteEditorScreen extends ConsumerStatefulWidget {
  const CustomPaletteEditorScreen({
    super.key,
    this.existing,
    this.seedPalette,
    this.seedBase,
  });

  final CustomThemePalette? existing;
  final CustomThemePalette? seedPalette;
  final FittinPaletteId? seedBase;

  @override
  ConsumerState<CustomPaletteEditorScreen> createState() =>
      _CustomPaletteEditorScreenState();
}

class _CustomPaletteEditorScreenState
    extends ConsumerState<CustomPaletteEditorScreen> {
  static const _roles = [
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
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  final _colors = <String, TextEditingController>{};
  late Brightness _brightness;
  late FittinPaletteId _base;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    final seed = existing ?? widget.seedPalette;
    _name = TextEditingController(
      text: existing?.name ?? (seed == null ? '' : '${seed.name} copy'),
    );
    _base =
        widget.seedBase ?? FittinPaletteRegistry.decode(seed?.basePaletteKey);
    _brightness =
        seed?.brightness ?? FittinPaletteRegistry.themeOf(_base).brightness;
    final initial =
        seed?.colors ?? _colorsFromTheme(FittinPaletteRegistry.themeOf(_base));
    for (final role in _roles) {
      _colors[role] = TextEditingController(text: initial[role]);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    for (final controller in _colors.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context, ref);
    final preview = _previewPalette();
    return DashboardPageScaffold(
      layout: DashboardPageLayout.detail,
      children: [
        DashboardScreenHeader(
          eyebrow: strings.isChinese ? '配色编辑器' : 'PALETTE EDITOR',
          title: widget.existing == null
              ? (strings.isChinese ? '新建配色' : 'New palette')
              : (strings.isChinese ? '编辑配色' : 'Edit palette'),
          subtitle: strings.isChinese
              ? '青色与青绿色会被拒绝；保存前还会检查文字对比度和力量/有氧区分度。'
              : 'Cyan and teal are rejected. Contrast and strength/cardio separation are checked before save.',
          showBackButton: true,
        ),
        const SizedBox(height: 18),
        if (preview != null) _PaletteLivePreview(palette: preview),
        const SizedBox(height: 16),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                maxLength: 48,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: strings.isChinese ? '方案名称' : 'Palette name',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? (strings.isChinese ? '请输入名称' : 'Enter a name')
                    : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<FittinPaletteId>(
                initialValue: _base,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: strings.isChinese
                      ? '字体与形状基底'
                      : 'Typography and shape base',
                ),
                items: [
                  for (final id in FittinPaletteRegistry.ids)
                    DropdownMenuItem(
                      value: id,
                      child: Text(
                        strings.paletteName(id),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _base = value);
                },
              ),
              const SizedBox(height: 12),
              SegmentedButton<Brightness>(
                segments: [
                  ButtonSegment(
                    value: Brightness.dark,
                    label: Text(strings.isChinese ? '深色' : 'Dark'),
                    icon: const Icon(Icons.dark_mode_outlined),
                  ),
                  ButtonSegment(
                    value: Brightness.light,
                    label: Text(strings.isChinese ? '浅色' : 'Light'),
                    icon: const Icon(Icons.light_mode_outlined),
                  ),
                ],
                selected: {_brightness},
                onSelectionChanged: (value) =>
                    setState(() => _brightness = value.first),
              ),
              const SizedBox(height: 18),
              for (final role in _roles) ...[
                TextFormField(
                  controller: _colors[role],
                  onChanged: (_) => setState(() {}),
                  autocorrect: false,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: _roleLabel(role, strings),
                    prefixIcon: _ColorPreview(controller: _colors[role]!),
                  ),
                  validator: (value) {
                    try {
                      parseHexColor(value ?? '');
                      return null;
                    } on FormatException {
                      return strings.isChinese ? '请输入 #RRGGBB' : 'Use #RRGGBB';
                    }
                  },
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: PremiumPrimaryButton(
                  label: _saving
                      ? strings.saving
                      : (strings.isChinese ? '验证并保存' : 'Validate and save'),
                  icon: Icons.check_rounded,
                  loading: _saving,
                  onPressed: _saving ? null : _save,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  CustomThemePalette? _previewPalette() {
    try {
      return CustomThemePalette(
        id: widget.existing?.id ?? 'user-palette:preview',
        name: _name.text.trim().isEmpty ? 'Preview' : _name.text.trim(),
        brightness: _brightness,
        basePaletteKey: _base.storageKey,
        colors: {for (final role in _roles) role: _colors[role]!.text},
      );
    } on Object {
      return null;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final service = ref.read(userContentServiceProvider);
      final palette = CustomThemePalette(
        id:
            widget.existing?.id ??
            service.newId(UserContentKind.customThemePalette),
        name: _name.text.trim(),
        brightness: _brightness,
        basePaletteKey: _base.storageKey,
        colors: {for (final role in _roles) role: _colors[role]!.text},
      );
      final document = ref
          .read(customThemePaletteDocumentsProvider)
          .valueOrNull
          ?.where((item) => item.id == palette.id)
          .firstOrNull;
      await service.saveCustomPalette(
        palette,
        expectedVersion: document?.version,
      );
      await ref.read(fittinThemeProvider.notifier).setCustomPalette(palette);
      if (mounted) Navigator.of(context).pop();
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _PaletteLivePreview extends StatelessWidget {
  const _PaletteLivePreview({required this.palette});

  final CustomThemePalette palette;

  @override
  Widget build(BuildContext context) {
    final theme = themeFromCustomPalette(palette);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(palette.name, style: theme.displayStyle(22, theme.fg)),
          const SizedBox(height: 5),
          Text('Aa  0123456789', style: theme.uiStyle(13, theme.fgDim)),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final color in [
                theme.accent,
                theme.strengthSeries,
                theme.cardioSeries,
                theme.success,
                theme.warning,
                theme.danger,
              ]) ...[
                Expanded(child: Container(height: 12, color: color)),
                const SizedBox(width: 4),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomPaletteRow extends ConsumerWidget {
  const _CustomPaletteRow({
    required this.palette,
    required this.selected,
    required this.onSelect,
    required this.onEdit,
    required this.onCopy,
    required this.onDelete,
  });

  final CustomThemePalette palette;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final previewTheme = themeFromCustomPalette(palette);
    final activeTheme = ref.watch(resolvedFittinThemeProvider);
    final strings = AppStrings.of(context, ref);
    return DashboardSurfaceCard(
      padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
      onTap: onSelect,
      child: Row(
        children: [
          _PaletteDots(theme: previewTheme),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  palette.name,
                  style: activeTheme.uiStyle(
                    14,
                    activeTheme.fg,
                    FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  selected
                      ? (strings.isChinese ? '当前使用' : 'Active')
                      : (strings.isChinese ? '点按应用' : 'Tap to apply'),
                  style: activeTheme.uiStyle(11, activeTheme.fgMuted),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: strings.isChinese ? '配色选项' : 'Palette actions',
            onSelected: (value) {
              if (value == 'copy') onCopy();
              if (value == 'edit') onEdit();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'copy',
                child: Text(strings.isChinese ? '复制' : 'Duplicate'),
              ),
              PopupMenuItem(
                value: 'edit',
                child: Text(strings.isChinese ? '编辑' : 'Edit'),
              ),
              PopupMenuItem(value: 'delete', child: Text(strings.delete)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BuiltInPaletteRow extends ConsumerWidget {
  const _BuiltInPaletteRow({
    required this.id,
    required this.selected,
    required this.onSelect,
    required this.onCopy,
  });

  final FittinPaletteId id;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context, ref);
    final previewTheme = FittinPaletteRegistry.themeOf(id);
    final activeTheme = ref.watch(resolvedFittinThemeProvider);
    return DashboardSurfaceCard(
      onTap: onSelect,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _PaletteDots(theme: previewTheme),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              strings.paletteName(id),
              style: activeTheme.uiStyle(14, activeTheme.fg, FontWeight.w700),
            ),
          ),
          if (selected) Icon(Icons.check_rounded, color: activeTheme.accent),
          IconButton(
            tooltip: strings.isChinese ? '复制为自定义' : 'Copy as custom',
            onPressed: onCopy,
            icon: const Icon(Icons.copy_rounded),
          ),
        ],
      ),
    );
  }
}

class _PaletteDots extends StatelessWidget {
  const _PaletteDots({required this.theme});
  final FittinTheme theme;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 46,
    height: 28,
    child: Stack(
      children: [
        for (var index = 0; index < 3; index++)
          Positioned(
            left: index * 13,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: [
                  theme.accent,
                  theme.strengthSeries,
                  theme.cardioSeries,
                ][index],
                shape: BoxShape.circle,
                border: Border.all(color: theme.bg, width: 2),
              ),
            ),
          ),
      ],
    ),
  );
}

class _ColorPreview extends StatelessWidget {
  const _ColorPreview({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    Color color;
    try {
      color = parseHexColor(controller.text);
    } on FormatException {
      color = Colors.transparent;
    }
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
      ),
    );
  }
}

Map<String, String> _colorsFromTheme(FittinTheme theme) => {
  'background': colorToHex(theme.bg),
  'surface': colorToHex(theme.surfaceSolid),
  'foreground': colorToHex(theme.fg),
  'mutedForeground': colorToHex(theme.fgMuted),
  'accent': colorToHex(theme.accent),
  'accentInk': colorToHex(theme.accentInk),
  'strength': colorToHex(theme.strengthSeries),
  'cardio': colorToHex(theme.cardioSeries),
  'success': colorToHex(theme.success),
  'warning': colorToHex(theme.warning),
  'danger': colorToHex(theme.danger),
};

String _roleLabel(String role, AppStrings strings) {
  if (!strings.isChinese) return role;
  return switch (role) {
    'background' => '页面背景',
    'surface' => '卡片表面',
    'foreground' => '主要文字',
    'mutedForeground' => '次要文字',
    'accent' => '强调色',
    'accentInk' => '强调色上的文字',
    'strength' => '力量数据',
    'cardio' => '有氧数据',
    'success' => '成功状态',
    'warning' => '警告状态',
    'danger' => '危险状态',
    _ => role,
  };
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
