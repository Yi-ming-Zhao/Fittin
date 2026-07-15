import 'package:fittin_v2/src/domain/exercise_performance_profile.dart';
import 'package:fittin_v2/src/domain/one_rep_max.dart';
import 'package:fittin_v2/src/domain/starting_load_estimator.dart';

const planStartLoadReviewEngineStateKey = 'planStartLoadReviewV1';

enum PlanStartLoadEntryKind {
  explicitWeight,
  trainingMaxPrescription,
  nonNumeric,
  reviewable,
}

class PlanStartRecommendationSnapshot {
  PlanStartRecommendationSnapshot({
    required this.suggestedWeightKg,
    required this.rawWeightKg,
    required this.source,
    required this.confidence,
    required this.safetyFactor,
    required List<StartingLoadWarningCode> warnings,
    required this.sourceExerciseId,
    required this.sourceWorkoutReference,
    required this.sourceCompletedAt,
    required this.sourceSetIndex,
    required this.sourceValueKg,
    required this.sourceObservedReps,
    required this.sourceFormulaKey,
    required this.conversionFormulaKey,
    required this.anchorFamilyKey,
    required this.ratioLower,
    required this.ratioCenter,
    required this.ratioUpper,
    required this.ratioConfidenceKey,
    required this.ratioEvidenceGradeKey,
    required this.catalogVersion,
    required this.profileCatalogVersion,
  }) : warnings = List.unmodifiable(warnings);

  factory PlanStartRecommendationSnapshot.fromRecommendation(
    StartingLoadRecommendation recommendation,
  ) {
    final provenance = recommendation.provenance;
    return PlanStartRecommendationSnapshot(
      suggestedWeightKg: recommendation.weightKg,
      rawWeightKg: recommendation.rawWeightKg,
      source: provenance.source,
      confidence: recommendation.confidence,
      safetyFactor: recommendation.safetyFactor,
      warnings: recommendation.warnings,
      sourceExerciseId: provenance.sourceExerciseId,
      sourceWorkoutReference: provenance.sourceSet?.workoutReference,
      sourceCompletedAt: provenance.sourceSet?.completedAt,
      sourceSetIndex: provenance.sourceSet?.setIndex,
      sourceValueKg: provenance.sourceValueKg,
      sourceObservedReps: provenance.sourceObservedReps,
      sourceFormulaKey: provenance.sourceFormula?.key,
      conversionFormulaKey: provenance.conversionFormula?.key,
      anchorFamilyKey: provenance.anchorFamily?.name,
      ratioLower: provenance.ratioLower,
      ratioCenter: provenance.ratioCenter,
      ratioUpper: provenance.ratioUpper,
      ratioConfidenceKey: provenance.ratioConfidence?.name,
      ratioEvidenceGradeKey: provenance.ratioEvidenceGrade?.name,
      catalogVersion: provenance.catalogVersion,
      profileCatalogVersion: provenance.profileCatalogVersion,
    );
  }

  factory PlanStartRecommendationSnapshot.fromJson(Map<String, dynamic> json) {
    return PlanStartRecommendationSnapshot(
      suggestedWeightKg: _optionalDouble(json['suggestedWeightKg']),
      rawWeightKg: _optionalDouble(json['rawWeightKg']),
      source: _enumByName(
        StartingLoadSource.values,
        json['source'],
        StartingLoadSource.unavailable,
      ),
      confidence: _enumByName(
        PerformanceConfidence.values,
        json['confidence'],
        PerformanceConfidence.unavailable,
      ),
      safetyFactor: _optionalDouble(json['safetyFactor']) ?? 0,
      warnings: (json['warnings'] as List<dynamic>? ?? const [])
          .map(
            (value) => _enumByNameOrNull(StartingLoadWarningCode.values, value),
          )
          .whereType<StartingLoadWarningCode>()
          .toList(),
      sourceExerciseId: json['sourceExerciseId'] as String? ?? '',
      sourceWorkoutReference: json['sourceWorkoutReference'] as String?,
      sourceCompletedAt: DateTime.tryParse(
        json['sourceCompletedAt'] as String? ?? '',
      ),
      sourceSetIndex: (json['sourceSetIndex'] as num?)?.toInt(),
      sourceValueKg: _optionalDouble(json['sourceValueKg']),
      sourceObservedReps: (json['sourceObservedReps'] as num?)?.toInt(),
      sourceFormulaKey: json['sourceFormulaKey'] as String?,
      conversionFormulaKey: json['conversionFormulaKey'] as String?,
      anchorFamilyKey: json['anchorFamilyKey'] as String?,
      ratioLower: _optionalDouble(json['ratioLower']),
      ratioCenter: _optionalDouble(json['ratioCenter']),
      ratioUpper: _optionalDouble(json['ratioUpper']),
      ratioConfidenceKey: json['ratioConfidenceKey'] as String?,
      ratioEvidenceGradeKey: json['ratioEvidenceGradeKey'] as String?,
      catalogVersion: json['catalogVersion'] as String? ?? '',
      profileCatalogVersion: json['profileCatalogVersion'] as String? ?? '',
    );
  }

