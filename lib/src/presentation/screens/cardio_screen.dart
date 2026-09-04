import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/cardio_import_service.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/application/user_content_provider.dart';
import 'package:fittin_v2/src/domain/models/cardio.dart';
import 'package:fittin_v2/src/domain/models/user_content.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CardioHubScreen extends ConsumerWidget {
  const CardioHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context, ref);
    final locale = ref.watch(appLocaleProvider);
    final theme = ref.watch(resolvedFittinThemeProvider);
    final activities = ref.watch(cardioActivityLibraryProvider);
    final records = ref.watch(cardioRecordsProvider);

    return DashboardPageScaffold(
      topPadding: 20,
      safeAreaBottom: true,
      children: [
        DashboardScreenHeader(
          eyebrow: strings.isChinese ? '有氧训练' : 'CARDIO',
          title: strings.isChinese ? '记录有氧' : 'Record cardio',
          subtitle: strings.isChinese
              ? '不同项目只记录真正有用的指标，也可以导入常见跑步文件。'
              : 'Capture the metrics that matter for each activity or import a common running file.',
          showBackButton: true,
          trailing: IconButton.filledTonal(
            tooltip: strings.isChinese ? '导入数据' : 'Import data',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CardioImportScreen()),
            ),
            icon: const Icon(Icons.file_upload_outlined),
          ),
        ),
        const SizedBox(height: 20),
        DashboardSectionLabel(
          label: strings.isChinese ? '选择项目' : 'CHOOSE ACTIVITY',
        ),
        const SizedBox(height: 10),
        activities.when(
          data: (items) => LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 520 ? 4 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: constraints.maxWidth < 340 ? 1.45 : 1.7,
                ),
                itemBuilder: (context, index) {
                  final activity = items[index];
                  return _ActivityTile(
                    theme: theme,
                    label: activity.displayName(locale.code),
                    icon: cardioActivityIcon(activity.icon),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            CardioRecordEditorScreen(activity: activity),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _InlineError(message: error.toString()),
        ),
        const SizedBox(height: 20),
        DashboardSectionLabel(
          label: strings.isChinese ? '最近记录' : 'RECENT RECORDS',
        ),
        const SizedBox(height: 10),
        records.when(
          data: (items) => items.isEmpty
              ? DashboardSurfaceCard(
                  child: Text(
                    strings.isChinese
                        ? '还没有有氧记录。完成第一条后，力量和有氧会一起出现在趋势里。'
                        : 'No cardio records yet. Your first one will appear beside strength work in Trends.',
                    style: theme
                        .uiStyle(14, theme.fgDim)
                        .copyWith(height: 1.45),
                  ),
                )
              : Column(
                  children: [
                    for (
                      var index = 0;
                      index < items.take(20).length;
                      index++
                    ) ...[
                      _CardioRecordTile(
                        theme: theme,
                        strings: strings,
                        record: items[index],
                        activity: activities.valueOrNull
                            ?.where(
                              (activity) =>
                                  activity.id == items[index].activityTypeId,
                            )
                            .firstOrNull,
                        localeCode: locale.code,
                        onTap: () => _editRecord(
                          context,
                          ref,
                          activities.valueOrNull,
                          items[index],
                        ),
                        onDelete: () =>
                            _deleteRecord(context, ref, strings, items[index]),
                      ),
                      if (index != items.take(20).length - 1)
                        const SizedBox(height: 8),
                    ],
                  ],
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _InlineError(message: error.toString()),
        ),
      ],
    );
  }

  void _editRecord(
    BuildContext context,
    WidgetRef ref,
    List<CardioActivityDefinition>? activities,
    CardioRecord record,
  ) {
    final activity = activities
        ?.where((value) => value.id == record.activityTypeId)
        .firstOrNull;
    if (activity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.of(context, ref).isChinese
                ? '这条记录的项目定义已删除，历史仍会保留。'
                : 'This record\'s activity definition was deleted; history remains available.',
          ),
        ),
      );
      return;
    }
    final document = ref
        .read(cardioRecordDocumentsProvider)
        .valueOrNull
        ?.where((value) => value.id == record.id)
        .firstOrNull;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CardioRecordEditorScreen(
          activity: activity,
          existing: record,
          expectedVersion: document?.version,
        ),
      ),
    );
  }

  Future<void> _deleteRecord(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
    CardioRecord record,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          strings.isChinese ? '删除这条有氧记录？' : 'Delete this cardio record?',
        ),
        content: Text(
          strings.isChinese
              ? '记录会从趋势中移除；已登录时会同步此删除。'
              : 'It will be removed from Trends and the deletion will sync when signed in.',
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
        .read(cardioRecordDocumentsProvider)
        .valueOrNull
        ?.where((item) => item.id == record.id)
        .firstOrNull;
    await ref
        .read(userContentServiceProvider)
        .delete(
          record.id,
          UserContentKind.cardioRecord,
          expectedVersion: document?.version,
        );
  }
}

