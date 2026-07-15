import 'dart:convert';

enum ExerciseDefinitionKind { exercise, selectionSlot }

enum ExerciseMovement {
  squat,
  hinge,
  horizontalPress,
  verticalPress,
  horizontalPull,
  verticalPull,
  kneeDominant,
  hipExtension,
  elbowFlexion,
  elbowExtension,
  shoulderAbduction,
  shoulderExternalRotation,
  locomotion,
  core,
  selection,
}

enum ExerciseEquipment {
  barbell,
  dumbbell,
  cable,
  machine,
  bodyweight,
  band,
  mixed,
  selection,
}

enum ExerciseLoadSemantics {
  totalExternal,
  perDumbbell,
  cableStack,
  machineStack,
  bodyweight,
  bodyweightPlusExternal,
  bandResistance,
  selection,
}

enum ExerciseMuscle {
  chest,
  anteriorDeltoids,
  lateralDeltoids,
  rearDeltoids,
  triceps,
  biceps,
  forearms,
  lats,
  upperBack,
  lowerBack,
  core,
  glutes,
  quadriceps,
  hamstrings,
  calves,
  adductors,
}

enum StrengthFamily { squat, bench, deadlift, none }

enum RatioPriorMode { ratio, calibrationOnly, notApplicable }

enum RatioConfidence { high, medium, low, none }

enum RatioEvidenceGrade { identity, c, d, calibrationOnly, notApplicable }

class ExerciseLibrarySource {
  const ExerciseLibrarySource({
    required this.id,
    required this.category,
    required this.uri,
    required this.revision,
    required this.license,
  });

  factory ExerciseLibrarySource.fromJson(Map<String, dynamic> json) {
    return ExerciseLibrarySource(
      id: _requiredString(json, 'id'),
      category: _requiredString(json, 'category'),
      uri: _requiredString(json, 'uri'),
      revision: _requiredString(json, 'revision'),
      license: _requiredString(json, 'license'),
    );
  }

  final String id;
  final String category;
  final String uri;
  final String revision;
  final String license;
}

class ExerciseMuscleProfile {
  ExerciseMuscleProfile({
    required List<ExerciseMuscle> primary,
    required List<ExerciseMuscle> secondary,
    required Map<ExerciseMuscle, double> weights,
  }) : primary = List.unmodifiable(primary),
       secondary = List.unmodifiable(secondary),
       weights = Map.unmodifiable(weights);

  factory ExerciseMuscleProfile.fromJson(Map<String, dynamic> json) {
    final primary = _enumList(json, 'primary', ExerciseMuscle.values, 'muscle');
    final secondary = _enumList(
      json,
      'secondary',
      ExerciseMuscle.values,
      'muscle',
    );
    final rawWeights = _requiredMap(json, 'weights');
    final weights = <ExerciseMuscle, double>{};
    for (final entry in rawWeights.entries) {
      final muscle = _enumByName(
        ExerciseMuscle.values,
        entry.key,
        'muscle weight',
      );
      final value = entry.value;
      if (value is! num) {
        throw FormatException('Muscle weight "${entry.key}" must be numeric.');
      }
      weights[muscle] = value.toDouble();
    }
    return ExerciseMuscleProfile(
      primary: primary,
      secondary: secondary,
      weights: weights,
    );
  }

  final List<ExerciseMuscle> primary;
  final List<ExerciseMuscle> secondary;
  final Map<ExerciseMuscle, double> weights;
}

class ExerciseRatioPrior {
  ExerciseRatioPrior({
    required this.mode,
    required this.anchor,
    required this.lower,
    required this.center,
    required this.upper,
    required this.evidenceGrade,
    required this.confidence,
    required List<String> sourceIds,
  }) : sourceIds = List.unmodifiable(sourceIds);

  factory ExerciseRatioPrior.fromJson(Map<String, dynamic> json) {
    return ExerciseRatioPrior(
      mode: _enumField(json, 'mode', RatioPriorMode.values, 'ratio mode'),
      anchor: _enumField(json, 'anchor', StrengthFamily.values, 'ratio anchor'),
      lower: _optionalDouble(json, 'lower'),
      center: _optionalDouble(json, 'center'),
      upper: _optionalDouble(json, 'upper'),
      evidenceGrade: _enumField(
        json,
        'evidenceGrade',
        RatioEvidenceGrade.values,
        'evidence grade',
      ),
      confidence: _enumField(
        json,
        'confidence',
        RatioConfidence.values,
        'ratio confidence',
      ),
      sourceIds: _stringList(json, 'sourceIds'),
    );
  }

