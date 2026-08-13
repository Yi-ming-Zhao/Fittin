import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/progress_repository.dart';
import 'package:fittin_v2/src/data/agent_local_repository.dart';

class LocalPersistenceBundle {
  const LocalPersistenceBundle({
    required this.databaseRepository,
    required this.progressRepository,
    required this.agentLocalRepository,
    this.webDatabaseRepository,
    this.webProgressRepository,
  });

  final DatabaseRepository databaseRepository;
  final ProgressRepository progressRepository;
  final AgentLocalRepository agentLocalRepository;
  final Object? webDatabaseRepository;
  final Object? webProgressRepository;
}
