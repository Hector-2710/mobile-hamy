import 'package:material_ui/material_ui.dart';

/// Paleta de Juntos, extraída del logotipo de la fresa y la guinda.
///
/// El papel crema es el fondo de todas las superficies; la fresa es el acento
/// de acción, la guinda la profundidad editorial y la hoja el verde de apoyo.
/// Usar estos tokens en lugar de hex literales en widgets.
abstract final class AppColors {
  // Fondos / superficies (papel crema)
  static const Color bg = Color(0xFFFBF4EA);
  static const Color surface = Color(0xFFFFFCF7);
  static const Color surfaceAlt = Color(0xFFF7EADF);
  static const Color surfaceMuted = Color(0xFFF1E2D5);
  static const Color surfaceMutedPressed = Color(0xFFE7D3C2);
  static const Color imagePlaceholder = Color(0xFFF3E3D7);
  static const Color imagePlaceholderAlt = Color(0xFFF8ECDF);

  // Texto (tinta ciruela)
  static const Color textPrimary = Color(0xFF33161D);
  static const Color textSecondary = Color(0xFF7A5B5F);
  static const Color textTertiary = Color(0xFF5B3C42);
  static const Color textBody = Color(0xFF5E4449);
  static const Color textMeta = Color(0xFF6E5458);
  static const Color textIconMuted = Color(0xFF5A3D43);
  static const Color textLabel = Color(0xFF7F6165);
  static const Color textMuted = Color(0xFF7C5F63);
  static const Color textMutedAlt = Color(0xFF84676B);
  static const Color textMutedSoft = Color(0xFFA5888A);
  static const Color textHint = Color(0xFF83686C);
  static const Color textPlaceholder = Color(0xFF7E6368);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Bordes / divisores
  static const Color borderSubtle = Color(0xFFF0E1D5);
  static const Color border = Color(0xFFE5D2C3);
  static const Color borderLight = Color(0xFFDDC7B7);
  static const Color borderSoft = Color(0xFFEAD8C9);
  static const Color borderSheet = Color(0xFFEADACB);
  static const Color borderInput = Color(0xFFD8C0B0);

  // Acento principal (fresa)
  static const Color accent = Color(0xFFC82F45);
  static const Color accentHover = Color(0xFFB3233A);
  static const Color accentPressed = Color(0xFF9E1C32);
  static const Color accentEmphasis = Color(0xFFD8394F);
  static const Color accentSoft = Color(0xFFE88897);
  static const Color accentGlow = Color(0xFFF5CDD3);

  // Acentos secundarios (guinda y hoja)
  static const Color cherry = Color(0xFF8A1230);
  static const Color cherryDeep = Color(0xFF5E0B20);
  static const Color leaf = Color(0xFF5C8A44);
  static const Color leafDeep = Color(0xFF3F6A2E);
  static const Color leafSoft = Color(0xFFDDE8D3);
  static const Color blush = Color(0xFFF9DFE2);

  // Oscuros / overlays
  static const Color ink = Color(0xFF2A1016);
  static const Color overlay = Color(0xFF1B0C11);

  // Selección
  static const Color selectionBg = Color(0xFFF6C9CF);
  static const Color selectionText = Color(0xFF4A131E);

  // Estados / semánticos
  static const Color error = Color(0xFFA32A2D);
  static const Color dangerHover = Color(0xFF8C1F24);
  static const Color errorSurface = Color(0xFFF9E3E1);
}
