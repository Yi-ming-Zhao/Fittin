import 'dart:collection';

import 'package:fittin_v2/src/domain/exercise_library.dart';
import 'package:fittin_v2/src/domain/exercise_performance_profile.dart';
import 'package:fittin_v2/src/domain/one_rep_max.dart';

enum StartingLoadSource {
  unavailable,
  existingWeight,
  sameExerciseObservedRm,
  sameExerciseActualOneRepMax,
  sameExerciseEstimatedOneRepMax,
  anchorRatio,
}

enum StartingLoadWarningCode {
  editableSuggestion,
  lowConfidence,
  formulaBasedConversion,
  estimatedOneRepMaxSource,
  catalogRatioPrior,
  ratioRangeIsNotGuarantee,
  equipmentCalibrationRequired,
  equipmentSpecificLoad,
  bodyweightLoadUnsupported,
  bandResistanceUnsupported,
  selectionSlotUnsupported,
  customExerciseMetadataMissing,
  invalidTarget,
  targetRepsOutsideFormulaRange,
  noSameExerciseData,
  noAnchorData,
  fractionalRirRoundedUp,
  roundedBelowMinimum,
  catalogVersionMismatch,
}

class StartingLoadProvenance {
  const StartingLoadProvenance({
    required this.source,
    required this.sourceExerciseId,
    required this.catalogVersion,
    required this.profileCatalogVersion,
    required this.sourceSet,
    required this.sourceValueKg,
    required this.sourceObservedReps,
    required this.sourceFormula,
    required this.conversionFormula,
    required this.anchorFamily,
    required this.ratioLower,
    required this.ratioCenter,
    required this.ratioUpper,
    required this.ratioConfidence,
    required this.ratioEvidenceGrade,
  });

  final StartingLoadSource source;
  final String sourceExerciseId;
  final String catalogVersion;
  final String profileCatalogVersion;
  final PerformanceSetSource? sourceSet;
  final double? sourceValueKg;
  final int? sourceObservedReps;
  final OneRepMaxFormula? sourceFormula;
  final OneRepMaxFormula? conversionFormula;
  final StrengthFamily? anchorFamily;
  final double? ratioLower;
  final double? ratioCenter;
  final double? ratioUpper;
  final RatioConfidence? ratioConfidence;
  final RatioEvidenceGrade? ratioEvidenceGrade;
}

class StartingLoadRecommendation {
  StartingLoadRecommendation({
    required this.weightKg,
    required this.rawWeightKg,
    required this.targetReps,
    required this.targetRir,
    required this.effectiveReps,
    required this.roundingIncrementKg,
    required this.confidence,
    required this.safetyFactor,
    required this.loadSemantics,
    required List<StartingLoadWarningCode> warnings,
    required this.provenance,
  }) : warnings = List.unmodifiable(LinkedHashSet.of(warnings));

  final double? weightKg;
  final double? rawWeightKg;
  final int targetReps;
  final double targetRir;
  final int effectiveReps;
  final double roundingIncrementKg;
  final PerformanceConfidence confidence;
  final double safetyFactor;
  final ExerciseLoadSemantics? loadSemantics;
  final List<StartingLoadWarningCode> warnings;
  final StartingLoadProvenance provenance;

  bool get hasNumericLoad => weightKg != null && weightKg! > 0;

  bool get isAutomaticEstimate {
    return hasNumericLoad &&
        provenance.source != StartingLoadSource.existingWeight;
  }
}

class StartingLoadEstimator {
  const StartingLoadEstimator();

