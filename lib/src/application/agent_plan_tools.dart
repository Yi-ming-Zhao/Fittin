import 'dart:convert';

import '../domain/models/agent_models.dart';
import '../domain/models/training_plan.dart';

/// JSON values only; patches never evaluate code or access anything outside a
/// deep copy of one plan. The caller checks the read digest before applying.
Map<String, dynamic> applyAgentPlanEdits(
  PlanTemplate source,
  Object? rawEdits,
) {
  if (rawEdits is! List || rawEdits.isEmpty || rawEdits.length > 40) {
    throw const FormatException('edits must contain 1 to 40 operations.');
  }
  if (utf8.encode(jsonEncode(rawEdits)).length > 64 * 1024) {
    throw const FormatException('Edits are too large. Split the change.');
  }
  final root = jsonDecode(jsonEncode(source.toJson())) as Map<String, dynamic>;
  for (final raw in rawEdits) {
    if (raw is! Map) {
      throw const FormatException('Each edit must be an object.');
    }
    final op = raw['op'];
    final path = raw['path'];
    if (!{'add', 'replace', 'remove'}.contains(op) ||
        path is! String ||
        !path.startsWith('/') ||
        path.length > 1000) {
      throw const FormatException(
        'Use add, replace or remove with an absolute JSON-pointer path.',
      );
    }
    final parts = path.substring(1).split('/').map((p) {
      if (RegExp(r'~(?![01])').hasMatch(p)) {
        throw const FormatException('Invalid JSON-pointer escape.');
      }
      return p.replaceAll('~1', '/').replaceAll('~0', '~');
    }).toList();
    if (parts.length > 20 || parts.last == 'id') {
      throw const FormatException(
        'Keep existing stable IDs. Use a bounded path from get_plan.',
      );
    }
    if (op != 'remove' && !raw.containsKey('value')) {
      throw const FormatException('add and replace require a value.');
    }
    Object? parent = root;
    for (final part in parts.take(parts.length - 1)) {
      if (parent is Map && parent.containsKey(part)) {
        parent = parent[part];
      } else if (parent is List) {
        parent = parent[_index(part, parent.length)];
      } else {
        throw FormatException('Path not found: $path. Read get_plan again.');
      }
    }
    final key = parts.last;
    if (parent is List) {
      final index = key == '-' && op == 'add'
          ? parent.length
          : _index(key, parent.length, allowEnd: op == 'add');
      if (op == 'add') {
        parent.insert(index, raw['value']);
      } else if (op == 'remove') {
        parent.removeAt(index);
      } else {
        parent[index] = raw['value'];
      }
    } else if (parent is Map) {
      final extensible =
          parts.length > 1 &&
          {
            'localizedName',
            'localizedDescription',
            'localizedDayLabel',
            'engineConfig',
          }.contains(parts[parts.length - 2]);
      if (!parent.containsKey(key) && !(op == 'add' && extensible)) {
        throw FormatException('Path not found: $path. Read get_plan again.');
      }
      if (op == 'remove') {
        parent.remove(key);
      } else {
        parent[key] = raw['value'];
      }
    } else {
      throw FormatException('Path not found: $path. Read get_plan again.');
    }
  }
  return root;
}

int _index(String part, int length, {bool allowEnd = false}) {
  final index = RegExp(r'^(0|[1-9][0-9]*)$').hasMatch(part)
      ? int.tryParse(part)
      : null;
  if (index == null || index < 0 || index >= length + (allowEnd ? 1 : 0)) {
    throw const FormatException(
      'Array index is invalid. Use the paths from get_plan.',
    );
  }
  return index;
}

