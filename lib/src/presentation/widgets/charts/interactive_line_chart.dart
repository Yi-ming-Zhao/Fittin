import 'dart:math' as math;

import 'package:fittin_v2/src/presentation/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';

typedef ChartDateFormatter = String Function(DateTime date);
typedef ChartValueFormatter = String Function(double value);
typedef ChartEmptySemanticsFormatter =
    String Function(String chartLabel, String emptyLabel);
typedef ChartSummarySemanticsFormatter =
    String Function(
      String chartLabel,
      String xAxisLabel,
      String dateRange,
      String yAxisLabel,
      String unit,
      List<String> seriesLabels,
    );
typedef ChartPointLabelFormatter =
    String Function(
      String seriesLabel,
      String dateLabel,
      String valueLabel,
      String unit,
      String? detail,
    );

@immutable
class DatedChartPoint {
  DatedChartPoint({required this.date, required this.value, this.detail})
    : assert(value.isFinite, 'Chart values must be finite.');

  final DateTime date;
  final double value;
  final String? detail;
}

@immutable
class DatedChartSeries {
  DatedChartSeries({
    required this.id,
    required this.label,
    required List<DatedChartPoint> points,
    this.color,
  }) : assert(id != '', 'A chart series needs a stable non-empty id.'),
       assert(label != '', 'A chart series needs a non-empty label.'),
       points = List<DatedChartPoint>.unmodifiable(points);

  final String id;
  final String label;
  final List<DatedChartPoint> points;
  final Color? color;
}

@immutable
class DatedChartSelection {
  const DatedChartSelection({required this.series, required this.point});

  final DatedChartSeries series;
  final DatedChartPoint point;

  @override
  bool operator ==(Object other) {
    return other is DatedChartSelection &&
        other.series.id == series.id &&
        other.point.date.millisecondsSinceEpoch ==
            point.date.millisecondsSinceEpoch &&
        other.point.value == point.value &&
        other.point.detail == point.detail;
  }

  @override
  int get hashCode => Object.hash(
    series.id,
    point.date.millisecondsSinceEpoch,
    point.value,
    point.detail,
  );
}

@immutable
class InteractiveLineChartTick<T> {
  const InteractiveLineChartTick({
    required this.value,
    required this.label,
    required this.position,
  });

  final T value;
  final String label;
  final double position;
}

@immutable
class InteractiveLineChartPositionedPoint {
  const InteractiveLineChartPositionedPoint({
    required this.selection,
    required this.offset,
    required this.color,
  });

  final DatedChartSelection selection;
  final Offset offset;
  final Color color;
}

/// A read-only geometry snapshot used by hit testing and focused chart tests.
@immutable
class InteractiveLineChartLayout {
  const InteractiveLineChartLayout({
    required this.plotRect,
    required this.xTicks,
    required this.yTicks,
    required this.points,
    this.minDate,
    this.maxDate,
    this.minY,
    this.maxY,
  });

  final Rect plotRect;
  final List<InteractiveLineChartTick<DateTime>> xTicks;
  final List<InteractiveLineChartTick<double>> yTicks;
  final List<InteractiveLineChartPositionedPoint> points;
  final DateTime? minDate;
  final DateTime? maxDate;
  final double? minY;
  final double? maxY;

  bool get isEmpty => points.isEmpty;
}

/// Shared dated line chart for analytical screens.
///
/// All user-visible copy is supplied by the caller so the widget stays fully
/// locale-aware. [height] includes the legend, plot and selection detail rail.
class InteractiveLineChart extends StatefulWidget {
  const InteractiveLineChart({
    required this.theme,
    required this.series,
    required this.chartLabel,
    required this.xAxisLabel,
    required this.yAxisLabel,
    required this.unit,
    required this.emptyLabel,
    required this.selectionHint,
    required this.axisDateFormatter,
    required this.detailDateFormatter,
    required this.axisValueFormatter,
    required this.detailValueFormatter,
    this.emptySemanticsFormatter,
    this.summarySemanticsFormatter,
    this.pointLabelFormatter,
    this.height = 260,
    this.touchTolerance = 44,
    this.onSelectionChanged,
    super.key,
  }) : assert(height >= 180, 'The chart needs at least 180 logical pixels.'),
       assert(
         touchTolerance >= 22,
         'Touch tolerance must preserve at least a 44-pixel target.',
       );