  StartingLoadRecommendation estimate({
    required ExerciseLibrary library,
    required ResolvedExercise exercise,
    required ExercisePerformanceProfileProjection profiles,
    required int targetReps,
    double targetRir = 3,
    double? existingWeightKg,
    double? roundingIncrementKg,
    OneRepMaxFormula formula = OneRepMaxFormula.epley,
    bool equipmentCalibrationConfirmed = false,
  }) {
    final definition = exercise.definition;
    final increment = _validIncrement(
      roundingIncrementKg,
      definition?.roundingIncrementKg,
    );
    final existing = existingWeightKg;
    if (existing != null && existing.isFinite && existing > 0) {
      return StartingLoadRecommendation(
        weightKg: existing,
        rawWeightKg: existing,
        targetReps: targetReps,
        targetRir: targetRir,
        effectiveReps: _safeEffectiveReps(targetReps, targetRir),
        roundingIncrementKg: increment,
        confidence: PerformanceConfidence.high,
        safetyFactor: 1,
        loadSemantics: definition?.loadSemantics,
        warnings: const [],
        provenance: _provenance(
          source: StartingLoadSource.existingWeight,
          sourceExerciseId: exercise.id,
          library: library,
          profiles: profiles,
        ),
      );
    }

    if (targetReps <= 0 ||
        !targetRir.isFinite ||
        targetRir < 0 ||
        targetRir > 1000) {
      return _unavailable(
        library: library,
        exercise: exercise,
        profiles: profiles,
        targetReps: targetReps,
        targetRir: targetRir,
        effectiveReps: 0,
        increment: increment,
        warnings: const [StartingLoadWarningCode.invalidTarget],
      );
    }

    final effectiveReps = (targetReps + targetRir).ceil();
    final initialWarnings = <StartingLoadWarningCode>[];
    if (targetRir != targetRir.truncateToDouble()) {
      initialWarnings.add(StartingLoadWarningCode.fractionalRirRoundedUp);
    }
    if (profiles.catalogVersion != library.catalogVersion) {
      initialWarnings.add(StartingLoadWarningCode.catalogVersionMismatch);
    }
    final profile = profiles[exercise.id];

    if (definition?.isSelectionSlot ?? false) {
      return _unavailable(
        library: library,
        exercise: exercise,
        profiles: profiles,
        targetReps: targetReps,
        targetRir: targetRir,
        effectiveReps: effectiveReps,
        increment: increment,
        warnings: [
          ...initialWarnings,
          StartingLoadWarningCode.selectionSlotUnsupported,
        ],
      );
    }
    if (definition?.loadSemantics == ExerciseLoadSemantics.bodyweight ||
        (profile?.isBodyweightOnly ?? false)) {
      return _unavailable(
        library: library,
        exercise: exercise,
        profiles: profiles,
        targetReps: targetReps,
        targetRir: targetRir,
        effectiveReps: effectiveReps,
        increment: increment,
        warnings: [
          ...initialWarnings,
          StartingLoadWarningCode.bodyweightLoadUnsupported,
        ],
      );
    }
    if (definition?.loadSemantics == ExerciseLoadSemantics.bandResistance) {
      return _unavailable(
        library: library,
        exercise: exercise,
        profiles: profiles,
        targetReps: targetReps,
        targetRir: targetRir,
        effectiveReps: effectiveReps,
        increment: increment,
        warnings: [
          ...initialWarnings,
          StartingLoadWarningCode.bandResistanceUnsupported,
        ],
      );
    }

    final equipmentSpecific =
        definition?.equipment == ExerciseEquipment.machine ||
        definition?.equipment == ExerciseEquipment.cable ||
        definition?.loadSemantics == ExerciseLoadSemantics.machineStack ||
        definition?.loadSemantics == ExerciseLoadSemantics.cableStack ||
        (profile?.requiresEquipmentCalibration ?? false);
    if (equipmentSpecific && !equipmentCalibrationConfirmed) {
      return _unavailable(
        library: library,
        exercise: exercise,
        profiles: profiles,
        targetReps: targetReps,
        targetRir: targetRir,
        effectiveReps: effectiveReps,
        increment: increment,
        warnings: [
          ...initialWarnings,
          StartingLoadWarningCode.equipmentCalibrationRequired,
          StartingLoadWarningCode.equipmentSpecificLoad,
        ],
      );
    }

    if (profile != null) {
      final sameExercise = _sameExerciseCandidate(
        profile: profile,
        effectiveReps: effectiveReps,
        formula: formula,
      );
      if (sameExercise != null) {
        var confidence = sameExercise.confidence;
        final warnings = <StartingLoadWarningCode>[
          ...initialWarnings,
          StartingLoadWarningCode.editableSuggestion,
          ...sameExercise.warnings,
        ];
        if (definition == null) {
          confidence = confidence.capAt(PerformanceConfidence.low);
          warnings.add(StartingLoadWarningCode.customExerciseMetadataMissing);
        }
        if (equipmentSpecific) {
          confidence = confidence.capAt(PerformanceConfidence.low);
          warnings.add(StartingLoadWarningCode.equipmentSpecificLoad);
        }
        return _recommend(
          library: library,
          profiles: profiles,
          exercise: exercise,
          targetReps: targetReps,
          targetRir: targetRir,
          effectiveReps: effectiveReps,
          increment: increment,
          rawWeightKg: sameExercise.rawWeightKg,
          confidence: confidence,
          warnings: warnings,
          source: sameExercise.source,
          sourceExerciseId: exercise.id,
          sourceSet: sameExercise.record.source,
          sourceValueKg: sameExercise.sourceValueKg,
          sourceObservedReps: sameExercise.observedReps,
          sourceFormula: sameExercise.record.formula,
          conversionFormula: sameExercise.conversionFormula,
        );
      }
    }

    initialWarnings.add(StartingLoadWarningCode.noSameExerciseData);
    if (definition == null) {
      return _unavailable(
        library: library,
        exercise: exercise,
        profiles: profiles,
        targetReps: targetReps,
        targetRir: targetRir,
        effectiveReps: effectiveReps,
        increment: increment,
        warnings: [
          ...initialWarnings,
          StartingLoadWarningCode.customExerciseMetadataMissing,
          StartingLoadWarningCode.noAnchorData,
        ],
      );
    }

    final prior = definition.ratioPrior;
    if (!prior.hasNumericRatio || prior.center == null) {
      return _unavailable(
        library: library,
        exercise: exercise,
        profiles: profiles,
        targetReps: targetReps,
        targetRir: targetRir,
        effectiveReps: effectiveReps,
        increment: increment,
        warnings: [
          ...initialWarnings,
          if (equipmentSpecific) StartingLoadWarningCode.equipmentSpecificLoad,
          StartingLoadWarningCode.noAnchorData,
        ],
      );
    }
    if (effectiveReps >
        ExercisePerformanceProfileService.maximumEstimatedReps) {
      return _unavailable(
        library: library,
        exercise: exercise,
        profiles: profiles,
        targetReps: targetReps,
        targetRir: targetRir,
        effectiveReps: effectiveReps,
        increment: increment,
        warnings: [
          ...initialWarnings,
          StartingLoadWarningCode.targetRepsOutsideFormulaRange,
        ],
      );
    }

    final anchorDefinition = _anchorDefinition(library, prior.anchor);
    final anchorProfile = anchorDefinition == null
        ? null
        : profiles[anchorDefinition.id];
    final anchorCapacity = anchorProfile == null
        ? null
        : _preferredOneRepMax(anchorProfile);
    if (anchorDefinition == null || anchorCapacity == null) {
      return _unavailable(
        library: library,
        exercise: exercise,
        profiles: profiles,
        targetReps: targetReps,
        targetRir: targetRir,
        effectiveReps: effectiveReps,
        increment: increment,
        warnings: [...initialWarnings, StartingLoadWarningCode.noAnchorData],
      );
    }

    final ratioOneRepMax = anchorCapacity.record.valueKg * prior.center!;
    final rawWeight = _repetitionMaximum(
      oneRepMaxKg: ratioOneRepMax,
      reps: effectiveReps,
      formula: formula,
    );
    if (rawWeight == null) {
      return _unavailable(
        library: library,
        exercise: exercise,
        profiles: profiles,
        targetReps: targetReps,
        targetRir: targetRir,
        effectiveReps: effectiveReps,
        increment: increment,
        warnings: [
          ...initialWarnings,
          StartingLoadWarningCode.targetRepsOutsideFormulaRange,
        ],
      );
    }

    final confidence = anchorCapacity.record.confidence.capAt(
      _ratioConfidence(prior.confidence),
    );
    return _recommend(
      library: library,
      profiles: profiles,
      exercise: exercise,
      targetReps: targetReps,
      targetRir: targetRir,
      effectiveReps: effectiveReps,
      increment: increment,
      rawWeightKg: rawWeight,
      confidence: confidence,
      warnings: [
        ...initialWarnings,
        StartingLoadWarningCode.editableSuggestion,
        StartingLoadWarningCode.formulaBasedConversion,
        StartingLoadWarningCode.catalogRatioPrior,
        StartingLoadWarningCode.ratioRangeIsNotGuarantee,
        if (!anchorCapacity.record.isActual)
          StartingLoadWarningCode.estimatedOneRepMaxSource,
      ],
      source: StartingLoadSource.anchorRatio,
      sourceExerciseId: anchorDefinition.id,
      sourceSet: anchorCapacity.record.source,
      sourceValueKg: anchorCapacity.record.valueKg,
      sourceFormula: anchorCapacity.record.formula,
      conversionFormula: formula,
      anchorFamily: prior.anchor,
      ratioLower: prior.lower,
      ratioCenter: prior.center,
      ratioUpper: prior.upper,
      ratioConfidence: prior.confidence,
      ratioEvidenceGrade: prior.evidenceGrade,
    );
  }
}

