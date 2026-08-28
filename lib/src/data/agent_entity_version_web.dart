import 'agent_local_repository.dart';
import 'agent_local_repository_web.dart';
import 'web_local_store.dart';

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
    _ => null,
  };
  if (name == null) return null;
  final row = await repository.store.getRecord(name, id);
  if (row == null) return 0;
  if (row['ownerUserId'] != owner &&
      !((type == 'plan' || type == 'plan_revision') &&
          row['isBuiltIn'] == true)) {
    return null;
  }
  return row['version'] as int? ?? 0;
}
