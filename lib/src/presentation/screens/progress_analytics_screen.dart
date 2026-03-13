import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/domain/one_rep_max.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';

class ProgressAnalyticsScreen extends ConsumerWidget {
  const ProgressAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context, ref);
    final overviewAsync = ref.watch(progressAnalyticsOverviewProvider);
    final formula = ref.watch(analyticsFormulaProvider);

    return Scaffold(
      body: SafeArea(
        child: overviewAsync.when(
          data: (overview) {
            if (overview.exerciseSummaries.isEmpty) {
              return _EmptyState(strings: strings);
            }
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.progressAnalytics,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        _FormulaPicker(
                          formula: formula,
                          strings: strings,
                          onChanged: (value) => ref
                              .read(analyticsFormulaProvider.notifier)
                              .setFormula(value),
                        ),
                        const SizedBox(height: 20),
                        _OverviewCards(overview: overview, strings: strings),
                        const SizedBox(height: 20),
                        Text(
                          strings.allExercises,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index.isOdd) {
                        return const SizedBox(height: 12);
                      }
                      final itemIndex = index ~/ 2;
                      if (itemIndex >= overview.exerciseSummaries.length) {
                        return null;
                      }
                      final summary = overview.exerciseSummaries[itemIndex];
                      return _ExerciseSummaryCard(
                        summary: summary,
                        strings: strings,
                        onTap: () => showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => _ExerciseDetailSheet(
                            summary: summary,
                            strings: strings,
                            formula: formula,
                          ),
                        ),
                      );
                    },
                    childCount: overview.exerciseSummaries.isEmpty
                        ? 0
                        : overview.exerciseSummaries.length * 2 - 1,
                  ),
                  ),
                ),
              ],
            );
          },
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(error.toString(), textAlign: TextAlign.center),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insights_rounded, size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              strings.analyticsEmptyTitle,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              strings.analyticsEmptySubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.66),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FormulaPicker extends StatelessWidget {
  const _FormulaPicker({
    required this.formula,
    required this.strings,
    required this.onChanged,
  });

  final OneRepMaxFormula formula;
  final AppStrings strings;
  final ValueChanged<OneRepMaxFormula> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '${strings.formula}: ',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<OneRepMaxFormula>(
            value: formula,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
            items: [
              for (final item in OneRepMaxFormula.values)
                DropdownMenuItem(
                  value: item,
                  child: Text(item.label),
                ),
            ],
            onChanged: (value) {
              if (value != null) {
                onChanged(value);
              }
            },
          ),
        ),
      ],
    );
  }
}

class _OverviewCards extends StatelessWidget {
  const _OverviewCards({required this.overview, required this.strings});

  final ProgressAnalyticsOverview overview;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final highlight = overview.highlightExerciseId == null
        ? null
        : overview.exerciseSummaries.firstWhere(
            (item) => item.exerciseId == overview.highlightExerciseId,
          );
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _StatCard(
          title: strings.workoutsCompleted,
          value: '${overview.completedWorkoutCount}',
        ),
        _StatCard(
          title: strings.trainingDays,
          value: '${overview.recentTrainingDays}',
        ),
        _StatCard(
          title: strings.recentVolume,
          value: strings.kilograms(overview.recentVolume),
        ),
        _StatCard(
          title: strings.highlightLift,
          value: highlight?.exerciseName ?? '—',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _ExerciseSummaryCard extends StatelessWidget {
  const _ExerciseSummaryCard({
    required this.summary,
    required this.strings,
    required this.onTap,
  });

  final ExerciseProgressSummary summary;
  final AppStrings strings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: theme.colorScheme.surface,
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    summary.exerciseName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (summary.isStagnating)
                  _Pill(
                    label: strings.stagnating,
                    color: theme.colorScheme.errorContainer,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetricPill(
                  label: strings.estimatedOneRepMax,
                  value: summary.currentEstimatedOneRepMax == null
                      ? '—'
                      : strings.kilograms(summary.currentEstimatedOneRepMax!),
                ),
                _MetricPill(
                  label: strings.actualOneRepMax,
                  value: summary.currentActualOneRepMax == null
                      ? strings.noActualOneRepMax
                      : strings.kilograms(summary.currentActualOneRepMax!),
                ),
                _MetricPill(
                  label: strings.recentChange,
                  value: summary.recentChange == null
                      ? strings.noRecentChangeLabel()
                      : strings.plusMinusKilograms(summary.recentChange!),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              strings.sessionsLogged(summary.encounterCount),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.66),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseDetailSheet extends StatelessWidget {
  const _ExerciseDetailSheet({
    required this.summary,
    required this.strings,
    required this.formula,
  });

  final ExerciseProgressSummary summary;
  final AppStrings strings;
  final OneRepMaxFormula formula;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final estimatedBestSet = summary.estimatedHistory.isEmpty
        ? null
        : summary.estimatedHistory.reduce((a, b) => a.value > b.value ? a : b);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                summary.exerciseName,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                '${strings.activeFormula}: ${formula.label}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              _MetricPill(
                label: strings.bestEstimatedOneRepMax,
                value: summary.bestEstimatedOneRepMax == null
                    ? '—'
                    : strings.kilograms(summary.bestEstimatedOneRepMax!),
              ),
              const SizedBox(height: 8),
              _MetricPill(
                label: strings.bestActualOneRepMax,
                value: summary.bestActualOneRepMax == null
                    ? strings.noActualOneRepMax
                    : strings.kilograms(summary.bestActualOneRepMax!),
              ),
              const SizedBox(height: 8),
              _MetricPill(
                label: strings.bestSet,
                value: estimatedBestSet == null
                    ? '—'
                    : '${strings.kilograms(estimatedBestSet.weight)} x ${estimatedBestSet.reps}',
              ),
              const SizedBox(height: 20),
              Text(
                strings.estimatedTrend,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...summary.estimatedHistory.reversed.take(6).map(
                (point) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(strings.kilograms(point.value)),
                  subtitle: Text(
                    '${strings.kilograms(point.weight)} x ${point.reps}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                strings.actualTrend,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (summary.actualHistory.isEmpty)
                Text(strings.noActualOneRepMax)
              else
                ...summary.actualHistory.reversed.take(6).map(
                  (point) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(strings.kilograms(point.value)),
                    subtitle: Text(strings.daysAgo(DateTime.now().difference(point.completedAt).inDays)),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                strings.personalRecords,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final pr in summary.personalRecords)
                    _Pill(label: pr, color: theme.colorScheme.secondaryContainer),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.66),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}
