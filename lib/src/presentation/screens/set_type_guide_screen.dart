import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart' show FittinTheme;

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
    final fittinTheme = ref.watch(resolvedFittinThemeProvider);
    final guideAsync = ref.watch(_setTypeGuideProvider);

    return DashboardPageScaffold(
      bottomPadding: 100,
      children: [
        DashboardScreenHeader(
          eyebrow: strings.profile,
          title: strings.trainingSetGuide,
          showBackButton: true,
          subtitle: strings.trainingSetGuideSubtitle,
        ),
        const SizedBox(height: 24),
        guideAsync.when(
          data: (content) => DashboardSurfaceCard(
            radius: 32,
            padding: EdgeInsets.all(fittinTheme.pad),
            child: _MarkdownLikeContent(content: content, theme: fittinTheme),
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
  const _MarkdownLikeContent({required this.content, required this.theme});

  final String content;
  final FittinTheme theme;

  @override
  Widget build(BuildContext context) {
    final lines = content.split('\n');
    int entryCount = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final rawLine in lines)
          if (rawLine.trim().isEmpty)
            const SizedBox(height: 10)
          else if (rawLine.startsWith('## '))
            _buildEntry(entryCount += 1, rawLine.substring(3))
          else if (rawLine.startsWith('# '))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                rawLine.substring(2),
                style: theme.numStyle(28, theme.fg).copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            )
          else if (rawLine.startsWith('- '))
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 8, right: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.accent,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      rawLine.substring(2),
                      style: theme.uiStyle(15, theme.fg).copyWith(height: 1.45),
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                rawLine,
                style: theme.uiStyle(15, theme.fg).copyWith(
                  height: 1.5,
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildEntry(int number, String title) {
    final numStr = number.toString().padLeft(2, '0');
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$numStr.',
            style: theme.numStyle(20, theme.accent).copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: theme.uiStyle(18, theme.fg).copyWith(
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
