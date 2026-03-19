import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/data/sync/sync_service.dart';

final syncControllerProvider =
    StateNotifierProvider<SyncController, AsyncValue<void>>((ref) {
      return SyncController(ref);
    });

class SyncController extends StateNotifier<AsyncValue<void>> {
  SyncController(this._ref) : super(const AsyncData(null));

  final Ref _ref;

  Future<void> synchronize() async {
    state = const AsyncLoading();
    try {
      await _ref.read(syncServiceProvider).synchronize();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
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
      if (next.valueOrNull != null) {
        ref.read(syncControllerProvider.notifier).synchronize();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncControllerProvider.notifier).synchronize();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(syncControllerProvider.notifier).synchronize();
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
