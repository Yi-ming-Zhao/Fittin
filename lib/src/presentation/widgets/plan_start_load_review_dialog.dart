import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/application/exercise_library_provider.dart';
import 'package:fittin_v2/src/domain/plan_start_load_review.dart';
import 'package:fittin_v2/src/domain/starting_load_estimator.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';
import 'package:fittin_v2/src/presentation/widgets/fittin_primitives.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlanStartLoadReviewDialog extends ConsumerStatefulWidget {
  const PlanStartLoadReviewDialog({super.key, required this.review});

  final PlanStartLoadReview review;

  @override
  ConsumerState<PlanStartLoadReviewDialog> createState() =>
      _PlanStartLoadReviewDialogState();
}

class _PlanStartLoadReviewDialogState
    extends ConsumerState<PlanStartLoadReviewDialog> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final entry in widget.review.editableEntries)
        entry.exerciseOccurrenceId: TextEditingController(
          text: _formatWeight(entry.confirmedWeightKg),
        ),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context, ref);
    final theme = ref.watch(resolvedFittinThemeProvider);
    final entries = widget.review.editableEntries;

    return AlertDialog(
      backgroundColor: theme.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(theme.radius),
        side: BorderSide(color: theme.border),
      ),
      title: Text(
        strings.reviewStartingLoads,
        style: theme.displayStyle(22, theme.fg),
      ),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.reviewStartingLoadsDescription,
                  style: theme.uiStyle(12, theme.fgDim).copyWith(height: 1.45),
                ),
                const SizedBox(height: 16),
                for (final entry in entries) ...[
                  _LoadReviewCard(
                    entry: entry,
                    controller: _controllers[entry.exerciseOccurrenceId]!,
                    strings: strings,
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        FittinBtn(
          theme,
          strings.cancel,
          size: 'sm',
          variant: 'secondary',
          onPressed: () => Navigator.of(context).pop(),
        ),
        FittinBtn(
          theme,
          strings.confirmAndStart,
          size: 'sm',
          onPressed: _confirm,
        ),
      ],
    );
  }

  void _confirm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final weights = <String, double?>{};
    for (final entry in widget.review.editableEntries) {
      final raw = _controllers[entry.exerciseOccurrenceId]!.text.trim();
      weights[entry.exerciseOccurrenceId] = raw.isEmpty
          ? null
          : double.parse(raw);
    }
    Navigator.of(context).pop(widget.review.withConfirmedWeights(weights));
  }
}

class _LoadReviewCard extends ConsumerWidget {
  const _LoadReviewCard({
    required this.entry,
    required this.controller,
    required this.strings,
  });

  final PlanStartLoadEntry entry;
  final TextEditingController controller;
  final AppStrings strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(resolvedFittinThemeProvider);
    final library = ref.watch(exerciseLibraryProvider).valueOrNull;
    final recommendation = entry.recommendation!;
    final warnings = recommendation.warnings
        .where(
          (warning) => warning != StartingLoadWarningCode.editableSuggestion,
        )
        .toList();
    final sourceExerciseName = library
        ?.findKnown(exerciseId: recommendation.sourceExerciseId, name: null)
        ?.displayName(strings.isChinese ? 'zh' : 'en');

    return DashboardSurfaceCard(
      padding: const EdgeInsets.all(14),
      radius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.exerciseName,
                  style: theme
                      .uiStyle(14, theme.fg)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${entry.targetReps}${entry.targetRir > 0 ? ' + ${_formatWeight(entry.targetRir)} RIR' : ''}',
                style: theme.numStyle(11, theme.fgMuted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            strings.startingLoadSourceLabel(
              recommendation.source,
              observedReps: recommendation.sourceObservedReps,
              sourceExerciseName:
                  sourceExerciseName ?? recommendation.sourceExerciseId,
            ),
            key: ValueKey('plan-start-source-${entry.exerciseOccurrenceId}'),
            style: theme.uiStyle(11, theme.fgDim).copyWith(height: 1.35),
          ),
          const SizedBox(height: 10),
          TextFormField(
            key: ValueKey('plan-start-load-${entry.exerciseOccurrenceId}'),
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: strings.confirmedLoad,
              suffixText: strings.kilogramUnit,
              hintText: strings.enterManually,
            ),
            validator: (value) {
              final raw = (value ?? '').trim();
              if (raw.isEmpty) {
                return null;
              }
              final parsed = double.tryParse(raw);
              if (parsed == null || parsed <= 0 || !parsed.isFinite) {
                return strings.enterValidLoad;
              }
              return null;
            },
          ),
          if (warnings.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final warning in warnings)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  '• ${strings.startingLoadWarning(warning)}',
                  style: theme.uiStyle(10, theme.fgMuted).copyWith(height: 1.3),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

String _formatWeight(double? value) {
  if (value == null) {
    return '';
  }
  return value.truncateToDouble() == value
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);
}
