import 'package:material_ui/material_ui.dart';

/// Sombras cálidas y con desplazamiento: profundidad de papel, no halos.
abstract final class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x12A53A4B), blurRadius: 26, offset: Offset(0, 10)),
    BoxShadow(color: Color(0x0D33161D), blurRadius: 4, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> logo = [
    BoxShadow(color: Color(0x1F8A1230), blurRadius: 22, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> saveButton = [
    BoxShadow(color: Color(0x38C82F45), blurRadius: 22, offset: Offset(0, 10)),
  ];
}
