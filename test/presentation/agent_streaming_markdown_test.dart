import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/presentation/widgets/agent_streaming_markdown.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';

void main() {
  test(
    'complete paragraphs split but fenced code and loose lists stay intact',
    () {
      expect(splitStreamingMarkdown('First\n\nSecond'), ['First', 'Second']);
      expect(splitStreamingMarkdown('```dart\nfirst\n\nsecond\n```\n\nTail'), [
        '```dart\nfirst\n\nsecond\n```',
        'Tail',
      ]);
      expect(splitStreamingMarkdown('- first\n\n- second\n\nTail'), [
        '- first\n\n- second',
        'Tail',
      ]);
      expect(splitStreamingMarkdown('```\nunfinished\n\ncode'), [
        '```\nunfinished\n\ncode',
      ]);
    },
  );
  testWidgets('streaming tail updates reuse completed block widgets', (
    tester,
  ) async {
    final theme = FittinPaletteRegistry.themeOf(
      FittinPaletteRegistry.decode(null),
    );
    Widget page(String data) => MaterialApp(
      home: Scaffold(
        body: AgentStreamingMarkdown(data: data, theme: theme, streaming: true),
      ),
    );
    await tester.pumpWidget(page('## Heading\n\nFirst part'));
    final before = tester.widget(
      find.byKey(const ValueKey('markdown-block-0')),
    );
    await tester.pumpWidget(page('## Heading\n\nFirst part and more'));
    expect(
      identical(
        before,
        tester.widget(find.byKey(const ValueKey('markdown-block-0'))),
      ),
      true,
    );
    expect(tester.takeException(), isNull);
  });
}