class _LoadCandidate {
  const _LoadCandidate({
    required this.rawWeightKg,
    required this.confidence,
    required this.source,
    required this.record,
    required this.sourceValueKg,
    required this.observedReps,
    required this.conversionFormula,
    required this.warnings,
  });

  final double rawWeightKg;
  final PerformanceConfidence confidence;
  final StartingLoadSource source;
  final OneRepMaxRecord record;
  final double sourceValueKg;
  final int? observedReps;
  final OneRepMaxFormula? conversionFormula;
  final List<StartingLoadWarningCode> warnings;
}

_LoadCandidate? _sameExerciseCandidate({
  required ExercisePerformanceProfile profile,
  required int effectiveReps,
  required OneRepMaxFormula formula,
}) {
  final observed = profile.observedRepMax(effectiveReps);
  if (observed != null) {
    final record = OneRepMaxRecord(
      valueKg: observed.weightKg,
      isActual: effectiveReps == 1,
      formula: null,
      confidence: observed.confidence,
      source: observed.source,
    );
    return _LoadCandidate(
      rawWeightKg: observed.weightKg,
      confidence: observed.confidence,
      source: StartingLoadSource.sameExerciseObservedRm,
      record: record,
      sourceValueKg: observed.weightKg,
      observedReps: effectiveReps,
      conversionFormula: null,
      warnings: const [],
    );
  }
  if (effectiveReps > ExercisePerformanceProfileService.maximumEstimatedReps) {
    return null;
  }

  final capacity = _preferredOneRepMax(profile);
  if (capacity == null) {
    return null;
  }
  final converted = _repetitionMaximum(
    oneRepMaxKg: capacity.record.valueKg,
    reps: effectiveReps,
    formula: formula,
  );
  if (converted == null) {
    return null;
  }
  return _LoadCandidate(
    rawWeightKg: converted,
    confidence: capacity.record.confidence,
    source: capacity.record.isActual
        ? StartingLoadSource.sameExerciseActualOneRepMax
        : StartingLoadSource.sameExerciseEstimatedOneRepMax,
    record: capacity.record,
    sourceValueKg: capacity.record.valueKg,
    observedReps: null,
    conversionFormula: formula,
    warnings: [
      StartingLoadWarningCode.formulaBasedConversion,
      if (!capacity.record.isActual)
        StartingLoadWarningCode.estimatedOneRepMaxSource,
    ],
  );
}

