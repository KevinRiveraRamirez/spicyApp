import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'responsive_center.dart';
import 'spicy_logo.dart';

/// Fondo y layout compartido por las pantallas con la identidad de
/// marca "PRINCIPAL sobre rojo" (el mismo tratamiento de lock/login,
/// aplicado primero en el Dashboard):
///
///  - Degradado rojo de borde a borde, siempre cubre el alto completo.
///  - Marca de agua del wordmark, tenue, anclada abajo.
///  - El ancho del contenido se adapta a teléfono/tablet/PC (no se
///    queda fijo en una columna angosta ni se estira feo en pantallas
///    anchas).
///  - Si el contenido es corto queda centrado de arriba hacia abajo;
///    si crece más que la pantalla, se comporta como una lista normal
///    con scroll.
///
/// Pensado para usarse como body de una pestaña dentro de [RootShell],
/// con su AppBar transparente flotando encima (ver root_shell.dart).
class BrandScreen extends StatelessWidget {
  final List<Widget> children;
  final Future<void> Function()? onRefresh;
  final bool centerWhenShort;

  const BrandScreen({
    super.key,
    required this.children,
    this.onRefresh,
    this.centerWhenShort = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final double contentMaxWidth = screenWidth < 700
        ? screenWidth
        : screenWidth < 1100
            ? screenWidth * 0.92
            : (screenWidth * 0.75).clamp(900, 1200).toDouble();

    // Dos caminos totalmente separados, sin compartir ninguna lógica de
    // centrado: si no queremos centrar, usamos un ListView normal y
    // simple (siempre queda arriba, sin ambigüedad posible). Solo el
    // camino "centerWhenShort" usa el truco de ConstrainedBox+Column
    // para centrar verticalmente cuando el contenido es corto.
    Widget list = centerWhenShort
        ? LayoutBuilder(
            builder: (context, constraints) {
              const topPad = 16.0 + kToolbarHeight;
              const bottomPad = 110.0;
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, topPad, 20, bottomPad),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: (constraints.maxHeight - topPad - bottomPad).clamp(0, double.infinity),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children,
                  ),
                ),
              );
            },
          )
        : ListView(
            padding: const EdgeInsets.fromLTRB(20, 16 + kToolbarHeight, 20, 110),
            children: children,
          );

    if (onRefresh != null) {
      list = RefreshIndicator(onRefresh: onRefresh!, color: AppColors.spicyRed, child: list);
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.spicyRed, AppColors.spicyRedDark, Color(0xFF1A0405)],
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: -30,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.06,
              child: Center(child: SpicyLogo(width: 320)),
            ),
          ),
        ),
        ResponsiveCenter(
          maxWidth: contentMaxWidth,
          // La barra superior es transparente y flota sobre este mismo
          // fondo (ver root_shell.dart): SafeArea cubre el notch/status
          // bar, y el LayoutBuilder de arriba suma kToolbarHeight para
          // no quedar tapados por la barra.
          child: SafeArea(
            bottom: false,
            child: list,
          ),
        ),
      ],
    );
  }
}