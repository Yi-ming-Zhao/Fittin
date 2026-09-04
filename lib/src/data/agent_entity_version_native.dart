import 'agent_local_repository.dart';
import 'models/body_metric_collection.dart';
import 'models/workout_log_collection.dart';
import 'models/template_collection.dart';
import 'models/instance_collection.dart';
import 'models/user_content_collection.dart';
import '../domain/models/user_content.dart';
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
    case 'custom_exercise':
    case 'custom_theme_palette':
      final kind = type == 'custom_exercise'
          ? UserContentKind.customExercise
          : UserContentKind.customThemePalette;
      final row = await db.userContentCollections.getByContentKey(
        '${kind.name}:$id',
      );
      return row == null
          ? 0
          : row.ownerUserId == owner && row.kindKey == kind.name
          ? row.version
          : null;
    default:
      return null;
  }
}
