import 'dart:async';

import 'package:fittin_v2/src/data/agent_local_repository.dart';
import 'package:fittin_v2/src/data/agent_transaction_context.dart';

class AgentBusinessTransaction {
  const AgentBusinessTransaction(this.repository);

  final AgentLocalRepository repository;

  Future<T> run<T>(Future<T> Function() operation) {
    if (Zone.current[agentTransactionZoneKey] == true) return operation();
    final local = repository;
    if (local is IsarAgentLocalRepository) {
      return local.isar.writeTxn(
        () => runZoned(operation, zoneValues: {agentTransactionZoneKey: true}),
      );
    }
    return operation();
  }
}
