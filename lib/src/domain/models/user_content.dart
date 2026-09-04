import 'package:fittin_v2/src/data/sync/sync_models.dart';

enum UserContentKind {
  customExercise,
  cardioActivity,
  cardioRecord,
  cardioImportFingerprint,
  customThemePalette,
}

class UserContentDocument {
  UserContentDocument({
    required this.id,
    required this.kind,
    required Map<String, dynamic> payload,
    this.ownerUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.version = 1,
    this.syncStatus = SyncStatusKeys.localOnly,
    this.lastSyncedAt,
    this.lastModifiedByDeviceId,
  }) : payload = Map.unmodifiable(payload),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final UserContentKind kind;
  final Map<String, dynamic> payload;
  final String? ownerUserId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String syncStatus;
  final DateTime? lastSyncedAt;
  final String? lastModifiedByDeviceId;

  bool get isDeleted => deletedAt != null;

  UserContentDocument copyWith({
    String? id,
    UserContentKind? kind,
    Map<String, dynamic>? payload,
    String? ownerUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
    int? version,
    String? syncStatus,
    DateTime? lastSyncedAt,
    String? lastModifiedByDeviceId,
  }) => UserContentDocument(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    payload: payload ?? this.payload,
    ownerUserId: ownerUserId ?? this.ownerUserId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
    version: version ?? this.version,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    lastModifiedByDeviceId:
        lastModifiedByDeviceId ?? this.lastModifiedByDeviceId,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind.name,
    'payload': payload,
    'ownerUserId': ownerUserId,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'deletedAt': deletedAt?.toUtc().toIso8601String(),
    'version': version,
    'syncStatus': syncStatus,
    'lastSyncedAt': lastSyncedAt?.toUtc().toIso8601String(),
    'lastModifiedByDeviceId': lastModifiedByDeviceId,
  };

  factory UserContentDocument.fromJson(Map<String, dynamic> json) =>
      UserContentDocument(
        id: json['id'] as String,
        kind: UserContentKind.values.byName(json['kind'] as String),
        payload: (json['payload'] as Map).cast<String, dynamic>(),
        ownerUserId: json['ownerUserId'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
        updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
        deletedAt: _optionalDate(json['deletedAt']),
        version: json['version'] as int? ?? 1,
        syncStatus: json['syncStatus'] as String? ?? SyncStatusKeys.localOnly,
        lastSyncedAt: _optionalDate(json['lastSyncedAt']),
        lastModifiedByDeviceId: json['lastModifiedByDeviceId'] as String?,
      );
}

DateTime? _optionalDate(Object? raw) =>
    raw is String && raw.isNotEmpty ? DateTime.parse(raw).toLocal() : null;
