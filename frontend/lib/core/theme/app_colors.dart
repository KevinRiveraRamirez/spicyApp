import 'package:flutter/material.dart';

/// Paleta oficial "SPICY Tech-Speed" (rediseño 2026). Sustituye por
/// completo la identidad roja/negra anterior: azul de marca, fondos
/// claros neutros (o carbón real en modo oscuro), y colores
/// funcionales de estado (éxito/alerta/peligro/info) separados del
/// color de marca.
///
/// Los tokens crudos viven aquí (uno por variante clara/oscura). El
/// acceso normal desde las pantallas es a través de [SpicyColors] vía
/// `context.colors`, que ya resuelve claro/oscuro automáticamente
/// según el tema activo.
class AppColors {
  AppColors._();

  // Marca
  static const lightBrandPrimary = Color(0xFF003BFD);
  static const darkBrandPrimary = Color(0xFF4D74FF);
  static const lightBrandPrimaryDark = Color(0xFF002DBF);
  static const darkBrandPrimaryDark = Color(0xFF7694FF);

  // Fondos y superficies
  static const lightBackground = Color(0xFFF5F7FB);
  static const darkBackground = Color(0xFF090D16);
  static const lightSurface = Color(0xFFFFFFFF);
  static const darkSurface = Color(0xFF111827);
  static const lightSurfaceAlt = Color(0xFFEDF1F7);
  static const darkSurfaceAlt = Color(0xFF182234);

  // Texto
  static const lightTextPrimary = Color(0xFF101828);
  static const darkTextPrimary = Color(0xFFF8FAFC);
  static const lightTextSecondary = Color(0xFF667085);
  static const darkTextSecondary = Color(0xFF98A2B3);

  // Bordes
  static const lightBorder = Color(0xFFE4E7EC);
  static const darkBorder = Color(0xFF273449);

  // Estado (funcionales, no de marca)
  static const lightSuccess = Color(0xFF12B76A);
  static const darkSuccess = Color(0xFF32D583);
  static const lightWarning = Color(0xFFF79009);
  static const darkWarning = Color(0xFFFDB022);
  static const lightDanger = Color(0xFFF04438);
  static const darkDanger = Color(0xFFF97066);
  static const lightInfo = Color(0xFF2E90FA);
  static const darkInfo = Color(0xFF53B1FD);

  static const white = Color(0xFFFFFFFF);
}

/// Tokens de color como [ThemeExtension]: se registran una vez en
/// [AppTheme] (uno para claro, otro para oscuro) y de ahí en adelante
/// cualquier widget los lee ya resueltos con `context.colors.xxx`, sin
/// tener que preguntar `Theme.of(context).brightness` en cada pantalla.
@immutable
class SpicyColors extends ThemeExtension<SpicyColors> {
  final Color brandPrimary;
  final Color brandPrimaryDark;
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;

  const SpicyColors({
    required this.brandPrimary,
    required this.brandPrimaryDark,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
  });

  static const light = SpicyColors(
    brandPrimary: AppColors.lightBrandPrimary,
    brandPrimaryDark: AppColors.lightBrandPrimaryDark,
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    surfaceAlt: AppColors.lightSurfaceAlt,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    border: AppColors.lightBorder,
    success: AppColors.lightSuccess,
    warning: AppColors.lightWarning,
    danger: AppColors.lightDanger,
    info: AppColors.lightInfo,
  );

  static const dark = SpicyColors(
    brandPrimary: AppColors.darkBrandPrimary,
    brandPrimaryDark: AppColors.darkBrandPrimaryDark,
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    surfaceAlt: AppColors.darkSurfaceAlt,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    border: AppColors.darkBorder,
    success: AppColors.darkSuccess,
    warning: AppColors.darkWarning,
    danger: AppColors.darkDanger,
    info: AppColors.darkInfo,
  );

  @override
  SpicyColors copyWith({
    Color? brandPrimary,
    Color? brandPrimaryDark,
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
  }) {
    return SpicyColors(
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandPrimaryDark: brandPrimaryDark ?? this.brandPrimaryDark,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
    );
  }

  @override
  SpicyColors lerp(ThemeExtension<SpicyColors>? other, double t) {
    if (other is! SpicyColors) return this;
    return SpicyColors(
      brandPrimary: Color.lerp(brandPrimary, other.brandPrimary, t)!,
      brandPrimaryDark: Color.lerp(brandPrimaryDark, other.brandPrimaryDark, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

/// Acceso corto y centralizado a los tokens de color desde cualquier
/// widget: `context.colors.brandPrimary`, `context.colors.textPrimary`, etc.
/// Cae de vuelta a la paleta clara si por algún motivo el tema no
/// registró la extensión (no debería pasar, ver [AppTheme]).
extension SpicyColorsX on BuildContext {
  SpicyColors get colors => Theme.of(this).extension<SpicyColors>() ?? SpicyColors.light;
}
