import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/exercise_library_provider.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/application/sync_provider.dart';
import 'package:fittin_v2/src/application/sync_refresh_provider.dart';
import 'package:fittin_v2/src/application/services/today_workout_gateway.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';
import 'package:fittin_v2/src/domain/weight_tools.dart';

final databaseRepositoryProvider = Provider<DatabaseRepository>((ref) {
  throw UnimplementedError(
    'databaseRepositoryProvider must be overridden in ProviderScope.',
  );
});

final todayWorkoutGatewayProvider = Provider<TodayWorkoutGateway>((ref) {
  final repository = ref.watch(databaseRepositoryProvider);
  final ownerUserId = ref.watch(currentUserIdProvider);
  return DatabaseTodayWorkoutGateway(
    repository,
    ownerUserId: ownerUserId,
    exerciseLibraryLoader: () => ref.read(exerciseLibraryProvider.future),
  );
});

final todayWorkoutSummaryProvider = FutureProvider<TodayWorkoutSummary>((
  ref,
) async {
  ref.watch(syncRefreshProvider);
  final gateway = ref.watch(todayWorkoutGatewayProvider);
  return gateway.loadTodayWorkoutSummary();
});

final activeTemplateProvider = FutureProvider<PlanTemplate>((ref) async {
  ref.watch(syncRefreshProvider);
  final gateway = ref.watch(todayWorkoutGatewayProvider);
  return gateway.loadActiveTemplate();
});

final activeSessionProvider =
    StateNotifierProvider<ActiveSessionNotifier, SessionState>((ref) {
      ref.watch(currentUserIdProvider);
      return ActiveSessionNotifier(ref);
    });

class SessionState {
  SessionState({this.isLoading = false, this.activeWorkout, this.errorMessage});

  final bool isLoading;
  final WorkoutSessionState? activeWorkout;
  final String? errorMessage;

