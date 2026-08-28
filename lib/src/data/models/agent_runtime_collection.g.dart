// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_runtime_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAgentRuntimeCollectionCollection on Isar {
  IsarCollection<AgentRuntimeCollection> get agentRuntimeCollections =>
      this.collection();
}

const AgentRuntimeCollectionSchema = CollectionSchema(
  name: r'AgentRuntimeCollection',
  id: 4455780028477532173,
  properties: {
    r'documentId': PropertySchema(
      id: 0,
      name: r'documentId',
      type: IsarType.string,
    ),
    r'documentKey': PropertySchema(
      id: 1,
      name: r'documentKey',
      type: IsarType.string,
    ),
    r'kind': PropertySchema(id: 2, name: r'kind', type: IsarType.string),
    r'ownerUserId': PropertySchema(
      id: 3,
      name: r'ownerUserId',
      type: IsarType.string,
    ),
    r'payload': PropertySchema(id: 4, name: r'payload', type: IsarType.string),
    r'updatedAt': PropertySchema(
      id: 5,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },
  estimateSize: _agentRuntimeCollectionEstimateSize,
  serialize: _agentRuntimeCollectionSerialize,
  deserialize: _agentRuntimeCollectionDeserialize,
  deserializeProp: _agentRuntimeCollectionDeserializeProp,
  idName: r'id',
  indexes: {
    r'documentKey': IndexSchema(
      id: 3456124934813830833,
      name: r'documentKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'documentKey',
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
    r'kind': IndexSchema(
      id: 1484550194077596484,
      name: r'kind',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'kind',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'updatedAt': IndexSchema(
      id: -6238191080293565125,
      name: r'updatedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'updatedAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _agentRuntimeCollectionGetId,
  getLinks: _agentRuntimeCollectionGetLinks,
  attach: _agentRuntimeCollectionAttach,
  version: '3.1.0+1',
);

int _agentRuntimeCollectionEstimateSize(
  AgentRuntimeCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.documentId.length * 3;
  bytesCount += 3 + object.documentKey.length * 3;
  bytesCount += 3 + object.kind.length * 3;
  {
    final value = object.ownerUserId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.payload.length * 3;
  return bytesCount;
}

void _agentRuntimeCollectionSerialize(
  AgentRuntimeCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.documentId);
  writer.writeString(offsets[1], object.documentKey);
  writer.writeString(offsets[2], object.kind);
  writer.writeString(offsets[3], object.ownerUserId);
  writer.writeString(offsets[4], object.payload);
  writer.writeDateTime(offsets[5], object.updatedAt);
}

AgentRuntimeCollection _agentRuntimeCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AgentRuntimeCollection();
  object.documentId = reader.readString(offsets[0]);
  object.documentKey = reader.readString(offsets[1]);
  object.id = id;
  object.kind = reader.readString(offsets[2]);
  object.ownerUserId = reader.readStringOrNull(offsets[3]);
  object.payload = reader.readString(offsets[4]);
  object.updatedAt = reader.readDateTime(offsets[5]);
  return object;
}

P _agentRuntimeCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _agentRuntimeCollectionGetId(AgentRuntimeCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _agentRuntimeCollectionGetLinks(
  AgentRuntimeCollection object,
) {
  return [];
}

void _agentRuntimeCollectionAttach(
  IsarCollection<dynamic> col,
  Id id,
  AgentRuntimeCollection object,
) {
  object.id = id;
}

extension AgentRuntimeCollectionByIndex
    on IsarCollection<AgentRuntimeCollection> {
  Future<AgentRuntimeCollection?> getByDocumentKey(String documentKey) {
    return getByIndex(r'documentKey', [documentKey]);
  }

  AgentRuntimeCollection? getByDocumentKeySync(String documentKey) {
    return getByIndexSync(r'documentKey', [documentKey]);
  }

  Future<bool> deleteByDocumentKey(String documentKey) {
    return deleteByIndex(r'documentKey', [documentKey]);
  }

  bool deleteByDocumentKeySync(String documentKey) {
    return deleteByIndexSync(r'documentKey', [documentKey]);
  }

  Future<List<AgentRuntimeCollection?>> getAllByDocumentKey(
    List<String> documentKeyValues,
  ) {
    final values = documentKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'documentKey', values);
  }

  List<AgentRuntimeCollection?> getAllByDocumentKeySync(
    List<String> documentKeyValues,
  ) {
    final values = documentKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'documentKey', values);
  }

  Future<int> deleteAllByDocumentKey(List<String> documentKeyValues) {
    final values = documentKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'documentKey', values);
  }

  int deleteAllByDocumentKeySync(List<String> documentKeyValues) {
    final values = documentKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'documentKey', values);
  }

  Future<Id> putByDocumentKey(AgentRuntimeCollection object) {
    return putByIndex(r'documentKey', object);
  }

  Id putByDocumentKeySync(
    AgentRuntimeCollection object, {
    bool saveLinks = true,
  }) {
    return putByIndexSync(r'documentKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDocumentKey(List<AgentRuntimeCollection> objects) {
    return putAllByIndex(r'documentKey', objects);
  }

  List<Id> putAllByDocumentKeySync(
    List<AgentRuntimeCollection> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'documentKey', objects, saveLinks: saveLinks);
  }
}

extension AgentRuntimeCollectionQueryWhereSort
    on QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QWhere> {
  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QAfterWhere>
  anyUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'updatedAt'),
      );
    });
  }
}

