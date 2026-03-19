import 'package:freezed_annotation/freezed_annotation.dart';

part 'body_metric.freezed.dart';
part 'body_metric.g.dart';

@freezed
class BodyMetric with _$BodyMetric {
  const factory BodyMetric({
    required String metricId,
    required DateTime timestamp,
    double? weightKg,
    double? bodyFatPercent,
    double? waistCm,
    String? note,
  }) = _BodyMetric;

  factory BodyMetric.fromJson(Map<String, dynamic> json) =>
      _$BodyMetricFromJson(json);
}
