import 'package:fittin_v2/src/domain/exercise_library.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const exerciseLibraryAssetPath = 'assets/exercises/exercise_library.v1.json';

class ExerciseLibraryLoader {
  ExerciseLibraryLoader({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  Future<ExerciseLibrary> load() async {
    final source = await _bundle.loadString(exerciseLibraryAssetPath);
    return ExerciseLibrary.fromJsonString(source);
  }
}

final exerciseLibraryLoaderProvider = Provider<ExerciseLibraryLoader>((ref) {
  return ExerciseLibraryLoader();
});

final exerciseLibraryProvider = FutureProvider<ExerciseLibrary>((ref) async {
  return ref.watch(exerciseLibraryLoaderProvider).load();
});
