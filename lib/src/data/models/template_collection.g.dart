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
    r'description': PropertySchema(
      id: 1,
      name: r'description',
      type: IsarType.string,
    ),
    r'isBuiltIn': PropertySchema(
      id: 2,
      name: r'isBuiltIn',
      type: IsarType.bool,
    ),
    r'lastModifiedAt': PropertySchema(
      id: 3,
      name: r'lastModifiedAt',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(
      id: 4,
      name: r'name',
      type: IsarType.string,
    ),
    r'rawJsonPayload': PropertySchema(
      id: 5,
      name: r'rawJsonPayload',
      type: IsarType.string,
    ),
    r'sourceTemplateId': PropertySchema(
      id: 6,
      name: r'sourceTemplateId',
      type: IsarType.string,
    ),
    r'templateId': PropertySchema(
      id: 7,
      name: r'templateId',
      type: IsarType.string,
    )
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
        )
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
        )
      ],
    )
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
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.rawJsonPayload.length * 3;
  {
    final value = object.sourceTemplateId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
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
  writer.writeString(offsets[1], object.description);
  writer.writeBool(offsets[2], object.isBuiltIn);
  writer.writeDateTime(offsets[3], object.lastModifiedAt);
  writer.writeString(offsets[4], object.name);
  writer.writeString(offsets[5], object.rawJsonPayload);
  writer.writeString(offsets[6], object.sourceTemplateId);
  writer.writeString(offsets[7], object.templateId);
}

TemplateCollection _templateCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TemplateCollection();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.description = reader.readString(offsets[1]);
  object.id = id;
  object.isBuiltIn = reader.readBool(offsets[2]);
  object.lastModifiedAt = reader.readDateTime(offsets[3]);
  object.name = reader.readString(offsets[4]);
  object.rawJsonPayload = reader.readString(offsets[5]);
  object.sourceTemplateId = reader.readStringOrNull(offsets[6]);
  object.templateId = reader.readString(offsets[7]);
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
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _templateCollectionGetId(TemplateCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _templateCollectionGetLinks(
    TemplateCollection object) {
  return [];
}

void _templateCollectionAttach(
    IsarCollection<dynamic> col, Id id, TemplateCollection object) {
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
      List<String> templateIdValues) {
    final values = templateIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'templateId', values);
  }

  List<TemplateCollection?> getAllByTemplateIdSync(
      List<String> templateIdValues) {
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

  List<Id> putAllByTemplateIdSync(List<TemplateCollection> objects,
      {bool saveLinks = true}) {
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
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
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
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterWhereClause>
      templateIdEqualTo(String templateId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'templateId',
        value: [templateId],
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterWhereClause>
      templateIdNotEqualTo(String templateId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'templateId',
              lower: [],
              upper: [templateId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'templateId',
              lower: [templateId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'templateId',
              lower: [templateId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'templateId',
              lower: [],
              upper: [templateId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterWhereClause>
      isBuiltInEqualTo(bool isBuiltIn) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isBuiltIn',
        value: [isBuiltIn],
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterWhereClause>
      isBuiltInNotEqualTo(bool isBuiltIn) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isBuiltIn',
              lower: [],
              upper: [isBuiltIn],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isBuiltIn',
              lower: [isBuiltIn],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isBuiltIn',
              lower: [isBuiltIn],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isBuiltIn',
              lower: [],
              upper: [isBuiltIn],
              includeUpper: false,
            ));
      }
    });
  }
}

extension TemplateCollectionQueryFilter
    on QueryBuilder<TemplateCollection, TemplateCollection, QFilterCondition> {
  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
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
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
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
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
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
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      isBuiltInEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isBuiltIn',
        value: value,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      lastModifiedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastModifiedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      lastModifiedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastModifiedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      lastModifiedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastModifiedAt',
        value: value,
      ));
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
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastModifiedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
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
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      rawJsonPayloadEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rawJsonPayload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      rawJsonPayloadGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rawJsonPayload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      rawJsonPayloadLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rawJsonPayload',
        value: value,
        caseSensitive: caseSensitive,
      ));
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
      return query.addFilterCondition(FilterCondition.between(
        property: r'rawJsonPayload',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      rawJsonPayloadStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rawJsonPayload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      rawJsonPayloadEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rawJsonPayload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      rawJsonPayloadContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rawJsonPayload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      rawJsonPayloadMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rawJsonPayload',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      rawJsonPayloadIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rawJsonPayload',
        value: '',
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      rawJsonPayloadIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rawJsonPayload',
        value: '',
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      sourceTemplateIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sourceTemplateId',
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      sourceTemplateIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sourceTemplateId',
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      sourceTemplateIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceTemplateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      sourceTemplateIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceTemplateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      sourceTemplateIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceTemplateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
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
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceTemplateId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      sourceTemplateIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceTemplateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      sourceTemplateIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceTemplateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      sourceTemplateIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceTemplateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      sourceTemplateIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceTemplateId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      sourceTemplateIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceTemplateId',
        value: '',
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      sourceTemplateIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceTemplateId',
        value: '',
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      templateIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'templateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      templateIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'templateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      templateIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'templateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
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
      return query.addFilterCondition(FilterCondition.between(
        property: r'templateId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      templateIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'templateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      templateIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'templateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      templateIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'templateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      templateIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'templateId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      templateIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'templateId',
        value: '',
      ));
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QAfterFilterCondition>
      templateIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'templateId',
        value: '',
      ));
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
      distinctByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QDistinct>
      distinctByRawJsonPayload({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rawJsonPayload',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QDistinct>
      distinctBySourceTemplateId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceTemplateId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TemplateCollection, TemplateCollection, QDistinct>
      distinctByTemplateId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'templateId', caseSensitive: caseSensitive);
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

  QueryBuilder<TemplateCollection, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
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
      templateIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'templateId');
    });
  }
}
