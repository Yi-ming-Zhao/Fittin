import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/exercise_library_provider.dart';
import 'package:fittin_v2/src/application/plan_start_load_review_service.dart';
import 'package:fittin_v2/src/application/plan_library_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/local/local_workout_log_repository.dart';
import 'package:fittin_v2/src/domain/exercise_performance_profile.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';
import 'package:fittin_v2/src/domain/plan_start_load_review.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/localization/plan_text.dart';
import 'package:fittin_v2/src/presentation/screens/plan_editor_screen.dart';
import 'package:fittin_v2/src/presentation/screens/share_screen.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';
import 'package:fittin_v2/src/presentation/widgets/fittin_primitives.dart';
import 'package:fittin_v2/src/presentation/widgets/plan_start_load_review_dialog.dart';

enum _PlanFilter { all, builtIn, custom }

class PlanLibraryScreen extends ConsumerStatefulWidget {
  const PlanLibraryScreen({super.key});

  @override
  ConsumerState<PlanLibraryScreen> createState() => _PlanLibraryScreenState();
}

class _PlanLibraryScreenState extends ConsumerState<PlanLibraryScreen> {
  _PlanFilter _filter = _PlanFilter.all;

  @override
  Widget build(BuildContext context) {
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
      data: (templates) {
        final visibleTemplates = switch (_filter) {
          _PlanFilter.all => templates,
          _PlanFilter.builtIn =>
            templates
                .where((item) => item.record.isBuiltIn)
                .toList(growable: false),
          _PlanFilter.custom =>
            templates
                .where((item) => !item.record.isBuiltIn)
                .toList(growable: false),
        };
        return DashboardPageScaffold(
          bottomPadding: 24,
          children: [
            DashboardScreenHeader(
              eyebrow: strings.planLibrary,
              title: strings.trainingPlans,
              subtitle: strings.trainingPlansSubtitle,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FittinChip(
                  fittinTheme,
                  strings.all,
                  key: const ValueKey('plan-filter-all'),
                  active: _filter == _PlanFilter.all,
                  onTap: () => setState(() => _filter = _PlanFilter.all),
                ),
                FittinChip(
                  fittinTheme,
                  strings.builtIn,
                  key: const ValueKey('plan-filter-built-in'),
                  active: _filter == _PlanFilter.builtIn,
                  onTap: () => setState(() => _filter = _PlanFilter.builtIn),
                ),
                FittinChip(
                  fittinTheme,
                  strings.custom,
                  key: const ValueKey('plan-filter-custom'),
                  active: _filter == _PlanFilter.custom,
                  onTap: () => setState(() => _filter = _PlanFilter.custom),
                ),
                FittinChip(
                  fittinTheme,
                  '+ ${strings.newPlan}',
                  key: const ValueKey('create-plan'),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PlanEditorScreen(),
                      ),
                    );
                    if (mounted) {
                      ref.invalidate(planLibraryItemsProvider);
                    }
                  },
                ),
                FittinChip(
                  fittinTheme,
                  strings.scanPlanQr,
                  key: const ValueKey('import-plan-qr'),
                  onTap: () async {
                    final imported = await Navigator.of(context)
                        .push<PlanTemplate>(
                          MaterialPageRoute(
                            builder: (_) => const QRScannerScreen(),
                          ),
                        );
                    if (!context.mounted || imported == null) return;
                    ref.invalidate(planLibraryItemsProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          strings.importedTemplate(
                            localizedTemplateName(imported, locale),
                          ),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (visibleTemplates.isEmpty)
              DashboardSurfaceCard(
                child: Text(
                  strings.noPlansForFilter,
                  style: fittinTheme.uiStyle(14, fittinTheme.fgDim),
                ),
              )
            else
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: visibleTemplates.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = visibleTemplates[index];
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
                    padding: const EdgeInsets.all(20),
                    radius: 20,
                    highlight: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            FittinEyebrow(
                              fittinTheme,
                              record.isBuiltIn
                                  ? strings.builtIn
                                  : strings.custom,
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
                                strings.active,
                                style: fittinTheme
                                    .uiStyle(10, fittinTheme.accent)
                                    .copyWith(letterSpacing: 0.8),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                localizedTemplateName(record.template, locale),
                                style: fittinTheme
                                    .displayStyle(22, fittinTheme.fg)
                                    .copyWith(height: 1.15),
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
                        const SizedBox(height: 12),
                        Text(
                          localizedTemplateDescription(record.template, locale),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: fittinTheme
                              .uiStyle(13, fittinTheme.fgDim)
                              .copyWith(height: 1.45),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final tag in preview.split(' · '))
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: fittinTheme.border,
                                    width: 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  tag,
                                  style: fittinTheme.uiStyle(
                                    11,
                                    fittinTheme.fgDim,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _Stat(
                              theme: fittinTheme,
                              label: strings.workoutsStat,
                              value: '$workoutCount',
                            ),
                            _Stat(
                              theme: fittinTheme,
                              label: strings.exercisesStat,
                              value: '$exerciseCount',
                            ),
                            _Stat(
                              theme: fittinTheme,
                              label: strings.runningStat,
                              value: '${record.instanceCount}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        );
      },
      loading: () => DashboardPageScaffold(
        bottomPadding: 24,
        children: [
          DashboardScreenHeader(
            eyebrow: strings.planLibrary,
            title: strings.trainingPlans,
            subtitle: strings.trainingPlansSubtitle,
          ),
          const SizedBox(height: 24),
          DashboardSurfaceCard(
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: fittinTheme.accent,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    strings.startupPreparing,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: fittinTheme.uiStyle(14, fittinTheme.fgDim),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      error: (error, _) => DashboardPageScaffold(
        bottomPadding: 24,
        children: [
          DashboardScreenHeader(
            eyebrow: strings.planLibrary,
            title: strings.trainingPlans,
            subtitle: strings.trainingPlansSubtitle,
          ),
          const SizedBox(height: 24),
          DashboardSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.loadError(error),
                  style: fittinTheme.uiStyle(14, fittinTheme.fgDim),
                ),
                const SizedBox(height: 16),
                FittinBtn(
                  fittinTheme,
                  strings.retry,
                  key: const ValueKey('retry-plan-library'),
                  size: 'sm',
                  icon: Icons.refresh_rounded,
                  onPressed: () => ref.invalidate(planLibraryItemsProvider),
                ),
              ],
            ),
          ),
        ],
      ),
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

Future<PlanStartLoadReview?> _resolvePlanStartLoadReview(
  BuildContext context,
  WidgetRef ref,
  StoredTemplateRecord record,
) async {
  final library = await ref.read(exerciseLibraryProvider.future);
  final logs = await ref
      .read(localWorkoutLogRepositoryProvider)
      .fetchAllWorkoutLogs();
  final formula = await ref
      .read(databaseRepositoryProvider)
      .fetchAnalyticsFormula();
  final profiles = const ExercisePerformanceProfileService().build(
    logs: logs,
    library: library,
    formula: formula,
  );
  final review = const PlanStartLoadReviewService().build(
    template: record.template,
    library: library,
    profiles: profiles,
    formula: formula,
    localeCode: ref.read(appLocaleProvider).code,
  );
  if (review.editableEntries.isEmpty || !context.mounted) {
    return review;
  }
  return showDialog<PlanStartLoadReview>(
    context: context,
    barrierDismissible: false,
    builder: (_) => PlanStartLoadReviewDialog(review: review),
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
        Text(value, style: theme.numStyle(16.0, theme.fg)),
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
    final exerciseLibrary = ref.watch(exerciseLibraryProvider).valueOrNull;
    final template = record.template;
    final workouts = template.workouts;
    final exerciseCount = workouts.fold<int>(
      0,
      (sum, workout) => sum + workout.exercises.length,
    );
    final progression = _buildProgressionSummary(template);

    return DashboardPageScaffold(
      bottomPadding: 24,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardBackButton(
              theme: theme,
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  FittinBtn(
                    theme,
                    strings.edit,
                    variant: 'secondary',
                    size: 'sm',
                    icon: Icons.edit_rounded,
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              PlanEditorScreen(templateId: template.id),
                        ),
                      );
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  FittinBtn(
                    theme,
                    strings.switchPlan,
                    size: 'sm',
                    icon: Icons.play_arrow_rounded,
                    onPressed: () async {
                      final trainingMaxProfile =
                          await _resolveTrainingMaxProfile(context, record);
                      if (!context.mounted || trainingMaxProfile == null) {
                        return;
                      }
                      PlanStartLoadReview? loadReview;
                      if (record.instanceCount == 0) {
                        loadReview = await _resolvePlanStartLoadReview(
                          context,
                          ref,
                          record,
                        );
                        if (!context.mounted || loadReview == null) {
                          return;
                        }
                      }
                      await ref
                          .read(planLibraryActionProvider.notifier)
                          .activateTemplate(
                            record,
                            trainingMaxProfile: trainingMaxProfile,
                            planStartLoadReview: loadReview,
                          );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        FittinEyebrow(
          theme,
          record.isBuiltIn ? strings.builtIn : strings.custom,
        ),
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
                strings.currentlyActive,
                style: theme
                    .uiStyle(11, theme.accent)
                    .copyWith(letterSpacing: 0.8, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        Text(
          localizedTemplateDescription(template, locale),
          style: theme.uiStyle(14, theme.fgDim).copyWith(height: 1.5),
        ),
        const SizedBox(height: 20),
        DashboardSurfaceCard(
          radius: theme.radius,
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Stat(
                theme: theme,
                label: strings.workoutsStat,
                value: '${workouts.length}',
              ),
              _Stat(
                theme: theme,
                label: strings.exercisesStat,
                value: '$exerciseCount',
              ),
              _Stat(
                theme: theme,
                label: strings.runningStat,
                value: '${record.instanceCount}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FittinEyebrow(theme, strings.weeklyStructure),
        const SizedBox(height: 10),
        ...workouts.asMap().entries.map((entry) {
          final index = entry.key;
          final workout = entry.value;
          final exerciseTotal = workout.exercises.length;
          final duration = workout.estimatedDurationMinutes;
          final exerciseNames = workout.exercises
              .map(
                (exercise) => localizedExerciseName(
                  exercise,
                  locale,
                  library: exerciseLibrary,
                ),
              )
              .join(' · ');
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: DashboardSurfaceCard(
              radius: theme.radius,
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
                          style: theme
                              .uiStyle(14, theme.fg)
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          exerciseNames,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.uiStyle(12, theme.fgDim),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          strings.workoutStructureSummary(
                            exerciseTotal,
                            duration,
                          ),
                          style: theme.uiStyle(12, theme.fgMuted),
                        ),
                      ],
                    ),
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
          radius: theme.radius,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    strings.progressionStages(progression.stageCount),
                    style: theme.uiStyle(13, theme.fg),
                  ),
                  if (progression.lowerIntensityPercent != null &&
                      progression.upperIntensityPercent != null)
                    Flexible(
                      child: Text(
                        strings.progressionIntensityRange(
                          progression.lowerIntensityPercent!,
                          progression.upperIntensityPercent!,
                        ),
                        textAlign: TextAlign.end,
                        style: theme.numStyle(12, theme.fgDim),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                strings.progressionSummary,
                style: theme.uiStyle(12, theme.fgMuted).copyWith(height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

_PlanProgressionSummary _buildProgressionSummary(PlanTemplate template) {
  final stageCount = template.workouts.fold<int>(
    1,
    (max, workout) => workout.exercises.fold<int>(
      max,
      (inner, exercise) =>
          exercise.stages.length > inner ? exercise.stages.length : inner,
    ),
  );
  final intensities = <double>[];
  for (final workout in template.workouts) {
    for (final exercise in workout.exercises) {
      for (final stage in exercise.stages) {
        for (final set in stage.sets) {
          if (set.kind != SetKinds.warmup &&
              set.intensity > 0 &&
              set.intensity.isFinite) {
            intensities.add(set.intensity * 100);
          }
        }
      }
    }
  }
  intensities.sort();
  return _PlanProgressionSummary(
    stageCount: stageCount,
    lowerIntensityPercent: intensities.isEmpty ? null : intensities.first,
    upperIntensityPercent: intensities.isEmpty ? null : intensities.last,
  );
}

class _PlanProgressionSummary {
  const _PlanProgressionSummary({
    required this.stageCount,
    required this.lowerIntensityPercent,
    required this.upperIntensityPercent,
  });

  final int stageCount;
  final double? lowerIntensityPercent;
  final double? upperIntensityPercent;
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
    final fittinTheme = container.read(resolvedFittinThemeProvider);
    return AlertDialog(
      backgroundColor: fittinTheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(fittinTheme.radius),
        side: BorderSide(color: fittinTheme.border),
      ),
      title: Text(
        strings.setTrainingMaxes,
        style: fittinTheme.displayStyle(22, fittinTheme.fg),
      ),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  localizedTemplateName(widget.template, locale),
                  style: fittinTheme
                      .uiStyle(14, fittinTheme.fg)
                      .copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                Text(
                  strings.trainingMaxSetupDescription,
                  style: fittinTheme
                      .uiStyle(12, fittinTheme.fgDim)
                      .copyWith(height: 1.45),
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
      ),
      actions: [
        FittinBtn(
          fittinTheme,
          strings.cancel,
          size: 'sm',
          variant: 'secondary',
          onPressed: () => Navigator.of(context).pop(),
        ),
        FittinBtn(
          fittinTheme,
          strings.startPlan,
          size: 'sm',
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
        ),
      ],
    );
  }
}
