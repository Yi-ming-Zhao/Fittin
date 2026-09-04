import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/exercise_library_provider.dart';
import 'package:fittin_v2/src/application/sync_refresh_provider.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/domain/models/cardio.dart';
import 'package:fittin_v2/src/domain/models/custom_exercise.dart';
import 'package:fittin_v2/src/domain/models/custom_theme_palette.dart';
import 'package:fittin_v2/src/domain/models/user_content.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final userContentServiceProvider = Provider<UserContentService>((ref) {
  return UserContentService(ref);
});

final customExerciseDocumentsProvider =
    FutureProvider<List<UserContentDocument>>((ref) async {
      ref.watch(syncRefreshProvider);
      final owner = ref.watch(currentUserIdProvider);
      return ref
          .watch(databaseRepositoryProvider)
          .fetchUserContents(
            UserContentKind.customExercise,
            ownerUserId: owner,
          );
    });

final exerciseCatalogProvider = FutureProvider<List<ExerciseCatalogItem>>((
  ref,
) async {
  final builtIn = await ref.watch(exerciseLibraryProvider.future);
  final customDocs = await ref.watch(customExerciseDocumentsProvider.future);
  final items = <ExerciseCatalogItem>[
    for (final definition in builtIn.definitions)
      if (!definition.isSelectionSlot)
        ExerciseCatalogItem.fromBuiltIn(definition),
    for (final document in customDocs)
      ExerciseCatalogItem.fromCustom(
        CustomExerciseDefinition.fromJson(document.payload),
      ),
  ];
  items.sort((left, right) {
    if (left.isBuiltIn != right.isBuiltIn) return left.isBuiltIn ? -1 : 1;
    return left.nameEn.toLowerCase().compareTo(right.nameEn.toLowerCase());
  });
  return items;
});

final customCardioActivityDocumentsProvider =
    FutureProvider<List<UserContentDocument>>((ref) async {
      ref.watch(syncRefreshProvider);
      final owner = ref.watch(currentUserIdProvider);
      return ref
          .watch(databaseRepositoryProvider)
          .fetchUserContents(
            UserContentKind.cardioActivity,
            ownerUserId: owner,
          );
    });

final cardioActivityLibraryProvider =
    FutureProvider<List<CardioActivityDefinition>>((ref) async {
      final custom = await ref.watch(
        customCardioActivityDocumentsProvider.future,
      );
      return [
        ...BuiltInCardioActivities.all,
        for (final document in custom)
          CardioActivityDefinition.fromJson(document.payload),
      ];
    });

final cardioRecordDocumentsProvider = FutureProvider<List<UserContentDocument>>(
  (ref) async {
    ref.watch(syncRefreshProvider);
    final owner = ref.watch(currentUserIdProvider);
    return ref
        .watch(databaseRepositoryProvider)
        .fetchUserContents(UserContentKind.cardioRecord, ownerUserId: owner);
  },
);

final cardioRecordsProvider = FutureProvider<List<CardioRecord>>((ref) async {
  final documents = await ref.watch(cardioRecordDocumentsProvider.future);
  final records = documents
      .map((document) => CardioRecord.fromJson(document.payload))
      .toList();
  records.sort((left, right) => right.startedAt.compareTo(left.startedAt));
  return records;
});

final cardioImportFingerprintDocumentsProvider =
    FutureProvider<List<UserContentDocument>>((ref) async {
      ref.watch(syncRefreshProvider);
      final owner = ref.watch(currentUserIdProvider);
      return ref
          .watch(databaseRepositoryProvider)
          .fetchUserContents(
            UserContentKind.cardioImportFingerprint,
            ownerUserId: owner,
          );
    });

final customThemePaletteDocumentsProvider =
    FutureProvider<List<UserContentDocument>>((ref) async {
      ref.watch(syncRefreshProvider);
      final owner = ref.watch(currentUserIdProvider);
      return ref
          .watch(databaseRepositoryProvider)
          .fetchUserContents(
            UserContentKind.customThemePalette,
            ownerUserId: owner,
          );
    });

final customThemePalettesProvider = FutureProvider<List<CustomThemePalette>>((
  ref,
) async {
  final documents = await ref.watch(customThemePaletteDocumentsProvider.future);
  return documents
      .map((document) => CustomThemePalette.fromJson(document.payload))
      .toList(growable: false);
});

class UserContentService {
  UserContentService(this._ref);

  final Ref _ref;

  Future<UserContentDocument> saveCustomExercise(
    CustomExerciseDefinition exercise, {
    int? expectedVersion,
  }) async {
    exercise.validate();
    final saved = await _save(
      kind: UserContentKind.customExercise,
      id: exercise.id,
      payload: exercise.toJson(),
      expectedVersion: expectedVersion,
    );
    _ref.invalidate(customExerciseDocumentsProvider);
    _ref.invalidate(exerciseCatalogProvider);
    return saved;
  }

  Future<UserContentDocument> saveCardioActivity(
    CardioActivityDefinition activity, {
    int? expectedVersion,
  }) async {
    if (activity.isBuiltIn || !activity.id.startsWith('user-cardio:')) {
      throw StateError('Built-in cardio activities cannot be modified.');
    }
    activity.validate();
    final saved = await _save(
      kind: UserContentKind.cardioActivity,
      id: activity.id,
      payload: activity.toJson(),
      expectedVersion: expectedVersion,
    );
    _ref.invalidate(customCardioActivityDocumentsProvider);
    _ref.invalidate(cardioActivityLibraryProvider);
    return saved;
  }

