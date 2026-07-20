import 'package:flutter/material.dart';

/// Paleta oficial de SPICY Streetwear Co. — Manual de marca 2026.
/// Rojo, negro y blanco como base (alto contraste, directo, veloz);
/// hueso y gris asfalto como apoyo. Proporción recomendada por el
/// manual: 60% rojo/negro, 30% blanco, 10% hueso/gris.
class AppColors {
  AppColors._();

  static const spicyRed = Color(0xFFE4131A);
  static const spicyRedDark = Color(0xFFB10E14);
  static const carbon = Color(0xFF111111);
  static const white = Color(0xFFFFFFFF);
  static const bone = Color(0xFFF3EEE6);
  static const asphalt = Color(0xFF4A4A4A);

  // Colores funcionales (fuera del manual, uso exclusivo de UI/estado)
  static const success = Color(0xFF1FAE6E);
  static const warning = spicyRed;

  // Tema claro — fondo blanco puro (30% del manual de marca), el hueso
  // se reserva para acentos/superficies secundarias, no como fondo base.
  static const lightBg = white;
  static const lightSurface = white;
  static const lightSurfaceAlt = Color(0xFFEAE3D6);
  static const lightBorder = Color(0xFFE1D8C8);
  static const lightText = carbon;
  static const lightTextDim = asphalt;

  // Tema oscuro
  static const darkBg = carbon;
  static const darkSurface = Color(0xFF1B1B1B);
  static const darkSurfaceAlt = Color(0xFF242424);
  static const darkBorder = Color(0xFF2E2E2E);
  static const darkText = bone;
  static const darkTextDim = Color(0xFFA3A3A3);
}