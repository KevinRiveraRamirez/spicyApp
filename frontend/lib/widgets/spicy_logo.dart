import 'package:flutter/material.dart';

/// Wordmark oficial de SPICY: la palabra "SPICY" fracturada en blanco,
/// atravesada por un destello. Según el manual de marca, es de uso
/// preferente sobre fondo rojo — por eso este widget casi siempre va
/// dentro de un contenedor rojo (ver [SpicyLogoBadge]).
class SpicyLogo extends StatelessWidget {
  final double width;
  const SpicyLogo({super.key, this.width = 160});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/spicy_logo_white.png',
      width: width,
      fit: BoxFit.contain,
    );
  }
}

/// El wordmark envuelto en una tarjeta roja redondeada — la variación
/// "PRINCIPAL · SOBRE ROJO" del manual, lista para usar en cualquier
/// fondo (claro u oscuro) sin perder contraste.
class SpicyLogoBadge extends StatelessWidget {
  final double logoWidth;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;

  const SpicyLogoBadge({
    super.key,
    this.logoWidth = 120,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFFE4131A),
        borderRadius: borderRadius ?? BorderRadius.circular(14),
      ),
      child: SpicyLogo(width: logoWidth),
    );
  }
}