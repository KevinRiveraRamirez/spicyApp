import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text.dart';

/// Hoja inferior estándar de la app: usada para todos los formularios
/// (producto, venta, compra, gasto, proveedor, detalle, ajustes...).
/// A pantalla casi completa en móvil, con [stickyFooter] opcional que
/// queda fijo justo sobre el teclado (para el botón principal, ej.
/// "COBRAR ₡12.500") en vez de scrollear junto con el formulario.
class SpicyBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? stickyFooter;

  const SpicyBottomSheet({super.key, required this.title, required this.child, this.stickyFooter});

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget child,
    Widget? stickyFooter,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      // Duración de apertura dentro del rango 260-320ms del sistema de
      // movimiento (el valor por defecto de Material ya cae en ese
      // rango con curva decelerate, muy cercana a easeOutCubic).
      builder: (_) => SpicyBottomSheet(title: title, stickyFooter: stickyFooter, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .92),
        decoration: BoxDecoration(
          color: c.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(color: c.border, borderRadius: BorderRadius.circular(4)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.md, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: AppTypography.screenTitle.copyWith(color: c.textPrimary, fontSize: 18)),
                  IconButton(
                    tooltip: 'Cerrar',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: c.textSecondary),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.xl),
                child: child,
              ),
            ),
            if (stickyFooter != null)
              Container(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.md,
                  AppSpacing.xl,
                  AppSpacing.md + MediaQuery.of(context).padding.bottom,
                ),
                decoration: BoxDecoration(
                  color: c.background,
                  border: Border(top: BorderSide(color: c.border)),
                ),
                child: stickyFooter,
              ),
          ],
        ),
      ),
    );
  }
}
