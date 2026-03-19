import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/local/local_plan_repository.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/template_validation.dart';

final templateLibraryProvider = FutureProvider<List<StoredTemplateRecord>>((
  ref,
) async {
  final repository = ref.watch(localPlanRepositoryProvider);
  await repository.ensureDefaultProgramSeeded();
  return repository.fetchTemplates();
});

final templateEditorProvider =
    StateNotifierProvider<TemplateEditorNotifier, TemplateEditorState>((ref) {
      return TemplateEditorNotifier(ref);
    });

class TemplateEditorState {
  TemplateEditorState({
    this.isLoading = false,
    this.isSaving = false,
    this.sourceTemplate,
    this.draft,
    this.validationErrors = const [],
    this.errorMessage,
    this.infoMessage,
  });

  final bool isLoading;
  final bool isSaving;
  final StoredTemplateRecord? sourceTemplate;
  final PlanTemplate? draft;
  final List<String> validationErrors;
  final String? errorMessage;
  final String? infoMessage;

  TemplateEditorState copyWith({
    bool? isLoading,
    bool? isSaving,
    StoredTemplateRecord? sourceTemplate,
    PlanTemplate? draft,
    List<String>? validationErrors,
    String? errorMessage,
    String? infoMessage,
    bool clearError = false,
    bool clearInfo = false,
  }) {
    return TemplateEditorState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      sourceTemplate: sourceTemplate ?? this.sourceTemplate,
      draft: draft ?? this.draft,
      validationErrors: validationErrors ?? this.validationErrors,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      infoMessage: clearInfo ? null : infoMessage ?? this.infoMessage,
    );
  }
}

class TemplateEditorNotifier extends StateNotifier<TemplateEditorState> {
  TemplateEditorNotifier(this._ref) : super(TemplateEditorState());

  final Ref _ref;

  DatabaseRepository get _repository => _ref.read(databaseRepositoryProvider);
  LocalPlanRepository get _localPlanRepository =>
      _ref.read(localPlanRepositoryProvider);

