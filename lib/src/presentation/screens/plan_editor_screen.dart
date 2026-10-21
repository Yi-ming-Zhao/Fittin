import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/template_editor_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/template_validation.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/screens/share_screen.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';
import 'package:fittin_v2/src/presentation/widgets/fittin_primitives.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart'
    show FittinTheme;

class PlanEditorScreen extends ConsumerStatefulWidget {
  const PlanEditorScreen({super.key, this.templateId});

  final String? templateId;

  @override
  ConsumerState<PlanEditorScreen> createState() => _PlanEditorScreenState();
}

class _PlanEditorScreenState extends ConsumerState<PlanEditorScreen> {
  int _selectedWorkoutIndex = 0;
  int _selectedPeriodizedWeek = 0;
  final _settingsController = ExpansibleController();
  final _settingsAnchor = GlobalKey();

  @override
  void dispose() {
    _settingsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = ref.read(templateEditorProvider);
      final notifier = ref.read(templateEditorProvider.notifier);
      if (widget.templateId == null) {
        if (currentState.draft != null) {
          return;
        }
        notifier.createBlankTemplate();
      } else {
        if (currentState.draft?.id == widget.templateId) {
          return;
        }
        notifier.loadTemplate(widget.templateId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(templateEditorProvider);
    final notifier = ref.read(templateEditorProvider.notifier);
    final strings = AppStrings.of(context, ref);
    final fittinTheme = ref.watch(resolvedFittinThemeProvider);
    final draft = state.draft;

    if (draft == null && state.errorMessage != null) {
      return DashboardPageScaffold(
        layout: DashboardPageLayout.detail,
        children: [
          DashboardScreenHeader(
            title: strings.templateEditor,
            showBackButton: true,
          ),
          const SizedBox(height: 24),
          Text(
            strings.isChinese
                ? '计划暂不可读取，草稿没有被覆盖。'
                : 'The plan could not be loaded. Existing drafts were not overwritten.',
          ),
          FilledButton(
            onPressed: widget.templateId == null
                ? notifier.createBlankTemplate
                : () => notifier.loadTemplate(widget.templateId!),
            child: Text(strings.isChinese ? '重试' : 'Retry'),
          ),
        ],
      );
    }
    if (state.isLoading || draft == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    _showPendingSnackbars(state, notifier, strings);

    final workouts = draft.workouts;
    if (_selectedWorkoutIndex >= workouts.length) {
      _selectedWorkoutIndex = workouts.isEmpty ? 0 : workouts.length - 1;
    }

    final isPeriodized = draft.isPeriodized;
    final visibleWorkout = workouts.isEmpty
        ? null
        : workouts[_selectedWorkoutIndex];
    final availableWeeks = visibleWorkout == null
        ? 1
        : _weekCountForWorkout(visibleWorkout);
    if (_selectedPeriodizedWeek >= availableWeeks) {
      _selectedPeriodizedWeek = 0;
    }

    return DashboardPageScaffold(
      layout: DashboardPageLayout.detail,
      children: [
        Row(
          children: [
            DashboardBackButton(theme: fittinTheme),
            const Spacer(),
            _HeaderActions(
              theme: fittinTheme,
              strings: strings,
              isSaving: state.isSaving,
              onShare: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ShareScreen(planTemplate: draft),
                  ),
                );
              },
              onSave: () async => notifier.saveTemplate(),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          draft.name,
          style: fittinTheme
              .displayStyle(28, fittinTheme.fg)
              .copyWith(height: 1.15),
        ),
        const SizedBox(height: 20),
        if (state.sourceTemplate != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _InfoBanner(
              message: state.sourceTemplate!.isBuiltIn
                  ? strings.builtInTemplateCopyNotice
                  : state.sourceTemplate!.instanceCount > 0
                  ? strings.activeTemplateCopyNotice
                  : strings.customTemplateEditNotice,
            ),
          ),
        if (state.validationErrors.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ValidationBanner(
              errors: state.validationErrors,
              strings: strings,
              onSelect: (index) {
                final issues = TemplateValidation.validate(draft).issues;
                if (index >= issues.length) return;
                final issue = issues[index];
                if (issue.workoutId == null) {
                  _settingsController.expand();
                  final settingsContext = _settingsAnchor.currentContext;
                  if (settingsContext != null) {
                    Scrollable.ensureVisible(
                      settingsContext,
                      duration: const Duration(milliseconds: 180),
                    );
                  }
                  return;
                }
                final exercise = draft.workouts
                    .firstWhere((day) => day.id == issue.workoutId)
                    .exercises
                    .where((exercise) => exercise.id == issue.exerciseId)
                    .firstOrNull;
                final stageIndex =
                    exercise?.stages.indexWhere(
                      (stage) => stage.id == issue.stageId,
                    ) ??
                    -1;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => exercise == null
                        ? _PlanDayEditor(workoutId: issue.workoutId!)
                        : _PlanExerciseEditor(
                            workoutId: issue.workoutId!,
                            exerciseId: exercise.id,
                            week: isPeriodized && stageIndex >= 0
                                ? stageIndex
                                : null,
                          ),
                  ),
                );
              },
            ),
          ),
        ExpansionTile(
          key: const ValueKey('plan-editor-settings'),
          controller: _settingsController,
          title: Text(
            strings.isChinese ? '计划设置' : 'Plan settings',
            key: _settingsAnchor,
          ),
          children: [
            _TemplateMetaCard(
              draft: draft,
              notifier: notifier,
              strings: strings,
            ),
            _ModeSelectorCard(
              scheduleMode: draft.resolvedScheduleMode,
              notifier: notifier,
              strings: strings,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (isPeriodized && visibleWorkout != null) ...[
          _PeriodizedSlotCard(
            theme: fittinTheme,
            strings: strings,
            workouts: workouts,
            selectedWorkoutIndex: _selectedWorkoutIndex,
            selectedWeekIndex: _selectedPeriodizedWeek,
            onWorkoutSelected: (index) {
              setState(() {
                _selectedWorkoutIndex = index;
                _selectedPeriodizedWeek = 0;
              });
            },
            onWeekSelected: (index) {
              setState(() {
                _selectedPeriodizedWeek = index;
              });
            },
          ),
          const SizedBox(height: 16),
          _dayTile(context, visibleWorkout, _selectedPeriodizedWeek, strings),
        ] else ...[
          for (
            var workoutIndex = 0;
            workoutIndex < workouts.length;
            workoutIndex++
          )
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _dayTile(context, workouts[workoutIndex], null, strings),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: FittinBtn(
              fittinTheme,
              strings.addWorkout,
              variant: 'secondary',
              size: 'sm',
              icon: Icons.add_rounded,
              onPressed: notifier.addWorkout,
            ),
          ),
        ],
      ],
    );
  }

  Widget _dayTile(
    BuildContext context,
    Workout workout,
    int? week,
    AppStrings strings,
  ) => DashboardSurfaceCard(
    key: ValueKey('edit-day-${workout.id}'),
    onTap: () => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PlanDayEditor(workoutId: workout.id, week: week),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                workout.name,
                style: refTheme(
                  context,
                ).uiStyle(17, refTheme(context).fg, FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                strings.isChinese
                    ? '${workout.exercises.length} 个动作 · ${workout.estimatedDurationMinutes} 分钟'
                    : '${workout.exercises.length} exercises · ${workout.estimatedDurationMinutes} min',
                style: refTheme(context).uiStyle(13, refTheme(context).fgDim),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right_rounded, color: refTheme(context).fgDim),
      ],
    ),
  );

