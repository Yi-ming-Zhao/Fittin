import 'package:fittin_v2/src/application/agent_provider_settings_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/application/ui_settings_provider.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/screens/about_screen.dart';
import 'package:fittin_v2/src/presentation/screens/account_screen.dart';
import 'package:fittin_v2/src/presentation/screens/agent_settings_screen.dart';
import 'package:fittin_v2/src/presentation/screens/cardio_activity_library_screen.dart';
import 'package:fittin_v2/src/presentation/screens/exercise_library_management_screen.dart';
import 'package:fittin_v2/src/presentation/screens/milestone_exercise_settings_screen.dart';
import 'package:fittin_v2/src/presentation/screens/profile_preferences_screen.dart';
import 'package:fittin_v2/src/presentation/screens/set_type_guide_screen.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:fittin_v2/src/presentation/widgets/appearance_palette_picker.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';
import 'package:fittin_v2/src/presentation/widgets/fittin_card.dart';
import 'package:fittin_v2/src/presentation/widgets/weight_tools_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileHubScreen extends ConsumerWidget {
  const ProfileHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context, ref);
    final theme = ref.watch(resolvedFittinThemeProvider);
    final user = ref.watch(authStateProvider);
    final agent = ref.watch(agentProviderSettingsControllerProvider);
    final accountSummary = user.when(
      data: (value) => value?.email ?? strings.signedOut,
      loading: () => strings.restoringAccount,
      error: (_, _) => strings.accountUnavailable,
    );
    final agentSummary = switch (agent.readiness) {
      AgentProviderReadiness.ready => strings.agentReady,
      AgentProviderReadiness.unverified => strings.agentNeedsTest,
      _ => strings.agentNotConfigured,
    };
    return DashboardPageScaffold(
      children: [
        DashboardScreenHeader(
          eyebrow: strings.profile,
          title: strings.isChinese ? '我的' : 'My Fittin',
          subtitle: strings.isChinese
              ? '账号、训练、外观和数据设置已按任务分组。'
              : 'Account, training, appearance, and data settings are grouped by task.',
        ),
        const SizedBox(height: 20),
        FittinCard(
          theme: theme,
          noPad: true,
          child: Column(
            children: [
              _HubRow(
                key: const ValueKey('profile-category-account'),
                theme: theme,
                icon: Icons.person_outline_rounded,
                title: strings.isChinese ? '账号与同步' : 'Account & sync',
                subtitle: accountSummary,
                onTap: () => _open(context, const AccountAndProfileScreen()),
                divider: true,
              ),
              _HubRow(
                key: const ValueKey('profile-category-training'),
                theme: theme,
                icon: Icons.fitness_center_rounded,
                title: strings.isChinese ? '训练与动作库' : 'Training & libraries',
                subtitle: strings.isChinese
                    ? '记录方式、动作、有氧和重量工具'
                    : 'Logging, exercises, cardio, and weight tools',
                onTap: () => _open(context, const TrainingSettingsScreen()),
                divider: true,
              ),
              _HubRow(
                key: const ValueKey('profile-category-appearance'),
                theme: theme,
                icon: Icons.palette_outlined,
                title: strings.isChinese ? '外观与语言' : 'Appearance & language',
                subtitle: strings.isChinese
                    ? '8 套系统配色、自定义配色和界面细节'
                    : 'Eight built-ins, custom palettes, and interface details',
                onTap: () => _open(context, const AppearanceSettingsScreen()),
                divider: true,
              ),
              _HubRow(
                key: const ValueKey('profile-category-agent'),
                theme: theme,
                icon: Icons.auto_awesome_outlined,
                title: strings.agentSettings,
                subtitle: agentSummary,
                onTap: () => _open(context, const AgentSettingsScreen()),
                divider: true,
              ),
              _HubRow(
                key: const ValueKey('profile-category-privacy'),
                theme: theme,
                icon: Icons.shield_outlined,
                title: strings.isChinese ? '数据与隐私' : 'Data & privacy',
                subtitle: strings.isChinese
                    ? '本地优先、云同步和 Agent 数据边界'
                    : 'Local-first storage, cloud sync, and Agent boundaries',
                onTap: () => _open(context, const DataPrivacyScreen()),
                divider: true,
              ),
              _HubRow(
                key: const ValueKey('profile-category-about'),
                theme: theme,
                icon: Icons.info_outline_rounded,
                title: strings.aboutFittin,
                subtitle: strings.isChinese
                    ? '版本、更新、开源许可和支持'
                    : 'Version, updates, licenses, and support',
                onTap: () => _open(context, const AboutScreen()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

class AccountAndProfileScreen extends ConsumerWidget {
  const AccountAndProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context, ref);
    final theme = ref.watch(resolvedFittinThemeProvider);
    return DashboardPageScaffold(
      layout: DashboardPageLayout.detail,
      children: [
        DashboardScreenHeader(
          eyebrow: strings.isChinese ? '账号' : 'ACCOUNT',
          title: strings.isChinese ? '账号与同步' : 'Account & sync',
          subtitle: strings.isChinese
              ? '管理登录、云同步和首页显示名称。'
              : 'Manage sign-in, cloud sync, and your Home display name.',
          showBackButton: true,
        ),
        const SizedBox(height: 18),
        FittinCard(
          theme: theme,
          noPad: true,
          child: Column(
            children: [
              _LinkRow(
                key: const ValueKey('open-account-screen'),
                theme: theme,
                title: strings.isChinese ? '登录与云同步' : 'Sign-in & cloud sync',
                subtitle: strings.accountSubtitle,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AccountScreen()),
                ),
                divider: true,
              ),
              _LinkRow(
                key: const ValueKey('open-profile-preferences'),
                theme: theme,
                title: strings.profilePreferences,
                subtitle: strings.profilePreferencesSubtitle,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ProfilePreferencesScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TrainingSettingsScreen extends ConsumerWidget {
  const TrainingSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context, ref);
    final theme = ref.watch(resolvedFittinThemeProvider);
    final mode = ref.watch(workoutRecordingModeProvider);
    return DashboardPageScaffold(
      layout: DashboardPageLayout.detail,
      children: [
        DashboardScreenHeader(
          eyebrow: strings.isChinese ? '训练' : 'TRAINING',
          title: strings.isChinese ? '训练与动作库' : 'Training & libraries',
          subtitle: strings.isChinese
              ? '集中管理记录交互、动作标签、有氧项目和重量工具。'
              : 'Manage logging interaction, exercise tags, cardio activities, and weight tools.',
          showBackButton: true,
        ),
        const SizedBox(height: 20),
        DashboardSectionLabel(
          label: strings.isChinese ? '记录方式' : 'LOGGING MODE',
        ),
        const SizedBox(height: 10),
        FittinCard(
          theme: theme,
          noPad: true,
          child: Column(
            children: [
              _SelectionRow(
                key: const ValueKey('recording-mode-card'),
                theme: theme,
                title: strings.cardLogger,
                subtitle: strings.cardLoggerSubtitle,
                selected: mode == WorkoutRecordingMode.card,
                onTap: () => ref
                    .read(workoutRecordingModeProvider.notifier)
                    .update(WorkoutRecordingMode.card),
                divider: true,
              ),
              _SelectionRow(
                key: const ValueKey('recording-mode-traditional'),
                theme: theme,
                title: strings.traditionalLogger,
                subtitle: strings.traditionalLoggerSubtitle,
                selected: mode == WorkoutRecordingMode.traditional,
                onTap: () => ref
                    .read(workoutRecordingModeProvider.notifier)
                    .update(WorkoutRecordingMode.traditional),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        DashboardSectionLabel(
          label: strings.isChinese ? '训练库' : 'TRAINING LIBRARIES',
        ),
        const SizedBox(height: 10),
        FittinCard(
          theme: theme,
          noPad: true,
          child: Column(
            children: [
              _LinkRow(
                key: const ValueKey('open-exercise-library'),
                theme: theme,
                title: strings.isChinese ? '动作库' : 'Exercise library',
                subtitle: strings.isChinese
                    ? '搜索、标签、复制和自定义动作'
                    : 'Search, tag, copy, and customize exercises',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ExerciseLibraryManagementScreen(),
                  ),
                ),
                divider: true,
              ),
              _LinkRow(
                key: const ValueKey('open-cardio-library'),
                theme: theme,
                title: strings.isChinese ? '有氧项目库' : 'Cardio activity library',
                subtitle: strings.isChinese
                    ? '管理不同项目的必填和可选指标'
                    : 'Manage required and optional metrics by activity',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CardioActivityLibraryScreen(),
                  ),
                ),
                divider: true,
              ),
              _LinkRow(
                key: const ValueKey('open-milestone-exercise-settings'),
                theme: theme,
                title: strings.milestoneExercises,
                subtitle: strings.milestoneExercisesSubtitle,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MilestoneExerciseSettingsScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        DashboardSectionLabel(label: strings.weightToolsSection),
        const SizedBox(height: 10),
        const WeightToolsSettingsCard(),
        const SizedBox(height: 20),
        DashboardSectionLabel(label: strings.referenceSection),
        const SizedBox(height: 10),
        FittinCard(
          theme: theme,
          noPad: true,
          child: _LinkRow(
            key: const ValueKey('open-set-type-guide'),
            theme: theme,
            title: strings.trainingSetGuide,
            subtitle: strings.trainingSetGuideSubtitle,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SetTypeGuideScreen()),
            ),
          ),
        ),
      ],
    );
  }
}

class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context, ref);
    final theme = ref.watch(resolvedFittinThemeProvider);
    final locale = ref.watch(appLocaleProvider);
    return DashboardPageScaffold(
      layout: DashboardPageLayout.detail,
      children: [
        DashboardScreenHeader(
          eyebrow: strings.isChinese ? '外观' : 'APPEARANCE',
          title: strings.isChinese ? '外观与语言' : 'Appearance & language',
          subtitle: strings.appearanceDescription,
          showBackButton: true,
        ),
        const SizedBox(height: 20),
        DashboardSectionLabel(label: strings.language),
        const SizedBox(height: 10),
        FittinCard(
          theme: theme,
          noPad: true,
          child: Column(
            children: [
              _SelectionRow(
                key: const ValueKey('locale-en'),
                theme: theme,
                title: strings.english,
                subtitle: strings.englishLanguageSubtitle,
                selected: locale == AppLocale.en,
                onTap: () => ref
                    .read(appLocaleProvider.notifier)
                    .setLocale(AppLocale.en),
                divider: true,
              ),
              _SelectionRow(
                key: const ValueKey('locale-zh'),
                theme: theme,
                title: strings.chinese,
                subtitle: strings.chineseLanguageSubtitle,
                selected: locale == AppLocale.zh,
                onTap: () => ref
                    .read(appLocaleProvider.notifier)
                    .setLocale(AppLocale.zh),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        DashboardSectionLabel(label: strings.appearanceSection),
        const SizedBox(height: 10),
        const AppearancePalettePicker(),
        const SizedBox(height: 20),
        DashboardSectionLabel(label: strings.visualSettingsSection),
        const SizedBox(height: 10),
        DashboardSurfaceCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.glassmorphismOpacity,
                style: theme.uiStyle(15, theme.fg, FontWeight.w700),
              ),
              const SizedBox(height: 5),
              Text(
                strings.glassmorphismOpacitySubtitle,
                style: theme.uiStyle(13, theme.fgDim),
              ),
              Consumer(
                builder: (context, ref, _) {
                  final opacity = ref.watch(uiSettingsProvider);
                  return Slider(
                    value: opacity,
                    min: 0.1,
                    max: 1,
                    label: '${(opacity * 100).round()}%',
                    onChanged: ref
                        .read(uiSettingsProvider.notifier)
                        .updateOpacity,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DataPrivacyScreen extends ConsumerWidget {
  const DataPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context, ref);
    final theme = ref.watch(resolvedFittinThemeProvider);
    return DashboardPageScaffold(
      layout: DashboardPageLayout.detail,
      children: [
        DashboardScreenHeader(
          eyebrow: strings.isChinese ? '隐私' : 'PRIVACY',
          title: strings.isChinese ? '数据与隐私' : 'Data & privacy',
          subtitle: strings.isChinese
              ? '训练优先写入本机，登录后再通过你的账号同步。'
              : 'Training writes locally first, then syncs through your account when signed in.',
          showBackButton: true,
        ),
        const SizedBox(height: 18),
        for (final item in [
          (
            Icons.phone_android_rounded,
            strings.isChinese ? '本地优先' : 'Local first',
            strings.isChinese
                ? '断网时仍可记录；重连后安全同步。'
                : 'Keep recording offline; changes sync safely after reconnection.',
          ),
          (
            Icons.key_rounded,
            strings.isChinese ? 'Agent 密钥' : 'Agent credentials',
            strings.isChinese
                ? '模型 API Key 不进入 Fittin 云同步或训练日志。'
                : 'Provider API keys never enter Fittin cloud sync or training logs.',
          ),
          (
            Icons.photo_outlined,
            strings.isChinese ? '进度照片' : 'Progress photos',
            strings.isChinese
                ? '照片不对 Agent 开放，也不会被模型分析。'
                : 'Photos are excluded from Agent tools and model analysis.',
          ),
        ]) ...[
          DashboardSurfaceCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item.$1, color: theme.accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.$2,
                        style: theme.uiStyle(14, theme.fg, FontWeight.w700),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.$3,
                        style: theme
                            .uiStyle(13, theme.fgDim)
                            .copyWith(height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AccountScreen())),
            icon: const Icon(Icons.sync_rounded),
            label: Text(
              strings.isChinese ? '管理账号与同步' : 'Manage account and sync',
            ),
          ),
        ),
      ],
    );
  }
}

class _HubRow extends StatelessWidget {
  const _HubRow({
    super.key,
    required this.theme,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.divider = false,
  });

  final FittinTheme theme;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool divider;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 72),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: divider
              ? Border(bottom: BorderSide(color: theme.border, width: 0.5))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.surfaceHi,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: theme.accent, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.uiStyle(14, theme.fg, FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.uiStyle(11, theme.fgMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: theme.fgMuted),
          ],
        ),
      ),
    ),
  );
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    super.key,
    required this.theme,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.divider = false,
  });

  final FittinTheme theme;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool divider;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: divider
            ? Border(bottom: BorderSide(color: theme.border, width: 0.5))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.uiStyle(14, theme.fg, FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(subtitle, style: theme.uiStyle(11, theme.fgMuted)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: theme.fgMuted),
        ],
      ),
    ),
  );
}

class _SelectionRow extends StatelessWidget {
  const _SelectionRow({
    super.key,
    required this.theme,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.divider = false,
  });

  final FittinTheme theme;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final bool divider;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    inMutuallyExclusiveGroup: true,
    label: '$title. $subtitle',
    child: InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 58),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: divider
              ? Border(bottom: BorderSide(color: theme.border, width: 0.5))
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.uiStyle(14, theme.fg, FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(subtitle, style: theme.uiStyle(11, theme.fgMuted)),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? theme.accent : theme.fgMuted,
            ),
          ],
        ),
      ),
    ),
  );
}
