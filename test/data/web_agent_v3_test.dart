@TestOn('browser')
library;

import 'dart:async';
import 'dart:js_interop';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;
import 'package:fittin_v2/src/data/web_local_store.dart';
import 'package:fittin_v2/src/data/agent_local_repository_web.dart';
import 'package:fittin_v2/src/data/agent_atomic_mutation_web.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'package:fittin_v2/src/domain/models/body_metric.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/agent_tools.dart';
import 'package:fittin_v2/src/application/agent_mutation_coordinator.dart';
import 'package:fittin_v2/src/data/agent_local_repository.dart';
import 'package:fittin_v2/src/data/progress_repository.dart';
import 'package:fittin_v2/src/data/web_database_repository.dart';
import 'package:fittin_v2/src/data/web_progress_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'separate Web connections reject stale previews and undo without partial writes',
    () async {
      final name = 'fittin_tabs_${DateTime.now().microsecondsSinceEpoch}';
      final first = await WebLocalStore.open(databaseName: name);
      final second = await WebLocalStore.open(databaseName: name);
      addTearDown(first.close);
      addTearDown(second.close);
      final progress = WebProgressRepository(first);
      final otherProgress = WebProgressRepository(second);
      final actions = WebAgentLocalRepository(first);
      final c = ProviderContainer(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(
            WebDatabaseRepository(first),
          ),
          progressRepositoryProvider.overrideWithValue(progress),
          agentLocalRepositoryProvider.overrideWithValue(actions),
        ],
      );
      addTearDown(c.dispose);
      final original = BodyMetric(
        metricId: 'm',
        timestamp: DateTime(2026, 8, 1),
        weightKg: 70,
        waistCm: 80,
      );
      await progress.saveBodyMetric(original);
      final tools = c.read(agentToolRegistryProvider);
      final stale = await tools.execute('propose_update_body_metric', {
        'metricId': 'm',
        'waistCm': null,
      });
      expect(stale.isError, false, reason: stale.encoded);
      // The value returns to its original content, but the other tab advanced its version.
      await otherProgress.saveBodyMetric(original.copyWith(weightKg: 71));
      await otherProgress.saveBodyMetric(original);
      final coordinator = c.read(agentMutationCoordinatorProvider);
      await expectLater(
        coordinator.confirm(stale.proposal!),
        throwsA(isA<AgentMutationConflict>()),
      );
      expect(await actions.fetchActions(), isEmpty);
      expect((await progress.fetchBodyMetrics()).single.waistCm, 80);
      final fresh = await tools.execute('propose_update_body_metric', {
        'metricId': 'm',
        'waistCm': null,
      });
      final action = await coordinator.confirm(fresh.proposal!);
      expect((await otherProgress.fetchBodyMetrics()).single.waistCm, isNull);
      await otherProgress.saveBodyMetric(original.copyWith(waistCm: null));
      await expectLater(
        coordinator.undo(action.id),
        throwsA(isA<AgentMutationConflict>()),
      );
      expect((await progress.fetchBodyMetrics()).single.waistCm, isNull);
    },
  );

  test(
    'v2 to v3 preserves all old stores and adds runtime, checkpoints, memory and diagnostics',
    () async {
      final name = 'fittin_agent_v2_${DateTime.now().microsecondsSinceEpoch}';
      final oldStores = WebStoreNames.all.take(9).toList();
      final request = web.window.indexedDB.open(name, 2);
      final opened = Completer<web.IDBDatabase>();
      request.onupgradeneeded = ((web.Event _) {
        final db = request.result as web.IDBDatabase;
        for (final store in oldStores) {
          db.createObjectStore(store);
        }
      }).toJS;
      request.onsuccess = ((web.Event _) => opened.complete(
        request.result as web.IDBDatabase,
      )).toJS;
      request.onerror = ((web.Event _) => opened.completeError(
        StateError('legacy open failed'),
      )).toJS;
      final legacy = await opened.future;
      final preserved = <String, Map<String, dynamic>>{};
      for (final store in oldStores) {
        final value = {
          'id': 'fixture',
          'ownerUserId': 'user-a',
          'currentWeek': 3,
          'currentWorkoutIndex': 2,
          'completedAt': '2026-08-01T10:00:00Z',
          'weightKg': 70,
          'note': 'existing data',
          'authSession': {'fixtureToken': 'test-only'},
        };
        preserved[store] = value;
        final tx = legacy.transaction(store.toJS, 'readwrite');
        final done = Completer<void>();
        tx.oncomplete = ((web.Event _) => done.complete()).toJS;
        tx.objectStore(store).put(value.jsify(), 'fixture'.toJS);
        await done.future;
      }
      legacy.close();
      final db = await WebLocalStore.open(databaseName: name);
      addTearDown(db.close);
      for (final entry in preserved.entries) {
        expect(await db.getRecord(entry.key, 'fixture'), entry.value);
      }
      final repo = WebAgentLocalRepository(db);
      for (final kind in ['run', 'checkpoint', 'memory', 'diagnostic']) {
        await repo.saveDocument(kind, 'new', {
          'value': 'safe',
        }, ownerUserId: 'user-a');
        expect(
          (await repo.readDocument(
            kind,
            'new',
            ownerUserId: 'user-a',
          ))!['value'],
          'safe',
        );
        expect(
          await repo.readDocument(kind, 'new', ownerUserId: 'user-b'),
          isNull,
        );
      }
    },
  );
  test(
    'Web complete metric replacement clears nulls; failed transactions roll back business, sync and audit',
    () async {
      final db = await WebLocalStore.open(
        databaseName: 'fittin_atomic_${DateTime.now().microsecondsSinceEpoch}',
      );
      addTearDown(db.close);
      final repo = WebAgentLocalRepository(db);
      final writer = AgentAtomicMutationWriter(repo);
      final before = {
        'metricId': 'm',
        'ownerUserId': 'u',
        'timestamp': '2026-08-01T00:00:00Z',
        'weightKg': 70,
        'waistCm': 80,
        'bodyFatPercent': 20,
        'note': 'clear me',
        'version': 2,
      };
      await db.putRecord(WebStoreNames.bodyMetrics, 'm', before);
      final action = AgentActionRecord(
        id: 'op',
        ownerUserId: 'u',
        toolName: 'propose_update_body_metric',
        title: 'Clear',
        targetType: 'body_metric',
        targetId: 'm',
        beforeJson: '{}',
        afterJson: '{}',
        afterDigest: 'digest',
        createdAt: DateTime.now(),
      );
      Future<void> write() => writer.writeBodyMetric(
        metric: BodyMetric(
          metricId: 'm',
          timestamp: DateTime(2026, 8, 1),
          weightKg: 70,
        ),
        metricId: 'm',
        ownerUserId: 'u',
        action: action,
        delete: false,
      );
      await expectLater(
        db.runInTransaction(WebStoreNames.all, () async {
          await write();
          throw StateError('injected after writes');
        }),
        throwsStateError,
      );
      expect(await db.getRecord(WebStoreNames.bodyMetrics, 'm'), before);
      expect(await db.getRecord(WebStoreNames.agentActions, 'op'), isNull);
      expect(await db.getAllRecords(WebStoreNames.syncQueue), isEmpty);
      await db.runInTransaction(WebStoreNames.all, write);
      final result = (await db.getRecord(WebStoreNames.bodyMetrics, 'm'))!;
      for (final key in ['waistCm', 'bodyFatPercent', 'note']) {
        expect(result.containsKey(key), true);
        expect(result[key], isNull);
      }
      expect(result['version'], 3);
      expect(await db.getRecord(WebStoreNames.agentActions, 'op'), isNotNull);
    },
  );
}
