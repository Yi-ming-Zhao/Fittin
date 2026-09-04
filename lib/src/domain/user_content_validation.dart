import 'dart:convert';

import 'package:fittin_v2/src/domain/models/cardio.dart';
import 'package:fittin_v2/src/domain/models/custom_exercise.dart';
import 'package:fittin_v2/src/domain/models/custom_theme_palette.dart';
import 'package:fittin_v2/src/domain/models/user_content.dart';

/// The shared trust boundary for locally-authored and remotely-hydrated
/// user-content documents. Repositories must call this before persisting a
/// payload so one malformed document cannot poison an entire library.
abstract final class UserContentValidation {
  static const maxPayloadBytes = 128 * 1024;

  static void validateDocument(UserContentDocument document) {
    validatePayload(
      kind: document.kind,
      id: document.id,
      payload: document.payload,
    );
  }

  static void validatePayload({
    required UserContentKind kind,
    required String id,
    required Map<String, dynamic> payload,
  }) {
    if (id.trim() != id || id.isEmpty || id.length > 160) {
      throw const FormatException('User content ID is invalid.');
    }
    try {
      if (utf8.encode(jsonEncode(payload)).length > maxPayloadBytes) {
        throw const FormatException('User content payload is too large.');
      }
    } on JsonUnsupportedObjectError {
      throw const FormatException('User content payload is not valid JSON.');
    }

    switch (kind) {
      case UserContentKind.customExercise:
        _requireIdPrefix(id, 'user-exercise:');
        _rejectUnknownKeys(payload, const {
          'id',
          'nameEn',
          'nameZhCn',
          'movement',
          'equipment',
          'loadSemantics',
          'primaryMuscles',
          'secondaryMuscles',
          'tags',
          'roundingIncrementKg',
          'sourceExerciseId',
        });
        final exercise = CustomExerciseDefinition.fromJson(payload);
        if (exercise.id != id) {
          throw const FormatException(
            'Exercise document and payload IDs do not match.',
          );
        }
        exercise.validate();
        return;
      case UserContentKind.cardioActivity:
        _requireIdPrefix(id, 'user-cardio:');
        _rejectUnknownKeys(payload, const {
          'id',
          'nameEn',
          'nameZhCn',
          'icon',
          'requiredMetrics',
          'optionalMetrics',
          'isBuiltIn',
        });
        final activity = CardioActivityDefinition.fromJson(payload);
        if (activity.id != id || activity.isBuiltIn) {
          throw const FormatException(
            'Custom cardio activity identity is invalid.',
          );
        }
        activity.validate();
        return;
      case UserContentKind.cardioRecord:
        _requireIdPrefix(id, 'cardio-record:');
        _rejectUnknownKeys(payload, const {
          'id',
          'activityTypeId',
          'activityName',
          'startedAt',
          'metrics',
          'note',
          'source',
          'sourceFingerprint',
        });
        final record = CardioRecord.fromJson(payload);
        if (record.id != id ||
            record.activityName.trim().isEmpty ||
            record.activityName.length > 80 ||
            record.source.length > 80 ||
            (record.sourceFingerprint?.length ?? 0) > 160) {
          throw const FormatException('Cardio record identity is invalid.');
        }
        // Every supported activity requires duration. A permissive local
        // definition still enforces numeric ranges at the repository edge;
        // the activity-specific service performs the narrower field check.
        record.validate(
          CardioActivityDefinition(
            id: record.activityTypeId,
            nameEn: 'Validated activity',
            nameZhCn: '已验证活动',
            icon: CardioActivityIcon.generic,
            requiredMetrics: const [CardioMetricKey.durationSeconds],
            optionalMetrics: CardioMetricKey.values.where(
              (value) => value != CardioMetricKey.durationSeconds,
            ),
            isBuiltIn: false,
          ),
        );
        return;
      case UserContentKind.cardioImportFingerprint:
        _requireIdPrefix(id, 'cardio-import:');
        _rejectUnknownKeys(payload, const {
          'fingerprint',
          'sourceName',
          'importedAt',
          'recordIds',
        });
        final fingerprint = payload['fingerprint'];
        final sourceName = payload['sourceName'];
        final importedAt = payload['importedAt'];
        final recordIds = payload['recordIds'];
        if (fingerprint is! String ||
            !RegExp(r'^[0-9a-f]{64}$').hasMatch(fingerprint) ||
            id != 'cardio-import:$fingerprint' ||
            sourceName is! String ||
            sourceName.trim().isEmpty ||
            sourceName.length > 255 ||
            importedAt is! String ||
            DateTime.tryParse(importedAt) == null ||
            recordIds is! List ||
            recordIds.isEmpty ||
            recordIds.length > 1000 ||
            recordIds.any(
              (value) =>
                  value is! String ||
                  !value.startsWith('cardio-record:') ||
                  value.length > 160,
            )) {
          throw const FormatException('Cardio import receipt is invalid.');
        }
        return;
      case UserContentKind.customThemePalette:
        _requireIdPrefix(id, 'user-palette:');
        _rejectUnknownKeys(payload, const {
          'id',
          'name',
          'brightness',
          'colors',
          'basePaletteKey',
        });
        final palette = CustomThemePalette.fromJson(payload);
        if (palette.id != id) {
          throw const FormatException(
            'Palette document and payload IDs do not match.',
          );
        }
        palette.validate();
        return;
    }
  }

  static void _requireIdPrefix(String id, String prefix) {
    if (!id.startsWith(prefix) || id.length == prefix.length) {
      throw FormatException('User content ID must start with $prefix.');
    }
  }

  static void _rejectUnknownKeys(
    Map<String, dynamic> payload,
    Set<String> allowed,
  ) {
    final unknown = payload.keys.where((key) => !allowed.contains(key));
    if (unknown.isNotEmpty) {
      throw FormatException(
        'User content contains unsupported fields: ${unknown.join(', ')}.',
      );
    }
  }
}
