import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/plan_library_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/localization/plan_text.dart';
import 'package:fittin_v2/src/presentation/screens/plan_editor_screen.dart';
import 'package:fittin_v2/src/presentation/widgets/charts/step_chart.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';
import 'package:fittin_v2/src/presentation/widgets/fittin_primitives.dart';

class PlanLibraryScreen extends ConsumerWidget {
  const PlanLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(planLibraryItemsProvider);
    final actionState = ref.watch(planLibraryActionProvider);
    final actionNotifier = ref.read(planLibraryActionProvider.notifier);
    final locale = ref.watch(appLocaleProvider);
    final strings = AppStrings.of(context, ref);
    final fittinTheme = ref.watch(resolvedFittinThemeProvider);

    if (actionState.infoMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(actionState.infoMessage!)));
        actionNotifier.dismissMessages();
      });
    } else if (actionState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(actionState.errorMessage!)));
        actionNotifier.dismissMessages();
      });
    }

    return templatesAsync.when(
      data: (templates) => DashboardPageScaffold(
        bottomPadding: 170,
        floatingActionButton: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: FittinBtn(
            fittinTheme,
            strings.newPlan,
            icon: Icons.add_rounded,
            onPressed: () async {
              await Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const PlanEditorScreen()));
              ref.invalidate(planLibraryItemsProvider);
            },
          ),
        ),
        children: [
          DashboardScreenHeader(
            eyebrow: strings.planLibrary,
            title: strings.isChinese ? 'Training plans' : 'Training plans',
            subtitle: strings.isChinese
                ? 'Built-in templates, custom copies, and switching live side-by-side as editable objects.'
                : 'Built-in templates, custom copies, and switching live side-by-side as editable objects.',
          ),
          const SizedBox(height: 24),
          // Filter chips — Fittin style
          Row(
            children: [
              FittinChip(fittinTheme, 'All', active: true),
              const SizedBox(width: 8),
              FittinChip(fittinTheme, strings.builtIn),
              const SizedBox(width: 8),
              FittinChip(fittinTheme, strings.custom),
              const SizedBox(width: 8),
              const Spacer(),
              FittinChip(fittinTheme, '+ New'),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: templates.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = templates[index];
              final record = item.record;
              final preview = record.template.workouts
                  .take(3)
                  .map((workout) => localizedWorkoutName(workout, locale))
                  .join(' · ');
              final workoutCount = record.template.workouts.length;
              final exerciseCount = record.template.workouts.fold<int>(
                0,
                (sum, workout) => sum + workout.exercises.length,
              );
              return DashboardSurfaceCard(
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _PlanDetailScreen(
                        record: record,
                        isActive: item.isActive,
                      ),
                    ),
                  );
                  ref.invalidate(planLibraryItemsProvider);
                },
                padding: const EdgeInsets.all(22),
                radius: 32,
                highlight: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            localizedTemplateName(record.template, locale),
                            style: fittinTheme.displayStyle(22, fittinTheme.fg).copyWith(
                              height: 1.15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: fittinTheme.fgMuted,
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        FittinEyebrow(
                          fittinTheme,
                          record.isBuiltIn ? strings.builtIn : strings.custom,
                        ),
                        if (item.isActive) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: fittinTheme.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Active',
                            style: fittinTheme.uiStyle(10, fittinTheme.accent).copyWith(
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      localizedTemplateDescription(record.template, locale),
                      style: fittinTheme.uiStyle(13, fittinTheme.fgDim).copyWith(height: 1.45),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final tag in preview.split(' · '))
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: fittinTheme.border, width: 0.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tag,
                              style: fittinTheme.uiStyle(11, fittinTheme.fgDim),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _Stat(theme: fittinTheme, label: 'Workouts', value: '$workoutCount'),
                        _Stat(theme: fittinTheme, label: 'Exercises', value: '$exerciseCount'),
                        _Stat(theme: fittinTheme, label: 'Running', value: '${record.instanceCount}'),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: FittinBtn(
                            fittinTheme,
                            item.isActive ? strings.current : strings.switchPlan,
                            size: 'sm',
                            onPressed:
                                item.isActive ||
                                    (actionState.isSwitching &&
                                        actionState.switchingTemplateId ==
                                            record.template.id)
                                ? null
                                : () async {
                                    final trainingMaxProfile =
                                        await _resolveTrainingMaxProfile(
                                          context,
                                          record,
                                        );
                                    if (!context.mounted ||
                                        trainingMaxProfile == null) {
                                      return;
                                    }
                                    await actionNotifier.activateTemplate(
                                      record,
                                      trainingMaxProfile: trainingMaxProfile,
                                    );
                                  },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FittinBtn(
                            fittinTheme,
                            strings.edit,
                            size: 'sm',
                            variant: 'secondary',
                            onPressed: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PlanEditorScreen(
                                    templateId: record.template.id,
                                  ),
                                ),
                              );
                              ref.invalidate(planLibraryItemsProvider);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) =>
          Scaffold(body: Center(child: Text(error.toString()))),
    );
  }
}

