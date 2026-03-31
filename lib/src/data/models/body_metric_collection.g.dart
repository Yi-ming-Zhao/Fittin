// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_metric_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBodyMetricCollectionCollection on Isar {
  IsarCollection<BodyMetricCollection> get bodyMetricCollections =>
      this.collection();
}

const BodyMetricCollectionSchema = CollectionSchema(
  name: r'BodyMetricCollection',
  id: -5021208054449053923,
  properties: {
    r'bodyFatPercent': PropertySchema(
      id: 0,
      name: r'bodyFatPercent',
      type: IsarType.double,
    ),
    r'deletedAt': PropertySchema(
      id: 1,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'lastModifiedByDeviceId': PropertySchema(
      id: 2,
      name: r'lastModifiedByDeviceId',
      type: IsarType.string,
    ),
    r'lastSyncedAt': PropertySchema(
      id: 3,
      name: r'lastSyncedAt',
      type: IsarType.dateTime,
    ),
    r'metricId': PropertySchema(
      id: 4,
      name: r'metricId',
      type: IsarType.string,
    ),
    r'note': PropertySchema(id: 5, name: r'note', type: IsarType.string),
    r'ownerUserId': PropertySchema(
      id: 6,
      name: r'ownerUserId',
      type: IsarType.string,
    ),
    r'syncStatusKey': PropertySchema(
      id: 7,
      name: r'syncStatusKey',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 8,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
    r'version': PropertySchema(id: 9, name: r'version', type: IsarType.long),
    r'waistCm': PropertySchema(id: 10, name: r'waistCm', type: IsarType.double),
    r'weightKg': PropertySchema(
      id: 11,
      name: r'weightKg',
      type: IsarType.double,
    ),
  },
  estimateSize: _bodyMetricCollectionEstimateSize,
  serialize: _bodyMetricCollectionSerialize,
  deserialize: _bodyMetricCollectionDeserialize,
  deserializeProp: _bodyMetricCollectionDeserializeProp,
  idName: r'id',
  indexes: {
    r'metricId': IndexSchema(
      id: -1685298009092058112,
      name: r'metricId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'metricId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'ownerUserId': IndexSchema(
      id: 1631799950038639233,
      name: r'ownerUserId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'ownerUserId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _bodyMetricCollectionGetId,
  getLinks: _bodyMetricCollectionGetLinks,
  attach: _bodyMetricCollectionAttach,
  version: '3.1.0+1',
);

int _bodyMetricCollectionEstimateSize(
  BodyMetricCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.lastModifiedByDeviceId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.metricId.length * 3;
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.ownerUserId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.syncStatusKey.length * 3;
  return bytesCount;
}

void _bodyMetricCollectionSerialize(
  BodyMetricCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.bodyFatPercent);
  writer.writeDateTime(offsets[1], object.deletedAt);
  writer.writeString(offsets[2], object.lastModifiedByDeviceId);
  writer.writeDateTime(offsets[3], object.lastSyncedAt);
  writer.writeString(offsets[4], object.metricId);
  writer.writeString(offsets[5], object.note);
  writer.writeString(offsets[6], object.ownerUserId);
  writer.writeString(offsets[7], object.syncStatusKey);
  writer.writeDateTime(offsets[8], object.timestamp);
  writer.writeLong(offsets[9], object.version);
  writer.writeDouble(offsets[10], object.waistCm);
  writer.writeDouble(offsets[11], object.weightKg);
}

BodyMetricCollection _bodyMetricCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BodyMetricCollection();
  object.bodyFatPercent = reader.readDoubleOrNull(offsets[0]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[1]);
  object.id = id;
  object.lastModifiedByDeviceId = reader.readStringOrNull(offsets[2]);
  object.lastSyncedAt = reader.readDateTimeOrNull(offsets[3]);
  object.metricId = reader.readString(offsets[4]);
  object.note = reader.readStringOrNull(offsets[5]);
  object.ownerUserId = reader.readStringOrNull(offsets[6]);
  object.syncStatusKey = reader.readString(offsets[7]);
  object.timestamp = reader.readDateTime(offsets[8]);
  object.version = reader.readLong(offsets[9]);
  object.waistCm = reader.readDoubleOrNull(offsets[10]);
  object.weightKg = reader.readDoubleOrNull(offsets[11]);
  return object;
}

P _bodyMetricCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readDoubleOrNull(offset)) as P;
    case 11:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _bodyMetricCollectionGetId(BodyMetricCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _bodyMetricCollectionGetLinks(
  BodyMetricCollection object,
) {
  return [];
}

void _bodyMetricCollectionAttach(
  IsarCollection<dynamic> col,
  Id id,
  BodyMetricCollection object,
) {
  object.id = id;
}

extension BodyMetricCollectionByIndex on IsarCollection<BodyMetricCollection> {
  Future<BodyMetricCollection?> getByMetricId(String metricId) {
    return getByIndex(r'metricId', [metricId]);
  }

  BodyMetricCollection? getByMetricIdSync(String metricId) {
    return getByIndexSync(r'metricId', [metricId]);
  }

  Future<bool> deleteByMetricId(String metricId) {
    return deleteByIndex(r'metricId', [metricId]);
  }

  bool deleteByMetricIdSync(String metricId) {
    return deleteByIndexSync(r'metricId', [metricId]);
  }

  Future<List<BodyMetricCollection?>> getAllByMetricId(
    List<String> metricIdValues,
  ) {
    final values = metricIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'metricId', values);
  }

  List<BodyMetricCollection?> getAllByMetricIdSync(
    List<String> metricIdValues,
  ) {
    final values = metricIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'metricId', values);
  }

  Future<int> deleteAllByMetricId(List<String> metricIdValues) {
    final values = metricIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'metricId', values);
  }

  int deleteAllByMetricIdSync(List<String> metricIdValues) {
    final values = metricIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'metricId', values);
  }

  Future<Id> putByMetricId(BodyMetricCollection object) {
    return putByIndex(r'metricId', object);
  }

  Id putByMetricIdSync(BodyMetricCollection object, {bool saveLinks = true}) {
    return putByIndexSync(r'metricId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByMetricId(List<BodyMetricCollection> objects) {
    return putAllByIndex(r'metricId', objects);
  }

  List<Id> putAllByMetricIdSync(
    List<BodyMetricCollection> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'metricId', objects, saveLinks: saveLinks);
  }
}

