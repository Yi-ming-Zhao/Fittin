import 'package:isar/isar.dart';

part 'app_state_collection.g.dart';

@collection
class AppStateCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String stateKey;

  String? activeInstanceId;
  String? localeCode;
  String? analyticsFormulaKey;
  double? glassOpacity;
  String? stringValue;

  late DateTime updatedAt;
}
