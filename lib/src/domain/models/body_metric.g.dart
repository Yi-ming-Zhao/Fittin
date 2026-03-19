// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_metric.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BodyMetricImpl _$$BodyMetricImplFromJson(Map<String, dynamic> json) =>
    _$BodyMetricImpl(
      metricId: json['metricId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      bodyFatPercent: (json['bodyFatPercent'] as num?)?.toDouble(),
      waistCm: (json['waistCm'] as num?)?.toDouble(),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$$BodyMetricImplToJson(_$BodyMetricImpl instance) =>
    <String, dynamic>{
      'metricId': instance.metricId,
      'timestamp': instance.timestamp.toIso8601String(),
      'weightKg': instance.weightKg,
      'bodyFatPercent': instance.bodyFatPercent,
      'waistCm': instance.waistCm,
      'note': instance.note,
    };