extension AgentRuntimeCollectionQueryWhere
    on
        QueryBuilder<
          AgentRuntimeCollection,
          AgentRuntimeCollection,
          QWhereClause
        > {
  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
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
    AgentRuntimeCollection,
    AgentRuntimeCollection,
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
    AgentRuntimeCollection,
    AgentRuntimeCollection,
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
    AgentRuntimeCollection,
    AgentRuntimeCollection,
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
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterWhereClause
  >
  documentKeyEqualTo(String documentKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'documentKey',
          value: [documentKey],
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterWhereClause
  >
  documentKeyNotEqualTo(String documentKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'documentKey',
                lower: [],
                upper: [documentKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'documentKey',
                lower: [documentKey],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'documentKey',
                lower: [documentKey],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'documentKey',
                lower: [],
                upper: [documentKey],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
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
    AgentRuntimeCollection,
    AgentRuntimeCollection,
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
    AgentRuntimeCollection,
    AgentRuntimeCollection,
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
    AgentRuntimeCollection,
    AgentRuntimeCollection,
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

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterWhereClause
  >
  kindEqualTo(String kind) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'kind', value: [kind]),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterWhereClause
  >
  kindNotEqualTo(String kind) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'kind',
                lower: [],
                upper: [kind],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'kind',
                lower: [kind],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'kind',
                lower: [kind],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'kind',
                lower: [],
                upper: [kind],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterWhereClause
  >
  updatedAtEqualTo(DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'updatedAt', value: [updatedAt]),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterWhereClause
  >
  updatedAtNotEqualTo(DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [],
                upper: [updatedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [updatedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [updatedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [],
                upper: [updatedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterWhereClause
  >
  updatedAtGreaterThan(DateTime updatedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'updatedAt',
          lower: [updatedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterWhereClause
  >
  updatedAtLessThan(DateTime updatedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'updatedAt',
          lower: [],
          upper: [updatedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterWhereClause
  >
  updatedAtBetween(
    DateTime lowerUpdatedAt,
    DateTime upperUpdatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'updatedAt',
          lower: [lowerUpdatedAt],
          includeLower: includeLower,
          upper: [upperUpdatedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension AgentRuntimeCollectionQueryFilter
    on
        QueryBuilder<
          AgentRuntimeCollection,
          AgentRuntimeCollection,
          QFilterCondition
        > {
  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  documentIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'documentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  documentIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'documentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  documentIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'documentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  documentIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'documentId',
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
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  documentIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'documentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  documentIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'documentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  documentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'documentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  documentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'documentId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  documentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'documentId', value: ''),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  documentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'documentId', value: ''),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  documentKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'documentKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  documentKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'documentKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  documentKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'documentKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  documentKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'documentKey',
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
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  documentKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'documentKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  documentKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'documentKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  documentKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'documentKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  documentKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'documentKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  documentKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'documentKey', value: ''),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  documentKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'documentKey', value: ''),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
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
    AgentRuntimeCollection,
    AgentRuntimeCollection,
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
    AgentRuntimeCollection,
    AgentRuntimeCollection,
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
    AgentRuntimeCollection,
    AgentRuntimeCollection,
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
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  kindEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  kindGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  kindLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  kindBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'kind',
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
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  kindStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  kindEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  kindContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  kindMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'kind',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  kindIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kind', value: ''),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  kindIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'kind', value: ''),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
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
    AgentRuntimeCollection,
    AgentRuntimeCollection,
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
    AgentRuntimeCollection,
    AgentRuntimeCollection,
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
    AgentRuntimeCollection,
    AgentRuntimeCollection,
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
    AgentRuntimeCollection,
    AgentRuntimeCollection,
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
    AgentRuntimeCollection,
    AgentRuntimeCollection,
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
    AgentRuntimeCollection,
    AgentRuntimeCollection,
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
    AgentRuntimeCollection,
    AgentRuntimeCollection,
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
    AgentRuntimeCollection,
    AgentRuntimeCollection,
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
    AgentRuntimeCollection,
    AgentRuntimeCollection,
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
    AgentRuntimeCollection,
    AgentRuntimeCollection,
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
    AgentRuntimeCollection,
    AgentRuntimeCollection,
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
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  payloadEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'payload',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  payloadGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'payload',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  payloadLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'payload',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  payloadBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'payload',
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
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  payloadStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'payload',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  payloadEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'payload',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  payloadContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'payload',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  payloadMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'payload',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  payloadIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'payload', value: ''),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  payloadIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'payload', value: ''),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  updatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  updatedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    AgentRuntimeCollection,
    AgentRuntimeCollection,
    QAfterFilterCondition
  >
  updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension AgentRuntimeCollectionQueryObject
    on
        QueryBuilder<
          AgentRuntimeCollection,
          AgentRuntimeCollection,
          QFilterCondition
        > {}

extension AgentRuntimeCollectionQueryLinks
    on
        QueryBuilder<
          AgentRuntimeCollection,
          AgentRuntimeCollection,
          QFilterCondition
        > {}

extension AgentRuntimeCollectionQuerySortBy
    on QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QSortBy> {
  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QAfterSortBy>
  sortByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.asc);
    });
  }

  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QAfterSortBy>
  sortByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.desc);
    });
  }

  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QAfterSortBy>
  sortByDocumentKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentKey', Sort.asc);
    });
  }

  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QAfterSortBy>
  sortByDocumentKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentKey', Sort.desc);
    });
  }

  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QAfterSortBy>
  sortByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QAfterSortBy>
  sortByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QAfterSortBy>
  sortByOwnerUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.asc);
    });
  }

  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QAfterSortBy>
  sortByOwnerUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.desc);
    });
  }

  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QAfterSortBy>
  sortByPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.asc);
    });
  }

  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QAfterSortBy>
  sortByPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.desc);
    });
  }

  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AgentRuntimeCollectionQuerySortThenBy
    on
        QueryBuilder<
          AgentRuntimeCollection,
          AgentRuntimeCollection,
          QSortThenBy
        > {
  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QAfterSortBy>
  thenByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.asc);
    });
  }

  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QAfterSortBy>
  thenByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.desc);
    });
  }

  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QAfterSortBy>
  thenByDocumentKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentKey', Sort.asc);
    });
  }

  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QAfterSortBy>
  thenByDocumentKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentKey', Sort.desc);
    });
  }

  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QAfterSortBy>
  thenByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QAfterSortBy>
  thenByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QAfterSortBy>
  thenByOwnerUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.asc);
    });
  }

  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QAfterSortBy>
  thenByOwnerUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.desc);
    });
  }

  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QAfterSortBy>
  thenByPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.asc);
    });
  }

  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QAfterSortBy>
  thenByPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.desc);
    });
  }

  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AgentRuntimeCollectionQueryWhereDistinct
    on QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QDistinct> {
  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QDistinct>
  distinctByDocumentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QDistinct>
  distinctByDocumentKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documentKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QDistinct>
  distinctByKind({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kind', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QDistinct>
  distinctByOwnerUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ownerUserId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QDistinct>
  distinctByPayload({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'payload', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AgentRuntimeCollection, AgentRuntimeCollection, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension AgentRuntimeCollectionQueryProperty
    on
        QueryBuilder<
          AgentRuntimeCollection,
          AgentRuntimeCollection,
          QQueryProperty
        > {
  QueryBuilder<AgentRuntimeCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AgentRuntimeCollection, String, QQueryOperations>
  documentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documentId');
    });
  }

  QueryBuilder<AgentRuntimeCollection, String, QQueryOperations>
  documentKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documentKey');
    });
  }

  QueryBuilder<AgentRuntimeCollection, String, QQueryOperations>
  kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kind');
    });
  }

  QueryBuilder<AgentRuntimeCollection, String?, QQueryOperations>
  ownerUserIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ownerUserId');
    });
  }

  QueryBuilder<AgentRuntimeCollection, String, QQueryOperations>
  payloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'payload');
    });
  }

  QueryBuilder<AgentRuntimeCollection, DateTime, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