class CardioRecordEditorScreen extends ConsumerStatefulWidget {
  const CardioRecordEditorScreen({
    super.key,
    required this.activity,
    this.existing,
    this.expectedVersion,
  });

  final CardioActivityDefinition activity;
  final CardioRecord? existing;
  final int? expectedVersion;

  @override
  ConsumerState<CardioRecordEditorScreen> createState() =>
      _CardioRecordEditorScreenState();
}

class _CardioRecordEditorScreenState
    extends ConsumerState<CardioRecordEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = <CardioMetricKey, TextEditingController>{};
  final _noteController = TextEditingController();
  DateTime _startedAt = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    for (final metric in widget.activity.allowedMetrics) {
      final value = widget.existing?.metric(metric);
      _controllers[metric] = TextEditingController(
        text: value == null ? '' : _displayMetric(metric, value),
      );
    }
    _noteController.text = widget.existing?.note ?? '';
    _startedAt = widget.existing?.startedAt ?? DateTime.now();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context, ref);
    final locale = ref.watch(appLocaleProvider);
    final theme = ref.watch(resolvedFittinThemeProvider);
    final metrics = [
      ...widget.activity.requiredMetrics,
      ...widget.activity.optionalMetrics,
    ];

    return DashboardPageScaffold(
      topPadding: 20,
      safeAreaBottom: true,
      children: [
        DashboardScreenHeader(
          eyebrow: widget.existing == null
              ? (strings.isChinese ? '新记录' : 'NEW RECORD')
              : (strings.isChinese ? '编辑记录' : 'EDIT RECORD'),
          title: widget.activity.displayName(locale.code),
          subtitle: strings.isChinese
              ? '必填项会根据项目自动调整；所有数值按本地保存。'
              : 'Required fields adapt to the activity and save locally first.',
          showBackButton: true,
        ),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: Column(
            children: [
              DashboardSurfaceCard(
                padding: const EdgeInsets.all(16),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.schedule_rounded, color: theme.accent),
                  title: Text(strings.isChinese ? '开始时间' : 'Start time'),
                  subtitle: Text(_formatDateTime(_startedAt)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _pickStartTime,
                ),
              ),
              const SizedBox(height: 10),
              for (var index = 0; index < metrics.length; index++) ...[
                TextFormField(
                  key: ValueKey('cardio-field-${metrics[index].name}'),
                  controller: _controllers[metrics[index]],
                  keyboardType:
                      metrics[index] == CardioMetricKey.paceSecondsPerKm
                      ? TextInputType.datetime
                      : const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: _metricLabel(metrics[index], strings),
                    suffixText: _metricUnit(metrics[index], strings),
                    helperText:
                        widget.activity.requiredMetrics.contains(metrics[index])
                        ? (strings.isChinese ? '必填' : 'Required')
                        : null,
                  ),
                  validator: (value) =>
                      _validateField(metrics[index], value, strings),
                ),
                if (index != metrics.length - 1) const SizedBox(height: 10),
              ],
              const SizedBox(height: 10),
              TextFormField(
                controller: _noteController,
                maxLength: 500,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: strings.isChinese ? '备注' : 'Note',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: PremiumPrimaryButton(
                  label: _saving
                      ? strings.saving
                      : (strings.isChinese ? '保存有氧记录' : 'Save cardio record'),
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

  String? _validateField(
    CardioMetricKey metric,
    String? value,
    AppStrings strings,
  ) {
    final required = widget.activity.requiredMetrics.contains(metric);
    if ((value == null || value.trim().isEmpty) && required) {
      return strings.isChinese ? '请填写这一项' : 'This field is required';
    }
    if (value == null || value.trim().isEmpty) return null;
    final parsed = _parseMetric(metric, value);
    if (parsed == null || !parsed.isFinite || parsed < 0) {
      return strings.isChinese ? '请输入有效数值' : 'Enter a valid value';
    }
    try {
      validateCardioMetricValue(metric, parsed);
    } on FormatException {
      return strings.isChinese ? '数值超出合理范围' : 'Value is out of range';
    }
    return null;
  }

  Future<void> _pickStartTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startedAt),
    );
    if (time == null) return;
    setState(() {
      _startedAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final metrics = <CardioMetricKey, double>{};
      for (final entry in _controllers.entries) {
        final value = entry.value.text.trim();
        if (value.isEmpty) continue;
        final parsed = _parseMetric(entry.key, value);
        if (parsed != null) metrics[entry.key] = parsed;
      }
      final service = ref.read(userContentServiceProvider);
      final record = CardioRecord(
        id: widget.existing?.id ?? service.newId(UserContentKind.cardioRecord),
        activityTypeId: widget.activity.id,
        activityName: widget.activity.nameEn,
        startedAt: _startedAt,
        metrics: metrics,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        source: widget.existing?.source ?? 'manual',
        sourceFingerprint: widget.existing?.sourceFingerprint,
      );
      await service.saveCardioRecord(
        record,
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

class CardioImportScreen extends ConsumerWidget {
  const CardioImportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context, ref);
    return DashboardPageScaffold(
      topPadding: 20,
      safeAreaBottom: true,
      children: [
        DashboardScreenHeader(
          eyebrow: strings.isChinese ? '数据导入' : 'DATA IMPORT',
          title: strings.isChinese ? '导入跑步与有氧' : 'Import cardio data',
          subtitle: strings.isChinese
              ? '支持 GPX、TCX、FIT 和 CSV。文件只在本机解析，确认前不会写入。'
              : 'Supports GPX, TCX, FIT, and CSV. Files are parsed locally and nothing is written before confirmation.',
          showBackButton: true,
        ),
        const SizedBox(height: 20),
        const CardioImportPanel(),
      ],
    );
  }
}

class CardioImportPanel extends ConsumerStatefulWidget {
  const CardioImportPanel({super.key});

  @override
  ConsumerState<CardioImportPanel> createState() => _CardioImportPanelState();
}

class _CardioImportPanelState extends ConsumerState<CardioImportPanel> {
  CardioImportPreview? _preview;
  CardioCsvInspection? _csvInspection;
  Uint8List? _csvBytes;
  String? _csvName;
  Map<CardioCsvField, String> _csvColumns = {};
  String? _error;
  bool _reading = false;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context, ref);
    final locale = ref.watch(appLocaleProvider);
    final theme = ref.watch(resolvedFittinThemeProvider);
    final preview = _preview;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardSurfaceCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.surfaceHi,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.folder_open_rounded, color: theme.accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.isChinese ? '选择运动文件' : 'Choose activity file',
                          style: theme.uiStyle(15, theme.fg, FontWeight.w700),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          strings.isChinese
                              ? 'GPX · TCX · FIT · CSV，最大 20 MB'
                              : 'GPX · TCX · FIT · CSV, up to 20 MB',
                          style: theme.uiStyle(12, theme.fgMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _reading || _saving ? null : _chooseFile,
                  icon: _reading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_rounded),
                  label: Text(
                    _reading
                        ? (strings.isChinese ? '正在本机解析…' : 'Parsing locally…')
                        : (strings.isChinese ? '选择文件' : 'Choose file'),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          _ImportMessageCard(
            icon: Icons.error_outline_rounded,
            color: theme.danger,
            message: _error!,
          ),
        ],
        if (_csvInspection != null) ...[
          const SizedBox(height: 18),
          DashboardSectionLabel(
            label: strings.isChinese ? 'CSV 列映射' : 'CSV COLUMN MAPPING',
          ),
          const SizedBox(height: 10),
          DashboardSurfaceCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  strings.isChinese
                      ? '请确认开始时间和时长。其他指标可以留空。'
                      : 'Confirm start time and duration. Optional metrics may remain unmapped.',
                  style: theme.uiStyle(13, theme.fgDim).copyWith(height: 1.4),
                ),
                const SizedBox(height: 14),
                for (final field in CardioCsvField.values) ...[
                  DropdownButtonFormField<String>(
                    key: ValueKey(
                      'csv-map-${_csvName ?? ''}-${field.name}-${_csvColumns[field] ?? 'none'}',
                    ),
                    initialValue: _csvColumns[field],
                    decoration: InputDecoration(
                      labelText: _csvFieldLabel(field, strings),
                      helperText:
                          field == CardioCsvField.startedAt ||
                              field == CardioCsvField.duration
                          ? (strings.isChinese ? '必填' : 'Required')
                          : null,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: '__none__',
                        child: Text(strings.isChinese ? '不导入' : 'Not mapped'),
                      ),
                      for (final header in _csvInspection!.headers)
                        DropdownMenuItem(value: header, child: Text(header)),
                    ],
                    onChanged: (value) => setState(() {
                      if (value == null || value == '__none__') {
                        _csvColumns.remove(field);
                      } else {
                        _csvColumns[field] = value;
                      }
                    }),
                  ),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 6),
                FilledButton.icon(
                  onPressed: _reading ? null : _previewMappedCsv,
                  icon: const Icon(Icons.preview_rounded),
                  label: Text(
                    strings.isChinese ? '生成导入预览' : 'Build import preview',
                  ),
                ),
              ],
            ),
          ),
        ],
        if (preview != null) ...[
          const SizedBox(height: 18),
          DashboardSectionLabel(
            label: strings.isChinese ? '导入预览' : 'IMPORT PREVIEW',
          ),
          const SizedBox(height: 10),
          DashboardSurfaceCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  preview.sourceName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.uiStyle(15, theme.fg, FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ImportStat(
                      theme: theme,
                      value: '${preview.newRecords.length}',
                      label: strings.isChinese ? '可导入' : 'new',
                    ),
                    _ImportStat(
                      theme: theme,
                      value: '${preview.duplicateRecordIds.length}',
                      label: strings.isChinese ? '重复' : 'duplicates',
                    ),
                    _ImportStat(
                      theme: theme,
                      value:
                          '${(preview.records.fold<double>(0, (sum, record) => sum + (record.metric(CardioMetricKey.durationSeconds) ?? 0)) / 60).round()}',
                      label: strings.isChinese ? '总分钟' : 'minutes',
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (preview.warnings.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final warning in preview.warnings.take(8)) ...[
              _ImportMessageCard(
                icon: Icons.info_outline_rounded,
                color: theme.warning,
                message: warning,
              ),
              const SizedBox(height: 6),
            ],
          ],
          const SizedBox(height: 10),
          for (final record in preview.records.take(20)) ...[
            _ImportRecordPreviewTile(
              theme: theme,
              label: BuiltInCardioActivities.byId(
                record.activityTypeId,
              ).displayName(locale.code),
              record: record,
              duplicate: preview.duplicateRecordIds.contains(record.id),
              duplicateLabel: strings.isChinese ? '已存在' : 'Already exists',
            ),
            const SizedBox(height: 8),
          ],
          SizedBox(
            width: double.infinity,
            child: PremiumPrimaryButton(
              label: _saving
                  ? strings.saving
                  : strings.isChinese
                  ? '确认导入 ${preview.newRecords.length} 条'
                  : 'Import ${preview.newRecords.length} records',
              icon: Icons.download_done_rounded,
              loading: _saving,
              onPressed: _saving || preview.newRecords.isEmpty ? null : _save,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _chooseFile() async {
    setState(() {
      _reading = true;
      _error = null;
    });
    try {
      const group = XTypeGroup(
        label: 'Cardio activity files',
        extensions: ['gpx', 'tcx', 'fit', 'csv'],
        mimeTypes: [
          'application/gpx+xml',
          'application/vnd.garmin.tcx+xml',
          'application/octet-stream',
          'text/csv',
        ],
        webWildCards: ['.gpx', '.tcx', '.fit', '.csv'],
      );
      final file = await openFile(acceptedTypeGroups: const [group]);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (file.name.toLowerCase().endsWith('.csv')) {
        final inspection = const CardioImportService().inspectCsv(bytes);
        if (!mounted) return;
        setState(() {
          _csvInspection = inspection;
          _csvBytes = bytes;
          _csvName = file.name;
          _csvColumns = Map.of(inspection.suggested.columns);
          _preview = null;
        });
        return;
      }
      final existing = await ref.read(cardioRecordsProvider.future);
      final confirmedFingerprints = await _confirmedFingerprints();
      final preview = const CardioImportService().parse(
        fileName: file.name,
        bytes: bytes,
        existingRecords: existing,
        confirmedFingerprints: confirmedFingerprints,
      );
      if (!mounted) return;
      setState(() {
        _csvInspection = null;
        _csvBytes = null;
        _csvName = null;
        _csvColumns = {};
        _preview = preview;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _preview = null;
        _error = error.toString();
      });
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  Future<void> _previewMappedCsv() async {
    final bytes = _csvBytes;
    final name = _csvName;
    if (bytes == null || name == null) return;
    final strings = AppStrings.of(context, ref);
    if (!_csvColumns.containsKey(CardioCsvField.startedAt) ||
        !_csvColumns.containsKey(CardioCsvField.duration)) {
      setState(() {
        _error = strings.isChinese
            ? '请映射开始时间和时长列。'
            : 'Map both start time and duration columns.';
      });
      return;
    }
    setState(() {
      _reading = true;
      _error = null;
    });
    try {
      final existing = await ref.read(cardioRecordsProvider.future);
      final confirmedFingerprints = await _confirmedFingerprints();
      final preview = const CardioImportService().parse(
        fileName: name,
        bytes: bytes,
        existingRecords: existing,
        confirmedFingerprints: confirmedFingerprints,
        csvMapping: CardioCsvMapping(Map.unmodifiable(_csvColumns)),
      );
      if (mounted) setState(() => _preview = preview);
    } on Object catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  Future<void> _save() async {
    final preview = _preview;
    if (preview == null || preview.newRecords.isEmpty) return;
    setState(() => _saving = true);
    try {
      final service = ref.read(userContentServiceProvider);
      await service.saveCardioImport(preview);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.of(context, ref).isChinese
                ? '已导入 ${preview.newRecords.length} 条有氧记录'
                : 'Imported ${preview.newRecords.length} cardio records',
          ),
        ),
      );
      Navigator.of(context).pop();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<Set<String>> _confirmedFingerprints() async {
    final documents = await ref.read(
      cardioImportFingerprintDocumentsProvider.future,
    );
    return documents
        .map((document) => document.payload['fingerprint'])
        .whereType<String>()
        .toSet();
  }
}

class _ImportStat extends StatelessWidget {
  const _ImportStat({
    required this.theme,
    required this.value,
    required this.label,
  });

  final FittinTheme theme;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
    decoration: BoxDecoration(
      color: theme.surfaceHi,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      '$value $label',
      style: theme.uiStyle(12, theme.fg, FontWeight.w700),
    ),
  );
}

class _ImportMessageCard extends StatelessWidget {
  const _ImportMessageCard({
    required this.icon,
    required this.color,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withValues(alpha: 0.24)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 9),
        Expanded(child: Text(message)),
      ],
    ),
  );
}

class _ImportRecordPreviewTile extends StatelessWidget {
  const _ImportRecordPreviewTile({
    required this.theme,
    required this.label,
    required this.record,
    required this.duplicate,
    required this.duplicateLabel,
  });

  final FittinTheme theme;
  final String label;
  final CardioRecord record;
  final bool duplicate;
  final String duplicateLabel;

  @override
  Widget build(BuildContext context) {
    final duration = record.metric(CardioMetricKey.durationSeconds) ?? 0;
    final distance = record.metric(CardioMetricKey.distanceMeters);
    return DashboardSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          Icon(
            duplicate ? Icons.content_copy_rounded : Icons.check_rounded,
            color: duplicate ? theme.fgMuted : theme.accent,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.uiStyle(14, theme.fg, FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  '${_formatDateTime(record.startedAt)} · ${(duration / 60).round()} min'
                  '${distance == null ? '' : ' · ${(distance / 1000).toStringAsFixed(2)} km'}',
                  style: theme.uiStyle(12, theme.fgMuted),
                ),
              ],
            ),
          ),
          if (duplicate)
            Text(
              duplicateLabel,
              style: theme.uiStyle(11, theme.fgMuted, FontWeight.w700),
            ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.theme,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final FittinTheme theme;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: theme.accent, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.uiStyle(13, theme.fg, FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardioRecordTile extends StatelessWidget {
  const _CardioRecordTile({
    required this.theme,
    required this.strings,
    required this.record,
    required this.localeCode,
    required this.onTap,
    required this.onDelete,
    this.activity,
  });

  final FittinTheme theme;
  final AppStrings strings;
  final CardioRecord record;
  final CardioActivityDefinition? activity;
  final String localeCode;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final duration = record.metric(CardioMetricKey.durationSeconds) ?? 0;
    final distance = record.metric(CardioMetricKey.distanceMeters);
    final pace = record.metric(CardioMetricKey.paceSecondsPerKm);
    return DashboardSurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
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
            child: Icon(Icons.directions_run_rounded, color: theme.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity?.displayName(localeCode) ?? record.activityName,
                  style: theme.uiStyle(14, theme.fg, FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    '${(duration / 60).round()} min',
                    if (distance != null)
                      '${(distance / 1000).toStringAsFixed(2)} km',
                    if (pace != null) '${_formatPace(pace)}/km',
                  ].join(' · '),
                  style: theme.uiStyle(12, theme.fgMuted),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: strings.delete,
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline_rounded, color: theme.fgMuted),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Text(message, textAlign: TextAlign.center),
  );
}

IconData cardioActivityIcon(CardioActivityIcon icon) => switch (icon) {
  CardioActivityIcon.run => Icons.directions_run_rounded,
  CardioActivityIcon.incline => Icons.trending_up_rounded,
  CardioActivityIcon.bike => Icons.directions_bike_rounded,
  CardioActivityIcon.row => Icons.rowing_rounded,
  CardioActivityIcon.stairs => Icons.stairs_rounded,
  CardioActivityIcon.swim => Icons.pool_rounded,
  CardioActivityIcon.elliptical => Icons.sync_rounded,
  CardioActivityIcon.generic => Icons.favorite_outline_rounded,
};

String _metricLabel(CardioMetricKey key, AppStrings strings) {
  if (strings.isChinese) {
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
  return switch (key) {
    CardioMetricKey.durationSeconds => 'Duration',
    CardioMetricKey.distanceMeters => 'Distance',
    CardioMetricKey.averageSpeedMps => 'Average speed',
    CardioMetricKey.paceSecondsPerKm => 'Average pace',
    CardioMetricKey.inclinePercent => 'Incline',
    CardioMetricKey.averageHeartRateBpm => 'Average heart rate',
    CardioMetricKey.maxHeartRateBpm => 'Maximum heart rate',
    CardioMetricKey.cadencePerMinute => 'Cadence',
    CardioMetricKey.elevationGainMeters => 'Elevation gain',
    CardioMetricKey.caloriesKcal => 'Calories',
    CardioMetricKey.steps => 'Steps / floors',
    CardioMetricKey.strokesPerMinute => 'Stroke rate',
    CardioMetricKey.poolLengthMeters => 'Pool length',
  };
}

String _metricUnit(CardioMetricKey key, AppStrings strings) => switch (key) {
  CardioMetricKey.durationSeconds => strings.isChinese ? '分钟' : 'min',
  CardioMetricKey.distanceMeters => 'km',
  CardioMetricKey.averageSpeedMps => 'km/h',
  CardioMetricKey.paceSecondsPerKm => 'min/km',
  CardioMetricKey.inclinePercent => '%',
  CardioMetricKey.averageHeartRateBpm ||
  CardioMetricKey.maxHeartRateBpm => 'bpm',
  CardioMetricKey.cadencePerMinute ||
  CardioMetricKey.strokesPerMinute => '/min',
  CardioMetricKey.elevationGainMeters ||
  CardioMetricKey.poolLengthMeters => 'm',
  CardioMetricKey.caloriesKcal => 'kcal',
  CardioMetricKey.steps => strings.isChinese ? '步' : 'steps',
};

String _csvFieldLabel(CardioCsvField field, AppStrings strings) {
  if (!strings.isChinese) {
    return switch (field) {
      CardioCsvField.startedAt => 'Start time',
      CardioCsvField.duration => 'Duration',
      CardioCsvField.distanceKm => 'Distance (km)',
      CardioCsvField.pace => 'Pace',
      CardioCsvField.speedKmh => 'Speed (km/h)',
      CardioCsvField.activity => 'Activity type',
      CardioCsvField.averageHeartRate => 'Average heart rate',
      CardioCsvField.maxHeartRate => 'Maximum heart rate',
      CardioCsvField.cadence => 'Cadence',
      CardioCsvField.elevationGain => 'Elevation gain',
      CardioCsvField.calories => 'Calories',
      CardioCsvField.incline => 'Incline',
    };
  }
  return switch (field) {
    CardioCsvField.startedAt => '开始时间',
    CardioCsvField.duration => '时长',
    CardioCsvField.distanceKm => '距离（公里）',
    CardioCsvField.pace => '配速',
    CardioCsvField.speedKmh => '速度（公里/时）',
    CardioCsvField.activity => '运动类型',
    CardioCsvField.averageHeartRate => '平均心率',
    CardioCsvField.maxHeartRate => '最高心率',
    CardioCsvField.cadence => '步频 / 踏频',
    CardioCsvField.elevationGain => '累计爬升',
    CardioCsvField.calories => '热量',
    CardioCsvField.incline => '坡度',
  };
}

double? _parseMetric(CardioMetricKey key, String source) {
  final text = source.trim();
  if (key == CardioMetricKey.paceSecondsPerKm && text.contains(':')) {
    final parts = text.split(':');
    if (parts.length != 2) return null;
    final minutes = int.tryParse(parts[0]);
    final seconds = int.tryParse(parts[1]);
    if (minutes == null || seconds == null || seconds >= 60) return null;
    return (minutes * 60 + seconds).toDouble();
  }
  final value = double.tryParse(text);
  if (value == null) return null;
  return switch (key) {
    CardioMetricKey.durationSeconds => value * 60,
    CardioMetricKey.distanceMeters => value * 1000,
    CardioMetricKey.averageSpeedMps => value / 3.6,
    _ => value,
  };
}

String _formatPace(double seconds) {
  final rounded = seconds.round();
  return '${rounded ~/ 60}:${(rounded % 60).toString().padLeft(2, '0')}';
}

String _formatDateTime(DateTime value) =>
    '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')} '
    '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

String _displayMetric(CardioMetricKey key, double value) {
  if (key == CardioMetricKey.paceSecondsPerKm) return _formatPace(value);
  final display = switch (key) {
    CardioMetricKey.durationSeconds => value / 60,
    CardioMetricKey.distanceMeters => value / 1000,
    CardioMetricKey.averageSpeedMps => value * 3.6,
    _ => value,
  };
  return display == display.roundToDouble()
      ? display.round().toString()
      : display.toStringAsFixed(2);
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
