import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/sync_refresh_provider.dart';
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
  Future<void>? _synchronizeInFlight;
  String? _synchronizingUserId;
  int? _synchronizingGeneration;
  int _generation = 0;

  Future<void> synchronize({bool hydrate = false}) {
    final userId = _ref.read(currentUserIdProvider);
    if (userId == null) {
      clearForSignedOutUser();
      return Future<void>.value();
    }

    final existing = _synchronizeInFlight;
    if (existing != null) {
      if (_synchronizingUserId == userId &&
          _synchronizingGeneration == _generation) {
        return existing;
      }
      return existing.then<void>(
        (_) => synchronize(hydrate: true),
        onError: (_, _) => synchronize(hydrate: true),
      );
    }

    final generation = _generation;
    late final Future<void> operation;
    operation =
        _performSynchronization(
          userId: userId,
          hydrate: hydrate,
          generation: generation,
        ).whenComplete(() {
          if (identical(_synchronizeInFlight, operation)) {
            _synchronizeInFlight = null;
            _synchronizingUserId = null;
            _synchronizingGeneration = null;
          }
        });
    _synchronizeInFlight = operation;
    _synchronizingUserId = userId;
    _synchronizingGeneration = generation;
    return operation;
  }

  Future<void> _performSynchronization({
    required String userId,
    required bool hydrate,
    required int generation,
  }) async {
    final shouldHydrate =
        hydrate ||
        state.activeUserId != userId ||
        state.stage == SyncStage.idle;
    state = state.copyWith(
      stage: shouldHydrate ? SyncStage.hydrating : SyncStage.syncing,
      activeUserId: userId,
      clearError: true,
    );
    try {
      await _ref.read(syncServiceProvider).synchronize();
      if (_ownsCurrentScope(userId, generation)) {
        state = state.copyWith(
          stage: SyncStage.synced,
          activeUserId: userId,
          lastSyncedAt: DateTime.now(),
          clearError: true,
        );
      }
    } catch (_) {
      rethrow;
    } finally {
      if (_ownsCurrentScope(userId, generation)) {
        _ref.read(syncRefreshProvider.notifier).state += 1;
      }
    }
  }

  Future<void> synchronizeWithRecovery({bool hydrate = false}) async {
    final requestedUserId = _ref.read(currentUserIdProvider);
    final requestedGeneration = _generation;
    try {
      await synchronize(hydrate: hydrate);
    } catch (error) {
      if (requestedUserId != null &&
          _ownsCurrentScope(requestedUserId, requestedGeneration)) {
        state = state.copyWith(
          stage: SyncStage.retryNeeded,
          activeUserId: requestedUserId,
          errorMessage: _friendlyError(error),
        );
      }
    }
  }

  void clearForSignedOutUser() {
    _generation += 1;
    state = const SyncControllerState();
  }

  bool _ownsCurrentScope(String userId, int generation) {
    return generation == _generation &&
        _ref.read(currentUserIdProvider) == userId;
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
  const SyncLifecycleGate({
    super.key,
    required this.child,
    this.performInitialSync = true,
  });

  final Widget child;
  final bool performInitialSync;

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
    if (widget.performInitialSync) {
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
