import 'package:fittin_v2/src/data/agent_local_repository.dart';
import 'package:fittin_v2/src/data/agent_local_repository_web.dart';
import 'package:fittin_v2/src/data/web_local_store.dart';

class AgentBusinessTransaction {
  const AgentBusinessTransaction(this.repository);

  final AgentLocalRepository repository;

  Future<T> run<T>(Future<T> Function() operation) {
    final local = repository;
    if (local is WebAgentLocalRepository) {
      return local.store.runInTransaction(WebStoreNames.all, operation);
    }
    return operation();
  }
}
