import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/application/services/today_workout_gateway.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';

final databaseRepositoryProvider = Provider<DatabaseRepository>((ref) {
  throw UnimplementedError(
    'databaseRepositoryProvider must be overridden in ProviderScope.',
  );
});

final todayWorkoutGatewayProvider = Provider<TodayWorkoutGateway>((ref) {
  final repository = ref.watch(databaseRepositoryProvider);
  final ownerUserId = ref.watch(currentUserIdProvider);
  return DatabaseTodayWorkoutGateway(repository, ownerUserId: ownerUserId);
});

final todayWorkoutSummaryProvider = FutureProvider<TodayWorkoutSummary>((
  ref,
) async {
  final gateway = ref.watch(todayWorkoutGatewayProvider);
  return gateway.loadTodayWorkoutSummary();
});

final activeTemplateProvider = FutureProvider<PlanTemplate>((ref) async {
  final gateway = ref.watch(todayWorkoutGatewayProvider);
  return gateway.loadActiveTemplate();
});

final activeSessionProvider =
    StateNotifierProvider<ActiveSessionNotifier, SessionState>((ref) {
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

  Future<void> startOrResumeSession() async {
    await _restoreInFlight;
    if (state.activeWorkout != null) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final repository = _ref.read(databaseRepositoryProvider);
      final ownerUserId = _ref.read(currentUserIdProvider);
      var session = state.activeWorkout;
      session ??= await _ref
          .read(todayWorkoutGatewayProvider)
          .loadTodayWorkoutSession();
      unawaited(
        repository.saveActiveSessionDraft(session, ownerUserId: ownerUserId),
      );
      state = SessionState(activeWorkout: session);
    } catch (error) {
      state = SessionState(errorMessage: error.toString());
    }
  }

  Future<void> _restorePersistedSession({required bool background}) async {
    if (state.activeWorkout != null) {
      return;
    }
    if (!background) {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      final session = await _loadPersistedSession();
      if (session == null || !mounted) {
        if (!background) {
          state = state.copyWith(isLoading: false);
        }
        return;
      }
      state = SessionState(activeWorkout: session);
    } catch (error) {
      if (!mounted || background) {
        return;
      }
      state = SessionState(errorMessage: error.toString());
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
    if (persistedDraft.instanceId == activeInstance.instanceId) {
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
    if (workout == null || index < 0 || index >= workout.exercises.length) {
      return;
    }

    _setActiveWorkout(
      workout.copyWith(currentExerciseIndex: index),
      preserveLoading: false,
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
    _updateCurrentExerciseSet(
      setIndex,
      (set) => set.copyWith(weight: newWeight < 0 ? 0 : newWeight),
    );
  }

  void completeSet(int setIndex) {
    final workout = state.activeWorkout;
    if (workout == null) {
      return;
    }

    final exerciseIndex = workout.currentExerciseIndex;
    final currentExercise = workout.exercises[exerciseIndex];
    if (setIndex < 0 || setIndex >= currentExercise.sets.length) {
      return;
    }

    final updatedSets = [...currentExercise.sets];
    updatedSets[setIndex] = updatedSets[setIndex].copyWith(isCompleted: true);

    var nextExerciseIndex = exerciseIndex;
    final nextSetIndex = updatedSets.indexWhere((set) => !set.isCompleted);
    if (nextSetIndex == -1) {
      for (var i = exerciseIndex + 1; i < workout.exercises.length; i++) {
        final candidate = workout.exercises[i];
        if (candidate.sets.any((set) => !set.isCompleted)) {
          nextExerciseIndex = i;
          break;
        }
      }
    }

    final updatedExercises = [...workout.exercises];
    updatedExercises[exerciseIndex] = currentExercise.copyWith(
      sets: updatedSets,
    );

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
      (set) => set.copyWith(isCompleted: !set.isCompleted),
    );
  }

  Future<bool> concludeSession() async {
    final workout = state.activeWorkout;
    if (workout == null) {
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _ref
          .read(todayWorkoutGatewayProvider)
          .concludeWorkoutSession(workout);
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
      return true;
    } catch (error) {
      state = SessionState(
        activeWorkout: workout,
        errorMessage: error.toString(),
      );
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
    if (workout == null) {
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

  void _setActiveWorkout(
    WorkoutSessionState workout, {
    required bool preserveLoading,
  }) {
    state = state.copyWith(
      isLoading: preserveLoading ? state.isLoading : false,
      activeWorkout: workout,
      clearError: true,
    );
    final ownerUserId = _ref.read(currentUserIdProvider);
    unawaited(
      _ref
          .read(databaseRepositoryProvider)
          .saveActiveSessionDraft(workout, ownerUserId: ownerUserId),
    );
  }
}
