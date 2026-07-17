import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/weight_tools.dart';
import 'package:fittin_v2/src/presentation/theme/domain_color_palettes.dart';
import 'package:flutter/material.dart';

class BarbellPlatePreview extends StatelessWidget {
  const BarbellPlatePreview({
    super.key,
    required this.breakdown,
    required this.semanticLabel,
    this.height = 72,
  });

  final PlateBreakdownResult breakdown;
  final String semanticLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    final plates = <double>[
      for (final plate in breakdown.platesPerSide)
        for (var index = 0; index < plate.count; index++) plate.weight,
    ]..sort((a, b) => b.compareTo(a));

    return Semantics(
      image: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: SizedBox(
          key: const ValueKey('weight-tools-barbell-preview'),
          height: height,
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: 300,
              height: height,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 286,
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          OlympicEquipmentPalette.shaftDark,
                          OlympicEquipmentPalette.shaftLight,
                          OlympicEquipmentPalette.shaftDark,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final plate in plates.reversed)
                        _PreviewPlate(weight: plate, unit: breakdown.unit),
                      const _PreviewCollar(),
                      const SizedBox(width: 116),
                      const _PreviewCollar(),
                      for (final plate in plates)
                        _PreviewPlate(weight: plate, unit: breakdown.unit),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewPlate extends StatelessWidget {
  const _PreviewPlate({required this.weight, required this.unit});

  final double weight;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final normalized = unit == LoadUnits.lbs ? weight / 45 : weight / 20;
    final plateHeight = (30 + normalized.clamp(0.0, 1.0) * 24).toDouble();
    final plateWidth = weight >= (unit == LoadUnits.lbs ? 35 : 15) ? 10.0 : 7.0;
    return Container(
      width: plateWidth,
      height: plateHeight,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: _plateColor(weight, unit),
        borderRadius: BorderRadius.circular(2.5),
        border: Border.all(
          color: OlympicEquipmentPalette.labelLight.withValues(alpha: 0.22),
          width: 0.7,
        ),
      ),
    );
  }
}

class _PreviewCollar extends StatelessWidget {
  const _PreviewCollar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: OlympicEquipmentPalette.collar,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

Color _plateColor(double weight, String unit) {
  if (unit == LoadUnits.lbs) {
    return OlympicEquipmentPalette.changePlate;
  }
  return switch (weight) {
    25 => OlympicEquipmentPalette.plate25,
    20 => OlympicEquipmentPalette.plate20,
    15 => OlympicEquipmentPalette.plate15,
    10 => OlympicEquipmentPalette.plate10,
    5 => OlympicEquipmentPalette.plate5,
    2.5 => OlympicEquipmentPalette.plate2_5,
    _ => OlympicEquipmentPalette.plateNeutral,
  };
}
