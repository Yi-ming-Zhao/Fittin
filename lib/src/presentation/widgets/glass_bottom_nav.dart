import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';

/// Fittin bottom tab bar — 5 tabs with glass background
/// Tabs: Today, Plans, Progress, Body, Profile
class FittinTabBar extends ConsumerWidget {
  const FittinTabBar({
    super.key,
    required this.theme,
    required this.active,
    required this.onChange,
  });

  final FittinTheme theme;
  final String active; // 'home' | 'plans' | 'progress' | 'body' | 'profile'
  final ValueChanged<String> onChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context, ref);
    final tabs = [
      ('home', strings.navToday, Icons.play_arrow_rounded),
      ('plans', strings.navPlans, Icons.layers_rounded),
      ('progress', strings.navPr, Icons.trending_up_rounded),
      ('body', strings.navBody, Icons.accessibility_new_rounded),
      ('profile', strings.navMe, Icons.person_outline_rounded),
    ];
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 398),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: theme.surface.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: theme.border, width: 0.5),
                ),
                child: Row(
                  children: tabs.map((t) {
                    final isActive = t.$1 == active;
                    return Expanded(
                      child: _FittinTabItem(
                        key: ValueKey(_navKeyFor(t.$1)),
                        theme: theme,
                        label: t.$2,
                        icon: t.$3,
                        isActive: isActive,
                        onTap: () => onChange(t.$1),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _navKeyFor(String id) {
    return switch (id) {
      'plans' => 'nav-plan-library',
      'profile' => 'nav-profile',
      _ => 'nav-$id',
    };
  }
}

class _FittinTabItem extends StatelessWidget {
  const _FittinTabItem({
    super.key,
    required this.theme,
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final FittinTheme theme;
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isActive,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: isActive ? theme.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: isActive
              ? theme.accentInk.withValues(alpha: 0.12)
              : theme.accent.withValues(alpha: 0.12),
          highlightColor: theme.fg.withValues(alpha: 0.05),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 17,
                  color: isActive ? theme.accentInk : theme.fgDim,
                ),
                const SizedBox(height: 1),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme
                        .uiStyle(10, isActive ? theme.accentInk : theme.fgDim)
                        .copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Backward-compatible GlassBottomNav — wraps FittinTabBar
class GlassBottomNav extends StatelessWidget {
  const GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.theme,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final FittinTheme? theme;

  static const _tabIds = ['home', 'plans', 'progress', 'body', 'profile'];

  @override
  Widget build(BuildContext context) {
    // If no FittinTheme provided, use a default
    if (theme == null) {
      return _LegacyNav(currentIndex: currentIndex, onTap: onTap);
    }
    return FittinTabBar(
      theme: theme!,
      active: _tabIds[currentIndex],
      onChange: (id) => onTap(_tabIds.indexOf(id)),
    );
  }
}

// Legacy fallback for when no FittinTheme is available
class _LegacyNav extends StatelessWidget {
  const _LegacyNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LegacyItem(
                  icon: Icons.home_rounded,
                  isActive: currentIndex == 0,
                  onTap: () => onTap(0),
                  theme: theme,
                ),
                _LegacyItem(
                  icon: Icons.fitness_center_rounded,
                  isActive: currentIndex == 1,
                  onTap: () => onTap(1),
                  theme: theme,
                ),
                _LegacyItem(
                  icon: Icons.insights_rounded,
                  isActive: currentIndex == 2,
                  onTap: () => onTap(2),
                  theme: theme,
                ),
                _LegacyItem(
                  icon: Icons.accessibility_new_rounded,
                  isActive: currentIndex == 3,
                  onTap: () => onTap(3),
                  theme: theme,
                ),
                _LegacyItem(
                  icon: Icons.person_outline_rounded,
                  isActive: currentIndex == 4,
                  onTap: () => onTap(4),
                  theme: theme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LegacyItem extends StatelessWidget {
  const _LegacyItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.theme,
  });

  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.colorScheme.onSurface.withValues(alpha: 0.4);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        height: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<Color?>(
              tween: ColorTween(
                begin: inactiveColor,
                end: isActive ? activeColor : inactiveColor,
              ),
              duration: const Duration(milliseconds: 300),
              builder: (context, color, child) {
                return Icon(icon, color: color, size: 28);
              },
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              width: 4,
              decoration: BoxDecoration(
                color: isActive ? activeColor : Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.8),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
