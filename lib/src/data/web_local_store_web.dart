import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

final Object _transactionZoneKey = Object();

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
  WebLocalStore._(this._database);

  static const _databaseName = 'fittin_v2_web_store';
  static const _databaseVersion = 3;
  static Future<WebLocalStore>? _instance;

  final web.IDBDatabase _database;

  static Future<WebLocalStore> open({String? databaseName}) {
    if (databaseName != null) return _openInternal(databaseName);
    return _instance ??= _openInternal();
  }

  void close() => _database.close();

  static Future<WebLocalStore> _openInternal([String? databaseName]) async {
    final request = web.window.indexedDB.open(
      databaseName ?? _databaseName,
      _databaseVersion,
    );
    final completer = Completer<web.IDBDatabase>();

    request.onupgradeneeded = ((web.Event _) {
      final database = request.result as web.IDBDatabase;
      for (final storeName in WebStoreNames.all) {
        if (!database.objectStoreNames.contains(storeName)) {
          database.createObjectStore(storeName);
        }
      }
    }).toJS;

    request.onsuccess = ((web.Event _) {
      completer.complete(request.result as web.IDBDatabase);
    }).toJS;

    request.onerror = ((web.Event _) {
      completer.completeError(
        request.error ?? StateError('Failed to open IndexedDB.'),
      );
    }).toJS;

    return WebLocalStore._(await completer.future);
  }

  Future<Map<String, dynamic>?> getRecord(String storeName, String key) async {
    final active = Zone.current[_transactionZoneKey] as web.IDBTransaction?;
    if (active != null) {
      final result = await _requestResult(
        active.objectStore(storeName).get(key.toJS),
      );
      return result == null ? null : _castRecord(result);
    }
    final transaction = _database.transaction(storeName.toJS, 'readonly');
    final store = transaction.objectStore(storeName);
    final result = await _requestResult(store.get(key.toJS));
    await _transactionCompleted(transaction);
    if (result == null) {
      return null;
    }
    return _castRecord(result);
  }

  Future<List<Map<String, dynamic>>> getAllRecords(String storeName) async {
    final active = Zone.current[_transactionZoneKey] as web.IDBTransaction?;
    if (active != null) {
      final result = await _requestResult(
        active.objectStore(storeName).getAll(),
      );
      return (result as List? ?? const <dynamic>[]).map(_castRecord).toList();
    }
    final transaction = _database.transaction(storeName.toJS, 'readonly');
    final store = transaction.objectStore(storeName);
    final result = await _requestResult(store.getAll());
    await _transactionCompleted(transaction);
    return (result as List? ?? const <dynamic>[]).map(_castRecord).toList();
  }

  Future<void> putRecord(
    String storeName,
    String key,
    Map<String, dynamic> value,
  ) async {
    final active = Zone.current[_transactionZoneKey] as web.IDBTransaction?;
    if (active != null) {
      await _requestResult(
        active.objectStore(storeName).put(value.jsify(), key.toJS),
      );
      return;
    }
    final transaction = _database.transaction(storeName.toJS, 'readwrite');
    final store = transaction.objectStore(storeName);
    await _requestResult(store.put(value.jsify(), key.toJS));
    await _transactionCompleted(transaction);
  }

  Future<void> deleteRecord(String storeName, String key) async {
    final active = Zone.current[_transactionZoneKey] as web.IDBTransaction?;
    if (active != null) {
      await _requestResult(active.objectStore(storeName).delete(key.toJS));
      return;
    }
    final transaction = _database.transaction(storeName.toJS, 'readwrite');
    final store = transaction.objectStore(storeName);
    await _requestResult(store.delete(key.toJS));
    await _transactionCompleted(transaction);
  }

  Future<void> applyMutations(List<WebStoreMutation> mutations) async {
    if (mutations.isEmpty) return;
    final active = Zone.current[_transactionZoneKey] as web.IDBTransaction?;
    if (active != null) {
      await _queueMutations(active, mutations);
      return;
    }
    final storeNames = mutations
        .map((mutation) => mutation.storeName)
        .toSet()
        .toList();
    final transaction = _database.transaction(storeNames.jsify()!, 'readwrite');
    await _queueMutations(transaction, mutations);
    await _transactionCompleted(transaction);
  }

  Future<T> runInTransaction<T>(
    List<String> storeNames,
    Future<T> Function() operation,
  ) async {
    if (Zone.current[_transactionZoneKey] != null) return operation();
    final transaction = _database.transaction(
      storeNames.toSet().toList().jsify()!,
      'readwrite',
    );
    try {
      final result = await runZoned(
        operation,
        zoneValues: {_transactionZoneKey: transaction},
      );
      await _transactionCompleted(transaction);
      return result;
    } catch (_) {
      try {
        transaction.abort();
      } catch (_) {}
      rethrow;
    }
  }

  static Future<void> _queueMutations(
    web.IDBTransaction transaction,
    List<WebStoreMutation> mutations,
  ) async {
    for (final mutation in mutations) {
      final store = transaction.objectStore(mutation.storeName);
      final request = mutation.isDelete
          ? store.delete(mutation.key.toJS)
          : store.put(mutation.value!.jsify(), mutation.key.toJS);
      await _requestResult(request);
    }
  }

  static Future<Object?> _requestResult(web.IDBRequest request) {
    final completer = Completer<Object?>();
    request.onsuccess = ((web.Event _) {
      completer.complete(request.result.dartify());
    }).toJS;
    request.onerror = ((web.Event _) {
      completer.completeError(
        request.error ?? StateError('IndexedDB request failed.'),
      );
    }).toJS;
    return completer.future;
  }

  static Future<void> _transactionCompleted(web.IDBTransaction transaction) {
    final completer = Completer<void>();
    transaction.oncomplete = ((web.Event _) {
      completer.complete();
    }).toJS;
    transaction.onerror = ((web.Event _) {
      completer.completeError(
        transaction.error ?? StateError('IndexedDB transaction failed.'),
      );
    }).toJS;
    transaction.onabort = ((web.Event _) {
      if (!completer.isCompleted) {
        completer.completeError(
          transaction.error ?? StateError('IndexedDB transaction aborted.'),
        );
      }
    }).toJS;
    return completer.future;
  }

  static Map<String, dynamic> _castRecord(dynamic value) {
    return (value as Map).cast<String, dynamic>();
  }
}
