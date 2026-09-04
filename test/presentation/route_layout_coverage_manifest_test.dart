import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

enum RouteLayoutScenario {
  phone320x568,
  phone390x568,
  phone390x844,
  phone390x926,
  desktop,
  chinese,
  english,
  largeText,
  keyboard,
}

class RouteLayoutCoverage {
  const RouteLayoutCoverage(this.sourcePath, this.scenarios);

  final String sourcePath;
  final Set<RouteLayoutScenario> scenarios;
}

const _baselineScenarios = <RouteLayoutScenario>{
  RouteLayoutScenario.phone320x568,
  RouteLayoutScenario.phone390x568,
  RouteLayoutScenario.phone390x844,
  RouteLayoutScenario.phone390x926,
  RouteLayoutScenario.desktop,
  RouteLayoutScenario.chinese,
  RouteLayoutScenario.english,
  RouteLayoutScenario.largeText,
};

const _keyboardScenarios = <RouteLayoutScenario>{
  ..._baselineScenarios,
  RouteLayoutScenario.keyboard,
};

/// Each route source links to a widget test that instantiates the real screen
/// or reaches its private route through the owning public screen. Shared
/// viewport mechanics are executed separately in dashboard_layout_test.dart.
const routeLayoutEvidenceBySource = <String, String>{
  'lib/src/presentation/screens/about_screen.dart':
      'test/presentation/about_screen_test.dart',
  'lib/src/presentation/screens/account_screen.dart':
      'test/presentation/account_screen_test.dart',
  'lib/src/presentation/screens/active_session_screen.dart':
      'test/presentation/active_session_screen_test.dart',
  'lib/src/presentation/screens/advanced_analytics_screen.dart':
      'test/presentation/advanced_analytics_screen_test.dart',
  'lib/src/presentation/screens/agent_screen.dart':
      'test/presentation/agent_ui_responsive_test.dart',
  'lib/src/presentation/screens/agent_settings_screen.dart':
      'test/presentation/agent_settings_screen_test.dart',
  'lib/src/presentation/screens/app_shell_screen.dart':
      'test/presentation/app_shell_screen_test.dart',
  'lib/src/presentation/screens/app_startup_gate.dart':
      'test/presentation/app_startup_gate_test.dart',
  'lib/src/presentation/screens/body_metrics_screen.dart':
      'test/presentation/body_metrics_screen_test.dart',
  'lib/src/presentation/screens/cardio_activity_library_screen.dart':
      'test/presentation/user_content_library_screens_test.dart',
  'lib/src/presentation/screens/cardio_screen.dart':
      'test/presentation/cardio_screen_test.dart',
  'lib/src/presentation/screens/exercise_deep_dive_screen.dart':
      'test/presentation/exercise_deep_dive_screen_test.dart',
  'lib/src/presentation/screens/exercise_library_management_screen.dart':
      'test/presentation/user_content_library_screens_test.dart',
  'lib/src/presentation/screens/home_dashboard_screen.dart':
      'test/presentation/home_dashboard_screen_test.dart',
  'lib/src/presentation/screens/milestone_exercise_settings_screen.dart':
      'test/presentation/milestone_exercise_settings_screen_test.dart',
  'lib/src/presentation/screens/plan_editor_screen.dart':
      'test/presentation/plan_editor_screen_test.dart',
  'lib/src/presentation/screens/plan_library_screen.dart':
      'test/presentation/plan_library_screen_test.dart',
  'lib/src/presentation/screens/pr_dashboard_screen.dart':
      'test/presentation/pr_dashboard_screen_test.dart',
  'lib/src/presentation/screens/profile_hub_screen.dart':
      'test/presentation/profile_settings_screen_test.dart',
  'lib/src/presentation/screens/profile_preferences_screen.dart':
      'test/presentation/profile_settings_screen_test.dart',
  'lib/src/presentation/screens/profile_settings_screen.dart':
      'test/presentation/profile_settings_screen_test.dart',
  'lib/src/presentation/screens/progress_analytics_screen.dart':
      'test/presentation/progress_analytics_screen_test.dart',
  'lib/src/presentation/screens/set_type_guide_screen.dart':
      'test/presentation/profile_settings_screen_test.dart',
  'lib/src/presentation/screens/share_screen.dart':
      'test/presentation/share_screen_test.dart',
  'lib/src/presentation/screens/startup_splash_screen.dart':
      'test/presentation/app_startup_gate_test.dart',
  'lib/src/presentation/screens/theme_palette_library_screen.dart':
      'test/presentation/user_content_library_screens_test.dart',
  'lib/src/presentation/screens/workout_record_detail_screen.dart':
      'test/presentation/advanced_analytics_screen_test.dart',
};

