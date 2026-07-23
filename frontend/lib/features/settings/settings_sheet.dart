import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/pin_service.dart';
import '../../state/app_state.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../auth/widgets/pin_pad.dart';

/// APK de Android publicado como release en GitHub (Firebase Hosting no
/// permite subir .apk en el plan gratis). Al sacar una versión nueva,
/// subí el APK como un nuevo release en GitHub y actualizá este link.
const kApkDownloadUrl = 'https://github.com/KevinRiveraRamirez/spicyApp/releases/download/v1.0.0/app-release.apk';

class SettingsSheet extends StatefulWidget {
  final VoidCallback onSignedOut;
  final VoidCallback onLockNow;

  const SettingsSheet({super.key, required this.onSignedOut, required this.onLockNow});

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  final _pinService = PinService();
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _row(
          icon: Icons.shield_outlined,
          title: 'Cambiar PIN',
          subtitle: 'Seguridad de la cuenta',
          onTap: () {
            Navigator.of(context).pop();
            _changePinFlow(context);
          },
        ),
        _rowSwitch(
          icon: app.darkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
          title: 'Modo oscuro',
          subtitle: 'Cuida tus ojos de noche',
          value: app.darkMode,
          onChanged: (_) => app.toggleDarkMode(),
        ),
        _row(
          icon: Icons.download_outlined,
          title: 'Exportar respaldo',
          subtitle: 'Descarga tus datos como JSON',
          onTap: () => _exportBackup(context, app),
        ),
        // Solo tiene sentido desde la versión web: te descarga el APK
        // para instalar la app nativa en Android. En la app ya instalada
        // (Android) no aplica.
        if (kIsWeb)
          _row(
            icon: Icons.android,
            title: 'Descargar app para Android',
            subtitle: 'Instala SPICY Admin en tu celular (APK)',
            onTap: () => _downloadApk(context),
          ),
        _row(
          icon: Icons.lock_outline,
          title: 'Bloquear ahora',
          subtitle: 'Cierra el acceso de inmediato',
          onTap: () {
            Navigator.of(context).pop();
            widget.onLockNow();
          },
        ),
        _row(
          icon: Icons.logout,
          title: 'Cerrar sesión',
          subtitle: 'Salir de esta cuenta de Supabase',
          danger: true,
          onTap: () async {
            await _authService.signOut();
            if (context.mounted) {
              Navigator.of(context).pop();
              widget.onSignedOut();
            }
          },
        ),
        const SizedBox(height: 8),
        const Text(
          'Tus datos viven en tu propio proyecto de Supabase (Postgres), protegidos con seguridad a nivel de fila. Sin terceros, sin filtros.',
          style: TextStyle(color: AppColors.asphalt, fontSize: 12),
        ),
      ],
    );
  }

  void _exportBackup(BuildContext context, AppState app) {
    final data = {
      'products': app.products.length,
      'suppliers': app.suppliers.length,
      'sales': app.sales.length,
      'purchases': app.purchases.length,
      'expenses': app.expenses.length,
    };
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resumen de datos'),
        content: Text(
          'Tus datos ya están respaldados automáticamente en Supabase (Postgres administrado).\n\n'
          '${const JsonEncoder.withIndent('  ').convert(data)}',
        ),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cerrar'))],
      ),
    );
  }

  Future<void> _downloadApk(BuildContext context) async {
    final uri = Uri.parse(kApkDownloadUrl);
    final ok = await launchUrl(uri, webOnlyWindowName: '_blank');
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo descargar el APK')),
      );
    }
  }

  void _changePinFlow(BuildContext context) {
    AppBottomSheet.show(
      context,
      title: 'Cambiar PIN',
      child: _ChangePinForm(pinService: _pinService),
    );
  }

  Widget _row({required IconData icon, required String title, required String subtitle, VoidCallback? onTap, bool danger = false}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.lightSurfaceAlt, borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: Icon(icon, size: 18, color: danger ? AppColors.spicyRed : AppColors.carbon),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: danger ? AppColors.spicyRed : null)),
                  Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.asphalt)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.asphalt),
          ],
        ),
      ),
    );
  }

  Widget _rowSwitch({required IconData icon, required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.lightSurfaceAlt, borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: AppColors.carbon),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.asphalt)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.spicyRed),
        ],
      ),
    );
  }
}

class _ChangePinForm extends StatefulWidget {
  final PinService pinService;
  const _ChangePinForm({required this.pinService});

  @override
  State<_ChangePinForm> createState() => _ChangePinFormState();
}

class _ChangePinFormState extends State<_ChangePinForm> {
  String _buffer = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Nuevo PIN de 4 dígitos', style: TextStyle(color: AppColors.asphalt, fontSize: 12.5)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: AppColors.carbon,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              PinDots(filled: _buffer.length),
              const SizedBox(height: 20),
              PinPad(
                onDigit: (d) async {
                  if (_buffer.length >= 4) return;
                  setState(() => _buffer += d);
                  if (_buffer.length == 4) {
                    await widget.pinService.setPin(_buffer);
                    if (mounted) Navigator.of(context).pop();
                  }
                },
                onDelete: () => setState(() => _buffer = _buffer.isEmpty ? '' : _buffer.substring(0, _buffer.length - 1)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}