import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/data/progress_repository.dart';
import 'package:fittin_v2/src/domain/models/body_metric.dart';
import 'package:fittin_v2/src/domain/models/progress_photo.dart';

final localProgressRepositoryProvider = Provider<LocalProgressRepository>((
  ref,
) {
  return LocalProgressRepository(
    repository: ref.watch(progressRepositoryProvider),
    ownerUserId: ref.watch(currentUserIdProvider),
  );
});

class LocalProgressRepository {
  LocalProgressRepository({
    required ProgressRepository repository,
    required String? ownerUserId,
  }) : _repository = repository,
       _ownerUserId = ownerUserId;

  final ProgressRepository _repository;
  final String? _ownerUserId;

  Future<void> saveBodyMetric(BodyMetric metric) {
    return _repository.saveBodyMetric(metric, ownerUserId: _ownerUserId);
  }

  Future<List<BodyMetric>> fetchBodyMetrics() {
    return _repository.fetchBodyMetrics(ownerUserId: _ownerUserId);
  }

  Future<void> deleteBodyMetric(String metricId) {
    return _repository.deleteBodyMetric(metricId);
  }

  Future<void> saveProgressPhoto(ProgressPhoto photo) {
    return _repository.saveProgressPhoto(photo, ownerUserId: _ownerUserId);
  }

  Future<List<ProgressPhoto>> fetchProgressPhotos() {
    return _repository.fetchProgressPhotos(ownerUserId: _ownerUserId);
  }

  Future<void> deleteProgressPhoto(String photoId) {
    return _repository.deleteProgressPhoto(photoId);
  }
}