  void _showPendingSnackbars(
    TemplateEditorState state,
    TemplateEditorNotifier notifier,
    AppStrings strings,
  ) {
    if (state.infoMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              strings.templateEditorInfoMessage(state.infoMessage!),
            ),
          ),
        );
        notifier.dismissMessages();
      });
    } else if (state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              strings.templateEditorErrorMessage(state.errorMessage!),
            ),
          ),
        );
        notifier.dismissMessages();
      });
    }
  }

  int _weekCountForWorkout(Workout workout) {
    var maxCount = 1;
    for (final exercise in workout.exercises) {
      if (exercise.stages.length > maxCount) {
        maxCount = exercise.stages.length;
      }
    }
    return maxCount;
  }
}

class _HeaderActions extends StatelessWidget {
  const _HeaderActions({
    required this.theme,
    required this.strings,
    required this.isSaving,
    required this.onShare,
    required this.onSave,
  });

  final FittinTheme theme;
  final AppStrings strings;
  final bool isSaving;
  final VoidCallback onShare;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittinBtn(
          theme,
          strings.share,
          variant: 'secondary',
          size: 'sm',
          icon: Icons.qr_code_2_rounded,
          onPressed: onShare,
        ),
        const SizedBox(width: 8),
        FittinBtn(
          theme,
          isSaving ? strings.saving : strings.save,
          size: 'sm',
          icon: isSaving ? null : Icons.save_outlined,
          onPressed: isSaving ? null : () => onSave(),
        ),
      ],
    );
  }
}

class _TemplateMetaCard extends StatelessWidget {
  const _TemplateMetaCard({
    required this.draft,
    required this.notifier,
    required this.strings,
  });

  final PlanTemplate draft;
  final TemplateEditorNotifier notifier;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return _EditorCard(
      title: strings.templateSection,
      child: Column(
        children: [
          _DraftTextField(
            label: strings.templateName,
            value: draft.name,
            onChanged: notifier.updateTemplateName,
          ),
          const SizedBox(height: 12),
          _DraftTextField(
            label: strings.description,
            value: draft.description,
            maxLines: 3,
            onChanged: notifier.updateTemplateDescription,
          ),
        ],
      ),
    );
  }
}

class _ModeSelectorCard extends StatelessWidget {
  const _ModeSelectorCard({
    required this.scheduleMode,
    required this.notifier,
    required this.strings,
  });

