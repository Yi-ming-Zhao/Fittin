// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppStateCollectionCollection on Isar {
  IsarCollection<AppStateCollection> get appStateCollections =>
      this.collection();
}

const AppStateCollectionSchema = CollectionSchema(
  name: r'AppStateCollection',
  id: 7585267032018409075,
  properties: {
    r'activeInstanceId': PropertySchema(
      id: 0,
      name: r'activeInstanceId',
      type: IsarType.string,
    ),
    r'analyticsFormulaKey': PropertySchema(
      id: 1,
      name: r'analyticsFormulaKey',
      type: IsarType.string,
    ),
    r'glassOpacity': PropertySchema(
      id: 2,
      name: r'glassOpacity',
      type: IsarType.double,
    ),
    r'localeCode': PropertySchema(
      id: 3,
      name: r'localeCode',
      type: IsarType.string,
    ),
    r'stateKey': PropertySchema(
      id: 4,
      name: r'stateKey',
      type: IsarType.string,
    ),
    r'stringValue': PropertySchema(
      id: 5,
      name: r'stringValue',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 6,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },
  estimateSize: _appStateCollectionEstimateSize,
  serialize: _appStateCollectionSerialize,
  deserialize: _appStateCollectionDeserialize,
  deserializeProp: _appStateCollectionDeserializeProp,
  idName: r'id',
  indexes: {
    r'stateKey': IndexSchema(
      id: 535423888346486579,
      name: r'stateKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'stateKey',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _appStateCollectionGetId,
  getLinks: _appStateCollectionGetLinks,
  attach: _appStateCollectionAttach,
  version: '3.1.0+1',
);

int _appStateCollectionEstimateSize(
  AppStateCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.activeInstanceId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.analyticsFormulaKey;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.localeCode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.stateKey.length * 3;
  {
    final value = object.stringValue;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _appStateCollectionSerialize(
  AppStateCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.activeInstanceId);
  writer.writeString(offsets[1], object.analyticsFormulaKey);
  writer.writeDouble(offsets[2], object.glassOpacity);
  writer.writeString(offsets[3], object.localeCode);
  writer.writeString(offsets[4], object.stateKey);
  writer.writeString(offsets[5], object.stringValue);
  writer.writeDateTime(offsets[6], object.updatedAt);
}

AppStateCollection _appStateCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppStateCollection();
  object.activeInstanceId = reader.readStringOrNull(offsets[0]);
  object.analyticsFormulaKey = reader.readStringOrNull(offsets[1]);
  object.glassOpacity = reader.readDoubleOrNull(offsets[2]);
  object.id = id;
  object.localeCode = reader.readStringOrNull(offsets[3]);
  object.stateKey = reader.readString(offsets[4]);
  object.stringValue = reader.readStringOrNull(offsets[5]);
  object.updatedAt = reader.readDateTime(offsets[6]);
  return object;
}

P _appStateCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDoubleOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _appStateCollectionGetId(AppStateCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _appStateCollectionGetLinks(
  AppStateCollection object,
) {
  return [];
}

void _appStateCollectionAttach(
  IsarCollection<dynamic> col,
  Id id,
  AppStateCollection object,
) {
  object.id = id;
}

extension AppStateCollectionByIndex on IsarCollection<AppStateCollection> {
  Future<AppStateCollection?> getByStateKey(String stateKey) {
    return getByIndex(r'stateKey', [stateKey]);
  }

  AppStateCollection? getByStateKeySync(String stateKey) {
    return getByIndexSync(r'stateKey', [stateKey]);
  }

  Future<bool> deleteByStateKey(String stateKey) {
    return deleteByIndex(r'stateKey', [stateKey]);
  }

  bool deleteByStateKeySync(String stateKey) {
    return deleteByIndexSync(r'stateKey', [stateKey]);
  }

  Future<List<AppStateCollection?>> getAllByStateKey(
    List<String> stateKeyValues,
  ) {
    final values = stateKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'stateKey', values);
  }

  List<AppStateCollection?> getAllByStateKeySync(List<String> stateKeyValues) {
    final values = stateKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'stateKey', values);
  }

  Future<int> deleteAllByStateKey(List<String> stateKeyValues) {
    final values = stateKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'stateKey', values);
  }

  int deleteAllByStateKeySync(List<String> stateKeyValues) {
    final values = stateKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'stateKey', values);
  }

  Future<Id> putByStateKey(AppStateCollection object) {
    return putByIndex(r'stateKey', object);
  }

  Id putByStateKeySync(AppStateCollection object, {bool saveLinks = true}) {
    return putByIndexSync(r'stateKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByStateKey(List<AppStateCollection> objects) {
    return putAllByIndex(r'stateKey', objects);
  }

  List<Id> putAllByStateKeySync(
    List<AppStateCollection> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'stateKey', objects, saveLinks: saveLinks);
  }
}

