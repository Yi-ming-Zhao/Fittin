@TestOn('browser')
library;

import 'dart:async';
import 'dart:js_interop';

import 'package:fittin_v2/src/data/web_local_store_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;

const _databaseName = 'fittin_v2_web_store';
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
    },
  );
}

Future<void> _deleteDatabase() {
  final request = web.window.indexedDB.deleteDatabase(_databaseName);
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
  final request = web.window.indexedDB.open(_databaseName, 1);
  final completer = Completer<web.IDBDatabase>();
  request.onupgradeneeded = ((web.Event _) {
    final database = request.result as web.IDBDatabase;
    for (final storeName in _legacyStores) {
      database.createObjectStore(storeName);
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
  request.onsuccess = ((web.Event _) => completer.complete()).toJS;
  request.onerror = ((web.Event _) {
    completer.completeError(
      request.error ?? StateError('Failed to seed legacy IndexedDB.'),
    );
  }).toJS;
  return completer.future;
}
