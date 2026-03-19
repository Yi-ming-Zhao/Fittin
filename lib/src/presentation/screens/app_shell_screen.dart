import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/glass_bottom_nav.dart';
import 'home_dashboard_screen.dart';
import 'plan_library_screen.dart';
import 'pr_dashboard_screen.dart';
import 'body_metrics_screen.dart';
import 'profile_settings_screen.dart';

class AppShellScreen extends ConsumerStatefulWidget {
  const AppShellScreen({super.key});

  @override
  ConsumerState<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends ConsumerState<AppShellScreen> {
  int _currentIndex = 0;

  void _handleTap(int index) {
    if (_currentIndex == index) {
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeDashboardScreen(),
          const PlanLibraryScreen(),
          const PRDashboardScreen(),
          const BodyMetricsScreen(),
          const ProfileSettingsScreen(),
        ],
      ),
      bottomNavigationBar: GlassBottomNav(
        currentIndex: _currentIndex,
        onTap: _handleTap,
      ),
    );
  }
}
