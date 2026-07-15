import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const defaultMilestoneExerciseIds = <String>{
  'squat',
  'bench_press',
  'deadlift',
};

class MilestoneExercisePreferences {
  MilestoneExercisePreferences({
    required this.schemaVersion,
    required Iterable<String> exerciseIds,
  }) : exerciseIds = Set<String>.unmodifiable(
         _normalizeMilestoneExerciseIds(exerciseIds),
       );

  static const currentSchemaVersion = 1;

  factory MilestoneExercisePreferences.defaults() {
    return MilestoneExercisePreferences(
      schemaVersion: currentSchemaVersion,
      exerciseIds: defaultMilestoneExerciseIds,
    );
  }

  factory MilestoneExercisePreferences.fromJson(Map<String, dynamic> json) {
    final schemaVersion = json['schemaVersion'];
    final rawIds = json['exerciseIds'];
    if (schemaVersion != currentSchemaVersion || rawIds is! List) {
      return MilestoneExercisePreferences.defaults();
    }
    final ids = rawIds
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet();
    return MilestoneExercisePreferences(
      schemaVersion: currentSchemaVersion,
      exerciseIds: ids,
    );
  }

  final int schemaVersion;
  final Set<String> exerciseIds;

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'exerciseIds': exerciseIds.toList(growable: false)..sort(),
  };

  MilestoneExercisePreferences copyWith({Iterable<String>? exerciseIds}) {
    return MilestoneExercisePreferences(
      schemaVersion: currentSchemaVersion,
      exerciseIds: exerciseIds ?? this.exerciseIds,
    );
  }
}

Set<String> _normalizeMilestoneExerciseIds(Iterable<String> exerciseIds) {
  final normalized = exerciseIds
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toSet();
  return normalized.isEmpty ? defaultMilestoneExerciseIds : normalized;
}

final milestoneExercisePreferencesProvider =
    StateNotifierProvider<
      MilestoneExercisePreferencesNotifier,
      MilestoneExercisePreferences
    >((ref) => MilestoneExercisePreferencesNotifier());

class MilestoneExercisePreferencesNotifier
    extends StateNotifier<MilestoneExercisePreferences> {
  MilestoneExercisePreferencesNotifier({
    SharedPreferences? preferences,
    bool loadPersisted = true,
  }) : _preferences = preferences,
       super(MilestoneExercisePreferences.defaults()) {
    if (loadPersisted && _hasServicesBinding) {
      _load();
    }
  }

  static const storageKey = 'milestone_exercise_preferences_v1';

  final SharedPreferences? _preferences;

  bool get _hasServicesBinding {
    if (_preferences != null) {
      return true;
    }
    try {
      ServicesBinding.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<SharedPreferences> _store() async =>
      _preferences ?? SharedPreferences.getInstance();

  Future<void> _load() async {
    try {
      final raw = (await _store()).getString(storageKey);
      if (raw == null) {
        return;
      }
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        state = MilestoneExercisePreferences.fromJson(decoded);
      }
    } catch (_) {
      // Keep deterministic Big Three defaults if persistence is unavailable.
      state = MilestoneExercisePreferences.defaults();
    }
  }

  Future<void> toggle(String exerciseId) async {
    final normalizedId = exerciseId.trim();
    if (normalizedId.isEmpty) {
      return;
    }
    final next = {...state.exerciseIds};
    if (!next.remove(normalizedId)) {
      next.add(normalizedId);
    }
    await _save(state.copyWith(exerciseIds: next));
  }

  Future<void> replace(Iterable<String> exerciseIds) async {
    final normalized = exerciseIds
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet();
    await _save(state.copyWith(exerciseIds: normalized));
  }

  Future<void> reset() async {
    await _save(MilestoneExercisePreferences.defaults());
  }

  Future<void> _save(MilestoneExercisePreferences value) async {
    state = value;
    await (await _store()).setString(storageKey, jsonEncode(value.toJson()));
  }
}
