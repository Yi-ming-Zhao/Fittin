import 'package:fittin_v2/src/application/app_startup_provider.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/screens/startup_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppStartupGate extends ConsumerStatefulWidget {
  const AppStartupGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppStartupGate> createState() => _AppStartupGateState();
}

class _AppStartupGateState extends ConsumerState<AppStartupGate> {
  String? _continuedScopeKey;
  String? _readyScopeKey;
  String? _lastScopeKey;
  bool _hasOpened = false;

  @override
  Widget build(BuildContext context) {
    final readiness = ref.watch(appStartupReadinessProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    final theme = ref.watch(resolvedFittinThemeProvider);
    final strings = AppStrings.of(context, ref);
    final scopeKey = currentUserId ?? '__local__';
    if (_lastScopeKey != scopeKey) {
      _lastScopeKey = scopeKey;
      _readyScopeKey = null;
      _continuedScopeKey = null;
    }
    final isReadyForCurrentScope =
        readiness.hasValue &&
        !readiness.isLoading &&
        readiness.valueOrNull?.userId == currentUserId;
    final isContinuingCurrentScope = _continuedScopeKey == scopeKey;
    if (isReadyForCurrentScope || isContinuingCurrentScope) {
      _readyScopeKey = scopeKey;
      _hasOpened = true;
    }

    final Widget visibleChild;
    if (_readyScopeKey == scopeKey) {
      visibleChild = KeyedSubtree(
        key: ValueKey('startup-ready-shell:$scopeKey'),
        child: widget.child,
      );
    } else if (_hasOpened) {
      visibleChild = Scaffold(
        key: const ValueKey('account-scope-loading'),
        body: Center(
          child: readiness.hasError && !readiness.isLoading
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(strings.accountUnavailable),
                    TextButton(onPressed: _retry, child: Text(strings.retry)),
                  ],
                )
              : const CircularProgressIndicator(),
        ),
      );
    } else {
      visibleChild = StartupSplashScreen(
        key: ValueKey(readiness.hasError ? 'startup-error' : 'startup-loading'),
        theme: theme,
        strings: strings,
        hasError: readiness.hasError && !readiness.isLoading,
        onRetry: readiness.hasError && !readiness.isLoading ? _retry : null,
        onContinueLocally: readiness.hasError && !readiness.isLoading
            ? () => setState(() => _continuedScopeKey = scopeKey)
            : null,
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (currentChild, _) => currentChild ?? const SizedBox(),
      child: visibleChild,
    );
  }

  void _retry() {
    setState(() => _continuedScopeKey = null);
    ref.invalidate(authStateProvider);
    ref.invalidate(initialUserHydrationProvider);
    ref.invalidate(initialHomeValidationProvider);
    ref.invalidate(appStartupReadinessProvider);
  }
}