extension BodyMetricCollectionQueryWhereSort
    on QueryBuilder<BodyMetricCollection, BodyMetricCollection, QWhere> {
  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BodyMetricCollectionQueryWhere
    on QueryBuilder<BodyMetricCollection, BodyMetricCollection, QWhereClause> {
  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterWhereClause>
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterWhereClause>
  idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterWhereClause>
  metricIdEqualTo(String metricId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'metricId', value: [metricId]),
      );
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterWhereClause>
  metricIdNotEqualTo(String metricId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'metricId',
                lower: [],
                upper: [metricId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'metricId',
                lower: [metricId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'metricId',
                lower: [metricId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'metricId',
                lower: [],
                upper: [metricId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterWhereClause>
  ownerUserIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'ownerUserId', value: [null]),
      );
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterWhereClause>
  ownerUserIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'ownerUserId',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterWhereClause>
  ownerUserIdEqualTo(String? ownerUserId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'ownerUserId',
          value: [ownerUserId],
        ),
      );
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterWhereClause>
  ownerUserIdNotEqualTo(String? ownerUserId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ownerUserId',
                lower: [],
                upper: [ownerUserId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ownerUserId',
                lower: [ownerUserId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ownerUserId',
                lower: [ownerUserId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ownerUserId',
                lower: [],
                upper: [ownerUserId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension BodyMetricCollectionQueryFilter
    on
        QueryBuilder<
          BodyMetricCollection,
          BodyMetricCollection,
          QFilterCondition
        > {
  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  bodyFatPercentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'bodyFatPercent'),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  bodyFatPercentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'bodyFatPercent'),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  bodyFatPercentEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'bodyFatPercent',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  bodyFatPercentGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'bodyFatPercent',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  bodyFatPercentLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'bodyFatPercent',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  bodyFatPercentBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'bodyFatPercent',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'deletedAt'),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'deletedAt'),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deletedAt', value: value),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  deletedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'deletedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  deletedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'deletedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  deletedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'deletedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  lastModifiedByDeviceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastModifiedByDeviceId'),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  lastModifiedByDeviceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastModifiedByDeviceId'),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  lastModifiedByDeviceIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lastModifiedByDeviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  lastModifiedByDeviceIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastModifiedByDeviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  lastModifiedByDeviceIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastModifiedByDeviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  lastModifiedByDeviceIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastModifiedByDeviceId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  lastModifiedByDeviceIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'lastModifiedByDeviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  lastModifiedByDeviceIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'lastModifiedByDeviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  lastModifiedByDeviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'lastModifiedByDeviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  lastModifiedByDeviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'lastModifiedByDeviceId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  lastModifiedByDeviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastModifiedByDeviceId', value: ''),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  lastModifiedByDeviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'lastModifiedByDeviceId',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  lastSyncedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastSyncedAt'),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  lastSyncedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastSyncedAt'),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  lastSyncedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastSyncedAt', value: value),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  lastSyncedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastSyncedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  lastSyncedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastSyncedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  lastSyncedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastSyncedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  metricIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'metricId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  metricIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'metricId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  metricIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'metricId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  metricIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'metricId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  metricIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'metricId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  metricIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'metricId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  metricIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'metricId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  metricIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'metricId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  metricIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'metricId', value: ''),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  metricIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'metricId', value: ''),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'note'),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'note'),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  noteEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  noteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  noteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  noteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'note',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  noteStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  noteEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  noteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  noteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'note',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  ownerUserIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'ownerUserId'),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  ownerUserIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'ownerUserId'),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  ownerUserIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'ownerUserId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  ownerUserIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'ownerUserId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  ownerUserIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'ownerUserId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  ownerUserIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'ownerUserId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  ownerUserIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'ownerUserId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  ownerUserIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'ownerUserId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  ownerUserIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'ownerUserId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  ownerUserIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'ownerUserId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  ownerUserIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ownerUserId', value: ''),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  ownerUserIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'ownerUserId', value: ''),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  syncStatusKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'syncStatusKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  syncStatusKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'syncStatusKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  syncStatusKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'syncStatusKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  syncStatusKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'syncStatusKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  syncStatusKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'syncStatusKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  syncStatusKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'syncStatusKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  syncStatusKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'syncStatusKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  syncStatusKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'syncStatusKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  syncStatusKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncStatusKey', value: ''),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  syncStatusKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'syncStatusKey', value: ''),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timestamp', value: value),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  timestampGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'timestamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  timestampLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'timestamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'timestamp',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  versionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'version', value: value),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  versionGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'version',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  versionLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'version',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  versionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'version',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  waistCmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'waistCm'),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  waistCmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'waistCm'),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  waistCmEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'waistCm',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  waistCmGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'waistCm',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  waistCmLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'waistCm',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  waistCmBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'waistCm',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  weightKgIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'weightKg'),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  weightKgIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'weightKg'),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  weightKgEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'weightKg',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  weightKgGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'weightKg',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  weightKgLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'weightKg',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    BodyMetricCollection,
    BodyMetricCollection,
    QAfterFilterCondition
  >
  weightKgBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'weightKg',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }
}