  final double? suggestedWeightKg;
  final double? rawWeightKg;
  final StartingLoadSource source;
  final PerformanceConfidence confidence;
  final double safetyFactor;
  final List<StartingLoadWarningCode> warnings;
  final String sourceExerciseId;
  final String? sourceWorkoutReference;
  final DateTime? sourceCompletedAt;
  final int? sourceSetIndex;
  final double? sourceValueKg;
  final int? sourceObservedReps;
  final String? sourceFormulaKey;
  final String? conversionFormulaKey;
  final String? anchorFamilyKey;
  final double? ratioLower;
  final double? ratioCenter;
  final double? ratioUpper;
  final String? ratioConfidenceKey;
  final String? ratioEvidenceGradeKey;
  final String catalogVersion;
  final String profileCatalogVersion;

  Map<String, dynamic> toJson() => {
    'suggestedWeightKg': suggestedWeightKg,
    'rawWeightKg': rawWeightKg,
    'source': source.name,
    'confidence': confidence.name,
    'safetyFactor': safetyFactor,
    'warnings': warnings.map((warning) => warning.name).toList(),
    'sourceExerciseId': sourceExerciseId,
    'sourceWorkoutReference': sourceWorkoutReference,
    'sourceCompletedAt': sourceCompletedAt?.toUtc().toIso8601String(),
    'sourceSetIndex': sourceSetIndex,
    'sourceValueKg': sourceValueKg,
    'sourceObservedReps': sourceObservedReps,
    'sourceFormulaKey': sourceFormulaKey,
    'conversionFormulaKey': conversionFormulaKey,
    'anchorFamilyKey': anchorFamilyKey,
    'ratioLower': ratioLower,
    'ratioCenter': ratioCenter,
    'ratioUpper': ratioUpper,
    'ratioConfidenceKey': ratioConfidenceKey,
    'ratioEvidenceGradeKey': ratioEvidenceGradeKey,
    'catalogVersion': catalogVersion,
    'profileCatalogVersion': profileCatalogVersion,
  };
}

class PlanStartLoadEntry {
  const PlanStartLoadEntry({
    required this.exerciseOccurrenceId,
    required this.exerciseDefinitionId,
    required this.exerciseName,
    required this.kind,
    required this.planWeightKg,
    required this.confirmedWeightKg,
    required this.targetReps,
    required this.targetRir,
    required this.recommendation,
  });

  factory PlanStartLoadEntry.fromJson(Map<String, dynamic> json) {
    final recommendation = json['recommendation'];
    return PlanStartLoadEntry(
      exerciseOccurrenceId: json['exerciseOccurrenceId'] as String? ?? '',
      exerciseDefinitionId: json['exerciseDefinitionId'] as String? ?? '',
      exerciseName: json['exerciseName'] as String? ?? '',
      kind: _enumByName(
        PlanStartLoadEntryKind.values,
        json['kind'],
        PlanStartLoadEntryKind.nonNumeric,
      ),
      planWeightKg: _optionalDouble(json['planWeightKg']),
      confirmedWeightKg: _optionalDouble(json['confirmedWeightKg']),
      targetReps: (json['targetReps'] as num?)?.toInt() ?? 0,
      targetRir: _optionalDouble(json['targetRir']) ?? 0,
      recommendation: recommendation is Map<String, dynamic>
          ? PlanStartRecommendationSnapshot.fromJson(recommendation)
          : null,
    );
  }

  final String exerciseOccurrenceId;
  final String exerciseDefinitionId;
  final String exerciseName;
  final PlanStartLoadEntryKind kind;
  final double? planWeightKg;
  final double? confirmedWeightKg;
  final int targetReps;
  final double targetRir;
  final PlanStartRecommendationSnapshot? recommendation;

  bool get isEditable => kind == PlanStartLoadEntryKind.reviewable;

  bool get wasEdited {
    if (!isEditable) {
      return false;
    }
    final suggested = recommendation?.suggestedWeightKg;
    final confirmed = confirmedWeightKg;
    if (suggested == null || confirmed == null) {
      return suggested != confirmed;
    }
    return (suggested - confirmed).abs() > 0.0001;
  }

