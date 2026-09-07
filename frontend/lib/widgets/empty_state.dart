import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text.dart';

/// Estado vacío real (sin datos todavía) — icono Material, título y
/// ayuda opcional. Reemplaza los emojis de la versión anterior.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const EmptyState({super.key, required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.huge, horizontal: AppSpacing.xl),
      child: Column(
        children: [
          Icon(icon, size: 36, color: c.textSecondary),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTypography.sectionTitle.copyWith(color: c.textPrimary), textAlign: TextAlign.center),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle!, style: AppTypography.body.copyWith(color: c.textSecondary), textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}
