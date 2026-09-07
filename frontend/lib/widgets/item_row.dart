import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text.dart';

/// Fila de lista reutilizable: icono + título + subtítulo + contenido
/// a la derecha (precio, chip de estado, etc.) Objetivo táctil de al
/// menos 48dp de alto.
class ItemRow extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ItemRow({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: onTap != null,
      label: '$title, $subtitle',
      child: Material(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Container(
            constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: c.border),
            ),
            child: Row(
              children: [
                leading,
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyMedium.copyWith(color: c.textPrimary, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.label.copyWith(color: c.textSecondary, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: AppSpacing.sm), trailing!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Miniatura cuadrada redondeada con un icono Material — usada como
/// "leading" en [ItemRow] (piezas, ventas, compras, proveedores).
class ItemThumb extends StatelessWidget {
  final IconData icon;
  final Color? background;
  final Color? foreground;

  const ItemThumb({super.key, required this.icon, this.background, this.foreground});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background ?? c.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Icon(icon, size: 20, color: foreground ?? c.textPrimary),
    );
  }
}
