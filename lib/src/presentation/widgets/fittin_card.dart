import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';

/// Fittin design system Card — glass / flat / bordered variants
class FittinCard extends StatelessWidget {
  const FittinCard({
    super.key,
    required this.theme,
    required this.child,
    this.style = FittinCardStyle.glass,
    this.padding,
    this.noPad = false,
    this.onTap,
  });

  final FittinTheme theme;
  final Widget child;
  final FittinCardStyle style;
  final double? padding;
  final bool noPad;
  final VoidCallback? onTap;

  double get _pad => noPad ? 0 : (padding ?? theme.pad);

  @override
  Widget build(BuildContext context) {
    final content = Builder(
      builder: (context) {
        if (style == FittinCardStyle.glass) {
          return _GlassCard(theme: theme, padding: _pad, child: child);
        }
        if (style == FittinCardStyle.flat) {
          return _FlatCard(theme: theme, padding: _pad, child: child);
        }
        return _BorderedCard(theme: theme, padding: _pad, child: child);
      },
    );

    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(theme.radius),
      child: content,
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.theme,
    required this.padding,
    required this.child,
  });

  final FittinTheme theme;
  final double padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(theme.radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(theme.radius),
            border: Border.all(color: theme.border, width: 0.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 0,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _FlatCard extends StatelessWidget {
  const _FlatCard({
    required this.theme,
    required this.padding,
    required this.child,
  });

  final FittinTheme theme;
  final double padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: theme.surfaceSolid,
        borderRadius: BorderRadius.circular(theme.radius),
      ),
      child: child,
    );
  }
}

class _BorderedCard extends StatelessWidget {
  const _BorderedCard({
    required this.theme,
    required this.padding,
    required this.child,
  });

  final FittinTheme theme;
  final double padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(theme.radius),
        border: Border.all(color: theme.borderHi, width: 0.75),
      ),
      child: child,
    );
  }
}