  final RatioPriorMode mode;
  final StrengthFamily anchor;
  final double? lower;
  final double? center;
  final double? upper;
  final RatioEvidenceGrade evidenceGrade;
  final RatioConfidence confidence;
  final List<String> sourceIds;

  bool get hasNumericRatio => mode == RatioPriorMode.ratio;
}

class ExerciseDefinition {
  ExerciseDefinition({
    required this.id,
    required this.kind,
    required this.nameEn,
    required this.nameZhCn,
    required List<String> aliases,
    required List<String> legacyIds,
    required this.movement,
    required this.equipment,
    required this.loadSemantics,
    required this.muscles,
    required this.strengthFamily,
    required this.isCompetitionLift,
    required this.roundingIncrementKg,
    required this.ratioPrior,
    required List<String> sourceIds,
    required this.sourceRevision,
    required this.license,
  }) : aliases = List.unmodifiable(aliases),
       legacyIds = List.unmodifiable(legacyIds),
       sourceIds = List.unmodifiable(sourceIds);

  factory ExerciseDefinition.fromJson(Map<String, dynamic> json) {
    final names = _requiredMap(json, 'names');
    return ExerciseDefinition(
      id: _requiredString(json, 'id'),
      kind: _enumField(
        json,
        'kind',
        ExerciseDefinitionKind.values,
        'definition kind',
      ),
      nameEn: _requiredString(names, 'en'),
      nameZhCn: _requiredString(names, 'zhCn'),
      aliases: _stringList(json, 'aliases'),
      legacyIds: _stringList(json, 'legacyIds'),
      movement: _enumField(
        json,
        'movement',
        ExerciseMovement.values,
        'movement',
      ),
      equipment: _enumField(
        json,
        'equipment',
        ExerciseEquipment.values,
        'equipment',
      ),
      loadSemantics: _enumField(
        json,
        'loadSemantics',
        ExerciseLoadSemantics.values,
        'load semantics',
      ),
      muscles: ExerciseMuscleProfile.fromJson(_requiredMap(json, 'muscles')),
      strengthFamily: _enumField(
        json,
        'strengthFamily',
        StrengthFamily.values,
        'strength family',
      ),
      isCompetitionLift: _requiredBool(json, 'isCompetitionLift'),
      roundingIncrementKg: _requiredDouble(json, 'roundingIncrementKg'),
      ratioPrior: ExerciseRatioPrior.fromJson(_requiredMap(json, 'ratioPrior')),
      sourceIds: _stringList(json, 'sourceIds'),
      sourceRevision: _requiredString(json, 'sourceRevision'),
      license: _requiredString(json, 'license'),
    );
  }

  final String id;
  final ExerciseDefinitionKind kind;
  final String nameEn;
  final String nameZhCn;
  final List<String> aliases;
  final List<String> legacyIds;
  final ExerciseMovement movement;
  final ExerciseEquipment equipment;
  final ExerciseLoadSemantics loadSemantics;
  final ExerciseMuscleProfile muscles;
  final StrengthFamily strengthFamily;
  final bool isCompetitionLift;
  final double roundingIncrementKg;
  final ExerciseRatioPrior ratioPrior;
  final List<String> sourceIds;
  final String sourceRevision;
  final String license;

  bool get isSelectionSlot => kind == ExerciseDefinitionKind.selectionSlot;

  String displayName(String localeCode) {
    return localeCode.toLowerCase().startsWith('zh') ? nameZhCn : nameEn;
  }
}

class ResolvedExercise {
  const ResolvedExercise._({
    required this.id,
    required this.definition,
    required this.originalId,
    required this.originalName,
  });

  final String id;
  final ExerciseDefinition? definition;
  final String? originalId;
  final String originalName;

  bool get isCustom => definition == null;
  bool get isSelectionSlot => definition?.isSelectionSlot ?? false;

  String displayName(String localeCode) {
    return definition?.displayName(localeCode) ?? originalName;
  }
}