  Future<UserContentDocument> saveCardioRecord(
    CardioRecord record, {
    int? expectedVersion,
  }) async {
    final activities = await _ref.read(cardioActivityLibraryProvider.future);
    final activity = activities.firstWhere(
      (candidate) => candidate.id == record.activityTypeId,
      orElse: () => throw StateError('Cardio activity is unavailable.'),
    );
    record.validate(activity);
    final saved = await _save(
      kind: UserContentKind.cardioRecord,
      id: record.id,
      payload: record.toJson(),
      expectedVersion: expectedVersion,
    );
    _ref.invalidate(cardioRecordDocumentsProvider);
    _ref.invalidate(cardioRecordsProvider);
    return saved;
  }

  Future<void> saveCardioImport(CardioImportPreview preview) async {
    if (preview.newRecords.isEmpty) {
      throw StateError('The import does not contain any new cardio records.');
    }
    final activities = await _ref.read(cardioActivityLibraryProvider.future);
    for (final record in preview.newRecords) {
      final activity = activities.firstWhere(
        (candidate) => candidate.id == record.activityTypeId,
        orElse: () => throw StateError('Cardio activity is unavailable.'),
      );
      record.validate(activity);
    }
    final owner = _ref.read(currentUserIdProvider);
    final receiptId = 'cardio-import:${preview.sourceFingerprint}';
    final importedAt = DateTime.now();
    final documents = <UserContentDocument>[
      for (final record in preview.newRecords)
        UserContentDocument(
          id: record.id,
          kind: UserContentKind.cardioRecord,
          payload: record.toJson(),
          ownerUserId: owner,
        ),
      UserContentDocument(
        id: receiptId,
        kind: UserContentKind.cardioImportFingerprint,
        ownerUserId: owner,
        payload: {
          'fingerprint': preview.sourceFingerprint,
          'sourceName': preview.sourceName,
          'importedAt': importedAt.toUtc().toIso8601String(),
          'recordIds': preview.newRecords.map((record) => record.id).toList(),
        },
      ),
    ];
    await _ref
        .read(databaseRepositoryProvider)
        .saveUserContentsAtomically(
          documents,
          expectedVersions: {for (final document in documents) document.id: 0},
        );
    _ref.invalidate(cardioRecordDocumentsProvider);
    _ref.invalidate(cardioRecordsProvider);
    _ref.invalidate(cardioImportFingerprintDocumentsProvider);
  }

  Future<UserContentDocument> saveCustomPalette(
    CustomThemePalette palette, {
    int? expectedVersion,
  }) async {
    palette.validate();
    final saved = await _save(
      kind: UserContentKind.customThemePalette,
      id: palette.id,
      payload: palette.toJson(),
      expectedVersion: expectedVersion,
    );
    _ref.invalidate(customThemePaletteDocumentsProvider);
    _ref.invalidate(customThemePalettesProvider);
    return saved;
  }

  Future<void> delete(
    String id,
    UserContentKind kind, {
    int? expectedVersion,
  }) async {
    final owner = _ref.read(currentUserIdProvider);
    await _ref
        .read(databaseRepositoryProvider)
        .deleteUserContent(
          id,
          kind: kind,
          ownerUserId: owner,
          expectedVersion: expectedVersion,
        );
    _invalidate(kind);
  }

  String newId(UserContentKind kind) {
    if (kind == UserContentKind.cardioImportFingerprint) {
      throw StateError('Import receipt IDs are derived from source hashes.');
    }
    final prefix = switch (kind) {
      UserContentKind.customExercise => 'user-exercise',
      UserContentKind.cardioActivity => 'user-cardio',
      UserContentKind.cardioRecord => 'cardio-record',
      UserContentKind.cardioImportFingerprint => throw StateError(
        'Import receipt IDs are derived from source hashes.',
      ),
      UserContentKind.customThemePalette => 'user-palette',
    };
    return '$prefix:${const Uuid().v4()}';
  }

  Future<UserContentDocument> _save({
    required UserContentKind kind,
    required String id,
    required Map<String, dynamic> payload,
    int? expectedVersion,
  }) {
    final owner = _ref.read(currentUserIdProvider);
    return _ref
        .read(databaseRepositoryProvider)
        .saveUserContent(
          UserContentDocument(
            id: id,
            kind: kind,
            payload: payload,
            ownerUserId: owner,
          ),
          expectedVersion: expectedVersion,
        );
  }

  void _invalidate(UserContentKind kind) {
    switch (kind) {
      case UserContentKind.customExercise:
        _ref.invalidate(customExerciseDocumentsProvider);
        _ref.invalidate(exerciseCatalogProvider);
      case UserContentKind.cardioActivity:
        _ref.invalidate(customCardioActivityDocumentsProvider);
        _ref.invalidate(cardioActivityLibraryProvider);
      case UserContentKind.cardioRecord:
        _ref.invalidate(cardioRecordDocumentsProvider);
        _ref.invalidate(cardioRecordsProvider);
      case UserContentKind.customThemePalette:
        _ref.invalidate(customThemePaletteDocumentsProvider);
        _ref.invalidate(customThemePalettesProvider);
      case UserContentKind.cardioImportFingerprint:
        _ref.invalidate(cardioImportFingerprintDocumentsProvider);
    }
  }
}
