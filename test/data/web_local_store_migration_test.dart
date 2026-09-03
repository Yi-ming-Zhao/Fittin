@TestOn('browser')
library;

import 'dart:async';
import 'dart:js_interop';

import 'package:fittin_v2/src/data/web_local_store_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;

const _databaseName = 'fittin_v2_web_store';
const _blockedDatabaseName = 'fittin_v2_web_store_blocked_test';
const _versionChangeDatabaseName = 'fittin_v2_web_store_versionchange_test';
const _legacyStores = <String>[
  WebStoreNames.appState,
  WebStoreNames.templates,
  WebStoreNames.instances,
  WebStoreNames.workoutLogs,
  WebStoreNames.bodyMetrics,
  WebStoreNames.progressPhotos,
  WebStoreNames.syncQueue,
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'IndexedDB v1 upgrades additively and aborts cross-store writes',
    () async {
      await _deleteDatabase();
      final legacy = await _openLegacyDatabase();
      for (final storeName in _legacyStores) {
        await _putLegacyRecord(legacy, storeName, {
          'id': '$storeName-existing',
          'marker': 'preserved',
        });
      }
      legacy.close();

      final store = await WebLocalStore.open();
      for (final storeName in _legacyStores) {
        expect(
          await store.getRecord(storeName, '$storeName-existing'),
          containsPair('marker', 'preserved'),
          reason: '$storeName should survive the v1 to v2 upgrade',
        );
      }

      await store.putRecord(
        WebStoreNames.agentConversations,
        'conversation-1',
        {'id': 'conversation-1'},
      );
      await store.putRecord(WebStoreNames.agentActions, 'action-1', {
        'id': 'action-1',
      });
      expect(
        await store.getRecord(
          WebStoreNames.agentConversations,
          'conversation-1',
        ),
        isNotNull,
      );
      expect(
        await store.getRecord(WebStoreNames.agentActions, 'action-1'),
        isNotNull,
      );

      await expectLater(
        store.runInTransaction(
          [WebStoreNames.appState, WebStoreNames.agentActions],
          () async {
            await store.putRecord(WebStoreNames.appState, 'partial-business', {
              'id': 'partial-business',
            });
            await store.putRecord(
              WebStoreNames.agentActions,
              'partial-action',
              {'id': 'partial-action'},
            );
            throw StateError('injected failure');
          },
        ),
        throwsStateError,
      );
      expect(
        await store.getRecord(WebStoreNames.appState, 'partial-business'),
        isNull,
      );
      expect(
        await store.getRecord(WebStoreNames.agentActions, 'partial-action'),
        isNull,
      );
      store.close();
      await expectLater(
        store.getRecord(WebStoreNames.appState, 'closed-store-read'),
        throwsA(isA<WebLocalStoreInvalidatedException>()),
      );

      final reopened = await WebLocalStore.open();
      expect(identical(store, reopened), isFalse);
      expect(
        await reopened.getRecord(
          WebStoreNames.agentConversations,
          'conversation-1',
        ),
        isNotNull,
      );
      reopened.close();
    },
  );

  test('blocked upgrade fails promptly and can be retried', () async {
    await _deleteDatabase(_blockedDatabaseName);
    final legacy = await _openDatabase(
      _blockedDatabaseName,
      3,
      WebStoreNames.all,
    );

    await expectLater(
      WebLocalStore.open(
        databaseName: _blockedDatabaseName,
        databaseVersion: 4,
        timeout: const Duration(seconds: 2),
      ),
      throwsA(isA<WebLocalStoreBlockedException>()),
    );

    legacy.close();
    final retried = await WebLocalStore.open(
      databaseName: _blockedDatabaseName,
      databaseVersion: 4,
      timeout: const Duration(seconds: 2),
    );
    expect(await retried.getAllRecords(WebStoreNames.appState), isEmpty);
    retried.close();
    await _deleteDatabase(_blockedDatabaseName);
  });

  test(
    'default versionchange invalidates the old store and opens a fresh singleton',
    () async {
      await _deleteDatabase();
      final current = await WebLocalStore.open();
      await current.putRecord(WebStoreNames.appState, 'before-delete', {
        'id': 'before-delete',
      });

      // Deleting an open IndexedDB dispatches versionchange with newVersion
      // null. The default store must release that connection and its cache.
      await _deleteDatabase();
      await expectLater(
        current.getAllRecords(WebStoreNames.appState),
        throwsA(
          isA<WebLocalStoreInvalidatedException>().having(
            (error) => error.message,
            'message',
            contains('version change'),
          ),
        ),
      );

      final reopened = await WebLocalStore.open();
      expect(identical(current, reopened), isFalse);
      await reopened.putRecord(WebStoreNames.appState, 'after-reopen', {
        'id': 'after-reopen',
      });
      expect(
        await reopened.getRecord(WebStoreNames.appState, 'after-reopen'),
        containsPair('id', 'after-reopen'),
      );
      current.close();
      expect(identical(reopened, await WebLocalStore.open()), isTrue);
      reopened.close();
      await _deleteDatabase();
    },
  );

  test('an open store closes itself for a later version upgrade', () async {
    await _deleteDatabase(_versionChangeDatabaseName);
    final current = await WebLocalStore.open(
      databaseName: _versionChangeDatabaseName,
      databaseVersion: 3,
    );

    final upgraded = await WebLocalStore.open(
      databaseName: _versionChangeDatabaseName,
      databaseVersion: 4,
      timeout: const Duration(seconds: 2),
    );
    expect(await upgraded.getAllRecords(WebStoreNames.appState), isEmpty);
    await expectLater(
      current.getAllRecords(WebStoreNames.appState),
      throwsA(isA<WebLocalStoreInvalidatedException>()),
    );
    current.close();
    upgraded.close();
    await _deleteDatabase(_versionChangeDatabaseName);
  });
}

