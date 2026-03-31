// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_log_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWorkoutLogCollectionCollection on Isar {
  IsarCollection<WorkoutLogCollection> get workoutLogCollections =>
      this.collection();
}

const WorkoutLogCollectionSchema = CollectionSchema(
  name: r'WorkoutLogCollection',
  id: 5061488129319444685,
  properties: {
    r'completedAt': PropertySchema(
      id: 0,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'deletedAt': PropertySchema(
      id: 1,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'instanceId': PropertySchema(
      id: 2,
      name: r'instanceId',
      type: IsarType.string,
    ),
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
    r'logId': PropertySchema(id: 5, name: r'logId', type: IsarType.string),
    r'ownerUserId': PropertySchema(
      id: 6,
      name: r'ownerUserId',
      type: IsarType.string,
    ),
    r'rawJsonPayload': PropertySchema(
      id: 7,
      name: r'rawJsonPayload',
      type: IsarType.string,
    ),
    r'syncStatusKey': PropertySchema(
      id: 8,
      name: r'syncStatusKey',
      type: IsarType.string,
    ),
    r'version': PropertySchema(id: 9, name: r'version', type: IsarType.long),
    r'workoutId': PropertySchema(
      id: 10,
      name: r'workoutId',
      type: IsarType.string,
    ),
    r'workoutName': PropertySchema(
      id: 11,
      name: r'workoutName',
      type: IsarType.string,
    ),
  },
  estimateSize: _workoutLogCollectionEstimateSize,
  serialize: _workoutLogCollectionSerialize,
  deserialize: _workoutLogCollectionDeserialize,
  deserializeProp: _workoutLogCollectionDeserializeProp,
  idName: r'id',
  indexes: {
    r'logId': IndexSchema(
      id: 3089637606214822530,
      name: r'logId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'logId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'instanceId': IndexSchema(
      id: -6720444513014720235,
      name: r'instanceId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'instanceId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'workoutId': IndexSchema(
      id: -2481575602404730374,
      name: r'workoutId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'workoutId',
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
    r'completedAt': IndexSchema(
      id: -3156591011457686752,
      name: r'completedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'completedAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _workoutLogCollectionGetId,
  getLinks: _workoutLogCollectionGetLinks,
  attach: _workoutLogCollectionAttach,
  version: '3.1.0+1',
);

int _workoutLogCollectionEstimateSize(
  WorkoutLogCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.instanceId.length * 3;
  {
    final value = object.lastModifiedByDeviceId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.logId.length * 3;
  {
    final value = object.ownerUserId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.rawJsonPayload.length * 3;
  bytesCount += 3 + object.syncStatusKey.length * 3;
  bytesCount += 3 + object.workoutId.length * 3;
  bytesCount += 3 + object.workoutName.length * 3;
  return bytesCount;
}

void _workoutLogCollectionSerialize(
  WorkoutLogCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.completedAt);
  writer.writeDateTime(offsets[1], object.deletedAt);
  writer.writeString(offsets[2], object.instanceId);
  writer.writeString(offsets[3], object.lastModifiedByDeviceId);
  writer.writeDateTime(offsets[4], object.lastSyncedAt);
  writer.writeString(offsets[5], object.logId);
  writer.writeString(offsets[6], object.ownerUserId);
  writer.writeString(offsets[7], object.rawJsonPayload);
  writer.writeString(offsets[8], object.syncStatusKey);
  writer.writeLong(offsets[9], object.version);
  writer.writeString(offsets[10], object.workoutId);
  writer.writeString(offsets[11], object.workoutName);
}

WorkoutLogCollection _workoutLogCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WorkoutLogCollection();
  object.completedAt = reader.readDateTime(offsets[0]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[1]);
  object.id = id;
  object.instanceId = reader.readString(offsets[2]);
  object.lastModifiedByDeviceId = reader.readStringOrNull(offsets[3]);
  object.lastSyncedAt = reader.readDateTimeOrNull(offsets[4]);
  object.logId = reader.readString(offsets[5]);
  object.ownerUserId = reader.readStringOrNull(offsets[6]);
  object.rawJsonPayload = reader.readString(offsets[7]);
  object.syncStatusKey = reader.readString(offsets[8]);
  object.version = reader.readLong(offsets[9]);
  object.workoutId = reader.readString(offsets[10]);
  object.workoutName = reader.readString(offsets[11]);
  return object;
}

P _workoutLogCollectionDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _workoutLogCollectionGetId(WorkoutLogCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _workoutLogCollectionGetLinks(
  WorkoutLogCollection object,
) {
  return [];
}

void _workoutLogCollectionAttach(
  IsarCollection<dynamic> col,
  Id id,
  WorkoutLogCollection object,
) {
  object.id = id;
}

extension WorkoutLogCollectionByIndex on IsarCollection<WorkoutLogCollection> {
  Future<WorkoutLogCollection?> getByLogId(String logId) {
    return getByIndex(r'logId', [logId]);
  }

  WorkoutLogCollection? getByLogIdSync(String logId) {
    return getByIndexSync(r'logId', [logId]);
  }

  Future<bool> deleteByLogId(String logId) {
    return deleteByIndex(r'logId', [logId]);
  }

  bool deleteByLogIdSync(String logId) {
    return deleteByIndexSync(r'logId', [logId]);
  }

  Future<List<WorkoutLogCollection?>> getAllByLogId(List<String> logIdValues) {
    final values = logIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'logId', values);
  }

  List<WorkoutLogCollection?> getAllByLogIdSync(List<String> logIdValues) {
    final values = logIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'logId', values);
  }

  Future<int> deleteAllByLogId(List<String> logIdValues) {
    final values = logIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'logId', values);
  }

  int deleteAllByLogIdSync(List<String> logIdValues) {
    final values = logIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'logId', values);
  }

  Future<Id> putByLogId(WorkoutLogCollection object) {
    return putByIndex(r'logId', object);
  }

  Id putByLogIdSync(WorkoutLogCollection object, {bool saveLinks = true}) {
    return putByIndexSync(r'logId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByLogId(List<WorkoutLogCollection> objects) {
    return putAllByIndex(r'logId', objects);
  }

  List<Id> putAllByLogIdSync(
    List<WorkoutLogCollection> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'logId', objects, saveLinks: saveLinks);
  }
}

extension WorkoutLogCollectionQueryWhereSort
    on QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QWhere> {
  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterWhere>
  anyCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'completedAt'),
      );
    });
  }
}

