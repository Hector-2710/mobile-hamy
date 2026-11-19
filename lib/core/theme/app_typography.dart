import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tipografía de Juntos: DM Serif Display para lo que se recuerda
/// (portada, meses, títulos) y Manrope para lo que se pulsa (UI, cuerpo).
abstract final class AppTypography {
  static String get sansFamily => GoogleFonts.manrope().fontFamily!;
  static String get serifFamily => GoogleFonts.dmSerifDisplay().fontFamily!;

  static TextTheme textTheme(ColorScheme colorScheme) {
    final base = GoogleFonts.manropeTextTheme();
    return base.copyWith(
      displaySmall: GoogleFonts.dmSerifDisplay(
        fontSize: 36,
        height: 1.04,
        letterSpacing: -1.0,
        color: AppColors.textPrimary,
      ),
      headlineMedium: GoogleFonts.dmSerifDisplay(
        fontSize: 27,
        height: 1.05,
        letterSpacing: -0.7,
        color: AppColors.textPrimary,
      ),
      headlineSmall: GoogleFonts.dmSerifDisplay(
        fontSize: 24,
        height: 1.12,
        letterSpacing: -0.4,
        color: AppColors.textPrimary,
      ),
      titleLarge: GoogleFonts.dmSerifDisplay(
        fontSize: 20,
        height: 1.2,
        letterSpacing: -0.2,
        color: AppColors.textPrimary,
      ),
      titleMedium: GoogleFonts.dmSerifDisplay(
        fontSize: 18,
        height: 1.2,
        letterSpacing: -0.1,
        color: AppColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: AppColors.textBody,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.55,
        color: AppColors.textSecondary,
      ),
      bodySmall: GoogleFonts.manrope(
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
        height: 1.45,
        color: AppColors.textMeta,
      ),
      labelLarge: GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
        color: AppColors.textPrimary,
      ),
      labelMedium: GoogleFonts.manrope(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textBody,
      ),
      labelSmall: GoogleFonts.manrope(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        color: AppColors.textMuted,
      ),
    );
  }

  static TextStyle get heroEmphasis => GoogleFonts.dmSerifDisplay(
    fontSize: 36,
    height: 1.04,
    letterSpacing: -1.0,
    fontStyle: FontStyle.italic,
    color: AppColors.accentEmphasis,
  );

  static TextStyle get cardTitle => GoogleFonts.dmSerifDisplay(
    fontSize: 20,
    height: 1.2,
    letterSpacing: -0.2,
    color: AppColors.textOnDark,
  );

  static TextStyle get detailTitle => GoogleFonts.dmSerifDisplay(
    fontSize: 38,
    height: 1.04,
    letterSpacing: -1.0,
    color: AppColors.textOnDark,
  );

  static TextStyle get modalTitle => GoogleFonts.dmSerifDisplay(
    fontSize: 26,
    height: 1.08,
    letterSpacing: -0.4,
    color: AppColors.textPrimary,
  );

  static TextStyle get inputSerif => GoogleFonts.dmSerifDisplay(
    fontSize: 21,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  static TextStyle get metaOnLight => GoogleFonts.manrope(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMeta,
  );

  static TextStyle get metaOnImage => GoogleFonts.manrope(
    fontSize: 10.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: Colors.white.withValues(alpha: 0.84),
  );

  static TextStyle get detailMeta => GoogleFonts.manrope(
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: Colors.white.withValues(alpha: 0.8),
  );
}
