import 'package:flutter/material.dart';

/// Wordmark "SPICY Tech-Speed": la S angular en la palabra completa.
/// De uso preferente en acceso y encabezados amplios. [blue] controla
/// si se pinta en azul de marca (sobre fondos claros) o en blanco
/// (sobre fondos oscuros/azules) — nunca degradados ni sombras.
class SpicyWordmark extends StatelessWidget {
  final double width;
  final bool blue;

  const SpicyWordmark({super.key, this.width = 160, this.blue = true});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      blue ? 'assets/images/spicy_wordmark_blue.png' : 'assets/images/spicy_wordmark_white.png',
      width: width,
      fit: BoxFit.contain,
    );
  }
}

/// Monograma "S" — la variación compacta del wordmark, para navegación,
/// avatar, favicon y etiquetas pequeñas donde no cabe la palabra
/// completa.
class SpicyMonogram extends StatelessWidget {
  final double size;
  final bool blue;

  const SpicyMonogram({super.key, this.size = 32, this.blue = true});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      blue ? 'assets/images/spicy_monogram_blue.png' : 'assets/images/spicy_monogram_white.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
