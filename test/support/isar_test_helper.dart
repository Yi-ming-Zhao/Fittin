import 'dart:ffi';
import 'dart:io';

import 'package:isar/isar.dart';
import 'package:fittin_v2/src/data/models/app_state_collection.dart';
import 'package:fittin_v2/src/data/models/body_metric_collection.dart';
import 'package:fittin_v2/src/data/models/instance_collection.dart';
import 'package:fittin_v2/src/data/models/sync_queue_collection.dart';
import 'package:fittin_v2/src/data/models/template_collection.dart';
import 'package:fittin_v2/src/data/models/workout_log_collection.dart';

Future<void> initializeTestIsarCore() async {
  final libraryPath =
      '${Platform.environment['HOME']}/.pub-cache/hosted/pub.dev/isar_flutter_libs-3.1.0+1/macos/libisar.dylib';
  await Isar.initializeIsarCore(
    libraries: {
      Abi.macosX64: libraryPath,
      Abi.macosArm64: libraryPath,
    },
  );
}

Future<({Isar isar, Directory directory})> openTestIsar(String name) async {
  await initializeTestIsarCore();
  final directory = await Directory.systemTemp.createTemp('fittin_$name');
  final isar = await Isar.open(
    [
      AppStateCollectionSchema,
      BodyMetricCollectionSchema,
      ProgressPhotoCollectionSchema,
      InstanceCollectionSchema,
      SyncQueueCollectionSchema,
      TemplateCollectionSchema,
      WorkoutLogCollectionSchema,
    ],
    directory: directory.path,
    name: name,
    inspector: false,
  );
  return (isar: isar, directory: directory);
}
