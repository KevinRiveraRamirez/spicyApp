import 'package:flutter/material.dart';

/// SPICY Admin está pensada principalmente para iPhone, pero debe verse
/// bien en pantallas más anchas (iPad, tablets Android, ventana de
/// escritorio/web). Este widget limita el ancho del CONTENIDO en
/// pantallas grandes (para que no se estire feo de borde a borde),
/// mientras que fondos de color/gradiente pueden seguir ocupando toda
/// la pantalla si van por fuera de este widget.
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveCenter({super.key, required this.child, this.maxWidth = 420});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}