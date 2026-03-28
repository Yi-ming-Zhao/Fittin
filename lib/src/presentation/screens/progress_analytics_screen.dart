import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/progress_analytics_provider.dart';
import 'package:fittin_v2/src/domain/one_rep_max.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';

class ProgressAnalyticsScreen extends ConsumerWidget {
  const ProgressAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context, ref);
    final overviewAsync = ref.watch(progressAnalyticsOverviewProvider);
    final formula = ref.watch(analyticsFormulaProvider);

    return overviewAsync.when(
      data: (overview) {
        if (overview.exerciseSummaries.isEmpty) {
          return DashboardPageScaffold(
            children: [
              DashboardScreenHeader(
                eyebrow: strings.insights,
                title: strings.progressAnalytics,
                subtitle: strings.analyticsEmptySubtitle,
              ),
              const SizedBox(height: 28),
              _EmptyState(strings: strings),
            ],
          );
        }

        return DashboardPageScaffold(
          children: [
            DashboardScreenHeader(
              eyebrow: strings.insights,
              title: strings.progressAnalytics,
              subtitle: strings.progressAnalyticsSubtitle,
            ),
            const SizedBox(height: 20),
            DashboardSurfaceCard(
              radius: 34,
              highlight: true,
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.strengthTrajectory,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.strengthTrajectorySubtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.68),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            DashboardSurfaceCard(
              child: _FormulaPicker(
                formula: formula,
                strings: strings,
                onChanged: (value) => ref
                    .read(analyticsFormulaProvider.notifier)
                    .setFormula(value),
              ),
            ),
            const SizedBox(height: 24),
            _OverviewCards(overview: overview, strings: strings),
            const SizedBox(height: 32),
            DashboardSectionLabel(label: strings.allExercises),
            const SizedBox(height: 14),
            for (final summary in overview.exerciseSummaries) ...[
              _ExerciseSummaryCard(
                summary: summary,
                strings: strings,
                onTap: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => _ExerciseDetailSheet(
                    summary: summary,
                    strings: strings,
                    formula: formula,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(error.toString(), textAlign: TextAlign.center),
          ),
        ),
      ),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DashboardSurfaceCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insights_rounded,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              strings.analyticsEmptyTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionLabel(label: strings.formula),
        const SizedBox(height: 10),
        DropdownButtonFormField<OneRepMaxFormula>(
          initialValue: formula,
          dropdownColor: const Color(0xFF111317),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.04),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.14),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.72),
              ),
            ),
          ),
          items: [
            for (final item in OneRepMaxFormula.values)
              DropdownMenuItem(value: item, child: Text(item.label)),
          ],
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
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
        _OverviewStatCard(
          title: strings.workoutsCompleted,
          value: '${overview.completedWorkoutCount}',
          highlight: true,
        ),
        _OverviewStatCard(
          title: strings.trainingDays,
          value: '${overview.recentTrainingDays}',
        ),
        _OverviewStatCard(
          title: strings.recentVolume,
          value: strings.kilograms(overview.recentVolume),
        ),
        _OverviewStatCard(
          title: strings.highlightLift,
          value: highlight?.exerciseName ?? '—',
        ),
      ],
    );
  }
}

class _OverviewStatCard extends StatelessWidget {
  const _OverviewStatCard({
    required this.title,
    required this.value,
    this.highlight = false,
  });

  final String title;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: DashboardStatCard(
        label: title,
        value: value,
        highlight: highlight,
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
    return DashboardSurfaceCard(
      onTap: onTap,
      radius: 30,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  summary.exerciseName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.05,
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
              color: Colors.white.withValues(alpha: 0.52),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0B0D10),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardScreenHeader(
                  eyebrow: strings.exerciseDetails,
                  title: summary.exerciseName,
                  subtitle: '${strings.activeFormula}: ${formula.label}',
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetricPill(
                      label: strings.bestEstimatedOneRepMax,
                      value: summary.bestEstimatedOneRepMax == null
                          ? '—'
                          : strings.kilograms(summary.bestEstimatedOneRepMax!),
                    ),
                    _MetricPill(
                      label: strings.bestActualOneRepMax,
                      value: summary.bestActualOneRepMax == null
                          ? strings.noActualOneRepMax
                          : strings.kilograms(summary.bestActualOneRepMax!),
                    ),
                    _MetricPill(
                      label: strings.bestSet,
                      value: estimatedBestSet == null
                          ? '—'
                          : '${strings.kilograms(estimatedBestSet.weight)} x ${estimatedBestSet.reps}',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                DashboardSectionLabel(label: strings.estimatedTrend),
                const SizedBox(height: 12),
                DashboardSurfaceCard(
                  radius: 24,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: summary.estimatedHistory.reversed
                        .take(6)
                        .map(
                          (point) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(strings.kilograms(point.value)),
                            subtitle: Text(
                              '${strings.kilograms(point.weight)} x ${point.reps}',
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 20),
                DashboardSectionLabel(label: strings.actualTrend),
                const SizedBox(height: 12),
                DashboardSurfaceCard(
                  radius: 24,
                  padding: const EdgeInsets.all(12),
                  child: summary.actualHistory.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(strings.noActualOneRepMax),
                        )
                      : Column(
                          children: summary.actualHistory.reversed
                              .take(6)
                              .map(
                                (point) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(strings.kilograms(point.value)),
                                  subtitle: Text(
                                    strings.daysAgo(
                                      DateTime.now()
                                          .difference(point.completedAt)
                                          .inDays,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ),
                const SizedBox(height: 20),
                DashboardSectionLabel(label: strings.personalRecords),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final pr in summary.personalRecords)
                      _Pill(
                        label: pr,
                        color: theme.colorScheme.secondaryContainer,
                      ),
                  ],
                ),
              ],
            ),
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
    return DashboardSurfaceCard(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.52),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
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
        color: color.withValues(alpha: 0.22),
        border: Border.all(color: color.withValues(alpha: 0.28)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
