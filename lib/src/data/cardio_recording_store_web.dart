import 'cardio_recording_store.dart';
import 'web_local_store.dart';

class WebCardioLocalDocuments implements CardioLocalDocuments {
  WebCardioLocalDocuments(this.store);
  final WebLocalStore store;
  static const _name = WebStoreNames.cardioLocal;
  @override
  Future<T> transaction<T>(Future<T> Function() action) =>
      store.runInTransaction([_name], action);
  @override
  Future<Map<String, dynamic>?> read(String key) async =>
      (await store.getRecord(_name, key))?['value']?.cast<String, dynamic>();
  @override
  Future<void> put(String key, Map<String, dynamic> value) =>
      store.putRecord(_name, key, {'key': key, 'value': value});
  @override
  Future<void> delete(String key) => store.deleteRecord(_name, key);
  @override
  Future<List<Map<String, dynamic>>> list(String prefix) async =>
      (await store.getAllRecords(_name))
          .where((doc) => (doc['key'] as String).startsWith(prefix))
          .map((doc) => Map<String, dynamic>.from(doc['value'] as Map))
          .toList();
}
