import 'package:fittin_v2/src/domain/exercise_library.dart';

class CustomExerciseDefinition {
  CustomExerciseDefinition({
    required this.id,
    required String nameEn,
    required String nameZhCn,
    required this.movement,
    required this.equipment,
    required this.loadSemantics,
    required List<ExerciseMuscle> primaryMuscles,
    required List<ExerciseMuscle> secondaryMuscles,
    required List<String> tags,
    this.roundingIncrementKg = 2.5,
    this.sourceExerciseId,
  }) : nameEn = nameEn.trim(),
       nameZhCn = nameZhCn.trim(),
       primaryMuscles = List.unmodifiable(primaryMuscles),
       secondaryMuscles = List.unmodifiable(secondaryMuscles),
       tags = List.unmodifiable(_validateAndNormalizeExerciseTags(tags)) {
    validate();
  }

  final String id;
  final String nameEn;
  final String nameZhCn;
  final ExerciseMovement movement;
  final ExerciseEquipment equipment;
  final ExerciseLoadSemantics loadSemantics;
  final List<ExerciseMuscle> primaryMuscles;
  final List<ExerciseMuscle> secondaryMuscles;
  final List<String> tags;
  final double roundingIncrementKg;
  final String? sourceExerciseId;

  void validate() {
    if (id.trim() != id ||
        !id.startsWith('user-exercise:') ||
        id.length == 'user-exercise:'.length ||
        id.length > 120) {
      throw const FormatException('Custom exercise ID is invalid.');
    }
    if (nameEn.isEmpty ||
        nameZhCn.isEmpty ||
        RegExp(r'[\u0000-\u001F\u007F]').hasMatch(nameEn) ||
        RegExp(r'[\u0000-\u001F\u007F]').hasMatch(nameZhCn)) {
      throw const FormatException('Exercise names are invalid.');
    }
    if (nameEn.length > 80 || nameZhCn.length > 80) {
      throw const FormatException('Exercise names are too long.');
    }
    if (movement == ExerciseMovement.selection ||
        equipment == ExerciseEquipment.selection ||
        loadSemantics == ExerciseLoadSemantics.selection) {
      throw const FormatException('Selection placeholders cannot be saved.');
    }
    if (primaryMuscles.isEmpty ||
        {...primaryMuscles, ...secondaryMuscles}.length !=
            primaryMuscles.length + secondaryMuscles.length) {
      throw const FormatException('Exercise muscle tags are invalid.');
    }
    if (!roundingIncrementKg.isFinite ||
        roundingIncrementKg <= 0 ||
        roundingIncrementKg > 25) {
      throw const FormatException('Exercise rounding increment is invalid.');
    }
    if (sourceExerciseId case final source?) {
      if (source.trim() != source ||
          source.isEmpty ||
          source.length > 120 ||
          source == id) {
        throw const FormatException('Exercise source ID is invalid.');
      }
    }
  }

  String displayName(String localeCode) =>
      localeCode.toLowerCase().startsWith('zh') ? nameZhCn : nameEn;

  Map<String, dynamic> toJson() => {
    'id': id,
    'nameEn': nameEn,
    'nameZhCn': nameZhCn,
    'movement': movement.name,
    'equipment': equipment.name,
    'loadSemantics': loadSemantics.name,
    'primaryMuscles': primaryMuscles.map((value) => value.name).toList(),
    'secondaryMuscles': secondaryMuscles.map((value) => value.name).toList(),
    'tags': tags,
    'roundingIncrementKg': roundingIncrementKg,
    'sourceExerciseId': sourceExerciseId,
  };

  factory CustomExerciseDefinition.fromJson(Map<String, dynamic> json) =>
      CustomExerciseDefinition(
        id: json['id'] as String,
        nameEn: json['nameEn'] as String,
        nameZhCn: json['nameZhCn'] as String,
        movement: ExerciseMovement.values.byName(json['movement'] as String),
        equipment: ExerciseEquipment.values.byName(json['equipment'] as String),
        loadSemantics: ExerciseLoadSemantics.values.byName(
          json['loadSemantics'] as String,
        ),
        primaryMuscles: (json['primaryMuscles'] as List)
            .cast<String>()
            .map(ExerciseMuscle.values.byName)
            .toList(),
        secondaryMuscles: (json['secondaryMuscles'] as List? ?? const [])
            .cast<String>()
            .map(ExerciseMuscle.values.byName)
            .toList(),
        tags: (json['tags'] as List? ?? const []).cast<String>(),
        roundingIncrementKg:
            (json['roundingIncrementKg'] as num?)?.toDouble() ?? 2.5,
        sourceExerciseId: json['sourceExerciseId'] as String?,
      );
}

