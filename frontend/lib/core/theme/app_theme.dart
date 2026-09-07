import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text.dart';

/// Tema visual "SPICY Tech-Speed" (rediseño 2026): tipografía Inter,
/// azul de marca, fondos claros neutros (o carbón real en oscuro),
/// esquinas moderadas y elevación casi nula — sin degradados grandes,
/// sin glow ni texturas. La paleta real vive en [SpicyColors]
/// (registrada aquí como [ThemeExtension] para claro y oscuro); este
/// archivo solo la conecta con los widgets estándar de Material.
class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(Color text, Color textSecondary) {
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
      displayLarge: AppTypography.display.copyWith(color: text),
      displayMedium: AppTypography.display.copyWith(color: text, fontSize: 24),
      headlineLarge: AppTypography.screenTitle.copyWith(color: text),
      headlineMedium: AppTypography.screenTitle.copyWith(color: text, fontSize: 20),
      headlineSmall: AppTypography.sectionTitle.copyWith(color: text),
      titleLarge: AppTypography.sectionTitle.copyWith(color: text),
      titleMedium: AppTypography.bodyMedium.copyWith(color: text, fontWeight: FontWeight.w700),
      titleSmall: AppTypography.label.copyWith(color: textSecondary),
      bodyLarge: AppTypography.bodyMedium.copyWith(color: text),
      bodyMedium: AppTypography.body.copyWith(color: text),
      bodySmall: AppTypography.label.copyWith(color: textSecondary, fontWeight: FontWeight.w500),
      labelLarge: AppTypography.label.copyWith(color: text),
      labelMedium: AppTypography.label.copyWith(color: textSecondary),
    );
  }

  static InputDecorationTheme _inputTheme(SpicyColors c) {
    OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: BorderSide(color: color, width: width),
        );
    return InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      isDense: false,
      constraints: const BoxConstraints(minHeight: AppSizes.inputHeight),
      hintStyle: AppTypography.body.copyWith(color: c.textSecondary),
      labelStyle: AppTypography.body.copyWith(color: c.textSecondary),
      helperStyle: AppTypography.label.copyWith(color: c.textSecondary),
      border: border(c.border),
      enabledBorder: border(c.border),
      focusedBorder: border(c.brandPrimary, 1.6),
      errorBorder: border(c.danger),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md + 2),
    );
  }

  static ThemeData _build({required Brightness brightness, required SpicyColors c}) {
    final scheme = brightness == Brightness.light
        ? ColorScheme.light(
            primary: c.brandPrimary,
            onPrimary: Colors.white,
            secondary: c.brandPrimaryDark,
            onSecondary: Colors.white,
            surface: c.surface,
            onSurface: c.textPrimary,
            error: c.danger,
          )
        : ColorScheme.dark(
            primary: c.brandPrimary,
            onPrimary: Colors.white,
            secondary: c.brandPrimaryDark,
            onSecondary: Colors.white,
            surface: c.surface,
            onSurface: c.textPrimary,
            error: c.danger,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      splashFactory: InkRipple.splashFactory,
      extensions: [c],
      textTheme: _textTheme(c.textPrimary, c.textSecondary),
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.screenTitle.copyWith(color: c.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: c.border),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      splashColor: c.brandPrimary.withOpacity(.08),
      highlightColor: Colors.transparent,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.brandPrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: c.surfaceAlt,
          disabledForegroundColor: c.textSecondary,
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.control)),
          textStyle: AppTypography.body.copyWith(fontWeight: FontWeight.w700, letterSpacing: .2),
          elevation: 0,
        ).copyWith(
          overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(.08)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.brandPrimary,
          disabledForegroundColor: c.textSecondary,
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          side: BorderSide(color: c.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.control)),
          textStyle: AppTypography.body.copyWith(fontWeight: FontWeight.w700, letterSpacing: .2),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.brandPrimary,
          minimumSize: const Size(0, AppSizes.minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.control)),
          textStyle: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      iconTheme: IconThemeData(color: c.textPrimary),
      inputDecorationTheme: _inputTheme(c),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceAlt,
        selectedColor: c.brandPrimary,
        labelStyle: AppTypography.label.copyWith(color: c.textPrimary),
        secondaryLabelStyle: AppTypography.label.copyWith(color: Colors.white),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        indicatorColor: c.brandPrimary.withOpacity(.14),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppTypography.label.copyWith(
            fontSize: 11,
            color: selected ? c.brandPrimary : c.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? c.brandPrimary : c.textSecondary);
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: c.surface,
        indicatorColor: c.brandPrimary.withOpacity(.14),
        selectedIconTheme: IconThemeData(color: c.brandPrimary),
        unselectedIconTheme: IconThemeData(color: c.textSecondary),
        selectedLabelTextStyle: AppTypography.label.copyWith(color: c.brandPrimary),
        unselectedLabelTextStyle: AppTypography.label.copyWith(color: c.textSecondary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? c.brandPrimary : c.surface,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? c.brandPrimary.withOpacity(.4) : c.surfaceAlt,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: c.textPrimary, borderRadius: BorderRadius.circular(6)),
        textStyle: AppTypography.label.copyWith(color: c.background, fontSize: 11),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.brandPrimary),
      visualDensity: VisualDensity.standard,
    );
  }

  static ThemeData light() => _build(brightness: Brightness.light, c: SpicyColors.light);
  static ThemeData dark() => _build(brightness: Brightness.dark, c: SpicyColors.dark);
}
