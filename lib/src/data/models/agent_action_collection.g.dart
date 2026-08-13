// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_action_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAgentActionCollectionCollection on Isar {
  IsarCollection<AgentActionCollection> get agentActionCollections =>
      this.collection();
}

const AgentActionCollectionSchema = CollectionSchema(
  name: r'AgentActionCollection',
  id: -289275775526264589,
  properties: {
    r'actionId': PropertySchema(
      id: 0,
      name: r'actionId',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'ownerUserId': PropertySchema(
      id: 2,
      name: r'ownerUserId',
      type: IsarType.string,
    ),
    r'rawJsonPayload': PropertySchema(
      id: 3,
      name: r'rawJsonPayload',
      type: IsarType.string,
    ),
    r'statusKey': PropertySchema(
      id: 4,
      name: r'statusKey',
      type: IsarType.string,
    ),
    r'undoneAt': PropertySchema(
      id: 5,
      name: r'undoneAt',
      type: IsarType.dateTime,
    ),
  },
  estimateSize: _agentActionCollectionEstimateSize,
  serialize: _agentActionCollectionSerialize,
  deserialize: _agentActionCollectionDeserialize,
  deserializeProp: _agentActionCollectionDeserializeProp,
  idName: r'id',
  indexes: {
    r'actionId': IndexSchema(
      id: -48703777413607206,
      name: r'actionId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'actionId',
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
  getId: _agentActionCollectionGetId,
  getLinks: _agentActionCollectionGetLinks,
  attach: _agentActionCollectionAttach,
  version: '3.1.0+1',
);

int _agentActionCollectionEstimateSize(
  AgentActionCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.actionId.length * 3;
  {
    final value = object.ownerUserId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.rawJsonPayload.length * 3;
  bytesCount += 3 + object.statusKey.length * 3;
  return bytesCount;
}

void _agentActionCollectionSerialize(
  AgentActionCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.actionId);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.ownerUserId);
  writer.writeString(offsets[3], object.rawJsonPayload);
  writer.writeString(offsets[4], object.statusKey);
  writer.writeDateTime(offsets[5], object.undoneAt);
}

AgentActionCollection _agentActionCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AgentActionCollection();
  object.actionId = reader.readString(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.id = id;
  object.ownerUserId = reader.readStringOrNull(offsets[2]);
  object.rawJsonPayload = reader.readString(offsets[3]);
  object.statusKey = reader.readString(offsets[4]);
  object.undoneAt = reader.readDateTimeOrNull(offsets[5]);
  return object;
}

P _agentActionCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _agentActionCollectionGetId(AgentActionCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _agentActionCollectionGetLinks(
  AgentActionCollection object,
) {
  return [];
}

void _agentActionCollectionAttach(
  IsarCollection<dynamic> col,
  Id id,
  AgentActionCollection object,
) {
  object.id = id;
}

extension AgentActionCollectionByIndex
    on IsarCollection<AgentActionCollection> {
  Future<AgentActionCollection?> getByActionId(String actionId) {
    return getByIndex(r'actionId', [actionId]);
  }

  AgentActionCollection? getByActionIdSync(String actionId) {
    return getByIndexSync(r'actionId', [actionId]);
  }

  Future<bool> deleteByActionId(String actionId) {
    return deleteByIndex(r'actionId', [actionId]);
  }

  bool deleteByActionIdSync(String actionId) {
    return deleteByIndexSync(r'actionId', [actionId]);
  }

  Future<List<AgentActionCollection?>> getAllByActionId(
    List<String> actionIdValues,
  ) {
    final values = actionIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'actionId', values);
  }

  List<AgentActionCollection?> getAllByActionIdSync(
    List<String> actionIdValues,
  ) {
    final values = actionIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'actionId', values);
  }

  Future<int> deleteAllByActionId(List<String> actionIdValues) {
    final values = actionIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'actionId', values);
  }

  int deleteAllByActionIdSync(List<String> actionIdValues) {
    final values = actionIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'actionId', values);
  }

  Future<Id> putByActionId(AgentActionCollection object) {
    return putByIndex(r'actionId', object);
  }

  Id putByActionIdSync(AgentActionCollection object, {bool saveLinks = true}) {
    return putByIndexSync(r'actionId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByActionId(List<AgentActionCollection> objects) {
    return putAllByIndex(r'actionId', objects);
  }

  List<Id> putAllByActionIdSync(
    List<AgentActionCollection> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'actionId', objects, saveLinks: saveLinks);
  }
}