  Future<void> loadTemplate(String templateId) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearInfo: true,
      validationErrors: const [],
    );

    try {
      await _repository.ensureDefaultProgramSeeded();
      final record = await _localPlanRepository.fetchStoredTemplate(templateId);
      if (record == null) {
        throw StateError('Template not found: $templateId');
      }
      final normalizedTemplate = _normalizeTemplateForEditing(record.template);
      state = TemplateEditorState(
        sourceTemplate: record,
        draft: normalizedTemplate,
        validationErrors: TemplateValidation.validate(
          normalizedTemplate,
        ).errors,
      );
    } catch (error) {
      state = TemplateEditorState(errorMessage: error.toString());
    }
  }

  void createBlankTemplate() {
    final template = _blankTemplate();
    state = TemplateEditorState(
      draft: template,
      validationErrors: TemplateValidation.validate(template).errors,
    );
  }

  void updateTemplateName(String value) {
    _updateDraft((draft) => draft.copyWith(name: value));
  }

  void updateTemplateDescription(String value) {
    _updateDraft((draft) => draft.copyWith(description: value));
  }

  void updateScheduleMode(String value) {
    _updateDraft((draft) => draft.copyWith(scheduleMode: value));
  }

  void addWorkout() {
    _updateDraft(
      (draft) =>
          _copyWithWorkouts(draft, [..._workoutsOf(draft), _newWorkout()]),
    );
  }

  void duplicateWorkout(int workoutIndex) {
    _updateDraft((draft) {
      final workouts = [..._workoutsOf(draft)];
      final source = workouts[workoutIndex];
      workouts.insert(workoutIndex + 1, _duplicateWorkout(source));
      return _copyWithWorkouts(draft, workouts);
    });
  }

  void removeWorkout(int workoutIndex) {
    _updateDraft((draft) {
      final workouts = [..._workoutsOf(draft)]..removeAt(workoutIndex);
      return _copyWithWorkouts(draft, workouts);
    });
  }

  void moveWorkout(int workoutIndex, int offset) {
    _updateDraft((draft) {
      final workouts = [..._workoutsOf(draft)];
      final targetIndex = workoutIndex + offset;
      if (targetIndex < 0 || targetIndex >= workouts.length) {
        return draft;
      }
      final workout = workouts.removeAt(workoutIndex);
      workouts.insert(targetIndex, workout);
      return _copyWithWorkouts(draft, workouts);
    });
  }

  void updateWorkoutName(int workoutIndex, String value) {
    _updateWorkout(workoutIndex, (workout) => workout.copyWith(name: value));
  }

  void updateWorkoutDayLabel(int workoutIndex, String value) {
    _updateWorkout(
      workoutIndex,
      (workout) => workout.copyWith(dayLabel: value),
    );
  }

  void updateWorkoutDuration(int workoutIndex, int value) {
    _updateWorkout(
      workoutIndex,
      (workout) =>
          workout.copyWith(estimatedDurationMinutes: value < 1 ? 1 : value),
    );
  }

  void addExercise(int workoutIndex) {
    _updateWorkout(
      workoutIndex,
      (workout) =>
          workout.copyWith(exercises: [...workout.exercises, _newExercise()]),
    );
  }

  void duplicateExercise(int workoutIndex, int exerciseIndex) {
    _updateWorkout(workoutIndex, (workout) {
      final exercises = [...workout.exercises];
      exercises.insert(
        exerciseIndex + 1,
        _duplicateExercise(exercises[exerciseIndex]),
      );
      return workout.copyWith(exercises: exercises);
    });
  }

  void removeExercise(int workoutIndex, int exerciseIndex) {
    _updateWorkout(workoutIndex, (workout) {
      final exercises = [...workout.exercises]..removeAt(exerciseIndex);
      return workout.copyWith(exercises: exercises);
    });
  }

  void moveExercise(int workoutIndex, int exerciseIndex, int offset) {
    _updateWorkout(workoutIndex, (workout) {
      final exercises = [...workout.exercises];
      final targetIndex = exerciseIndex + offset;
      if (targetIndex < 0 || targetIndex >= exercises.length) {
        return workout;
      }
      final exercise = exercises.removeAt(exerciseIndex);
      exercises.insert(targetIndex, exercise);
      return workout.copyWith(exercises: exercises);
    });
  }

  void updateExerciseName(int workoutIndex, int exerciseIndex, String value) {
    _updateExercise(
      workoutIndex,
      exerciseIndex,
      (exercise) => exercise.copyWith(name: value),
    );
  }

  void updateExerciseMovementId(
    int workoutIndex,
    int exerciseIndex,
    String value,
  ) {
    _updateExercise(
      workoutIndex,
      exerciseIndex,
      (exercise) => exercise.copyWith(exerciseId: value),
    );
  }

  void updateExerciseTier(int workoutIndex, int exerciseIndex, String value) {
    _updateExercise(
      workoutIndex,
      exerciseIndex,
      (exercise) => exercise.copyWith(tier: value),
    );
  }

  void updateExerciseRestSeconds(
    int workoutIndex,
    int exerciseIndex,
    int value,
  ) {
    _updateExercise(
      workoutIndex,
      exerciseIndex,
      (exercise) => exercise.copyWith(restSeconds: value < 0 ? 0 : value),
    );
  }

  void updateExerciseBaseWeight(
    int workoutIndex,
    int exerciseIndex,
    double value,
  ) {
    _updateExercise(
      workoutIndex,
      exerciseIndex,
      (exercise) => exercise.copyWith(initialBaseWeight: value < 0 ? 0 : value),
    );
  }

  void updateExerciseLoadUnit(
    int workoutIndex,
    int exerciseIndex,
    String value,
  ) {
    _updateExercise(
      workoutIndex,
      exerciseIndex,
      (exercise) => exercise.copyWith(loadUnit: value),
    );
  }

  void addStage(int workoutIndex, int exerciseIndex) {
    _updateExercise(workoutIndex, exerciseIndex, (exercise) {
      return exercise.copyWith(stages: [...exercise.stages, _newStage()]);
    });
  }

  void duplicateStage(int workoutIndex, int exerciseIndex, int stageIndex) {
    _updateExercise(workoutIndex, exerciseIndex, (exercise) {
      final stages = [...exercise.stages];
      stages.insert(stageIndex + 1, _duplicateStage(stages[stageIndex]));
      return exercise.copyWith(stages: stages);
    });
  }

  void removeStage(int workoutIndex, int exerciseIndex, int stageIndex) {
    _updateExercise(workoutIndex, exerciseIndex, (exercise) {
      final stages = [...exercise.stages]..removeAt(stageIndex);
      return exercise.copyWith(stages: stages);
    });
  }

  void moveStage(
    int workoutIndex,
    int exerciseIndex,
    int stageIndex,
    int offset,
  ) {
    _updateExercise(workoutIndex, exerciseIndex, (exercise) {
      final stages = [...exercise.stages];
      final targetIndex = stageIndex + offset;
      if (targetIndex < 0 || targetIndex >= stages.length) {
        return exercise;
      }
      final stage = stages.removeAt(stageIndex);
      stages.insert(targetIndex, stage);
      return exercise.copyWith(stages: stages);
    });
  }

  void updateStageName(
    int workoutIndex,
    int exerciseIndex,
    int stageIndex,
    String value,
  ) {
    _updateStage(
      workoutIndex,
      exerciseIndex,
      stageIndex,
      (stage) => stage.copyWith(name: value),
    );
  }

  void addSet(int workoutIndex, int exerciseIndex, int stageIndex) {
    _updateStage(workoutIndex, exerciseIndex, stageIndex, (stage) {
      return stage.copyWith(sets: [...stage.sets, _newSetDefinition()]);
    });
  }

  void duplicateSet(
    int workoutIndex,
    int exerciseIndex,
    int stageIndex,
    int setIndex,
  ) {
    _updateStage(workoutIndex, exerciseIndex, stageIndex, (stage) {
      final sets = [...stage.sets];
      sets.insert(setIndex + 1, sets[setIndex]);
      return stage.copyWith(sets: sets);
    });
  }

  void removeSet(
    int workoutIndex,
    int exerciseIndex,
    int stageIndex,
    int setIndex,
  ) {
    _updateStage(workoutIndex, exerciseIndex, stageIndex, (stage) {
      final sets = [...stage.sets]..removeAt(setIndex);
      return stage.copyWith(sets: sets);
    });
  }

  void moveSet(
    int workoutIndex,
    int exerciseIndex,
    int stageIndex,
    int setIndex,
    int offset,
  ) {
    _updateStage(workoutIndex, exerciseIndex, stageIndex, (stage) {
      final sets = [...stage.sets];
      final targetIndex = setIndex + offset;
      if (targetIndex < 0 || targetIndex >= sets.length) {
        return stage;
      }
      final set = sets.removeAt(setIndex);
      sets.insert(targetIndex, set);
      return stage.copyWith(sets: sets);
    });
  }

  void updateSetTargetReps(
    int workoutIndex,
    int exerciseIndex,
    int stageIndex,
    int setIndex,
    int value,
  ) {
    _updateSet(
      workoutIndex,
      exerciseIndex,
      stageIndex,
      setIndex,
      (set) => set.copyWith(targetReps: value < 1 ? 1 : value),
    );
  }

  void updateSetIntensity(
    int workoutIndex,
    int exerciseIndex,
    int stageIndex,
    int setIndex,
    double value,
  ) {
    _updateSet(
      workoutIndex,
      exerciseIndex,
      stageIndex,
      setIndex,
      (set) => set.copyWith(intensity: value <= 0 ? 0.1 : value),
    );
  }

  void updateSetKind(
    int workoutIndex,
    int exerciseIndex,
    int stageIndex,
    int setIndex,
    String value,
  ) {
    _updateSet(
      workoutIndex,
      exerciseIndex,
      stageIndex,
      setIndex,
      (set) => set.copyWith(kind: value),
    );
  }

  void updateSetAmrap(
    int workoutIndex,
    int exerciseIndex,
    int stageIndex,
    int setIndex,
    bool value,
  ) {
    _updateSet(
      workoutIndex,
      exerciseIndex,
      stageIndex,
      setIndex,
      (set) => set.copyWith(isAmrap: value),
    );
  }

  void updateSetType(
    int workoutIndex,
    int exerciseIndex,
    int stageIndex,
    int setIndex,
    String value,
  ) {
    _updateSet(
      workoutIndex,
      exerciseIndex,
      stageIndex,
      setIndex,
      (set) => set.copyWith(
        setType: value,
        isAmrap: value == SetTypes.amrapSet,
        kind: value == SetTypes.warmupSet ? SetKinds.warmup : SetKinds.working,
      ),
    );
  }

  void addRuleAction(
    int workoutIndex,
    int exerciseIndex,
    int stageIndex,
    String condition,
  ) {
    _updateRule(workoutIndex, exerciseIndex, stageIndex, condition, (rule) {
      return rule.copyWith(
        actions: [
          ...rule.actions,
          const RuleAction(type: 'STAY_STAGE'),
        ],
      );
    });
  }

  void removeRuleAction(
    int workoutIndex,
    int exerciseIndex,
    int stageIndex,
    String condition,
    int actionIndex,
  ) {
    _updateRule(workoutIndex, exerciseIndex, stageIndex, condition, (rule) {
      final actions = [...rule.actions]..removeAt(actionIndex);
      return rule.copyWith(actions: actions);
    });
  }

  void updateRuleActionType(
    int workoutIndex,
    int exerciseIndex,
    int stageIndex,
    String condition,
    int actionIndex,
    String value,
  ) {
    _updateRuleAction(
      workoutIndex,
      exerciseIndex,
      stageIndex,
      condition,
      actionIndex,
      (action) => action.copyWith(
        type: value,
        amount: value == 'ADD_WEIGHT' ? (action.amount ?? 2.5) : null,
        multiplier: value == 'MULTIPLY_WEIGHT'
            ? (action.multiplier ?? 0.9)
            : null,
        targetStageId: value == 'JUMP_TO_STAGE' ? action.targetStageId : null,
      ),
    );
  }

  void updateRuleActionAmount(
    int workoutIndex,
    int exerciseIndex,
    int stageIndex,
    String condition,
    int actionIndex,
    double value,
  ) {
    _updateRuleAction(
      workoutIndex,
      exerciseIndex,
      stageIndex,
      condition,
      actionIndex,
      (action) => action.copyWith(amount: value),
    );
  }

  void updateRuleActionMultiplier(
    int workoutIndex,
    int exerciseIndex,
    int stageIndex,
    String condition,
    int actionIndex,
    double value,
  ) {
    _updateRuleAction(
      workoutIndex,
      exerciseIndex,
      stageIndex,
      condition,
      actionIndex,
      (action) => action.copyWith(multiplier: value),
    );
  }

  void updateRuleActionTargetStage(
    int workoutIndex,
    int exerciseIndex,
    int stageIndex,
    String condition,
    int actionIndex,
    String? value,
  ) {
    _updateRuleAction(
      workoutIndex,
      exerciseIndex,
      stageIndex,
      condition,
      actionIndex,
      (action) => action.copyWith(targetStageId: value),
    );
  }

  Future<StoredTemplateRecord?> saveTemplate() async {
    final draft = state.draft;
    if (draft == null) {
      return null;
    }

    final validation = TemplateValidation.validate(draft);
    if (!validation.isValid) {
      state = state.copyWith(
        validationErrors: validation.errors,
        errorMessage: validation.errors.first,
      );
      return null;
    }

    state = state.copyWith(isSaving: true, clearError: true, clearInfo: true);

    try {
      final record = await _localPlanRepository.saveEditedTemplate(
        draft: draft,
        originalTemplateId: state.sourceTemplate?.template.id,
      );
      _ref.invalidate(templateLibraryProvider);
      state = TemplateEditorState(
        sourceTemplate: record,
        draft: record.template,
        validationErrors: const [],
        infoMessage: record.template.id == state.sourceTemplate?.template.id
            ? 'Template updated.'
            : 'Saved as a new template copy.',
      );
      return record;
    } catch (error) {
      state = state.copyWith(isSaving: false, errorMessage: error.toString());
      return null;
    }
  }

  void dismissMessages() {
    state = state.copyWith(clearError: true, clearInfo: true);
  }

  void _updateDraft(PlanTemplate Function(PlanTemplate draft) transform) {
    final draft = state.draft;
    if (draft == null) {
      return;
    }
    final updated = transform(draft);
    state = state.copyWith(
      draft: updated,
      validationErrors: TemplateValidation.validate(updated).errors,
      clearError: true,
      clearInfo: true,
    );
  }

  void _updateWorkout(int workoutIndex, Workout Function(Workout) transform) {
    _updateDraft((draft) {
      final workouts = [..._workoutsOf(draft)];
      workouts[workoutIndex] = transform(workouts[workoutIndex]);
      return _copyWithWorkouts(draft, workouts);
    });
  }

  void _updateExercise(
    int workoutIndex,
    int exerciseIndex,
    Exercise Function(Exercise) transform,
  ) {
    _updateWorkout(workoutIndex, (workout) {
      final exercises = [...workout.exercises];
      exercises[exerciseIndex] = transform(exercises[exerciseIndex]);
      return workout.copyWith(exercises: exercises);
    });
  }

  void _updateStage(
    int workoutIndex,
    int exerciseIndex,
    int stageIndex,
    SetScheme Function(SetScheme) transform,
  ) {
    _updateExercise(workoutIndex, exerciseIndex, (exercise) {
      final stages = [...exercise.stages];
      stages[stageIndex] = transform(stages[stageIndex]);
      return exercise.copyWith(stages: stages);
    });
  }

  void _updateSet(
    int workoutIndex,
    int exerciseIndex,
    int stageIndex,
    int setIndex,
    SetDefinition Function(SetDefinition) transform,
  ) {
    _updateStage(workoutIndex, exerciseIndex, stageIndex, (stage) {
      final sets = [...stage.sets];
      sets[setIndex] = transform(sets[setIndex]);
      return stage.copyWith(sets: sets);
    });
  }

  void _updateRule(
    int workoutIndex,
    int exerciseIndex,
    int stageIndex,
    String condition,
    ProgressionRule Function(ProgressionRule rule) transform,
  ) {
    _updateStage(workoutIndex, exerciseIndex, stageIndex, (stage) {
      final rules = [...stage.rules];
      final ruleIndex = rules.indexWhere((rule) => rule.condition == condition);
      if (ruleIndex == -1) {
        rules.add(
          transform(ProgressionRule(condition: condition, actions: const [])),
        );
      } else {
        rules[ruleIndex] = transform(rules[ruleIndex]);
      }
      return stage.copyWith(rules: rules);
    });
  }

  void _updateRuleAction(
    int workoutIndex,
    int exerciseIndex,
    int stageIndex,
    String condition,
    int actionIndex,
    RuleAction Function(RuleAction action) transform,
  ) {
    _updateRule(workoutIndex, exerciseIndex, stageIndex, condition, (rule) {
      final actions = [...rule.actions];
      if (actionIndex < 0 || actionIndex >= actions.length) {
        return rule;
      }
      actions[actionIndex] = transform(actions[actionIndex]);
      return rule.copyWith(actions: actions);
    });
  }

  List<Workout> _workoutsOf(PlanTemplate template) {
    if (template.phases.isEmpty) {
      return const [];
    }
    return template.phases.first.workouts;
  }

  PlanTemplate _copyWithWorkouts(
    PlanTemplate template,
    List<Workout> workouts,
  ) {
    final phases = template.phases.isEmpty
        ? [Phase(id: _newId('phase'), name: 'Main Phase', workouts: workouts)]
        : [
            template.phases.first.copyWith(workouts: workouts),
            ...template.phases.skip(1),
          ];
    return template.copyWith(phases: phases);
  }

  PlanTemplate _blankTemplate() {
    return PlanTemplate(
      id: _newId('template'),
      name: 'Custom Plan',
      description: 'Editable training plan',
      scheduleMode: PlanScheduleModes.linear,
      phases: [
        Phase(
          id: _newId('phase'),
          name: 'Main Phase',
          workouts: [_newWorkout()],
        ),
      ],
    );
  }

  PlanTemplate _normalizeTemplateForEditing(PlanTemplate template) {
    return template.copyWith(
      scheduleMode: template.resolvedScheduleMode,
      phases: [
        for (final phase in template.phases)
          phase.copyWith(
            workouts: [
              for (final workout in phase.workouts)
                workout.copyWith(
                  exercises: [
                    for (final exercise in workout.exercises)
                      exercise.copyWith(
                        loadUnit:
                            LoadUnits.supported.contains(exercise.loadUnit)
                            ? exercise.loadUnit
                            : LoadUnits.kg,
                        stages: [
                          for (final stage in exercise.stages)
                            stage.copyWith(
                              sets: [
                                for (final set in stage.sets)
                                  set.copyWith(
                                    setType: set.resolvedSetType,
                                    kind:
                                        set.resolvedSetType ==
                                            SetTypes.warmupSet
                                        ? SetKinds.warmup
                                        : SetKinds.working,
                                    isAmrap:
                                        set.resolvedSetType ==
                                        SetTypes.amrapSet,
                                  ),
                              ],
                            ),
                        ],
                      ),
                  ],
                ),
            ],
          ),
      ],
    );
  }

  Workout _newWorkout() {
    return Workout(
      id: _newId('workout'),
      name: 'New Workout',
      dayLabel: 'Day 1',
      estimatedDurationMinutes: 45,
      exercises: [_newExercise()],
    );
  }

  Workout _duplicateWorkout(Workout workout) {
    return workout.copyWith(
      id: _newId('workout'),
      name: '${workout.name} Copy',
      exercises: [
        for (final exercise in workout.exercises) _duplicateExercise(exercise),
      ],
    );
  }

  Exercise _newExercise() {
    return Exercise(
      id: _newId('exercise'),
      exerciseId: 'custom_exercise',
      name: 'New Exercise',
      initialBaseWeight: 20,
      tier: 'T2',
      restSeconds: 120,
      loadUnit: LoadUnits.kg,
      stages: [_newStage()],
    );
  }

  Exercise _duplicateExercise(Exercise exercise) {
    return exercise.copyWith(
      id: _newId('exercise'),
      name: '${exercise.name} Copy',
      stages: [for (final stage in exercise.stages) _duplicateStage(stage)],
    );
  }

  SetScheme _newStage() {
    return SetScheme(
      id: _newId('stage'),
      name: '3x10',
      sets: [
        _newSetDefinition(kind: 'warmup', intensity: 0.6),
        _newSetDefinition(kind: 'working'),
      ],
      rules: [
        const ProgressionRule(
          condition: 'on_success',
          actions: [RuleAction(type: 'STAY_STAGE')],
        ),
        const ProgressionRule(
          condition: 'on_failure',
          actions: [RuleAction(type: 'STAY_STAGE')],
        ),
      ],
    );
  }

  SetScheme _duplicateStage(SetScheme stage) {
    return stage.copyWith(id: _newId('stage'), name: '${stage.name} Copy');
  }

  SetDefinition _newSetDefinition({
    String kind = SetKinds.working,
    String? setType,
    double intensity = 1,
  }) {
    return SetDefinition(
      targetReps: kind == SetKinds.warmup ? 5 : 10,
      intensity: intensity,
      kind: kind,
      setType:
          setType ??
          (kind == SetKinds.warmup ? SetTypes.warmupSet : SetTypes.straightSet),
      isAmrap: setType == SetTypes.amrapSet,
    );
  }

  String _newId(String prefix) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
  }
}
