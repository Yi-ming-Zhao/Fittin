// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_content_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserContentCollectionCollection on Isar {
  IsarCollection<UserContentCollection> get userContentCollections =>
      this.collection();
}

const UserContentCollectionSchema = CollectionSchema(
  name: r'UserContentCollection',
  id: -8762661622936299720,
  properties: {
    r'contentId': PropertySchema(
      id: 0,
      name: r'contentId',
      type: IsarType.string,
    ),
    r'contentKey': PropertySchema(
      id: 1,
      name: r'contentKey',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'deletedAt': PropertySchema(
      id: 3,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'kindKey': PropertySchema(id: 4, name: r'kindKey', type: IsarType.string),
    r'lastModifiedAt': PropertySchema(
      id: 5,
      name: r'lastModifiedAt',
      type: IsarType.dateTime,
    ),
    r'lastModifiedByDeviceId': PropertySchema(
      id: 6,
      name: r'lastModifiedByDeviceId',
      type: IsarType.string,
    ),
    r'lastSyncedAt': PropertySchema(
      id: 7,
      name: r'lastSyncedAt',
      type: IsarType.dateTime,
    ),
    r'ownerUserId': PropertySchema(
      id: 8,
      name: r'ownerUserId',
      type: IsarType.string,
    ),
    r'rawJsonPayload': PropertySchema(
      id: 9,
      name: r'rawJsonPayload',
      type: IsarType.string,
    ),
    r'syncStatusKey': PropertySchema(
      id: 10,
      name: r'syncStatusKey',
      type: IsarType.string,
    ),
    r'version': PropertySchema(id: 11, name: r'version', type: IsarType.long),
  },
  estimateSize: _userContentCollectionEstimateSize,
  serialize: _userContentCollectionSerialize,
  deserialize: _userContentCollectionDeserialize,
  deserializeProp: _userContentCollectionDeserializeProp,
  idName: r'id',
  indexes: {
    r'contentKey': IndexSchema(
      id: -9125623273277660326,
      name: r'contentKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'contentKey',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'contentId': IndexSchema(
      id: -332487537278013663,
      name: r'contentId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'contentId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'kindKey': IndexSchema(
      id: 8095817513437614369,
      name: r'kindKey',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'kindKey',
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
  getId: _userContentCollectionGetId,
  getLinks: _userContentCollectionGetLinks,
  attach: _userContentCollectionAttach,
  version: '3.1.0+1',
);

int _userContentCollectionEstimateSize(
  UserContentCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.contentId.length * 3;
  bytesCount += 3 + object.contentKey.length * 3;
  bytesCount += 3 + object.kindKey.length * 3;
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
  bytesCount += 3 + object.rawJsonPayload.length * 3;
  bytesCount += 3 + object.syncStatusKey.length * 3;
  return bytesCount;
}

void _userContentCollectionSerialize(
  UserContentCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.contentId);
  writer.writeString(offsets[1], object.contentKey);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeDateTime(offsets[3], object.deletedAt);
  writer.writeString(offsets[4], object.kindKey);
  writer.writeDateTime(offsets[5], object.lastModifiedAt);
  writer.writeString(offsets[6], object.lastModifiedByDeviceId);
  writer.writeDateTime(offsets[7], object.lastSyncedAt);
  writer.writeString(offsets[8], object.ownerUserId);
  writer.writeString(offsets[9], object.rawJsonPayload);
  writer.writeString(offsets[10], object.syncStatusKey);
  writer.writeLong(offsets[11], object.version);
}

UserContentCollection _userContentCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserContentCollection();
  object.contentId = reader.readString(offsets[0]);
  object.contentKey = reader.readString(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[3]);
  object.id = id;
  object.kindKey = reader.readString(offsets[4]);
  object.lastModifiedAt = reader.readDateTime(offsets[5]);
  object.lastModifiedByDeviceId = reader.readStringOrNull(offsets[6]);
  object.lastSyncedAt = reader.readDateTimeOrNull(offsets[7]);
  object.ownerUserId = reader.readStringOrNull(offsets[8]);
  object.rawJsonPayload = reader.readString(offsets[9]);
  object.syncStatusKey = reader.readString(offsets[10]);
  object.version = reader.readLong(offsets[11]);
  return object;
}

P _userContentCollectionDeserializeProp<P>(
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
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userContentCollectionGetId(UserContentCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userContentCollectionGetLinks(
  UserContentCollection object,
) {
  return [];
}

void _userContentCollectionAttach(
  IsarCollection<dynamic> col,
  Id id,
  UserContentCollection object,
) {
  object.id = id;
}

extension UserContentCollectionByIndex
    on IsarCollection<UserContentCollection> {
  Future<UserContentCollection?> getByContentKey(String contentKey) {
    return getByIndex(r'contentKey', [contentKey]);
  }

  UserContentCollection? getByContentKeySync(String contentKey) {
    return getByIndexSync(r'contentKey', [contentKey]);
  }

  Future<bool> deleteByContentKey(String contentKey) {
    return deleteByIndex(r'contentKey', [contentKey]);
  }

  bool deleteByContentKeySync(String contentKey) {
    return deleteByIndexSync(r'contentKey', [contentKey]);
  }

  Future<List<UserContentCollection?>> getAllByContentKey(
    List<String> contentKeyValues,
  ) {
    final values = contentKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'contentKey', values);
  }

  List<UserContentCollection?> getAllByContentKeySync(
    List<String> contentKeyValues,
  ) {
    final values = contentKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'contentKey', values);
  }

  Future<int> deleteAllByContentKey(List<String> contentKeyValues) {
    final values = contentKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'contentKey', values);
  }

  int deleteAllByContentKeySync(List<String> contentKeyValues) {
    final values = contentKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'contentKey', values);
  }

  Future<Id> putByContentKey(UserContentCollection object) {
    return putByIndex(r'contentKey', object);
  }

  Id putByContentKeySync(
    UserContentCollection object, {
    bool saveLinks = true,
  }) {
    return putByIndexSync(r'contentKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByContentKey(List<UserContentCollection> objects) {
    return putAllByIndex(r'contentKey', objects);
  }

  List<Id> putAllByContentKeySync(
    List<UserContentCollection> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'contentKey', objects, saveLinks: saveLinks);
  }
}

extension UserContentCollectionQueryWhereSort
    on QueryBuilder<UserContentCollection, UserContentCollection, QWhere> {
  QueryBuilder<UserContentCollection, UserContentCollection, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserContentCollectionQueryWhere
    on
        QueryBuilder<
          UserContentCollection,
          UserContentCollection,
          QWhereClause
        > {
  QueryBuilder<UserContentCollection, UserContentCollection, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterWhereClause>
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

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterWhereClause>
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

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterWhereClause>
  contentKeyEqualTo(String contentKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'contentKey', value: [contentKey]),
      );
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterWhereClause>
  contentKeyNotEqualTo(String contentKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'contentKey',
                lower: [],
                upper: [contentKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'contentKey',
                lower: [contentKey],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'contentKey',
                lower: [contentKey],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'contentKey',
                lower: [],
                upper: [contentKey],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterWhereClause>
  contentIdEqualTo(String contentId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'contentId', value: [contentId]),
      );
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterWhereClause>
  contentIdNotEqualTo(String contentId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'contentId',
                lower: [],
                upper: [contentId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'contentId',
                lower: [contentId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'contentId',
                lower: [contentId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'contentId',
                lower: [],
                upper: [contentId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterWhereClause>
  kindKeyEqualTo(String kindKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'kindKey', value: [kindKey]),
      );
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterWhereClause>
  kindKeyNotEqualTo(String kindKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'kindKey',
                lower: [],
                upper: [kindKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'kindKey',
                lower: [kindKey],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'kindKey',
                lower: [kindKey],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'kindKey',
                lower: [],
                upper: [kindKey],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterWhereClause>
  ownerUserIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'ownerUserId', value: [null]),
      );
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterWhereClause>
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

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterWhereClause>
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

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterWhereClause>
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

extension UserContentCollectionQueryFilter
    on
        QueryBuilder<
          UserContentCollection,
          UserContentCollection,
          QFilterCondition
        > {
  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
  contentIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'contentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
  contentIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'contentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
  contentIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'contentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
  contentIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'contentId',
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
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
  contentIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'contentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
  contentIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'contentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
  contentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'contentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
  contentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'contentId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
  contentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'contentId', value: ''),
      );
    });
  }

  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
  contentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'contentId', value: ''),
      );
    });
  }

  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
  contentKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'contentKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
  contentKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'contentKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
  contentKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'contentKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
  contentKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'contentKey',
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
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
  contentKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'contentKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
  contentKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'contentKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
  contentKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'contentKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
  contentKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'contentKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
  contentKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'contentKey', value: ''),
      );
    });
  }

  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
  contentKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'contentKey', value: ''),
      );
    });
  }

  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
  kindKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'kindKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
  kindKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'kindKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
  kindKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'kindKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
  kindKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'kindKey',
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
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
  kindKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'kindKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
  kindKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'kindKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
  kindKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'kindKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
  kindKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'kindKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
  kindKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kindKey', value: ''),
      );
    });
  }

  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
  kindKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'kindKey', value: ''),
      );
    });
  }

  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
  lastModifiedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastModifiedAt', value: value),
      );
    });
  }

  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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
    UserContentCollection,
    UserContentCollection,
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

