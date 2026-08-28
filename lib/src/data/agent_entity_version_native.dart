import 'agent_local_repository.dart';
import 'models/body_metric_collection.dart';
import 'models/workout_log_collection.dart';
import 'models/template_collection.dart';
import 'models/instance_collection.dart';
import 'package:isar/isar.dart';

Future<int?> agentEntityVersion(
  AgentLocalRepository repository,
  String type,
  String id,
  String? owner,
) async {
  if (repository is! IsarAgentLocalRepository) return null;
  final db = repository.isar;
  switch (type) {
    case 'plan':
    case 'plan_revision':
      final row = await db.templateCollections.getByTemplateId(id);
      return row == null
          ? 0
          : row.ownerUserId == owner || row.isBuiltIn
          ? row.version
          : null;
    case 'instance':
      final row = await db.instanceCollections.getByInstanceId(id);
      return row == null
          ? 0
          : row.ownerUserId == owner
          ? row.version
          : null;
    case 'workout_log':
      final row = await db.workoutLogCollections.getByLogId(id);
      return row == null
          ? 0
          : row.ownerUserId == owner
          ? row.version
          : null;
    case 'body_metric':
      final row = await db.bodyMetricCollections
          .filter()
          .metricIdEqualTo(id)
          .findFirst();
      return row == null
          ? 0
          : row.ownerUserId == owner
          ? row.version
          : null;
    default:
      return null;
  }
}
