import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/application/ui_settings_provider.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/weight_tools.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/widgets/fittin_primitives.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart' show FittinTheme;

class WeightToolsSheet extends ConsumerStatefulWidget {
  const WeightToolsSheet({
    super.key,
    this.initialWeight = 0,
    this.initialUnit = LoadUnits.kg,
    this.showApplyButton = false,
    this.exerciseName,
    this.onApply,
  });

  final double initialWeight;
  final String initialUnit;
  final bool showApplyButton;
  final String? exerciseName;
  final void Function(double value, String unit)? onApply;

  @override
  ConsumerState<WeightToolsSheet> createState() => _WeightToolsSheetState();
}

class _WeightToolsSheetState extends ConsumerState<WeightToolsSheet> {
  late final TextEditingController _controller;
  late String _unit;

  @override
  void initState() {
    super.initState();
    _unit = widget.initialUnit == LoadUnits.lbs ? LoadUnits.lbs : LoadUnits.kg;
    _controller = TextEditingController(
      text: _formatNumber(widget.initialWeight),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context, ref);
    final fittinTheme = ref.watch(resolvedFittinThemeProvider);
    final kgBarWeight = ref.watch(kgBarWeightProvider);
    final lbBarWeight = ref.watch(lbBarWeightProvider);
    final rawInput = double.tryParse(_controller.text.trim()) ?? 0;
    final convertedValue = convertWeight(
      rawInput,
      _unit,
      _unit == LoadUnits.kg ? LoadUnits.lbs : LoadUnits.kg,
    );
    final breakdown = computePlateBreakdown(
      totalWeight: rawInput,
      unit: _unit,
      barWeight: _unit == LoadUnits.lbs ? lbBarWeight : kgBarWeight,
    );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          fittinTheme.pad,
          fittinTheme.pad,
          fittinTheme.pad,
          fittinTheme.pad + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                strings.isChinese ? '重量工具' : 'Weight Tools',
                style: fittinTheme.uiStyle(22, fittinTheme.fg).copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.exerciseName == null
                    ? (strings.isChinese
                          ? '快速做千克/磅换算，并查看杠铃上片方案。'
                          : 'Convert between kg/lb and preview barbell plate loading.')
                    : (strings.isChinese
                          ? '基于当前动作快速换算重量并查看上片。'
                          : 'Use the current exercise context to convert load and preview plate loading.'),
                style: fittinTheme.uiStyle(14, fittinTheme.fgDim),
              ),
              if (widget.exerciseName != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.exerciseName!,
                  style: fittinTheme.uiStyle(14, fittinTheme.fg).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              FittinSegmented(
                theme: fittinTheme,
                options: [strings.isChinese ? '公斤' : 'kg', strings.isChinese ? '磅' : 'lb'],
                value: _unit == LoadUnits.kg
                    ? (strings.isChinese ? '公斤' : 'kg')
                    : (strings.isChinese ? '磅' : 'lb'),
                onChange: (value) {
                  setState(() {
                    _unit = value == (strings.isChinese ? '公斤' : 'kg')
                        ? LoadUnits.kg
                        : LoadUnits.lbs;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: strings.isChinese ? '输入重量' : 'Enter Weight',
                  suffixText: _unit == LoadUnits.kg ? 'kg' : 'lb',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),
              _ResultCard(
                theme: fittinTheme,
                label: strings.isChinese ? '换算结果' : 'Converted Value',
                value:
                    '${_formatNumber(convertedValue)} ${_unit == LoadUnits.kg ? 'lb' : 'kg'}',
              ),
              const SizedBox(height: 12),
              _ResultCard(
                theme: fittinTheme,
                label: strings.isChinese ? '默认杠重' : 'Default Bar Weight',
                value:
                    '${_formatNumber(_unit == LoadUnits.kg ? kgBarWeight : lbBarWeight)} ${_unit == LoadUnits.kg ? 'kg' : 'lb'}',
              ),
              const SizedBox(height: 12),
              _ResultCard(
                theme: fittinTheme,
                label: strings.isChinese ? '上片方案' : 'Plate Loading',
                value: _plateBreakdownLabel(strings, breakdown),
                dimmed: !breakdown.exact,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(strings.cancel),
                    ),
                  ),
                  if (widget.showApplyButton) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          widget.onApply?.call(rawInput, _unit);
                          Navigator.of(context).pop();
                        },
                        child: Text(strings.isChinese ? '用于当前组' : 'Use for Set'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _plateBreakdownLabel(AppStrings strings, PlateBreakdownResult result) {
    if (result.platesPerSide.isEmpty) {
      return strings.isChinese
          ? '无需加片，或当前重量低于默认杠重。'
          : 'No plates needed, or the target load is below the bar weight.';
    }
    final joined = result.platesPerSide
        .map((plate) => '${_formatNumber(plate.weight)} × ${plate.count}')
        .join(' + ');
    if (result.exact) {
      return strings.isChinese ? '每边 $joined' : '$joined each side';
    }
    return strings.isChinese
        ? '每边 $joined，仍差 ${_formatNumber(result.unresolvedWeight)} ${result.unit == LoadUnits.kg ? '公斤' : '磅'}'
        : '$joined each side, remaining ${_formatNumber(result.unresolvedWeight)} ${result.unit == LoadUnits.kg ? 'kg' : 'lb'}';
  }
}

class WeightToolsSettingsCard extends ConsumerStatefulWidget {
  const WeightToolsSettingsCard({super.key});

  @override
  ConsumerState<WeightToolsSettingsCard> createState() =>
      _WeightToolsSettingsCardState();
}

class _WeightToolsSettingsCardState
    extends ConsumerState<WeightToolsSettingsCard> {
  late final TextEditingController _kgController;
  late final TextEditingController _lbController;

  @override
  void initState() {
    super.initState();
    _kgController = TextEditingController();
    _lbController = TextEditingController();
  }

  @override
  void dispose() {
    _kgController.dispose();
    _lbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context, ref);
    final fittinTheme = ref.watch(resolvedFittinThemeProvider);
    final kgBarWeight = ref.watch(kgBarWeightProvider);
    final lbBarWeight = ref.watch(lbBarWeightProvider);
    _kgController.value = TextEditingValue(text: _formatNumber(kgBarWeight));
    _lbController.value = TextEditingValue(text: _formatNumber(lbBarWeight));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.isChinese ? '重量工具' : 'Weight Tools',
          style: fittinTheme.uiStyle(16, fittinTheme.fg).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          strings.isChinese
              ? '在设置里维护常用换算和默认杠重，训练记录页会直接复用。'
              : 'Maintain your preferred converter defaults and bar weights here for the workout logger.',
          style: fittinTheme.uiStyle(14, fittinTheme.fgDim),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _kgController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: strings.isChinese ? '公斤杠重' : 'kg Bar Weight',
                  suffixText: 'kg',
                ),
                onSubmitted: (value) {
                  final parsed = double.tryParse(value.trim());
                  if (parsed != null && parsed > 0) {
                    ref.read(kgBarWeightProvider.notifier).update(parsed);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _lbController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: strings.isChinese ? '磅杠重' : 'lb Bar Weight',
                  suffixText: 'lb',
                ),
                onSubmitted: (value) {
                  final parsed = double.tryParse(value.trim());
                  if (parsed != null && parsed > 0) {
                    ref.read(lbBarWeightProvider.notifier).update(parsed);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        FittinBtn(
          fittinTheme,
          strings.isChinese ? '打开换算器' : 'Open Converter',
          icon: Icons.calculate_rounded,
          onPressed: () {
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.black,
              builder: (_) => const WeightToolsSheet(),
            );
          },
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.theme,
    required this.label,
    required this.value,
    this.dimmed = false,
  });

  final FittinTheme theme;
  final String label;
  final String value;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.uiStyle(12, theme.fgMuted).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.uiStyle(16, theme.fg).copyWith(
              fontWeight: FontWeight.w800,
              color: theme.fg.withValues(alpha: dimmed ? 0.72 : 0.94),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatNumber(double value) {
  if (value.truncateToDouble() == value) {
    return value.toStringAsFixed(0);
  }
  if ((value * 10).roundToDouble() / 10 == value) {
    return value.toStringAsFixed(1);
  }
  return value.toStringAsFixed(2);
}
