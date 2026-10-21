import 'package:flutter/material.dart';
import '../../domain/models/cardio_recording.dart';

String cardioDurationLabel(double seconds) {
  if (!seconds.isFinite || seconds < 0) return '—';
  final total = seconds.round();
  final hours = total ~/ 3600;
  final minutes = (total % 3600) ~/ 60;
  final remainder = (total % 60).toString().padLeft(2, '0');
  return hours > 0
      ? '$hours:${minutes.toString().padLeft(2, '0')}:$remainder'
      : '$minutes:$remainder';
}

/// Per-lap values, not an activity-wide average reused for every row. A manual
/// lap can end before a kilometre boundary, so rows are not labelled kilometres.
class CardioSplitList extends StatelessWidget {
  const CardioSplitList({
    super.key,
    required this.laps,
    required this.chinese,
    this.cycling = false,
  });

  final List<CardioLap> laps;
  final bool chinese, cycling;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < laps.length; i++) ...[
          if (i > 0) Divider(height: 1, color: colors.outlineVariant),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${chinese ? '分段' : 'Lap'} ${i + 1}${laps[i].automatic ? (chinese ? ' · 自动' : ' · Auto') : ''}',
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 20,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    _value(
                      context,
                      '${(laps[i].distanceMeters / 1000).toStringAsFixed(2)} km',
                      chinese ? '距离' : 'Distance',
                    ),
                    _value(
                      context,
                      cardioDurationLabel(laps[i].activeMilliseconds / 1000),
                      chinese ? '用时' : 'Time',
                    ),
                    _value(
                      context,
                      _rate(laps[i]),
                      cycling
                          ? (chinese ? '速度 · km/h' : 'Speed · km/h')
                          : (chinese ? '配速 · /km' : 'Pace · /km'),
                      accent: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _rate(CardioLap lap) {
    if (lap.distanceMeters <= 0 || lap.activeMilliseconds <= 0) return '—';
    return cycling
        ? (lap.distanceMeters * 3600 / lap.activeMilliseconds).toStringAsFixed(
            1,
          )
        : cardioDurationLabel(lap.paceSecondsPerKm!);
  }

  Widget _value(
    BuildContext context,
    String value,
    String label, {
    bool accent = false,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
            color: accent
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
