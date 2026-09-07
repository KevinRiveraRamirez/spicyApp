import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text.dart';
import 'spicy_logo.dart';

/// Barra superior de la app. En móvil/tablet es compacta (monograma +
/// título de pantalla); en escritorio se amplía con el wordmark
/// completo y deja espacio para búsqueda contextual.
class SpicyTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  final bool isDesktop;

  const SpicyTopBar({super.key, required this.title, this.actions = const [], this.isDesktop = false});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppBar(
      titleSpacing: isDesktop ? AppSpacing.xxl : AppSpacing.lg,
      title: Row(
        children: [
          if (!isDesktop) ...[
            const SpicyMonogram(size: 26),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(title, style: AppTypography.screenTitle.copyWith(color: c.textPrimary, fontSize: isDesktop ? 20 : 17)),
        ],
      ),
      actions: [...actions, const SizedBox(width: AppSpacing.sm)],
    );
  }
}
