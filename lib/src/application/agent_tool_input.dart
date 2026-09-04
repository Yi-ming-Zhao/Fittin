import 'dart:convert';

/// The provider's function schema is documentation; this local validator is
/// the actual trust boundary. Version 1 accepts business fields only.
abstract final class AgentToolInput {
  static const schemaVersion = 1;
  static const _internal = {
    'ownerUserId',
    'authEpoch',
    'syncStatus',
    'syncStatusKey',
    'version',
    'deletedAt',
    'lastSyncedAt',
    'lastModifiedByDeviceId',
    'preConclusionSnapshot',
    'postConclusionSnapshot',
  };

  static void validate(
    Map<String, dynamic> value,
    Map<String, dynamic> schema,
  ) {
    if (utf8.encode(jsonEncode(value)).length > 128 * 1024) {
      throw const FormatException('Tool input exceeds the size budget.');
    }
    _visit(value, schema, 'input', 0);
  }

  static void _visit(
    Object? value,
    Map<String, dynamic> schema,
    String path,
    int depth,
  ) {
    if (depth > 30) {
      throw const FormatException('Tool input is nested too deeply.');
    }
    final types = schema['type'] is List
        ? schema['type'] as List
        : [schema['type']];
    if (types.first != null &&
        !types.any(
          (type) => switch (type) {
            'object' => value is Map,
            'array' => value is List,
            'string' => value is String,
            'integer' => value is int,
            'number' => value is num && value.isFinite,
            'boolean' => value is bool,
            'null' => value == null,
            _ => false,
          },
        )) {
      throw FormatException('$path has the wrong type.');
    }
    if (schema['enum'] is List && !(schema['enum'] as List).contains(value)) {
      throw FormatException('$path is not an allowed value.');
    }
    if (value is num) {
      if (!value.isFinite ||
          (schema['exclusiveMinimum'] is num &&
              value <= (schema['exclusiveMinimum'] as num)) ||
          (schema['minimum'] is num && value < (schema['minimum'] as num)) ||
          (schema['maximum'] is num && value > (schema['maximum'] as num))) {
        throw FormatException('$path is outside the allowed range.');
      }
    } else if (value is String) {
      if (value.length < (schema['minLength'] as int? ?? 0) ||
          value.length > (schema['maxLength'] as int? ?? 16000)) {
        throw FormatException('$path has an invalid length.');
      }
    } else if (value is List) {
      if (value.length < (schema['minItems'] as int? ?? 0) ||
          value.length > (schema['maxItems'] as int? ?? 1000)) {
        throw FormatException('$path has an invalid number of items.');
      }
      if (schema['uniqueItems'] == true &&
          value.map(canonicalJson).toSet().length != value.length) {
        throw FormatException('$path contains duplicate items.');
      }
      for (var i = 0; i < value.length; i++) {
        _visit(
          value[i],
          (schema['items'] as Map? ?? {}).cast(),
          '$path/$i',
          depth + 1,
        );
      }
    } else if (value is Map) {
      final properties = (schema['properties'] as Map? ?? {})
          .cast<String, dynamic>();
      for (final required in schema['required'] as List? ?? []) {
        if (!value.containsKey(required)) {
          throw FormatException('$path is missing $required.');
        }
      }
      for (final entry in value.entries) {
        final key = entry.key;
        if (key is! String ||
            _internal.contains(key) ||
            (schema['additionalProperties'] == false &&
                !properties.containsKey(key))) {
          throw FormatException('$path contains a non-editable field.');
        }
        _visit(
          entry.value,
          (properties[key] as Map? ?? {}).cast(),
          '$path/$key',
          depth + 1,
        );
      }
    }
  }

  static String canonicalJson(Object? value) {
    if (value is Map) {
      final keys = value.keys.map((key) => '$key').toList()..sort();
      return '{${keys.map((key) => '${jsonEncode(key)}:${canonicalJson(value[key])}').join(',')}}';
    }
    if (value is List) {
      return '[${value.map(canonicalJson).join(',')}]';
    }
    return jsonEncode(value);
  }
}
