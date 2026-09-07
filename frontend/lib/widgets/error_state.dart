import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text.dart';
import 'spicy_buttons.dart';

/// Estado de error con opción de reintentar — para cuando falla una
/// carga (conexión, Supabase pausado, etc.), en vez de una pantalla en
/// blanco o un simple mensaje de texto.
class ErrorState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onRetry;

  const ErrorState({super.key, required this.title, this.subtitle, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.huge, horizontal: AppSpacing.xl),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 36, color: c.danger),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTypography.sectionTitle.copyWith(color: c.textPrimary), textAlign: TextAlign.center),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle!, style: AppTypography.body.copyWith(color: c.textSecondary), textAlign: TextAlign.center),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: 160,
              child: SecondaryButton(label: 'Reintentar', icon: Icons.refresh, onPressed: onRetry),
            ),
          ],
        ],
      ),
    );
  }
}
