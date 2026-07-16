import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/advanced_analytics_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/domain/exercise_library.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart'
    show FittinTheme;
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';

enum _AnatomySide { front, back }

class AnatomyLoadMap extends ConsumerStatefulWidget {
  const AnatomyLoadMap({super.key, required this.overview});

  final MuscleLoadOverview overview;

  @override
  ConsumerState<AnatomyLoadMap> createState() => _AnatomyLoadMapState();
}

class _AnatomyLoadMapState extends ConsumerState<AnatomyLoadMap> {
  ExerciseMuscle? _selectedMuscle;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context, ref);
    final theme = ref.watch(resolvedFittinThemeProvider);
    final intensityByMuscle = <ExerciseMuscle, double>{
      for (final load in widget.overview.loads)
        load.muscle: load.normalizedIntensity,
    };
    final selectedLoad = _selectedMuscle == null
        ? null
        : widget.overview.forMuscle(_selectedMuscle!);

    return DashboardSurfaceCard(
      radius: 28,
      highlight: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  strings.anatomicalLoadMap,
                  style: theme
                      .uiStyle(11, theme.fgDim, FontWeight.w800)
                      .copyWith(letterSpacing: 1.5),
                ),
              ),
              if (widget.overview.hasData)
                Container(
                  key: const ValueKey('anatomy-completed-set-total'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.loadLow.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: theme.loadHigh.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    strings.anatomyCompletedSets(
                      widget.overview.totalCompletedSets,
                    ),
                    style: theme.uiStyle(10, theme.fg, FontWeight.w700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final diagramHeight = (constraints.maxWidth * 0.92).clamp(
                260.0,
                336.0,
              );
              return SizedBox(
                height: diagramHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _AnatomyDiagram(
                        theme: theme,
                        key: const ValueKey('anatomy-front-diagram'),
                        side: _AnatomySide.front,
                        sideLabel: strings.anatomyFront,
                        strings: strings,
                        intensityByMuscle: intensityByMuscle,
                        selectedMuscle: _selectedMuscle,
                        onSelected: _selectMuscle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _AnatomyDiagram(
                        theme: theme,
                        key: const ValueKey('anatomy-back-diagram'),
                        side: _AnatomySide.back,
                        sideLabel: strings.anatomyBack,
                        strings: strings,
                        intensityByMuscle: intensityByMuscle,
                        selectedMuscle: _selectedMuscle,
                        onSelected: _selectMuscle,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          _IntensityLegend(theme: theme, strings: strings),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: !widget.overview.hasData
                ? _AnatomyMessage(
                    theme: theme,
                    key: const ValueKey('anatomy-no-data'),
                    icon: Icons.info_outline_rounded,
                    text: strings.anatomyNoData,
                  )
                : _selectedMuscle == null
                ? _AnatomyMessage(
                    theme: theme,
                    key: const ValueKey('anatomy-tap-hint'),
                    icon: Icons.touch_app_outlined,
                    text: strings.anatomyTapHint,
                  )
                : _SelectedMuscleDetail(
                    theme: theme,
                    key: ValueKey('anatomy-detail-${_selectedMuscle!.name}'),
                    muscle: _selectedMuscle!,
                    load: selectedLoad,
                    strings: strings,
                  ),
          ),
        ],
      ),
    );
  }

  void _selectMuscle(ExerciseMuscle muscle) {
    setState(() {
      _selectedMuscle = muscle;
    });
  }
}

class _AnatomyDiagram extends StatelessWidget {
  const _AnatomyDiagram({
    super.key,
    required this.theme,
    required this.side,
    required this.sideLabel,
    required this.strings,
    required this.intensityByMuscle,
    required this.selectedMuscle,
    required this.onSelected,
  });

  final _AnatomySide side;
  final FittinTheme theme;
  final String sideLabel;
  final AppStrings strings;
  final Map<ExerciseMuscle, double> intensityByMuscle;
  final ExerciseMuscle? selectedMuscle;
  final ValueChanged<ExerciseMuscle> onSelected;

