import 'package:isar/isar.dart';

part 'workout_log_collection.g.dart';

@collection
class WorkoutLogCollection {
  Id id = Isar.autoIncrement;

  // UUID for the log entry
  @Index(unique: true, replace: true)
  late String logId;

  // The Instance this log belongs to
  @Index()
  late String instanceId;

  @Index()
  late String workoutId;

  late String workoutName;

  // Whole-workout log payload stored as JSON for schema flexibility.
  late String rawJsonPayload;

  @Index()
  late DateTime completedAt;
}
