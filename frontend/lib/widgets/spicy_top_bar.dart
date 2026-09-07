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

/// Barra superior "integrada": para escritorio, en vez de un [AppBar]
/// que cruza TODO el ancho de la pantalla (incluida la barra lateral,
/// duplicando visualmente el título de la pantalla contra el saludo o
/// encabezado propio del contenido), esta barra vive dentro de la
/// columna de contenido — a la derecha del sidebar, sin cruzarlo.
/// Junta en un solo lugar: título de pantalla (si aplica), botón de
/// acción principal y accesos de configuración/bloqueo.
class SpicyContentHeader extends StatelessWidget {
  final String? title;
  final IconData? titleIcon;
  final Widget? primaryAction;
  final List<Widget> actions;

  const SpicyContentHeader({super.key, this.title, this.titleIcon, this.primaryAction, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      height: AppSizes.contentHeaderHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      decoration: BoxDecoration(
        color: c.background,
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          if (title != null)
            Expanded(
              child: Row(
                children: [
                  if (titleIcon != null) ...[
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(color: c.brandPrimary.withOpacity(.1), borderRadius: BorderRadius.circular(AppRadius.control)),
                      alignment: Alignment.center,
                      child: Icon(titleIcon, size: 18, color: c.brandPrimary),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Flexible(
                    child: Text(
                      title!,
                      style: AppTypography.screenTitle.copyWith(color: c.textPrimary, letterSpacing: -0.3),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
          else
            const Spacer(),
          if (primaryAction != null) ...[
            primaryAction!,
            const SizedBox(width: AppSpacing.md),
          ],
          ...actions,
        ],
      ),
    );
  }
}