List<String> _validateAndNormalizeExerciseTags(Iterable<String> tags) {
  final source = tags.toList(growable: false);
  if (source.length > 20) {
    throw const FormatException('An exercise can have at most 20 user tags.');
  }
  final normalized = <String>{};
  for (final tag in source) {
    final value = tag.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');
    if (value.isEmpty || value.length > 32) {
      throw const FormatException('Exercise tag is invalid.');
    }
    if (!normalized.add(value)) {
      throw const FormatException('Exercise tags must be unique.');
    }
  }
  final result = normalized.toList()..sort();
  return result;
}

List<String> normalizeExerciseTags(Iterable<String> tags) {
  final normalized = <String>{};
  for (final tag in tags) {
    final value = tag.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');
    if (value.isNotEmpty && value.length <= 32) normalized.add(value);
  }
  final result = normalized.toList()..sort();
  return result.take(20).toList(growable: false);
}

class ExerciseCatalogItem {
  const ExerciseCatalogItem({
    required this.id,
    required this.nameEn,
    required this.nameZhCn,
    required this.movement,
    required this.equipment,
    required this.loadSemantics,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.tags,
    required this.roundingIncrementKg,
    required this.isBuiltIn,
    this.aliases = const [],
  });

  factory ExerciseCatalogItem.fromBuiltIn(ExerciseDefinition definition) =>
      ExerciseCatalogItem(
        id: definition.id,
        nameEn: definition.nameEn,
        nameZhCn: definition.nameZhCn,
        movement: definition.movement,
        equipment: definition.equipment,
        loadSemantics: definition.loadSemantics,
        primaryMuscles: definition.muscles.primary,
        secondaryMuscles: definition.muscles.secondary,
        tags: _derivedTags(
          definition.movement,
          definition.equipment,
          definition.muscles.primary,
          definition.muscles.secondary,
        ),
        roundingIncrementKg: definition.roundingIncrementKg,
        isBuiltIn: true,
        aliases: definition.aliases,
      );

  factory ExerciseCatalogItem.fromCustom(CustomExerciseDefinition definition) =>
      ExerciseCatalogItem(
        id: definition.id,
        nameEn: definition.nameEn,
        nameZhCn: definition.nameZhCn,
        movement: definition.movement,
        equipment: definition.equipment,
        loadSemantics: definition.loadSemantics,
        primaryMuscles: definition.primaryMuscles,
        secondaryMuscles: definition.secondaryMuscles,
        tags: {
          ..._derivedTags(
            definition.movement,
            definition.equipment,
            definition.primaryMuscles,
            definition.secondaryMuscles,
          ),
          ...definition.tags,
        }.toList()..sort(),
        roundingIncrementKg: definition.roundingIncrementKg,
        isBuiltIn: false,
      );

  final String id;
  final String nameEn;
  final String nameZhCn;
  final ExerciseMovement movement;
  final ExerciseEquipment equipment;
  final ExerciseLoadSemantics loadSemantics;
  final List<ExerciseMuscle> primaryMuscles;
  final List<ExerciseMuscle> secondaryMuscles;
  final List<String> tags;
  final double roundingIncrementKg;
  final bool isBuiltIn;
  final List<String> aliases;

  String displayName(String localeCode) =>
      localeCode.toLowerCase().startsWith('zh') ? nameZhCn : nameEn;
}

List<String> _derivedTags(
  ExerciseMovement movement,
  ExerciseEquipment equipment,
  List<ExerciseMuscle> primary,
  List<ExerciseMuscle> secondary,
) => normalizeExerciseTags([
  'movement:${movement.name}',
  'equipment:${equipment.name}',
  ...primary.map((value) => 'primary:${value.name}'),
  ...secondary.map((value) => 'secondary:${value.name}'),
]);
