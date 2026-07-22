import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Tarjeta de KPI. Si se le da [background] (rojo o negro), se pinta
/// como "cajita" sólida de marca con texto blanco — el tratamiento que
/// usamos en el Dashboard. Sin [background], cae de vuelta a la tarjeta
/// neutra (blanco/carbón) que usan otras pantallas.
class KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String? delta;
  final bool positive;
  final Color? background;
  /// Color opcional para el valor (ej. verde/rojo según si es ingreso o
  /// gasto, o si la utilidad es positiva o negativa). Si es null, usa el
  /// color de texto normal del tema.
  final Color? valueColor;
  /// Ancho fijo (uso en fila con scroll horizontal, teléfono). Si es
  /// null, la tarjeta ocupa todo el espacio que le den (uso en
  /// [Expanded] dentro de una fila fija, tablet/PC).
  final double? width;
  final EdgeInsets margin;

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.delta,
    this.positive = true,
    this.background,
    this.valueColor,
    this.width = 150,
    this.margin = const EdgeInsets.only(right: 12),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final solid = background != null;

    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      margin: margin,
      decoration: BoxDecoration(
        color: solid ? background : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: solid ? null : Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: solid
                ? const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700)
                : Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: solid
                ? TextStyle(color: valueColor ?? Colors.white, fontSize: 19, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)
                : Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 19, color: valueColor),
          ),
          if (delta != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: solid ? Colors.white.withOpacity(.18) : (positive ? AppColors.success : AppColors.spicyRed).withOpacity(.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(delta!,
                  style: TextStyle(
                      color: solid ? Colors.white : (positive ? AppColors.success : AppColors.spicyRed),
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }
}