import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/pr_dashboard_provider.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/domain/models/training_state.dart';

enum HomeGreetingPeriod { morning, afternoon, evening, night }

class HomeDashboardData {
  const HomeDashboardData({
    required this.greetingPeriod,
    required this.displayName,
    required this.todayWorkout,
    required this.weekProgress,
    required this.cycleProgress,
    required this.sparklineLifts,
    required this.milestones,
    required this.hasUnreadMilestones,
  });

  final HomeGreetingPeriod greetingPeriod;
  final String displayName;
  final TodayWorkoutSummary todayWorkout;
  final double weekProgress;
  final double cycleProgress;
  final List<ExerciseProgressSummary> sparklineLifts;
  final List<PRMilestone> milestones;
  final bool hasUnreadMilestones;
}

final homeDateTimeProvider = Provider<DateTime>((ref) => DateTime.now());

final homeDisplayNamePreferenceProvider =
    StateNotifierProvider<
      HomeDisplayNamePreferenceNotifier,
      AsyncValue<String?>
    >((ref) {
      ref.watch(currentUserIdProvider);
      return HomeDisplayNamePreferenceNotifier(ref);
    });

class HomeDisplayNamePreferenceNotifier
    extends StateNotifier<AsyncValue<String?>> {
  HomeDisplayNamePreferenceNotifier(this._ref)
    : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final repository = _ref.read(databaseRepositoryProvider);
    final ownerUserId = _ref.read(currentUserIdProvider);
    state = AsyncValue.data(
      await repository.fetchHomeDisplayName(ownerUserId: ownerUserId),
    );
    _ref.invalidate(homeDashboardDataProvider);
  }

  Future<void> save(String value) async {
    final repository = _ref.read(databaseRepositoryProvider);
    final ownerUserId = _ref.read(currentUserIdProvider);
    await repository.saveHomeDisplayName(value, ownerUserId: ownerUserId);
    state = AsyncValue.data(
      await repository.fetchHomeDisplayName(ownerUserId: ownerUserId),
    );
    _ref.invalidate(homeDashboardDataProvider);
  }

  Future<void> clear() async {
    final repository = _ref.read(databaseRepositoryProvider);
    final ownerUserId = _ref.read(currentUserIdProvider);
    await repository.clearHomeDisplayName(ownerUserId: ownerUserId);
    state = const AsyncValue.data(null);
    _ref.invalidate(homeDashboardDataProvider);
  }
}

final homeDashboardDataProvider = FutureProvider<HomeDashboardData>((
  ref,
) async {
  final repository = ref.watch(databaseRepositoryProvider);
  final ownerUserId = ref.watch(currentUserIdProvider);
  final authUser = ref.watch(authStateProvider).valueOrNull;
  final locale = ref.watch(appLocaleProvider);
  final now = ref.watch(homeDateTimeProvider);
  final todayWorkout = await ref.watch(todayWorkoutSummaryProvider.future);
  final analytics = await ref.watch(progressAnalyticsOverviewProvider.future);
  final customDisplayName = await repository.fetchHomeDisplayName(
    ownerUserId: ownerUserId,
  );
  final prData = buildPRDashboardData(analytics);
  final lastSeenAt = await repository.fetchHomeMilestonesLastSeenAt(
    ownerUserId: ownerUserId,
  );
  final milestones = prData.allMilestones.take(5).toList();
  final latestMilestoneAt = milestones.isEmpty ? null : milestones.first.date;

  final cycleProgressDenominator =
      todayWorkout.cycleWeekCount * todayWorkout.workoutsPerWeek;
  final cycleProgressNumerator =
      ((todayWorkout.currentWeekNumber - 1) * todayWorkout.workoutsPerWeek) +
      (todayWorkout.currentDayNumber - 1);

  return HomeDashboardData(
    greetingPeriod: resolveGreetingPeriod(now),
    displayName: resolveHomeDisplayName(
      customDisplayName: customDisplayName,
      authUser: authUser,
      fallbackName: locale == AppLocale.zh ? '训练者' : 'Athlete',
    ),
    todayWorkout: todayWorkout,
    weekProgress:
        ((todayWorkout.currentDayNumber - 1) / todayWorkout.workoutsPerWeek)
            .clamp(0.0, 1.0),
    cycleProgress: cycleProgressDenominator == 0
        ? 0
        : (cycleProgressNumerator / cycleProgressDenominator).clamp(0.0, 1.0),
    sparklineLifts: prData.primaryLiftSummaries,
    milestones: milestones,
    hasUnreadMilestones:
        latestMilestoneAt != null &&
        (lastSeenAt == null || latestMilestoneAt.isAfter(lastSeenAt)),
  );
});

final homeDashboardControllerProvider = Provider<HomeDashboardController>(
  (ref) => HomeDashboardController(ref),
);

class HomeDashboardController {
  const HomeDashboardController(this._ref);

  final Ref _ref;

  Future<void> markMilestonesSeen(DateTime? latestMilestoneAt) async {
    if (latestMilestoneAt == null) {
      return;
    }
    final repository = _ref.read(databaseRepositoryProvider);
    final ownerUserId = _ref.read(currentUserIdProvider);
    await repository.saveHomeMilestonesLastSeenAt(
      latestMilestoneAt,
      ownerUserId: ownerUserId,
    );
    _ref.invalidate(homeDashboardDataProvider);
  }
}

HomeGreetingPeriod resolveGreetingPeriod(DateTime now) {
  final hour = now.hour;
  if (hour < 5) {
    return HomeGreetingPeriod.night;
  }
  if (hour < 12) {
    return HomeGreetingPeriod.morning;
  }
  if (hour < 18) {
    return HomeGreetingPeriod.afternoon;
  }
  return HomeGreetingPeriod.evening;
}

String resolveHomeDisplayName({
  required String? customDisplayName,
  required AuthUser? authUser,
  required String fallbackName,
}) {
  final trimmedCustom = customDisplayName?.trim();
  if (trimmedCustom != null && trimmedCustom.isNotEmpty) {
    return trimmedCustom;
  }
  final displayName = authUser?.displayName?.trim();
  if (displayName != null && displayName.isNotEmpty) {
    return displayName;
  }
  final email = authUser?.email?.trim();
  if (email != null && email.isNotEmpty) {
    return email.split('@').first;
  }
  return fallbackName;
}
