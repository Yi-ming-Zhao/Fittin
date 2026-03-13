import 'dart:convert';
import 'dart:io';

import 'package:fittin_v2/src/domain/models/training_plan.dart';

class ExportService {
  static const sharePrefix = 'fittin-plan:';

  static String exportTemplateToSharePayload(PlanTemplate template) {
    final jsonString = jsonEncode(_compactJson(template.toJson()));
    final compressed = gzip.encode(utf8.encode(jsonString));
    final payload = base64UrlEncode(compressed);
    return '$sharePrefix$payload';
  }

  static PlanTemplate importTemplateFromSharePayload(String sharePayload) {
    final payload = sharePayload.startsWith(sharePrefix)
        ? sharePayload.substring(sharePrefix.length)
        : sharePayload;

    try {
      return _parsePayloadBytes(_decodePayload(payload));
    } on FormatException {
      return _parsePayloadBytes(base64Decode(payload));
    }
  }

  static String exportTemplateToBase64(PlanTemplate template) {
    return exportTemplateToSharePayload(template);
  }

  static PlanTemplate importTemplateFromBase64(String base64Payload) {
    return importTemplateFromSharePayload(base64Payload);
  }

  static List<int> _decodePayload(String payload) {
    final normalized = base64Url.normalize(payload);
    return base64Url.decode(normalized);
  }

  static PlanTemplate _parsePayloadBytes(List<int> bytes) {
    try {
      return _parseJsonString(utf8.decode(gzip.decode(bytes)));
    } catch (_) {
      return _parseJsonString(utf8.decode(bytes));
    }
  }

  static PlanTemplate _parseJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return PlanTemplate.fromJson(json);
  }

  static Object? _compactJson(Object? value, [String? key]) {
    if (value is Map<String, dynamic>) {
      final compacted = <String, dynamic>{};
      for (final entry in value.entries) {
        final compactValue = _compactJson(entry.value, entry.key);
        if (_shouldDrop(entry.key, compactValue)) {
          continue;
        }
        compacted[entry.key] = compactValue;
      }
      return compacted;
    }
    if (value is List) {
      return [
        for (final item in value)
          if (_compactJson(item) != null) _compactJson(item),
      ];
    }
    return value;
  }

  static bool _shouldDrop(String key, Object? value) {
    if (value == null) {
      return true;
    }
    if (value is Map && value.isEmpty) {
      return true;
    }
    switch (key) {
      case 'engineFamily':
        return value == 'legacy';
      case 'requiredTrainingMaxKeys':
      case 'history':
        return value is List && value.isEmpty;
      case 'engineConfig':
        return value is Map && value.isEmpty;
      case 'initialBaseWeight':
        return value == 0 || value == 0.0;
      case 'trainingMaxMultiplier':
      case 'basePercent':
      case 'intensity':
        return value == 1 || value == 1.0;
      case 'roundingIncrement':
        return value == 2.5;
      case 'order':
        return value == 0;
      case 'isAmrap':
        return value == false;
      case 'kind':
        return value == 'working';
      default:
        return false;
    }
  }
}
