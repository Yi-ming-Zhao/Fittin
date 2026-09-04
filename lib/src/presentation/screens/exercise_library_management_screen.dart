import 'dart:async';

import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/application/user_content_provider.dart';
import 'package:fittin_v2/src/domain/exercise_library.dart';
import 'package:fittin_v2/src/domain/models/custom_exercise.dart';
import 'package:fittin_v2/src/domain/models/user_content.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExerciseLibraryManagementScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryManagementScreen({super.key});

  @override
  ConsumerState<ExerciseLibraryManagementScreen> createState() =>
      _ExerciseLibraryManagementScreenState();
}

class _ExerciseLibraryManagementScreenState
    extends ConsumerState<ExerciseLibraryManagementScreen> {
  final _search = TextEditingController();
  ExerciseEquipment? _equipment;
  ExerciseMuscle? _muscle;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context, ref);
    final locale = ref.watch(appLocaleProvider);
    final theme = ref.watch(resolvedFittinThemeProvider);
    final catalog = ref.watch(exerciseCatalogProvider);
    final query = _search.text.trim().toLowerCase();
    return DashboardPageScaffold(
      layout: DashboardPageLayout.detail,
      children: [
        DashboardScreenHeader(
          eyebrow: strings.isChinese ? '训练设置' : 'TRAINING',
          title: strings.isChinese ? '动作库' : 'Exercise library',
          subtitle: strings.isChinese
              ? '内置动作只读；你可以复制后调整，或创建自己的动作和标签。'
              : 'Built-ins stay read-only. Copy one to customize it, or create your own tagged movement.',
          showBackButton: true,
          trailing: IconButton.filledTonal(
            tooltip: strings.isChinese ? '新建动作' : 'New exercise',
            onPressed: () => _openEditor(),
            icon: const Icon(Icons.add_rounded),
          ),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _search,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: strings.isChinese
                ? '搜索名称、器械、肌群或标签'
                : 'Search name, equipment, muscle, or tag',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _search.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _ChoiceChip(
                label: strings.isChinese ? '全部器械' : 'All equipment',
                selected: _equipment == null,
                onTap: () => setState(() => _equipment = null),
              ),
              for (final value in ExerciseEquipment.values)
                if (value != ExerciseEquipment.selection)
                  _ChoiceChip(
                    label: exerciseEquipmentLabel(value, strings.isChinese),
                    selected: _equipment == value,
                    onTap: () => setState(() => _equipment = value),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _ChoiceChip(
                label: strings.isChinese ? '全部肌群' : 'All muscles',
                selected: _muscle == null,
                onTap: () => setState(() => _muscle = null),
              ),
              for (final value in ExerciseMuscle.values)
                _ChoiceChip(
                  label: exerciseMuscleLabel(value, strings.isChinese),
                  selected: _muscle == value,
                  onTap: () => setState(() => _muscle = value),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        catalog.when(
          data: (items) {
            final visible = items
                .where((item) {
                  if (_equipment != null && item.equipment != _equipment) {
                    return false;
                  }
                  if (_muscle != null &&
                      !item.primaryMuscles.contains(_muscle) &&
                      !item.secondaryMuscles.contains(_muscle)) {
                    return false;
                  }
                  if (query.isEmpty) return true;
                  return [
                    item.nameEn,
                    item.nameZhCn,
                    item.movement.name,
                    item.equipment.name,
                    ...item.tags,
                  ].join(' ').toLowerCase().contains(query);
                })
                .toList(growable: false);
            if (visible.isEmpty) {
              return DashboardSurfaceCard(
                child: Text(
                  strings.isChinese ? '没有匹配动作' : 'No matching exercises',
                  textAlign: TextAlign.center,
                  style: theme.uiStyle(14, theme.fgDim),
                ),
              );
            }
            return Column(
              children: [
                for (var index = 0; index < visible.length; index++) ...[
                  _ExerciseRow(
                    item: visible[index],
                    localeCode: locale.code,
                    theme: theme,
                    strings: strings,
                    onCopy: () => _openEditor(copyFrom: visible[index]),
                    onEdit: visible[index].isBuiltIn
                        ? null
                        : () => _openCustomEditor(visible[index].id),
                    onDelete: visible[index].isBuiltIn
                        ? null
                        : () => _delete(visible[index]),
                  ),
                  if (index != visible.length - 1) const SizedBox(height: 8),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text(error.toString()),
        ),
      ],
    );
  }

  void _openEditor({ExerciseCatalogItem? copyFrom}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CustomExerciseEditorScreen(copyFrom: copyFrom),
      ),
    );
  }

  void _openCustomEditor(String id) {
    final document = ref
        .read(customExerciseDocumentsProvider)
        .valueOrNull
        ?.where((item) => item.id == id)
        .firstOrNull;
    if (document == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CustomExerciseEditorScreen(
          existing: CustomExerciseDefinition.fromJson(document.payload),
          expectedVersion: document.version,
        ),
      ),
    );
  }

  Future<void> _delete(ExerciseCatalogItem item) async {
    final strings = AppStrings.of(context, ref);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.isChinese ? '删除自定义动作？' : 'Delete custom exercise?'),
        content: Text(
          strings.isChinese
              ? '已完成的训练历史会保留当时的动作名称和数据。'
              : 'Completed workout history keeps the recorded name and data.',
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
        .read(customExerciseDocumentsProvider)
        .valueOrNull
        ?.where((value) => value.id == item.id)
        .firstOrNull;
    await ref
        .read(userContentServiceProvider)
        .delete(
          item.id,
          UserContentKind.customExercise,
          expectedVersion: document?.version,
        );
  }
}

class CustomExerciseEditorScreen extends ConsumerStatefulWidget {
  const CustomExerciseEditorScreen({
    super.key,
    this.existing,
    this.copyFrom,
    this.expectedVersion,
  });

  final CustomExerciseDefinition? existing;
  final ExerciseCatalogItem? copyFrom;
  final int? expectedVersion;

  @override
  ConsumerState<CustomExerciseEditorScreen> createState() =>
      _CustomExerciseEditorScreenState();
}

class _CustomExerciseEditorScreenState
    extends ConsumerState<CustomExerciseEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameZh;
  late final TextEditingController _nameEn;
  late final TextEditingController _tags;
  late final TextEditingController _increment;
  late ExerciseMovement _movement;
  late ExerciseEquipment _equipment;
  late ExerciseLoadSemantics _loadSemantics;
  late Set<ExerciseMuscle> _primary;
  late Set<ExerciseMuscle> _secondary;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final source = widget.existing;
    final copy = widget.copyFrom;
    _nameZh = TextEditingController(text: source?.nameZhCn ?? copy?.nameZhCn);
    _nameEn = TextEditingController(text: source?.nameEn ?? copy?.nameEn);
    _tags = TextEditingController(text: source?.tags.join(', ') ?? '');
    _increment = TextEditingController(
      text: (source?.roundingIncrementKg ?? copy?.roundingIncrementKg ?? 2.5)
          .toString(),
    );
    _movement = source?.movement ?? copy?.movement ?? ExerciseMovement.squat;
    _equipment =
        source?.equipment ?? copy?.equipment ?? ExerciseEquipment.barbell;
    _loadSemantics =
        source?.loadSemantics ??
        copy?.loadSemantics ??
        ExerciseLoadSemantics.totalExternal;
    _primary = {
      ...?source?.primaryMuscles,
      if (source == null) ...?copy?.primaryMuscles,
    };
    _secondary = {
      ...?source?.secondaryMuscles,
      if (source == null) ...?copy?.secondaryMuscles,
    };
  }

  @override
  void dispose() {
    _nameZh.dispose();
    _nameEn.dispose();
    _tags.dispose();
    _increment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context, ref);
    return DashboardPageScaffold(
      layout: DashboardPageLayout.detail,
      children: [
        DashboardScreenHeader(
          eyebrow: strings.isChinese ? '动作库' : 'EXERCISE LIBRARY',
          title: widget.existing == null
              ? (strings.isChinese ? '新建自定义动作' : 'New custom exercise')
              : (strings.isChinese ? '编辑自定义动作' : 'Edit custom exercise'),
          subtitle: strings.isChinese
              ? '动作分类会同时用于训练中替换、统计和 Agent 工具。'
              : 'These tags drive in-session replacement, analytics, and Agent tools.',
          showBackButton: true,
        ),
        const SizedBox(height: 18),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameZh,
                maxLength: 80,
                decoration: const InputDecoration(labelText: '中文名称'),
                validator: _required,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameEn,
                maxLength: 80,
                decoration: const InputDecoration(labelText: 'English name'),
                validator: _required,
              ),
              const SizedBox(height: 8),
              _EnumDropdown<ExerciseMovement>(
                value: _movement,
                label: strings.isChinese ? '动作模式' : 'Movement pattern',
                values: ExerciseMovement.values.where(
                  (value) => value != ExerciseMovement.selection,
                ),
                itemLabel: (value) =>
                    exerciseMovementLabel(value, strings.isChinese),
                onChanged: (value) => setState(() => _movement = value),
              ),
              const SizedBox(height: 12),
              _EnumDropdown<ExerciseEquipment>(
                value: _equipment,
                label: strings.isChinese ? '器械' : 'Equipment',
                values: ExerciseEquipment.values.where(
                  (value) => value != ExerciseEquipment.selection,
                ),
                itemLabel: (value) =>
                    exerciseEquipmentLabel(value, strings.isChinese),
                onChanged: (value) => setState(() => _equipment = value),
              ),
              const SizedBox(height: 12),
              _EnumDropdown<ExerciseLoadSemantics>(
                value: _loadSemantics,
                label: strings.isChinese ? '重量含义' : 'Load meaning',
                values: ExerciseLoadSemantics.values.where(
                  (value) => value != ExerciseLoadSemantics.selection,
                ),
                itemLabel: (value) =>
                    exerciseLoadLabel(value, strings.isChinese),
                onChanged: (value) => setState(() => _loadSemantics = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _increment,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: strings.isChinese ? '重量取整步长' : 'Load increment',
                  suffixText: 'kg',
                ),
                validator: (value) {
                  final parsed = double.tryParse(value ?? '');
                  return parsed == null || parsed <= 0 || parsed > 25
                      ? (strings.isChinese ? '请输入 0–25 kg' : 'Enter 0–25 kg')
                      : null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                strings.isChinese
                    ? '主要肌群（至少一个）'
                    : 'Primary muscles (at least one)',
              ),
              const SizedBox(height: 8),
              _MuscleChips(
                selected: _primary,
                disabled: _secondary,
                isChinese: strings.isChinese,
                onChanged: (value) => setState(() => _primary = value),
              ),
              const SizedBox(height: 16),
              Text(strings.isChinese ? '次要肌群' : 'Secondary muscles'),
              const SizedBox(height: 8),
              _MuscleChips(
                selected: _secondary,
                disabled: _primary,
                isChinese: strings.isChinese,
                onChanged: (value) => setState(() => _secondary = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tags,
                maxLength: 500,
                decoration: InputDecoration(
                  labelText: strings.isChinese ? '自定义标签' : 'Custom tags',
                  helperText: strings.isChinese
                      ? '用逗号分隔，最多 20 个'
                      : 'Comma-separated, up to 20',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: PremiumPrimaryButton(
                  label: _saving
                      ? strings.saving
                      : (strings.isChinese ? '保存动作' : 'Save exercise'),
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

  String? _required(String? value) {
    if (value != null && value.trim().isNotEmpty) return null;
    return AppStrings.of(context, ref).isChinese ? '请填写' : 'Required';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_primary.isEmpty) {
      final strings = AppStrings.of(context, ref);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            strings.isChinese
                ? '请选择至少一个主要肌群'
                : 'Select at least one primary muscle.',
          ),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final service = ref.read(userContentServiceProvider);
      final exercise = CustomExerciseDefinition(
        id:
            widget.existing?.id ??
            service.newId(UserContentKind.customExercise),
        nameEn: _nameEn.text.trim(),
        nameZhCn: _nameZh.text.trim(),
        movement: _movement,
        equipment: _equipment,
        loadSemantics: _loadSemantics,
        primaryMuscles: _primary.toList(),
        secondaryMuscles: _secondary.toList(),
        tags: _tags.text.split(RegExp(r'[,\n，]')),
        roundingIncrementKg: double.parse(_increment.text),
        sourceExerciseId:
            widget.existing?.sourceExerciseId ?? widget.copyFrom?.id,
      );
      await service.saveCustomExercise(
        exercise,
        expectedVersion: widget.expectedVersion,
      );
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

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({
    required this.item,
    required this.localeCode,
    required this.theme,
    required this.strings,
    required this.onCopy,
    this.onEdit,
    this.onDelete,
  });

  final ExerciseCatalogItem item;
  final String localeCode;
  final FittinTheme theme;
  final AppStrings strings;
  final VoidCallback onCopy;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => DashboardSurfaceCard(
    padding: const EdgeInsets.fromLTRB(14, 11, 4, 11),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.surfaceHi,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(Icons.fitness_center_rounded, color: theme.accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.displayName(localeCode),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.uiStyle(14, theme.fg, FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                '${exerciseEquipmentLabel(item.equipment, strings.isChinese)} · ${item.primaryMuscles.map((value) => exerciseMuscleLabel(value, strings.isChinese)).join(' / ')}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.uiStyle(11, theme.fgMuted),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          tooltip: strings.isChinese ? '动作选项' : 'Exercise actions',
          onSelected: (value) {
            if (value == 'copy') onCopy();
            if (value == 'edit') onEdit?.call();
            if (value == 'delete') onDelete?.call();
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'copy',
              child: Text(strings.isChinese ? '复制为自定义' : 'Copy as custom'),
            ),
            if (!item.isBuiltIn)
              PopupMenuItem(
                value: 'edit',
                child: Text(strings.isChinese ? '编辑' : 'Edit'),
              ),
            if (!item.isBuiltIn)
              PopupMenuItem(value: 'delete', child: Text(strings.delete)),
          ],
        ),
      ],
    ),
  );
}

class _EnumDropdown<T extends Enum> extends StatelessWidget {
  const _EnumDropdown({
    required this.value,
    required this.label,
    required this.values,
    required this.itemLabel,
    required this.onChanged,
  });

  final T value;
  final String label;
  final Iterable<T> values;
  final String Function(T value) itemLabel;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<T>(
    initialValue: value,
    isExpanded: true,
    decoration: InputDecoration(labelText: label),
    items: [
      for (final item in values)
        DropdownMenuItem(
          value: item,
          child: Text(itemLabel(item), overflow: TextOverflow.ellipsis),
        ),
    ],
    onChanged: (value) {
      if (value != null) onChanged(value);
    },
  );
}

class _MuscleChips extends StatelessWidget {
  const _MuscleChips({
    required this.selected,
    required this.disabled,
    required this.isChinese,
    required this.onChanged,
  });

  final Set<ExerciseMuscle> selected;
  final Set<ExerciseMuscle> disabled;
  final bool isChinese;
  final ValueChanged<Set<ExerciseMuscle>> onChanged;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 7,
    runSpacing: 7,
    children: [
      for (final muscle in ExerciseMuscle.values)
        FilterChip(
          label: Text(exerciseMuscleLabel(muscle, isChinese)),
          selected: selected.contains(muscle),
          onSelected: disabled.contains(muscle)
              ? null
              : (enabled) {
                  final result = {...selected};
                  enabled ? result.add(muscle) : result.remove(muscle);
                  onChanged(result);
                },
        ),
    ],
  );
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 7),
    child: FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    ),
  );
}

