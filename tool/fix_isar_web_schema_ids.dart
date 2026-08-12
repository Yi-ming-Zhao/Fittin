import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:xxh3/xxh3.dart';

const _maxSafeJsInteger = 9007199254740991;
final _schemaFiles =
    Directory('lib/src/data/models')
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.g.dart'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

final _collectionPattern = RegExp(
  r"(const\s+\w+\s*=\s*(?:CollectionSchema|Schema)\(\s*name: r'([^']+)',\s*id: )(-?\d{16,})",
  multiLine: true,
);
final _indexPattern = RegExp(
  r"((?:r'[^']+':\s+)?IndexSchema\(\s*id: )(-?\d{16,})(,\s*name: r'([^']+)',)",
  multiLine: true,
);

enum _Mode { exact, webSafe }

class _RewriteResult {
  const _RewriteResult(this.source, this.replacements);

  final String source;
  final int replacements;
}

int _exactIdForName(String name) {
  return xxh3(Uint8List.fromList(utf8.encode(name)));
}

int _targetIdForName(String name, _Mode mode) {
  final exact = _exactIdForName(name);
  if (mode == _Mode.exact || exact.abs() <= _maxSafeJsInteger) {
    return exact;
  }

  return exact.toDouble().toInt();
}

_RewriteResult _rewriteSchemaIds(String source, _Mode mode) {
  var replacements = 0;
  var updated = source.replaceAllMapped(_collectionPattern, (match) {
    final name = match.group(2)!;
    final current = int.parse(match.group(3)!);
    final target = _targetIdForName(name, mode);
    if (current != target) {
      replacements += 1;
    }
    return '${match.group(1)!}$target';
  });

  updated = updated.replaceAllMapped(_indexPattern, (match) {
    final name = match.group(4)!;
    final current = int.parse(match.group(2)!);
    final target = _targetIdForName(name, mode);
    if (current != target) {
      replacements += 1;
    }
    return '${match.group(1)!}$target${match.group(3)!}';
  });

  return _RewriteResult(updated, replacements);
}

void main(List<String> args) {
  final checkOnly = args.contains('--check');
  final mode = args.contains('--web-safe') ? _Mode.webSafe : _Mode.exact;
  final changedFiles = <String>[];
  var replacementCount = 0;

  for (final file in _schemaFiles) {
    final original = file.readAsStringSync();
    final result = _rewriteSchemaIds(original, mode);
    if (result.replacements == 0) {
      continue;
    }

    replacementCount += result.replacements;
    changedFiles.add(file.path);
    if (!checkOnly) {
      file.writeAsStringSync(result.source);
    }
  }

  final modeLabel = mode == _Mode.webSafe ? 'web-safe' : 'exact';

  if (checkOnly && changedFiles.isNotEmpty) {
    stderr.writeln(
      'Found $replacementCount generated Isar schema id literal(s) that do not '
      'match $modeLabel mode in:',
    );
    for (final path in changedFiles) {
      stderr.writeln(path);
    }
    exitCode = 1;
    return;
  }

  if (checkOnly) {
    stdout.writeln(
      'All generated Isar schema ids already match $modeLabel mode.',
    );
    return;
  }

  stdout.writeln(
    'Rewrote $replacementCount generated Isar schema id literal(s) in '
    '${changedFiles.length} file(s) for $modeLabel mode.',
  );
  for (final path in changedFiles) {
    stdout.writeln(path);
  }
}