class ExerciseLibrary {
  ExerciseLibrary._({
    required this.schemaVersion,
    required this.catalogVersion,
    required this.sourceRevision,
    required List<ExerciseLibrarySource> sources,
    required List<ExerciseDefinition> definitions,
  }) : sources = List.unmodifiable(sources),
       definitions = List.unmodifiable(definitions) {
    _validateAndIndex();
  }

  factory ExerciseLibrary.fromJson(Map<String, dynamic> json) {
    final sources = _objectList(
      json,
      'sources',
    ).map(ExerciseLibrarySource.fromJson).toList(growable: false);
    final definitions = _objectList(
      json,
      'definitions',
    ).map(ExerciseDefinition.fromJson).toList(growable: false);
    return ExerciseLibrary._(
      schemaVersion: _requiredInt(json, 'schemaVersion'),
      catalogVersion: _requiredString(json, 'catalogVersion'),
      sourceRevision: _requiredString(json, 'sourceRevision'),
      sources: sources,
      definitions: definitions,
    );
  }

  factory ExerciseLibrary.fromJsonString(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Exercise library root must be an object.');
    }
    return ExerciseLibrary.fromJson(decoded);
  }

  final int schemaVersion;
  final String catalogVersion;
  final String sourceRevision;
  final List<ExerciseLibrarySource> sources;
  final List<ExerciseDefinition> definitions;

  final Map<String, ExerciseDefinition> _definitionsById = {};
  final Map<String, ExerciseDefinition> _definitionsByNormalizedKey = {};
  final Map<String, ExerciseLibrarySource> _sourcesById = {};

  ExerciseDefinition? byId(String id) => _definitionsById[id];

  ExerciseDefinition? findKnown({String? exerciseId, String? name}) {
    for (final candidate in [exerciseId, name]) {
      if (candidate == null || candidate.trim().isEmpty) {
        continue;
      }
      final exact = _definitionsById[candidate.trim()];
      if (exact != null) {
        return exact;
      }
      final normalized = normalizeExerciseKey(candidate);
      final resolved = _definitionsByNormalizedKey[normalized];
      if (resolved != null) {
        return resolved;
      }
    }
    return null;
  }

  ResolvedExercise resolve({String? exerciseId, required String name}) {
    final known = findKnown(exerciseId: exerciseId, name: name);
    if (known != null) {
      return ResolvedExercise._(
        id: known.id,
        definition: known,
        originalId: exerciseId,
        originalName: name,
      );
    }

    final trimmedId = exerciseId?.trim();
    if (trimmedId != null && trimmedId.startsWith('custom:')) {
      return ResolvedExercise._(
        id: trimmedId,
        definition: null,
        originalId: exerciseId,
        originalName: name.trim().isEmpty
            ? trimmedId.substring(7)
            : name.trim(),
      );
    }

    final fallbackLabel = name.trim().isNotEmpty
        ? name.trim()
        : (trimmedId?.isNotEmpty ?? false)
        ? trimmedId!
        : 'exercise';
    return ResolvedExercise._(
      id: customExerciseId(fallbackLabel),
      definition: null,
      originalId: exerciseId,
      originalName: fallbackLabel,
    );
  }

  void _validateAndIndex() {
    if (schemaVersion != 1) {
      throw FormatException(
        'Unsupported exercise library schema: $schemaVersion.',
      );
    }
    if (catalogVersion.trim().isEmpty || sourceRevision.trim().isEmpty) {
      throw const FormatException('Catalog version metadata cannot be empty.');
    }
    if (sources.isEmpty || definitions.isEmpty) {
      throw const FormatException('Exercise library cannot be empty.');
    }

    for (final source in sources) {
      if (_sourcesById.putIfAbsent(source.id, () => source) != source) {
        throw FormatException('Duplicate source id: ${source.id}.');
      }
      if (source.id.trim().isEmpty ||
          source.category.trim().isEmpty ||
          source.uri.trim().isEmpty ||
          source.revision.trim().isEmpty ||
          source.license.trim().isEmpty) {
        throw FormatException('Incomplete source metadata: ${source.id}.');
      }
    }

    for (final definition in definitions) {
      _validateDefinition(definition);
      if (_definitionsById.putIfAbsent(definition.id, () => definition) !=
          definition) {
        throw FormatException('Duplicate exercise id: ${definition.id}.');
      }
      final keys = <String>{
        definition.id,
        definition.nameEn,
        definition.nameZhCn,
        ...definition.legacyIds,
        ...definition.aliases,
      };
      for (final key in keys) {
        final normalized = normalizeExerciseKey(key);
        if (normalized.isEmpty) {
          throw FormatException('Empty normalized alias on ${definition.id}.');
        }
        final existing = _definitionsByNormalizedKey[normalized];
        if (existing != null && existing.id != definition.id) {
          throw FormatException(
            'Exercise key "$key" conflicts between '
            '${existing.id} and ${definition.id}.',
          );
        }
        _definitionsByNormalizedKey[normalized] = definition;
      }
    }
  }

  void _validateDefinition(ExerciseDefinition definition) {
    if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(definition.id)) {
      throw FormatException('Invalid canonical id: ${definition.id}.');
    }
    if (definition.nameEn.trim().isEmpty ||
        definition.nameZhCn.trim().isEmpty) {
      throw FormatException('Missing bilingual name: ${definition.id}.');
    }
    if (normalizeExerciseKey(definition.nameEn) ==
        normalizeExerciseKey(definition.nameZhCn)) {
      throw FormatException(
        'Chinese name cannot be an English placeholder: ${definition.id}.',
      );
    }
    if (definition.sourceRevision.trim().isEmpty ||
        definition.license.trim().isEmpty ||
        definition.sourceIds.isEmpty) {
      throw FormatException('Incomplete evidence metadata: ${definition.id}.');
    }
    _validateSourceIds(definition.id, definition.sourceIds);
    _validateSourceIds(
      '${definition.id} ratio prior',
      definition.ratioPrior.sourceIds,
    );

    final muscles = {
      ...definition.muscles.primary,
      ...definition.muscles.secondary,
    };
    if (muscles.length !=
        definition.muscles.primary.length +
            definition.muscles.secondary.length) {
      throw FormatException('Duplicate muscle role: ${definition.id}.');
    }
    if (!muscles.containsAll(definition.muscles.weights.keys) ||
        !definition.muscles.weights.keys.toSet().containsAll(muscles)) {
      throw FormatException(
        'Muscle weights do not match roles: ${definition.id}.',
      );
    }
    final weightTotal = definition.muscles.weights.values.fold<double>(
      0,
      (sum, value) => sum + value,
    );
    if (definition.isSelectionSlot) {
      if (definition.movement != ExerciseMovement.selection ||
          definition.equipment != ExerciseEquipment.selection ||
          definition.loadSemantics != ExerciseLoadSemantics.selection ||
          muscles.isNotEmpty ||
          definition.muscles.weights.isNotEmpty ||
          definition.isCompetitionLift ||
          definition.strengthFamily != StrengthFamily.none ||
          definition.roundingIncrementKg != 0 ||
          definition.ratioPrior.mode != RatioPriorMode.notApplicable) {
        throw FormatException('Invalid selection slot: ${definition.id}.');
      }
    } else {
      if (definition.movement == ExerciseMovement.selection ||
          definition.equipment == ExerciseEquipment.selection ||
          definition.loadSemantics == ExerciseLoadSemantics.selection ||
          definition.muscles.primary.isEmpty ||
          definition.roundingIncrementKg <= 0 ||
          (weightTotal - 1).abs() > 0.0001) {
        throw FormatException('Incomplete exercise fields: ${definition.id}.');
      }
      if (definition.isCompetitionLift &&
          definition.strengthFamily == StrengthFamily.none) {
        throw FormatException(
          'Competition lift requires a strength family: ${definition.id}.',
        );
      }
    }

    final prior = definition.ratioPrior;
    final numericValues = [prior.lower, prior.center, prior.upper];
    switch (prior.mode) {
      case RatioPriorMode.ratio:
        if (definition.isSelectionSlot ||
            prior.anchor == StrengthFamily.none ||
            numericValues.any((value) => value == null) ||
            prior.lower! <= 0 ||
            prior.lower! > prior.center! ||
            prior.center! > prior.upper! ||
            prior.upper! > 1.25 ||
            prior.confidence == RatioConfidence.none ||
            (prior.evidenceGrade == RatioEvidenceGrade.identity &&
                prior.confidence != RatioConfidence.high) ||
            prior.evidenceGrade == RatioEvidenceGrade.calibrationOnly ||
            prior.evidenceGrade == RatioEvidenceGrade.notApplicable) {
          throw FormatException('Invalid numeric ratio: ${definition.id}.');
        }
        break;
      case RatioPriorMode.calibrationOnly:
        if (definition.isSelectionSlot ||
            prior.anchor != StrengthFamily.none ||
            numericValues.any((value) => value != null) ||
            prior.confidence != RatioConfidence.low ||
            prior.evidenceGrade != RatioEvidenceGrade.calibrationOnly) {
          throw FormatException(
            'Invalid calibration policy: ${definition.id}.',
          );
        }
        break;
      case RatioPriorMode.notApplicable:
        if (!definition.isSelectionSlot ||
            prior.anchor != StrengthFamily.none ||
            numericValues.any((value) => value != null) ||
            prior.confidence != RatioConfidence.none ||
            prior.evidenceGrade != RatioEvidenceGrade.notApplicable) {
          throw FormatException('Invalid slot ratio policy: ${definition.id}.');
        }
        break;
    }

    if ((definition.equipment == ExerciseEquipment.machine ||
            definition.equipment == ExerciseEquipment.cable) &&
        prior.mode != RatioPriorMode.calibrationOnly) {
      throw FormatException(
        'Machine/cable exercise must be calibration-only: ${definition.id}.',
      );
    }
  }

  void _validateSourceIds(String owner, List<String> sourceIds) {
    if (sourceIds.isEmpty) {
      throw FormatException('Missing sources for $owner.');
    }
    for (final sourceId in sourceIds) {
      if (!_sourcesById.containsKey(sourceId)) {
        throw FormatException('Unknown source "$sourceId" on $owner.');
      }
    }
  }
}

