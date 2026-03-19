// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProgressPhotoImpl _$$ProgressPhotoImplFromJson(Map<String, dynamic> json) =>
    _$ProgressPhotoImpl(
      photoId: json['photoId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      filePath: json['filePath'] as String,
      label: json['label'] as String?,
      metadataJson: json['metadataJson'] as String?,
    );

Map<String, dynamic> _$$ProgressPhotoImplToJson(_$ProgressPhotoImpl instance) =>
    <String, dynamic>{
      'photoId': instance.photoId,
      'timestamp': instance.timestamp.toIso8601String(),
      'filePath': instance.filePath,
      'label': instance.label,
      'metadataJson': instance.metadataJson,
    };
