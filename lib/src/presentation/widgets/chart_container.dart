import 'package:flutter/material.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';
 
class ChartContainer extends StatelessWidget {
  const ChartContainer({
    super.key,
    required this.child,
    this.title,
    this.height = 240,
    this.headerAction,
  });
 
  final Widget child;
  final String? title;
  final double height;
  final Widget? headerAction;
 
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
 
    return DashboardSurfaceCard(
      padding: const EdgeInsets.all(20),
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title!.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (headerAction != null) headerAction!,
              ],
            ),
            const SizedBox(height: 20),
          ],
          SizedBox(height: height, width: double.infinity, child: child),
        ],
      ),
    );
  }
}
