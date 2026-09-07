import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text.dart';
import 'spicy_buttons.dart';

/// Estado vacío real (sin datos todavía) — icono Material, título,
/// ayuda opcional y, si se provee, una acción primaria directa (no se
/// queda solo en explicar que no hay datos). Contenido dentro de un
/// ancho máximo para no perderse en pantallas grandes, y ancho
/// completo (dentro del padding del contenedor) en móvil.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final IconData? secondaryIcon;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
    this.secondaryLabel,
    this.onSecondary,
    this.secondaryIcon,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl, horizontal: AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: c.surfaceAlt, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Icon(icon, size: 26, color: c.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(title, style: AppTypography.sectionTitle.copyWith(color: c.textPrimary), textAlign: TextAlign.center),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle!, style: AppTypography.body.copyWith(color: c.textSecondary), textAlign: TextAlign.center),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    PrimaryButton(label: actionLabel!, icon: actionIcon, onPressed: onAction),
                    if (secondaryLabel != null && onSecondary != null)
                      SecondaryButton(label: secondaryLabel!, icon: secondaryIcon, onPressed: onSecondary),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