extension BodyMetricCollectionQueryObject
    on
        QueryBuilder<
          BodyMetricCollection,
          BodyMetricCollection,
          QFilterCondition
        > {}

extension BodyMetricCollectionQueryLinks
    on
        QueryBuilder<
          BodyMetricCollection,
          BodyMetricCollection,
          QFilterCondition
        > {}

extension BodyMetricCollectionQuerySortBy
    on QueryBuilder<BodyMetricCollection, BodyMetricCollection, QSortBy> {
  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  sortByBodyFatPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyFatPercent', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  sortByBodyFatPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyFatPercent', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  sortByLastModifiedByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedByDeviceId', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  sortByLastModifiedByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedByDeviceId', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  sortByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  sortByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  sortByMetricId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metricId', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  sortByMetricIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metricId', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  sortByOwnerUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  sortByOwnerUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  sortBySyncStatusKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatusKey', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  sortBySyncStatusKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatusKey', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  sortByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  sortByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  sortByWaistCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waistCm', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  sortByWaistCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waistCm', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  sortByWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  sortByWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.desc);
    });
  }
}

extension BodyMetricCollectionQuerySortThenBy
    on QueryBuilder<BodyMetricCollection, BodyMetricCollection, QSortThenBy> {
  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  thenByBodyFatPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyFatPercent', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  thenByBodyFatPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyFatPercent', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  thenByLastModifiedByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedByDeviceId', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  thenByLastModifiedByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedByDeviceId', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  thenByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  thenByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  thenByMetricId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metricId', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  thenByMetricIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metricId', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  thenByOwnerUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  thenByOwnerUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  thenBySyncStatusKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatusKey', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  thenBySyncStatusKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatusKey', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  thenByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  thenByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  thenByWaistCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waistCm', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  thenByWaistCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waistCm', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  thenByWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QAfterSortBy>
  thenByWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.desc);
    });
  }
}

