import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../services/auth_service.dart';
import '../../services/pin_service.dart';
import '../../state/app_state.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/confirm_dialog.dart';
import '../auth/widgets/pin_pad.dart';

/// APK de Android publicado como release en GitHub (Firebase Hosting no
/// permite subir .apk en el plan gratis). "latest" siempre resuelve al
/// release más reciente — el workflow de GitHub Actions sube uno nuevo
/// automáticamente en cada push a main, así que este link nunca hay que
/// tocarlo a mano.
const kApkDownloadUrl = 'https://github.com/KevinRiveraRamirez/spicyApp/releases/latest/download/app-release.apk';

/// Ajustes: hoja estructurada por secciones (Seguridad, Apariencia,
/// Datos, Aplicación, Sesión) en vez de una lista plana de filas
/// ambiguas — cada fila lleva título, descripción y, si aplica, un
/// estado explícito. "Cerrar sesión" queda separado y confirmado por
/// ser irreversible dentro del dispositivo actual.
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
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SettingsSection(
          title: 'Seguridad',
          children: [
            _SettingsRow(
              icon: Icons.shield_outlined,
              title: 'Cambiar PIN',
              subtitle: 'Actualiza el PIN de bloqueo de esta app',
              onTap: () {
                Navigator.of(context).pop();
                _changePinFlow(context);
              },
            ),
            _SettingsRow(
              icon: Icons.lock_outline,
              title: 'Bloquear ahora',
              subtitle: 'Cierra el acceso de inmediato en este dispositivo',
              onTap: () {
                Navigator.of(context).pop();
                widget.onLockNow();
              },
            ),
          ],
        ),
        _SettingsSection(
          title: 'Apariencia',
          children: [
            _SettingsSwitchRow(
              icon: app.darkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              title: 'Modo oscuro',
              subtitle: app.darkMode ? 'Activado' : 'Desactivado',
              value: app.darkMode,
              onChanged: (_) => app.toggleDarkMode(),
            ),
          ],
        ),
        _SettingsSection(
          title: 'Datos',
          children: [
            _SettingsRow(
              icon: Icons.download_outlined,
              title: 'Exportar respaldo',
              subtitle: 'Descarga un resumen de tus datos como JSON',
              onTap: () => _exportBackup(context, app),
            ),
          ],
        ),
        if (kIsWeb)
          _SettingsSection(
            title: 'Aplicación',
            children: [
              _SettingsRow(
                icon: Icons.android,
                title: 'Descargar app para Android',
                subtitle: 'Instala SPICY Admin en tu celular (APK)',
                onTap: () => _downloadApk(context),
              ),
            ],
          ),
        _SettingsSection(
          title: 'Sesión',
          children: [
            _SettingsRow(
              icon: Icons.logout,
              title: 'Cerrar sesión',
              subtitle: 'Salir de esta cuenta de Supabase en este dispositivo',
              danger: true,
              onTap: () => _signOut(context),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Tus datos viven en tu propio proyecto de Supabase (Postgres), protegidos con seguridad a nivel de fila. Sin terceros, sin filtros.',
          style: AppTypography.label.copyWith(color: c.textSecondary, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: '¿Cerrar sesión?',
      message: 'Vas a salir de tu cuenta de Supabase en este dispositivo. Podrás volver a entrar con tu correo y contraseña.',
      confirmLabel: 'Cerrar sesión',
    );
    if (!confirmed || !context.mounted) return;
    await _authService.signOut();
    if (context.mounted) {
      Navigator.of(context).pop();
      widget.onSignedOut();
    }
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo descargar el APK')));
    }
  }

  void _changePinFlow(BuildContext context) {
    SpicyBottomSheet.show(context, title: 'Cambiar PIN', child: _ChangePinForm(pinService: _pinService));
  }
}

/// Grupo de filas bajo un título de sección — separa visualmente
/// Seguridad/Apariencia/Datos/Aplicación/Sesión en vez de una lista
/// plana ambigua.
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.label.copyWith(color: c.textSecondary, letterSpacing: .4)),
          const SizedBox(height: AppSpacing.xs),
          Container(
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: c.border),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool danger;
  const _SettingsRow({required this.icon, required this.title, required this.subtitle, this.onTap, this.danger = false});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = danger ? c.danger : c.textPrimary;
    return Semantics(
      button: true,
      label: '$title, $subtitle',
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: c.surfaceAlt, borderRadius: BorderRadius.circular(AppRadius.control)),
                alignment: Alignment.center,
                child: Icon(icon, size: 18, color: fg),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.bodyMedium.copyWith(color: fg, fontWeight: FontWeight.w700)),
                    Text(subtitle, style: AppTypography.label.copyWith(color: c.textSecondary, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: c.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSwitchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SettingsSwitchRow({required this.icon, required this.title, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: c.surfaceAlt, borderRadius: BorderRadius.circular(AppRadius.control)),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: c.textPrimary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyMedium.copyWith(color: c.textPrimary, fontWeight: FontWeight.w700)),
                Text(subtitle, style: AppTypography.label.copyWith(color: c.textSecondary, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
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
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Nuevo PIN de 4 dígitos', style: AppTypography.body.copyWith(color: c.textSecondary)),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
          decoration: BoxDecoration(color: AppColors.lightBrandPrimary, borderRadius: BorderRadius.circular(AppRadius.sheet)),
          child: Column(
            children: [
              PinDots(filled: _buffer.length),
              const SizedBox(height: AppSpacing.xl),
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