extension WorkoutLogCollectionQueryWhere
    on QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QWhereClause> {
  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterWhereClause>
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

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterWhereClause>
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

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterWhereClause>
  logIdEqualTo(String logId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'logId', value: [logId]),
      );
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterWhereClause>
  logIdNotEqualTo(String logId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'logId',
                lower: [],
                upper: [logId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'logId',
                lower: [logId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'logId',
                lower: [logId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'logId',
                lower: [],
                upper: [logId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterWhereClause>
  instanceIdEqualTo(String instanceId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'instanceId', value: [instanceId]),
      );
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterWhereClause>
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

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterWhereClause>
  workoutIdEqualTo(String workoutId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'workoutId', value: [workoutId]),
      );
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterWhereClause>
  workoutIdNotEqualTo(String workoutId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'workoutId',
                lower: [],
                upper: [workoutId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'workoutId',
                lower: [workoutId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'workoutId',
                lower: [workoutId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'workoutId',
                lower: [],
                upper: [workoutId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterWhereClause>
  ownerUserIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'ownerUserId', value: [null]),
      );
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterWhereClause>
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

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterWhereClause>
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

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterWhereClause>
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

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterWhereClause>
  completedAtEqualTo(DateTime completedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'completedAt',
          value: [completedAt],
        ),
      );
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterWhereClause>
  completedAtNotEqualTo(DateTime completedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'completedAt',
                lower: [],
                upper: [completedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'completedAt',
                lower: [completedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'completedAt',
                lower: [completedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'completedAt',
                lower: [],
                upper: [completedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterWhereClause>
  completedAtGreaterThan(DateTime completedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'completedAt',
          lower: [completedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterWhereClause>
  completedAtLessThan(DateTime completedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'completedAt',
          lower: [],
          upper: [completedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterWhereClause>
  completedAtBetween(
    DateTime lowerCompletedAt,
    DateTime upperCompletedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'completedAt',
          lower: [lowerCompletedAt],
          includeLower: includeLower,
          upper: [upperCompletedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension WorkoutLogCollectionQueryFilter
    on
        QueryBuilder<
          WorkoutLogCollection,
          WorkoutLogCollection,
          QFilterCondition
        > {
  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  completedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'completedAt', value: value),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  completedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'completedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  completedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'completedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  completedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'completedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  instanceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'instanceId', value: ''),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  instanceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'instanceId', value: ''),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  logIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'logId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  logIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'logId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  logIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'logId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  logIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'logId',
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
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  logIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'logId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  logIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'logId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  logIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'logId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  logIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'logId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  logIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'logId', value: ''),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  logIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'logId', value: ''),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
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
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  workoutIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'workoutId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  workoutIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'workoutId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  workoutIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'workoutId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  workoutIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'workoutId',
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
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  workoutIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'workoutId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  workoutIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'workoutId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  workoutIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'workoutId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  workoutIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'workoutId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  workoutIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'workoutId', value: ''),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  workoutIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'workoutId', value: ''),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  workoutNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'workoutName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  workoutNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'workoutName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  workoutNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'workoutName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  workoutNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'workoutName',
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
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  workoutNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'workoutName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  workoutNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'workoutName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  workoutNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'workoutName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  workoutNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'workoutName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  workoutNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'workoutName', value: ''),
      );
    });
  }

  QueryBuilder<
    WorkoutLogCollection,
    WorkoutLogCollection,
    QAfterFilterCondition
  >
  workoutNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'workoutName', value: ''),
      );
    });
  }
}

extension WorkoutLogCollectionQueryObject
    on
        QueryBuilder<
          WorkoutLogCollection,
          WorkoutLogCollection,
          QFilterCondition
        > {}

extension WorkoutLogCollectionQueryLinks
    on
        QueryBuilder<
          WorkoutLogCollection,
          WorkoutLogCollection,
          QFilterCondition
        > {}

extension WorkoutLogCollectionQuerySortBy
    on QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QSortBy> {
  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  sortByInstanceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'instanceId', Sort.asc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  sortByInstanceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'instanceId', Sort.desc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  sortByLastModifiedByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedByDeviceId', Sort.asc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  sortByLastModifiedByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedByDeviceId', Sort.desc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  sortByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  sortByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  sortByLogId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logId', Sort.asc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  sortByLogIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logId', Sort.desc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  sortByOwnerUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.asc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  sortByOwnerUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.desc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  sortByRawJsonPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJsonPayload', Sort.asc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  sortByRawJsonPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJsonPayload', Sort.desc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  sortBySyncStatusKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatusKey', Sort.asc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  sortBySyncStatusKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatusKey', Sort.desc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  sortByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  sortByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  sortByWorkoutId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workoutId', Sort.asc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  sortByWorkoutIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workoutId', Sort.desc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  sortByWorkoutName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workoutName', Sort.asc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  sortByWorkoutNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workoutName', Sort.desc);
    });
  }
}