extension BodyMetricCollectionQueryWhereDistinct
    on QueryBuilder<BodyMetricCollection, BodyMetricCollection, QDistinct> {
  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QDistinct>
  distinctByBodyFatPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bodyFatPercent');
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QDistinct>
  distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QDistinct>
  distinctByLastModifiedByDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'lastModifiedByDeviceId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QDistinct>
  distinctByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncedAt');
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QDistinct>
  distinctByMetricId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'metricId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QDistinct>
  distinctByNote({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QDistinct>
  distinctByOwnerUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ownerUserId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QDistinct>
  distinctBySyncStatusKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'syncStatusKey',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QDistinct>
  distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QDistinct>
  distinctByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'version');
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QDistinct>
  distinctByWaistCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'waistCm');
    });
  }

  QueryBuilder<BodyMetricCollection, BodyMetricCollection, QDistinct>
  distinctByWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weightKg');
    });
  }
}

extension BodyMetricCollectionQueryProperty
    on
        QueryBuilder<
          BodyMetricCollection,
          BodyMetricCollection,
          QQueryProperty
        > {
  QueryBuilder<BodyMetricCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BodyMetricCollection, double?, QQueryOperations>
  bodyFatPercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bodyFatPercent');
    });
  }

  QueryBuilder<BodyMetricCollection, DateTime?, QQueryOperations>
  deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<BodyMetricCollection, String?, QQueryOperations>
  lastModifiedByDeviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastModifiedByDeviceId');
    });
  }

  QueryBuilder<BodyMetricCollection, DateTime?, QQueryOperations>
  lastSyncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncedAt');
    });
  }

  QueryBuilder<BodyMetricCollection, String, QQueryOperations>
  metricIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metricId');
    });
  }

  QueryBuilder<BodyMetricCollection, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<BodyMetricCollection, String?, QQueryOperations>
  ownerUserIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ownerUserId');
    });
  }

  QueryBuilder<BodyMetricCollection, String, QQueryOperations>
  syncStatusKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatusKey');
    });
  }

  QueryBuilder<BodyMetricCollection, DateTime, QQueryOperations>
  timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<BodyMetricCollection, int, QQueryOperations> versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'version');
    });
  }

  QueryBuilder<BodyMetricCollection, double?, QQueryOperations>
  waistCmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'waistCm');
    });
  }

  QueryBuilder<BodyMetricCollection, double?, QQueryOperations>
  weightKgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weightKg');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProgressPhotoCollectionCollection on Isar {
  IsarCollection<ProgressPhotoCollection> get progressPhotoCollections =>
      this.collection();
}

