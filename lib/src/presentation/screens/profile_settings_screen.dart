import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/application/ui_settings_provider.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/screens/account_screen.dart';
import 'package:fittin_v2/src/presentation/screens/profile_preferences_screen.dart';
import 'package:fittin_v2/src/presentation/screens/set_type_guide_screen.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';
import 'package:fittin_v2/src/presentation/widgets/fittin_card.dart';
import 'package:fittin_v2/src/presentation/widgets/fittin_primitives.dart';
import 'package:fittin_v2/src/presentation/widgets/weight_tools_sheet.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart'
    show FittinTheme;

class ProfileSettingsScreen extends ConsumerWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context, ref);
    final fittinTheme = ref.watch(resolvedFittinThemeProvider);
    final locale = ref.watch(appLocaleProvider);
    final notifier = ref.read(appLocaleProvider.notifier);
    final authUser = ref.watch(authStateProvider).valueOrNull;
    final recordingMode = ref.watch(workoutRecordingModeProvider);

    return DashboardPageScaffold(
      bottomPadding: 180,
      children: [
        DashboardScreenHeader(
          eyebrow: strings.profile,
          title: strings.settings,
          subtitle: strings.isChinese
              ? '账号、语言、重量工具与界面偏好。'
              : 'Account, language, weight tools, and interface preferences.',
        ),
        const SizedBox(height: 24),
        DashboardSectionLabel(label: strings.account),
        const SizedBox(height: 10),
        DashboardSurfaceCard(
          radius: fittinTheme.radius,
          padding: EdgeInsets.all(fittinTheme.pad),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authUser?.email ?? strings.signedOut,
                      style: fittinTheme
                          .displayStyle(18, fittinTheme.fg)
                          .copyWith(height: 1.1),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      strings.accountSubtitle,
                      style: fittinTheme.uiStyle(14, fittinTheme.fgDim),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FittinBtn(
                fittinTheme,
                strings.isChinese ? strings.manageAccount : 'Manage',
                key: const ValueKey('open-account-screen'),
                size: 'sm',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AccountScreen()),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        DashboardSectionLabel(label: strings.language),
        const SizedBox(height: 10),
        FittinCard(
          theme: fittinTheme,
          noPad: true,
          child: Column(
            children: [
              _LocaleTile(
                theme: fittinTheme,
                key: const ValueKey('locale-en'),
                title: strings.english,
                subtitle: 'English',
                selected: locale == AppLocale.en,
                onTap: () => notifier.setLocale(AppLocale.en),
                showDivider: true,
              ),
              _LocaleTile(
                theme: fittinTheme,
                key: const ValueKey('locale-zh'),
                title: strings.chinese,
                subtitle: 'Chinese',
                selected: locale == AppLocale.zh,
                onTap: () => notifier.setLocale(AppLocale.zh),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        DashboardSectionLabel(
          label: strings.isChinese ? '训练记录方式' : 'WORKOUT LOGGING',
        ),
        const SizedBox(height: 10),
        FittinCard(
          theme: fittinTheme,
          noPad: true,
          child: Column(
            children: [
              _LocaleTile(
                key: const ValueKey('recording-mode-card'),
                theme: fittinTheme,
                title: strings.isChinese ? '卡片记录' : 'Card logger',
                subtitle: strings.isChinese
                    ? '左滑完成、下滑取消，实时查看后续组。'
                    : 'Swipe left to finish, down to cancel, with a live set stack.',
                selected: recordingMode == WorkoutRecordingMode.card,
                onTap: () => ref
                    .read(workoutRecordingModeProvider.notifier)
                    .update(WorkoutRecordingMode.card),
                showDivider: true,
              ),
              _LocaleTile(
                key: const ValueKey('recording-mode-traditional'),
                theme: fittinTheme,
                title: strings.isChinese ? '传统记录' : 'Traditional logger',
                subtitle: strings.isChinese
                    ? '保留按钮式录入与居中的完成操作。'
                    : 'Keep button-based entry with a centered finish action.',
                selected: recordingMode == WorkoutRecordingMode.traditional,
                onTap: () => ref
                    .read(workoutRecordingModeProvider.notifier)
                    .update(WorkoutRecordingMode.traditional),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        DashboardSectionLabel(
          label: strings.isChinese ? '重量工具' : 'WEIGHT TOOLS',
        ),
        const SizedBox(height: 10),
        const WeightToolsSettingsCard(),
        const SizedBox(height: 24),
        DashboardSectionLabel(label: strings.isChinese ? '参考' : 'REFERENCE'),
        const SizedBox(height: 10),
        FittinCard(
          theme: fittinTheme,
          noPad: true,
          child: Column(
            children: [
              _SettingsLinkRow(
                key: const ValueKey('open-set-type-guide'),
                theme: fittinTheme,
                title: strings.trainingSetGuide,
                subtitle: strings.trainingSetGuideSubtitle,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SetTypeGuideScreen()),
                ),
                showDivider: true,
              ),
              _SettingsLinkRow(
                key: const ValueKey('open-profile-preferences'),
                theme: fittinTheme,
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
        const SizedBox(height: 24),
        DashboardSectionLabel(
          label: strings.isChinese ? '视觉设置' : 'VISUAL SETTINGS',
        ),
        const SizedBox(height: 10),
        DashboardSurfaceCard(
          radius: fittinTheme.radius,
          padding: EdgeInsets.all(fittinTheme.pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.isChinese ? '磨砂玻璃透明度' : 'Glassmorphism Opacity',
                style: fittinTheme
                    .uiStyle(16, fittinTheme.fg)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                strings.isChinese
                    ? '调节全局界面卡片的透明强度。'
                    : 'Adjust the global transparency intensity for interface cards.',
                style: fittinTheme.uiStyle(14, fittinTheme.fgDim),
              ),
              const SizedBox(height: 24),
              Consumer(
                builder: (context, ref, child) {
                  final opacity = ref.watch(uiSettingsProvider);
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '0.1',
                            style: fittinTheme.uiStyle(11, fittinTheme.fgMuted),
                          ),
                          Text(
                            '${(opacity * 100).toInt()}%',
                            style: fittinTheme
                                .uiStyle(14, fittinTheme.accent)
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '1.0',
                            style: fittinTheme.uiStyle(11, fittinTheme.fgMuted),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 16,
                          ),
                        ),
                        child: Slider(
                          value: opacity,
                          min: 0.1,
                          max: 1.0,
                          onChanged: (val) => ref
                              .read(uiSettingsProvider.notifier)
                              .updateOpacity(val),
                        ),
                      ),
                    ],
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

class _LocaleTile extends StatelessWidget {
  const _LocaleTile({
    super.key,
    required this.theme,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.showDivider = false,
  });

  final FittinTheme theme;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          border: showDivider
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
                    style: theme
                        .uiStyle(14, theme.fg)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: theme.uiStyle(12, theme.fgDim)),
                ],
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? theme.accent : theme.borderHi,
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: selected
                  ? Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.accent,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsLinkRow extends StatelessWidget {
  const _SettingsLinkRow({
    super.key,
    required this.theme,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showDivider = false,
  });

  final FittinTheme theme;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          border: showDivider
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
                    style: theme
                        .uiStyle(14, theme.fg)
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
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
}
