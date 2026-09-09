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

enum _AnatomySide { front, back, side }

class AnatomyLoadMap extends ConsumerStatefulWidget {
  const AnatomyLoadMap({super.key, required this.overview});

  final MuscleLoadOverview overview;

  @override
  ConsumerState<AnatomyLoadMap> createState() => _AnatomyLoadMapState();
}

class _AnatomyLoadMapState extends ConsumerState<AnatomyLoadMap> {
  ExerciseMuscle? _selectedMuscle;
  _AnatomySide? _focusedSide;

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
          Text(
            strings.isChinese
                ? '训练组分布 · 点视图标题放大'
                : 'Set exposure · tap a view title to enlarge',
            style: theme.uiStyle(11, theme.fgMuted),
          ),
          if (_focusedSide != null)
            TextButton.icon(
              onPressed: () => setState(() => _focusedSide = null),
              icon: const Icon(Icons.grid_view_rounded, size: 16),
              label: Text(strings.isChinese ? '返回三视图' : 'All three views'),
            ),
          LayoutBuilder(
            builder: (context, constraints) {
              final diagramHeight = _focusedSide == null
                  ? (constraints.maxWidth * 1.03).clamp(270.0, 360.0)
                  : 420.0;
              return SizedBox(
                height: diagramHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final side
                        in _focusedSide == null
                            ? _AnatomySide.values
                            : [_focusedSide!])
                      Expanded(
                        child: _AnatomyDiagram(
                          theme: theme,
                          key: ValueKey('anatomy-${side.name}-diagram'),
                          side: side,
                          sideLabel: switch (side) {
                            _AnatomySide.front => strings.anatomyFront,
                            _AnatomySide.back => strings.anatomyBack,
                            _AnatomySide.side =>
                              strings.isChinese ? '侧面' : 'Side',
                          },
                          onFocus: () => setState(() => _focusedSide = side),
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
    required this.onFocus,
  });

  final _AnatomySide side;
  final FittinTheme theme;
  final String sideLabel;
  final AppStrings strings;
  final Map<ExerciseMuscle, double> intensityByMuscle;
  final ExerciseMuscle? selectedMuscle;
  final ValueChanged<ExerciseMuscle> onSelected;
  final VoidCallback onFocus;

  @override
  Widget build(BuildContext context) {
    final regionLabels = <ExerciseMuscle, String>{
      for (final muscle in ExerciseMuscle.values)
        muscle: strings.muscleName(muscle),
    };
    return Column(
      children: [
        TextButton(
          onPressed: onFocus,
          child: Text(
            sideLabel,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: theme.fgDim,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
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
                    key: ValueKey('anatomy-${side.name}-canvas'),
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
    if (side != _AnatomySide.side) {
      canvas.drawLine(const Offset(60, 46), const Offset(60, 148), paint);
      for (final x in [44.0, 76.0]) {
        canvas.drawArc(
          Rect.fromCenter(center: Offset(x, 231), width: 10, height: 9),
          0,
          math.pi,
          false,
          paint,
        );
        canvas.drawLine(Offset(x, 278), Offset(x, 300), paint);
      }
    }
    // Fine fiber lines give the regions depth without borrowing medical imagery.
    for (final region in _AnatomyGeometry.regions(side)) {
      canvas.save();
      canvas.clipPath(region.path);
      final bounds = region.path.getBounds();
      for (double y = bounds.top + 4; y < bounds.bottom; y += 6) {
        canvas.drawPath(
          Path()
            ..moveTo(bounds.left, y + 3)
            ..quadraticBezierTo(bounds.center.dx, y - 3, bounds.right, y + 2),
          Paint()
            ..color = anatomyStroke.withValues(alpha: .16)
            ..style = PaintingStyle.stroke
            ..strokeWidth = .4 / scale,
        );
      }
      canvas.restore();
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
  static const height = 320.0;

  static List<_AnatomyRegionPath> regions(_AnatomySide side) => switch (side) {
    _AnatomySide.front => _frontRegions,
    _AnatomySide.back => _backRegions,
    _AnatomySide.side => _sideRegions,
  };

  static _AnatomyRegionPath? regionAt(
    _AnatomySide side,
    Offset point,
    Size size,
  ) {
    if (size.isEmpty) return null;
    final design = _AnatomyFit(size).toDesign(point);
    for (final region in regions(side).reversed) {
      if (region.path.contains(design)) return region;
    }
    return null;
  }

  static Path _shape(List<List<double>> points) {
    final path = Path();
    final first = points.first;
    final last = points.last;
    path.moveTo((first[0] + last[0]) / 2, (first[1] + last[1]) / 2);
    for (var i = 0; i < points.length; i++) {
      final a = points[i];
      final b = points[(i + 1) % points.length];
      path.quadraticBezierTo(a[0], a[1], (a[0] + b[0]) / 2, (a[1] + b[1]) / 2);
    }
    return path..close();
  }

  static Path _sym(Path left) => Path()
    ..addPath(left, Offset.zero)
    ..addPath(
      left.transform(
        Float64List.fromList([
          -1,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          1,
          0,
          120,
          0,
          0,
          1,
        ]),
      ),
      Offset.zero,
    );

  static _AnatomyRegionPath _r(String id, ExerciseMuscle muscle, Path path) =>
      _AnatomyRegionPath(id: id, muscle: muscle, path: path);

  static Path bodyPath(_AnatomySide side) {
    if (side == _AnatomySide.side) return _sideBody;
    return Path()
      ..addPath(
        _shape([
          [50, 5],
          [60, 2],
          [70, 5],
          [72, 17],
          [68, 29],
          [63, 34],
          [57, 34],
          [52, 29],
          [48, 17],
        ]),
        Offset.zero,
      )
      ..addPath(
        _sym(
          _shape([
            [54, 30],
            [53, 41],
            [40, 46],
            [29, 52],
            [23, 67],
            [20, 91],
            [17, 112],
            [13, 132],
            [9, 160],
            [8, 171],
            [12, 181],
            [18, 181],
            [21, 170],
            [23, 148],
            [29, 123],
            [31, 113],
            [34, 91],
            [37, 84],
            [41, 108],
            [40, 127],
            [34, 150],
            [33, 170],
            [34, 198],
            [38, 221],
            [38, 235],
            [36, 249],
            [39, 278],
            [40, 298],
            [34, 305],
            [32, 312],
            [48, 314],
            [52, 309],
            [51, 293],
            [52, 272],
            [55, 247],
            [53, 233],
            [55, 215],
            [57, 189],
            [59, 169],
            [60, 163],
            [60, 42],
          ]),
        ),
        Offset.zero,
      );
  }

  static final _frontRegions = <_AnatomyRegionPath>[
    _r(
      'chest',
      ExerciseMuscle.chest,
      _sym(
        _shape([
          [59, 55],
          [47, 51],
          [37, 57],
          [34, 68],
          [39, 80],
          [53, 84],
          [59, 78],
        ]),
      ),
    ),
    _r(
      'front-deltoids',
      ExerciseMuscle.anteriorDeltoids,
      _sym(
        _shape([
          [37, 51],
          [28, 54],
          [24, 66],
          [26, 79],
          [33, 73],
          [36, 62],
        ]),
      ),
    ),
    _r(
      'side-deltoids',
      ExerciseMuscle.lateralDeltoids,
      _sym(
        _shape([
          [26, 56],
          [22, 64],
          [21, 78],
          [25, 82],
          [28, 74],
        ]),
      ),
    ),
    _r(
      'biceps',
      ExerciseMuscle.biceps,
      _sym(
        _shape([
          [27, 80],
          [32, 78],
          [31, 94],
          [26, 113],
          [22, 112],
          [21, 99],
        ]),
      ),
    ),
    _r(
      'triceps',
      ExerciseMuscle.triceps,
      _sym(
        _shape([
          [21, 82],
          [24, 84],
          [20, 106],
          [18, 112],
          [18, 98],
        ]),
      ),
    ),
    _r(
      'forearms',
      ExerciseMuscle.forearms,
      _sym(
        _shape([
          [20, 115],
          [28, 116],
          [23, 134],
          [19, 161],
          [13, 164],
          [13, 146],
          [16, 130],
        ]),
      ),
    ),
    _r('core', ExerciseMuscle.core, _coreFront()),
    _r(
      'hip-flexors',
      ExerciseMuscle.hipFlexors,
      _sym(
        _shape([
          [39, 134],
          [47, 140],
          [56, 153],
          [54, 162],
          [45, 151],
          [37, 145],
        ]),
      ),
    ),
    _r(
      'quadriceps',
      ExerciseMuscle.quadriceps,
      _sym(
        Path()
          ..addPath(
            _shape([
              [38, 157],
              [46, 157],
              [44, 187],
              [42, 208],
              [40, 220],
              [35, 204],
              [34, 177],
            ]),
            Offset.zero,
          )
          ..addPath(
            _shape([
              [47, 160],
              [53, 168],
              [52, 193],
              [49, 214],
              [44, 215],
              [45, 192],
            ]),
            Offset.zero,
          )
          ..addPath(
            _shape([
              [53, 194],
              [55, 210],
              [53, 224],
              [47, 226],
              [47, 216],
            ]),
            Offset.zero,
          ),
      ),
    ),
    _r(
      'adductors',
      ExerciseMuscle.adductors,
      _sym(
        _shape([
          [50, 152],
          [58, 163],
          [56, 184],
          [52, 198],
          [49, 183],
        ]),
      ),
    ),
    _r(
      'calves',
      ExerciseMuscle.calves,
      _sym(
        _shape([
          [40, 239],
          [44, 239],
          [42, 260],
          [42, 281],
          [39, 270],
          [37, 251],
        ]),
      ),
    ),
    _r(
      'tibialis',
      ExerciseMuscle.tibialisAnterior,
      _sym(
        _shape([
          [48, 235],
          [52, 239],
          [50, 260],
          [47, 287],
          [43, 296],
          [45, 270],
        ]),
      ),
    ),
  ];

  static Path _coreFront() {
    final path = Path();
    for (final y in [88.0, 101.0, 114.0]) {
      path.addPath(
        _sym(
          _shape([
            [49, y],
            [58, y - 1],
            [58, y + 10],
            [49, y + 11],
            [47, y + 5],
          ]),
        ),
        Offset.zero,
      );
    }
    path.addPath(
      _sym(
        _shape([
          [48, 128],
          [58, 126],
          [58, 142],
          [54, 150],
          [49, 142],
        ]),
      ),
      Offset.zero,
    );
    path.addPath(
      _sym(
        _shape([
          [37, 85],
          [44, 91],
          [46, 118],
          [43, 134],
          [38, 124],
          [40, 104],
        ]),
      ),
      Offset.zero,
    );
    return path;
  }

  static final _backRegions = <_AnatomyRegionPath>[
    _r(
      'upper-back',
      ExerciseMuscle.upperBack,
      _shape([
        [60, 35],
        [49, 44],
        [36, 52],
        [42, 66],
        [51, 76],
        [60, 95],
        [69, 76],
        [78, 66],
        [84, 52],
        [71, 44],
      ]),
    ),
    _r(
      'rear-deltoids',
      ExerciseMuscle.rearDeltoids,
      _sym(
        _shape([
          [36, 52],
          [27, 55],
          [23, 67],
          [25, 79],
          [34, 72],
          [38, 64],
        ]),
      ),
    ),
    _r(
      'side-deltoids',
      ExerciseMuscle.lateralDeltoids,
      _sym(
        _shape([
          [24, 59],
          [20, 72],
          [21, 82],
          [25, 79],
          [27, 67],
        ]),
      ),
    ),
    _r(
      'rotator-cuff',
      ExerciseMuscle.rotatorCuff,
      _sym(
        _shape([
          [39, 65],
          [50, 72],
          [48, 84],
          [37, 79],
        ]),
      ),
    ),
    _r(
      'lats',
      ExerciseMuscle.lats,
      _sym(
        _shape([
          [36, 80],
          [49, 85],
          [57, 99],
          [53, 117],
          [43, 137],
          [38, 123],
          [40, 104],
        ]),
      ),
    ),
    _r(
      'triceps',
      ExerciseMuscle.triceps,
      _sym(
        _shape([
          [27, 78],
          [32, 80],
          [31, 95],
          [25, 114],
          [20, 113],
          [20, 97],
        ]),
      ),
    ),
    _r(
      'forearms',
      ExerciseMuscle.forearms,
      _sym(
        _shape([
          [20, 116],
          [28, 118],
          [22, 139],
          [19, 162],
          [13, 165],
          [13, 148],
          [16, 130],
        ]),
      ),
    ),
    _r(
      'lower-back',
      ExerciseMuscle.lowerBack,
      _sym(
        _shape([
          [57, 99],
          [59, 110],
          [58, 145],
          [50, 150],
          [46, 136],
          [52, 116],
        ]),
      ),
    ),
    _r(
      'glutes',
      ExerciseMuscle.glutes,
      _sym(
        _shape([
          [46, 140],
          [56, 149],
          [59, 156],
          [58, 175],
          [45, 180],
          [35, 170],
          [35, 154],
          [39, 145],
        ]),
      ),
    ),
    _r(
      'hamstrings',
      ExerciseMuscle.hamstrings,
      _sym(
        Path()
          ..addPath(
            _shape([
              [36, 177],
              [44, 181],
              [44, 204],
              [42, 226],
              [38, 228],
              [35, 204],
            ]),
            Offset.zero,
          )
          ..addPath(
            _shape([
              [47, 180],
              [55, 177],
              [54, 204],
              [51, 227],
              [47, 223],
              [45, 202],
            ]),
            Offset.zero,
          ),
      ),
    ),
    _r(
      'adductors',
      ExerciseMuscle.adductors,
      _sym(
        _shape([
          [56, 175],
          [58, 178],
          [56, 201],
          [52, 207],
        ]),
      ),
    ),
    _r(
      'calves',
      ExerciseMuscle.calves,
      _sym(
        Path()
          ..addPath(
            _shape([
              [41, 236],
              [46, 242],
              [44, 263],
              [41, 274],
              [37, 261],
              [37, 246],
            ]),
            Offset.zero,
          )
          ..addPath(
            _shape([
              [48, 234],
              [53, 242],
              [51, 261],
              [47, 274],
              [45, 261],
            ]),
            Offset.zero,
          ),
      ),
    ),
  ];

  static final _sideBody = _shape([
    [58, 3],
    [71, 6],
    [75, 15],
    [81, 22],
    [75, 25],
    [73, 32],
    [65, 35],
    [66, 43],
    [75, 51],
    [79, 67],
    [83, 75],
    [77, 89],
    [77, 113],
    [75, 133],
    [78, 151],
    [80, 164],
    [78, 187],
    [75, 210],
    [74, 225],
    [77, 240],
    [75, 262],
    [72, 291],
    [77, 304],
    [87, 308],
    [87, 313],
    [65, 314],
    [62, 301],
    [61, 280],
    [59, 260],
    [57, 239],
    [58, 227],
    [53, 211],
    [47, 187],
    [43, 170],
    [43, 151],
    [47, 133],
    [49, 114],
    [45, 99],
    [43, 114],
    [40, 139],
    [37, 164],
    [34, 180],
    [27, 178],
    [26, 171],
    [29, 153],
    [31, 131],
    [34, 105],
    [35, 82],
    [37, 63],
    [43, 52],
    [52, 45],
    [56, 34],
    [50, 26],
    [48, 15],
    [51, 6],
  ]);

  static final _sideRegions = <_AnatomyRegionPath>[
    _r(
      'chest',
      ExerciseMuscle.chest,
      _shape([
        [65, 52],
        [75, 58],
        [79, 72],
        [75, 81],
        [67, 75],
        [63, 65],
      ]),
    ),
    _r(
      'front-deltoids',
      ExerciseMuscle.anteriorDeltoids,
      _shape([
        [57, 51],
        [64, 54],
        [65, 67],
        [58, 77],
        [54, 69],
      ]),
    ),
    _r(
      'side-deltoids',
      ExerciseMuscle.lateralDeltoids,
      _shape([
        [49, 51],
        [56, 51],
        [57, 66],
        [52, 79],
        [45, 77],
        [43, 64],
      ]),
    ),
    _r(
      'rear-deltoids',
      ExerciseMuscle.rearDeltoids,
      _shape([
        [43, 54],
        [49, 55],
        [44, 70],
        [43, 80],
        [38, 74],
        [38, 62],
      ]),
    ),
    _r(
      'biceps',
      ExerciseMuscle.biceps,
      _shape([
        [51, 78],
        [55, 82],
        [52, 99],
        [47, 116],
        [42, 111],
        [44, 96],
      ]),
    ),
    _r(
      'triceps',
      ExerciseMuscle.triceps,
      _shape([
        [38, 79],
        [44, 81],
        [45, 96],
        [40, 117],
        [35, 111],
        [35, 94],
      ]),
    ),
    _r(
      'forearms',
      ExerciseMuscle.forearms,
      _shape([
        [35, 116],
        [44, 116],
        [40, 136],
        [35, 162],
        [30, 169],
        [29, 158],
        [32, 137],
      ]),
    ),
    _r(
      'lats',
      ExerciseMuscle.lats,
      _shape([
        [53, 78],
        [62, 80],
        [65, 101],
        [61, 119],
        [51, 132],
        [50, 113],
      ]),
    ),
    _r(
      'core',
      ExerciseMuscle.core,
      _shape([
        [68, 82],
        [76, 85],
        [75, 110],
        [72, 131],
        [62, 143],
        [62, 125],
        [66, 106],
      ]),
    ),
    _r(
      'lower-back',
      ExerciseMuscle.lowerBack,
      _shape([
        [49, 115],
        [53, 123],
        [50, 144],
        [46, 146],
      ]),
    ),
    _r(
      'glutes',
      ExerciseMuscle.glutes,
      _shape([
        [49, 140],
        [60, 143],
        [66, 154],
        [64, 171],
        [52, 179],
        [45, 174],
        [43, 159],
      ]),
    ),
    _r(
      'hip-flexors',
      ExerciseMuscle.hipFlexors,
      _shape([
        [69, 137],
        [75, 142],
        [78, 155],
        [72, 165],
        [65, 156],
      ]),
    ),
    _r(
      'quadriceps',
      ExerciseMuscle.quadriceps,
      _shape([
        [69, 161],
        [77, 166],
        [77, 185],
        [71, 211],
        [68, 226],
        [62, 223],
        [62, 206],
        [65, 183],
      ]),
    ),
    _r(
      'hamstrings',
      ExerciseMuscle.hamstrings,
      _shape([
        [49, 179],
        [60, 180],
        [63, 201],
        [61, 222],
        [57, 218],
        [52, 201],
      ]),
    ),
    _r(
      'calves',
      ExerciseMuscle.calves,
      _shape([
        [61, 235],
        [69, 242],
        [68, 260],
        [63, 276],
        [60, 266],
        [57, 249],
      ]),
    ),
    _r(
      'tibialis',
      ExerciseMuscle.tibialisAnterior,
      _shape([
        [72, 234],
        [76, 241],
        [73, 263],
        [70, 288],
        [66, 295],
        [68, 270],
      ]),
    ),
  ];
}

Color _highlightColor(Color low, Color high, double intensity) {
  return Color.lerp(low, high, intensity.clamp(0, 1))!;
}
