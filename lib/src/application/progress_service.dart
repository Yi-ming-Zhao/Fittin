import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/domain/one_rep_max.dart';

final progressServiceProvider = Provider<ProgressService>((ref) {
  return ProgressService();
});

class ProgressService {
  /// Calculates the Estimated 1-Rep Max using the Brzycki formula.
  /// Standard choice for the progress tracking module.
  double? calculateE1RM(double weight, int reps) {
    return estimateOneRepMax(
      formula: OneRepMaxFormula.brzycki,
      weight: weight,
      reps: reps,
    );
  }

  /// Calculates an estimated N-Rep Max based on the 1RM and Brzycki formula.
  double? calculateNRM(double e1rm, int targetReps) {
    if (targetReps == 1) return e1rm;
    if (targetReps >= 37) return null;
    // W = 1RM * (37 - r) / 36
    return e1rm * (37 - targetReps) / 36;
  }

  /// Calculates E1RM for a list of sets and returns the best one.
  double? calculateBestE1RM(List<({double weight, int reps})> sets) {
    double best = 0;
    for (final set in sets) {
      final e1rm = calculateE1RM(set.weight, set.reps);
      if (e1rm != null && e1rm > best) {
        best = e1rm;
      }
    }
    return best > 0 ? best : null;
  }
}