const ProgressPhotoCollectionSchema = CollectionSchema(
  name: r'ProgressPhotoCollection',
  id: -6816542570682781510,
  properties: {
    r'deletedAt': PropertySchema(
      id: 0,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'filePath': PropertySchema(
      id: 1,
      name: r'filePath',
      type: IsarType.string,
    ),
    r'label': PropertySchema(id: 2, name: r'label', type: IsarType.string),
    r'lastModifiedByDeviceId': PropertySchema(
      id: 3,
      name: r'lastModifiedByDeviceId',
      type: IsarType.string,
    ),
    r'lastSyncedAt': PropertySchema(
      id: 4,
      name: r'lastSyncedAt',
      type: IsarType.dateTime,
    ),
    r'metadataJson': PropertySchema(
      id: 5,
      name: r'metadataJson',
      type: IsarType.string,
    ),
    r'ownerUserId': PropertySchema(
      id: 6,
      name: r'ownerUserId',
      type: IsarType.string,
    ),
    r'photoId': PropertySchema(id: 7, name: r'photoId', type: IsarType.string),
    r'syncStatusKey': PropertySchema(
      id: 8,
      name: r'syncStatusKey',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 9,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
    r'version': PropertySchema(id: 10, name: r'version', type: IsarType.long),
  },
  estimateSize: _progressPhotoCollectionEstimateSize,
  serialize: _progressPhotoCollectionSerialize,
  deserialize: _progressPhotoCollectionDeserialize,
  deserializeProp: _progressPhotoCollectionDeserializeProp,
  idName: r'id',
  indexes: {
    r'photoId': IndexSchema(
      id: -1877533456151046685,
      name: r'photoId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'photoId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'ownerUserId': IndexSchema(
      id: 1631799950038639233,
      name: r'ownerUserId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'ownerUserId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _progressPhotoCollectionGetId,
  getLinks: _progressPhotoCollectionGetLinks,
  attach: _progressPhotoCollectionAttach,
  version: '3.1.0+1',
);

int _progressPhotoCollectionEstimateSize(
  ProgressPhotoCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.filePath.length * 3;
  {
    final value = object.label;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lastModifiedByDeviceId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.metadataJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.ownerUserId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.photoId.length * 3;
  bytesCount += 3 + object.syncStatusKey.length * 3;
  return bytesCount;
}

void _progressPhotoCollectionSerialize(
  ProgressPhotoCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.deletedAt);
  writer.writeString(offsets[1], object.filePath);
  writer.writeString(offsets[2], object.label);
  writer.writeString(offsets[3], object.lastModifiedByDeviceId);
  writer.writeDateTime(offsets[4], object.lastSyncedAt);
  writer.writeString(offsets[5], object.metadataJson);
  writer.writeString(offsets[6], object.ownerUserId);
  writer.writeString(offsets[7], object.photoId);
  writer.writeString(offsets[8], object.syncStatusKey);
  writer.writeDateTime(offsets[9], object.timestamp);
  writer.writeLong(offsets[10], object.version);
}

ProgressPhotoCollection _progressPhotoCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProgressPhotoCollection();
  object.deletedAt = reader.readDateTimeOrNull(offsets[0]);
  object.filePath = reader.readString(offsets[1]);
  object.id = id;
  object.label = reader.readStringOrNull(offsets[2]);
  object.lastModifiedByDeviceId = reader.readStringOrNull(offsets[3]);
  object.lastSyncedAt = reader.readDateTimeOrNull(offsets[4]);
  object.metadataJson = reader.readStringOrNull(offsets[5]);
  object.ownerUserId = reader.readStringOrNull(offsets[6]);
  object.photoId = reader.readString(offsets[7]);
  object.syncStatusKey = reader.readString(offsets[8]);
  object.timestamp = reader.readDateTime(offsets[9]);
  object.version = reader.readLong(offsets[10]);
  return object;
}

P _progressPhotoCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _progressPhotoCollectionGetId(ProgressPhotoCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _progressPhotoCollectionGetLinks(
  ProgressPhotoCollection object,
) {
  return [];
}

void _progressPhotoCollectionAttach(
  IsarCollection<dynamic> col,
  Id id,
  ProgressPhotoCollection object,
) {
  object.id = id;
}

extension ProgressPhotoCollectionByIndex
    on IsarCollection<ProgressPhotoCollection> {
  Future<ProgressPhotoCollection?> getByPhotoId(String photoId) {
    return getByIndex(r'photoId', [photoId]);
  }

  ProgressPhotoCollection? getByPhotoIdSync(String photoId) {
    return getByIndexSync(r'photoId', [photoId]);
  }

  Future<bool> deleteByPhotoId(String photoId) {
    return deleteByIndex(r'photoId', [photoId]);
  }

  bool deleteByPhotoIdSync(String photoId) {
    return deleteByIndexSync(r'photoId', [photoId]);
  }

  Future<List<ProgressPhotoCollection?>> getAllByPhotoId(
    List<String> photoIdValues,
  ) {
    final values = photoIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'photoId', values);
  }

  List<ProgressPhotoCollection?> getAllByPhotoIdSync(
    List<String> photoIdValues,
  ) {
    final values = photoIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'photoId', values);
  }

  Future<int> deleteAllByPhotoId(List<String> photoIdValues) {
    final values = photoIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'photoId', values);
  }

  int deleteAllByPhotoIdSync(List<String> photoIdValues) {
    final values = photoIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'photoId', values);
  }

  Future<Id> putByPhotoId(ProgressPhotoCollection object) {
    return putByIndex(r'photoId', object);
  }

  Id putByPhotoIdSync(ProgressPhotoCollection object, {bool saveLinks = true}) {
    return putByIndexSync(r'photoId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPhotoId(List<ProgressPhotoCollection> objects) {
    return putAllByIndex(r'photoId', objects);
  }

  List<Id> putAllByPhotoIdSync(
    List<ProgressPhotoCollection> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'photoId', objects, saveLinks: saveLinks);
  }
}

extension ProgressPhotoCollectionQueryWhereSort
    on QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QWhere> {
  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ProgressPhotoCollectionQueryWhere
    on
        QueryBuilder<
          ProgressPhotoCollection,
          ProgressPhotoCollection,
          QWhereClause
        > {
  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterWhereClause
  >
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterWhereClause
  >
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterWhereClause
  >
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterWhereClause
  >
  idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterWhereClause
  >
  photoIdEqualTo(String photoId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'photoId', value: [photoId]),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterWhereClause
  >
  photoIdNotEqualTo(String photoId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'photoId',
                lower: [],
                upper: [photoId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'photoId',
                lower: [photoId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'photoId',
                lower: [photoId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'photoId',
                lower: [],
                upper: [photoId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterWhereClause
  >
  ownerUserIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'ownerUserId', value: [null]),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterWhereClause
  >
  ownerUserIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'ownerUserId',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterWhereClause
  >
  ownerUserIdEqualTo(String? ownerUserId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'ownerUserId',
          value: [ownerUserId],
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterWhereClause
  >
  ownerUserIdNotEqualTo(String? ownerUserId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ownerUserId',
                lower: [],
                upper: [ownerUserId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ownerUserId',
                lower: [ownerUserId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ownerUserId',
                lower: [ownerUserId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ownerUserId',
                lower: [],
                upper: [ownerUserId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension ProgressPhotoCollectionQueryFilter
    on
        QueryBuilder<
          ProgressPhotoCollection,
          ProgressPhotoCollection,
          QFilterCondition
        > {
  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'deletedAt'),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'deletedAt'),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deletedAt', value: value),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  deletedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'deletedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  deletedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'deletedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  deletedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'deletedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  filePathEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'filePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  filePathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'filePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  filePathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'filePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  filePathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'filePath',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  filePathStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'filePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  filePathEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'filePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  filePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'filePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  filePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'filePath',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  filePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'filePath', value: ''),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  filePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'filePath', value: ''),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  labelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'label'),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  labelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'label'),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  labelEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  labelGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  labelLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  labelBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'label',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  labelStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  labelEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  labelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  labelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'label',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  labelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'label', value: ''),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  labelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'label', value: ''),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  lastModifiedByDeviceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastModifiedByDeviceId'),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  lastModifiedByDeviceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastModifiedByDeviceId'),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  lastModifiedByDeviceIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lastModifiedByDeviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  lastModifiedByDeviceIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastModifiedByDeviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  lastModifiedByDeviceIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastModifiedByDeviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  lastModifiedByDeviceIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastModifiedByDeviceId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  lastModifiedByDeviceIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'lastModifiedByDeviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  lastModifiedByDeviceIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'lastModifiedByDeviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  lastModifiedByDeviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'lastModifiedByDeviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  lastModifiedByDeviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'lastModifiedByDeviceId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  lastModifiedByDeviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastModifiedByDeviceId', value: ''),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  lastModifiedByDeviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'lastModifiedByDeviceId',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  lastSyncedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastSyncedAt'),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  lastSyncedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastSyncedAt'),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  lastSyncedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastSyncedAt', value: value),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  lastSyncedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastSyncedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  lastSyncedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastSyncedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  lastSyncedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastSyncedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  metadataJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'metadataJson'),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  metadataJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'metadataJson'),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  metadataJsonEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'metadataJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  metadataJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'metadataJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  metadataJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'metadataJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  metadataJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'metadataJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  metadataJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'metadataJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  metadataJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'metadataJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  metadataJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'metadataJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  metadataJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'metadataJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  metadataJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'metadataJson', value: ''),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  metadataJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'metadataJson', value: ''),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  ownerUserIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'ownerUserId'),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  ownerUserIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'ownerUserId'),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  ownerUserIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'ownerUserId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  ownerUserIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'ownerUserId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  ownerUserIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'ownerUserId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  ownerUserIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'ownerUserId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  ownerUserIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'ownerUserId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  ownerUserIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'ownerUserId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  ownerUserIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'ownerUserId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  ownerUserIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'ownerUserId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  ownerUserIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ownerUserId', value: ''),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  ownerUserIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'ownerUserId', value: ''),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  photoIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'photoId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  photoIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'photoId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  photoIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'photoId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  photoIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'photoId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  photoIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'photoId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  photoIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'photoId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  photoIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'photoId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  photoIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'photoId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  photoIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'photoId', value: ''),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  photoIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'photoId', value: ''),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  syncStatusKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'syncStatusKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  syncStatusKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'syncStatusKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  syncStatusKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'syncStatusKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  syncStatusKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'syncStatusKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  syncStatusKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'syncStatusKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  syncStatusKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'syncStatusKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  syncStatusKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'syncStatusKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  syncStatusKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'syncStatusKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  syncStatusKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncStatusKey', value: ''),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  syncStatusKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'syncStatusKey', value: ''),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timestamp', value: value),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  timestampGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'timestamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  timestampLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'timestamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'timestamp',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  versionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'version', value: value),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  versionGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'version',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  versionLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'version',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ProgressPhotoCollection,
    ProgressPhotoCollection,
    QAfterFilterCondition
  >
  versionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'version',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension ProgressPhotoCollectionQueryObject
    on
        QueryBuilder<
          ProgressPhotoCollection,
          ProgressPhotoCollection,
          QFilterCondition
        > {}

