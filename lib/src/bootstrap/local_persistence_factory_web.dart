import 'package:fittin_v2/src/bootstrap/local_persistence_bundle.dart';
import 'package:fittin_v2/src/data/web_database_repository.dart';
import 'package:fittin_v2/src/data/web_local_store.dart';
import 'package:fittin_v2/src/data/web_progress_repository.dart';

Future<LocalPersistenceBundle> createLocalPersistence() async {
  final store = await WebLocalStore.open();
  final databaseRepository = WebDatabaseRepository(store);
  final progressRepository = WebProgressRepository(store);
  return LocalPersistenceBundle(
    databaseRepository: databaseRepository,
    progressRepository: progressRepository,
    webDatabaseRepository: databaseRepository,
    webProgressRepository: progressRepository,
  );
}
