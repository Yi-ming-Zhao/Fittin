import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fittin_v2/src/data/local/local_progress_repository.dart';
import 'package:fittin_v2/src/data/remote/progress_photo_cache.dart';
import 'package:fittin_v2/src/domain/models/body_metric.dart';
import 'package:fittin_v2/src/domain/models/progress_photo.dart';
import 'package:uuid/uuid.dart';

final bodyMetricsProvider =
    StateNotifierProvider<BodyMetricsNotifier, AsyncValue<List<BodyMetric>>>((
      ref,
    ) {
      return BodyMetricsNotifier(ref);
    });

final progressPhotosProvider =
    StateNotifierProvider<
      ProgressPhotosNotifier,
      AsyncValue<List<ProgressPhoto>>
    >((ref) {
      return ProgressPhotosNotifier(ref.watch(localProgressRepositoryProvider));
    });

class ProgressPhotosNotifier
    extends StateNotifier<AsyncValue<List<ProgressPhoto>>> {
  ProgressPhotosNotifier(this._repository, {ImagePicker? picker})
    : _picker = picker ?? ImagePicker(),
      super(const AsyncValue.loading()) {
    reload();
  }

  final LocalProgressRepository _repository;
  final ImagePicker _picker;

  Future<void> reload() async {
    try {
      state = AsyncValue.data(await _repository.fetchProgressPhotos());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<bool> addPhoto({required ImageSource source, String? label}) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 88,
      maxWidth: 1600,
    );
    if (picked == null) return false;
    final bytes = await picked.readAsBytes();
    if (bytes.isEmpty || bytes.length > 10 * 1024 * 1024) {
      throw StateError('Photo must be smaller than 10 MB.');
    }
    final photoId = const Uuid().v4();
    final localPath = await cacheProgressPhotoBytes(photoId, bytes);
    await _repository.saveProgressPhoto(
      ProgressPhoto(
        photoId: photoId,
        timestamp: DateTime.now(),
        filePath: localPath,
        label: label?.trim().isEmpty == true ? null : label?.trim(),
      ),
    );
    await reload();
    return true;
  }

  Future<void> deletePhoto(String photoId) async {
    await _repository.deleteProgressPhoto(photoId);
    await reload();
  }
}

class BodyMetricsNotifier extends StateNotifier<AsyncValue<List<BodyMetric>>> {
  BodyMetricsNotifier(this._ref) : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref _ref;
  int _loadRevision = 0;

  Future<void> _load() async {
    if (!mounted) return;
    final revision = ++_loadRevision;
    state = const AsyncValue.loading();
    try {
      final metrics = await _ref
          .read(localProgressRepositoryProvider)
          .fetchBodyMetrics();
      if (mounted && revision == _loadRevision) {
        state = AsyncValue.data(metrics);
      }
    } catch (e, st) {
      if (mounted && revision == _loadRevision) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> reload() => _load();

  Future<void> addMetric({
    double? weight,
    double? bodyFat,
    double? waist,
    String? note,
  }) async {
    _validateOptionalMetric(weight, minimum: 20, maximum: 500, label: 'Weight');
    _validateOptionalMetric(
      bodyFat,
      minimum: 1,
      maximum: 75,
      label: 'Body fat',
    );
    _validateOptionalMetric(waist, minimum: 30, maximum: 250, label: 'Waist');
    if (weight == null &&
        bodyFat == null &&
        waist == null &&
        (note == null || note.trim().isEmpty)) {
      throw ArgumentError('Enter at least one measurement or a note.');
    }
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

  void _validateOptionalMetric(
    double? value, {
    required double minimum,
    required double maximum,
    required String label,
  }) {
    if (value == null) return;
    if (!value.isFinite || value < minimum || value > maximum) {
      throw ArgumentError('$label must be between $minimum and $maximum.');
    }
  }

  Future<void> deleteMetric(String id) async {
    await _ref.read(localProgressRepositoryProvider).deleteBodyMetric(id);
    await _load();
  }
}
