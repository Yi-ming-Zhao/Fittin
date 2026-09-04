import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/application/user_content_provider.dart';
import 'package:fittin_v2/src/domain/models/cardio.dart';
import 'package:fittin_v2/src/domain/models/user_content.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/screens/cardio_screen.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CardioActivityLibraryScreen extends ConsumerWidget {
  const CardioActivityLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context, ref);
    final locale = ref.watch(appLocaleProvider);
    final theme = ref.watch(resolvedFittinThemeProvider);
    final activities = ref.watch(cardioActivityLibraryProvider);
    return DashboardPageScaffold(
      layout: DashboardPageLayout.detail,
      children: [
        DashboardScreenHeader(
          eyebrow: strings.isChinese ? '训练设置' : 'TRAINING',
          title: strings.isChinese ? '有氧项目库' : 'Cardio activity library',
          subtitle: strings.isChinese
              ? '每个项目只展示真正有用的必填和可选指标。'
              : 'Each activity exposes only the required and optional metrics that matter.',
          showBackButton: true,
          trailing: IconButton.filledTonal(
            tooltip: strings.isChinese ? '新建项目' : 'New activity',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const CardioActivityEditorScreen(),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
          ),
        ),
        const SizedBox(height: 18),
        activities.when(
          data: (items) => Column(
            children: [
              for (var index = 0; index < items.length; index++) ...[
                _ActivityLibraryRow(
                  activity: items[index],
                  label: items[index].displayName(locale.code),
                  theme: theme,
                  strings: strings,
                  onCopy: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          CardioActivityEditorScreen(copyFrom: items[index]),
                    ),
                  ),
                  onEdit: items[index].isBuiltIn
                      ? null
                      : () => _edit(context, ref, items[index]),
                  onDelete: items[index].isBuiltIn
                      ? null
                      : () => _delete(context, ref, items[index]),
                ),
                if (index != items.length - 1) const SizedBox(height: 8),
              ],
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text(error.toString()),
        ),
      ],
    );
  }

  void _edit(
    BuildContext context,
    WidgetRef ref,
    CardioActivityDefinition activity,
  ) {
    final document = ref
        .read(customCardioActivityDocumentsProvider)
        .valueOrNull
        ?.where((value) => value.id == activity.id)
        .firstOrNull;
    if (document == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CardioActivityEditorScreen(
          existing: activity,
          expectedVersion: document.version,
        ),
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    CardioActivityDefinition activity,
  ) async {
    final strings = AppStrings.of(context, ref);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          strings.isChinese ? '删除自定义有氧项目？' : 'Delete custom cardio activity?',
        ),
        content: Text(
          strings.isChinese
              ? '历史记录会保留项目名称和数据，但不再能新建这种记录。'
              : 'History keeps the activity name and data, but new records can no longer use it.',
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
        .read(customCardioActivityDocumentsProvider)
        .valueOrNull
        ?.where((value) => value.id == activity.id)
        .firstOrNull;
    await ref
        .read(userContentServiceProvider)
        .delete(
          activity.id,
          UserContentKind.cardioActivity,
          expectedVersion: document?.version,
        );
  }
}

class CardioActivityEditorScreen extends ConsumerStatefulWidget {
  const CardioActivityEditorScreen({
    super.key,
    this.existing,
    this.copyFrom,
    this.expectedVersion,
  });

  final CardioActivityDefinition? existing;
  final CardioActivityDefinition? copyFrom;
  final int? expectedVersion;

  @override
  ConsumerState<CardioActivityEditorScreen> createState() =>
      _CardioActivityEditorScreenState();
}

