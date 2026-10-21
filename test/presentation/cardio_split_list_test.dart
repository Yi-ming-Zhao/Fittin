import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/domain/models/cardio_recording.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:fittin_v2/src/presentation/widgets/cardio_split_list.dart';

void main() {
  const laps = [
    CardioLap(
      distanceMeters: 1000,
      activeMilliseconds: 300000,
      endDistanceMeters: 1000,
      automatic: true,
    ),
    CardioLap(
      distanceMeters: 400,
      activeMilliseconds: 96000,
      endDistanceMeters: 1400,
      automatic: false,
    ),
  ];

  test(
    'duration rounds at minute boundaries without invalid sixty seconds',
    () {
      expect(cardioDurationLabel(3599.9), '1:00:00');
      expect(cardioDurationLabel(59.9), '1:00');
      expect(cardioDurationLabel(double.nan), '—');
    },
  );

  testWidgets('split pace uses its own distance and cycling uses speed', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: CardioSplitList(laps: laps, chinese: false)),
      ),
    );
    expect(find.text('4:00'), findsOneWidget);
    expect(find.text('1:36'), findsOneWidget);
    expect(find.text('Lap 1 · Auto'), findsOneWidget);
    expect(find.text('Lap 2'), findsOneWidget);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CardioSplitList(laps: laps, chinese: false, cycling: true),
        ),
      ),
    );
    expect(find.text('15.0'), findsOneWidget);
    expect(find.text('12.0'), findsOneWidget);
    expect(find.text('Speed · km/h'), findsNWidgets(2));
  });

  testWidgets('all palettes fit 320px with large bilingual split labels', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final palette in FittinPaletteRegistry.ids) {
      for (final chinese in [false, true]) {
        for (final cycling in [false, true]) {
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(
                colorScheme: FittinPaletteRegistry.themeOf(palette).colorScheme,
              ),
              home: MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(1.8)),
                child: Scaffold(
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: CardioSplitList(
                      laps: laps,
                      chinese: chinese,
                      cycling: cycling,
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          expect(
            tester.takeException(),
            isNull,
            reason: '$palette/$chinese/$cycling',
          );
        }
      }
    }
  });
}
