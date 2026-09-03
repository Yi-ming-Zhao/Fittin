class WebStoreNames {
  static const appState = 'app_state';
  static const templates = 'templates';
  static const instances = 'instances';
  static const workoutLogs = 'workout_logs';
  static const bodyMetrics = 'body_metrics';
  static const progressPhotos = 'progress_photos';
  static const syncQueue = 'sync_queue';
  static const agentConversations = 'agent_conversations';
  static const agentActions = 'agent_actions';
  static const agentRuns = 'agent_runs';
  static const agentCheckpoints = 'agent_checkpoints';
  static const agentMemory = 'agent_memory';
  static const agentDiagnostics = 'agent_diagnostics';

  static const all = [
    appState,
    templates,
    instances,
    workoutLogs,
    bodyMetrics,
    progressPhotos,
    syncQueue,
    agentConversations,
    agentActions,
    agentRuns,
    agentCheckpoints,
    agentMemory,
    agentDiagnostics,
  ];
}

class WebLocalStoreOpenException implements Exception {
  const WebLocalStoreOpenException(this.message);

  final String message;

  @override
  String toString() => 'WebLocalStoreOpenException: $message';
}

class WebLocalStoreBlockedException extends WebLocalStoreOpenException {
  const WebLocalStoreBlockedException(super.message);
}

class WebLocalStoreInvalidatedException implements Exception {
  const WebLocalStoreInvalidatedException(this.message);

  final String message;

  @override
  String toString() => 'WebLocalStoreInvalidatedException: $message';
}

class WebStoreMutation {
  const WebStoreMutation.put(this.storeName, this.key, this.value)
    : isDelete = false;
  const WebStoreMutation.delete(this.storeName, this.key)
    : value = null,
      isDelete = true;

  final String storeName;
  final String key;
  final Map<String, dynamic>? value;
  final bool isDelete;
}

class WebLocalStore {
  static Future<WebLocalStore> open({
    String? databaseName,
    int databaseVersion = 3,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    throw UnsupportedError('WebLocalStore is only available on the web.');
  }

  void close() {}

  Future<Map<String, dynamic>?> getRecord(String storeName, String key) async {
    throw UnsupportedError('WebLocalStore is only available on the web.');
  }

  Future<List<Map<String, dynamic>>> getAllRecords(String storeName) async {
    throw UnsupportedError('WebLocalStore is only available on the web.');
  }

  Future<void> putRecord(
    String storeName,
    String key,
    Map<String, dynamic> value,
  ) async {
    throw UnsupportedError('WebLocalStore is only available on the web.');
  }

  Future<void> deleteRecord(String storeName, String key) async {
    throw UnsupportedError('WebLocalStore is only available on the web.');
  }

  Future<void> applyMutations(List<WebStoreMutation> mutations) async {
    throw UnsupportedError('WebLocalStore is only available on the web.');
  }

  Future<T> runInTransaction<T>(
    List<String> storeNames,
    Future<T> Function() operation,
  ) async {
    throw UnsupportedError('WebLocalStore is only available on the web.');
  }
}
