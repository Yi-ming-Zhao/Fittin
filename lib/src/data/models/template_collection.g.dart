// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTemplateCollectionCollection on Isar {
  IsarCollection<TemplateCollection> get templateCollections =>
      this.collection();
}

const TemplateCollectionSchema = CollectionSchema(
  name: r'TemplateCollection',
  id: -4094051142176530049,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'deletedAt': PropertySchema(
      id: 1,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'description': PropertySchema(
      id: 2,
      name: r'description',
      type: IsarType.string,
    ),
    r'isBuiltIn': PropertySchema(
      id: 3,
      name: r'isBuiltIn',
      type: IsarType.bool,
    ),
    r'lastModifiedAt': PropertySchema(
      id: 4,
      name: r'lastModifiedAt',
      type: IsarType.dateTime,
    ),
    r'lastModifiedByDeviceId': PropertySchema(
      id: 5,
      name: r'lastModifiedByDeviceId',
      type: IsarType.string,
    ),
    r'lastSyncedAt': PropertySchema(
      id: 6,
      name: r'lastSyncedAt',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(id: 7, name: r'name', type: IsarType.string),
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
    r'sourceTemplateId': PropertySchema(
      id: 10,
      name: r'sourceTemplateId',
      type: IsarType.string,
    ),
    r'syncStatusKey': PropertySchema(
      id: 11,
      name: r'syncStatusKey',
      type: IsarType.string,
    ),
    r'templateId': PropertySchema(
      id: 12,
      name: r'templateId',
      type: IsarType.string,
    ),
    r'version': PropertySchema(id: 13, name: r'version', type: IsarType.long),
  },
  estimateSize: _templateCollectionEstimateSize,
  serialize: _templateCollectionSerialize,
  deserialize: _templateCollectionDeserialize,
  deserializeProp: _templateCollectionDeserializeProp,
  idName: r'id',
  indexes: {
    r'templateId': IndexSchema(
      id: -5352721467389445085,
      name: r'templateId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'templateId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'isBuiltIn': IndexSchema(
      id: 8159970814813350081,
      name: r'isBuiltIn',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isBuiltIn',
          type: IndexType.value,
          caseSensitive: false,
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
  getId: _templateCollectionGetId,
  getLinks: _templateCollectionGetLinks,
  attach: _templateCollectionAttach,
  version: '3.1.0+1',
);

int _templateCollectionEstimateSize(
  TemplateCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.description.length * 3;
  {
    final value = object.lastModifiedByDeviceId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.ownerUserId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.rawJsonPayload.length * 3;
  {
    final value = object.sourceTemplateId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.syncStatusKey.length * 3;
  bytesCount += 3 + object.templateId.length * 3;
  return bytesCount;
}

void _templateCollectionSerialize(
  TemplateCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeDateTime(offsets[1], object.deletedAt);
  writer.writeString(offsets[2], object.description);
  writer.writeBool(offsets[3], object.isBuiltIn);
  writer.writeDateTime(offsets[4], object.lastModifiedAt);
  writer.writeString(offsets[5], object.lastModifiedByDeviceId);
  writer.writeDateTime(offsets[6], object.lastSyncedAt);
  writer.writeString(offsets[7], object.name);
  writer.writeString(offsets[8], object.ownerUserId);
  writer.writeString(offsets[9], object.rawJsonPayload);
  writer.writeString(offsets[10], object.sourceTemplateId);
  writer.writeString(offsets[11], object.syncStatusKey);
  writer.writeString(offsets[12], object.templateId);
  writer.writeLong(offsets[13], object.version);
}

TemplateCollection _templateCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TemplateCollection();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[1]);
  object.description = reader.readString(offsets[2]);
  object.id = id;
  object.isBuiltIn = reader.readBool(offsets[3]);
  object.lastModifiedAt = reader.readDateTime(offsets[4]);
  object.lastModifiedByDeviceId = reader.readStringOrNull(offsets[5]);
  object.lastSyncedAt = reader.readDateTimeOrNull(offsets[6]);
  object.name = reader.readString(offsets[7]);
  object.ownerUserId = reader.readStringOrNull(offsets[8]);
  object.rawJsonPayload = reader.readString(offsets[9]);
  object.sourceTemplateId = reader.readStringOrNull(offsets[10]);
  object.syncStatusKey = reader.readString(offsets[11]);
  object.templateId = reader.readString(offsets[12]);
  object.version = reader.readLong(offsets[13]);
  return object;
}

P _templateCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _templateCollectionGetId(TemplateCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _templateCollectionGetLinks(
  TemplateCollection object,
) {
  return [];
}

void _templateCollectionAttach(
  IsarCollection<dynamic> col,
  Id id,
  TemplateCollection object,
) {
  object.id = id;
}

extension TemplateCollectionByIndex on IsarCollection<TemplateCollection> {
  Future<TemplateCollection?> getByTemplateId(String templateId) {
    return getByIndex(r'templateId', [templateId]);
  }

  TemplateCollection? getByTemplateIdSync(String templateId) {
    return getByIndexSync(r'templateId', [templateId]);
  }

  Future<bool> deleteByTemplateId(String templateId) {
    return deleteByIndex(r'templateId', [templateId]);
  }

  bool deleteByTemplateIdSync(String templateId) {
    return deleteByIndexSync(r'templateId', [templateId]);
  }

  Future<List<TemplateCollection?>> getAllByTemplateId(
    List<String> templateIdValues,
  ) {
    final values = templateIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'templateId', values);
  }

  List<TemplateCollection?> getAllByTemplateIdSync(
    List<String> templateIdValues,
  ) {
    final values = templateIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'templateId', values);
  }

  Future<int> deleteAllByTemplateId(List<String> templateIdValues) {
    final values = templateIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'templateId', values);
  }

  int deleteAllByTemplateIdSync(List<String> templateIdValues) {
    final values = templateIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'templateId', values);
  }

  Future<Id> putByTemplateId(TemplateCollection object) {
    return putByIndex(r'templateId', object);
  }

  Id putByTemplateIdSync(TemplateCollection object, {bool saveLinks = true}) {
    return putByIndexSync(r'templateId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByTemplateId(List<TemplateCollection> objects) {
    return putAllByIndex(r'templateId', objects);
  }

  List<Id> putAllByTemplateIdSync(
    List<TemplateCollection> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'templateId', objects, saveLinks: saveLinks);
  }
}

extension TemplateCollectionQueryWhereSort
    on QueryBuilder<TemplateCollection, TemplateCollection, QWhere> {
  QueryBuilder<TemplateCollection, TemplateCollection, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterWhere>
  anyIsBuiltIn() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isBuiltIn'),
      );
    });
  }
}

