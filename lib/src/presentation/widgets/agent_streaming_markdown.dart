import 'package:flutter/material.dart';
import '../theme/fittin_theme.dart';
import 'agent_markdown.dart';

/// Freeze complete Markdown blocks, leaving only the unfinished tail mutable.
/// Fenced code and loose lists remain intact across their internal blank lines.
List<String> splitStreamingMarkdown(String data) {
  final lines = data.split('\n');
  final blocks = <String>[];
  final current = <String>[];
  String? fence;
  var fenceLength = 0;
  var listBlock = false;
  final fencePattern = RegExp(r'^ {0,3}(`{3,}|~{3,})');
  final listPattern = RegExp(r'^\s*(?:[-+*]|\d+[.)])\s');
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final marker = fencePattern.firstMatch(line)?.group(1);
    if (marker != null) {
      if (fence == null) {
        fence = marker[0];
        fenceLength = marker.length;
      } else if (marker[0] == fence &&
          marker.length >= fenceLength &&
          line.trim() == marker) {
        fence = null;
      }
    }
    listBlock = listBlock || listPattern.hasMatch(line);
    final next = i + 1 < lines.length ? lines[i + 1] : '';
    final continuesList =
        listBlock &&
        (listPattern.hasMatch(next) ||
            next.startsWith(' ') ||
            next.startsWith('\t'));
    if (line.isEmpty &&
        i < lines.length - 1 &&
        fence == null &&
        !continuesList &&
        current.isNotEmpty) {
      blocks.add(current.join('\n'));
      current.clear();
      listBlock = false;
    } else {
      current.add(line);
    }
  }
  blocks.add(current.join('\n'));
  return blocks;
}

class AgentStreamingMarkdown extends StatefulWidget {
  const AgentStreamingMarkdown({
    super.key,
    required this.data,
    required this.theme,
    required this.streaming,
  });
  final String data;
  final FittinTheme theme;
  final bool streaming;
  @override
  State<AgentStreamingMarkdown> createState() => _AgentStreamingMarkdownState();
}

class _AgentStreamingMarkdownState extends State<AgentStreamingMarkdown> {
  List<String> _blocks = [];
  List<Widget> _widgets = [];
  @override
  void initState() {
    super.initState();
    _update();
  }

  @override
  void didUpdateWidget(AgentStreamingMarkdown old) {
    super.didUpdateWidget(old);
    if (!identical(old.theme, widget.theme)) {
      _blocks = [];
      _widgets = [];
    }
    if (old.data != widget.data ||
        old.streaming != widget.streaming ||
        !identical(old.theme, widget.theme)) {
      _update();
    }
  }

  void _update() {
    // Final text is parsed as a whole once, including cross-block references.
    final next = widget.streaming
        ? splitStreamingMarkdown(widget.data)
        : [widget.data];
    final widgets = <Widget>[];
    for (var i = 0; i < next.length; i++) {
      widgets.add(
        i < _blocks.length && next[i] == _blocks[i]
            ? _widgets[i]
            : RepaintBoundary(
                key: ValueKey('markdown-block-$i'),
                child: AgentMarkdown(data: next[i], theme: widget.theme),
              ),
      );
    }
    _blocks = next;
    _widgets = widgets;
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < _widgets.length; i++) ...[
        if (i > 0 && _blocks[i].isNotEmpty) const SizedBox(height: 12),
        _widgets[i],
      ],
    ],
  );
}