  @override
  Widget build(BuildContext context) {
    final regionLabels = <ExerciseMuscle, String>{
      for (final muscle in ExerciseMuscle.values)
        muscle: strings.muscleName(muscle),
    };
    return Column(
      children: [
        Text(
          sideLabel,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: theme.fgDim,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Semantics(
                container: true,
                explicitChildNodes: true,
                label: sideLabel,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (details) {
                    final region = _AnatomyGeometry.regionAt(
                      side,
                      details.localPosition,
                      constraints.biggest,
                    );
                    if (region != null) {
                      onSelected(region.muscle);
                    }
                  },
                  child: CustomPaint(
                    painter: _AnatomyPainter(
                      side: side,
                      intensityByMuscle: intensityByMuscle,
                      selectedMuscle: selectedMuscle,
                      regionLabels: regionLabels,
                      noContributionLabel: strings.muscleNoContribution,
                      textDirection: Directionality.of(context),
                      onSelected: onSelected,
                      anatomyBase: theme.anatomyBase,
                      anatomyStroke: theme.anatomyStroke,
                      anatomyInactive: theme.anatomyInactive,
                      anatomySelected: theme.anatomySelected,
                      loadLow: theme.loadLow,
                      loadHigh: theme.loadHigh,
                    ),
                    size: Size.infinite,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _IntensityLegend extends StatelessWidget {
  const _IntensityLegend({required this.theme, required this.strings});

  final FittinTheme theme;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: theme.fgMuted,
      fontWeight: FontWeight.w700,
    );
    return Semantics(
      label: strings.anatomyLegendSemantics,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              strings.anatomyRelativeIntensity,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
          const SizedBox(width: 10),
          Text(strings.anatomyLowIntensity, style: style),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              key: const ValueKey('anatomy-intensity-legend'),
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  colors: [theme.loadLow, theme.loadHigh],
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(strings.anatomyHighIntensity, style: style),
        ],
      ),
    );
  }
}

class _AnatomyMessage extends StatelessWidget {
  const _AnatomyMessage({
    super.key,
    required this.theme,
    required this.icon,
    required this.text,
  });

  final FittinTheme theme;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: theme.fgMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: theme.fgDim, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedMuscleDetail extends StatelessWidget {
  const _SelectedMuscleDetail({
    super.key,
    required this.theme,
    required this.muscle,
    required this.load,
    required this.strings,
  });

  final FittinTheme theme;
  final ExerciseMuscle muscle;
  final MuscleLoadData? load;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final intensity = load?.normalizedIntensity ?? 0;
    final color = _highlightColor(theme.loadLow, theme.loadHigh, intensity);
    return Semantics(
      liveRegion: true,
      label: strings.anatomyRegionDetailSemantics(
        strings.muscleName(muscle),
        load == null
            ? strings.muscleNoContribution
            : strings.muscleContribution(
                load!.weightedCompletedSets,
                load!.contributingCompletedSets,
              ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.34)),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.muscleName(muscle),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: theme.fg,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    load == null
                        ? strings.muscleNoContribution
                        : strings.muscleContribution(
                            load!.weightedCompletedSets,
                            load!.contributingCompletedSets,
                          ),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: theme.fgDim),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnatomyPainter extends CustomPainter {
  _AnatomyPainter({
    required this.side,
    required this.intensityByMuscle,
    required this.selectedMuscle,
    required this.regionLabels,
    required this.noContributionLabel,
    required this.textDirection,
    required this.onSelected,
    required this.anatomyBase,
    required this.anatomyStroke,
    required this.anatomyInactive,
    required this.anatomySelected,
    required this.loadLow,
    required this.loadHigh,
  });

  final _AnatomySide side;
  final Map<ExerciseMuscle, double> intensityByMuscle;
  final ExerciseMuscle? selectedMuscle;
  final Map<ExerciseMuscle, String> regionLabels;
  final String noContributionLabel;
  final TextDirection textDirection;
  final ValueChanged<ExerciseMuscle> onSelected;
  final Color anatomyBase;
  final Color anatomyStroke;
  final Color anatomyInactive;
  final Color anatomySelected;
  final Color loadLow;
  final Color loadHigh;

  @override
  void paint(Canvas canvas, Size size) {
    final fit = _AnatomyFit(size);
    canvas.save();
    canvas.translate(fit.offset.dx, fit.offset.dy);
    canvas.scale(fit.scale);

    final basePaint = Paint()
      ..color = anatomyBase
      ..style = PaintingStyle.fill;
    final baseStroke = Paint()
      ..color = anatomyStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1 / fit.scale;
    final base = _AnatomyGeometry.bodyPath(side);
    canvas.drawPath(base, basePaint);
    canvas.drawPath(base, baseStroke);

    for (final region in _AnatomyGeometry.regions(side)) {
      final intensity = intensityByMuscle[region.muscle] ?? 0;
      final selected = region.muscle == selectedMuscle;
      canvas.drawPath(
        region.path,
        Paint()
          ..color = intensity <= 0
              ? anatomyInactive
              : _highlightColor(
                  loadLow,
                  loadHigh,
                  intensity,
                ).withValues(alpha: 0.45 + intensity * 0.5)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        region.path,
        Paint()
          ..color = selected
              ? anatomySelected
              : anatomyStroke.withValues(alpha: intensity > 0 ? 0.8 : 0.42)
          ..style = PaintingStyle.stroke
          ..strokeWidth = (selected ? 1.7 : 0.7) / fit.scale,
      );
    }

    _paintBodyLandmarks(canvas, fit.scale);
    canvas.restore();
  }

  void _paintBodyLandmarks(Canvas canvas, double scale) {
    final paint = Paint()
      ..color = anatomyStroke.withValues(alpha: 0.58)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7 / scale;
    canvas.drawLine(const Offset(60, 44), const Offset(60, 139), paint);
    canvas.drawLine(const Offset(39, 145), const Offset(81, 145), paint);
    if (side == _AnatomySide.front) {
      for (final y in [99.0, 112.0, 125.0]) {
        canvas.drawLine(Offset(45, y), Offset(75, y), paint);
      }
    } else {
      canvas.drawLine(const Offset(46, 74), const Offset(74, 74), paint);
      canvas.drawLine(const Offset(47, 118), const Offset(73, 118), paint);
    }
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder => (size) {
    final fit = _AnatomyFit(size);
    return [
      for (final region in _AnatomyGeometry.regions(side))
        CustomPainterSemantics(
          key: ValueKey('anatomy-region-${side.name}-${region.id}'),
          rect: fit.toCanvasRect(region.path.getBounds()).inflate(3),
          properties: SemanticsProperties(
            label: regionLabels[region.muscle],
            value: intensityByMuscle.containsKey(region.muscle)
                ? '${(intensityByMuscle[region.muscle]! * 100).round()}%'
                : noContributionLabel,
            button: true,
            selected: region.muscle == selectedMuscle,
            textDirection: textDirection,
            onTap: () => onSelected(region.muscle),
          ),
        ),
    ];
  };

  @override
  bool shouldRepaint(covariant _AnatomyPainter oldDelegate) {
    return oldDelegate.side != side ||
        oldDelegate.selectedMuscle != selectedMuscle ||
        oldDelegate.anatomyBase != anatomyBase ||
        oldDelegate.anatomyStroke != anatomyStroke ||
        oldDelegate.anatomyInactive != anatomyInactive ||
        oldDelegate.anatomySelected != anatomySelected ||
        oldDelegate.loadLow != loadLow ||
        oldDelegate.loadHigh != loadHigh ||
        !mapEquals(oldDelegate.intensityByMuscle, intensityByMuscle);
  }

  @override
  bool shouldRebuildSemantics(covariant _AnatomyPainter oldDelegate) {
    return shouldRepaint(oldDelegate) ||
        !mapEquals(oldDelegate.regionLabels, regionLabels) ||
        oldDelegate.noContributionLabel != noContributionLabel ||
        oldDelegate.textDirection != textDirection;
  }
}

class _AnatomyFit {
  _AnatomyFit(Size size)
    : scale = math.min(
        size.width / _AnatomyGeometry.width,
        size.height / _AnatomyGeometry.height,
      ),
      offset = Offset(
        (size.width -
                _AnatomyGeometry.width *
                    math.min(
                      size.width / _AnatomyGeometry.width,
                      size.height / _AnatomyGeometry.height,
                    )) /
            2,
        (size.height -
                _AnatomyGeometry.height *
                    math.min(
                      size.width / _AnatomyGeometry.width,
                      size.height / _AnatomyGeometry.height,
                    )) /
            2,
      );

  final double scale;
  final Offset offset;

  Offset toDesign(Offset point) =>
      Offset((point.dx - offset.dx) / scale, (point.dy - offset.dy) / scale);

  Rect toCanvasRect(Rect rect) => Rect.fromLTRB(
    offset.dx + rect.left * scale,
    offset.dy + rect.top * scale,
    offset.dx + rect.right * scale,
    offset.dy + rect.bottom * scale,
  );
}

class _AnatomyRegionPath {
  const _AnatomyRegionPath({
    required this.id,
    required this.muscle,
    required this.path,
  });

  final String id;
  final ExerciseMuscle muscle;
  final Path path;
}

class _AnatomyGeometry {
  static const width = 120.0;
  static const height = 250.0;

  static List<_AnatomyRegionPath> regions(_AnatomySide side) {
    return side == _AnatomySide.front ? _frontRegions : _backRegions;
  }

  static _AnatomyRegionPath? regionAt(
    _AnatomySide side,
    Offset canvasPoint,
    Size canvasSize,
  ) {
    if (canvasSize.isEmpty) {
      return null;
    }
    final designPoint = _AnatomyFit(canvasSize).toDesign(canvasPoint);
    for (final region in regions(side).reversed) {
      if (region.path.contains(designPoint)) {
        return region;
      }
    }
    return null;
  }

  static Path bodyPath(_AnatomySide side) {
    final path = Path()
      ..addOval(const Rect.fromLTWH(46, 2, 28, 34))
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(53, 32, 14, 16),
          const Radius.circular(5),
        ),
      )
      ..addPath(_torso(), Offset.zero)
      ..addPath(_arms(), Offset.zero)
      ..addPath(_pelvis(), Offset.zero)
      ..addPath(_legs(), Offset.zero);
    return path;
  }

  static final List<_AnatomyRegionPath> _frontRegions = [
    _AnatomyRegionPath(
      id: 'chest',
      muscle: ExerciseMuscle.chest,
      path: _pairedRounded(
        const Rect.fromLTWH(36, 57, 23, 27),
        const Rect.fromLTWH(61, 57, 23, 27),
        8,
      ),
    ),
    _AnatomyRegionPath(
      id: 'front-deltoids',
      muscle: ExerciseMuscle.anteriorDeltoids,
      path: _pairedOvals(
        const Rect.fromLTWH(25, 52, 15, 23),
        const Rect.fromLTWH(80, 52, 15, 23),
      ),
    ),
    _AnatomyRegionPath(
      id: 'side-deltoids',
      muscle: ExerciseMuscle.lateralDeltoids,
      path: _pairedOvals(
        const Rect.fromLTWH(21, 56, 9, 22),
        const Rect.fromLTWH(90, 56, 9, 22),
      ),
    ),
    _AnatomyRegionPath(
      id: 'biceps',
      muscle: ExerciseMuscle.biceps,
      path: _pairedRounded(
        const Rect.fromLTWH(17, 79, 12, 37),
        const Rect.fromLTWH(91, 79, 12, 37),
        6,
      ),
    ),
    _AnatomyRegionPath(
      id: 'forearms',
      muscle: ExerciseMuscle.forearms,
      path: _pairedRounded(
        const Rect.fromLTWH(11, 117, 12, 39),
        const Rect.fromLTWH(97, 117, 12, 39),
        6,
      ),
    ),
    _AnatomyRegionPath(
      id: 'core',
      muscle: ExerciseMuscle.core,
      path: _rounded(const Rect.fromLTWH(43, 87, 34, 51), 11),
    ),
    _AnatomyRegionPath(
      id: 'quadriceps',
      muscle: ExerciseMuscle.quadriceps,
      path: _pairedRounded(
        const Rect.fromLTWH(35, 153, 20, 54),
        const Rect.fromLTWH(65, 153, 20, 54),
        9,
      ),
    ),
    _AnatomyRegionPath(
      id: 'adductors',
      muscle: ExerciseMuscle.adductors,
      path: _pairedRounded(
        const Rect.fromLTWH(51, 157, 9, 45),
        const Rect.fromLTWH(60, 157, 9, 45),
        5,
      ),
    ),
    _AnatomyRegionPath(
      id: 'calves',
      muscle: ExerciseMuscle.calves,
      path: _pairedRounded(
        const Rect.fromLTWH(37, 207, 15, 38),
        const Rect.fromLTWH(68, 207, 15, 38),
        7,
      ),
    ),
  ];

  static final List<_AnatomyRegionPath> _backRegions = [
    _AnatomyRegionPath(
      id: 'rear-deltoids',
      muscle: ExerciseMuscle.rearDeltoids,
      path: _pairedOvals(
        const Rect.fromLTWH(24, 53, 17, 23),
        const Rect.fromLTWH(79, 53, 17, 23),
      ),
    ),
    _AnatomyRegionPath(
      id: 'side-deltoids',
      muscle: ExerciseMuscle.lateralDeltoids,
      path: _pairedOvals(
        const Rect.fromLTWH(20, 57, 9, 21),
        const Rect.fromLTWH(91, 57, 9, 21),
      ),
    ),
    _AnatomyRegionPath(
      id: 'upper-back',
      muscle: ExerciseMuscle.upperBack,
      path: _polygon(const [
        Offset(38, 55),
        Offset(60, 47),
        Offset(82, 55),
        Offset(76, 86),
        Offset(60, 93),
        Offset(44, 86),
      ]),
    ),
    _AnatomyRegionPath(
      id: 'lats',
      muscle: ExerciseMuscle.lats,
      path: _pairedRounded(
        const Rect.fromLTWH(34, 78, 19, 45),
        const Rect.fromLTWH(67, 78, 19, 45),
        9,
      ),
    ),
    _AnatomyRegionPath(
      id: 'triceps',
      muscle: ExerciseMuscle.triceps,
      path: _pairedRounded(
        const Rect.fromLTWH(17, 79, 12, 38),
        const Rect.fromLTWH(91, 79, 12, 38),
        6,
      ),
    ),
    _AnatomyRegionPath(
      id: 'forearms',
      muscle: ExerciseMuscle.forearms,
      path: _pairedRounded(
        const Rect.fromLTWH(11, 117, 12, 39),
        const Rect.fromLTWH(97, 117, 12, 39),
        6,
      ),
    ),
    _AnatomyRegionPath(
      id: 'lower-back',
      muscle: ExerciseMuscle.lowerBack,
      path: _rounded(const Rect.fromLTWH(46, 105, 28, 35), 10),
    ),
    _AnatomyRegionPath(
      id: 'glutes',
      muscle: ExerciseMuscle.glutes,
      path: _pairedRounded(
        const Rect.fromLTWH(37, 139, 23, 28),
        const Rect.fromLTWH(60, 139, 23, 28),
        10,
      ),
    ),
    _AnatomyRegionPath(
      id: 'hamstrings',
      muscle: ExerciseMuscle.hamstrings,
      path: _pairedRounded(
        const Rect.fromLTWH(36, 166, 19, 43),
        const Rect.fromLTWH(65, 166, 19, 43),
        9,
      ),
    ),
    _AnatomyRegionPath(
      id: 'calves',
      muscle: ExerciseMuscle.calves,
      path: _pairedRounded(
        const Rect.fromLTWH(36, 207, 17, 38),
        const Rect.fromLTWH(67, 207, 17, 38),
        8,
      ),
    ),
  ];

  static Path _torso() {
    return Path()
      ..moveTo(43, 43)
      ..quadraticBezierTo(28, 47, 27, 65)
      ..quadraticBezierTo(31, 88, 38, 111)
      ..lineTo(37, 137)
      ..quadraticBezierTo(47, 145, 60, 145)
      ..quadraticBezierTo(73, 145, 83, 137)
      ..lineTo(82, 111)
      ..quadraticBezierTo(89, 88, 93, 65)
      ..quadraticBezierTo(92, 47, 77, 43)
      ..quadraticBezierTo(68, 47, 60, 48)
      ..quadraticBezierTo(52, 47, 43, 43)
      ..close();
  }

  static Path _arms() {
    return _polygon(const [
      Offset(28, 58),
      Offset(18, 63),
      Offset(14, 94),
      Offset(7, 143),
      Offset(12, 160),
      Offset(23, 157),
      Offset(30, 116),
      Offset(35, 77),
    ])..addPath(
      _polygon(const [
        Offset(92, 58),
        Offset(102, 63),
        Offset(106, 94),
        Offset(113, 143),
        Offset(108, 160),
        Offset(97, 157),
        Offset(90, 116),
        Offset(85, 77),
      ]),
      Offset.zero,
    );
  }

  static Path _pelvis() {
    return Path()
      ..moveTo(38, 132)
      ..quadraticBezierTo(60, 142, 82, 132)
      ..lineTo(86, 160)
      ..quadraticBezierTo(73, 171, 60, 166)
      ..quadraticBezierTo(47, 171, 34, 160)
      ..close();
  }

  static Path _legs() {
    return _polygon(const [
      Offset(35, 154),
      Offset(59, 157),
      Offset(55, 206),
      Offset(52, 246),
      Offset(34, 246),
      Offset(31, 209),
    ])..addPath(
      _polygon(const [
        Offset(61, 157),
        Offset(85, 154),
        Offset(89, 209),
        Offset(86, 246),
        Offset(68, 246),
        Offset(65, 206),
      ]),
      Offset.zero,
    );
  }
}

Path _pairedOvals(Rect left, Rect right) {
  return Path()
    ..addOval(left)
    ..addOval(right);
}

Path _pairedRounded(Rect left, Rect right, double radius) {
  return Path()
    ..addRRect(RRect.fromRectAndRadius(left, Radius.circular(radius)))
    ..addRRect(RRect.fromRectAndRadius(right, Radius.circular(radius)));
}

Path _rounded(Rect rect, double radius) {
  return Path()
    ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
}

Path _polygon(List<Offset> points) {
  final path = Path()..moveTo(points.first.dx, points.first.dy);
  for (final point in points.skip(1)) {
    path.lineTo(point.dx, point.dy);
  }
  return path..close();
}

Color _highlightColor(Color low, Color high, double intensity) {
  return Color.lerp(low, high, intensity.clamp(0, 1))!;
}