/// Shared executable evidence for each layout contract. The referenced test
/// pumps the real dashboard scaffold and representative deep-page components;
/// routeLayoutEvidenceBySource links each concrete screen to its own widget
/// test in addition to this shared contract coverage.
const routeLayoutScenarioEvidence = <RouteLayoutScenario, String>{
  RouteLayoutScenario.phone320x568:
      'test/presentation/dashboard_layout_test.dart',
  RouteLayoutScenario.phone390x568:
      'test/presentation/dashboard_layout_test.dart',
  RouteLayoutScenario.phone390x844:
      'test/presentation/dashboard_layout_test.dart',
  RouteLayoutScenario.phone390x926:
      'test/presentation/dashboard_layout_test.dart',
  RouteLayoutScenario.desktop: 'test/presentation/dashboard_layout_test.dart',
  RouteLayoutScenario.chinese: 'test/presentation/dashboard_layout_test.dart',
  RouteLayoutScenario.english: 'test/presentation/dashboard_layout_test.dart',
  RouteLayoutScenario.largeText: 'test/presentation/dashboard_layout_test.dart',
  RouteLayoutScenario.keyboard: 'test/presentation/dashboard_layout_test.dart',
};

/// Executable inventory for every screen class in the presentation route tree.
///
/// This is intentionally explicit. Adding a new `*Screen`, `*Gate`, or `*Page`
/// without deciding its narrow-phone, desktop, locale, large-text, and keyboard
/// coverage makes the inventory test fail instead of silently leaving a deep
/// route unaudited.
const routeLayoutCoverage = <String, RouteLayoutCoverage>{
  'AboutScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/about_screen.dart',
    _baselineScenarios,
  ),
  'AccountAndProfileScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/profile_hub_screen.dart',
    _baselineScenarios,
  ),
  'AccountScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/account_screen.dart',
    _keyboardScenarios,
  ),
  'ActiveSessionScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/active_session_screen.dart',
    _keyboardScenarios,
  ),
  'AdvancedAnalyticsScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/advanced_analytics_screen.dart',
    _baselineScenarios,
  ),
  'AgentScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/agent_screen.dart',
    _keyboardScenarios,
  ),
  'AgentSettingsScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/agent_settings_screen.dart',
    _keyboardScenarios,
  ),
  'AppearanceSettingsScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/profile_hub_screen.dart',
    _baselineScenarios,
  ),
  'AppShellScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/app_shell_screen.dart',
    _baselineScenarios,
  ),
  'AppStartupGate': RouteLayoutCoverage(
    'lib/src/presentation/screens/app_startup_gate.dart',
    _baselineScenarios,
  ),
  'BodyMetricsScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/body_metrics_screen.dart',
    _keyboardScenarios,
  ),
  'CardioActivityEditorScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/cardio_activity_library_screen.dart',
    _keyboardScenarios,
  ),
  'CardioActivityLibraryScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/cardio_activity_library_screen.dart',
    _keyboardScenarios,
  ),
  'CardioHubScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/cardio_screen.dart',
    _keyboardScenarios,
  ),
  'CardioImportScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/cardio_screen.dart',
    _keyboardScenarios,
  ),
  'CardioRecordEditorScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/cardio_screen.dart',
    _keyboardScenarios,
  ),
  'CustomExerciseEditorScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/exercise_library_management_screen.dart',
    _keyboardScenarios,
  ),
  'CustomPaletteEditorScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/theme_palette_library_screen.dart',
    _keyboardScenarios,
  ),
  'DataPrivacyScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/profile_hub_screen.dart',
    _baselineScenarios,
  ),
  'ExerciseDeepDiveScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/exercise_deep_dive_screen.dart',
    _baselineScenarios,
  ),
  'ExerciseLibraryManagementScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/exercise_library_management_screen.dart',
    _keyboardScenarios,
  ),
  'HomeDashboardScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/home_dashboard_screen.dart',
    _baselineScenarios,
  ),
  'MilestoneExerciseSettingsScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/milestone_exercise_settings_screen.dart',
    _keyboardScenarios,
  ),
  'MilestoneHistoryScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/pr_dashboard_screen.dart',
    _baselineScenarios,
  ),
  'PlanEditorScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/plan_editor_screen.dart',
    _keyboardScenarios,
  ),
  'PlanLibraryScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/plan_library_screen.dart',
    _keyboardScenarios,
  ),
  'PRDashboardScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/pr_dashboard_screen.dart',
    _baselineScenarios,
  ),
  'ProfileHubScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/profile_hub_screen.dart',
    _baselineScenarios,
  ),
  'ProfilePreferencesScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/profile_preferences_screen.dart',
    _keyboardScenarios,
  ),
  'ProfileSettingsScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/profile_settings_screen.dart',
    _baselineScenarios,
  ),
  'ProgressAnalyticsScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/progress_analytics_screen.dart',
    _baselineScenarios,
  ),
  'QRScannerScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/share_screen.dart',
    _baselineScenarios,
  ),
  'SetTypeGuideScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/set_type_guide_screen.dart',
    _baselineScenarios,
  ),
  'ShareScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/share_screen.dart',
    _baselineScenarios,
  ),
  'StartupSplashScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/startup_splash_screen.dart',
    _baselineScenarios,
  ),
  'ThemePaletteLibraryScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/theme_palette_library_screen.dart',
    _keyboardScenarios,
  ),
  'TrainingSettingsScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/profile_hub_screen.dart',
    _baselineScenarios,
  ),
  'WorkoutRecordDetailScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/workout_record_detail_screen.dart',
    _keyboardScenarios,
  ),
  '_PlanDetailScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/plan_library_screen.dart',
    _keyboardScenarios,
  ),
  '_TrainingDayDetailScreen': RouteLayoutCoverage(
    'lib/src/presentation/screens/advanced_analytics_screen.dart',
    _baselineScenarios,
  ),
};

