import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';

final _setTypeGuideProvider = FutureProvider<String>((ref) async {
  final locale = ref.watch(appLocaleProvider);
  final assetPath = locale == AppLocale.zh
      ? 'assets/guides/set_types_zh.md'
      : 'assets/guides/set_types_en.md';
  return rootBundle.loadString(assetPath);
});

class SetTypeGuideScreen extends ConsumerWidget {
  const SetTypeGuideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context, ref);
    final guideAsync = ref.watch(_setTypeGuideProvider);

    return DashboardPageScaffold(
      bottomPadding: 100,
      children: [
        DashboardScreenHeader(
          eyebrow: strings.profile,
          title: strings.trainingSetGuide,
          subtitle: strings.trainingSetGuideSubtitle,
        ),
        const SizedBox(height: 24),
        guideAsync.when(
          data: (content) => DashboardSurfaceCard(
            radius: 32,
            child: _MarkdownLikeContent(content: content),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => DashboardSurfaceCard(
            radius: 32,
            child: Text(error.toString()),
          ),
        ),
      ],
    );
  }
}

class _MarkdownLikeContent extends StatelessWidget {
  const _MarkdownLikeContent({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lines = content.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final rawLine in lines)
          if (rawLine.trim().isEmpty)
            const SizedBox(height: 10)
          else if (rawLine.startsWith('## '))
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 8),
              child: Text(
                rawLine.substring(3),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          else if (rawLine.startsWith('# '))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                rawLine.substring(2),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            )
          else if (rawLine.startsWith('- '))
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                '• ${rawLine.substring(2)}',
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                rawLine,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                  height: 1.5,
                ),
              ),
            ),
      ],
    );
  }
}
