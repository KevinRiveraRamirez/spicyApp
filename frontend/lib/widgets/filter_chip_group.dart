import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text.dart';

/// Fila de filtros horizontales desplazables (categorías de
/// Inventario, tipo/periodo de movimientos en Finanzas, etc.). Un solo
/// valor seleccionado a la vez.
class FilterChipGroup extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const FilterChipGroup({super.key, required this.options, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      height: AppSizes.minTouchTarget,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final option = options[i];
          final active = option == selected;
          return Semantics(
            button: true,
            selected: active,
            label: option,
            child: AnimatedContainer(
              duration: AppMotion.chipSelect,
              child: ChoiceChip(
                label: Text(option, style: AppTypography.label.copyWith(color: active ? Colors.white : c.textPrimary)),
                selected: active,
                selectedColor: c.brandPrimary,
                backgroundColor: c.surfaceAlt,
                onSelected: (_) => onSelected(option),
              ),
            ),
          );
        },
      ),
    );
  }
}
