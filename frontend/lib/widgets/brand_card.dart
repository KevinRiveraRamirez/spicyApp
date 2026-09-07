import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text.dart';

/// Tarjeta de contenido estándar (sucesora de la vieja "BrandCard" que
/// vivía sobre el fondo rojo de marca): superficie neutra, borde
/// sutil, título y acción opcional. Es el contenedor por defecto para
/// cualquier bloque de una pantalla (gráfico, sección de movimientos,
/// resumen, etc.)
class ContentCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final Widget? action;
  final EdgeInsets padding;

  const ContentCard({
    super.key,
    this.title,
    required this.child,
    this.action,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title!, style: AppTypography.sectionTitle.copyWith(color: c.textPrimary, fontSize: 15)),
                if (action != null) action!,
              ],
            ),
          if (title != null) const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}