extension WorkoutLogCollectionQuerySortThenBy
    on QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QSortThenBy> {
  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  thenByInstanceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'instanceId', Sort.asc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  thenByInstanceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'instanceId', Sort.desc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  thenByLastModifiedByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedByDeviceId', Sort.asc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  thenByLastModifiedByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedByDeviceId', Sort.desc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  thenByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  thenByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  thenByLogId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logId', Sort.asc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  thenByLogIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logId', Sort.desc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  thenByOwnerUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.asc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  thenByOwnerUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUserId', Sort.desc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  thenByRawJsonPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJsonPayload', Sort.asc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  thenByRawJsonPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJsonPayload', Sort.desc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  thenBySyncStatusKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatusKey', Sort.asc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  thenBySyncStatusKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatusKey', Sort.desc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  thenByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  thenByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  thenByWorkoutId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workoutId', Sort.asc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  thenByWorkoutIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workoutId', Sort.desc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  thenByWorkoutName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workoutName', Sort.asc);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QAfterSortBy>
  thenByWorkoutNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workoutName', Sort.desc);
    });
  }
}

extension WorkoutLogCollectionQueryWhereDistinct
    on QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QDistinct> {
  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QDistinct>
  distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt');
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QDistinct>
  distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QDistinct>
  distinctByInstanceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'instanceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QDistinct>
  distinctByLastModifiedByDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'lastModifiedByDeviceId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QDistinct>
  distinctByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncedAt');
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QDistinct>
  distinctByLogId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'logId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QDistinct>
  distinctByOwnerUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ownerUserId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QDistinct>
  distinctByRawJsonPayload({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'rawJsonPayload',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QDistinct>
  distinctBySyncStatusKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'syncStatusKey',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QDistinct>
  distinctByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'version');
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QDistinct>
  distinctByWorkoutId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'workoutId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkoutLogCollection, WorkoutLogCollection, QDistinct>
  distinctByWorkoutName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'workoutName', caseSensitive: caseSensitive);
    });
  }
}

extension WorkoutLogCollectionQueryProperty
    on
        QueryBuilder<
          WorkoutLogCollection,
          WorkoutLogCollection,
          QQueryProperty
        > {
  QueryBuilder<WorkoutLogCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WorkoutLogCollection, DateTime, QQueryOperations>
  completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
    });
  }

  QueryBuilder<WorkoutLogCollection, DateTime?, QQueryOperations>
  deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<WorkoutLogCollection, String, QQueryOperations>
  instanceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'instanceId');
    });
  }

  QueryBuilder<WorkoutLogCollection, String?, QQueryOperations>
  lastModifiedByDeviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastModifiedByDeviceId');
    });
  }

  QueryBuilder<WorkoutLogCollection, DateTime?, QQueryOperations>
  lastSyncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncedAt');
    });
  }

  QueryBuilder<WorkoutLogCollection, String, QQueryOperations> logIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'logId');
    });
  }

  QueryBuilder<WorkoutLogCollection, String?, QQueryOperations>
  ownerUserIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ownerUserId');
    });
  }

  QueryBuilder<WorkoutLogCollection, String, QQueryOperations>
  rawJsonPayloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rawJsonPayload');
    });
  }

  QueryBuilder<WorkoutLogCollection, String, QQueryOperations>
  syncStatusKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatusKey');
    });
  }

  QueryBuilder<WorkoutLogCollection, int, QQueryOperations> versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'version');
    });
  }

  QueryBuilder<WorkoutLogCollection, String, QQueryOperations>
  workoutIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'workoutId');
    });
  }

  QueryBuilder<WorkoutLogCollection, String, QQueryOperations>
  workoutNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'workoutName');
    });
  }
}