  final String scheduleMode;
  final TemplateEditorNotifier notifier;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return _EditorCard(
      title: strings.scheduleMode,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          SizedBox(
            width: 220,
            child: _ModeTile(
              selected: scheduleMode == PlanScheduleModes.linear,
              title: strings.linearPlan,
              subtitle: strings.linearPlanModeDescription,
              onTap: () =>
                  notifier.updateScheduleMode(PlanScheduleModes.linear),
            ),
          ),
          SizedBox(
            width: 220,
            child: _ModeTile(
              selected: scheduleMode == PlanScheduleModes.periodized,
              title: strings.periodizedPlan,
              subtitle: strings.periodizedPlanModeDescription,
              onTap: () =>
                  notifier.updateScheduleMode(PlanScheduleModes.periodized),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodizedSlotCard extends StatelessWidget {
  const _PeriodizedSlotCard({
    required this.theme,
    required this.strings,
    required this.workouts,
    required this.selectedWorkoutIndex,
    required this.selectedWeekIndex,
    required this.onWorkoutSelected,
    required this.onWeekSelected,
  });

  final FittinTheme theme;
  final AppStrings strings;
  final List<Workout> workouts;
  final int selectedWorkoutIndex;
  final int selectedWeekIndex;
  final ValueChanged<int> onWorkoutSelected;
  final ValueChanged<int> onWeekSelected;

  @override
  Widget build(BuildContext context) {
    final weekCount = workouts.fold<int>(
      1,
      (max, workout) => workout.exercises.fold<int>(
        max,
        (innerMax, exercise) => exercise.stages.length > innerMax
            ? exercise.stages.length
            : innerMax,
      ),
    );

    return _EditorCard(
      title: strings.weekDaySlot,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < workouts.length; i++)
                _SlotChip(
                  theme: theme,
                  label: strings.daySlotLabel(i + 1),
                  selected: i == selectedWorkoutIndex,
                  onTap: () => onWorkoutSelected(i),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < weekCount; i++)
                _SlotChip(
                  theme: theme,
                  label: strings.weekSlotLabel(i + 1),
                  selected: i == selectedWeekIndex,
                  onTap: () => onWeekSelected(i),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanDayEditor extends ConsumerWidget {
  const _PlanDayEditor({required this.workoutId, this.week});
  final String workoutId;
  final int? week;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(templateEditorProvider).draft;
    final index =
        draft?.workouts.indexWhere((day) => day.id == workoutId) ?? -1;
    final strings = AppStrings.of(context, ref);
    return DashboardPageScaffold(
      layout: DashboardPageLayout.detail,
      children: [
        DashboardScreenHeader(
          title: index < 0 ? strings.workoutName : draft!.workouts[index].name,
          showBackButton: true,
        ),
        const SizedBox(height: 16),
        if (index >= 0)
          _WorkoutEditorCard(
            workout: draft!.workouts[index],
            workoutIndex: index,
            notifier: ref.read(templateEditorProvider.notifier),
            strings: strings,
            periodizedWeekIndex: week,
            showWorkoutMetadataEditor: true,
            allowPeriodizedSlotFocus: week != null,
            compactExercises: true,
            periodizedSlotLabel: week == null
                ? null
                : strings.periodizedEditorSlotLabel(week! + 1, index + 1),
          ),
        if (index < 0)
          Text(
            strings.isChinese
                ? '这个训练日已移除，请返回计划总览。'
                : 'This day was removed. Return to the plan overview.',
          ),
      ],
    );
  }
}

class _PlanExerciseEditor extends ConsumerWidget {
  const _PlanExerciseEditor({
    required this.workoutId,
    required this.exerciseId,
    this.week,
  });
  final String workoutId;
  final String exerciseId;
  final int? week;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(templateEditorProvider).draft;
    final dayIndex =
        draft?.workouts.indexWhere((day) => day.id == workoutId) ?? -1;
    final exerciseIndex = dayIndex < 0
        ? -1
        : draft!.workouts[dayIndex].exercises.indexWhere(
            (exercise) => exercise.id == exerciseId,
          );
    final strings = AppStrings.of(context, ref);
    return DashboardPageScaffold(
      layout: DashboardPageLayout.detail,
      children: [
        DashboardScreenHeader(
          title: exerciseIndex < 0
              ? strings.exerciseName
              : draft!.workouts[dayIndex].exercises[exerciseIndex].name,
          showBackButton: true,
        ),
        const SizedBox(height: 16),
        if (exerciseIndex >= 0)
          _ExerciseEditorCard(
            workoutIndex: dayIndex,
            exerciseIndex: exerciseIndex,
            exercise: draft!.workouts[dayIndex].exercises[exerciseIndex],
            notifier: ref.read(templateEditorProvider.notifier),
            strings: strings,
            visibleStageIndex: week,
            showRules: week == null,
            standalone: true,
          ),
        if (exerciseIndex < 0)
          Text(
            strings.isChinese
                ? '这个动作已移除，请返回训练日。'
                : 'This exercise was removed. Return to its training day.',
          ),
      ],
    );
  }
}

class _WorkoutEditorCard extends StatelessWidget {
  const _WorkoutEditorCard({
    required this.workout,
    required this.workoutIndex,
    required this.notifier,
    required this.strings,
    this.periodizedWeekIndex,
    this.showWorkoutMetadataEditor = false,
    this.allowPeriodizedSlotFocus = false,
    this.periodizedSlotLabel,
    this.compactExercises = false,
  });

  final Workout workout;
  final int workoutIndex;
  final TemplateEditorNotifier notifier;
  final AppStrings strings;
  final int? periodizedWeekIndex;
  final bool showWorkoutMetadataEditor;
  final bool allowPeriodizedSlotFocus;
  final String? periodizedSlotLabel;
  final bool compactExercises;

  @override
  Widget build(BuildContext context) {
    final title = periodizedSlotLabel == null
        ? '${workout.dayLabel} · ${workout.name}'
        : '$periodizedSlotLabel · ${workout.name}';

    return _EditorCard(
      title: compactExercises ? '' : title,
      plain: compactExercises,
      actions: allowPeriodizedSlotFocus
          ? null
          : [
              _EditorActionButton(
                controlKey: ValueKey('workout-$workoutIndex-move-up'),
                onPressed: () => notifier.moveWorkout(workoutIndex, -1),
                label: strings.moveWorkoutUp,
                icon: Icons.arrow_upward_rounded,
              ),
              _EditorActionButton(
                controlKey: ValueKey('workout-$workoutIndex-move-down'),
                onPressed: () => notifier.moveWorkout(workoutIndex, 1),
                label: strings.moveWorkoutDown,
                icon: Icons.arrow_downward_rounded,
              ),
              _EditorActionButton(
                controlKey: ValueKey('workout-$workoutIndex-duplicate'),
                onPressed: () => notifier.duplicateWorkout(workoutIndex),
                label: strings.duplicateWorkout,
                icon: Icons.copy_rounded,
              ),
              _EditorActionButton(
                controlKey: ValueKey('workout-$workoutIndex-delete'),
                onPressed: () => notifier.removeWorkout(workoutIndex),
                label: strings.deleteWorkout,
                icon: Icons.delete_outline_rounded,
              ),
            ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showWorkoutMetadataEditor) ...[
            _DraftTextField(
              label: strings.workoutName,
              value: workout.name,
              onChanged: (value) =>
                  notifier.updateWorkoutName(workoutIndex, value),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 160,
                  child: _DraftTextField(
                    label: strings.dayLabel,
                    value: workout.dayLabel,
                    onChanged: (value) =>
                        notifier.updateWorkoutDayLabel(workoutIndex, value),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: _DraftIntField(
                    label: strings.minutes,
                    value: workout.estimatedDurationMinutes,
                    onChanged: (value) =>
                        notifier.updateWorkoutDuration(workoutIndex, value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          for (
            var exerciseIndex = 0;
            exerciseIndex < workout.exercises.length;
            exerciseIndex++
          )
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: compactExercises
                  ? DashboardSurfaceCard(
                      key: ValueKey(
                        'edit-exercise-${workout.exercises[exerciseIndex].id}',
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => _PlanExerciseEditor(
                            workoutId: workout.id,
                            exerciseId: workout.exercises[exerciseIndex].id,
                            week: periodizedWeekIndex,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              workout.exercises[exerciseIndex].name,
                              style: refTheme(
                                context,
                              ).uiStyle(16, refTheme(context).fg),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: refTheme(context).fgDim,
                          ),
                        ],
                      ),
                    )
                  : _ExerciseEditorCard(
                      workoutIndex: workoutIndex,
                      exerciseIndex: exerciseIndex,
                      exercise: workout.exercises[exerciseIndex],
                      notifier: notifier,
                      strings: strings,
                      visibleStageIndex: periodizedWeekIndex,
                      showRules: periodizedWeekIndex == null,
                    ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: FittinBtn(
              refTheme(context),
              strings.addExercise,
              variant: 'secondary',
              size: 'sm',
              icon: Icons.add_rounded,
              onPressed: () => notifier.addExercise(workoutIndex),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseEditorCard extends StatelessWidget {
  const _ExerciseEditorCard({
    required this.workoutIndex,
    required this.exerciseIndex,
    required this.exercise,
    required this.notifier,
    required this.strings,
    this.visibleStageIndex,
    required this.showRules,
    this.standalone = false,
  });

  final int workoutIndex;
  final int exerciseIndex;
  final Exercise exercise;
  final TemplateEditorNotifier notifier;
  final AppStrings strings;
  final int? visibleStageIndex;
  final bool showRules;
  final bool standalone;

  @override
  Widget build(BuildContext context) {
    final tierOptions = const ['T1', 'T2', 'T3'];
    final visibleStages = visibleStageIndex == null
        ? exercise.stages.asMap().entries.toList()
        : [
            if (visibleStageIndex! < exercise.stages.length)
              MapEntry(visibleStageIndex!, exercise.stages[visibleStageIndex!]),
          ];

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (standalone)
              const Spacer()
            else
              Expanded(
                child: Text(
                  exercise.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            _EditorActionButton(
              controlKey: ValueKey(
                'exercise-$workoutIndex-$exerciseIndex-move-up',
              ),
              onPressed: () =>
                  notifier.moveExercise(workoutIndex, exerciseIndex, -1),
              label: strings.moveExerciseUp,
              icon: Icons.arrow_upward_rounded,
            ),
            _EditorActionButton(
              controlKey: ValueKey(
                'exercise-$workoutIndex-$exerciseIndex-move-down',
              ),
              onPressed: () =>
                  notifier.moveExercise(workoutIndex, exerciseIndex, 1),
              label: strings.moveExerciseDown,
              icon: Icons.arrow_downward_rounded,
            ),
            _EditorActionButton(
              controlKey: ValueKey(
                'exercise-$workoutIndex-$exerciseIndex-duplicate',
              ),
              onPressed: () =>
                  notifier.duplicateExercise(workoutIndex, exerciseIndex),
              label: strings.duplicateExercise,
              icon: Icons.copy_rounded,
            ),
            _EditorActionButton(
              controlKey: ValueKey(
                'exercise-$workoutIndex-$exerciseIndex-delete',
              ),
              onPressed: () =>
                  notifier.removeExercise(workoutIndex, exerciseIndex),
              label: strings.deleteExercise,
              icon: Icons.delete_outline_rounded,
            ),
          ],
        ),
        _DraftTextField(
          label: strings.exerciseName,
          value: exercise.name,
          onChanged: (value) =>
              notifier.updateExerciseName(workoutIndex, exerciseIndex, value),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 120,
              child: _DraftIntField(
                label: strings.restSeconds,
                value: exercise.restSeconds,
                onChanged: (value) => notifier.updateExerciseRestSeconds(
                  workoutIndex,
                  exerciseIndex,
                  value,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 140,
              child: _DraftDoubleField(
                label: strings.startWeight,
                value: exercise.initialBaseWeight,
                onChanged: (value) => notifier.updateExerciseBaseWeight(
                  workoutIndex,
                  exerciseIndex,
                  value,
                ),
              ),
            ),
            SizedBox(
              width: 160,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: exercise.loadUnit,
                decoration: InputDecoration(labelText: strings.loadUnit),
                items: [
                  DropdownMenuItem(
                    value: LoadUnits.kg,
                    child: const Text('kg'),
                  ),
                  DropdownMenuItem(
                    value: LoadUnits.lbs,
                    child: const Text('lbs'),
                  ),
                  DropdownMenuItem(
                    value: LoadUnits.bodyweight,
                    child: Text(strings.bodyweightLoad),
                  ),
                  DropdownMenuItem(
                    value: LoadUnits.cableStack,
                    child: Text(strings.cableStack),
                  ),
                  DropdownMenuItem(
                    value: LoadUnits.percent1rm,
                    child: Text(strings.percent1rm),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    notifier.updateExerciseLoadUnit(
                      workoutIndex,
                      exerciseIndex,
                      value,
                    );
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 160,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: exercise.equipmentType,
                decoration: InputDecoration(labelText: strings.equipmentType),
                items: [
                  DropdownMenuItem(
                    value: EquipmentTypes.general,
                    child: Text(strings.equipmentGeneral),
                  ),
                  DropdownMenuItem(
                    value: EquipmentTypes.barbell,
                    child: Text(strings.equipmentBarbell),
                  ),
                  DropdownMenuItem(
                    value: EquipmentTypes.dumbbell,
                    child: Text(strings.equipmentDumbbell),
                  ),
                  DropdownMenuItem(
                    value: EquipmentTypes.machine,
                    child: Text(strings.equipmentMachine),
                  ),
                  DropdownMenuItem(
                    value: EquipmentTypes.cable,
                    child: Text(strings.equipmentCable),
                  ),
                  DropdownMenuItem(
                    value: EquipmentTypes.bodyweight,
                    child: Text(strings.equipmentBodyweight),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    notifier.updateExerciseEquipmentType(
                      workoutIndex,
                      exerciseIndex,
                      value,
                    );
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (final entry in visibleStages)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _StageEditorCard(
              workoutIndex: workoutIndex,
              exerciseIndex: exerciseIndex,
              stageIndex: entry.key,
              stage: entry.value,
              stageIds: [for (final stage in exercise.stages) stage.id],
              notifier: notifier,
              strings: strings,
              showRules: showRules,
            ),
          ),
        ExpansionTile(
          key: ValueKey('exercise-advanced-$workoutIndex-$exerciseIndex'),
          tilePadding: EdgeInsets.zero,
          title: Text(
            strings.isChinese ? '动作高级设置' : 'Advanced exercise settings',
          ),
          childrenPadding: const EdgeInsets.only(bottom: 16),
          children: [
            _DraftTextField(
              label: strings.movementId,
              value: exercise.exerciseId,
              onChanged: (value) => notifier.updateExerciseMovementId(
                workoutIndex,
                exerciseIndex,
                value,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: tierOptions.contains(exercise.tier)
                  ? exercise.tier
                  : tierOptions.first,
              decoration: InputDecoration(labelText: strings.tier),
              items: [
                for (final tier in tierOptions)
                  DropdownMenuItem(value: tier, child: Text(tier)),
              ],
              onChanged: (value) {
                if (value != null) {
                  notifier.updateExerciseTier(
                    workoutIndex,
                    exerciseIndex,
                    value,
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              isExpanded: true,
              initialValue: exercise.trainingMaxLift,
              decoration: InputDecoration(
                labelText: strings.trainingMaxMapping,
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(strings.noneOrLater),
                ),
                DropdownMenuItem<String?>(
                  value: 'squat',
                  child: Text(strings.squatShort),
                ),
                DropdownMenuItem<String?>(
                  value: 'bench',
                  child: Text(strings.benchShort),
                ),
                DropdownMenuItem<String?>(
                  value: 'deadlift',
                  child: Text(strings.deadliftShort),
                ),
                DropdownMenuItem<String?>(
                  value: 'overhead_press',
                  child: Text(strings.overheadPressShort),
                ),
              ],
              onChanged: (value) => notifier.updateExerciseTrainingMaxLift(
                workoutIndex,
                exerciseIndex,
                value,
              ),
            ),
          ],
        ),
        if (visibleStageIndex == null)
          Align(
            alignment: Alignment.centerLeft,
            child: FittinBtn(
              refTheme(context),
              strings.addStage,
              variant: 'secondary',
              size: 'sm',
              icon: Icons.add_rounded,
              onPressed: () => notifier.addStage(workoutIndex, exerciseIndex),
            ),
          ),
      ],
    );
    return standalone
        ? content
        : DashboardSurfaceCard(
            radius: 24,
            padding: const EdgeInsets.all(16),
            child: content,
          );
  }
}

class _StageEditorCard extends StatelessWidget {
  const _StageEditorCard({
    required this.workoutIndex,
    required this.exerciseIndex,
    required this.stageIndex,
    required this.stage,
    required this.stageIds,
    required this.notifier,
    required this.strings,
    required this.showRules,
  });

  final int workoutIndex;
  final int exerciseIndex;
  final int stageIndex;
  final SetScheme stage;
  final List<String> stageIds;
  final TemplateEditorNotifier notifier;
  final AppStrings strings;
  final bool showRules;

  @override
  Widget build(BuildContext context) {
    final stageActions = [
      _EditorActionButton(
        controlKey: ValueKey(
          'stage-$workoutIndex-$exerciseIndex-$stageIndex-move-up',
        ),
        onPressed: () =>
            notifier.moveStage(workoutIndex, exerciseIndex, stageIndex, -1),
        label: '${strings.stage} · ${strings.moveUp}',
        icon: Icons.arrow_upward_rounded,
      ),
      _EditorActionButton(
        controlKey: ValueKey(
          'stage-$workoutIndex-$exerciseIndex-$stageIndex-move-down',
        ),
        onPressed: () =>
            notifier.moveStage(workoutIndex, exerciseIndex, stageIndex, 1),
        label: '${strings.stage} · ${strings.moveDown}',
        icon: Icons.arrow_downward_rounded,
      ),
      _EditorActionButton(
        controlKey: ValueKey(
          'stage-$workoutIndex-$exerciseIndex-$stageIndex-duplicate',
        ),
        onPressed: () =>
            notifier.duplicateStage(workoutIndex, exerciseIndex, stageIndex),
        label: '${strings.stage} · ${strings.duplicate}',
        icon: Icons.copy_rounded,
      ),
      _EditorActionButton(
        controlKey: ValueKey(
          'stage-$workoutIndex-$exerciseIndex-$stageIndex-delete',
        ),
        onPressed: () =>
            notifier.removeStage(workoutIndex, exerciseIndex, stageIndex),
        label: '${strings.stage} · ${strings.delete}',
        icon: Icons.delete_outline_rounded,
      ),
    ];
    return DashboardSurfaceCard(
      radius: 20,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final title = Text(
                stage.name,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              );
              if (constraints.maxWidth < 280) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    title,
                    Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(children: stageActions),
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: title),
                  ...stageActions,
                ],
              );
            },
          ),
          _DraftTextField(
            label: strings.stageName,
            value: stage.name,
            onChanged: (value) => notifier.updateStageName(
              workoutIndex,
              exerciseIndex,
              stageIndex,
              value,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            strings.sets,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          for (var setIndex = 0; setIndex < stage.sets.length; setIndex++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SetEditorRow(
                workoutIndex: workoutIndex,
                exerciseIndex: exerciseIndex,
                stageIndex: stageIndex,
                setIndex: setIndex,
                setDefinition: stage.sets[setIndex],
                notifier: notifier,
                strings: strings,
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: FittinBtn(
              refTheme(context),
              strings.addSet,
              variant: 'secondary',
              size: 'sm',
              icon: Icons.add_rounded,
              onPressed: () =>
                  notifier.addSet(workoutIndex, exerciseIndex, stageIndex),
            ),
          ),
          if (showRules) ...[
            const SizedBox(height: 16),
            ExpansionTile(
              key: ValueKey('stage-$stageIndex-progression'),
              title: Text(strings.progression),
              children: [
                _RuleEditor(
                  title: strings.onSuccess,
                  strings: strings,
                  condition: 'on_success',
                  stage: stage,
                  stageIds: stageIds,
                  workoutIndex: workoutIndex,
                  exerciseIndex: exerciseIndex,
                  stageIndex: stageIndex,
                  notifier: notifier,
                ),
                const SizedBox(height: 8),
                _RuleEditor(
                  title: strings.onFailure,
                  strings: strings,
                  condition: 'on_failure',
                  stage: stage,
                  stageIds: stageIds,
                  workoutIndex: workoutIndex,
                  exerciseIndex: exerciseIndex,
                  stageIndex: stageIndex,
                  notifier: notifier,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SetEditorRow extends StatelessWidget {
  const _SetEditorRow({
    required this.workoutIndex,
    required this.exerciseIndex,
    required this.stageIndex,
    required this.setIndex,
    required this.setDefinition,
    required this.notifier,
    required this.strings,
  });

  final int workoutIndex;
  final int exerciseIndex;
  final int stageIndex;
  final int setIndex;
  final SetDefinition setDefinition;
  final TemplateEditorNotifier notifier;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final typeLabel = switch (setDefinition.resolvedSetType) {
      SetTypes.warmupSet => strings.warmup,
      SetTypes.topSet => strings.topSet,
      SetTypes.backoffSet => strings.backoffSet,
      SetTypes.amrapSet => strings.amrapSet,
      _ => strings.straightSet,
    };
    return ExpansionTile(
      key: ValueKey(
        'set-details-$workoutIndex-$exerciseIndex-$stageIndex-$setIndex',
      ),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
      title: Text('${setIndex + 1} · $typeLabel'),
      subtitle: Text(
        '${setDefinition.targetReps} ${strings.isChinese ? '次' : 'reps'}'
        '${setDefinition.targetRpe == null ? '' : ' · RPE ${setDefinition.targetRpe}'}',
      ),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: setDefinition.kind,
                    decoration: InputDecoration(labelText: strings.role),
                    items: [
                      DropdownMenuItem(
                        value: SetKinds.warmup,
                        child: Text(strings.warmup),
                      ),
                      DropdownMenuItem(
                        value: SetKinds.working,
                        child: Text(strings.working),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        notifier.updateSetKind(
                          workoutIndex,
                          exerciseIndex,
                          stageIndex,
                          setIndex,
                          value,
                        );
                        if (value == SetKinds.warmup) {
                          notifier.updateSetType(
                            workoutIndex,
                            exerciseIndex,
                            stageIndex,
                            setIndex,
                            SetTypes.warmupSet,
                          );
                        }
                      }
                    },
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'up':
                        notifier.moveSet(
                          workoutIndex,
                          exerciseIndex,
                          stageIndex,
                          setIndex,
                          -1,
                        );
                        break;
                      case 'down':
                        notifier.moveSet(
                          workoutIndex,
                          exerciseIndex,
                          stageIndex,
                          setIndex,
                          1,
                        );
                        break;
                      case 'duplicate':
                        notifier.duplicateSet(
                          workoutIndex,
                          exerciseIndex,
                          stageIndex,
                          setIndex,
                        );
                        break;
                      case 'delete':
                        notifier.removeSet(
                          workoutIndex,
                          exerciseIndex,
                          stageIndex,
                          setIndex,
                        );
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'up', child: Text(strings.moveUp)),
                    PopupMenuItem(value: 'down', child: Text(strings.moveDown)),
                    PopupMenuItem(
                      value: 'duplicate',
                      child: Text(strings.duplicate),
                    ),
                    PopupMenuItem(value: 'delete', child: Text(strings.delete)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: setDefinition.resolvedSetType,
              decoration: InputDecoration(labelText: strings.setType),
              items: [
                DropdownMenuItem(
                  value: SetTypes.straightSet,
                  child: Text(strings.straightSet),
                ),
                DropdownMenuItem(
                  value: SetTypes.topSet,
                  child: Text(strings.topSet),
                ),
                DropdownMenuItem(
                  value: SetTypes.backoffSet,
                  child: Text(strings.backoffSet),
                ),
                DropdownMenuItem(
                  value: SetTypes.amrapSet,
                  child: Text(strings.amrapSet),
                ),
                DropdownMenuItem(
                  value: SetTypes.warmupSet,
                  child: Text(strings.warmup),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  notifier.updateSetType(
                    workoutIndex,
                    exerciseIndex,
                    stageIndex,
                    setIndex,
                    value,
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: 100,
                  child: _DraftIntField(
                    label: strings.reps,
                    value: setDefinition.targetReps,
                    onChanged: (value) => notifier.updateSetTargetReps(
                      workoutIndex,
                      exerciseIndex,
                      stageIndex,
                      setIndex,
                      value,
                    ),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: _DraftDoubleField(
                    label: strings.intensity,
                    value: setDefinition.intensity,
                    onChanged: (value) => notifier.updateSetIntensity(
                      workoutIndex,
                      exerciseIndex,
                      stageIndex,
                      setIndex,
                      value,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _DraftDoubleField(
              label: strings.targetRpe,
              value: setDefinition.targetRpe ?? 0,
              onChanged: (value) => notifier.updateSetTargetRpe(
                workoutIndex,
                exerciseIndex,
                stageIndex,
                setIndex,
                value <= 0 ? null : value,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RuleEditor extends StatelessWidget {
  const _RuleEditor({
    required this.title,
    required this.strings,
    required this.condition,
    required this.stage,
    required this.stageIds,
    required this.workoutIndex,
    required this.exerciseIndex,
    required this.stageIndex,
    required this.notifier,
  });

  final String title;
  final AppStrings strings;
  final String condition;
  final SetScheme stage;
  final List<String> stageIds;
  final int workoutIndex;
  final int exerciseIndex;
  final int stageIndex;
  final TemplateEditorNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final rule = stage.rules.cast<ProgressionRule?>().firstWhere(
      (rule) => rule?.condition == condition,
      orElse: () => null,
    );
    final actions = rule?.actions ?? const <RuleAction>[];
    return DashboardSurfaceCard(
      radius: 18,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title)),
              IconButton(
                onPressed: () => notifier.addRuleAction(
                  workoutIndex,
                  exerciseIndex,
                  stageIndex,
                  condition,
                ),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          for (var actionIndex = 0; actionIndex < actions.length; actionIndex++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _RuleActionEditorRow(
                action: actions[actionIndex],
                stageIds: stageIds,
                strings: strings,
                onTypeChanged: (value) => notifier.updateRuleActionType(
                  workoutIndex,
                  exerciseIndex,
                  stageIndex,
                  condition,
                  actionIndex,
                  value,
                ),
                onAmountChanged: (value) => notifier.updateRuleActionAmount(
                  workoutIndex,
                  exerciseIndex,
                  stageIndex,
                  condition,
                  actionIndex,
                  value,
                ),
                onMultiplierChanged: (value) =>
                    notifier.updateRuleActionMultiplier(
                      workoutIndex,
                      exerciseIndex,
                      stageIndex,
                      condition,
                      actionIndex,
                      value,
                    ),
                onTargetStageChanged: (value) =>
                    notifier.updateRuleActionTargetStage(
                      workoutIndex,
                      exerciseIndex,
                      stageIndex,
                      condition,
                      actionIndex,
                      value,
                    ),
                onDelete: () => notifier.removeRuleAction(
                  workoutIndex,
                  exerciseIndex,
                  stageIndex,
                  condition,
                  actionIndex,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RuleActionEditorRow extends StatelessWidget {
  const _RuleActionEditorRow({
    required this.action,
    required this.stageIds,
    required this.strings,
    required this.onTypeChanged,
    required this.onAmountChanged,
    required this.onMultiplierChanged,
    required this.onTargetStageChanged,
    required this.onDelete,
  });

  final RuleAction action;
  final List<String> stageIds;
  final AppStrings strings;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<double> onAmountChanged;
  final ValueChanged<double> onMultiplierChanged;
  final ValueChanged<String?> onTargetStageChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final typeField = DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: action.type,
      decoration: InputDecoration(labelText: strings.ruleAction),
      items: [
        DropdownMenuItem(
          value: 'STAY_STAGE',
          child: Text(strings.ruleActionStay),
        ),
        DropdownMenuItem(
          value: 'ADD_WEIGHT',
          child: Text(strings.ruleActionAddWeight),
        ),
        DropdownMenuItem(
          value: 'MULTIPLY_WEIGHT',
          child: Text(strings.ruleActionMultiply),
        ),
        DropdownMenuItem(
          value: 'JUMP_TO_STAGE',
          child: Text(strings.ruleActionJumpStage),
        ),
      ],
      onChanged: (value) {
        if (value != null) onTypeChanged(value);
      },
    );
    final detailField = switch (action.type) {
      'ADD_WEIGHT' => _DraftDoubleField(
        label: strings.amount,
        value: action.amount ?? 2.5,
        onChanged: onAmountChanged,
      ),
      'MULTIPLY_WEIGHT' => _DraftDoubleField(
        label: strings.multiplier,
        value: action.multiplier ?? 0.9,
        onChanged: onMultiplierChanged,
      ),
      'JUMP_TO_STAGE' => DropdownButtonFormField<String>(
        initialValue: action.targetStageId,
        decoration: InputDecoration(labelText: strings.stage),
        items: [
          for (final stageId in stageIds)
            DropdownMenuItem(value: stageId, child: Text(stageId)),
        ],
        onChanged: onTargetStageChanged,
      ),
      _ => null,
    };
    final deleteButton = IconButton(
      onPressed: onDelete,
      tooltip: strings.delete,
      icon: const Icon(Icons.delete_outline_rounded),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final largeText = MediaQuery.textScalerOf(context).scale(14) >= 20;
        final compact = constraints.maxWidth < 340 || largeText;
        if (compact) {
          return Column(
            key: const ValueKey('plan-rule-action-compact'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              typeField,
              const SizedBox(height: 8),
              Row(
                children: [
                  if (detailField != null)
                    Expanded(child: detailField)
                  else
                    const Spacer(),
                  const SizedBox(width: 8),
                  deleteButton,
                ],
              ),
            ],
          );
        }
        return Row(
          key: const ValueKey('plan-rule-action-wide'),
          children: [
            Expanded(flex: 2, child: typeField),
            const SizedBox(width: 8),
            if (detailField != null)
              Expanded(child: detailField)
            else
              const Spacer(),
            deleteButton,
          ],
        );
      },
    );
  }
}

class _EditorCard extends StatelessWidget {
  const _EditorCard({
    required this.title,
    required this.child,
    this.actions,
    this.plain = false,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool plain;

  @override
  Widget build(BuildContext context) {
    final theme = refTheme(context);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty || actions != null)
          Row(
            children: [
              if (title.isEmpty)
                const Spacer()
              else
                Expanded(
                  child: Text(
                    title,
                    style: theme
                        .uiStyle(18, theme.fg)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              if (actions != null) ...actions!,
            ],
          ),
        if (title.isNotEmpty || actions != null) const SizedBox(height: 18),
        child,
      ],
    );
    return plain
        ? content
        : DashboardSurfaceCard(
            radius: 24,
            padding: const EdgeInsets.all(20),
            child: content,
          );
  }
}

class _EditorActionButton extends StatelessWidget {
  const _EditorActionButton({
    required this.controlKey,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final Key controlKey;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      onTap: onPressed,
      excludeSemantics: true,
      child: IconButton(
        key: controlKey,
        tooltip: label,
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = refTheme(context);
    return Semantics(
      label: title,
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: selected ? theme.accentDim : theme.surfaceHi,
            border: Border.all(
              color: selected
                  ? theme.accent.withValues(alpha: 0.8)
                  : theme.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme
                    .uiStyle(15, theme.fg)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: theme.uiStyle(12, theme.fgDim).copyWith(height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final dynamic theme; // FittinTheme

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        excludeFromSemantics: true,
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? theme.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: selected
                ? null
                : Border.all(color: theme.border, width: 0.5),
          ),
          child: Text(
            label,
            style: theme
                .uiStyle(13.0, selected ? theme.accentInk : theme.fgDim)
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _DraftTextField extends StatefulWidget {
  const _DraftTextField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.maxLines = 1,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final int maxLines;

  @override
  State<_DraftTextField> createState() => _DraftTextFieldState();
}

class _DraftTextFieldState extends State<_DraftTextField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _DraftTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      maxLines: widget.maxLines,
      decoration: _inputDecoration(context, widget.label),
      onChanged: widget.onChanged,
    );
  }
}

class _DraftIntField extends StatefulWidget {
  const _DraftIntField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  State<_DraftIntField> createState() => _DraftIntFieldState();
}

class _DraftIntFieldState extends State<_DraftIntField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _DraftIntField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextText = widget.value.toString();
    if (!_focusNode.hasFocus && _controller.text != nextText) {
      _controller.text = nextText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.number,
      decoration: _inputDecoration(context, widget.label),
      onChanged: (value) => widget.onChanged(int.tryParse(value) ?? 0),
    );
  }
}

class _DraftDoubleField extends StatefulWidget {
  const _DraftDoubleField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  State<_DraftDoubleField> createState() => _DraftDoubleFieldState();
}

class _DraftDoubleFieldState extends State<_DraftDoubleField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _DraftDoubleField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextText = widget.value.toString();
    if (!_focusNode.hasFocus && _controller.text != nextText) {
      _controller.text = nextText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: _inputDecoration(context, widget.label),
      onChanged: (value) => widget.onChanged(double.tryParse(value) ?? 0),
    );
  }
}

FittinTheme refTheme(BuildContext context) =>
    ProviderScope.containerOf(context).read(resolvedFittinThemeProvider);

InputDecoration _inputDecoration(BuildContext context, String label) {
  final theme = refTheme(context);
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: theme.surfaceHi,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: theme.border, width: 0.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: theme.border, width: 0.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: theme.accent.withValues(alpha: 0.8)),
    ),
  );
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      radius: 28,
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _ValidationBanner extends StatelessWidget {
  const _ValidationBanner({
    required this.errors,
    required this.strings,
    required this.onSelect,
  });

  final List<String> errors;
  final AppStrings strings;
  final void Function(int) onSelect;

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      radius: 28,
      highlight: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.validation,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < errors.length; i++)
            TextButton(
              key: ValueKey('plan-validation-$i'),
              onPressed: () => onSelect(i),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(strings.templateValidationError(errors[i])),
              ),
            ),
        ],
      ),
    );
  }
}