  final FittinTheme theme;
  final List<DatedChartSeries> series;
  final String chartLabel;
  final String xAxisLabel;
  final String yAxisLabel;
  final String unit;
  final String emptyLabel;
  final String selectionHint;
  final ChartDateFormatter axisDateFormatter;
  final ChartDateFormatter detailDateFormatter;
  final ChartValueFormatter axisValueFormatter;
  final ChartValueFormatter detailValueFormatter;
  final ChartEmptySemanticsFormatter? emptySemanticsFormatter;
  final ChartSummarySemanticsFormatter? summarySemanticsFormatter;
  final ChartPointLabelFormatter? pointLabelFormatter;
  final double height;
  final double touchTolerance;
  final ValueChanged<DatedChartSelection?>? onSelectionChanged;

  @override
  State<InteractiveLineChart> createState() => _InteractiveLineChartState();
}

class _InteractiveLineChartState extends State<InteractiveLineChart> {
  DatedChartSelection? _selection;

  List<DatedChartSeries> get _visibleSeries => widget.series
      .where((series) => series.points.any((point) => point.value.isFinite))
      .toList(growable: false);

  @override
  void didUpdateWidget(covariant InteractiveLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    final rebound = _rebindSelection(widget.series, _selection);
    if (rebound != _selection) {
      _selection = rebound;
    }
  }

