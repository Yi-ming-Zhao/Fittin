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
  ActiveSessionNotifier(this._ref) : super(SessionState());

  final Ref _ref;

  Future<void> startOrResumeSession() async {
    if (state.activeWorkout != null) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final session = await _ref
          .read(todayWorkoutGatewayProvider)
          .loadTodayWorkoutSession();
      state = SessionState(activeWorkout: session);
    } catch (error) {
      state = SessionState(errorMessage: error.toString());
    }
  }

  void selectExercise(int index) {
    final workout = state.activeWorkout;
    if (workout == null || index < 0 || index >= workout.exercises.length) {
      return;
    }

    state = state.copyWith(
      activeWorkout: workout.copyWith(currentExerciseIndex: index),
      clearError: true,
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

    state = state.copyWith(
      activeWorkout: workout.copyWith(
        exercises: updatedExercises,
        currentExerciseIndex: nextExerciseIndex,
      ),
      clearError: true,
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

    state = state.copyWith(
      activeWorkout: workout.copyWith(exercises: updatedExercises),
      clearError: true,
    );
  }
}
