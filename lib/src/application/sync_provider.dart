import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/data/sync/sync_service.dart';

final syncControllerProvider =
    StateNotifierProvider<SyncController, SyncControllerState>((ref) {
      return SyncController(ref);
    });

enum SyncStage { idle, hydrating, syncing, synced, retryNeeded }

class SyncControllerState {
  const SyncControllerState({
    this.stage = SyncStage.idle,
    this.activeUserId,
    this.lastSyncedAt,
    this.errorMessage,
  });

  final SyncStage stage;
  final String? activeUserId;
  final DateTime? lastSyncedAt;
  final String? errorMessage;

  bool get isRunning =>
      stage == SyncStage.hydrating || stage == SyncStage.syncing;

  SyncControllerState copyWith({
    SyncStage? stage,
    String? activeUserId,
    DateTime? lastSyncedAt,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SyncControllerState(
      stage: stage ?? this.stage,
      activeUserId: activeUserId ?? this.activeUserId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class SyncController extends StateNotifier<SyncControllerState> {
  SyncController(this._ref) : super(const SyncControllerState());

  final Ref _ref;
  bool _isSynchronizing = false;

  Future<void> synchronize({bool hydrate = false}) async {
    final userId = _ref.read(currentUserIdProvider);
    if (userId == null) {
      clearForSignedOutUser();
      return;
    }
    if (_isSynchronizing) {
      return;
    }

    _isSynchronizing = true;
    final shouldHydrate =
        hydrate || state.activeUserId != userId || state.stage == SyncStage.idle;
    state = state.copyWith(
      stage: shouldHydrate ? SyncStage.hydrating : SyncStage.syncing,
      activeUserId: userId,
      clearError: true,
    );
    try {
      await _ref.read(syncServiceProvider).synchronize();
      state = state.copyWith(
        stage: SyncStage.synced,
        activeUserId: userId,
        lastSyncedAt: DateTime.now(),
        clearError: true,
      );
    } catch (_) {
      rethrow;
    } finally {
      _isSynchronizing = false;
    }
  }

  Future<void> synchronizeWithRecovery({bool hydrate = false}) async {
    try {
      await synchronize(hydrate: hydrate);
    } catch (error) {
      state = state.copyWith(
        stage: SyncStage.retryNeeded,
        errorMessage: _friendlyError(error),
      );
    }
  }

  void clearForSignedOutUser() {
    if (_isSynchronizing) {
      _isSynchronizing = false;
    }
    state = const SyncControllerState();
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }
    return message;
  }
}

class SyncLifecycleGate extends ConsumerStatefulWidget {
  const SyncLifecycleGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SyncLifecycleGate> createState() => _SyncLifecycleGateState();
}

class _SyncLifecycleGateState extends ConsumerState<SyncLifecycleGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.listenManual(authStateProvider, (_, next) {
      final user = next.valueOrNull;
      if (user != null) {
        ref
            .read(syncControllerProvider.notifier)
            .synchronizeWithRecovery(hydrate: true);
      } else {
        ref.read(syncControllerProvider.notifier).clearForSignedOutUser();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user != null) {
        ref
            .read(syncControllerProvider.notifier)
            .synchronizeWithRecovery(hydrate: true);
      } else {
        ref.read(syncControllerProvider.notifier).clearForSignedOutUser();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        ref.read(currentUserIdProvider) != null) {
      ref.read(syncControllerProvider.notifier).synchronizeWithRecovery();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