String exerciseEquipmentLabel(ExerciseEquipment value, bool zh) {
  if (!zh) return _splitEnum(value.name);
  return switch (value) {
    ExerciseEquipment.barbell => '杠铃',
    ExerciseEquipment.dumbbell => '哑铃',
    ExerciseEquipment.cable => '绳索',
    ExerciseEquipment.machine => '器械',
    ExerciseEquipment.bodyweight => '自重',
    ExerciseEquipment.band => '弹力带',
    ExerciseEquipment.mixed => '混合',
    ExerciseEquipment.selection => '待选',
  };
}

String exerciseMuscleLabel(ExerciseMuscle value, bool zh) {
  if (!zh) return _splitEnum(value.name);
  return switch (value) {
    ExerciseMuscle.chest => '胸',
    ExerciseMuscle.anteriorDeltoids => '三角肌前束',
    ExerciseMuscle.lateralDeltoids => '三角肌中束',
    ExerciseMuscle.rearDeltoids => '三角肌后束',
    ExerciseMuscle.triceps => '肱三头肌',
    ExerciseMuscle.biceps => '肱二头肌',
    ExerciseMuscle.forearms => '前臂',
    ExerciseMuscle.lats => '背阔肌',
    ExerciseMuscle.upperBack => '上背',
    ExerciseMuscle.lowerBack => '下背',
    ExerciseMuscle.core => '核心',
    ExerciseMuscle.glutes => '臀肌',
    ExerciseMuscle.quadriceps => '股四头肌',
    ExerciseMuscle.hamstrings => '股二头肌',
    ExerciseMuscle.calves => '小腿',
    ExerciseMuscle.adductors => '内收肌',
  };
}

