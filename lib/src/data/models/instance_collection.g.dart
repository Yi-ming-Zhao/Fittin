// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instance_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetInstanceCollectionCollection on Isar {
  IsarCollection<InstanceCollection> get instanceCollections =>
      this.collection();
}

const InstanceCollectionSchema = CollectionSchema(
  name: r'InstanceCollection',
  id: -2215033191059263970,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currentStatesJson': PropertySchema(
      id: 1,
      name: r'currentStatesJson',
      type: IsarType.stringList,
    ),
    r'currentWorkoutIndex': PropertySchema(
      id: 2,
      name: r'currentWorkoutIndex',
      type: IsarType.long,
    ),
    r'deletedAt': PropertySchema(
      id: 3,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'engineStateJson': PropertySchema(
      id: 4,
      name: r'engineStateJson',
      type: IsarType.string,
    ),
    r'instanceId': PropertySchema(
      id: 5,
      name: r'instanceId',
      type: IsarType.string,
    ),
    r'lastModifiedAt': PropertySchema(
      id: 6,
      name: r'lastModifiedAt',
      type: IsarType.dateTime,
    ),
    r'lastModifiedByDeviceId': PropertySchema(
      id: 7,
      name: r'lastModifiedByDeviceId',
      type: IsarType.string,
    ),
    r'lastSyncedAt': PropertySchema(
      id: 8,
      name: r'lastSyncedAt',
      type: IsarType.dateTime,
    ),
    r'ownerUserId': PropertySchema(
      id: 9,
      name: r'ownerUserId',
      type: IsarType.string,
    ),
    r'syncStatusKey': PropertySchema(
      id: 10,
      name: r'syncStatusKey',
      type: IsarType.string,
    ),
    r'templateId': PropertySchema(
      id: 11,
      name: r'templateId',
      type: IsarType.string,
    ),
    r'trainingMaxProfileJson': PropertySchema(
      id: 12,
      name: r'trainingMaxProfileJson',
      type: IsarType.string,
    ),
    r'version': PropertySchema(id: 13, name: r'version', type: IsarType.long),
  },
  estimateSize: _instanceCollectionEstimateSize,
  serialize: _instanceCollectionSerialize,
  deserialize: _instanceCollectionDeserialize,
  deserializeProp: _instanceCollectionDeserializeProp,
  idName: r'id',
  indexes: {
    r'instanceId': IndexSchema(
      id: -6720444513014720235,
      name: r'instanceId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'instanceId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'templateId': IndexSchema(
      id: -5352721467389445085,
      name: r'templateId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'templateId',
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
  getId: _instanceCollectionGetId,
  getLinks: _instanceCollectionGetLinks,
  attach: _instanceCollectionAttach,
  version: '3.1.0+1',
);

int _instanceCollectionEstimateSize(
  InstanceCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.currentStatesJson.length * 3;
  {
    for (var i = 0; i < object.currentStatesJson.length; i++) {
      final value = object.currentStatesJson[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.engineStateJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.instanceId.length * 3;
  {
    final value = object.lastModifiedByDeviceId;
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
  bytesCount += 3 + object.templateId.length * 3;
  {
    final value = object.trainingMaxProfileJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _instanceCollectionSerialize(
  InstanceCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeStringList(offsets[1], object.currentStatesJson);
  writer.writeLong(offsets[2], object.currentWorkoutIndex);
  writer.writeDateTime(offsets[3], object.deletedAt);
  writer.writeString(offsets[4], object.engineStateJson);
  writer.writeString(offsets[5], object.instanceId);
  writer.writeDateTime(offsets[6], object.lastModifiedAt);
  writer.writeString(offsets[7], object.lastModifiedByDeviceId);
  writer.writeDateTime(offsets[8], object.lastSyncedAt);
  writer.writeString(offsets[9], object.ownerUserId);
  writer.writeString(offsets[10], object.syncStatusKey);
  writer.writeString(offsets[11], object.templateId);
  writer.writeString(offsets[12], object.trainingMaxProfileJson);
  writer.writeLong(offsets[13], object.version);
}

InstanceCollection _instanceCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = InstanceCollection();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.currentStatesJson = reader.readStringList(offsets[1]) ?? [];
  object.currentWorkoutIndex = reader.readLong(offsets[2]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[3]);
  object.engineStateJson = reader.readStringOrNull(offsets[4]);
  object.id = id;
  object.instanceId = reader.readString(offsets[5]);
  object.lastModifiedAt = reader.readDateTime(offsets[6]);
  object.lastModifiedByDeviceId = reader.readStringOrNull(offsets[7]);
  object.lastSyncedAt = reader.readDateTimeOrNull(offsets[8]);
  object.ownerUserId = reader.readStringOrNull(offsets[9]);
  object.syncStatusKey = reader.readString(offsets[10]);
  object.templateId = reader.readString(offsets[11]);
  object.trainingMaxProfileJson = reader.readStringOrNull(offsets[12]);
  object.version = reader.readLong(offsets[13]);
  return object;
}

P _instanceCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _instanceCollectionGetId(InstanceCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _instanceCollectionGetLinks(
  InstanceCollection object,
) {
  return [];
}

void _instanceCollectionAttach(
  IsarCollection<dynamic> col,
  Id id,
  InstanceCollection object,
) {
  object.id = id;
}

extension InstanceCollectionByIndex on IsarCollection<InstanceCollection> {
  Future<InstanceCollection?> getByInstanceId(String instanceId) {
    return getByIndex(r'instanceId', [instanceId]);
  }

  InstanceCollection? getByInstanceIdSync(String instanceId) {
    return getByIndexSync(r'instanceId', [instanceId]);
  }

  Future<bool> deleteByInstanceId(String instanceId) {
    return deleteByIndex(r'instanceId', [instanceId]);
  }

  bool deleteByInstanceIdSync(String instanceId) {
    return deleteByIndexSync(r'instanceId', [instanceId]);
  }

  Future<List<InstanceCollection?>> getAllByInstanceId(
    List<String> instanceIdValues,
  ) {
    final values = instanceIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'instanceId', values);
  }

  List<InstanceCollection?> getAllByInstanceIdSync(
    List<String> instanceIdValues,
  ) {
    final values = instanceIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'instanceId', values);
  }

  Future<int> deleteAllByInstanceId(List<String> instanceIdValues) {
    final values = instanceIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'instanceId', values);
  }

  int deleteAllByInstanceIdSync(List<String> instanceIdValues) {
    final values = instanceIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'instanceId', values);
  }

  Future<Id> putByInstanceId(InstanceCollection object) {
    return putByIndex(r'instanceId', object);
  }

  Id putByInstanceIdSync(InstanceCollection object, {bool saveLinks = true}) {
    return putByIndexSync(r'instanceId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByInstanceId(List<InstanceCollection> objects) {
    return putAllByIndex(r'instanceId', objects);
  }

  List<Id> putAllByInstanceIdSync(
    List<InstanceCollection> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'instanceId', objects, saveLinks: saveLinks);
  }
}

extension InstanceCollectionQueryWhereSort
    on QueryBuilder<InstanceCollection, InstanceCollection, QWhere> {
  QueryBuilder<InstanceCollection, InstanceCollection, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension InstanceCollectionQueryWhere
    on QueryBuilder<InstanceCollection, InstanceCollection, QWhereClause> {
  QueryBuilder<InstanceCollection, InstanceCollection, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterWhereClause>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterWhereClause>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterWhereClause>
  instanceIdEqualTo(String instanceId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'instanceId', value: [instanceId]),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterWhereClause>
  instanceIdNotEqualTo(String instanceId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'instanceId',
                lower: [],
                upper: [instanceId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'instanceId',
                lower: [instanceId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'instanceId',
                lower: [instanceId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'instanceId',
                lower: [],
                upper: [instanceId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterWhereClause>
  templateIdEqualTo(String templateId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'templateId', value: [templateId]),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterWhereClause>
  templateIdNotEqualTo(String templateId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'templateId',
                lower: [],
                upper: [templateId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'templateId',
                lower: [templateId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'templateId',
                lower: [templateId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'templateId',
                lower: [],
                upper: [templateId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterWhereClause>
  ownerUserIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'ownerUserId', value: [null]),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterWhereClause>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterWhereClause>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterWhereClause>
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

extension InstanceCollectionQueryFilter
    on QueryBuilder<InstanceCollection, InstanceCollection, QFilterCondition> {
  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  currentStatesJsonElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currentStatesJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  currentStatesJsonElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currentStatesJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  currentStatesJsonElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currentStatesJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  currentStatesJsonElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currentStatesJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  currentStatesJsonElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'currentStatesJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  currentStatesJsonElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'currentStatesJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  currentStatesJsonElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'currentStatesJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  currentStatesJsonElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'currentStatesJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  currentStatesJsonElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currentStatesJson', value: ''),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  currentStatesJsonElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'currentStatesJson', value: ''),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  currentStatesJsonLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'currentStatesJson', length, true, length, true);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  currentStatesJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'currentStatesJson', 0, true, 0, true);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  currentStatesJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'currentStatesJson', 0, false, 999999, true);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  currentStatesJsonLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'currentStatesJson', 0, true, length, include);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  currentStatesJsonLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'currentStatesJson',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  currentStatesJsonLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'currentStatesJson',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  currentWorkoutIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currentWorkoutIndex', value: value),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  currentWorkoutIndexGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currentWorkoutIndex',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  currentWorkoutIndexLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currentWorkoutIndex',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  currentWorkoutIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currentWorkoutIndex',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'deletedAt'),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'deletedAt'),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deletedAt', value: value),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  engineStateJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'engineStateJson'),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  engineStateJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'engineStateJson'),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  engineStateJsonEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'engineStateJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  engineStateJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'engineStateJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  engineStateJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'engineStateJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  engineStateJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'engineStateJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  engineStateJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'engineStateJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  engineStateJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'engineStateJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  engineStateJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'engineStateJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  engineStateJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'engineStateJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  engineStateJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'engineStateJson', value: ''),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  engineStateJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'engineStateJson', value: ''),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  instanceIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'instanceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  instanceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'instanceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  instanceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'instanceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  instanceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'instanceId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  instanceIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'instanceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  instanceIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'instanceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  instanceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'instanceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  instanceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'instanceId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  instanceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'instanceId', value: ''),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  instanceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'instanceId', value: ''),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  lastModifiedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastModifiedAt', value: value),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  lastModifiedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastModifiedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  lastModifiedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastModifiedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  lastModifiedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastModifiedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  lastModifiedByDeviceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastModifiedByDeviceId'),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  lastModifiedByDeviceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastModifiedByDeviceId'),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  lastModifiedByDeviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastModifiedByDeviceId', value: ''),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  lastSyncedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastSyncedAt'),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  lastSyncedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastSyncedAt'),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  lastSyncedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastSyncedAt', value: value),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  ownerUserIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'ownerUserId'),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  ownerUserIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'ownerUserId'),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  ownerUserIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ownerUserId', value: ''),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  ownerUserIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'ownerUserId', value: ''),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  syncStatusKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncStatusKey', value: ''),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  syncStatusKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'syncStatusKey', value: ''),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  templateIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'templateId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  templateIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'templateId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  templateIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'templateId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  templateIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'templateId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  templateIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'templateId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  templateIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'templateId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  templateIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'templateId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  templateIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'templateId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  templateIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'templateId', value: ''),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  templateIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'templateId', value: ''),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  trainingMaxProfileJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'trainingMaxProfileJson'),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  trainingMaxProfileJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'trainingMaxProfileJson'),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  trainingMaxProfileJsonEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'trainingMaxProfileJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  trainingMaxProfileJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'trainingMaxProfileJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  trainingMaxProfileJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'trainingMaxProfileJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  trainingMaxProfileJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'trainingMaxProfileJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  trainingMaxProfileJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'trainingMaxProfileJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  trainingMaxProfileJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'trainingMaxProfileJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  trainingMaxProfileJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'trainingMaxProfileJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  trainingMaxProfileJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'trainingMaxProfileJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  trainingMaxProfileJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'trainingMaxProfileJson', value: ''),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  trainingMaxProfileJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'trainingMaxProfileJson',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
  versionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'version', value: value),
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterFilterCondition>
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

extension InstanceCollectionQueryObject
    on QueryBuilder<InstanceCollection, InstanceCollection, QFilterCondition> {}

extension InstanceCollectionQueryLinks
    on QueryBuilder<InstanceCollection, InstanceCollection, QFilterCondition> {}

extension InstanceCollectionQuerySortBy
    on QueryBuilder<InstanceCollection, InstanceCollection, QSortBy> {
  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  sortByCurrentWorkoutIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentWorkoutIndex', Sort.asc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  sortByCurrentWorkoutIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentWorkoutIndex', Sort.desc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  sortByEngineStateJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'engineStateJson', Sort.asc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  sortByEngineStateJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'engineStateJson', Sort.desc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  sortByInstanceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'instanceId', Sort.asc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  sortByInstanceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'instanceId', Sort.desc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  sortByLastModifiedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedAt', Sort.asc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  sortByLastModifiedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedAt', Sort.desc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  sortByLastModifiedByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedByDeviceId', Sort.asc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  sortByLastModifiedByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedByDeviceId', Sort.desc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  sortByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  sortByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  sortByOwnerUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.asc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  sortByOwnerUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.desc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  sortBySyncStatusKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatusKey', Sort.asc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  sortBySyncStatusKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatusKey', Sort.desc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  sortByTemplateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateId', Sort.asc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  sortByTemplateIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateId', Sort.desc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  sortByTrainingMaxProfileJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trainingMaxProfileJson', Sort.asc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  sortByTrainingMaxProfileJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trainingMaxProfileJson', Sort.desc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  sortByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  sortByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension InstanceCollectionQuerySortThenBy
    on QueryBuilder<InstanceCollection, InstanceCollection, QSortThenBy> {
  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  thenByCurrentWorkoutIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentWorkoutIndex', Sort.asc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  thenByCurrentWorkoutIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentWorkoutIndex', Sort.desc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  thenByEngineStateJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'engineStateJson', Sort.asc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  thenByEngineStateJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'engineStateJson', Sort.desc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  thenByInstanceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'instanceId', Sort.asc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  thenByInstanceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'instanceId', Sort.desc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  thenByLastModifiedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedAt', Sort.asc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  thenByLastModifiedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedAt', Sort.desc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  thenByLastModifiedByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedByDeviceId', Sort.asc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  thenByLastModifiedByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedByDeviceId', Sort.desc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  thenByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  thenByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  thenByOwnerUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.asc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  thenByOwnerUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.desc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  thenBySyncStatusKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatusKey', Sort.asc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  thenBySyncStatusKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatusKey', Sort.desc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  thenByTemplateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateId', Sort.asc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  thenByTemplateIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateId', Sort.desc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  thenByTrainingMaxProfileJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trainingMaxProfileJson', Sort.asc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  thenByTrainingMaxProfileJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trainingMaxProfileJson', Sort.desc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  thenByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QAfterSortBy>
  thenByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension InstanceCollectionQueryWhereDistinct
    on QueryBuilder<InstanceCollection, InstanceCollection, QDistinct> {
  QueryBuilder<InstanceCollection, InstanceCollection, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QDistinct>
  distinctByCurrentStatesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentStatesJson');
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QDistinct>
  distinctByCurrentWorkoutIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentWorkoutIndex');
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QDistinct>
  distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QDistinct>
  distinctByEngineStateJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'engineStateJson',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QDistinct>
  distinctByInstanceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'instanceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QDistinct>
  distinctByLastModifiedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastModifiedAt');
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QDistinct>
  distinctByLastModifiedByDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'lastModifiedByDeviceId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QDistinct>
  distinctByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncedAt');
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QDistinct>
  distinctByOwnerUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ownerUserId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QDistinct>
  distinctBySyncStatusKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'syncStatusKey',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QDistinct>
  distinctByTemplateId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'templateId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QDistinct>
  distinctByTrainingMaxProfileJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'trainingMaxProfileJson',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<InstanceCollection, InstanceCollection, QDistinct>
  distinctByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'version');
    });
  }
}