extension TemplateCollectionQueryWhere
    on QueryBuilder<TemplateCollection, TemplateCollection, QWhereClause> {
  QueryBuilder<TemplateCollection, TemplateCollection, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterWhereClause>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterWhereClause>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterWhereClause>
  templateIdEqualTo(String templateId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'templateId', value: [templateId]),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterWhereClause>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterWhereClause>
  isBuiltInEqualTo(bool isBuiltIn) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'isBuiltIn', value: [isBuiltIn]),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterWhereClause>
  isBuiltInNotEqualTo(bool isBuiltIn) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isBuiltIn',
                lower: [],
                upper: [isBuiltIn],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isBuiltIn',
                lower: [isBuiltIn],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isBuiltIn',
                lower: [isBuiltIn],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isBuiltIn',
                lower: [],
                upper: [isBuiltIn],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterWhereClause>
  ownerUserIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'ownerUserId', value: [null]),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterWhereClause>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterWhereClause>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterWhereClause>
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

extension TemplateCollectionQueryFilter
    on QueryBuilder<TemplateCollection, TemplateCollection, QFilterCondition> {
  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'deletedAt'),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'deletedAt'),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deletedAt', value: value),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  descriptionEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'description',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  descriptionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  descriptionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'description',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  isBuiltInEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isBuiltIn', value: value),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  lastModifiedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastModifiedAt', value: value),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  lastModifiedByDeviceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastModifiedByDeviceId'),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  lastModifiedByDeviceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastModifiedByDeviceId'),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  lastModifiedByDeviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastModifiedByDeviceId', value: ''),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  lastSyncedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastSyncedAt'),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  lastSyncedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastSyncedAt'),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  lastSyncedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastSyncedAt', value: value),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  nameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  nameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  nameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  ownerUserIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'ownerUserId'),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  ownerUserIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'ownerUserId'),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  ownerUserIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ownerUserId', value: ''),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  ownerUserIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'ownerUserId', value: ''),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  rawJsonPayloadIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'rawJsonPayload', value: ''),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  rawJsonPayloadIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'rawJsonPayload', value: ''),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  sourceTemplateIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'sourceTemplateId'),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  sourceTemplateIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'sourceTemplateId'),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  sourceTemplateIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sourceTemplateId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  sourceTemplateIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sourceTemplateId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  sourceTemplateIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sourceTemplateId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  sourceTemplateIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sourceTemplateId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  sourceTemplateIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sourceTemplateId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  sourceTemplateIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sourceTemplateId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  sourceTemplateIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sourceTemplateId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  sourceTemplateIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sourceTemplateId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  sourceTemplateIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sourceTemplateId', value: ''),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  sourceTemplateIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sourceTemplateId', value: ''),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  syncStatusKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncStatusKey', value: ''),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  syncStatusKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'syncStatusKey', value: ''),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  templateIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'templateId', value: ''),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  templateIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'templateId', value: ''),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
  versionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'version', value: value),
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
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

extension TemplateCollectionQueryObject
    on QueryBuilder<TemplateCollection, TemplateCollection, QFilterCondition> {}

extension TemplateCollectionQueryLinks
    on QueryBuilder<TemplateCollection, TemplateCollection, QFilterCondition> {}

