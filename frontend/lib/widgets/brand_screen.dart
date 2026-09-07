import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import 'responsive_center.dart';

/// Contenedor estándar de una pantalla/pestaña: fondo neutro del tema
/// (sin degradados ni marcas de agua), márgenes laterales que crecen
/// con el tamaño de pantalla (16dp teléfono, 24dp tablet, 32dp
/// escritorio) y ancho de contenido limitado a 1280dp en escritorio
/// para no perder legibilidad.
class SpicyScreen extends StatelessWidget {
  final List<Widget> children;
  final Future<void> Function()? onRefresh;
  final EdgeInsets? extraPadding;

  const SpicyScreen({
    super.key,
    required this.children,
    this.onRefresh,
    this.extraPadding,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppSizes.breakpointDesktop;
    final isTablet = width >= AppSizes.breakpointTablet;
    final lateral = isDesktop ? AppSpacing.xxxl : (isTablet ? AppSpacing.xxl : AppSpacing.lg);
    // Un poco menos de aire justo debajo de la barra superior — la
    // barra ya trae su propio padding interno.
    final top = (extraPadding?.top ?? 0) + AppSpacing.md;
    final bottom = (extraPadding?.bottom ?? 0) + AppSpacing.huge;

    Widget list = ListView(
      padding: EdgeInsets.fromLTRB(lateral, top, lateral, bottom),
      children: children,
    );

    if (onRefresh != null) {
      list = RefreshIndicator(onRefresh: onRefresh!, color: c.brandPrimary, child: list);
    }

    return ColoredBox(
      color: c.background,
      child: ResponsiveCenter(
        maxWidth: AppSizes.maxContentWidth,
        child: list,
      ),
    );
  }
}