extension AppStateCollectionQueryWhereSort
    on QueryBuilder<AppStateCollection, AppStateCollection, QWhere> {
  QueryBuilder<AppStateCollection, AppStateCollection, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppStateCollectionQueryWhere
    on QueryBuilder<AppStateCollection, AppStateCollection, QWhereClause> {
  QueryBuilder<AppStateCollection, AppStateCollection, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterWhereClause>
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

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterWhereClause>
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

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterWhereClause>
  stateKeyEqualTo(String stateKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'stateKey', value: [stateKey]),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterWhereClause>
  stateKeyNotEqualTo(String stateKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stateKey',
                lower: [],
                upper: [stateKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stateKey',
                lower: [stateKey],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stateKey',
                lower: [stateKey],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stateKey',
                lower: [],
                upper: [stateKey],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension AppStateCollectionQueryFilter
    on QueryBuilder<AppStateCollection, AppStateCollection, QFilterCondition> {
  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  activeInstanceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'activeInstanceId'),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  activeInstanceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'activeInstanceId'),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  activeInstanceIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'activeInstanceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  activeInstanceIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'activeInstanceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  activeInstanceIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'activeInstanceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  activeInstanceIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'activeInstanceId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  activeInstanceIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'activeInstanceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  activeInstanceIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'activeInstanceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  activeInstanceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'activeInstanceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  activeInstanceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'activeInstanceId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  activeInstanceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'activeInstanceId', value: ''),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  activeInstanceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'activeInstanceId', value: ''),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  analyticsFormulaKeyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'analyticsFormulaKey'),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  analyticsFormulaKeyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'analyticsFormulaKey'),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  analyticsFormulaKeyEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'analyticsFormulaKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  analyticsFormulaKeyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'analyticsFormulaKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  analyticsFormulaKeyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'analyticsFormulaKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  analyticsFormulaKeyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'analyticsFormulaKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  analyticsFormulaKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'analyticsFormulaKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  analyticsFormulaKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'analyticsFormulaKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  analyticsFormulaKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'analyticsFormulaKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  analyticsFormulaKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'analyticsFormulaKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  analyticsFormulaKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'analyticsFormulaKey', value: ''),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  analyticsFormulaKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'analyticsFormulaKey',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  glassOpacityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'glassOpacity'),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  glassOpacityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'glassOpacity'),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  glassOpacityEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'glassOpacity',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  glassOpacityGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'glassOpacity',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  glassOpacityLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'glassOpacity',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  glassOpacityBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'glassOpacity',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
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

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
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

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
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

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  localeCodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'localeCode'),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  localeCodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'localeCode'),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  localeCodeEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'localeCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  localeCodeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'localeCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  localeCodeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'localeCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  localeCodeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'localeCode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  localeCodeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'localeCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  localeCodeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'localeCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  localeCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'localeCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  localeCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'localeCode',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  localeCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'localeCode', value: ''),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  localeCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'localeCode', value: ''),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  stateKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'stateKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  stateKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'stateKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  stateKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'stateKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  stateKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'stateKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  stateKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'stateKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  stateKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'stateKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  stateKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'stateKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  stateKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'stateKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  stateKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'stateKey', value: ''),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  stateKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'stateKey', value: ''),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  stringValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'stringValue'),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  stringValueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'stringValue'),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  stringValueEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'stringValue',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  stringValueGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'stringValue',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  stringValueLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'stringValue',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  stringValueBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'stringValue',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  stringValueStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'stringValue',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  stringValueEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'stringValue',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  stringValueContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'stringValue',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  stringValueMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'stringValue',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  stringValueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'stringValue', value: ''),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  stringValueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'stringValue', value: ''),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
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

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
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

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterFilterCondition>
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

