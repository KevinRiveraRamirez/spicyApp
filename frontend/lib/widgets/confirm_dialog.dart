import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Diálogo de confirmación estándar para acciones destructivas
/// (eliminar proveedor, eliminar gasto, etc.) — nunca se borra nada
/// sin este paso explícito.
class ConfirmDialog {
  ConfirmDialog._();

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Eliminar',
    String cancelLabel = 'Cancelar',
    bool destructive = true,
  }) async {
    final c = context.colors;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: destructive ? c.danger : c.brandPrimary),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
