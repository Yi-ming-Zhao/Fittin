import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/glass_bottom_nav.dart';
import 'home_dashboard_screen.dart';
import 'agent_screen.dart';
import 'plan_library_screen.dart';
import 'pr_dashboard_screen.dart';
import 'body_metrics_screen.dart';
import 'profile_settings_screen.dart';
import '../../application/fittin_theme_provider.dart';
import '../app_shell_navigation.dart';

class AppShellScreen extends ConsumerStatefulWidget {
  const AppShellScreen({super.key});

  @override
  ConsumerState<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends ConsumerState<AppShellScreen> {
  void _handleTap(int index) {
    if (ref.read(appShellTabIndexProvider) == index) return;
    ref.read(appShellTabIndexProvider.notifier).state = index;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(resolvedFittinThemeProvider);
    final currentIndex = ref.watch(appShellTabIndexProvider);

    return Scaffold(
      extendBody: false,
      body: IndexedStack(
        index: currentIndex,
        children: const [
          HomeDashboardScreen(),
          PlanLibraryScreen(),
          AgentScreen(),
          PRDashboardScreen(),
          BodyMetricsScreen(),
          ProfileSettingsScreen(),
        ],
      ),
      bottomNavigationBar: FittinTabBar(
        theme: theme,
        active: [
          'home',
          'plans',
          'agent',
          'progress',
          'body',
          'profile',
        ][currentIndex],
        onChange: (id) => _handleTap(
          ['home', 'plans', 'agent', 'progress', 'body', 'profile'].indexOf(id),
        ),
      ),
    );
  }
}