Future<TrainingMaxProfile?> _resolveTrainingMaxProfile(
  BuildContext context,
  StoredTemplateRecord record,
) async {
  if (record.instanceCount > 0 ||
      record.template.requiredTrainingMaxKeys.isEmpty) {
    return TrainingMaxProfile.empty;
  }

  return showDialog<TrainingMaxProfile>(
    context: context,
    builder: (_) => _TrainingMaxSetupDialog(template: record.template),
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.theme, required this.label, required this.value});

  final dynamic theme;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittinEyebrow(theme, label),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.numStyle(16.0, theme.fg),
        ),
      ],
    );
  }
}

class _PlanDetailScreen extends ConsumerWidget {
  const _PlanDetailScreen({required this.record, required this.isActive});

  final StoredTemplateRecord record;
  final bool isActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final strings = AppStrings.of(context, ref);
    final theme = ref.watch(resolvedFittinThemeProvider);
    final template = record.template;
    final workouts = template.workouts;
    final exerciseCount = workouts.fold<int>(
      0,
      (sum, workout) => sum + workout.exercises.length,
    );
    final progressionValues = _buildProgressionSeries(template);

    return DashboardPageScaffold(
      bottomPadding: 150,
      children: [
        Row(
          children: [
            FittinBtn(
              theme,
              'Library',
              variant: 'ghost',
              size: 'sm',
              icon: Icons.chevron_left_rounded,
              onPressed: () => Navigator.of(context).pop(),
            ),
            const Spacer(),
            FittinBtn(
              theme,
              strings.edit,
              variant: 'secondary',
              size: 'sm',
              icon: Icons.edit_rounded,
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PlanEditorScreen(templateId: template.id),
                  ),
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
            const SizedBox(width: 8),
            FittinBtn(
              theme,
              strings.switchPlan,
              size: 'sm',
              icon: Icons.play_arrow_rounded,
              onPressed: () async {
                final trainingMaxProfile = await _resolveTrainingMaxProfile(
                  context,
                  record,
                );
                if (!context.mounted || trainingMaxProfile == null) {
                  return;
                }
                await ref
                    .read(planLibraryActionProvider.notifier)
                    .activateTemplate(
                      record,
                      trainingMaxProfile: trainingMaxProfile,
                    );
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        FittinEyebrow(theme, record.isBuiltIn ? strings.builtIn : strings.custom),
        const SizedBox(height: 10),
        Text(
          localizedTemplateName(template, locale),
          style: theme.displayStyle(32, theme.fg).copyWith(height: 1.1),
        ),
        if (isActive) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: theme.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'CURRENTLY ACTIVE',
                style: theme.uiStyle(11, theme.accent).copyWith(
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        Text(
          '${localizedTemplateDescription(template, locale)} '
          '${strings.isChinese ? '根据训练最大值与既定周期结构组织主要动作训练。' : 'Derived from training maxes, with fixed weekly loading across the main training block.'}',
          style: theme.uiStyle(14, theme.fgDim).copyWith(height: 1.5),
        ),
        const SizedBox(height: 20),
        DashboardSurfaceCard(
          radius: 30,
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Stat(theme: theme, label: 'Workouts', value: '${workouts.length}'),
              _Stat(theme: theme, label: 'Exercises', value: '$exerciseCount'),
              _Stat(theme: theme, label: 'Running', value: '${record.instanceCount}'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FittinEyebrow(theme, 'Weekly structure'),
        const SizedBox(height: 10),
        ...workouts.asMap().entries.map((entry) {
          final index = entry.key;
          final workout = entry.value;
          final exerciseTotal = workout.exercises.length;
          final duration = workout.estimatedDurationMinutes;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: DashboardSurfaceCard(
              radius: 24,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  SizedBox(
                    width: 34,
                    child: Text(
                      'D${index + 1}',
                      style: theme.numStyle(20, theme.fgDim),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizedWorkoutName(workout, locale),
                          style: theme.uiStyle(14, theme.fg).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$exerciseTotal ${strings.isChinese ? '个动作' : 'exercises'}'
                          ' · $duration ${strings.isChinese ? '分钟' : 'min'}',
                          style: theme.uiStyle(12, theme.fgMuted),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.fgMuted,
                    size: 18,
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        FittinEyebrow(theme, strings.progression),
        const SizedBox(height: 10),
        DashboardSurfaceCard(
          radius: 30,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Weeks 1-${progressionValues.length}',
                    style: theme.uiStyle(13, theme.fg),
                  ),
                  Text(
                    'Intensity ${progressionValues.first.toStringAsFixed(0)}% -> ${progressionValues.last.toStringAsFixed(0)}%',
                    style: theme.numStyle(12, theme.fgDim),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              StepChart(
                theme,
                progressionValues,
                height: 120,
                showDots: false,
                yLabels: const ['95', '78', '60'],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

List<double> _buildProgressionSeries(PlanTemplate template) {
  final maxStages = template.workouts.fold<int>(
    1,
    (max, workout) => workout.exercises.fold<int>(
      max,
      (inner, exercise) => exercise.stages.length > inner ? exercise.stages.length : inner,
    ),
  );
  if (maxStages <= 1) {
    return const [60, 70, 80, 90];
  }

  final start = 60.0;
  final end = 92.0;
  return List<double>.generate(maxStages, (index) {
    final progress = maxStages == 1 ? 1.0 : index / (maxStages - 1);
    return start + (end - start) * progress;
  });
}

class _TrainingMaxSetupDialog extends StatefulWidget {
  const _TrainingMaxSetupDialog({required this.template});

  final PlanTemplate template;

  @override
  State<_TrainingMaxSetupDialog> createState() =>
      _TrainingMaxSetupDialogState();
}

class _TrainingMaxSetupDialogState extends State<_TrainingMaxSetupDialog> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final key in widget.template.requiredTrainingMaxKeys)
        key: TextEditingController(),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final container = ProviderScope.containerOf(context);
    final locale = container.read(appLocaleProvider);
    final strings = AppStrings.fromLocale(locale);
    return AlertDialog(
      title: Text(strings.setTrainingMaxes),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localizedTemplateName(widget.template, locale),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                strings.isChinese
                    ? '可以先输入已知主项训练最大值，或直接快速开始，之后再去计划编辑页补齐动作起始重量。'
                    : 'Enter known training maxes now, or quick start first and fill in accessory starting loads later in the plan editor.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              for (final liftKey
                  in widget.template.requiredTrainingMaxKeys) ...[
                TextFormField(
                  controller: _controllers[liftKey],
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: liftLabelFor(liftKey),
                    hintText: 'kg',
                  ),
                  validator: (value) {
                    final parsed = double.tryParse((value ?? '').trim());
                    if (parsed == null || parsed <= 0) {
                      return strings.enterValidMax;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(TrainingMaxProfile.empty),
          child: Text(strings.isChinese ? '快速开始' : 'Quick Start'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }
            Navigator.of(context).pop(
              TrainingMaxProfile({
                for (final entry in _controllers.entries)
                  entry.key: double.parse(entry.value.text.trim()),
              }),
            );
          },
          child: Text(strings.startPlan),
        ),
      ],
    );
  }
}
