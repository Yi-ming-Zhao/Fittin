import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/progress_repository.dart';

class LocalPersistenceBundle {
  const LocalPersistenceBundle({
    required this.databaseRepository,
    required this.progressRepository,
    this.webDatabaseRepository,
    this.webProgressRepository,
  });

  final DatabaseRepository databaseRepository;
  final ProgressRepository progressRepository;
  final Object? webDatabaseRepository;
  final Object? webProgressRepository;
}