class _CardioActivityEditorScreenState
    extends ConsumerState<CardioActivityEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameZh;
  late final TextEditingController _nameEn;
  late CardioActivityIcon _icon;
  late Set<CardioMetricKey> _required;
  late Set<CardioMetricKey> _optional;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final source = widget.existing ?? widget.copyFrom;
    _nameZh = TextEditingController(text: source?.nameZhCn);
    _nameEn = TextEditingController(text: source?.nameEn);
    _icon = source?.icon ?? CardioActivityIcon.generic;
    _required = {CardioMetricKey.durationSeconds, ...?source?.requiredMetrics};
    _optional = {...?source?.optionalMetrics}..removeAll(_required);
  }

  @override
  void dispose() {
    _nameZh.dispose();
    _nameEn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context, ref);
    final theme = ref.watch(resolvedFittinThemeProvider);
    return DashboardPageScaffold(
      layout: DashboardPageLayout.detail,
      children: [
        DashboardScreenHeader(
          eyebrow: strings.isChinese ? '有氧项目库' : 'CARDIO LIBRARY',
          title: widget.existing == null
              ? (strings.isChinese ? '新建有氧项目' : 'New cardio activity')
              : (strings.isChinese ? '编辑有氧项目' : 'Edit cardio activity'),
          subtitle: strings.isChinese
              ? '时间始终必填；其他指标可设为必填、可选或不记录。'
              : 'Duration is always required; every other metric can be required, optional, or hidden.',
          showBackButton: true,
        ),
        const SizedBox(height: 18),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameZh,
                maxLength: 80,
                decoration: const InputDecoration(labelText: '中文名称'),
                validator: _requiredText,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameEn,
                maxLength: 80,
                decoration: const InputDecoration(labelText: 'English name'),
                validator: _requiredText,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<CardioActivityIcon>(
                initialValue: _icon,
                decoration: InputDecoration(
                  labelText: strings.isChinese ? '图标' : 'Icon',
                ),
                items: [
                  for (final icon in CardioActivityIcon.values)
                    DropdownMenuItem(
                      value: icon,
                      child: Row(
                        children: [
                          Icon(cardioActivityIcon(icon), size: 20),
                          const SizedBox(width: 10),
                          Text(_titleCase(icon.name)),
                        ],
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _icon = value);
                },
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
                decoration: BoxDecoration(
                  color: theme.surfaceSolid,
                  borderRadius: BorderRadius.circular(theme.radiusSm),
                  border: Border.all(color: theme.border),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            strings.isChinese ? '指标' : 'Metric',
                            style: theme.uiStyle(12, theme.fgMuted),
                          ),
                        ),
                        SizedBox(
                          width: 58,
                          child: Text(
                            strings.isChinese ? '必填' : 'Req.',
                            textAlign: TextAlign.center,
                            style: theme.uiStyle(11, theme.fgMuted),
                          ),
                        ),
                        SizedBox(
                          width: 58,
                          child: Text(
                            strings.isChinese ? '可选' : 'Opt.',
                            textAlign: TextAlign.center,
                            style: theme.uiStyle(11, theme.fgMuted),
                          ),
                        ),
                      ],
                    ),
                    for (final metric in CardioMetricKey.values)
                      _MetricRoleRow(
                        metric: metric,
                        isChinese: strings.isChinese,
                        required: _required.contains(metric),
                        optional: _optional.contains(metric),
                        locked: metric == CardioMetricKey.durationSeconds,
                        onRequired: () => setState(() {
                          _required.add(metric);
                          _optional.remove(metric);
                        }),
                        onOptional: () => setState(() {
                          if (metric == CardioMetricKey.durationSeconds) return;
                          if (_optional.contains(metric)) {
                            _optional.remove(metric);
                          } else {
                            _optional.add(metric);
                            _required.remove(metric);
                          }
                        }),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: PremiumPrimaryButton(
                  label: _saving
                      ? strings.saving
                      : (strings.isChinese ? '保存有氧项目' : 'Save cardio activity'),
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

  String? _requiredText(String? value) =>
      value == null || value.trim().isEmpty ? '请填写 / Required' : null;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final service = ref.read(userContentServiceProvider);
      final activity = CardioActivityDefinition(
        id:
            widget.existing?.id ??
            service.newId(UserContentKind.cardioActivity),
        nameEn: _nameEn.text.trim(),
        nameZhCn: _nameZh.text.trim(),
        icon: _icon,
        requiredMetrics: _required,
        optionalMetrics: _optional,
      );
      await service.saveCardioActivity(
        activity,
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

class _ActivityLibraryRow extends StatelessWidget {
  const _ActivityLibraryRow({
    required this.activity,
    required this.label,
    required this.theme,
    required this.strings,
    required this.onCopy,
    this.onEdit,
    this.onDelete,
  });

  final CardioActivityDefinition activity;
  final String label;
  final FittinTheme theme;
  final AppStrings strings;
  final VoidCallback onCopy;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => DashboardSurfaceCard(
    padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
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
          child: Icon(cardioActivityIcon(activity.icon), color: theme.accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.uiStyle(14, theme.fg, FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                strings.isChinese
                    ? '${activity.requiredMetrics.length} 项必填 · ${activity.optionalMetrics.length} 项可选'
                    : '${activity.requiredMetrics.length} required · ${activity.optionalMetrics.length} optional',
                style: theme.uiStyle(11, theme.fgMuted),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
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
            if (!activity.isBuiltIn)
              PopupMenuItem(
                value: 'edit',
                child: Text(strings.isChinese ? '编辑' : 'Edit'),
              ),
            if (!activity.isBuiltIn)
              PopupMenuItem(value: 'delete', child: Text(strings.delete)),
          ],
        ),
      ],
    ),
  );
}

class _MetricRoleRow extends StatelessWidget {
  const _MetricRoleRow({
    required this.metric,
    required this.isChinese,
    required this.required,
    required this.optional,
    required this.locked,
    required this.onRequired,
    required this.onOptional,
  });

  final CardioMetricKey metric;
  final bool isChinese;
  final bool required;
  final bool optional;
  final bool locked;
  final VoidCallback onRequired;
  final VoidCallback onOptional;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 48),
    child: Row(
      children: [
        Expanded(
          child: Text(
            cardioMetricLabel(metric, isChinese),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(
          width: 58,
          child: Checkbox(
            value: required,
            onChanged: locked ? null : (_) => onRequired(),
          ),
        ),
        SizedBox(
          width: 58,
          child: Checkbox(
            value: optional,
            onChanged: locked ? null : (_) => onOptional(),
          ),
        ),
      ],
    ),
  );
}

String cardioMetricLabel(CardioMetricKey key, bool zh) {
  if (!zh) return _titleCase(key.name);
  return switch (key) {
    CardioMetricKey.durationSeconds => '时间',
    CardioMetricKey.distanceMeters => '距离',
    CardioMetricKey.averageSpeedMps => '平均速度',
    CardioMetricKey.paceSecondsPerKm => '平均配速',
    CardioMetricKey.inclinePercent => '坡度',
    CardioMetricKey.averageHeartRateBpm => '平均心率',
    CardioMetricKey.maxHeartRateBpm => '最高心率',
    CardioMetricKey.cadencePerMinute => '步频 / 踏频',
    CardioMetricKey.elevationGainMeters => '累计爬升',
    CardioMetricKey.caloriesKcal => '热量',
    CardioMetricKey.steps => '步数 / 级数',
    CardioMetricKey.strokesPerMinute => '桨频',
    CardioMetricKey.poolLengthMeters => '泳池长度',
  };
}

String _titleCase(String source) {
  final words = source
      .replaceAllMapped(
        RegExp(r'([a-z])([A-Z])'),
        (match) => '${match[1]} ${match[2]}',
      )
      .split(' ');
  return words
      .map(
        (word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