({OneRepMaxRecord record})? _preferredOneRepMax(
  ExercisePerformanceProfile profile,
) {
  final actual = profile.actualOneRepMax;
  if (actual != null) {
    return (record: actual);
  }
  final estimated = profile.estimatedOneRepMax;
  if (estimated != null) {
    return (record: estimated);
  }
  return null;
}

ExerciseDefinition? _anchorDefinition(
  ExerciseLibrary library,
  StrengthFamily family,
) {
  final matches =
      library.definitions
          .where(
            (definition) =>
                definition.isCompetitionLift &&
                definition.strengthFamily == family,
          )
          .toList()
        ..sort((a, b) => a.id.compareTo(b.id));
  return matches.isEmpty ? null : matches.first;
}

double? _repetitionMaximum({
  required double oneRepMaxKg,
  required int reps,
  required OneRepMaxFormula formula,
}) {
  if (!oneRepMaxKg.isFinite || oneRepMaxKg <= 0 || reps <= 0 || reps > 10) {
    return null;
  }
  if (reps == 1) {
    return oneRepMaxKg;
  }
  final multiplier = estimateOneRepMax(formula: formula, weight: 1, reps: reps);
  if (multiplier == null || !multiplier.isFinite || multiplier <= 0) {
    return null;
  }
  return oneRepMaxKg / multiplier;
}

