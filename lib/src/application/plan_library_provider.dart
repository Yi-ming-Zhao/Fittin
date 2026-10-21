import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/sync_refresh_provider.dart';
import 'package:fittin_v2/src/application/template_editor_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/local/local_instance_repository.dart';
import 'package:fittin_v2/src/data/local/local_plan_repository.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';
import 'package:fittin_v2/src/domain/plan_start_load_review.dart';

class PlanLibraryItem {
  const PlanLibraryItem({required this.record, required this.isActive});

  final StoredTemplateRecord record;
  final bool isActive;
}

class PlanLibraryActionState {
  const PlanLibraryActionState({
    this.isSwitching = false,
    this.switchingTemplateId,
    this.errorMessage,
    this.infoMessage,
  });

  final bool isSwitching;
  final String? switchingTemplateId;
  final String? errorMessage;
  final String? infoMessage;

  PlanLibraryActionState copyWith({
    bool? isSwitching,
    String? switchingTemplateId,
    String? errorMessage,
    String? infoMessage,
    bool clearError = false,
    bool clearInfo = false,
  }) {
    return PlanLibraryActionState(
      isSwitching: isSwitching ?? this.isSwitching,
      switchingTemplateId: switchingTemplateId ?? this.switchingTemplateId,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      infoMessage: clearInfo ? null : infoMessage ?? this.infoMessage,
    );
  }
}

final planLibraryItemsProvider = FutureProvider<List<PlanLibraryItem>>((
  ref,
) async {
  ref.watch(syncRefreshProvider);
  final planRepository = ref.watch(localPlanRepositoryProvider);
  final instanceRepository = ref.watch(localInstanceRepositoryProvider);
  await planRepository.ensureDefaultProgramSeeded();
  final templates = await planRepository.fetchTemplates();
  final activeInstance = await instanceRepository.fetchActiveInstance();
  final activeTemplateId = activeInstance?.templateId;

  return [
    for (final record in templates)
      PlanLibraryItem(
        record: record,
        isActive: activeTemplateId == record.template.id,
      ),
  ];
});

final planLibraryActionProvider =
    StateNotifierProvider<PlanLibraryActionNotifier, PlanLibraryActionState>((
      ref,
    ) {
      return PlanLibraryActionNotifier(ref);
    });

final planInstanceProvider =
    FutureProvider.family<StoredTrainingInstance?, String>((
      ref,
      templateId,
    ) async {
      ref.watch(syncRefreshProvider);
      return ref
          .watch(localInstanceRepositoryProvider)
          .fetchInstanceForTemplate(templateId);
    });

class PlanLibraryActionNotifier extends StateNotifier<PlanLibraryActionState> {
  PlanLibraryActionNotifier(this._ref) : super(const PlanLibraryActionState());

  final Ref _ref;

  Future<void> transition(
    StoredTrainingInstance expected, {
    required InstanceLifecycleAction action,
    required String? expectedActiveInstanceId,
    TrainingMaxProfile trainingMaxProfile = TrainingMaxProfile.empty,
    PlanStartLoadReview? planStartLoadReview,
  }) async {
    if (state.isSwitching) return;
    state = PlanLibraryActionState(
      isSwitching: true,
      switchingTemplateId: expected.templateId,
    );
    try {
      await _ref
          .read(localInstanceRepositoryProvider)
          .transition(
            expected,
            action: action,
            expectedActiveInstanceId: expectedActiveInstanceId,
            trainingMaxProfile: trainingMaxProfile,
            planStartLoadReview: planStartLoadReview,
          );
      _refresh();
      state = const PlanLibraryActionState();
    } catch (error) {
      state = PlanLibraryActionState(errorMessage: error.toString());
      rethrow;
    }
  }

  void _refresh() {
    _ref.invalidate(planInstanceProvider);
    _ref.invalidate(planLibraryItemsProvider);
    _ref.invalidate(templateLibraryProvider);
    _ref.invalidate(todayWorkoutSummaryProvider);
    _ref.invalidate(activeTemplateProvider);
    _ref.invalidate(activeSessionProvider);
  }

  Future<void> activateTemplate(
    StoredTemplateRecord record, {
    TrainingMaxProfile trainingMaxProfile = TrainingMaxProfile.empty,
    PlanStartLoadReview? planStartLoadReview,
  }) async {
    if (state.isSwitching) return;
    state = PlanLibraryActionState(
      isSwitching: true,
      switchingTemplateId: record.template.id,
    );

    try {
      await _ref
          .read(localInstanceRepositoryProvider)
          .activateTemplate(
            record.template.id,
            trainingMaxProfile: trainingMaxProfile,
            planStartLoadReview: planStartLoadReview,
          );
      _refresh();
      state = PlanLibraryActionState(
        infoMessage: '${record.template.name} is now active.',
      );
    } catch (error) {
      state = PlanLibraryActionState(errorMessage: error.toString());
    }
  }

  void dismissMessages() {
    state = state.copyWith(clearError: true, clearInfo: true);
  }
}