extension AppStateCollectionQueryObject
    on QueryBuilder<AppStateCollection, AppStateCollection, QFilterCondition> {}

extension AppStateCollectionQueryLinks
    on QueryBuilder<AppStateCollection, AppStateCollection, QFilterCondition> {}

extension AppStateCollectionQuerySortBy
    on QueryBuilder<AppStateCollection, AppStateCollection, QSortBy> {
  QueryBuilder<AppStateCollection, AppStateCollection, QAfterSortBy>
  sortByActiveInstanceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeInstanceId', Sort.asc);
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterSortBy>
  sortByActiveInstanceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeInstanceId', Sort.desc);
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterSortBy>
  sortByAnalyticsFormulaKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'analyticsFormulaKey', Sort.asc);
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterSortBy>
  sortByAnalyticsFormulaKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'analyticsFormulaKey', Sort.desc);
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterSortBy>
  sortByGlassOpacity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'glassOpacity', Sort.asc);
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterSortBy>
  sortByGlassOpacityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'glassOpacity', Sort.desc);
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterSortBy>
  sortByLocaleCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localeCode', Sort.asc);
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterSortBy>
  sortByLocaleCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localeCode', Sort.desc);
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterSortBy>
  sortByStateKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateKey', Sort.asc);
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterSortBy>
  sortByStateKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateKey', Sort.desc);
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterSortBy>
  sortByStringValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringValue', Sort.asc);
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterSortBy>
  sortByStringValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringValue', Sort.desc);
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AppStateCollectionQuerySortThenBy
    on QueryBuilder<AppStateCollection, AppStateCollection, QSortThenBy> {
  QueryBuilder<AppStateCollection, AppStateCollection, QAfterSortBy>
  thenByActiveInstanceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeInstanceId', Sort.asc);
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterSortBy>
  thenByActiveInstanceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeInstanceId', Sort.desc);
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterSortBy>
  thenByAnalyticsFormulaKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'analyticsFormulaKey', Sort.asc);
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterSortBy>
  thenByAnalyticsFormulaKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'analyticsFormulaKey', Sort.desc);
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterSortBy>
  thenByGlassOpacity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'glassOpacity', Sort.asc);
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterSortBy>
  thenByGlassOpacityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'glassOpacity', Sort.desc);
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterSortBy>
  thenByLocaleCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localeCode', Sort.asc);
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterSortBy>
  thenByLocaleCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localeCode', Sort.desc);
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterSortBy>
  thenByStateKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateKey', Sort.asc);
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterSortBy>
  thenByStateKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateKey', Sort.desc);
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterSortBy>
  thenByStringValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringValue', Sort.asc);
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterSortBy>
  thenByStringValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringValue', Sort.desc);
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AppStateCollectionQueryWhereDistinct
    on QueryBuilder<AppStateCollection, AppStateCollection, QDistinct> {
  QueryBuilder<AppStateCollection, AppStateCollection, QDistinct>
  distinctByActiveInstanceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'activeInstanceId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QDistinct>
  distinctByAnalyticsFormulaKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'analyticsFormulaKey',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QDistinct>
  distinctByGlassOpacity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'glassOpacity');
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QDistinct>
  distinctByLocaleCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localeCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QDistinct>
  distinctByStateKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stateKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QDistinct>
  distinctByStringValue({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stringValue', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppStateCollection, AppStateCollection, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension AppStateCollectionQueryProperty
    on QueryBuilder<AppStateCollection, AppStateCollection, QQueryProperty> {
  QueryBuilder<AppStateCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AppStateCollection, String?, QQueryOperations>
  activeInstanceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activeInstanceId');
    });
  }

  QueryBuilder<AppStateCollection, String?, QQueryOperations>
  analyticsFormulaKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'analyticsFormulaKey');
    });
  }

  QueryBuilder<AppStateCollection, double?, QQueryOperations>
  glassOpacityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'glassOpacity');
    });
  }

  QueryBuilder<AppStateCollection, String?, QQueryOperations>
  localeCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localeCode');
    });
  }

  QueryBuilder<AppStateCollection, String, QQueryOperations>
  stateKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stateKey');
    });
  }

  QueryBuilder<AppStateCollection, String?, QQueryOperations>
  stringValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stringValue');
    });
  }

  QueryBuilder<AppStateCollection, DateTime, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
