/// Sistema espacial centralizado del rediseño 2026. Evita valores de
/// padding/margin sueltos repartidos por cada pantalla — cualquier
/// separación en la UI debería salir de aquí.
class AppSpacing {
  AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
  static const huge = 40.0;
}

/// Radios de esquina: controles pequeños, tarjetas, y hojas/modales
/// grandes usan cada uno su propio radio consistente en toda la app.
class AppRadius {
  AppRadius._();

  static const control = 10.0;
  static const card = 14.0;
  static const sheet = 20.0;
}

/// Medidas fijas de accesibilidad/ergonomía táctil y layout.
class AppSizes {
  AppSizes._();

  static const minTouchTarget = 48.0;
  static const buttonHeight = 52.0;
  static const inputHeight = 52.0;
  static const maxContentWidth = 1280.0;

  // Breakpoints responsive (dp de ancho de pantalla).
  static const breakpointTablet = 600.0;
  static const breakpointDesktop = 1024.0;

  // Navegación
  static const sidebarExpandedWidth = 220.0;
  static const sidebarCollapsedWidth = 80.0;
  static const contentHeaderHeight = 64.0;
}

/// Duraciones y curvas de movimiento estándar — el movimiento debe
/// orientar, no ser espectáculo (ver manual de rediseño 2026).
class AppMotion {
  AppMotion._();

  static const tabChange = Duration(milliseconds: 200);
  static const sheetOpen = Duration(milliseconds: 280);
  static const cardStagger = Duration(milliseconds: 350);
  static const pressedScale = Duration(milliseconds: 90);
  static const chipSelect = Duration(milliseconds: 160);
  static const numberChange = Duration(milliseconds: 200);
  static const hoverElevate = Duration(milliseconds: 160);
}
