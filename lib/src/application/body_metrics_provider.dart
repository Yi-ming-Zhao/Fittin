import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/data/local/local_progress_repository.dart';
import 'package:fittin_v2/src/domain/models/body_metric.dart';
import 'package:uuid/uuid.dart';

final bodyMetricsProvider =
    StateNotifierProvider<BodyMetricsNotifier, AsyncValue<List<BodyMetric>>>((
      ref,
    ) {
      return BodyMetricsNotifier(ref);
    });

class BodyMetricsNotifier extends StateNotifier<AsyncValue<List<BodyMetric>>> {
  BodyMetricsNotifier(this._ref) : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final metrics = await _ref
          .read(localProgressRepositoryProvider)
          .fetchBodyMetrics();
      state = AsyncValue.data(metrics);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addMetric({
    double? weight,
    double? bodyFat,
    double? waist,
    String? note,
  }) async {
    final metric = BodyMetric(
      metricId: const Uuid().v4(),
      timestamp: DateTime.now(),
      weightKg: weight,
      bodyFatPercent: bodyFat,
      waistCm: waist,
      note: note,
    );

    await _ref.read(localProgressRepositoryProvider).saveBodyMetric(metric);
    await _load();
  }

  Future<void> deleteMetric(String id) async {
    await _ref.read(localProgressRepositoryProvider).deleteBodyMetric(id);
    await _load();
  }
}
