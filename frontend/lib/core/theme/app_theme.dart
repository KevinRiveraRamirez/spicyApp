import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Tema visual de SPICY: tipografía Lato como marca el manual
/// (Black Italic para titulares, Bold para subtítulos, Regular
/// para cuerpo de texto), esquinas ligeramente cuadradas y alto
/// contraste rojo / negro / blanco.
class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(Color text, Color textDim) {
    final base = GoogleFonts.latoTextTheme();
    return base.copyWith(
      // Titulares grandes: Lato Black Italic (impacto, como el logotipo)
      displayLarge: GoogleFonts.lato(
        fontSize: 26, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: text,
      ),
      headlineLarge: GoogleFonts.lato(
        fontSize: 22, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: text,
      ),
      headlineMedium: GoogleFonts.lato(
        fontSize: 19, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: text,
      ),
      // Subtítulos: Lato Bold, no itálica, en mayúsculas con tracking
      titleLarge: GoogleFonts.lato(
        fontSize: 15, fontWeight: FontWeight.w700, color: text,
      ),
      titleMedium: GoogleFonts.lato(
        fontSize: 13.5, fontWeight: FontWeight.w700, color: text, letterSpacing: .3,
      ),
      titleSmall: GoogleFonts.lato(
        fontSize: 11.5, fontWeight: FontWeight.w700, color: textDim, letterSpacing: .6,
      ),
      // Cuerpo: Lato Regular
      bodyLarge: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w400, color: text),
      bodyMedium: GoogleFonts.lato(fontSize: 13, fontWeight: FontWeight.w400, color: text),
      bodySmall: GoogleFonts.lato(fontSize: 11.5, fontWeight: FontWeight.w400, color: textDim),
      labelLarge: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w700, color: text),
    );
  }

  static ThemeData light() {
    const scheme = ColorScheme.light(
      primary: AppColors.spicyRed,
      onPrimary: AppColors.white,
      secondary: AppColors.carbon,
      onSecondary: AppColors.white,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightText,
      error: AppColors.spicyRed,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.lightBg,
      textTheme: _textTheme(AppColors.lightText, AppColors.lightTextDim),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBg,
        foregroundColor: AppColors.lightText,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
      ),
      dividerColor: AppColors.lightBorder,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.spicyRed,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          textStyle: GoogleFonts.lato(fontWeight: FontWeight.w700, letterSpacing: .4),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.spicyRed, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.spicyRed,
        unselectedItemColor: AppColors.lightTextDim,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }

  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      primary: AppColors.spicyRed,
      onPrimary: AppColors.white,
      secondary: AppColors.bone,
      onSecondary: AppColors.carbon,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkText,
      error: AppColors.spicyRed,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.darkBg,
      textTheme: _textTheme(AppColors.darkText, AppColors.darkTextDim),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBg,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
      dividerColor: AppColors.darkBorder,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.spicyRed,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          textStyle: GoogleFonts.lato(fontWeight: FontWeight.w700, letterSpacing: .4),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.spicyRed, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.spicyRed,
        unselectedItemColor: AppColors.darkTextDim,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}
