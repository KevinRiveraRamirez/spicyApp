import 'package:flutter/material.dart';
import '../core/theme/app_text.dart';

/// Chip de estado (disponible/agotado, pedido/en tránsito/recibida,
/// etc.). Siempre lleva texto, nunca depende solo del color para
/// comunicar el estado.
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusChip({super.key, required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Estado: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 12, color: color), const SizedBox(width: 4)],
            Text(label, style: AppTypography.label.copyWith(color: color, fontSize: 10.5)),
          ],
        ),
      ),
    );
  }
}
