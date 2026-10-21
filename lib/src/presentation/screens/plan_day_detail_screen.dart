import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/app_locale_provider.dart';
import '../../application/exercise_library_provider.dart';
import '../../application/fittin_theme_provider.dart';
import '../../application/plan_library_provider.dart';
import '../../data/database_repository.dart';
import '../../data/seeds/seed_utils.dart';
import '../../domain/models/training_plan.dart';
import '../../domain/models/training_max.dart';
import '../../domain/models/training_state.dart';
import '../../domain/program_engine.dart';
import '../localization/app_strings.dart';
import '../localization/plan_text.dart';
import '../widgets/dashboard_primitives.dart';
import '../widgets/fittin_primitives.dart';

String _setTypeLabel(String type, AppStrings strings) => switch (type) {
  SetTypes.topSet => strings.topSet,
  SetTypes.backoffSet => strings.backoffSet,
  SetTypes.amrapSet => strings.amrapSet,
  SetTypes.warmupSet => strings.warmup,
  _ => strings.straightSet,
};

/// Read-only: constructing a preview never activates or advances an instance.
class PlanDayDetailScreen extends ConsumerStatefulWidget {
  const PlanDayDetailScreen({
    super.key,
    required this.template,
    required this.workout,
  });
  final PlanTemplate template;
  final Workout workout;
  @override
  ConsumerState<PlanDayDetailScreen> createState() => _PlanDayDetailState();
}

class _PlanDayDetailState extends ConsumerState<PlanDayDetailScreen> {
  int _week = 0;

  @override
  Widget build(BuildContext context) {
    final template = widget.template;
    final workout = widget.workout;
    final theme = ref.watch(resolvedFittinThemeProvider);
    final locale = ref.watch(appLocaleProvider);
    final strings = AppStrings.of(context, ref);
    final library = ref.watch(exerciseLibraryProvider).valueOrNull;
    final instanceState = ref.watch(planInstanceProvider(template.id));
    final stored = instanceState.valueOrNull;
    final starter = buildStarterStatesForTemplate(template);
    final states = <String, TrainingState>{
      for (final state in starter) state.exerciseId: state,
      for (final state in stored?.states ?? <TrainingState>[])
        state.exerciseId: state,
    };
    final weeks = workout.exercises.fold(
      1,
      (int count, exercise) =>
          exercise.stages.length > count ? exercise.stages.length : count,
    );
    if (template.isPeriodized) {
      for (final exercise in workout.exercises) {
        states[exercise.id] = states[exercise.id]!.copyWith(
          currentStageId:
              exercise.stages[_week.clamp(0, exercise.stages.length - 1)].id,
        );
      }
    }
    final originalInstance =
        stored ??
        StoredTrainingInstance(
          instanceId: 'preview',
          templateId: template.id,
          currentWorkoutIndex: 0,
          states: states.values.toList(),
        );
    // Missing TM values are placeholders for engine resolution only; the UI
    // below renders the rule, never these placeholder weights.
    final instance = originalInstance.copyWith(
      trainingMaxProfile: TrainingMaxProfile({
        for (final exercise in workout.exercises)
          if (exercise.trainingMaxLift != null) exercise.trainingMaxLift!: 0,
        ...originalInstance.trainingMaxProfile.values,
      }),
    );
    final session = ProgramEngineDispatcher.resolve(template.engineFamily)
        .buildSession(
          template: template,
          instance: instance,
          workout: workout,
          stateByExerciseId: states,
        );
    return DashboardPageScaffold(
      layout: DashboardPageLayout.detail,
      children: [
        DashboardScreenHeader(
          title: localizedWorkoutName(workout, locale),
          showBackButton: true,
        ),
        const SizedBox(height: 20),
        if (instanceState.isLoading) const LinearProgressIndicator(),
        if (instanceState.hasError)
          Text(
            strings.isChinese
                ? '无法读取当前进度，以下仅展示计划规则。'
                : 'Current progress is unavailable. Showing plan rules only.',
          ),
        if (template.isPeriodized) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < weeks; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FittinChip(
                      theme,
                      strings.isChinese ? '第 ${i + 1} 周' : 'Week ${i + 1}',
                      active: i == _week,
                      onTap: () => setState(() => _week = i),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        for (var i = 0; i < workout.exercises.length; i++) ...[
          Builder(
            builder: (_) {
              final exercise = workout.exercises[i];
              final resolved = session.exercises[i];
              final stage = exercise.stageById(resolved.stageId);
              final hasLoad =
                  exercise.loadUnit == LoadUnits.bodyweight ||
                  (template.isPeriodized && exercise.trainingMaxLift != null
                      ? stored?.trainingMaxProfile.values.containsKey(
                              exercise.trainingMaxLift,
                            ) ==
                            true
                      : states[exercise.id]!.baseWeight > 0);
              final localizedNotes = exercise.engineConfig['localizedNotes'];
              final note = localizedNotes is Map
                  ? localizedNotes[locale.code] ??
                        exercise.engineConfig['notes']
                  : exercise.engineConfig['notes'];
              final usesTm =
                  template.isPeriodized && exercise.trainingMaxLift != null;
              return DashboardSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizedExerciseName(exercise, locale, library: library),
                      style: theme.uiStyle(18, theme.fg, FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      strings.isChinese
                          ? '组间休息 ${resolved.restSeconds} 秒'
                          : '${resolved.restSeconds}s rest',
                      style: theme.uiStyle(13, theme.fgDim),
                    ),
                    const SizedBox(height: 12),
                    for (var s = 0; s < resolved.sets.length; s++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 28,
                              child: Text(
                                '${s + 1}',
                                style: theme.numStyle(15, theme.fgMuted),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${resolved.sets[s].isAmrap ? (strings.isChinese ? '力竭' : 'AMRAP') : '${resolved.sets[s].targetReps} ${strings.isChinese ? '次' : 'reps'}'} · '
                                '${exercise.loadUnit == LoadUnits.bodyweight
                                    ? (strings.isChinese ? '自重' : 'Bodyweight')
                                    : hasLoad
                                    ? '${resolved.sets[s].targetWeight} ${resolved.displayLoadUnit}'
                                    : '${(resolveSetIntensity(stage.sets[s]) * (usesTm ? stage.basePercent * exercise.trainingMaxMultiplier : 1) * 100).toStringAsFixed(0)}% ${usesTm ? 'TM' : (strings.isChinese ? '基础重量' : 'base load')}'}'
                                '${resolved.sets[s].targetRpe == null ? '' : ' · RPE ${resolved.sets[s].targetRpe}'}'
                                ' · ${_setTypeLabel(stage.sets[s].resolvedSetType, strings)}',
                                style: theme.uiStyle(14, theme.fg),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (note is String && note.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(note, style: theme.uiStyle(13, theme.fgDim)),
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
