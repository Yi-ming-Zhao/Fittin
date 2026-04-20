import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
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
    return Consumer(
      builder: (context, ref, _) {
        final theme = ref.watch(resolvedFittinThemeProvider);
        return DashboardSurfaceCard(
          padding: EdgeInsets.all(theme.pad),
          radius: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashboardSectionLabel(label: title!),
                    if (headerAction != null) ...[
                      const SizedBox(height: 12),
                      headerAction!,
                    ],
                  ],
                ),
                const SizedBox(height: 18),
              ],
              SizedBox(height: height, width: double.infinity, child: child),
            ],
          ),
        );
      },
    );
  }
}