extension InstanceCollectionQueryProperty
    on QueryBuilder<InstanceCollection, InstanceCollection, QQueryProperty> {
  QueryBuilder<InstanceCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<InstanceCollection, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<InstanceCollection, List<String>, QQueryOperations>
  currentStatesJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentStatesJson');
    });
  }

  QueryBuilder<InstanceCollection, int, QQueryOperations>
  currentWorkoutIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentWorkoutIndex');
    });
  }

  QueryBuilder<InstanceCollection, DateTime?, QQueryOperations>
  deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<InstanceCollection, String?, QQueryOperations>
  engineStateJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'engineStateJson');
    });
  }

  QueryBuilder<InstanceCollection, String, QQueryOperations>
  instanceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'instanceId');
    });
  }

  QueryBuilder<InstanceCollection, DateTime, QQueryOperations>
  lastModifiedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastModifiedAt');
    });
  }

  QueryBuilder<InstanceCollection, String?, QQueryOperations>
  lastModifiedByDeviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastModifiedByDeviceId');
    });
  }

  QueryBuilder<InstanceCollection, DateTime?, QQueryOperations>
  lastSyncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncedAt');
    });
  }

  QueryBuilder<InstanceCollection, String?, QQueryOperations>
  ownerUserIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ownerUserId');
    });
  }

  QueryBuilder<InstanceCollection, String, QQueryOperations>
  syncStatusKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatusKey');
    });
  }

  QueryBuilder<InstanceCollection, String, QQueryOperations>
  templateIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'templateId');
    });
  }

  QueryBuilder<InstanceCollection, String?, QQueryOperations>
  trainingMaxProfileJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trainingMaxProfileJson');
    });
  }

  QueryBuilder<InstanceCollection, int, QQueryOperations> versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'version');
    });
  }
}
