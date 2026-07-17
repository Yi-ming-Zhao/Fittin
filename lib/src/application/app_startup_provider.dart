import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/home_dashboard_provider.dart';
import 'package:fittin_v2/src/application/plan_library_provider.dart';
import 'package:fittin_v2/src/application/sync_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppStartupReadiness {
  const AppStartupReadiness({this.userId, this.degraded = false});

  final String? userId;
  final bool degraded;
}

final startupMinimumDurationProvider = Provider<Duration>(
  (ref) => const Duration(milliseconds: 800),
);

final startupTimeoutProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 14),
);

final initialUserHydrationProvider = FutureProvider<SyncControllerState>((
  ref,
) async {
  final user = await ref.watch(authStateProvider.future);
  final controller = ref.read(syncControllerProvider.notifier);
  if (user == null) {
    controller.clearForSignedOutUser();
    return ref.read(syncControllerProvider);
  }

  await controller.synchronizeWithRecovery(hydrate: true);
  return ref.read(syncControllerProvider);
});

final initialHomeValidationProvider = FutureProvider<void>((ref) async {
  Future<void> validate<T>(Future<T> future) async {
    try {
      await future;
    } catch (error) {
      if (!isMissingActivePlanError(error)) {
        rethrow;
      }
    }
  }

  await Future.wait([
    validate(ref.watch(todayWorkoutSummaryProvider.future)),
    validate(ref.watch(activeTemplateProvider.future)),
    validate(ref.watch(homeDashboardDataProvider.future)),
    validate(ref.watch(planLibraryItemsProvider.future)),
  ]);
});

final appStartupReadinessProvider = FutureProvider<AppStartupReadiness>((
  ref,
) async {
  final authFuture = ref.watch(authStateProvider.future);
  final hydrationFuture = ref.watch(initialUserHydrationProvider.future);
  final minimumDuration = ref.watch(startupMinimumDurationProvider);
  final timeout = ref.watch(startupTimeoutProvider);
  final stopwatch = Stopwatch()..start();

  Future<AppStartupReadiness> prepare() async {
    final user = await authFuture;
    final expectedUserId = user?.id;
    final syncState = await hydrationFuture;
    if (ref.read(currentUserIdProvider) != expectedUserId) {
      throw StateError('Startup user scope changed during hydration.');
    }
    await ref.watch(initialHomeValidationProvider.future);
    return AppStartupReadiness(
      userId: expectedUserId,
      degraded: syncState.stage == SyncStage.retryNeeded,
    );
  }

  try {
    return await prepare().timeout(timeout);
  } finally {
    final remaining = minimumDuration - stopwatch.elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }
  }
});
