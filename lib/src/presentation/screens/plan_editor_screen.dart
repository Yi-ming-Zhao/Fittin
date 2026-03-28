import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/template_editor_provider.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/screens/share_screen.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';

class PlanEditorScreen extends ConsumerStatefulWidget {
  const PlanEditorScreen({super.key, this.templateId});

  final String? templateId;

  @override
  ConsumerState<PlanEditorScreen> createState() => _PlanEditorScreenState();
}

class _PlanEditorScreenState extends ConsumerState<PlanEditorScreen> {
  int _selectedWorkoutIndex = 0;
  int _selectedPeriodizedWeek = 0;

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
    final draft = state.draft;

    if (state.isLoading || draft == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    _showPendingSnackbars(state, notifier);

    final workouts = draft.workouts;
    if (_selectedWorkoutIndex >= workouts.length) {
      _selectedWorkoutIndex = workouts.isEmpty ? 0 : workouts.length - 1;
    }

    final isPeriodized = draft.isPeriodized;
    final visibleWorkout = workouts[_selectedWorkoutIndex];
    final availableWeeks = _weekCountForWorkout(visibleWorkout);
    if (_selectedPeriodizedWeek >= availableWeeks) {
      _selectedPeriodizedWeek = 0;
    }

    return DashboardPageScaffold(
      bottomPadding: 140,
      children: [
        DashboardScreenHeader(
          eyebrow: strings.templateEditor,
          title: draft.name,
          showBackButton: true,
          subtitle: draft.isPeriodized
              ? (strings.isChinese
                    ? '按周/天槽位精细修改周期计划，不再一次看完整个周期。'
                    : 'Edit periodized plans by week/day slot instead of scrolling the whole cycle.')
              : (strings.isChinese
                    ? '线性计划按可复用训练日整体编辑。'
                    : 'Linear plans are edited as reusable workout structures.'),
          trailing: _HeaderActions(
            strings: strings,
            isSaving: state.isSaving,
            onShare: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ShareScreen(planTemplate: draft)),
              );
            },
            onSave: () async => notifier.saveTemplate(),
          ),
        ),
        const SizedBox(height: 20),
        if (state.sourceTemplate != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _InfoBanner(
              message: state.sourceTemplate!.isBuiltIn
                  ? (strings.isChinese
                        ? '内置模板会另存为新的自定义副本。'
                        : 'Built-in templates save as a new custom copy.')
                  : state.sourceTemplate!.instanceCount > 0
                  ? (strings.isChinese
                        ? '已有进行中实例的模板会另存为新副本，避免覆盖现有进度。'
                        : 'Templates with active instances save as a new copy to protect existing progress.')
                  : (strings.isChinese
                        ? '你正在直接编辑自定义模板。'
                        : 'You are editing a custom template in place.'),
            ),
          ),
        if (state.validationErrors.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ValidationBanner(errors: state.validationErrors),
          ),
        _TemplateMetaCard(
          draft: draft,
          notifier: notifier,
          strings: strings,
        ),
        const SizedBox(height: 16),
        _ModeSelectorCard(
          scheduleMode: draft.resolvedScheduleMode,
          notifier: notifier,
          strings: strings,
        ),
        const SizedBox(height: 16),
        if (isPeriodized) ...[
          _PeriodizedSlotCard(
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
          _WorkoutEditorCard(
            workout: visibleWorkout,
            workoutIndex: _selectedWorkoutIndex,
            notifier: notifier,
            strings: strings,
            periodizedWeekIndex: _selectedPeriodizedWeek,
            showWorkoutMetadataEditor: true,
            allowPeriodizedSlotFocus: true,
            periodizedSlotLabel:
                'W${_selectedPeriodizedWeek + 1}D${_selectedWorkoutIndex + 1}',
          ),
        ] else ...[
          for (var workoutIndex = 0; workoutIndex < workouts.length; workoutIndex++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _WorkoutEditorCard(
                workout: workouts[workoutIndex],
                workoutIndex: workoutIndex,
                notifier: notifier,
                strings: strings,
                showWorkoutMetadataEditor: true,
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: notifier.addWorkout,
              icon: const Icon(Icons.add_rounded),
              label: Text(strings.addWorkout),
            ),
          ),
        ],
      ],
    );
  }

  void _showPendingSnackbars(
    TemplateEditorState state,
    TemplateEditorNotifier notifier,
  ) {
    if (state.infoMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.infoMessage!)));
        notifier.dismissMessages();
      });
    } else if (state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
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
    required this.strings,
    required this.isSaving,
    required this.onShare,
    required this.onSave,
  });

  final AppStrings strings;
  final bool isSaving;
  final VoidCallback onShare;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onShare,
          icon: const Icon(Icons.qr_code_2_rounded),
          tooltip: strings.share,
        ),
        TextButton.icon(
          onPressed: isSaving ? null : () => onSave(),
          icon: isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined),
          label: Text(strings.save),
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
      title: strings.templateEditor,
      child: Column(
        children: [
          _DraftTextField(
            label: strings.templateName,
            value: draft.name,
            onChanged: notifier.updateTemplateName,
          ),
          const SizedBox(height: 12),
          _DraftTextField(
            label: strings.isChinese ? '描述' : 'Description',
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
      child: Row(
        children: [
          Expanded(
            child: _ModeTile(
              selected: scheduleMode == PlanScheduleModes.linear,
              title: strings.linearPlan,
              subtitle: strings.isChinese ? '整套训练日复用' : 'Reusable workout structure',
              onTap: () => notifier.updateScheduleMode(PlanScheduleModes.linear),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ModeTile(
              selected: scheduleMode == PlanScheduleModes.periodized,
              title: strings.periodizedPlan,
              subtitle: strings.isChinese ? '按周/天槽位编辑' : 'Edit by week/day slots',
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
    required this.strings,
    required this.workouts,
    required this.selectedWorkoutIndex,
    required this.selectedWeekIndex,
    required this.onWorkoutSelected,
    required this.onWeekSelected,
  });

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
        (innerMax, exercise) =>
            exercise.stages.length > innerMax ? exercise.stages.length : innerMax,
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
                  label: 'D${i + 1}',
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
                  label: 'W${i + 1}',
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
  });

  final Workout workout;
  final int workoutIndex;
  final TemplateEditorNotifier notifier;
  final AppStrings strings;
  final int? periodizedWeekIndex;
  final bool showWorkoutMetadataEditor;
  final bool allowPeriodizedSlotFocus;
  final String? periodizedSlotLabel;

  @override
  Widget build(BuildContext context) {
    final title = periodizedSlotLabel == null
        ? '${workout.dayLabel} · ${workout.name}'
        : '$periodizedSlotLabel · ${workout.name}';

    return _EditorCard(
      title: title,
      actions: allowPeriodizedSlotFocus
          ? null
          : [
              IconButton(
                onPressed: () => notifier.moveWorkout(workoutIndex, -1),
                icon: const Icon(Icons.arrow_upward_rounded),
              ),
              IconButton(
                onPressed: () => notifier.moveWorkout(workoutIndex, 1),
                icon: const Icon(Icons.arrow_downward_rounded),
              ),
              IconButton(
                onPressed: () => notifier.duplicateWorkout(workoutIndex),
                icon: const Icon(Icons.copy_rounded),
              ),
              IconButton(
                onPressed: () => notifier.removeWorkout(workoutIndex),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
      child: Column(
        children: [
          if (showWorkoutMetadataEditor) ...[
            _DraftTextField(
              label: strings.workoutName,
              value: workout.name,
              onChanged: (value) => notifier.updateWorkoutName(workoutIndex, value),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DraftTextField(
                    label: strings.dayLabel,
                    value: workout.dayLabel,
                    onChanged: (value) =>
                        notifier.updateWorkoutDayLabel(workoutIndex, value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
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
          for (var exerciseIndex = 0; exerciseIndex < workout.exercises.length; exerciseIndex++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ExerciseEditorCard(
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
            child: OutlinedButton.icon(
              onPressed: () => notifier.addExercise(workoutIndex),
              icon: const Icon(Icons.add_rounded),
              label: Text(strings.addExercise),
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
  });

  final int workoutIndex;
  final int exerciseIndex;
  final Exercise exercise;
  final TemplateEditorNotifier notifier;
  final AppStrings strings;
  final int? visibleStageIndex;
  final bool showRules;

  @override
  Widget build(BuildContext context) {
    final tierOptions = const ['T1', 'T2', 'T3'];
    final visibleStages = visibleStageIndex == null
        ? exercise.stages.asMap().entries.toList()
        : [
            if (visibleStageIndex! < exercise.stages.length)
              MapEntry(visibleStageIndex!, exercise.stages[visibleStageIndex!]),
          ];

    return DashboardSurfaceCard(
      radius: 24,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  exercise.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => notifier.moveExercise(workoutIndex, exerciseIndex, -1),
                icon: const Icon(Icons.arrow_upward_rounded),
              ),
              IconButton(
                onPressed: () => notifier.moveExercise(workoutIndex, exerciseIndex, 1),
                icon: const Icon(Icons.arrow_downward_rounded),
              ),
              IconButton(
                onPressed: () =>
                    notifier.duplicateExercise(workoutIndex, exerciseIndex),
                icon: const Icon(Icons.copy_rounded),
              ),
              IconButton(
                onPressed: () => notifier.removeExercise(workoutIndex, exerciseIndex),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          _DraftTextField(
            label: strings.isChinese ? '动作名称' : 'Exercise Name',
            value: exercise.name,
            onChanged: (value) =>
                notifier.updateExerciseName(workoutIndex, exerciseIndex, value),
          ),
          const SizedBox(height: 12),
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
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
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
                      notifier.updateExerciseTier(workoutIndex, exerciseIndex, value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DraftIntField(
                  label: strings.restSeconds,
                  value: exercise.restSeconds,
                  onChanged: (value) =>
                      notifier.updateExerciseRestSeconds(workoutIndex, exerciseIndex, value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DraftDoubleField(
                  label: strings.startWeight,
                  value: exercise.initialBaseWeight,
                  onChanged: (value) =>
                      notifier.updateExerciseBaseWeight(workoutIndex, exerciseIndex, value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: exercise.loadUnit,
                  decoration: InputDecoration(labelText: strings.loadUnit),
                  items: [
                    DropdownMenuItem(value: LoadUnits.kg, child: const Text('kg')),
                    DropdownMenuItem(value: LoadUnits.lbs, child: const Text('lbs')),
                    DropdownMenuItem(
                      value: LoadUnits.bodyweight,
                      child: Text(strings.isChinese ? '自身体重' : 'Bodyweight'),
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
                      notifier.updateExerciseLoadUnit(workoutIndex, exerciseIndex, value);
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
          if (visibleStageIndex == null)
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () => notifier.addStage(workoutIndex, exerciseIndex),
                icon: const Icon(Icons.add_rounded),
                label: Text(strings.addStage),
              ),
            ),
        ],
      ),
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
    return DashboardSurfaceCard(
      radius: 20,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  stage.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => notifier.moveStage(workoutIndex, exerciseIndex, stageIndex, -1),
                icon: const Icon(Icons.arrow_upward_rounded),
              ),
              IconButton(
                onPressed: () => notifier.moveStage(workoutIndex, exerciseIndex, stageIndex, 1),
                icon: const Icon(Icons.arrow_downward_rounded),
              ),
              IconButton(
                onPressed: () => notifier.duplicateStage(workoutIndex, exerciseIndex, stageIndex),
                icon: const Icon(Icons.copy_rounded),
              ),
              IconButton(
                onPressed: () => notifier.removeStage(workoutIndex, exerciseIndex, stageIndex),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          _DraftTextField(
            label: strings.stageName,
            value: stage.name,
            onChanged: (value) =>
                notifier.updateStageName(workoutIndex, exerciseIndex, stageIndex, value),
          ),
          const SizedBox(height: 12),
          Text(
            strings.sets,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
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
            child: OutlinedButton.icon(
              onPressed: () => notifier.addSet(workoutIndex, exerciseIndex, stageIndex),
              icon: const Icon(Icons.add_rounded),
              label: Text(strings.addSet),
            ),
          ),
          if (showRules) ...[
            const SizedBox(height: 16),
            Text(
              strings.progression,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _RuleEditor(
              title: strings.onSuccess,
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
              condition: 'on_failure',
              stage: stage,
              stageIds: stageIds,
              workoutIndex: workoutIndex,
              exerciseIndex: exerciseIndex,
              stageIndex: stageIndex,
              notifier: notifier,
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
    return DashboardSurfaceCard(
      radius: 18,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: setDefinition.kind,
                  decoration: InputDecoration(labelText: strings.role),
                  items: [
                    DropdownMenuItem(value: SetKinds.warmup, child: Text(strings.warmup)),
                    DropdownMenuItem(value: SetKinds.working, child: Text(strings.working)),
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
                      notifier.moveSet(workoutIndex, exerciseIndex, stageIndex, setIndex, -1);
                      break;
                    case 'down':
                      notifier.moveSet(workoutIndex, exerciseIndex, stageIndex, setIndex, 1);
                      break;
                    case 'duplicate':
                      notifier.duplicateSet(workoutIndex, exerciseIndex, stageIndex, setIndex);
                      break;
                    case 'delete':
                      notifier.removeSet(workoutIndex, exerciseIndex, stageIndex, setIndex);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'up',
                    child: Text(strings.isChinese ? '上移' : 'Move up'),
                  ),
                  PopupMenuItem(
                    value: 'down',
                    child: Text(strings.isChinese ? '下移' : 'Move down'),
                  ),
                  PopupMenuItem(
                    value: 'duplicate',
                    child: Text(strings.isChinese ? '复制' : 'Duplicate'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(strings.isChinese ? '删除' : 'Delete'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
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
          Row(
            children: [
              Expanded(
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
              const SizedBox(width: 8),
              Expanded(
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
        ],
      ),
    );
  }
}

class _RuleEditor extends StatelessWidget {
  const _RuleEditor({
    required this.title,
    required this.condition,
    required this.stage,
    required this.stageIds,
    required this.workoutIndex,
    required this.exerciseIndex,
    required this.stageIndex,
    required this.notifier,
  });

  final String title;
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
                onPressed: () =>
                    notifier.addRuleAction(workoutIndex, exerciseIndex, stageIndex, condition),
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
    required this.onTypeChanged,
    required this.onAmountChanged,
    required this.onMultiplierChanged,
    required this.onTargetStageChanged,
    required this.onDelete,
  });

  final RuleAction action;
  final List<String> stageIds;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<double> onAmountChanged;
  final ValueChanged<double> onMultiplierChanged;
  final ValueChanged<String?> onTargetStageChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            initialValue: action.type,
            decoration: const InputDecoration(labelText: 'Action'),
            items: const [
              DropdownMenuItem(value: 'STAY_STAGE', child: Text('Stay')),
              DropdownMenuItem(value: 'ADD_WEIGHT', child: Text('Add Weight')),
              DropdownMenuItem(value: 'MULTIPLY_WEIGHT', child: Text('Multiply')),
              DropdownMenuItem(value: 'JUMP_TO_STAGE', child: Text('Jump Stage')),
            ],
            onChanged: (value) {
              if (value != null) onTypeChanged(value);
            },
          ),
        ),
        const SizedBox(width: 8),
        if (action.type == 'ADD_WEIGHT')
          Expanded(
            child: _DraftDoubleField(
              label: 'Amount',
              value: action.amount ?? 2.5,
              onChanged: onAmountChanged,
            ),
          )
        else if (action.type == 'MULTIPLY_WEIGHT')
          Expanded(
            child: _DraftDoubleField(
              label: 'Multiplier',
              value: action.multiplier ?? 0.9,
              onChanged: onMultiplierChanged,
            ),
          )
        else if (action.type == 'JUMP_TO_STAGE')
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: action.targetStageId,
              decoration: const InputDecoration(labelText: 'Stage'),
              items: [
                for (final stageId in stageIds)
                  DropdownMenuItem(value: stageId, child: Text(stageId)),
              ],
              onChanged: onTargetStageChanged,
            ),
          )
        else
          const Spacer(),
        IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline_rounded)),
      ],
    );
  }
}

class _EditorCard extends StatelessWidget {
  const _EditorCard({
    required this.title,
    required this.child,
    this.actions,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      radius: 32,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (actions != null) ...actions!,
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
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
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.04),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.08),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.18),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.66),
              ),
            ),
          ],
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
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: selected ? theme.colorScheme.primary : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _DraftTextField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: value);
    controller.selection = TextSelection.collapsed(offset: controller.text.length);
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
      onChanged: onChanged,
    );
  }
}

class _DraftIntField extends StatelessWidget {
  const _DraftIntField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: value.toString());
    controller.selection = TextSelection.collapsed(offset: controller.text.length);
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      onChanged: (value) => onChanged(int.tryParse(value) ?? 0),
    );
  }
}

class _DraftDoubleField extends StatelessWidget {
  const _DraftDoubleField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: value.toString());
    controller.selection = TextSelection.collapsed(offset: controller.text.length);
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
      onChanged: (value) => onChanged(double.tryParse(value) ?? 0),
    );
  }
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
  const _ValidationBanner({required this.errors});

  final List<String> errors;

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      radius: 28,
      highlight: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Validation',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          for (final error in errors.take(6))
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('• $error'),
            ),
        ],
      ),
    );
  }
}
