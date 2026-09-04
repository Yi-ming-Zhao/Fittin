import 'package:fittin_v2/src/domain/exercise_library.dart';
import 'package:fittin_v2/src/domain/models/custom_exercise.dart';
import 'package:fittin_v2/src/domain/models/custom_theme_palette.dart';
import 'package:fittin_v2/src/domain/models/user_content.dart';
import 'package:fittin_v2/src/domain/user_content_validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('user-content trust boundary', () {
    test('accepts canonical custom exercise and palette payloads', () {
      expect(
        () => UserContentValidation.validatePayload(
          kind: UserContentKind.customExercise,
          id: _exercise.id,
          payload: _exercise.toJson(),
        ),
        returnsNormally,
      );
      expect(
        () => UserContentValidation.validatePayload(
          kind: UserContentKind.customThemePalette,
          id: _palette.id,
          payload: _palette.toJson(),
        ),
        returnsNormally,
      );
    });

    test('rejects payload identity mismatch and internal fields', () {
      expect(
        () => UserContentValidation.validatePayload(
          kind: UserContentKind.customExercise,
          id: 'user-exercise:other',
          payload: _exercise.toJson(),
        ),
        throwsFormatException,
      );
      expect(
        () => UserContentValidation.validatePayload(
          kind: UserContentKind.customExercise,
          id: _exercise.id,
          payload: {..._exercise.toJson(), 'ownerUserId': 'attacker'},
        ),
        throwsFormatException,
      );
    });

    test('rejects unsafe palette colors at the domain boundary', () {
      for (final invalid in [
        {..._palette.colors, 'accent': '#80ABCDEF'},
        {..._palette.colors, 'accent': '#00AFAA'},
        {..._palette.colors, 'foreground': '#222222'},
      ]) {
        expect(
          () => CustomThemePalette(
            id: 'user-palette:invalid',
            name: 'Invalid',
            brightness: Brightness.dark,
            colors: invalid,
          ),
          throwsFormatException,
        );
      }
    });

    test('rejects duplicate and placeholder exercise classifications', () {
      expect(
        () => CustomExerciseDefinition(
          id: 'user-exercise:invalid',
          nameEn: 'Invalid',
          nameZhCn: '无效',
          movement: ExerciseMovement.selection,
          equipment: ExerciseEquipment.cable,
          loadSemantics: ExerciseLoadSemantics.cableStack,
          primaryMuscles: const [ExerciseMuscle.upperBack],
          secondaryMuscles: const [],
          tags: const ['back'],
        ),
        throwsFormatException,
      );
      expect(
        () => CustomExerciseDefinition(
          id: 'user-exercise:invalid',
          nameEn: 'Invalid',
          nameZhCn: '无效',
          movement: ExerciseMovement.horizontalPull,
          equipment: ExerciseEquipment.cable,
          loadSemantics: ExerciseLoadSemantics.cableStack,
          primaryMuscles: const [ExerciseMuscle.upperBack],
          secondaryMuscles: const [],
          tags: const ['back', ' back '],
        ),
        throwsFormatException,
      );
    });

    test(
      'requires canonical import receipts instead of arbitrary payloads',
      () {
        final fingerprint = List.filled(64, 'a').join();
        final id = 'cardio-import:$fingerprint';
        final payload = {
          'fingerprint': fingerprint,
          'sourceName': 'rqrun.csv',
          'importedAt': '2026-09-04T02:00:00.000Z',
          'recordIds': const ['cardio-record:imported'],
        };
        expect(
          () => UserContentValidation.validatePayload(
            kind: UserContentKind.cardioImportFingerprint,
            id: id,
            payload: payload,
          ),
          returnsNormally,
        );
        expect(
          () => UserContentValidation.validatePayload(
            kind: UserContentKind.cardioImportFingerprint,
            id: id,
            payload: {...payload, 'ownerUserId': 'other-user'},
          ),
          throwsFormatException,
        );
      },
    );
  });
}

final _exercise = CustomExerciseDefinition(
  id: 'user-exercise:test',
  nameEn: 'Cable row',
  nameZhCn: '绳索划船',
  movement: ExerciseMovement.horizontalPull,
  equipment: ExerciseEquipment.cable,
  loadSemantics: ExerciseLoadSemantics.cableStack,
  primaryMuscles: const [ExerciseMuscle.upperBack],
  secondaryMuscles: const [ExerciseMuscle.biceps],
  tags: const ['back', 'row'],
);

final _palette = CustomThemePalette(
  id: 'user-palette:test',
  name: 'Ember Archive',
  brightness: Brightness.dark,
  colors: const {
    'background': '#111111',
    'surface': '#1B1B1B',
    'foreground': '#F5F1E8',
    'mutedForeground': '#B8B0A2',
    'accent': '#D6A94E',
    'accentInk': '#111111',
    'strength': '#E05D44',
    'cardio': '#8B6FD6',
    'success': '#72A85F',
    'warning': '#E4A93B',
    'danger': '#D95C65',
  },
);
