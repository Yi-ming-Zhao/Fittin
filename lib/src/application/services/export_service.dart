import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/template_validation.dart';

class ExportService {
  static const sharePrefix = 'fittin-plan:';
  static const maxEncodedPayloadLength = 128 * 1024;
  static const maxCompressedBytes = 96 * 1024;
  static const maxDecodedBytes = 512 * 1024;

  static String exportTemplateToSharePayload(PlanTemplate template) {
    final jsonString = jsonEncode(_compactJson(template.toJson()));
    final compressed = gzip.encode(utf8.encode(jsonString));
    final payload = base64UrlEncode(compressed);
    return '$sharePrefix$payload';
  }

  static PlanTemplate importTemplateFromSharePayload(String sharePayload) {
    if (sharePayload.length > maxEncodedPayloadLength + sharePrefix.length) {
      throw const FormatException('Shared plan payload is too large.');
    }
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
    final bytes = base64Url.decode(normalized);
    if (bytes.length > maxCompressedBytes) {
      throw const FormatException('Shared plan payload is too large.');
    }
    return bytes;
  }

  static PlanTemplate _parsePayloadBytes(List<int> bytes) {
    final isGzip = bytes.length >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b;
    final decoded = isGzip ? _boundedGzipDecode(bytes) : bytes;
    if (decoded.length > maxDecodedBytes) {
      throw const FormatException('Decoded plan payload is too large.');
    }
    return _parseJsonString(utf8.decode(decoded));
  }

  static PlanTemplate _parseJsonString(String jsonString) {
    final decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Shared plan must contain a JSON object.');
    }
    final template = PlanTemplate.fromJson(decoded);
    final validation = TemplateValidation.validate(template);
    if (!validation.isValid) {
      throw FormatException(validation.errors.first);
    }
    return template;
  }

  static List<int> _boundedGzipDecode(List<int> bytes) {
    final sink = _BoundedByteSink(maxDecodedBytes);
    final decoder = gzip.decoder.startChunkedConversion(sink);
    decoder.add(bytes);
    decoder.close();
    return sink.takeBytes();
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
      final compacted = <Object?>[];
      for (final item in value) {
        final compactItem = _compactJson(item);
        if (compactItem != null) {
          compacted.add(compactItem);
        }
      }
      return compacted;
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
      case 'scheduleMode':
        return value == 'legacy';
      case 'loadUnit':
        return value == 'kg';
      case 'roundingIncrement':
        return value == 2.5;
      case 'order':
        return value == 0;
      case 'isAmrap':
        return value == false;
      case 'kind':
        return value == 'working';
      case 'setType':
        return value == 'straight_set';
      default:
        return false;
    }
  }
}

class _BoundedByteSink extends ByteConversionSinkBase {
  _BoundedByteSink(this.limit);

  final int limit;
  final BytesBuilder _builder = BytesBuilder(copy: false);
  bool _closed = false;

  @override
  void add(List<int> chunk) {
    if (_closed) throw StateError('Cannot add to a closed byte sink.');
    if (_builder.length + chunk.length > limit) {
      throw const FormatException('Decoded plan payload is too large.');
    }
    _builder.add(chunk);
  }

  @override
  void close() {
    _closed = true;
  }

  List<int> takeBytes() => _builder.takeBytes();
}
