import 'dart:convert';
import 'dart:async';
import 'agent_transaction_context.dart';
import 'package:isar/isar.dart';
import 'cardio_recording_store.dart';
import 'models/app_state_collection.dart';

/// Existing local-only schema; these keys never enter a synchronization queue.
class IsarCardioLocalDocuments implements CardioLocalDocuments {
  IsarCardioLocalDocuments(this.isar);
  final Isar isar;
  static const _prefix = 'local-cardio/';
  static final _transactionOwner = Object();

  @override
  Future<T> transaction<T>(Future<T> Function() action) =>
      Zone.current[agentTransactionZoneKey] == true ||
          identical(Zone.current[_transactionOwner], isar)
      ? action()
      : isar.writeTxn(
          () => runZoned(action, zoneValues: {_transactionOwner: isar}),
        );
  @override
  Future<Map<String, dynamic>?> read(String key) async {
    final row = await isar.appStateCollections.getByStateKey('$_prefix$key');
    return row?.stringValue == null
        ? null
        : (jsonDecode(row!.stringValue!) as Map).cast<String, dynamic>();
  }

  @override
  Future<void> put(String key, Map<String, dynamic> value) async {
    await isar.appStateCollections.putByStateKey(
      AppStateCollection()
        ..stateKey = '$_prefix$key'
        ..stringValue = jsonEncode(value)
        ..updatedAt = DateTime.now(),
    );
  }

  @override
  Future<void> delete(String key) async {
    await isar.appStateCollections.deleteByStateKey('$_prefix$key');
  }

  @override
  Future<List<Map<String, dynamic>>> list(String prefix) async {
    final rows = await isar.appStateCollections
        .filter()
        .stateKeyStartsWith('$_prefix$prefix')
        .findAll();
    return rows
        .map(
          (row) =>
              (jsonDecode(row.stringValue!) as Map).cast<String, dynamic>(),
        )
        .toList();
  }
}