extension AgentActionCollectionQueryWhereSort
    on QueryBuilder<AgentActionCollection, AgentActionCollection, QWhere> {
  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AgentActionCollectionQueryWhere
    on
        QueryBuilder<
          AgentActionCollection,
          AgentActionCollection,
          QWhereClause
        > {
  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterWhereClause>
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

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterWhereClause>
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

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterWhereClause>
  actionIdEqualTo(String actionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'actionId', value: [actionId]),
      );
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterWhereClause>
  actionIdNotEqualTo(String actionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'actionId',
                lower: [],
                upper: [actionId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'actionId',
                lower: [actionId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'actionId',
                lower: [actionId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'actionId',
                lower: [],
                upper: [actionId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterWhereClause>
  ownerUserIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'ownerUserId', value: [null]),
      );
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterWhereClause>
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

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterWhereClause>
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

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterWhereClause>
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

extension AgentActionCollectionQueryFilter
    on
        QueryBuilder<
          AgentActionCollection,
          AgentActionCollection,
          QFilterCondition
        > {
  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  actionIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'actionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  actionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'actionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  actionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'actionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  actionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'actionId',
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
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  actionIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'actionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  actionIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'actionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  actionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'actionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  actionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'actionId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  actionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'actionId', value: ''),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  actionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'actionId', value: ''),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
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
    AgentActionCollection,
    AgentActionCollection,
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
    AgentActionCollection,
    AgentActionCollection,
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
    AgentActionCollection,
    AgentActionCollection,
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
    AgentActionCollection,
    AgentActionCollection,
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
    AgentActionCollection,
    AgentActionCollection,
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
    AgentActionCollection,
    AgentActionCollection,
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
    AgentActionCollection,
    AgentActionCollection,
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
    AgentActionCollection,
    AgentActionCollection,
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
    AgentActionCollection,
    AgentActionCollection,
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
    AgentActionCollection,
    AgentActionCollection,
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
    AgentActionCollection,
    AgentActionCollection,
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
    AgentActionCollection,
    AgentActionCollection,
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
    AgentActionCollection,
    AgentActionCollection,
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
    AgentActionCollection,
    AgentActionCollection,
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
    AgentActionCollection,
    AgentActionCollection,
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
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  rawJsonPayloadEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'rawJsonPayload',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  rawJsonPayloadGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'rawJsonPayload',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  rawJsonPayloadLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'rawJsonPayload',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  rawJsonPayloadBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'rawJsonPayload',
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
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  rawJsonPayloadStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'rawJsonPayload',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  rawJsonPayloadEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'rawJsonPayload',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  rawJsonPayloadContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'rawJsonPayload',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  rawJsonPayloadMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'rawJsonPayload',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  rawJsonPayloadIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'rawJsonPayload', value: ''),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  rawJsonPayloadIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'rawJsonPayload', value: ''),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  statusKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'statusKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  statusKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'statusKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  statusKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'statusKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  statusKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'statusKey',
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
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  statusKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'statusKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  statusKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'statusKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  statusKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'statusKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  statusKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'statusKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  statusKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'statusKey', value: ''),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  statusKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'statusKey', value: ''),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  undoneAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'undoneAt'),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  undoneAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'undoneAt'),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  undoneAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'undoneAt', value: value),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  undoneAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'undoneAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  undoneAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'undoneAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    AgentActionCollection,
    AgentActionCollection,
    QAfterFilterCondition
  >
  undoneAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'undoneAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension AgentActionCollectionQueryObject
    on
        QueryBuilder<
          AgentActionCollection,
          AgentActionCollection,
          QFilterCondition
        > {}

extension AgentActionCollectionQueryLinks
    on
        QueryBuilder<
          AgentActionCollection,
          AgentActionCollection,
          QFilterCondition
        > {}

extension AgentActionCollectionQuerySortBy
    on QueryBuilder<AgentActionCollection, AgentActionCollection, QSortBy> {
  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterSortBy>
  sortByActionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionId', Sort.asc);
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterSortBy>
  sortByActionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionId', Sort.desc);
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterSortBy>
  sortByOwnerUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.asc);
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterSortBy>
  sortByOwnerUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.desc);
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterSortBy>
  sortByRawJsonPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJsonPayload', Sort.asc);
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterSortBy>
  sortByRawJsonPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJsonPayload', Sort.desc);
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterSortBy>
  sortByStatusKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusKey', Sort.asc);
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterSortBy>
  sortByStatusKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusKey', Sort.desc);
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterSortBy>
  sortByUndoneAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'undoneAt', Sort.asc);
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterSortBy>
  sortByUndoneAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'undoneAt', Sort.desc);
    });
  }
}

extension AgentActionCollectionQuerySortThenBy
    on QueryBuilder<AgentActionCollection, AgentActionCollection, QSortThenBy> {
  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterSortBy>
  thenByActionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionId', Sort.asc);
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterSortBy>
  thenByActionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionId', Sort.desc);
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterSortBy>
  thenByOwnerUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.asc);
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterSortBy>
  thenByOwnerUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.desc);
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterSortBy>
  thenByRawJsonPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJsonPayload', Sort.asc);
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterSortBy>
  thenByRawJsonPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJsonPayload', Sort.desc);
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterSortBy>
  thenByStatusKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusKey', Sort.asc);
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterSortBy>
  thenByStatusKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusKey', Sort.desc);
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterSortBy>
  thenByUndoneAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'undoneAt', Sort.asc);
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QAfterSortBy>
  thenByUndoneAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'undoneAt', Sort.desc);
    });
  }
}

extension AgentActionCollectionQueryWhereDistinct
    on QueryBuilder<AgentActionCollection, AgentActionCollection, QDistinct> {
  QueryBuilder<AgentActionCollection, AgentActionCollection, QDistinct>
  distinctByActionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QDistinct>
  distinctByOwnerUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ownerUserId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QDistinct>
  distinctByRawJsonPayload({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'rawJsonPayload',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QDistinct>
  distinctByStatusKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'statusKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AgentActionCollection, AgentActionCollection, QDistinct>
  distinctByUndoneAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'undoneAt');
    });
  }
}

extension AgentActionCollectionQueryProperty
    on
        QueryBuilder<
          AgentActionCollection,
          AgentActionCollection,
          QQueryProperty
        > {
  QueryBuilder<AgentActionCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AgentActionCollection, String, QQueryOperations>
  actionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actionId');
    });
  }

  QueryBuilder<AgentActionCollection, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<AgentActionCollection, String?, QQueryOperations>
  ownerUserIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ownerUserId');
    });
  }

  QueryBuilder<AgentActionCollection, String, QQueryOperations>
  rawJsonPayloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rawJsonPayload');
    });
  }

  QueryBuilder<AgentActionCollection, String, QQueryOperations>
  statusKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'statusKey');
    });
  }

  QueryBuilder<AgentActionCollection, DateTime?, QQueryOperations>
  undoneAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'undoneAt');
    });
  }
}
