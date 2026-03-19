abstract final class SyncStatusKeys {
  static const localOnly = 'local_only';
  static const pendingUpload = 'pending_upload';
  static const synced = 'synced';
  static const pendingDelete = 'pending_delete';
  static const conflict = 'conflict';
}

abstract final class SyncEntityTypes {
  static const template = 'template';
  static const instance = 'instance';
  static const workoutLog = 'workout_log';
  static const bodyMetric = 'body_metric';
  static const progressPhoto = 'progress_photo';
}

abstract final class SyncOperationTypes {
  static const upsert = 'upsert';
  static const delete = 'delete';
}
