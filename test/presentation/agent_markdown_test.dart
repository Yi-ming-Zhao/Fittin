import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/presentation/widgets/agent_markdown.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';

void main() {
  test('only explicit web links can open', () {
    expect(
      AgentMarkdown.safeLink('https://example.com/plan')?.host,
      'example.com',
    );
    for (final link in [
      'javascript:alert(1)',
      'file:///secret',
      'intent://open',
      'data:text/html,bad',
      'https://user:pass@example.com',
      '/relative',
    ]) {
      expect(AgentMarkdown.safeLink(link), isNull);
    }
  });

  for (final width in [320.0, 390.0]) {
    testWidgets('Markdown is themed and bounded at $width', (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      for (final id in FittinPaletteRegistry.ids) {
        final theme = FittinPaletteRegistry.themeOf(id);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: AgentMarkdown(
                    theme: theme,
                    data: '''
## 训练计划 / Training

**重点**：保持控制，_充分休息_。

- 第一组 12 次
- 第二组 10 次

| 动作 Exercise | 组数 Sets | 次数 Reps |
| --- | --- | --- |
| 保加利亚分腿蹲 Bulgarian split squat | 3 | 12 |

> 修改前需要确认。

```json
{"very_long_key_that_must_scroll_without_breaking_the_phone_layout": "example"}
```

[说明](https://example.com) ![图片不自动加载](https://example.com/tracking.png)
''',
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        expect(
          tester.takeException(),
          isNull,
          reason: '${id.storageKey}/$width',
        );
        expect(find.byType(MarkdownBody), findsOneWidget);
        expect(find.byType(Image), findsNothing);
        final markdown = tester.widget<MarkdownBody>(find.byType(MarkdownBody));
        expect(markdown.styleSheet!.p!.color, theme.fg);
        expect(markdown.styleSheet!.code!.letterSpacing, 0);
        expect(markdown.selectable, true);
        expect(
          tester.getSize(find.byType(AgentMarkdown)).width,
          lessThanOrEqualTo(width - 40),
        );
      }
    });
  }
}