List<AgentMutationChange> agentPlanDifferences(
  PlanTemplate before,
  PlanTemplate after, {
  required bool chinese,
}) {
  final changes = <AgentMutationChange>[];
  void visit(Object? a, Object? b, String path) {
    if (agentPayloadDigest(a) == agentPayloadDigest(b)) return;
    if (changes.length >= 200) {
      throw const FormatException(
        'Too many changed fields. Split this plan revision into smaller edits.',
      );
    }
    if (a is Map && b is Map) {
      for (final key in {...a.keys, ...b.keys}) {
        final container = {
          'phases',
          'workouts',
          'exercises',
          'stages',
        }.contains(key);
        final label = chinese ? (_planFieldLabels[key] ?? '$key') : '$key';
        visit(
          a[key],
          b[key],
          container
              ? path
              : path.isEmpty
              ? label
              : '$path / $label',
        );
      }
    } else if (a is List && b is List) {
      final count = a.length > b.length ? a.length : b.length;
      for (var i = 0; i < count; i++) {
        final old = i < a.length ? a[i] : null;
        final next = i < b.length ? b[i] : null;
        final item = old is Map
            ? old
            : next is Map
            ? next
            : null;
        final label = item?['name'] ?? '#${i + 1}';
        visit(old, next, path.isEmpty ? '$label' : '$path / $label');
      }
    } else {
      String display(Object? value) => value == null
          ? (chinese ? '无' : 'None')
          : value is String
          ? value
          : jsonEncode(value);
      changes.add(
        AgentMutationChange(path: path, before: display(a), after: display(b)),
      );
    }
  }

  // Normalize nested Freezed objects before traversing the actual field diff.
  visit(
    jsonDecode(jsonEncode(before.toJson())),
    jsonDecode(jsonEncode(after.toJson())),
    '',
  );
  if (changes.isEmpty) throw const FormatException('No plan fields changed.');
  return changes;
}

const _planFieldLabels = {
  'name': '名称',
  'description': '说明',
  'sets': '训练组',
  'rules': '进阶规则',
  'targetReps': '目标次数',
  'intensity': '强度比例',
  'restSeconds': '组间休息（秒）',
  'initialBaseWeight': '起始重量',
  'targetRpe': '目标 RPE',
  'isAmrap': '力竭组',
  'basePercent': '基础比例',
  'localizedName': '多语言名称',
  'localizedDescription': '多语言说明',
  'dayLabel': '训练日标签',
  'estimatedDurationMinutes': '预计时长（分钟）',
  'exerciseId': '动作类型',
  'loadUnit': '重量单位',
  'equipmentType': '器械类型',
  'roundingIncrement': '重量步长',
  'setType': '组类型',
  'kind': '训练组分类',
};

/// The minimum complete schema is explicit so providers do not invent a
/// workouts-at-root plan that cannot be decoded by Fittin.
const agentPlanSchema = <String, dynamic>{
  'type': 'object',
  'description':
      'Full Fittin PlanTemplate. For revisions prefer edits. Preserve all existing fields. Nest phases -> workouts -> exercises -> stages -> sets/rules.',
  'required': ['id', 'name', 'description', 'phases'],
  'properties': {
    'id': {'type': 'string'},
    'name': {'type': 'string'},
    'description': {'type': 'string'},
    'engineFamily': {'type': 'string'},
    'scheduleMode': {
      'type': 'string',
      'enum': ['legacy', 'linear', 'periodized'],
    },
    'phases': {
      'type': 'array',
      'minItems': 1,
      'items': {
        'type': 'object',
        'required': ['id', 'name', 'workouts'],
        'properties': {
          'id': {'type': 'string'},
          'name': {'type': 'string'},
          'workouts': {
            'type': 'array',
            'minItems': 1,
            'items': {
              'type': 'object',
              'required': ['id', 'name', 'exercises'],
              'properties': {
                'id': {'type': 'string'},
                'name': {'type': 'string'},
                'exercises': {
                  'type': 'array',
                  'minItems': 1,
                  'items': {
                    'type': 'object',
                    'required': ['id', 'exerciseId', 'name', 'stages'],
                    'properties': {
                      'id': {'type': 'string'},
                      'exerciseId': {'type': 'string'},
                      'name': {'type': 'string'},
                      'initialBaseWeight': {'type': 'number', 'minimum': 0},
                      'restSeconds': {'type': 'integer', 'minimum': 0},
                      'stages': {
                        'type': 'array',
                        'minItems': 1,
                        'items': {
                          'type': 'object',
                          'required': ['id', 'name', 'sets', 'rules'],
                          'properties': {
                            'id': {'type': 'string'},
                            'name': {'type': 'string'},
                            'rules': {
                              'type': 'array',
                              'items': {'type': 'object'},
                            },
                            'sets': {
                              'type': 'array',
                              'minItems': 1,
                              'items': {
                                'type': 'object',
                                'required': ['targetReps', 'intensity'],
                                'properties': {
                                  'targetReps': {
                                    'type': 'integer',
                                    'minimum': 1,
                                  },
                                  'intensity': {'type': 'number', 'minimum': 0},
                                  'isAmrap': {'type': 'boolean'},
                                  'kind': {
                                    'type': 'string',
                                    'enum': ['working', 'warmup'],
                                  },
                                },
                              },
                            },
                          },
                        },
                      },
                    },
                  },
                },
              },
            },
          },
        },
      },
    },
  },
};
