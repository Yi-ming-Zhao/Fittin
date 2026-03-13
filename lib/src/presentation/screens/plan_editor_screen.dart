import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/template_editor_provider.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/presentation/screens/share_screen.dart';

class PlanEditorScreen extends ConsumerStatefulWidget {
  const PlanEditorScreen({super.key, this.templateId});

  final String? templateId;

  @override
  ConsumerState<PlanEditorScreen> createState() => _PlanEditorScreenState();
}

class _PlanEditorScreenState extends ConsumerState<PlanEditorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(templateEditorProvider.notifier);
      if (widget.templateId == null) {
        notifier.createBlankTemplate();
      } else {
        notifier.loadTemplate(widget.templateId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(templateEditorProvider);
    final notifier = ref.read(templateEditorProvider.notifier);
    final draft = state.draft;

    if (state.isLoading || draft == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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

    return Scaffold(
      appBar: AppBar(
        title: Text(draft.name),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ShareScreen(planTemplate: draft),
                ),
              );
            },
            icon: const Icon(Icons.qr_code_2_rounded),
            tooltip: 'Share plan',
          ),
          TextButton.icon(
            onPressed: state.isSaving
                ? null
                : () async {
                    await notifier.saveTemplate();
                  },
            icon: state.isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          if (state.sourceTemplate != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _InfoBanner(
                message: state.sourceTemplate!.isBuiltIn
                    ? 'Built-in templates save as a new custom copy.'
                    : state.sourceTemplate!.instanceCount > 0
                    ? 'Templates with active instances save as a new copy to protect existing progress.'
                    : 'You are editing a custom template in place.',
              ),
            ),
          if (state.validationErrors.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ValidationBanner(errors: state.validationErrors),
            ),
          _EditorCard(
            title: 'Template',
            child: Column(
              children: [
                _DraftTextField(
                  label: 'Template Name',
                  value: draft.name,
                  onChanged: notifier.updateTemplateName,
                ),
                const SizedBox(height: 12),
                _DraftTextField(
                  label: 'Description',
                  value: draft.description,
                  maxLines: 3,
                  onChanged: notifier.updateTemplateDescription,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (
            var workoutIndex = 0;
            workoutIndex < draft.workouts.length;
            workoutIndex++
          )
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _WorkoutEditorCard(
                workout: draft.workouts[workoutIndex],
                workoutIndex: workoutIndex,
                notifier: notifier,
              ),
            ),
          OutlinedButton.icon(
            onPressed: notifier.addWorkout,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Workout'),
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
  });

  final Workout workout;
  final int workoutIndex;
  final TemplateEditorNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return _EditorCard(
      title: '${workout.dayLabel} · ${workout.name}',
      actions: [
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
          _DraftTextField(
            label: 'Workout Name',
            value: workout.name,
            onChanged: (value) =>
                notifier.updateWorkoutName(workoutIndex, value),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DraftTextField(
                  label: 'Day Label',
                  value: workout.dayLabel,
                  onChanged: (value) =>
                      notifier.updateWorkoutDayLabel(workoutIndex, value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DraftIntField(
                  label: 'Minutes',
                  value: workout.estimatedDurationMinutes,
                  onChanged: (value) =>
                      notifier.updateWorkoutDuration(workoutIndex, value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (
            var exerciseIndex = 0;
            exerciseIndex < workout.exercises.length;
            exerciseIndex++
          )
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ExerciseEditorCard(
                workoutIndex: workoutIndex,
                exerciseIndex: exerciseIndex,
                exercise: workout.exercises[exerciseIndex],
                notifier: notifier,
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => notifier.addExercise(workoutIndex),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Exercise'),
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
  });

  final int workoutIndex;
  final int exerciseIndex;
  final Exercise exercise;
  final TemplateEditorNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final tierOptions = const ['T1', 'T2', 'T3'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
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
                onPressed: () =>
                    notifier.moveExercise(workoutIndex, exerciseIndex, -1),
                icon: const Icon(Icons.arrow_upward_rounded),
              ),
              IconButton(
                onPressed: () =>
                    notifier.moveExercise(workoutIndex, exerciseIndex, 1),
                icon: const Icon(Icons.arrow_downward_rounded),
              ),
              IconButton(
                onPressed: () =>
                    notifier.duplicateExercise(workoutIndex, exerciseIndex),
                icon: const Icon(Icons.copy_rounded),
              ),
              IconButton(
                onPressed: () =>
                    notifier.removeExercise(workoutIndex, exerciseIndex),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          _DraftTextField(
            label: 'Exercise Name',
            value: exercise.name,
            onChanged: (value) =>
                notifier.updateExerciseName(workoutIndex, exerciseIndex, value),
          ),
          const SizedBox(height: 12),
          _DraftTextField(
            label: 'Movement Id',
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
                  value: tierOptions.contains(exercise.tier)
                      ? exercise.tier
                      : tierOptions.first,
                  decoration: const InputDecoration(labelText: 'Tier'),
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
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DraftIntField(
                  label: 'Rest (sec)',
                  value: exercise.restSeconds,
                  onChanged: (value) => notifier.updateExerciseRestSeconds(
                    workoutIndex,
                    exerciseIndex,
                    value,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DraftDoubleField(
                  label: 'Start Weight',
                  value: exercise.initialBaseWeight,
                  onChanged: (value) => notifier.updateExerciseBaseWeight(
                    workoutIndex,
                    exerciseIndex,
                    value,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (
            var stageIndex = 0;
            stageIndex < exercise.stages.length;
            stageIndex++
          )
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _StageEditorCard(
                workoutIndex: workoutIndex,
                exerciseIndex: exerciseIndex,
                stageIndex: stageIndex,
                stage: exercise.stages[stageIndex],
                stageIds: [for (final stage in exercise.stages) stage.id],
                notifier: notifier,
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => notifier.addStage(workoutIndex, exerciseIndex),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Stage'),
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
  });

  final int workoutIndex;
  final int exerciseIndex;
  final int stageIndex;
  final SetScheme stage;
  final List<String> stageIds;
  final TemplateEditorNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  stage.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                onPressed: () => notifier.moveStage(
                  workoutIndex,
                  exerciseIndex,
                  stageIndex,
                  -1,
                ),
                icon: const Icon(Icons.arrow_upward_rounded),
              ),
              IconButton(
                onPressed: () => notifier.moveStage(
                  workoutIndex,
                  exerciseIndex,
                  stageIndex,
                  1,
                ),
                icon: const Icon(Icons.arrow_downward_rounded),
              ),
              IconButton(
                onPressed: () => notifier.duplicateStage(
                  workoutIndex,
                  exerciseIndex,
                  stageIndex,
                ),
                icon: const Icon(Icons.copy_rounded),
              ),
              IconButton(
                onPressed: () => notifier.removeStage(
                  workoutIndex,
                  exerciseIndex,
                  stageIndex,
                ),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          _DraftTextField(
            label: 'Stage Name',
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
            'Sets',
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
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () =>
                  notifier.addSet(workoutIndex, exerciseIndex, stageIndex),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Set'),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Progression',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _RuleEditor(
            title: 'On Success',
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
            title: 'On Failure',
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
  });

  final int workoutIndex;
  final int exerciseIndex;
  final int stageIndex;
  final int setIndex;
  final SetDefinition setDefinition;
  final TemplateEditorNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: setDefinition.kind,
            decoration: const InputDecoration(labelText: 'Role'),
            items: const [
              DropdownMenuItem(value: 'warmup', child: Text('Warmup')),
              DropdownMenuItem(value: 'working', child: Text('Working')),
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
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _DraftIntField(
            label: 'Reps',
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
            label: 'Intensity',
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
        const SizedBox(width: 8),
        Column(
          children: [
            const Text('AMRAP'),
            Switch(
              value: setDefinition.isAmrap,
              onChanged: (value) => notifier.updateSetAmrap(
                workoutIndex,
                exerciseIndex,
                stageIndex,
                setIndex,
                value,
              ),
            ),
          ],
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
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'up', child: Text('Move up')),
            PopupMenuItem(value: 'down', child: Text('Move down')),
            PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ],
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
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
                onRemove: () => notifier.removeRuleAction(
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
    required this.onRemove,
  });

  final RuleAction action;
  final List<String> stageIds;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<double> onAmountChanged;
  final ValueChanged<double> onMultiplierChanged;
  final ValueChanged<String?> onTargetStageChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: action.type,
            decoration: const InputDecoration(labelText: 'Action'),
            items: const [
              DropdownMenuItem(value: 'STAY_STAGE', child: Text('Stay Stage')),
              DropdownMenuItem(value: 'ADD_WEIGHT', child: Text('Add Weight')),
              DropdownMenuItem(
                value: 'MULTIPLY_WEIGHT',
                child: Text('Multiply Weight'),
              ),
              DropdownMenuItem(
                value: 'JUMP_TO_STAGE',
                child: Text('Jump Stage'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                onTypeChanged(value);
              }
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
              value: stageIds.contains(action.targetStageId)
                  ? action.targetStageId
                  : null,
              decoration: const InputDecoration(labelText: 'Target Stage'),
              items: [
                for (final stageId in stageIds)
                  DropdownMenuItem(value: stageId, child: Text(stageId)),
              ],
              onChanged: onTargetStageChanged,
            ),
          )
        else
          const Spacer(),
        IconButton(onPressed: onRemove, icon: const Icon(Icons.close_rounded)),
      ],
    );
  }
}

class _EditorCard extends StatelessWidget {
  const _EditorCard({
    required this.title,
    required this.child,
    this.actions = const [],
  });

  final String title;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.onSurface.withOpacity(0.04),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ...actions,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 10),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).colorScheme.errorContainer,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cannot save yet',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          for (final error in errors.take(5))
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $error'),
            ),
        ],
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
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );

  @override
  void didUpdateWidget(covariant _DraftTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      maxLines: widget.maxLines,
      decoration: InputDecoration(labelText: widget.label),
      onChanged: widget.onChanged,
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
    return _DraftTextField(
      label: label,
      value: value.toString(),
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
    return _DraftTextField(
      label: label,
      value: value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2),
      onChanged: (value) => onChanged(double.tryParse(value) ?? 0),
    );
  }
}
