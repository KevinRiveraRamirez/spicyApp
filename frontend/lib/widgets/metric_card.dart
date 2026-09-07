import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text.dart';

/// Tarjeta compacta de indicador (KPI): icono pequeño, etiqueta, valor
/// destacado (números tabulares) y una comparación breve opcional. No
/// es una tarjeta blanca gigante — pensada para ir en fila (scroll
/// horizontal en teléfono, 3-4 columnas en escritorio).
class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? delta;
  final bool deltaPositive;
  final IconData icon;
  final Color? valueColor;
  final VoidCallback? onTap;
  final double? width;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.delta,
    this.deltaPositive = true,
    this.valueColor,
    this.onTap,
    this.width = 168,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final deltaColor = deltaPositive ? c.success : c.danger;

    return Semantics(
      label: '$label: $value${delta != null ? ', $delta' : ''}',
      button: onTap != null,
      child: Material(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Container(
            width: width,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: c.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: c.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.label.copyWith(color: c.textSecondary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.metric.copyWith(color: valueColor ?? c.textPrimary),
                ),
                if (delta != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(delta!, style: AppTypography.label.copyWith(color: deltaColor)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
