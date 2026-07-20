import 'package:flutter/material.dart';

/// Teclado numérico circular para el PIN de 4 dígitos, estilo pantalla
/// de bloqueo de SPICY (fondo rojo, botones translúcidos).
///
/// Cuadrícula FIJA de 3 columnas x 4 filas (1-9, vacío, 0, borrar) —
/// construida con Column/Row en vez de Wrap para que la forma nunca
/// cambie sin importar el ancho de la pantalla (teléfono, tablet, PC).
class PinPad extends StatelessWidget {
  final void Function(String digit) onDigit;
  final VoidCallback onDelete;

  const PinPad({super.key, required this.onDigit, required this.onDelete});

  static const _rows = <List<String>>[
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['', '0', 'del'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int r = 0; r < _rows.length; r++) ...[
          if (r > 0) const SizedBox(height: 14),
          _PinRow(keys: _rows[r], onDigit: onDigit, onDelete: onDelete),
        ],
      ],
    );
  }
}

class _PinRow extends StatelessWidget {
  final List<String> keys;
  final void Function(String digit) onDigit;
  final VoidCallback onDelete;

  const _PinRow({required this.keys, required this.onDigit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < keys.length; i++) ...[
          if (i > 0) const SizedBox(width: 14),
          _buildKey(keys[i]),
        ],
      ],
    );
  }

  Widget _buildKey(String k) {
    if (k.isEmpty) return const SizedBox(width: 64, height: 64);
    if (k == 'del') {
      return _PinKey(
        ghost: true,
        onTap: onDelete,
        child: const Icon(Icons.backspace_outlined, color: Colors.white, size: 20),
      );
    }
    return _PinKey(
      onTap: () => onDigit(k),
      child: Text(k, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
    );
  }
}

class _PinKey extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool ghost;
  const _PinKey({required this.child, required this.onTap, this.ghost = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 64,
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ghost ? Colors.transparent : Colors.white.withOpacity(.08),
          border: ghost ? null : Border.all(color: Colors.white.withOpacity(.25)),
        ),
        child: child,
      ),
    );
  }
}

/// Puntos que muestran cuántos dígitos del PIN se han capturado.
class PinDots extends StatelessWidget {
  final int filled;
  final bool error;
  const PinDots({super.key, required this.filled, this.error = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (i) {
        final isFilled = i < filled;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled || error ? Colors.white : Colors.transparent,
            border: Border.all(color: Colors.white.withOpacity(.6), width: 2),
          ),
        );
      }),
    );
  }
}