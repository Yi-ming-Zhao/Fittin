import 'package:flutter/material.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';

/// Eyebrow label — 10px, uppercase, letter-spacing 1.8, fgMuted
class FittinEyebrow extends StatelessWidget {
  const FittinEyebrow(this.theme, this.text, {super.key, this.style});

  final FittinTheme theme;
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: theme.eyebrowStyle().merge(style),
    );
  }
}

/// Section title — display font, variable size, tight letter-spacing
class FittinSectionTitle extends StatelessWidget {
  const FittinSectionTitle(
    this.theme,
    this.text, {
    super.key,
    this.fontSize,
    this.style,
    this.letterSpacing,
  });

  final FittinTheme theme;
  final String text;
  final double? fontSize;
  final TextStyle? style;
  final double? letterSpacing;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: theme.displayStyle(fontSize ?? theme.titleSize, null).merge(style),
    );
  }
}

/// Big number display with optional unit suffix
class FittinBigNum extends StatelessWidget {
  const FittinBigNum(
    this.theme,
    this.value, {
    super.key,
    this.size = 40,
    this.unit,
    this.color,
    this.style,
  });

  final FittinTheme theme;
  final String value;
  final double size;
  final String? unit;
  final Color? color;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: value,
            style: theme
                .numStyle(size, color)
                .copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                )
                .merge(style),
          ),
          if (unit != null)
            TextSpan(
              text: ' $unit',
              style: theme.uiStyle(size * 0.38, theme.fgDim),
            ),
        ],
      ),
    );
  }
}

/// Delta chip — ▲/▼ with sign and unit
class FittinDelta extends StatelessWidget {
  const FittinDelta(
    this.theme,
    this.value, {
    super.key,
    this.unit = '',
  });

  final FittinTheme theme;
  final double value;
  final String unit;

  bool get _positive => value > 0;
  String get _sign => _positive ? '+' : '';

  @override
  Widget build(BuildContext context) {
    final color = _positive ? theme.accent : theme.fgDim;
    final formattedValue = value.abs().toStringAsFixed(1);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _positive ? Icons.arrow_upward : Icons.arrow_downward,
          size: 11,
          color: color.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 4),
        Text(
          '$_sign$formattedValue$unit',
          style: theme.uiStyle(11, color).copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

/// Chip / pill tag
class FittinChip extends StatelessWidget {
  const FittinChip(
    this.theme,
    this.label, {
    super.key,
    this.active = false,
    this.onTap,
  });

  final FittinTheme theme;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? theme.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: active ? null : Border.all(color: theme.border, width: 0.5),
        ),
        child: Text(
          label,
          style: theme.uiStyle(12, active ? theme.accentInk : theme.fgDim)
              .copyWith(fontWeight: FontWeight.w500, letterSpacing: 0.1),
        ),
      ),
    );
  }
}

/// Segmented control — glass pill with active/inactive segments
class FittinSegmented extends StatelessWidget {
  const FittinSegmented({
    super.key,
    required this.theme,
    required this.options,
    required this.value,
    required this.onChange,
  });

  final FittinTheme theme;
  final List<String> options;
  final String value;
  final ValueChanged<String> onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: theme.surfaceHi,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((o) {
          final active = o == value;
          return GestureDetector(
            onTap: () => onChange(o),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: active ? theme.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                o,
                style: theme
                    .uiStyle(12, active ? theme.accentInk : theme.fgDim)
                    .copyWith(fontWeight: FontWeight.w500, letterSpacing: 0.2),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Button variants: primary (accent fill), secondary (surfaceHi), ghost
class FittinBtn extends StatelessWidget {
  const FittinBtn(
    this.theme,
    this.label, {
    super.key,
    this.variant = 'primary',
    this.size = 'md',
    this.onPressed,
    this.icon,
    this.block = false,
  });

  final FittinTheme theme;
  final String label;
  final String variant; // 'primary' | 'secondary' | 'ghost'
  final String size; // 'sm' | 'md'
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool block;

  EdgeInsets get _pad =>
      size == 'sm' ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8) : const EdgeInsets.symmetric(horizontal: 20, vertical: 12);

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == 'primary';
    final isGhost = variant == 'ghost';

    Color bg;
    Color fg;
    BorderSide? border;

    if (isPrimary) {
      bg = theme.accent;
      fg = theme.accentInk;
    } else if (isGhost) {
      bg = Colors.transparent;
      fg = theme.fg;
    } else {
      bg = theme.surfaceHi;
      fg = theme.fg;
      border = BorderSide(color: theme.borderHi, width: 0.5);
    }

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: _pad,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: border != null ? Border.fromBorderSide(border) : null,
        ),
        child: Row(
          mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: size == 'sm' ? 12 : 14, color: fg),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme
                    .uiStyle(size == 'sm' ? 12 : 14, fg)
                    .copyWith(fontWeight: FontWeight.w500, letterSpacing: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thin horizontal divider
class FittinDivider extends StatelessWidget {
  const FittinDivider(this.theme, {super.key, this.style});

  final FittinTheme theme;
  final BoxConstraints? style;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      color: theme.border,
    );
  }
}
