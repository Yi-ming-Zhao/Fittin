import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';

/// Fittin bottom tab bar — 5 tabs with glass background
/// Tabs: Today, Plans, Progress, Body, Profile
class FittinTabBar extends StatelessWidget {
  const FittinTabBar({
    super.key,
    required this.theme,
    required this.active,
    required this.onChange,
  });

  final FittinTheme theme;
  final String active; // 'home' | 'plans' | 'progress' | 'body' | 'profile'
  final ValueChanged<String> onChange;

  static const _tabs = [
    ('home', 'Today'),
    ('plans', 'Plans'),
    ('progress', 'Progress'),
    ('body', 'Body'),
    ('profile', 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 34),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: theme.border, width: 0.5),
            ),
            child: Row(
              children: _tabs.map((t) {
                final isActive = t.$1 == active;
                return Expanded(
                  child: _FittinTabItem(
                    theme: theme,
                    label: t.$2,
                    isActive: isActive,
                    onTap: () => onChange(t.$1),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _FittinTabItem extends StatelessWidget {
  const _FittinTabItem({
    required this.theme,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final FittinTheme theme;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? theme.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.uiStyle(
              11,
              isActive ? theme.accentInk : theme.fgDim,
            ).copyWith(
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
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
      return _LegacyNav(
        currentIndex: currentIndex,
        onTap: onTap,
      );
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
  const _LegacyNav({
    required this.currentIndex,
    required this.onTap,
  });

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
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
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