extension ProgressPhotoCollectionQueryLinks
    on
        QueryBuilder<
          ProgressPhotoCollection,
          ProgressPhotoCollection,
          QFilterCondition
        > {}

extension ProgressPhotoCollectionQuerySortBy
    on QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QSortBy> {
  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  sortByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.asc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  sortByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.desc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  sortByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  sortByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  sortByLastModifiedByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedByDeviceId', Sort.asc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  sortByLastModifiedByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedByDeviceId', Sort.desc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  sortByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  sortByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  sortByMetadataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.asc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  sortByMetadataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.desc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  sortByOwnerUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.asc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  sortByOwnerUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.desc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  sortByPhotoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoId', Sort.asc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  sortByPhotoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoId', Sort.desc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  sortBySyncStatusKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatusKey', Sort.asc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  sortBySyncStatusKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatusKey', Sort.desc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  sortByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  sortByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension ProgressPhotoCollectionQuerySortThenBy
    on
        QueryBuilder<
          ProgressPhotoCollection,
          ProgressPhotoCollection,
          QSortThenBy
        > {
  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  thenByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.asc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  thenByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.desc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  thenByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  thenByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  thenByLastModifiedByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedByDeviceId', Sort.asc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  thenByLastModifiedByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedByDeviceId', Sort.desc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  thenByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  thenByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  thenByMetadataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.asc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  thenByMetadataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.desc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  thenByOwnerUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.asc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  thenByOwnerUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.desc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  thenByPhotoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoId', Sort.asc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  thenByPhotoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoId', Sort.desc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  thenBySyncStatusKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatusKey', Sort.asc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  thenBySyncStatusKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatusKey', Sort.desc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  thenByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QAfterSortBy>
  thenByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension ProgressPhotoCollectionQueryWhereDistinct
    on
        QueryBuilder<
          ProgressPhotoCollection,
          ProgressPhotoCollection,
          QDistinct
        > {
  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QDistinct>
  distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QDistinct>
  distinctByFilePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QDistinct>
  distinctByLabel({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'label', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QDistinct>
  distinctByLastModifiedByDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'lastModifiedByDeviceId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QDistinct>
  distinctByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncedAt');
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QDistinct>
  distinctByMetadataJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'metadataJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QDistinct>
  distinctByOwnerUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ownerUserId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QDistinct>
  distinctByPhotoId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'photoId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QDistinct>
  distinctBySyncStatusKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'syncStatusKey',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QDistinct>
  distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<ProgressPhotoCollection, ProgressPhotoCollection, QDistinct>
  distinctByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'version');
    });
  }
}

