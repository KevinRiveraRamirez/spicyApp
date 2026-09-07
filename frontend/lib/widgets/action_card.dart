import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text.dart';

/// Acceso rápido a una acción frecuente (Nueva venta, Agregar producto,
/// Nueva compra...). En móvil se acomodan en fila bajo el saludo del
/// Inicio; siempre con objetivo táctil de al menos 48dp.
class ActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool emphasized;

  const ActionCard({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final bg = emphasized ? c.brandPrimary : c.surface;
    final fg = emphasized ? Colors.white : c.textPrimary;

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Container(
            constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: emphasized ? null : Border.all(color: c.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: fg),
                const SizedBox(width: AppSpacing.sm),
                // Flexible + ellipsis: nunca desborda aunque la tarjeta
                // quede angosta (3 en fila en un teléfono chico).
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium.copyWith(color: fg, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
