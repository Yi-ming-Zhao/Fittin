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
  final home = Platform.environment['HOME'];
  if (home == null || home.isEmpty) {
    throw StateError('HOME is required to locate isar_flutter_libs test binaries.');
  }

  final pubCacheRoot = '$home/.pub-cache/hosted/pub.dev/isar_flutter_libs-3.1.0+1';
  final libraries = <Abi, String>{};

  if (Platform.isMacOS) {
    final libraryPath = '$pubCacheRoot/macos/libisar.dylib';
    libraries.addAll({
      Abi.macosX64: libraryPath,
      Abi.macosArm64: libraryPath,
    });
  } else if (Platform.isLinux) {
    final libraryPath = '$pubCacheRoot/linux/libisar.so';
    libraries.addAll({
      Abi.linuxX64: libraryPath,
      Abi.linuxArm64: libraryPath,
    });
  } else if (Platform.isWindows) {
    final libraryPath = '$pubCacheRoot/windows/isar.dll';
    libraries.addAll({
      Abi.windowsX64: libraryPath,
      Abi.windowsArm64: libraryPath,
    });
  } else {
    throw UnsupportedError('Unsupported platform for Isar test core: ${Platform.operatingSystem}');
  }

  await Isar.initializeIsarCore(
    libraries: libraries,
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
