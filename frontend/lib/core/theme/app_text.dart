import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Escala tipográfica del rediseño 2026 — Inter para toda la interfaz.
/// El carácter "Tech-Speed" (el wordmark angular) queda reservado
/// únicamente para el logotipo; ningún titular de contenido usa
/// itálica ni la tipografía de marca.
///
/// Estos estilos no incluyen color: cada pantalla aplica el color con
/// `.copyWith(color: context.colors.textPrimary)` (o el que
/// corresponda), para que la misma escala sirva en claro y oscuro.
class AppTypography {
  AppTypography._();

  static TextStyle get display => GoogleFonts.inter(fontSize: 28, height: 34 / 28, fontWeight: FontWeight.w700);

  static TextStyle get screenTitle => GoogleFonts.inter(fontSize: 22, height: 28 / 22, fontWeight: FontWeight.w700);

  static TextStyle get sectionTitle => GoogleFonts.inter(fontSize: 17, height: 24 / 17, fontWeight: FontWeight.w700);

  static TextStyle get body => GoogleFonts.inter(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400);

  static TextStyle get bodyMedium => GoogleFonts.inter(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500);

  static TextStyle get label => GoogleFonts.inter(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w600);

  /// Para valores numéricos destacados (KPIs, totales): usa números
  /// tabulares para que las cifras no "bailen" al cambiar de valor.
  static TextStyle get metric => GoogleFonts.inter(
        fontSize: 24,
        height: 30 / 24,
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