String exerciseMovementLabel(ExerciseMovement value, bool zh) {
  if (!zh) return _splitEnum(value.name);
  return switch (value) {
    ExerciseMovement.squat => '蹲',
    ExerciseMovement.hinge => '髋关节铰链',
    ExerciseMovement.horizontalPress => '水平推',
    ExerciseMovement.verticalPress => '垂直推',
    ExerciseMovement.horizontalPull => '水平拉',
    ExerciseMovement.verticalPull => '垂直拉',
    ExerciseMovement.kneeDominant => '膝主导',
    ExerciseMovement.hipExtension => '伸髋',
    ExerciseMovement.elbowFlexion => '屈肘',
    ExerciseMovement.elbowExtension => '伸肘',
    ExerciseMovement.shoulderAbduction => '肩外展',
    ExerciseMovement.shoulderExternalRotation => '肩外旋',
    ExerciseMovement.locomotion => '移动',
    ExerciseMovement.core => '核心',
    ExerciseMovement.selection => '待选',
  };
}

String exerciseLoadLabel(ExerciseLoadSemantics value, bool zh) {
  if (!zh) return _splitEnum(value.name);
  return switch (value) {
    ExerciseLoadSemantics.totalExternal => '外部总重',
    ExerciseLoadSemantics.perDumbbell => '单只哑铃',
    ExerciseLoadSemantics.cableStack => '绳索配重',
    ExerciseLoadSemantics.machineStack => '器械配重',
    ExerciseLoadSemantics.bodyweight => '自重',
    ExerciseLoadSemantics.bodyweightPlusExternal => '自重加负重',
    ExerciseLoadSemantics.bandResistance => '弹力带阻力',
    ExerciseLoadSemantics.selection => '待选',
  };
}

String _splitEnum(String source) => source
    .replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match[1]} ${match[2]}',
    )
    .toLowerCase();

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
