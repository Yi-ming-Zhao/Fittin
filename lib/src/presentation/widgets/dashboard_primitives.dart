import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/application/ui_settings_provider.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:fittin_v2/src/presentation/widgets/fittin_primitives.dart';

class DashboardPageScaffold extends StatelessWidget {
  const DashboardPageScaffold({
    super.key,
    required this.children,
    this.bottomPadding = 24,
    this.topPadding = 54,
    this.floatingActionButton,
    this.extendBody = false,
    this.scrollable = true,
    this.safeAreaBottom = false,
  });

  final List<Widget> children;
  final double bottomPadding;
  final double topPadding;
  final Widget? floatingActionButton;
  final bool extendBody;
  final bool scrollable;
  final bool safeAreaBottom;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final fittinTheme = ref.watch(resolvedFittinThemeProvider);
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: floatingActionButton,
          extendBody: extendBody,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  fittinTheme.bgDeep,
                  fittinTheme.bg,
                  Color.lerp(fittinTheme.bg, Colors.black, 0.25)!,
                ],
              ),
            ),
            child: SafeArea(
              bottom: safeAreaBottom,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: scrollable
                      ? ListView(
                          padding: EdgeInsets.fromLTRB(
                            20,
                            topPadding,
                            20,
                            bottomPadding,
                          ),
                          children: children,
                        )
                      : Padding(
                          padding: EdgeInsets.fromLTRB(
                            20,
                            topPadding,
                            20,
                            bottomPadding,
                          ),
                          child: Column(children: children),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class DashboardScreenHeader extends StatelessWidget {
  const DashboardScreenHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showBackButton = false,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final theme = ref.watch(resolvedFittinThemeProvider);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showBackButton) ...[
              DashboardBackButton(theme: theme),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittinEyebrow(theme, eyebrow),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: theme
                        .displayStyle(32, theme.fg)
                        .copyWith(height: 0.98),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      subtitle!,
                      style: theme
                          .uiStyle(15, theme.fgDim)
                          .copyWith(height: 1.45),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 16), trailing!],
          ],
        );
      },
    );
  }
}

class DashboardBackButton extends StatelessWidget {
  const DashboardBackButton({
    super.key,
    required this.theme,
    this.label,
    this.onPressed,
  });

  final FittinTheme theme;
  final String? label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      key: const ValueKey('dashboard-header-back'),
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      style: TextButton.styleFrom(
        foregroundColor: theme.fgDim,
        padding: EdgeInsets.zero,
        minimumSize: const Size(40, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        alignment: Alignment.centerLeft,
      ),
      icon: Icon(Icons.chevron_left_rounded, size: 18, color: theme.fgDim),
      label: label == null
          ? const SizedBox.shrink()
          : Text(
              label!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.uiStyle(13, theme.fgDim, FontWeight.w500),
            ),
    );
  }
}

class DashboardSectionLabel extends StatelessWidget {
  const DashboardSectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final theme = ref.watch(resolvedFittinThemeProvider);
        return FittinEyebrow(theme, label);
      },
    );
  }
}

class DashboardSurfaceCard extends StatelessWidget {
  const DashboardSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius,
    this.onTap,
    this.highlight = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? radius;
  final VoidCallback? onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final content = Consumer(
      builder: (context, ref, _) {
        final theme = ref.watch(resolvedFittinThemeProvider);
        final glassOpacity = ref.watch(uiSettingsProvider);
        final cardRadius = radius ?? theme.radius;
        return ClipRRect(
          borderRadius: BorderRadius.circular(cardRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(cardRadius),
                color: highlight
                    ? theme.surface.withValues(
                        alpha: 0.6 * glassOpacity.clamp(0.35, 1.0),
                      )
                    : Colors.transparent,
                border: Border.all(
                  color: highlight ? theme.borderHi : theme.borderHi,
                  width: 0.75,
                ),
                boxShadow: const [],
              ),
              child: Padding(padding: padding, child: child),
            ),
          ),
        );
      },
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius ?? 20),
      child: content,
    );
  }
}

class DashboardStatCard extends StatelessWidget {
  const DashboardStatCard({
    super.key,
    required this.label,
    required this.value,
    this.caption,
    this.highlight = false,
    this.reserveCaptionSpace = false,
  });

  final String label;
  final String value;
  final String? caption;
  final bool highlight;
  final bool reserveCaptionSpace;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final theme = ref.watch(resolvedFittinThemeProvider);
        return DashboardSurfaceCard(
          radius: 24,
          highlight: highlight,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittinEyebrow(theme, label),
              const SizedBox(height: 12),
              Text(
                value,
                style: theme.numStyle(28, theme.fg).copyWith(height: 1),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 18,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: caption != null
                      ? Text(caption!, style: theme.uiStyle(12, theme.fgDim))
                      : (reserveCaptionSpace
                            ? const SizedBox.shrink()
                            : const SizedBox.shrink()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DashboardControlTile extends StatelessWidget {
  const DashboardControlTile({
    super.key,
    required this.label,
    required this.value,
    this.trailing,
    this.accent = false,
  });

  final String label;
  final String value;
  final Widget? trailing;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withValues(alpha: accent ? 0.1 : 0.05),
        border: Border.all(
          color: Colors.white.withValues(alpha: accent ? 0.14 : 0.06),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.48),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: accent
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}

class PremiumPrimaryButton extends StatelessWidget {
  const PremiumPrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.loading = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.24),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(62),
          backgroundColor: Color.lerp(
            theme.colorScheme.primary,
            Colors.white,
            0.16,
          ),
          foregroundColor: Colors.black,
          shape: const StadiumBorder(),
          textStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
        onPressed: loading ? null : onPressed,
        icon: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon ?? Icons.arrow_forward_rounded),
        label: Text(label),
      ),
    );
  }
}

class GlassActionButton extends StatelessWidget {
  const GlassActionButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.85),
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
