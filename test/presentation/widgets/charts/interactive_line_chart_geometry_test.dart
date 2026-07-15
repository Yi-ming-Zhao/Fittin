import 'dart:ui';

import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:fittin_v2/src/presentation/widgets/charts/interactive_line_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('InteractiveLineChartPainter geometry', () {
    test('empty data has a safe empty layout', () {
      final painter = _painter(const []);
      final layout = painter.layoutFor(const Size(360, 170));

      expect(layout.isEmpty, isTrue);
      expect(layout.points, isEmpty);
      expect(layout.xTicks, isEmpty);
      expect(layout.yTicks, isEmpty);
      expect(
        painter.nearestSelection(const Offset(180, 80), const Size(360, 170)),
        isNull,
      );
    });

    test(
      'a single point is centered inside expanded date and value domains',
      () {
        final point = DatedChartPoint(date: DateTime(2026, 4, 5), value: 100);
        final painter = _painter([
          DatedChartSeries(id: 'bench', label: 'Bench', points: [point]),
        ]);
        final layout = painter.layoutFor(const Size(360, 170));

        expect(layout.points, hasLength(1));
        expect(layout.minY, lessThan(100));
        expect(layout.maxY, greaterThan(100));
        expect(layout.xTicks, hasLength(3));
        expect(layout.yTicks.length, greaterThanOrEqualTo(3));
        expect(
          layout.points.single.offset.dx,
          closeTo(layout.plotRect.center.dx, 0.001),
        );
        expect(
          layout.points.single.offset.dy,
          closeTo(layout.plotRect.center.dy, 0.001),
        );
      },
    );

    test('constant values keep finite positions and a non-zero y domain', () {
      final painter = _painter([
        DatedChartSeries(
          id: 'weight',
          label: 'Weight',
          points: [
            DatedChartPoint(date: DateTime(2026, 1, 1), value: 82),
            DatedChartPoint(date: DateTime(2026, 1, 4), value: 82),
            DatedChartPoint(date: DateTime(2026, 1, 8), value: 82),
          ],
        ),
      ]);
      final layout = painter.layoutFor(const Size(360, 170));

      expect(layout.minY, lessThan(82));
      expect(layout.maxY, greaterThan(82));
      expect(layout.points, hasLength(3));
      final constantY = layout.points.first.offset.dy;
      for (final positioned in layout.points) {
        expect(positioned.offset.dx.isFinite, isTrue);
        expect(positioned.offset.dy.isFinite, isTrue);
        expect(positioned.offset.dy, closeTo(constantY, 0.001));
        expect(
          layout.plotRect.inflate(0.001).contains(positioned.offset),
          isTrue,
        );
      }
    });

    test('irregular dates use elapsed time rather than list index spacing', () {
      final painter = _painter([
        DatedChartSeries(
          id: 'squat',
          label: 'Squat',
          points: [
            DatedChartPoint(date: DateTime(2026, 1, 1), value: 100),
            DatedChartPoint(date: DateTime(2026, 1, 2), value: 102),
            DatedChartPoint(date: DateTime(2026, 1, 10), value: 110),
          ],
        ),
      ]);
      final points = painter
          .layoutFor(const Size(360, 170))
          .points
          .map((point) => point.offset)
          .toList();

      final firstGap = points[1].dx - points[0].dx;
      final secondGap = points[2].dx - points[1].dx;
      expect(firstGap, greaterThan(0));
      expect(secondGap / firstGap, closeTo(8, 0.05));
    });

    test('multiple series retain every point and distinct warm colors', () {
      final painter = _painter([
        DatedChartSeries(
          id: 'squat',
          label: 'Squat',
          points: [
            DatedChartPoint(date: DateTime(2026, 1, 1), value: 100),
            DatedChartPoint(date: DateTime(2026, 1, 2), value: 105),
          ],
        ),
        DatedChartSeries(
          id: 'deadlift',
          label: 'Deadlift',
          points: [
            DatedChartPoint(date: DateTime(2026, 1, 1), value: 140),
            DatedChartPoint(date: DateTime(2026, 1, 2), value: 145),
          ],
        ),
      ]);
      final positions = painter.layoutFor(const Size(360, 170)).points;

      expect(positions, hasLength(4));
      expect(positions.map((point) => point.color).toSet(), hasLength(2));
      for (final color in positions.map((point) => point.color)) {
        expect(_isCyanOrTeal(color), isFalse);
      }
    });

    test(
      '360px chart reserves readable measured gutters and bounded ticks',
      () {
        final painter = _painter([
          DatedChartSeries(
            id: 'body-weight',
            label: 'Body weight',
            points: [
              DatedChartPoint(date: DateTime(2026, 1, 1), value: 1234.5),
              DatedChartPoint(date: DateTime(2026, 3, 1), value: 1400.5),
            ],
          ),
        ], axisValueFormatter: (value) => value.toStringAsFixed(1));
        final layout = painter.layoutFor(const Size(360, 170));

        expect(layout.plotRect.left, greaterThan(31));
        expect(layout.plotRect.right, lessThanOrEqualTo(352));
        expect(layout.plotRect.width, greaterThan(220));
        expect(layout.xTicks.length, lessThanOrEqualTo(3));
        expect(layout.plotRect.height, greaterThan(90));
      },
    );

    test('nearest point selection uses a 44px tolerance', () {
      final painter = _painter([
        DatedChartSeries(
          id: 'bench',
          label: 'Bench',
          points: [DatedChartPoint(date: DateTime(2026, 4, 5), value: 105)],
        ),
      ]);
      const size = Size(360, 170);
      final center = painter.layoutFor(size).points.single.offset;

      expect(
        painter.nearestSelection(center + const Offset(43, 0), size),
        isNotNull,
      );
      expect(
        painter.nearestSelection(center + const Offset(45, 0), size),
        isNull,
      );
    });

    test(
      'painting sparse and multi-series data completes without exceptions',
      () {
        final painter = _painter([
          DatedChartSeries(
            id: 'squat',
            label: 'Squat',
            points: [DatedChartPoint(date: DateTime(2026, 1, 1), value: 100)],
          ),
          DatedChartSeries(
            id: 'bench',
            label: 'Bench',
            points: [
              DatedChartPoint(date: DateTime(2026, 1, 2), value: 80),
              DatedChartPoint(date: DateTime(2026, 3, 2), value: 90),
            ],
          ),
        ]);
        final recorder = PictureRecorder();

        painter.paint(Canvas(recorder), const Size(360, 170));

        expect(recorder.endRecording(), isA<Picture>());
      },
    );
  });
}

InteractiveLineChartPainter _painter(
  List<DatedChartSeries> series, {
  ChartValueFormatter? axisValueFormatter,
}) {
  return InteractiveLineChartPainter(
    theme: FittinTheme.resolve(
      direction: FittinDirection.technical,
      accent: FittinAccent.ember,
      chart: FittinChartStyle.linear,
    ),
    series: series,
    xAxisLabel: 'Date',
    yAxisLabel: 'Load',
    unit: 'kg',
    axisDateFormatter: (date) => '${date.month}/${date.day}',
    detailDateFormatter: (date) => '${date.year}-${date.month}-${date.day}',
    axisValueFormatter:
        axisValueFormatter ?? (value) => value.toStringAsFixed(0),
    detailValueFormatter: (value) => value.toStringAsFixed(1),
    textDirection: TextDirection.ltr,
  );
}

bool _isCyanOrTeal(Color color) {
  final hsl = HSLColor.fromColor(color);
  return hsl.saturation > 0.12 && hsl.hue >= 130 && hsl.hue <= 200;
}