extension UserContentCollectionQueryObject
    on
        QueryBuilder<
          UserContentCollection,
          UserContentCollection,
          QFilterCondition
        > {}

extension UserContentCollectionQueryLinks
    on
        QueryBuilder<
          UserContentCollection,
          UserContentCollection,
          QFilterCondition
        > {}

extension UserContentCollectionQuerySortBy
    on QueryBuilder<UserContentCollection, UserContentCollection, QSortBy> {
  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  sortByContentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentId', Sort.asc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  sortByContentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentId', Sort.desc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  sortByContentKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentKey', Sort.asc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  sortByContentKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentKey', Sort.desc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  sortByKindKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kindKey', Sort.asc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  sortByKindKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kindKey', Sort.desc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  sortByLastModifiedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedAt', Sort.asc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  sortByLastModifiedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedAt', Sort.desc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  sortByLastModifiedByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedByDeviceId', Sort.asc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  sortByLastModifiedByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedByDeviceId', Sort.desc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  sortByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  sortByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  sortByOwnerUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.asc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  sortByOwnerUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.desc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  sortByRawJsonPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJsonPayload', Sort.asc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  sortByRawJsonPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJsonPayload', Sort.desc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  sortBySyncStatusKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatusKey', Sort.asc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  sortBySyncStatusKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatusKey', Sort.desc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  sortByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  sortByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension UserContentCollectionQuerySortThenBy
    on QueryBuilder<UserContentCollection, UserContentCollection, QSortThenBy> {
  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  thenByContentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentId', Sort.asc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  thenByContentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentId', Sort.desc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  thenByContentKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentKey', Sort.asc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  thenByContentKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentKey', Sort.desc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  thenByKindKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kindKey', Sort.asc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  thenByKindKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kindKey', Sort.desc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  thenByLastModifiedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedAt', Sort.asc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  thenByLastModifiedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedAt', Sort.desc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  thenByLastModifiedByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedByDeviceId', Sort.asc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  thenByLastModifiedByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedByDeviceId', Sort.desc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  thenByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  thenByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  thenByOwnerUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.asc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  thenByOwnerUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.desc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  thenByRawJsonPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJsonPayload', Sort.asc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  thenByRawJsonPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJsonPayload', Sort.desc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  thenBySyncStatusKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatusKey', Sort.asc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  thenBySyncStatusKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatusKey', Sort.desc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  thenByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QAfterSortBy>
  thenByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension UserContentCollectionQueryWhereDistinct
    on QueryBuilder<UserContentCollection, UserContentCollection, QDistinct> {
  QueryBuilder<UserContentCollection, UserContentCollection, QDistinct>
  distinctByContentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QDistinct>
  distinctByContentKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contentKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QDistinct>
  distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QDistinct>
  distinctByKindKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kindKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QDistinct>
  distinctByLastModifiedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastModifiedAt');
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QDistinct>
  distinctByLastModifiedByDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'lastModifiedByDeviceId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QDistinct>
  distinctByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncedAt');
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QDistinct>
  distinctByOwnerUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ownerUserId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QDistinct>
  distinctByRawJsonPayload({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'rawJsonPayload',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QDistinct>
  distinctBySyncStatusKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'syncStatusKey',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<UserContentCollection, UserContentCollection, QDistinct>
  distinctByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'version');
    });
  }
}