  PlanStartLoadEntry withConfirmedWeight(double? value) {
    return PlanStartLoadEntry(
      exerciseOccurrenceId: exerciseOccurrenceId,
      exerciseDefinitionId: exerciseDefinitionId,
      exerciseName: exerciseName,
      kind: kind,
      planWeightKg: planWeightKg,
      confirmedWeightKg: value,
      targetReps: targetReps,
      targetRir: targetRir,
      recommendation: recommendation,
    );
  }

  Map<String, dynamic> toJson() => {
    'exerciseOccurrenceId': exerciseOccurrenceId,
    'exerciseDefinitionId': exerciseDefinitionId,
    'exerciseName': exerciseName,
    'kind': kind.name,
    'planWeightKg': planWeightKg,
    'confirmedWeightKg': confirmedWeightKg,
    'targetReps': targetReps,
    'targetRir': targetRir,
    'recommendation': recommendation?.toJson(),
  };
}

class PlanStartLoadReview {
  PlanStartLoadReview({
    required this.templateId,
    required this.catalogVersion,
    required this.profileFormulaKey,
    required this.profileSourceFingerprint,
    required List<PlanStartLoadEntry> entries,
  }) : entries = List.unmodifiable(entries);

  static const schemaVersion = 1;

  factory PlanStartLoadReview.fromJson(Map<String, dynamic> json) {
    if (json['schemaVersion'] != schemaVersion) {
      throw const FormatException('Unsupported plan-start review version.');
    }
    final rawEntries = json['entries'];
    if (rawEntries is! List) {
      throw const FormatException('Plan-start review entries are missing.');
    }
    return PlanStartLoadReview(
      templateId: json['templateId'] as String? ?? '',
      catalogVersion: json['catalogVersion'] as String? ?? '',
      profileFormulaKey: json['profileFormulaKey'] as String? ?? '',
      profileSourceFingerprint:
          json['profileSourceFingerprint'] as String? ?? '',
      entries: rawEntries
          .whereType<Map<String, dynamic>>()
          .map(PlanStartLoadEntry.fromJson)
          .toList(),
    );
  }

  final String templateId;
  final String catalogVersion;
  final String profileFormulaKey;
  final String profileSourceFingerprint;
  final List<PlanStartLoadEntry> entries;

  List<PlanStartLoadEntry> get editableEntries =>
      entries.where((entry) => entry.isEditable).toList(growable: false);

  Map<String, double> get confirmedOverridesKg => {
    for (final entry in editableEntries)
      if (entry.confirmedWeightKg != null && entry.confirmedWeightKg! > 0)
        entry.exerciseOccurrenceId: entry.confirmedWeightKg!,
  };

  PlanStartLoadReview withConfirmedWeights(Map<String, double?> weights) {
    return PlanStartLoadReview(
      templateId: templateId,
      catalogVersion: catalogVersion,
      profileFormulaKey: profileFormulaKey,
      profileSourceFingerprint: profileSourceFingerprint,
      entries: [
        for (final entry in entries)
          entry.isEditable && weights.containsKey(entry.exerciseOccurrenceId)
              ? entry.withConfirmedWeight(weights[entry.exerciseOccurrenceId])
              : entry,
      ],
    );
  }

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'templateId': templateId,
    'catalogVersion': catalogVersion,
    'profileFormulaKey': profileFormulaKey,
    'profileSourceFingerprint': profileSourceFingerprint,
    'entries': entries.map((entry) => entry.toJson()).toList(),
  };
}

Map<String, dynamic> engineStateWithPlanStartLoadReview(
  Map<String, dynamic> engineState,
  PlanStartLoadReview? review,
) {
  if (review == null) {
    return engineState;
  }
  return {...engineState, planStartLoadReviewEngineStateKey: review.toJson()};
}

PlanStartLoadReview? planStartLoadReviewFromEngineState(
  Map<String, dynamic> engineState,
) {
  final value = engineState[planStartLoadReviewEngineStateKey];
  if (value is! Map<String, dynamic>) {
    return null;
  }
  try {
    return PlanStartLoadReview.fromJson(value);
  } on FormatException {
    return null;
  }
}

T _enumByName<T extends Enum>(List<T> values, Object? raw, T fallback) {
  if (raw is String) {
    for (final value in values) {
      if (value.name == raw) {
        return value;
      }
    }
  }
  return fallback;
}

T? _enumByNameOrNull<T extends Enum>(List<T> values, Object? raw) {
  if (raw is String) {
    for (final value in values) {
      if (value.name == raw) {
        return value;
      }
    }
  }
  return null;
}

double? _optionalDouble(Object? value) {
  return value is num ? value.toDouble() : null;
}
