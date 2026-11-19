import 'package:flutter/widgets.dart';

/// Radios de borde: papel recortado, esquinas generosas y nunca afiladas.
abstract final class AppRadii {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 22;
  static const double xl = 26;
  static const double sheet = 30;

  static const BorderRadius card = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius button = BorderRadius.all(Radius.circular(18));
  static const BorderRadius input = BorderRadius.all(Radius.circular(md));
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}
