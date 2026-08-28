import 'dart:convert';
import '../domain/models/agent_models.dart';

/// The preview is computed from exactly the trusted snapshots being committed.
abstract final class AgentMutationDiff {
  static List<AgentMutationChange> between(
    Object? before,
    Object? after, {
    bool chinese = false,
  }) {
    final changes = <AgentMutationChange>[];
    final labels = chinese
        ? const <String, String>{
            'completedAt': '完成时间',
            'timestamp': '测量时间',
            'weightKg': '体重（kg）',
            'bodyFatPercent': '体脂率（%）',
            'waistCm': '腰围（cm）',
            'note': '备注',
            'phases': '阶段',
            'workouts': '训练日',
            'exercises': '动作',
            'sets': '组',
            'stages': '方案',
            'name': '名称',
            'exerciseName': '动作名称',
            'completedReps': '完成次数',
            'weight': '重量（kg）',
            'completedRpe': 'RPE',
            'isSkipped': '跳过',
            'isCompleted': '完成',
            'targetReps': '目标次数',
            'restSeconds': '组间休息（秒）',
          }
        : const <String, String>{};
    String display(Object? value) =>
        value == null ? (chinese ? '未设置' : 'Not set') : value.toString();
    void visit(Object? a, Object? b, String path) {
      if (canonicalJson(a) == canonicalJson(b)) return;
      if (a is Map || b is Map) {
        final left = a is Map ? a : const {};
        final right = b is Map ? b : const {};
        for (final key in {...left.keys, ...right.keys}) {
          if (key == 'preConclusionSnapshot' ||
              key == 'postConclusionSnapshot') {
            continue;
          }
          visit(
            left[key],
            right[key],
            [
              path,
              labels[key] ?? '$key',
            ].where((v) => v.isNotEmpty).join(' / '),
          );
        }
      } else if (a is List || b is List) {
        final left = a is List ? a : const [];
        final right = b is List ? b : const [];
        final count = left.length > right.length ? left.length : right.length;
        for (var i = 0; i < count; i++) {
          final item = i < right.length ? right[i] : left[i];
          final name = item is Map
              ? item['name'] ?? item['exerciseName']
              : null;
          visit(
            i < left.length ? left[i] : null,
            i < right.length ? right[i] : null,
            '$path ${i + 1}${name is String && name.isNotEmpty ? '（$name）' : ''}',
          );
        }
      } else {
        changes.add(
          AgentMutationChange(
            path: path,
            before: display(a),
            after: display(b),
          ),
        );
      }
    }

    visit(jsonDecode(jsonEncode(before)), jsonDecode(jsonEncode(after)), '');
    return changes;
  }
}
