import 'agent_local_repository.dart';
import 'agent_local_repository_web.dart';
import 'web_local_store.dart';
import '../domain/models/user_content.dart';

Future<int?> agentEntityVersion(
  AgentLocalRepository repository,
  String type,
  String id,
  String? owner,
) async {
  if (repository is! WebAgentLocalRepository) return null;
  final name = switch (type) {
    'plan' || 'plan_revision' => WebStoreNames.templates,
    'instance' => WebStoreNames.instances,
    'workout_log' => WebStoreNames.workoutLogs,
    'body_metric' => WebStoreNames.bodyMetrics,
    'custom_exercise' || 'custom_theme_palette' => WebStoreNames.userContent,
    _ => null,
  };
  if (name == null) return null;
  final kind = switch (type) {
    'custom_exercise' => UserContentKind.customExercise,
    'custom_theme_palette' => UserContentKind.customThemePalette,
    _ => null,
  };
  final key = kind == null ? id : '${kind.name}:$id';
  final row = await repository.store.getRecord(name, key);
  if (row == null) return 0;
  if (kind != null && row['kindKey'] != kind.name) return null;
  if (row['ownerUserId'] != owner &&
      !((type == 'plan' || type == 'plan_revision') &&
          row['isBuiltIn'] == true)) {
    return null;
  }
  return row['version'] as int? ?? 0;
}
