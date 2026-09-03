import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

final Object _transactionZoneKey = Object();

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
  WebLocalStore._(this._database, {required Object? defaultToken})
    : _defaultToken = defaultToken;

  static const _databaseName = 'fittin_v2_web_store';
  static const _databaseVersion = 3;
  static Future<WebLocalStore>? _instance;
  static Object? _instanceToken;

  final web.IDBDatabase _database;
  final Object? _defaultToken;
  String? _invalidationMessage;

  static Future<WebLocalStore> open({
    String? databaseName,
    int databaseVersion = _databaseVersion,
    Duration timeout = const Duration(seconds: 8),
  }) {
    if (databaseName != null || databaseVersion != _databaseVersion) {
      return _openInternal(
        databaseName: databaseName ?? _databaseName,
        databaseVersion: databaseVersion,
        timeout: timeout,
      );
    }
    final cached = _instance;
    if (cached != null) return cached;
    final token = Object();
    _instanceToken = token;
    return _instance = _openDefault(timeout, token);
  }

  void close() {
    _invalidate(
      'This browser storage connection is closed. Open WebLocalStore again before accessing data.',
    );
  }

  void _invalidate(String message) {
    if (_invalidationMessage != null) return;
    _invalidationMessage = message;
    _database.close();
    final token = _defaultToken;
    if (token != null && identical(_instanceToken, token)) {
      _instance = null;
      _instanceToken = null;
    }
  }

  void _ensureUsable() {
    final message = _invalidationMessage;
    if (message != null) throw WebLocalStoreInvalidatedException(message);
  }

  static Future<WebLocalStore> _openDefault(
    Duration timeout,
    Object token,
  ) async {
    try {
      return await _openInternal(
        databaseName: _databaseName,
        databaseVersion: _databaseVersion,
        timeout: timeout,
        defaultToken: token,
      );
    } catch (_) {
      // A failed future must not poison every later startup retry.
      if (identical(_instanceToken, token)) {
        _instance = null;
        _instanceToken = null;
      }
      rethrow;
    }
  }

  static Future<WebLocalStore> _openInternal({
    required String databaseName,
    required int databaseVersion,
    required Duration timeout,
    Object? defaultToken,
  }) async {
    final request = web.window.indexedDB.open(databaseName, databaseVersion);
    final completer = Completer<web.IDBDatabase>();
    final timeoutTimer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.completeError(
          const WebLocalStoreOpenException(
            'Opening browser storage timed out. Close other Fittin tabs and retry.',
          ),
        );
      }
    });

    request.onupgradeneeded = ((web.Event _) {
      final database = request.result as web.IDBDatabase;
      for (final storeName in WebStoreNames.all) {
        if (!database.objectStoreNames.contains(storeName)) {
          database.createObjectStore(storeName);
        }
      }
    }).toJS;

    request.onsuccess = ((web.Event _) {
      final database = request.result as web.IDBDatabase;
      if (completer.isCompleted) {
        // IndexedDB requests cannot be cancelled. A request that succeeds after
        // the caller has already received a timeout/blocked error must not leave
        // another hidden connection behind.
        database.close();
        return;
      }
      completer.complete(database);
    }).toJS;

    request.onerror = ((web.Event _) {
      if (!completer.isCompleted) {
        completer.completeError(
          request.error ??
              const WebLocalStoreOpenException(
                'Failed to open browser storage.',
              ),
        );
      }
    }).toJS;

    request.onblocked = ((web.Event _) {
      if (!completer.isCompleted) {
        completer.completeError(
          const WebLocalStoreBlockedException(
            'A previous Fittin tab is blocking a browser storage upgrade. Close it and retry.',
          ),
        );
      }
    }).toJS;

    try {
      final store = WebLocalStore._(
        await completer.future,
        defaultToken: defaultToken,
      );
      store._database.onversionchange = ((web.Event _) {
        store._invalidate(
          'This browser storage connection was invalidated by a version change. Open WebLocalStore again before accessing data.',
        );
      }).toJS;
      return store;
    } finally {
      timeoutTimer.cancel();
    }
  }

  Future<Map<String, dynamic>?> getRecord(String storeName, String key) async {
    _ensureUsable();
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
    _ensureUsable();
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
    _ensureUsable();
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
    _ensureUsable();
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
    _ensureUsable();
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
    _ensureUsable();
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
