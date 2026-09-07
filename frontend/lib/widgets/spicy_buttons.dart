import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Botón principal (alto 52dp, ver [AppTheme]): estados normal, hover,
/// focus, pressed y disabled los resuelve el `ElevatedButtonTheme`
/// global; este widget solo añade el estado "loading" (icono opcional
/// + spinner) que se repite en toda la app.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = loading || onPressed == null;
    return ElevatedButton(
      onPressed: disabled ? null : onPressed,
      child: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
                Text(label),
              ],
            ),
    );
  }
}

/// Botón secundario: mismo alto y radio que el principal, pero
/// contorneado — para la acción que acompaña, nunca compite con la
/// principal.
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = loading || onPressed == null;
    return OutlinedButton(
      onPressed: disabled ? null : onPressed,
      child: loading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: context.colors.brandPrimary),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
                Text(label),
              ],
            ),
    );
  }
}
