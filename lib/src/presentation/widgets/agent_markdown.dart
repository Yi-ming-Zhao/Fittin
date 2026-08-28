import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/fittin_theme.dart';

/// Model output is untrusted: never fetch images or allow local/custom schemes.
class AgentMarkdown extends StatelessWidget {
  const AgentMarkdown({super.key, required this.data, required this.theme});

  final String data;
  final FittinTheme theme;

  static Uri? safeLink(String? href) {
    final uri = href == null ? null : Uri.tryParse(href);
    if (uri == null ||
        !{'https', 'http'}.contains(uri.scheme) ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      return null;
    }
    return uri;
  }

  @override
  Widget build(BuildContext context) {
    final body = theme.uiStyle(14, theme.fg).copyWith(height: 1.55);
    return MarkdownBody(
      data: data,
      selectable: true,
      softLineBreak: true,
      onTapLink: (_, href, _) async {
        final uri = safeLink(href);
        if (uri != null) {
          try {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (_) {
            /* Leave text readable if no handler exists. */
          }
        }
      },
      imageBuilder: (_, _, alt) =>
          Text(alt ?? '', style: body.copyWith(color: theme.fgDim)),
      styleSheet: MarkdownStyleSheet(
        p: body,
        h1: theme.uiStyle(23, theme.fg, FontWeight.w700).copyWith(height: 1.3),
        h2: theme.uiStyle(20, theme.fg, FontWeight.w700).copyWith(height: 1.35),
        h3: theme.uiStyle(17, theme.fg, FontWeight.w700).copyWith(height: 1.4),
        h4: body.copyWith(fontWeight: FontWeight.w700),
        h5: body.copyWith(fontWeight: FontWeight.w700),
        h6: body.copyWith(fontWeight: FontWeight.w700),
        strong: body.copyWith(fontWeight: FontWeight.w700),
        em: body.copyWith(fontStyle: FontStyle.italic),
        a: body.copyWith(
          color: theme.accent,
          decoration: TextDecoration.underline,
        ),
        listBullet: body.copyWith(color: theme.fgDim),
        listIndent: 22,
        blockSpacing: 12,
        blockquote: body.copyWith(color: theme.fgDim),
        blockquotePadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(left: BorderSide(color: theme.accent, width: 2)),
        ),
        code: theme
            .uiStyle(12, theme.fg)
            .copyWith(
              fontFamily: 'monospace',
              letterSpacing: 0,
              height: 1.5,
              backgroundColor: theme.surface,
            ),
        codeblockPadding: const EdgeInsets.all(12),
        codeblockDecoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        tableHead: body.copyWith(fontSize: 12, fontWeight: FontWeight.w700),
        tableBody: body.copyWith(fontSize: 12),
        tableBorder: TableBorder.all(color: theme.border, width: 0.75),
        tableCellsPadding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 9,
        ),
        tableColumnWidth: const FlexColumnWidth(),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(top: BorderSide(color: theme.border)),
        ),
      ),
    );
  }
}
