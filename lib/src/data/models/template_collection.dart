import 'package:isar/isar.dart';

part 'template_collection.g.dart';

@collection
class TemplateCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String templateId;

  late String name;

  late String description;

  @Index()
  late bool isBuiltIn;

  String? sourceTemplateId;

  late DateTime createdAt;

  late DateTime lastModifiedAt;

  // Since PlanTemplate tree can be complex and Isar strongly types nested objects,
  // we serialize the whole definition tree to a JSON string here to maximize
  // flexibility for the RuleEngine.
  late String rawJsonPayload;
}