PerformanceConfidence _ratioConfidence(RatioConfidence confidence) {
  return switch (confidence) {
    RatioConfidence.high => PerformanceConfidence.high,
    RatioConfidence.medium => PerformanceConfidence.medium,
    RatioConfidence.low => PerformanceConfidence.low,
    RatioConfidence.none => PerformanceConfidence.unavailable,
  };
}

double _safetyFactor(PerformanceConfidence confidence) {
  return switch (confidence) {
    PerformanceConfidence.high => 0.95,
    PerformanceConfidence.medium => 0.90,
    PerformanceConfidence.low => 0.85,
    PerformanceConfidence.unavailable => 0,
  };
}

double _validIncrement(double? requested, double? catalog) {
  if (requested != null && requested.isFinite && requested > 0) {
    return requested;
  }
  if (catalog != null && catalog.isFinite && catalog > 0) {
    return catalog;
  }
  return 2.5;
}

int _safeEffectiveReps(int targetReps, double targetRir) {
  if (targetReps <= 0 || !targetRir.isFinite || targetRir < 0) {
    return 0;
  }
  return (targetReps + targetRir).ceil();
}

StartingLoadRecommendation _recommend({
  required ExerciseLibrary library,
  required ExercisePerformanceProfileProjection profiles,
  required ResolvedExercise exercise,
  required int targetReps,
  required double targetRir,
  required int effectiveReps,
  required double increment,
  required double rawWeightKg,
  required PerformanceConfidence confidence,
  required List<StartingLoadWarningCode> warnings,
  required StartingLoadSource source,
  required String sourceExerciseId,
  required PerformanceSetSource sourceSet,
  required double sourceValueKg,
  int? sourceObservedReps,
  OneRepMaxFormula? sourceFormula,
  OneRepMaxFormula? conversionFormula,
  StrengthFamily? anchorFamily,
  double? ratioLower,
  double? ratioCenter,
  double? ratioUpper,
  RatioConfidence? ratioConfidence,
  RatioEvidenceGrade? ratioEvidenceGrade,
}) {
  final factor = _safetyFactor(confidence);
  final adjusted = rawWeightKg * factor;
  final rounded = _roundDown(adjusted, increment);
  if (!rounded.isFinite || rounded <= 0) {
    return _unavailable(
      library: library,
      exercise: exercise,
      profiles: profiles,
      targetReps: targetReps,
      targetRir: targetRir,
      effectiveReps: effectiveReps,
      increment: increment,
      warnings: [...warnings, StartingLoadWarningCode.roundedBelowMinimum],
    );
  }
  final finalWarnings = <StartingLoadWarningCode>[
    ...warnings,
    if (confidence == PerformanceConfidence.low)
      StartingLoadWarningCode.lowConfidence,
  ];
  return StartingLoadRecommendation(
    weightKg: rounded,
    rawWeightKg: rawWeightKg,
    targetReps: targetReps,
    targetRir: targetRir,
    effectiveReps: effectiveReps,
    roundingIncrementKg: increment,
    confidence: confidence,
    safetyFactor: factor,
    loadSemantics: exercise.definition?.loadSemantics,
    warnings: finalWarnings,
    provenance: _provenance(
      source: source,
      sourceExerciseId: sourceExerciseId,
      library: library,
      profiles: profiles,
      sourceSet: sourceSet,
      sourceValueKg: sourceValueKg,
      sourceObservedReps: sourceObservedReps,
      sourceFormula: sourceFormula,
      conversionFormula: conversionFormula,
      anchorFamily: anchorFamily,
      ratioLower: ratioLower,
      ratioCenter: ratioCenter,
      ratioUpper: ratioUpper,
      ratioConfidence: ratioConfidence,
      ratioEvidenceGrade: ratioEvidenceGrade,
    ),
  );
}