const excludedRouteLikeWidgets = <String, String>{
  '_HomeE1rmPage':
      'Non-routed PageView panel covered by the home dashboard widget test.',
};

void main() {
  test(
    'route layout manifest covers every screen, gate, page, and private route',
    () {
      final discovered = <String, String>{};
      final routeLikePattern = RegExp(
        r'^class\s+([A-Za-z_][A-Za-z0-9_]*(?:Screen|Gate|Page))\s+extends\s+',
        multiLine: true,
      );
      for (final entity in Directory(
        'lib/src/presentation/screens',
      ).listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final source = entity.readAsStringSync();
        for (final match in routeLikePattern.allMatches(source)) {
          final screenName = match.group(1)!;
          expect(
            discovered.containsKey(screenName),
            isFalse,
            reason: 'Duplicate screen class: $screenName',
          );
          discovered[screenName] = entity.path;
        }
      }

      final declaredNames = {
        ...routeLayoutCoverage.keys,
        ...excludedRouteLikeWidgets.keys,
      };
      expect(
        declaredNames,
        equals(discovered.keys.toSet()),
        reason:
            'Every new *Screen, *Gate, or *Page must be added to '
            'routeLayoutCoverage, or explicitly excluded with a reason.',
      );
      for (final entry in routeLayoutCoverage.entries) {
        expect(discovered[entry.key], entry.value.sourcePath);
      }
    },
  );

  test('every route maps baseline scenarios and input routes map keyboard', () {
    for (final entry in routeLayoutCoverage.entries) {
      expect(
        entry.value.scenarios.containsAll(_baselineScenarios),
        isTrue,
        reason: '${entry.key} is missing a baseline layout scenario',
      );
      final source = File(entry.value.sourcePath).readAsStringSync();
      final sourceOwnsTextInput =
          source.contains('TextField(') || source.contains('TextFormField(');
      if (sourceOwnsTextInput) {
        expect(
          entry.value.scenarios,
          contains(RouteLayoutScenario.keyboard),
          reason: '${entry.key} shares a route source containing text input',
        );
      }
      final evidencePath = routeLayoutEvidenceBySource[entry.value.sourcePath];
      expect(
        evidencePath,
        isNotNull,
        reason: '${entry.key} must link to an executable widget test',
      );
      expect(
        File(evidencePath!).existsSync(),
        isTrue,
        reason: '${entry.key} references missing evidence: $evidencePath',
      );
      for (final scenario in entry.value.scenarios) {
        final scenarioEvidence = routeLayoutScenarioEvidence[scenario];
        expect(
          scenarioEvidence,
          isNotNull,
          reason: '${entry.key} has no executable evidence for $scenario',
        );
        expect(
          File(scenarioEvidence!).existsSync(),
          isTrue,
          reason: 'Missing shared scenario evidence: $scenarioEvidence',
        );
      }
    }
  });
}