extension TemplateCollectionQuerySortBy
    on QueryBuilder<TemplateCollection, TemplateCollection, QSortBy> {
  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  sortByIsBuiltIn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBuiltIn', Sort.asc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  sortByIsBuiltInDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBuiltIn', Sort.desc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  sortByLastModifiedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedAt', Sort.asc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  sortByLastModifiedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedAt', Sort.desc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  sortByLastModifiedByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedByDeviceId', Sort.asc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  sortByLastModifiedByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedByDeviceId', Sort.desc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  sortByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  sortByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  sortByOwnerUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.asc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  sortByOwnerUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.desc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  sortByRawJsonPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJsonPayload', Sort.asc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  sortByRawJsonPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJsonPayload', Sort.desc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  sortBySourceTemplateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceTemplateId', Sort.asc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  sortBySourceTemplateIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceTemplateId', Sort.desc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  sortBySyncStatusKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatusKey', Sort.asc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  sortBySyncStatusKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatusKey', Sort.desc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  sortByTemplateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateId', Sort.asc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  sortByTemplateIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateId', Sort.desc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  sortByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  sortByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension TemplateCollectionQuerySortThenBy
    on QueryBuilder<TemplateCollection, TemplateCollection, QSortThenBy> {
  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  thenByIsBuiltIn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBuiltIn', Sort.asc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  thenByIsBuiltInDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBuiltIn', Sort.desc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  thenByLastModifiedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedAt', Sort.asc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  thenByLastModifiedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedAt', Sort.desc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  thenByLastModifiedByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedByDeviceId', Sort.asc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  thenByLastModifiedByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedByDeviceId', Sort.desc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  thenByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  thenByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  thenByOwnerUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.asc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  thenByOwnerUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.desc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  thenByRawJsonPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJsonPayload', Sort.asc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  thenByRawJsonPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJsonPayload', Sort.desc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  thenBySourceTemplateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceTemplateId', Sort.asc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  thenBySourceTemplateIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceTemplateId', Sort.desc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  thenBySyncStatusKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatusKey', Sort.asc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  thenBySyncStatusKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatusKey', Sort.desc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  thenByTemplateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateId', Sort.asc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  thenByTemplateIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateId', Sort.desc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  thenByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterSortBy>
  thenByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension TemplateCollectionQueryWhereDistinct
    on QueryBuilder<TemplateCollection, TemplateCollection, QDistinct> {
  QueryBuilder<TemplateCollection, TemplateCollection, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QDistinct>
  distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QDistinct>
  distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QDistinct>
  distinctByIsBuiltIn() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isBuiltIn');
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QDistinct>
  distinctByLastModifiedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastModifiedAt');
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QDistinct>
  distinctByLastModifiedByDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'lastModifiedByDeviceId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QDistinct>
  distinctByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncedAt');
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QDistinct>
  distinctByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QDistinct>
  distinctByOwnerUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ownerUserId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QDistinct>
  distinctByRawJsonPayload({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'rawJsonPayload',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QDistinct>
  distinctBySourceTemplateId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'sourceTemplateId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QDistinct>
  distinctBySyncStatusKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'syncStatusKey',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QDistinct>
  distinctByTemplateId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'templateId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QDistinct>
  distinctByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'version');
    });
  }
}

extension TemplateCollectionQueryProperty
    on QueryBuilder<TemplateCollection, TemplateCollection, QQueryProperty> {
  QueryBuilder<TemplateCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TemplateCollection, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<TemplateCollection, DateTime?, QQueryOperations>
  deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<TemplateCollection, String, QQueryOperations>
  descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<TemplateCollection, bool, QQueryOperations> isBuiltInProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isBuiltIn');
    });
  }

  QueryBuilder<TemplateCollection, DateTime, QQueryOperations>
  lastModifiedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastModifiedAt');
    });
  }

  QueryBuilder<TemplateCollection, String?, QQueryOperations>
  lastModifiedByDeviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastModifiedByDeviceId');
    });
  }

  QueryBuilder<TemplateCollection, DateTime?, QQueryOperations>
  lastSyncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncedAt');
    });
  }

  QueryBuilder<TemplateCollection, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<TemplateCollection, String?, QQueryOperations>
  ownerUserIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ownerUserId');
    });
  }

  QueryBuilder<TemplateCollection, String, QQueryOperations>
  rawJsonPayloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rawJsonPayload');
    });
  }

  QueryBuilder<TemplateCollection, String?, QQueryOperations>
  sourceTemplateIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceTemplateId');
    });
  }

  QueryBuilder<TemplateCollection, String, QQueryOperations>
  syncStatusKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatusKey');
    });
  }

  QueryBuilder<TemplateCollection, String, QQueryOperations>
  templateIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'templateId');
    });
  }

  QueryBuilder<TemplateCollection, int, QQueryOperations> versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'version');
    });
  }
}
