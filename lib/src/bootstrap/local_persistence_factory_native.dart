import 'package:fittin_v2/src/bootstrap/local_persistence_bundle.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/models/app_state_collection.dart';
import 'package:fittin_v2/src/data/models/body_metric_collection.dart';
import 'package:fittin_v2/src/data/models/instance_collection.dart';
import 'package:fittin_v2/src/data/models/sync_queue_collection.dart';
import 'package:fittin_v2/src/data/models/template_collection.dart';
import 'package:fittin_v2/src/data/models/workout_log_collection.dart';
import 'package:fittin_v2/src/data/progress_repository.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

Future<LocalPersistenceBundle> createLocalPersistence() async {
  const schemas = [
    AppStateCollectionSchema,
    TemplateCollectionSchema,
    InstanceCollectionSchema,
    WorkoutLogCollectionSchema,
    BodyMetricCollectionSchema,
    ProgressPhotoCollectionSchema,
    SyncQueueCollectionSchema,
  ];

  final appDirectory = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(schemas, directory: appDirectory.path);
  return LocalPersistenceBundle(
    databaseRepository: DatabaseRepository(isar),
    progressRepository: ProgressRepository(isar),
  );
}