  SessionState copyWith({
    bool? isLoading,
    WorkoutSessionState? activeWorkout,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SessionState(
      isLoading: isLoading ?? this.isLoading,
      activeWorkout: activeWorkout ?? this.activeWorkout,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class ActiveSessionNotifier extends StateNotifier<SessionState> {
  ActiveSessionNotifier(this._ref) : super(SessionState()) {
    _restoreInFlight = _restorePersistedSession(background: true);
  }

  final Ref _ref;
  Future<void>? _restoreInFlight;
  Future<void>? _startInFlight;
  Future<bool>? _conclusionInFlight;
  Future<void> _draftWriteTail = Future<void>.value();
  bool _draftWritesOpen = true;
  bool _restoreFailed = false;

  Future<void> startOrResumeSession() {
    final existing = _startInFlight;
    if (existing != null) {
      return existing;
    }
    late final Future<void> operation;
    operation = _startOrResumeSession().whenComplete(() {
      if (identical(_startInFlight, operation)) {
        _startInFlight = null;
      }
    });
    _startInFlight = operation;
    return operation;
  }

  Future<void> _startOrResumeSession() async {
    await _restoreInFlight;
    var previousWorkout = state.activeWorkout;

    try {
      if (_restoreFailed && previousWorkout == null) {
        await _restorePersistedSession(background: false);
        previousWorkout = state.activeWorkout;
      }
      state = state.copyWith(isLoading: true, clearError: true);
      final scheduledSession = await _ref
          .read(todayWorkoutGatewayProvider)
          .loadTodayWorkoutSession();
      if (previousWorkout != null &&
          workoutSessionMatchesSchedule(previousWorkout, scheduledSession)) {
        final resumedWorkout = previousWorkout.scheduleToken.isEmpty
            ? previousWorkout.copyWith(
                scheduleToken: scheduledSession.scheduleToken,
              )
            : previousWorkout;
        state = SessionState(activeWorkout: resumedWorkout);
        if (!identical(resumedWorkout, previousWorkout)) {
          _queueDraftSave(resumedWorkout);
        }
        return;
      }

      if (previousWorkout != null &&
          previousWorkout.instanceId == scheduledSession.instanceId) {
        await _discardDraft(previousWorkout.instanceId);
      }
      _draftWritesOpen = true;
      _setActiveWorkout(scheduledSession, preserveLoading: false);
    } catch (error) {
      state = SessionState(
        activeWorkout: previousWorkout,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> _restorePersistedSession({required bool background}) async {
    if (state.activeWorkout != null) {
      _restoreFailed = false;
      return;
    }
    if (!background) {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      final session = await _loadPersistedSession();
      _restoreFailed = false;
      if (session == null || !mounted) {
        if (!background) {
          state = state.copyWith(isLoading: false);
        }
        return;
      }
      state = SessionState(activeWorkout: session);
    } catch (error) {
      _restoreFailed = true;
      if (!mounted || background) {
        return;
      }
      state = SessionState(errorMessage: error.toString());
      rethrow;
    }
  }

  Future<WorkoutSessionState?> _loadPersistedSession() async {
    final repository = _ref.read(databaseRepositoryProvider);
    final ownerUserId = _ref.read(currentUserIdProvider);
    final activeInstance = await repository.fetchActiveInstanceForUser(
      ownerUserId,
    );
    if (activeInstance == null) {
      return null;
    }

    final persistedDraft = await repository.fetchActiveSessionDraft(
      activeInstance.instanceId,
      ownerUserId: ownerUserId,
    );
    if (persistedDraft == null) {
      return null;
    }
    final scheduledSession = await _ref
        .read(todayWorkoutGatewayProvider)
        .loadTodayWorkoutSession();
    if (workoutSessionMatchesSchedule(persistedDraft, scheduledSession)) {
      if (persistedDraft.scheduleToken.isEmpty) {
        final upgradedDraft = persistedDraft.copyWith(
          scheduleToken: scheduledSession.scheduleToken,
        );
        _queueDraftSave(upgradedDraft);
        return upgradedDraft;
      }
      return persistedDraft;
    }

    await repository.clearActiveSessionDraft(
      activeInstance.instanceId,
      ownerUserId: ownerUserId,
    );
    return null;
  }

  void selectExercise(int index) {
    final workout = state.activeWorkout;
    if (!_acceptsMutations ||
        workout == null ||
        index < 0 ||
        index >= workout.exercises.length) {
      return;
    }

    _setActiveWorkout(
      workout.copyWith(
        currentExerciseIndex: index,
        exercises: [
          for (
            var exerciseIndex = 0;
            exerciseIndex < workout.exercises.length;
            exerciseIndex++
          )
            exerciseIndex == index
                ? _withResolvedCurrentSet(workout.exercises[exerciseIndex])
                : workout.exercises[exerciseIndex],
        ],
      ),
      preserveLoading: false,
    );
  }

  void selectSet(int setIndex) {
    if (!_acceptsMutations) {
      return;
    }
    _updateCurrentExercise(
      (exercise) => exercise.copyWith(
        currentSetIndex: _clampSetIndex(setIndex, exercise.sets.length),
      ),
    );
  }

  void updateReps(int setIndex, int newReps) {
    _updateCurrentExerciseSet(
      setIndex,
      (set) => set.copyWith(
        completedReps: newReps < 0 ? 0 : (newReps > 99 ? 99 : newReps),
      ),
    );
  }

  void updateWeight(int setIndex, double newWeight) {
    final workout = state.activeWorkout;
    if (!_acceptsMutations || workout == null) {
      return;
    }

    final exerciseIndex = workout.currentExerciseIndex;
    final currentExercise = workout.exercises[exerciseIndex];
    if (setIndex < 0 || setIndex >= currentExercise.sets.length) {
      return;
    }

    final resolvedWeight = newWeight < 0 ? 0.0 : newWeight;
    final updatedSets = [
      for (var index = 0; index < currentExercise.sets.length; index++)
        if (index == setIndex ||
            (index > setIndex && !_isResolved(currentExercise.sets[index])))
          currentExercise.sets[index].copyWith(weight: resolvedWeight)
        else
          currentExercise.sets[index],
    ];
    final updatedExercises = [...workout.exercises];
    updatedExercises[exerciseIndex] = currentExercise.copyWith(
      sets: updatedSets,
    );
    _setActiveWorkout(
      workout.copyWith(exercises: updatedExercises),
      preserveLoading: false,
    );
  }

  void updateWeightFromDisplayUnit(
    int setIndex,
    double displayWeight, {
    required String displayUnit,
  }) {
    final canonicalWeight = convertWeight(
      displayWeight,
      displayUnit,
      LoadUnits.kg,
    );
    updateWeight(setIndex, canonicalWeight);
  }

  void updateCompletedRpe(int setIndex, double? newRpe) {
    _updateCurrentExerciseSet(
      setIndex,
      (set) => set.copyWith(completedRpe: _normalizeRpe(newRpe)),
    );
  }

  void switchExerciseDisplayUnit(String unit) {
    if (!LoadUnits.supported.contains(unit)) {
      return;
    }
    _updateCurrentExercise(
      (exercise) => exercise.copyWith(displayLoadUnit: unit),
    );
  }

  void completeSet(int setIndex) {
    _resolveSet(setIndex, completed: true);
  }

  void cancelSet(int setIndex) {
    _resolveSet(setIndex, completed: false);
  }

  void _resolveSet(int setIndex, {required bool completed}) {
    final workout = state.activeWorkout;
    if (!_acceptsMutations || workout == null) {
      return;
    }

    final exerciseIndex = workout.currentExerciseIndex;
    final currentExercise = workout.exercises[exerciseIndex];
    if (setIndex < 0 || setIndex >= currentExercise.sets.length) {
      return;
    }

    final updatedSets = [...currentExercise.sets];
    updatedSets[setIndex] = updatedSets[setIndex].copyWith(
      isCompleted: completed,
      isSkipped: !completed,
    );

    var nextExerciseIndex = exerciseIndex;
    var nextCurrentSetIndex = setIndex;
    final nextSetIndex = updatedSets.indexWhere((set) => !_isResolved(set));
    if (nextSetIndex == -1) {
      for (var i = exerciseIndex + 1; i < workout.exercises.length; i++) {
        final candidate = workout.exercises[i];
        if (candidate.sets.any((set) => !_isResolved(set))) {
          nextExerciseIndex = i;
          nextCurrentSetIndex = candidate.currentSetIndex;
          break;
        }
      }
    } else {
      nextCurrentSetIndex = nextSetIndex;
    }

    final updatedExercises = [...workout.exercises];
    updatedExercises[exerciseIndex] = currentExercise.copyWith(
      sets: updatedSets,
      currentSetIndex: nextSetIndex == -1
          ? currentExercise.currentSetIndex
          : nextSetIndex,
    );
    if (nextExerciseIndex != exerciseIndex) {
      updatedExercises[nextExerciseIndex] = _withResolvedCurrentSet(
        updatedExercises[nextExerciseIndex],
      ).copyWith(currentSetIndex: nextCurrentSetIndex);
    }

    _setActiveWorkout(
      workout.copyWith(
        exercises: updatedExercises,
        currentExerciseIndex: nextExerciseIndex,
      ),
      preserveLoading: false,
    );
  }

  void toggleSetComplete(int setIndex) {
    _updateCurrentExerciseSet(
      setIndex,
      (set) => set.copyWith(isCompleted: !set.isCompleted, isSkipped: false),
    );
  }

  Future<bool> concludeSession() {
    final existing = _conclusionInFlight;
    if (existing != null) {
      return existing;
    }
    late final Future<bool> operation;
    operation = _concludeSession().whenComplete(() {
      if (identical(_conclusionInFlight, operation)) {
        _conclusionInFlight = null;
      }
    });
    _conclusionInFlight = operation;
    return operation;
  }

  Future<bool> _concludeSession() async {
    final workout = state.activeWorkout;
    if (workout == null) {
      return false;
    }

    _draftWritesOpen = false;
    state = state.copyWith(isLoading: true, clearError: true);
    var progressionCommitted = false;

    try {
      await _draftWriteTail;
      await _ref
          .read(todayWorkoutGatewayProvider)
          .concludeWorkoutSession(workout);
      progressionCommitted = true;
      final ownerUserId = _ref.read(currentUserIdProvider);
      await _ref
          .read(databaseRepositoryProvider)
          .clearActiveSessionDraft(
            workout.instanceId,
            ownerUserId: ownerUserId,
          );
      state = SessionState();
      _ref.invalidate(todayWorkoutSummaryProvider);
      _ref.invalidate(progressAnalyticsOverviewProvider);
      if (ownerUserId != null) {
        unawaited(
          _ref.read(syncControllerProvider.notifier).synchronizeWithRecovery(),
        );
      }
      return true;
    } catch (error) {
      if (progressionCommitted) {
        state = SessionState(errorMessage: error.toString());
        _ref.invalidate(todayWorkoutSummaryProvider);
      } else {
        _draftWritesOpen = true;
        state = SessionState(
          activeWorkout: workout,
          errorMessage: error.toString(),
        );
        _queueDraftSave(workout);
      }
      return false;
    }
  }

  void dismissError() {
    state = state.copyWith(clearError: true);
  }

  void _updateCurrentExerciseSet(
    int setIndex,
    SessionSetState Function(SessionSetState current) update,
  ) {
    final workout = state.activeWorkout;
    if (!_acceptsMutations || workout == null) {
      return;
    }

    final exerciseIndex = workout.currentExerciseIndex;
    final currentExercise = workout.exercises[exerciseIndex];
    if (setIndex < 0 || setIndex >= currentExercise.sets.length) {
      return;
    }

    final updatedSets = [...currentExercise.sets];
    updatedSets[setIndex] = update(updatedSets[setIndex]);

    final updatedExercises = [...workout.exercises];
    updatedExercises[exerciseIndex] = currentExercise.copyWith(
      sets: updatedSets,
    );

    _setActiveWorkout(
      workout.copyWith(exercises: updatedExercises),
      preserveLoading: false,
    );
  }

  void _updateCurrentExercise(
    ExerciseSessionState Function(ExerciseSessionState exercise) update,
  ) {
    final workout = state.activeWorkout;
    if (!_acceptsMutations || workout == null) {
      return;
    }
    final exerciseIndex = workout.currentExerciseIndex;
    final updatedExercises = [...workout.exercises];
    updatedExercises[exerciseIndex] = update(updatedExercises[exerciseIndex]);
    _setActiveWorkout(
      workout.copyWith(exercises: updatedExercises),
      preserveLoading: false,
    );
  }

  void _setActiveWorkout(
    WorkoutSessionState workout, {
    required bool preserveLoading,
  }) {
    state = state.copyWith(
      isLoading: preserveLoading ? state.isLoading : false,
      activeWorkout: workout,
      clearError: true,
    );
    _queueDraftSave(workout);
  }

  void _queueDraftSave(WorkoutSessionState workout) {
    if (!_draftWritesOpen) {
      return;
    }
    final ownerUserId = _ref.read(currentUserIdProvider);
    final repository = _ref.read(databaseRepositoryProvider);
    final write = _draftWriteTail.then(
      (_) =>
          repository.saveActiveSessionDraft(workout, ownerUserId: ownerUserId),
    );
    _draftWriteTail = write.catchError((Object _, StackTrace __) {});
  }

  Future<void> _discardDraft(String instanceId) async {
    _draftWritesOpen = false;
    try {
      await _draftWriteTail;
      final ownerUserId = _ref.read(currentUserIdProvider);
      await _ref
          .read(databaseRepositoryProvider)
          .clearActiveSessionDraft(instanceId, ownerUserId: ownerUserId);
    } finally {
      _draftWritesOpen = true;
    }
  }

  bool get _acceptsMutations => !state.isLoading && _conclusionInFlight == null;

  ExerciseSessionState _withResolvedCurrentSet(ExerciseSessionState exercise) {
    if (exercise.sets.isEmpty) {
      return exercise;
    }
    final firstIncomplete = exercise.sets.indexWhere(
      (set) => !_isResolved(set),
    );
    if (firstIncomplete == -1) {
      return exercise.copyWith(
        currentSetIndex: _clampSetIndex(
          exercise.currentSetIndex,
          exercise.sets.length,
        ),
      );
    }
    return exercise.copyWith(
      currentSetIndex: _clampSetIndex(firstIncomplete, exercise.sets.length),
    );
  }

  int _clampSetIndex(int setIndex, int length) {
    if (length <= 0) {
      return 0;
    }
    if (setIndex < 0) {
      return 0;
    }
    if (setIndex >= length) {
      return length - 1;
    }
    return setIndex;
  }

  double? _normalizeRpe(double? value) {
    if (value == null) {
      return null;
    }
    final clamped = value.clamp(0, 10).toDouble();
    return (clamped * 2).round() / 2;
  }

  bool _isResolved(SessionSetState set) => set.isCompleted || set.isSkipped;
}