extension UserContentCollectionQueryProperty
    on
        QueryBuilder<
          UserContentCollection,
          UserContentCollection,
          QQueryProperty
        > {
  QueryBuilder<UserContentCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserContentCollection, String, QQueryOperations>
  contentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contentId');
    });
  }

  QueryBuilder<UserContentCollection, String, QQueryOperations>
  contentKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contentKey');
    });
  }

  QueryBuilder<UserContentCollection, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<UserContentCollection, DateTime?, QQueryOperations>
  deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<UserContentCollection, String, QQueryOperations>
  kindKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kindKey');
    });
  }

  QueryBuilder<UserContentCollection, DateTime, QQueryOperations>
  lastModifiedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastModifiedAt');
    });
  }

  QueryBuilder<UserContentCollection, String?, QQueryOperations>
  lastModifiedByDeviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastModifiedByDeviceId');
    });
  }

  QueryBuilder<UserContentCollection, DateTime?, QQueryOperations>
  lastSyncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncedAt');
    });
  }

  QueryBuilder<UserContentCollection, String?, QQueryOperations>
  ownerUserIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ownerUserId');
    });
  }

  QueryBuilder<UserContentCollection, String, QQueryOperations>
  rawJsonPayloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rawJsonPayload');
    });
  }

  QueryBuilder<UserContentCollection, String, QQueryOperations>
  syncStatusKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatusKey');
    });
  }

  QueryBuilder<UserContentCollection, int, QQueryOperations> versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'version');
    });
  }
}