StartingLoadRecommendation _unavailable({
  required ExerciseLibrary library,
  required ResolvedExercise exercise,
  required ExercisePerformanceProfileProjection profiles,
  required int targetReps,
  required double targetRir,
  required int effectiveReps,
  required double increment,
  required List<StartingLoadWarningCode> warnings,
}) {
  return StartingLoadRecommendation(
    weightKg: null,
    rawWeightKg: null,
    targetReps: targetReps,
    targetRir: targetRir,
    effectiveReps: effectiveReps,
    roundingIncrementKg: increment,
    confidence: PerformanceConfidence.unavailable,
    safetyFactor: 0,
    loadSemantics: exercise.definition?.loadSemantics,
    warnings: warnings,
    provenance: _provenance(
      source: StartingLoadSource.unavailable,
      sourceExerciseId: exercise.id,
      library: library,
      profiles: profiles,
    ),
  );
}

StartingLoadProvenance _provenance({
  required StartingLoadSource source,
  required String sourceExerciseId,
  required ExerciseLibrary library,
  required ExercisePerformanceProfileProjection profiles,
  PerformanceSetSource? sourceSet,
  double? sourceValueKg,
  int? sourceObservedReps,
  OneRepMaxFormula? sourceFormula,
  OneRepMaxFormula? conversionFormula,
  StrengthFamily? anchorFamily,
  double? ratioLower,
  double? ratioCenter,
  double? ratioUpper,
  RatioConfidence? ratioConfidence,
  RatioEvidenceGrade? ratioEvidenceGrade,
}) {
  return StartingLoadProvenance(
    source: source,
    sourceExerciseId: sourceExerciseId,
    catalogVersion: library.catalogVersion,
    profileCatalogVersion: profiles.catalogVersion,
    sourceSet: sourceSet,
    sourceValueKg: sourceValueKg,
    sourceObservedReps: sourceObservedReps,
    sourceFormula: sourceFormula,
    conversionFormula: conversionFormula,
    anchorFamily: anchorFamily,
    ratioLower: ratioLower,
    ratioCenter: ratioCenter,
    ratioUpper: ratioUpper,
    ratioConfidence: ratioConfidence,
    ratioEvidenceGrade: ratioEvidenceGrade,
  );
}

double _roundDown(double value, double increment) {
  return ((value + 1e-9) / increment).floor() * increment;
}