extension ProgressPhotoCollectionQueryProperty
    on
        QueryBuilder<
          ProgressPhotoCollection,
          ProgressPhotoCollection,
          QQueryProperty
        > {
  QueryBuilder<ProgressPhotoCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ProgressPhotoCollection, DateTime?, QQueryOperations>
  deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<ProgressPhotoCollection, String, QQueryOperations>
  filePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filePath');
    });
  }

  QueryBuilder<ProgressPhotoCollection, String?, QQueryOperations>
  labelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'label');
    });
  }

  QueryBuilder<ProgressPhotoCollection, String?, QQueryOperations>
  lastModifiedByDeviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastModifiedByDeviceId');
    });
  }

  QueryBuilder<ProgressPhotoCollection, DateTime?, QQueryOperations>
  lastSyncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncedAt');
    });
  }

  QueryBuilder<ProgressPhotoCollection, String?, QQueryOperations>
  metadataJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metadataJson');
    });
  }

  QueryBuilder<ProgressPhotoCollection, String?, QQueryOperations>
  ownerUserIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ownerUserId');
    });
  }

  QueryBuilder<ProgressPhotoCollection, String, QQueryOperations>
  photoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'photoId');
    });
  }

  QueryBuilder<ProgressPhotoCollection, String, QQueryOperations>
  syncStatusKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatusKey');
    });
  }

  QueryBuilder<ProgressPhotoCollection, DateTime, QQueryOperations>
  timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<ProgressPhotoCollection, int, QQueryOperations>
  versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'version');
    });
  }
}