Future<void> _deleteDatabase([String databaseName = _databaseName]) {
  final request = web.window.indexedDB.deleteDatabase(databaseName);
  final completer = Completer<void>();
  request.onsuccess = ((web.Event _) => completer.complete()).toJS;
  request.onerror = ((web.Event _) {
    completer.completeError(
      request.error ?? StateError('Failed to delete test IndexedDB.'),
    );
  }).toJS;
  request.onblocked = ((web.Event _) {
    completer.completeError(StateError('Test IndexedDB deletion was blocked.'));
  }).toJS;
  return completer.future;
}

Future<web.IDBDatabase> _openLegacyDatabase() {
  return _openDatabase(_databaseName, 1, _legacyStores);
}

Future<web.IDBDatabase> _openDatabase(
  String databaseName,
  int version,
  List<String> storeNames,
) {
  final request = web.window.indexedDB.open(databaseName, version);
  final completer = Completer<web.IDBDatabase>();
  request.onupgradeneeded = ((web.Event _) {
    final database = request.result as web.IDBDatabase;
    for (final storeName in storeNames) {
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
      request.error ?? StateError('Failed to create legacy IndexedDB.'),
    );
  }).toJS;
  return completer.future;
}

Future<void> _putLegacyRecord(
  web.IDBDatabase database,
  String storeName,
  Map<String, dynamic> value,
) {
  final transaction = database.transaction(storeName.toJS, 'readwrite');
  final request = transaction
      .objectStore(storeName)
      .put(value.jsify(), '$storeName-existing'.toJS);
  final completer = Completer<void>();
  request.onerror = ((web.Event _) {
    if (!completer.isCompleted) {
      completer.completeError(
        request.error ?? StateError('Failed to seed legacy IndexedDB.'),
      );
    }
  }).toJS;
  transaction.oncomplete = ((web.Event _) {
    if (!completer.isCompleted) completer.complete();
  }).toJS;
  transaction.onerror = ((web.Event _) {
    if (!completer.isCompleted) {
      completer.completeError(
        transaction.error ?? StateError('Legacy seed transaction failed.'),
      );
    }
  }).toJS;
  transaction.onabort = ((web.Event _) {
    if (!completer.isCompleted) {
      completer.completeError(
        transaction.error ?? StateError('Legacy seed transaction aborted.'),
      );
    }
  }).toJS;
  return completer.future;
}