String normalizeExerciseKey(String value) {
  return value.trim().toLowerCase().replaceAll(
    RegExp(r'[^a-z0-9\u3400-\u9fff]+'),
    '',
  );
}

String customExerciseId(String value) {
  final normalized = normalizeExerciseKey(value);
  if (normalized.isNotEmpty) {
    return 'custom:$normalized';
  }
  final encoded = utf8.encode(value.trim().toLowerCase());
  final hex = encoded
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
  return 'custom:u${hex.isEmpty ? 'exercise' : hex}';
}

Map<String, dynamic> _requiredMap(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! Map<String, dynamic>) {
    throw FormatException('"$key" must be an object.');
  }
  return value;
}

List<Map<String, dynamic>> _objectList(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! List) {
    throw FormatException('"$key" must be a list.');
  }
  return value
      .map((item) {
        if (item is! Map<String, dynamic>) {
          throw FormatException('Every "$key" entry must be an object.');
        }
        return item;
      })
      .toList(growable: false);
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('"$key" must be a non-empty string.');
  }
  return value;
}

bool _requiredBool(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! bool) {
    throw FormatException('"$key" must be a boolean.');
  }
  return value;
}

int _requiredInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! int) {
    throw FormatException('"$key" must be an integer.');
  }
  return value;
}

double _requiredDouble(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! num) {
    throw FormatException('"$key" must be numeric.');
  }
  return value.toDouble();
}

double? _optionalDouble(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is! num) {
    throw FormatException('"$key" must be numeric when present.');
  }
  return value.toDouble();
}

List<String> _stringList(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! List || value.any((item) => item is! String)) {
    throw FormatException('"$key" must be a string list.');
  }
  return List.unmodifiable(value.cast<String>());
}

T _enumField<T extends Enum>(
  Map<String, dynamic> json,
  String key,
  List<T> values,
  String label,
) {
  return _enumByName(values, _requiredString(json, key), label);
}

T _enumByName<T extends Enum>(List<T> values, String name, String label) {
  for (final value in values) {
    if (value.name == name) {
      return value;
    }
  }
  throw FormatException('Unknown $label: $name.');
}

List<T> _enumList<T extends Enum>(
  Map<String, dynamic> json,
  String key,
  List<T> values,
  String label,
) {
  return _stringList(
    json,
    key,
  ).map((name) => _enumByName(values, name, label)).toList(growable: false);
}
