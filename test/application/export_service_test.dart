import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/services/export_service.dart';
import 'package:fittin_v2/src/data/seeds/gzclp_seed.dart';
import 'package:fittin_v2/src/data/seeds/jacked_and_tan_seed.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'exports the seeded plan as a compact QR payload and reimports it',
    () async {
      final template = await GzclpSeed.loadTemplate();

      final payload = ExportService.exportTemplateToSharePayload(template);
      final imported = ExportService.importTemplateFromSharePayload(payload);

      expect(payload, startsWith(ExportService.sharePrefix));
      expect(payload.length, lessThan(4500));
      expect(imported, template);
    },
  );

  test('still accepts legacy raw base64 JSON payloads', () async {
    final template = await GzclpSeed.loadTemplate();
    final legacyPayload = base64Encode(
      utf8.encode(jsonEncode(template.toJson())),
    );

    final imported = ExportService.importTemplateFromSharePayload(
      legacyPayload,
    );

    expect(imported, template);
  });

  test(
    'exports the Jacked & Tan built-in plan as a compact QR payload',
    () async {
      final template = await JackedAndTanSeed.loadTemplate();

      final payload = ExportService.exportTemplateToSharePayload(template);
      final imported = ExportService.importTemplateFromSharePayload(payload);

      expect(payload, startsWith(ExportService.sharePrefix));
      expect(payload.length, lessThan(4500));
      expect(imported, template);
    },
  );
}
