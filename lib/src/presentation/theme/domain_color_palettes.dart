import 'package:flutter/material.dart';

/// Fixed physical-equipment colors. These are intentionally independent of
/// the selected app appearance so standardized plate identification remains
/// recognizable.
abstract final class OlympicEquipmentPalette {
  static const Color shaftDark = Color(0xFF5E6367);
  static const Color shaftLight = Color(0xFFE1E3E4);
  static const Color shaftMid = Color(0xFF777C80);
  static const Color sleeveDark = Color(0xFF676C70);
  static const Color sleeveLight = Color(0xFFD6D9DB);
  static const Color collar = Color(0xFFBFC3C6);

  static const Color plate25 = Color(0xFFB94A48);
  static const Color plate20 = Color(0xFF416F9F);
  static const Color plate15 = Color(0xFFC3A74A);
  static const Color plate10 = Color(0xFF4E7A45);
  static const Color plate5 = Color(0xFFD8D5CC);
  static const Color plate2_5 = Color(0xFF292A2C);
  static const Color plateNeutral = Color(0xFFA7ADB2);
  static const Color changePlate = Color(0xFF858B90);

  static const Color labelLight = Color(0xFFFFFFFF);
  static const Color labelDark = Color(0xFF17191B);
}

/// Fixed colors for exported/shareable artwork. Exported output must remain
/// predictable and printable regardless of the user's live appearance.
abstract final class ExportPalette {
  static const Color canvas = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF111111);
  static const Color mutedInk = Color(0xFF66615A);
  static const Color rule = Color(0xFFD8D3CC);
  static const Color qrForeground = Color(0xFF000000);
  static const Color qrBackground = Color(0xFFFFFFFF);
}