  @override
  Widget build(BuildContext context) {
    final series = _visibleSeries;
    if (series.isEmpty) {
      return Semantics(
        key: const ValueKey('interactive-line-chart-semantics'),
        container: true,
        label:
            widget.emptySemanticsFormatter?.call(
              widget.chartLabel,
              widget.emptyLabel,
            ) ??
            '${widget.chartLabel}. ${widget.emptyLabel}',
        child: Container(
          key: const ValueKey('interactive-line-chart-empty'),
          height: widget.height,
          alignment: Alignment.center,
          decoration: _chartDecoration(widget.theme),
          child: Text(
            widget.emptyLabel,
            style: _chartTextStyle(widget.theme, 13, widget.theme.fgMuted),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final summary = _semanticSummary(series);
    final selectedLabel = _selection == null
        ? widget.selectionHint
        : _selectionLabel(_selection!);

    return Semantics(
      key: const ValueKey('interactive-line-chart-semantics'),
      container: true,
      explicitChildNodes: true,
      label: summary,
      value: selectedLabel,
      child: Container(
        height: widget.height,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: _chartDecoration(widget.theme),
        child: Column(
          children: [
            if (series.length > 1) ...[
              _ChartLegend(theme: widget.theme, series: series),
              const SizedBox(height: 6),
            ],
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final painter = InteractiveLineChartPainter(
                    theme: widget.theme,
                    series: series,
                    xAxisLabel: widget.xAxisLabel,
                    yAxisLabel: widget.yAxisLabel,
                    unit: widget.unit,
                    axisDateFormatter: widget.axisDateFormatter,
                    detailDateFormatter: widget.detailDateFormatter,
                    axisValueFormatter: widget.axisValueFormatter,
                    detailValueFormatter: widget.detailValueFormatter,
                    pointLabelFormatter: widget.pointLabelFormatter,
                    selection: _selection,
                    textDirection: Directionality.of(context),
                    textScaler: MediaQuery.textScalerOf(context),
                    onPointSelected: _select,
                  );
                  final size = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (details) {
                      final nearest = painter.nearestSelection(
                        details.localPosition,
                        size,
                        tolerance: widget.touchTolerance,
                      );
                      if (nearest != null) {
                        _select(nearest);
                      }
                    },
                    child: CustomPaint(
                      key: const ValueKey('interactive-line-chart-plot'),
                      painter: painter,
                      size: Size.infinite,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            _SelectionDetailRail(
              theme: widget.theme,
              label: selectedLabel,
              selection: _selection,
              color: _selection == null
                  ? widget.theme.fgMuted
                  : _seriesColor(
                      widget.theme,
                      series.indexWhere(
                        (item) => item.id == _selection!.series.id,
                      ),
                      _selection!.series,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _select(DatedChartSelection selection) {
    if (_selection == selection) {
      return;
    }
    setState(() => _selection = selection);
    widget.onSelectionChanged?.call(selection);
  }

  String _selectionLabel(DatedChartSelection selection) {
    return _formatSelectionLabel(
      selection,
      unit: widget.unit,
      dateFormatter: widget.detailDateFormatter,
      valueFormatter: widget.detailValueFormatter,
      formatter: widget.pointLabelFormatter,
    );
  }

  String _semanticSummary(List<DatedChartSeries> series) {
    final points = series.expand((item) => item.points).toList(growable: false)
      ..sort((a, b) => a.date.compareTo(b.date));
    final range = points.first.date == points.last.date
        ? widget.detailDateFormatter(points.first.date)
        : '${widget.detailDateFormatter(points.first.date)} – '
              '${widget.detailDateFormatter(points.last.date)}';
    final names = series.map((item) => item.label).toList(growable: false);
    final formatter = widget.summarySemanticsFormatter;
    if (formatter != null) {
      return formatter(
        widget.chartLabel,
        widget.xAxisLabel,
        range,
        widget.yAxisLabel,
        widget.unit,
        names,
      );
    }
    final unit = widget.unit.isEmpty ? '' : ' · ${widget.unit}';
    return '${widget.chartLabel}. ${widget.xAxisLabel}: $range. '
        '${widget.yAxisLabel}$unit. ${names.join(', ')}';
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend({required this.theme, required this.series});

  final FittinTheme theme;
  final List<DatedChartSeries> series;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: series.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final item = series[index];
          return Semantics(
            label: item.label,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 3,
                  decoration: BoxDecoration(
                    color: _seriesColor(theme, index, item),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  item.label,
                  style: _chartTextStyle(
                    theme,
                    10,
                    theme.fgDim,
                    FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SelectionDetailRail extends StatelessWidget {
  const _SelectionDetailRail({
    required this.theme,
    required this.label,
    required this.selection,
    required this.color,
  });

  final FittinTheme theme;
  final String label;
  final DatedChartSelection? selection;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const ValueKey('interactive-line-chart-detail'),
      container: true,
      liveRegion: selection != null,
      label: label,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: theme.surfaceHi,
          borderRadius: BorderRadius.circular(theme.radiusSm),
          border: Border.all(color: theme.border),
        ),
        child: Row(
          children: [
            Container(
              width: selection == null ? 6 : 8,
              height: selection == null ? 6 : 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: ExcludeSemantics(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _chartTextStyle(
                    theme,
                    11,
                    selection == null ? theme.fgMuted : theme.fg,
                    selection == null ? FontWeight.w400 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InteractiveLineChartPainter extends CustomPainter {
  InteractiveLineChartPainter({
    required this.theme,
    required this.series,
    required this.xAxisLabel,
    required this.yAxisLabel,
    required this.unit,
    required this.axisDateFormatter,
    required this.detailDateFormatter,
    required this.axisValueFormatter,
    required this.detailValueFormatter,
    required this.textDirection,
    this.pointLabelFormatter,
    this.textScaler = TextScaler.noScaling,
    this.selection,
    this.onPointSelected,
  });

  final FittinTheme theme;
  final List<DatedChartSeries> series;
  final String xAxisLabel;
  final String yAxisLabel;
  final String unit;
  final ChartDateFormatter axisDateFormatter;
  final ChartDateFormatter detailDateFormatter;
  final ChartValueFormatter axisValueFormatter;
  final ChartValueFormatter detailValueFormatter;
  final ChartPointLabelFormatter? pointLabelFormatter;
  final TextDirection textDirection;
  final TextScaler textScaler;
  final DatedChartSelection? selection;
  final ValueChanged<DatedChartSelection>? onPointSelected;

  static const _seriesPalette = <Color>[
    Color(0xFFD4734A),
    Color(0xFFD8AA55),
    Color(0xFFB87AA8),
    Color(0xFF817FA8),
    Color(0xFFF3ECE0),
  ];

  @visibleForTesting
  InteractiveLineChartLayout layoutFor(Size size) {
    final flattened = <DatedChartSelection>[];
    for (final item in series) {
      for (final point in item.points) {
        if (point.value.isFinite) {
          flattened.add(DatedChartSelection(series: item, point: point));
        }
      }
    }

    final axisStyle = _chartTextStyle(
      theme,
      9,
      theme.fgMuted,
    ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
    final axisTitleStyle = _chartTextStyle(
      theme,
      9,
      theme.fgDim,
      FontWeight.w600,
    );
    if (flattened.isEmpty) {
      return InteractiveLineChartLayout(
        plotRect: Rect.fromLTWH(0, 0, size.width, size.height),
        xTicks: const [],
        yTicks: const [],
        points: const [],
      );
    }

    flattened.sort((a, b) => a.point.date.compareTo(b.point.date));
    final rawMinDate = flattened.first.point.date;
    final rawMaxDate = flattened.last.point.date;
    var minEpoch = rawMinDate.millisecondsSinceEpoch.toDouble();
    var maxEpoch = rawMaxDate.millisecondsSinceEpoch.toDouble();
    if ((maxEpoch - minEpoch).abs() < 1) {
      const day = Duration.millisecondsPerDay;
      minEpoch -= day;
      maxEpoch += day;
    }

    final values = flattened.map((item) => item.point.value).toList();
    final yScale = _NiceScale.fromValues(
      values,
      targetTickCount: size.height < 150 ? 3 : 4,
    );
    final yLabels = yScale.ticks.map(axisValueFormatter).toList();
    final maxYLabelWidth = yLabels.fold<double>(
      0,
      (current, label) =>
          math.max(current, _measureText(label, axisStyle).width),
    );
    final yTitle = unit.isEmpty ? yAxisLabel : '$yAxisLabel · $unit';
    final titleHeight = math.max(
      _measureText(yTitle, axisTitleStyle).height,
      _measureText(xAxisLabel, axisTitleStyle).height,
    );
    final tickHeight = yLabels.isEmpty
        ? 0.0
        : _measureText(yLabels.first, axisStyle).height;
    final left = math.min(
      size.width * 0.31,
      math.max(31.0, maxYLabelWidth + 10),
    );
    const right = 8.0;
    final top = titleHeight + 8;
    final bottom = tickHeight + titleHeight + 12;
    final plotRect = Rect.fromLTRB(
      left,
      top,
      math.max(left + 1, size.width - right),
      math.max(top + 1, size.height - bottom),
    );

    final xTickCount = plotRect.width < 230
        ? 2
        : plotRect.width < 390
        ? 3
        : 4;
    final xTicks = List<InteractiveLineChartTick<DateTime>>.generate(
      xTickCount,
      (index) {
        final ratio = xTickCount == 1 ? 0.5 : index / (xTickCount - 1);
        final epoch = minEpoch + (maxEpoch - minEpoch) * ratio;
        final date = DateTime.fromMillisecondsSinceEpoch(epoch.round());
        return InteractiveLineChartTick<DateTime>(
          value: date,
          label: axisDateFormatter(date),
          position: plotRect.left + plotRect.width * ratio,
        );
      },
      growable: false,
    );
    final yTicks = List<InteractiveLineChartTick<double>>.generate(
      yScale.ticks.length,
      (index) {
        final value = yScale.ticks[index];
        return InteractiveLineChartTick<double>(
          value: value,
          label: yLabels[index],
          position: _mapY(value, yScale.min, yScale.max, plotRect),
        );
      },
      growable: false,
    );

    final positions = <InteractiveLineChartPositionedPoint>[];
    for (var seriesIndex = 0; seriesIndex < series.length; seriesIndex++) {
      final item = series[seriesIndex];
      for (final point in item.points) {
        if (!point.value.isFinite) {
          continue;
        }
        positions.add(
          InteractiveLineChartPositionedPoint(
            selection: DatedChartSelection(series: item, point: point),
            offset: Offset(
              _mapX(
                point.date.millisecondsSinceEpoch.toDouble(),
                minEpoch,
                maxEpoch,
                plotRect,
              ),
              _mapY(point.value, yScale.min, yScale.max, plotRect),
            ),
            color: _seriesColor(theme, seriesIndex, item),
          ),
        );
      }
    }

    return InteractiveLineChartLayout(
      plotRect: plotRect,
      xTicks: xTicks,
      yTicks: yTicks,
      points: List.unmodifiable(positions),
      minDate: rawMinDate,
      maxDate: rawMaxDate,
      minY: yScale.min,
      maxY: yScale.max,
    );
  }

  DatedChartSelection? nearestSelection(
    Offset localPosition,
    Size size, {
    double tolerance = 44,
  }) {
    final layout = layoutFor(size);
    if (!layout.plotRect.inflate(tolerance).contains(localPosition)) {
      return null;
    }
    InteractiveLineChartPositionedPoint? nearest;
    var nearestDistance = double.infinity;
    for (final point in layout.points) {
      final distance = (point.offset - localPosition).distance;
      if (distance < nearestDistance) {
        nearest = point;
        nearestDistance = distance;
      }
    }
    return nearestDistance <= tolerance ? nearest?.selection : null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final layout = layoutFor(size);
    if (layout.isEmpty) {
      return;
    }
    final axisStyle = _chartTextStyle(
      theme,
      9,
      theme.fgMuted,
    ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
    final axisTitleStyle = _chartTextStyle(
      theme,
      9,
      theme.fgDim,
      FontWeight.w600,
    );
    final gridPaint = Paint()
      ..color = theme.chartGrid
      ..strokeWidth = 1;
    final axisPaint = Paint()
      ..color = theme.borderHi.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    for (final tick in layout.yTicks) {
      canvas.drawLine(
        Offset(layout.plotRect.left, tick.position),
        Offset(layout.plotRect.right, tick.position),
        gridPaint,
      );
      _paintText(
        canvas,
        tick.label,
        axisStyle,
        Offset(0, tick.position),
        maxWidth: layout.plotRect.left - 8,
        alignment: _ChartTextAlignment.rightCenter,
      );
    }
    for (final tick in layout.xTicks) {
      canvas.drawLine(
        Offset(tick.position, layout.plotRect.top),
        Offset(tick.position, layout.plotRect.bottom),
        gridPaint,
      );
    }
    canvas.drawLine(
      layout.plotRect.bottomLeft,
      layout.plotRect.topLeft,
      axisPaint,
    );
    canvas.drawLine(
      layout.plotRect.bottomLeft,
      layout.plotRect.bottomRight,
      axisPaint,
    );

    final yTitle = unit.isEmpty ? yAxisLabel : '$yAxisLabel · $unit';
    _paintText(
      canvas,
      yTitle,
      axisTitleStyle,
      Offset(layout.plotRect.left, 0),
      maxWidth: layout.plotRect.width * 0.72,
    );
    _paintText(
      canvas,
      xAxisLabel,
      axisTitleStyle,
      Offset(layout.plotRect.right, size.height),
      maxWidth: layout.plotRect.width * 0.45,
      alignment: _ChartTextAlignment.rightBottom,
    );
    for (var i = 0; i < layout.xTicks.length; i++) {
      final tick = layout.xTicks[i];
      final alignment = i == 0
          ? _ChartTextAlignment.leftTop
          : i == layout.xTicks.length - 1
          ? _ChartTextAlignment.rightTop
          : _ChartTextAlignment.centerTop;
      _paintText(
        canvas,
        tick.label,
        axisStyle,
        Offset(tick.position, layout.plotRect.bottom + 5),
        maxWidth: math.max(48, layout.plotRect.width / layout.xTicks.length),
        alignment: alignment,
      );
    }

    final selectedPosition = layout.points
        .where((item) => item.selection == selection)
        .firstOrNull;
    if (selectedPosition != null) {
      canvas.drawLine(
        Offset(selectedPosition.offset.dx, layout.plotRect.top),
        Offset(selectedPosition.offset.dx, layout.plotRect.bottom),
        Paint()
          ..color = selectedPosition.color.withValues(alpha: 0.28)
          ..strokeWidth = 1,
      );
    }

    canvas.save();
    canvas.clipRect(layout.plotRect.inflate(1));
    for (var seriesIndex = 0; seriesIndex < series.length; seriesIndex++) {
      final item = series[seriesIndex];
      final positions =
          layout.points
              .where((point) => point.selection.series.id == item.id)
              .toList()
            ..sort(
              (a, b) =>
                  a.selection.point.date.compareTo(b.selection.point.date),
            );
      if (positions.isEmpty) {
        continue;
      }
      final path = _pathFor(positions.map((item) => item.offset).toList());
      final color = _seriesColor(theme, seriesIndex, item);
      if (theme.chartStyle == FittinChartStyle.area) {
        final area = Path.from(path)
          ..lineTo(positions.last.offset.dx, layout.plotRect.bottom)
          ..lineTo(positions.first.offset.dx, layout.plotRect.bottom)
          ..close();
        canvas.drawPath(area, Paint()..color = color.withValues(alpha: 0.08));
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      for (final positioned in positions) {
        final isSelected = positioned.selection == selection;
        if (isSelected) {
          canvas.drawCircle(
            positioned.offset,
            7,
            Paint()
              ..color = theme.fg
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
        }
        canvas.drawCircle(
          positioned.offset,
          isSelected ? 4 : 3,
          Paint()..color = color,
        );
        canvas.drawCircle(
          positioned.offset,
          isSelected ? 1.7 : 1.2,
          Paint()..color = theme.surfaceSolid,
        );
      }
    }
    canvas.restore();
  }

  Path _pathFor(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      switch (theme.chartStyle) {
        case FittinChartStyle.step:
          final middle = previous.dx + (current.dx - previous.dx) / 2;
          path
            ..lineTo(middle, previous.dy)
            ..lineTo(middle, current.dy)
            ..lineTo(current.dx, current.dy);
        case FittinChartStyle.smooth:
          final middle = previous.dx + (current.dx - previous.dx) / 2;
          path.cubicTo(
            middle,
            previous.dy,
            middle,
            current.dy,
            current.dx,
            current.dy,
          );
        case FittinChartStyle.linear:
        case FittinChartStyle.area:
          path.lineTo(current.dx, current.dy);
      }
    }
    return path;
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder => (Size size) {
    final bounds = Offset.zero & size;
    final positions = layoutFor(size).points;
    return List<CustomPainterSemantics>.generate(positions.length, (index) {
      final positioned = positions[index];
      final label = _formatSelectionLabel(
        positioned.selection,
        unit: unit,
        dateFormatter: detailDateFormatter,
        valueFormatter: detailValueFormatter,
        formatter: pointLabelFormatter,
      );
      return CustomPainterSemantics(
        rect: Rect.fromCenter(
          center: positioned.offset,
          width: 44,
          height: 44,
        ).intersect(bounds),
        properties: SemanticsProperties(
          label: label,
          textDirection: textDirection,
          button: true,
          selected: positioned.selection == selection,
          sortKey: OrdinalSortKey(index.toDouble()),
          onTap: onPointSelected == null
              ? null
              : () => onPointSelected!(positioned.selection),
        ),
      );
    }, growable: false);
  };

  @override
  bool shouldRepaint(covariant InteractiveLineChartPainter oldDelegate) {
    return oldDelegate.theme != theme ||
        oldDelegate.series != series ||
        oldDelegate.selection != selection ||
        oldDelegate.xAxisLabel != xAxisLabel ||
        oldDelegate.yAxisLabel != yAxisLabel ||
        oldDelegate.unit != unit ||
        oldDelegate.textDirection != textDirection ||
        oldDelegate.textScaler != textScaler;
  }

  @override
  bool shouldRebuildSemantics(
    covariant InteractiveLineChartPainter oldDelegate,
  ) {
    return shouldRepaint(oldDelegate) ||
        oldDelegate.pointLabelFormatter != pointLabelFormatter;
  }

  Size _measureText(String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();
    return painter.size;
  }

  void _paintText(
    Canvas canvas,
    String text,
    TextStyle style,
    Offset anchor, {
    required double maxWidth,
    _ChartTextAlignment alignment = _ChartTextAlignment.leftTop,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      textScaler: textScaler,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: math.max(1, maxWidth));
    final offset = switch (alignment) {
      _ChartTextAlignment.leftTop => anchor,
      _ChartTextAlignment.centerTop => Offset(
        anchor.dx - painter.width / 2,
        anchor.dy,
      ),
      _ChartTextAlignment.rightTop => Offset(
        anchor.dx - painter.width,
        anchor.dy,
      ),
      _ChartTextAlignment.rightCenter => Offset(
        anchor.dx + maxWidth - painter.width,
        anchor.dy - painter.height / 2,
      ),
      _ChartTextAlignment.rightBottom => Offset(
        anchor.dx - painter.width,
        anchor.dy - painter.height,
      ),
    };
    painter.paint(canvas, offset);
  }
}

enum _ChartTextAlignment {
  leftTop,
  centerTop,
  rightTop,
  rightCenter,
  rightBottom,
}

@immutable
class _NiceScale {
  const _NiceScale({required this.min, required this.max, required this.ticks});

  factory _NiceScale.fromValues(
    List<double> values, {
    required int targetTickCount,
  }) {
    var rawMin = values.reduce(math.min);
    var rawMax = values.reduce(math.max);
    if ((rawMax - rawMin).abs() < 1e-9) {
      final padding = math.max(rawMin.abs() * 0.1, 1.0);
      rawMin -= padding;
      rawMax += padding;
    } else {
      final padding = (rawMax - rawMin) * 0.08;
      rawMin -= padding;
      rawMax += padding;
    }
    final roughStep = (rawMax - rawMin) / math.max(1, targetTickCount - 1);
    final step = _niceNumber(roughStep);
    final min = (rawMin / step).floorToDouble() * step;
    var max = (rawMax / step).ceilToDouble() * step;
    if (max <= min) {
      max = min + step;
    }
    final count = ((max - min) / step).round() + 1;
    final ticks = List<double>.generate(count, (index) {
      final value = min + step * index;
      return value.abs() < 1e-9 ? 0 : value;
    }, growable: false);
    return _NiceScale(min: min, max: max, ticks: ticks);
  }

  final double min;
  final double max;
  final List<double> ticks;

  static double _niceNumber(double value) {
    if (!value.isFinite || value <= 0) {
      return 1;
    }
    final exponent = math.pow(10, (math.log(value) / math.ln10).floor());
    final fraction = value / exponent;
    final niceFraction = switch (fraction) {
      <= 1 => 1.0,
      <= 2 => 2.0,
      <= 2.5 => 2.5,
      <= 5 => 5.0,
      _ => 10.0,
    };
    return niceFraction * exponent;
  }
}

double _mapX(double value, double min, double max, Rect plotRect) {
  final ratio = max == min ? 0.5 : (value - min) / (max - min);
  return plotRect.left + plotRect.width * ratio.clamp(0.0, 1.0);
}

double _mapY(double value, double min, double max, Rect plotRect) {
  final ratio = max == min ? 0.5 : (value - min) / (max - min);
  return plotRect.bottom - plotRect.height * ratio.clamp(0.0, 1.0);
}

String _formatSelectionLabel(
  DatedChartSelection selection, {
  required String unit,
  required ChartDateFormatter dateFormatter,
  required ChartValueFormatter valueFormatter,
  ChartPointLabelFormatter? formatter,
}) {
  final value = valueFormatter(selection.point.value);
  final date = dateFormatter(selection.point.date);
  final detail = selection.point.detail;
  if (formatter != null) {
    return formatter(selection.series.label, date, value, unit, detail);
  }
  final valueWithUnit = unit.isEmpty ? value : '$value $unit';
  return [
    selection.series.label,
    date,
    valueWithUnit,
    if (detail?.trim().isNotEmpty ?? false) detail!.trim(),
  ].join(' · ');
}

DatedChartSelection? _rebindSelection(
  List<DatedChartSeries> series,
  DatedChartSelection? selection,
) {
  if (selection == null) {
    return null;
  }
  for (final item in series) {
    if (item.id != selection.series.id) {
      continue;
    }
    for (final point in item.points) {
      if (point.date.millisecondsSinceEpoch ==
              selection.point.date.millisecondsSinceEpoch &&
          point.value == selection.point.value) {
        return DatedChartSelection(series: item, point: point);
      }
    }
  }
  return null;
}

BoxDecoration _chartDecoration(FittinTheme theme) {
  return BoxDecoration(
    color: theme.surfaceSolid,
    borderRadius: BorderRadius.circular(theme.radius),
    border: Border.all(color: theme.border),
  );
}

TextStyle _chartTextStyle(
  FittinTheme theme,
  double size,
  Color color, [
  FontWeight weight = FontWeight.w400,
]) {
  return TextStyle(
    fontFamily: theme.uiFontFamily,
    fontFamilyFallback: AppTypography.fontFamilyFallback,
    fontSize: size,
    fontWeight: weight,
    color: color,
  );
}

Color _seriesColor(
  FittinTheme theme,
  int seriesIndex,
  DatedChartSeries series,
) {
  if (series.color != null) {
    return series.color!;
  }
  if (seriesIndex <= 0) {
    return theme.chartStroke;
  }
  return InteractiveLineChartPainter._seriesPalette[seriesIndex %
      InteractiveLineChartPainter._seriesPalette.length];
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
