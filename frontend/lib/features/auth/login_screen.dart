import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../services/auth_service.dart';
import '../../widgets/responsive_center.dart';
import '../../widgets/spicy_buttons.dart';
import '../../widgets/spicy_logo.dart';

/// Pantalla de acceso con Supabase Auth (correo + contraseña). Fondo
/// azul de marca sólido (sin degradado), tarjeta blanca de ancho
/// máximo 420dp con el formulario — la variación "principal sobre
/// azul" del manual Tech-Speed, consistente con [LockScreen].
///
/// Una vez autenticado, la app pide crear un PIN local de 4 dígitos
/// para desbloqueos rápidos posteriores (ver LockScreen).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isSignUp = false;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_isSignUp) {
        await _authService.signUp(email: _emailCtrl.text.trim(), password: _passCtrl.text);
      } else {
        await _authService.signIn(email: _emailCtrl.text.trim(), password: _passCtrl.text);
      }
      // La navegación real la maneja el listener de sesión en main.dart / AuthGate.
    } catch (e) {
      setState(() => _error = 'No se pudo entrar. Revisa tus datos e intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: BorderSide(color: color, width: width),
        );
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: AppColors.lightTextSecondary),
      filled: true,
      fillColor: AppColors.lightBackground,
      border: border(AppColors.lightBorder),
      enabledBorder: border(AppColors.lightBorder),
      focusedBorder: border(AppColors.lightBrandPrimary, 1.6),
      constraints: const BoxConstraints(minHeight: AppSizes.inputHeight),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBrandPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: ResponsiveCenter(
            maxWidth: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SpicyWordmark(width: 180, blue: false),
                  const SizedBox(height: AppSpacing.sm),
                  Text('STREETWEAR CO.', style: AppTypography.label.copyWith(color: Colors.white70, letterSpacing: 2.5)),
                  const SizedBox(height: AppSpacing.xxl),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    decoration: BoxDecoration(
                      color: AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(AppRadius.sheet),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _isSignUp ? 'Crea tu cuenta' : 'Bienvenido de vuelta',
                          textAlign: TextAlign.center,
                          style: AppTypography.screenTitle.copyWith(color: AppColors.lightTextPrimary),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _isSignUp ? 'Regístrate para administrar tu tienda.' : 'Ingresa tu correo. Sin rodeos.',
                          textAlign: TextAlign.center,
                          style: AppTypography.body.copyWith(color: AppColors.lightTextSecondary),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          style: AppTypography.body.copyWith(color: AppColors.lightTextPrimary),
                          decoration: _fieldDecoration('Correo electrónico', Icons.mail_outline),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextField(
                          controller: _passCtrl,
                          obscureText: true,
                          style: AppTypography.body.copyWith(color: AppColors.lightTextPrimary),
                          decoration: _fieldDecoration('Contraseña', Icons.lock_outline),
                          onSubmitted: (_) => _loading ? null : _submit(),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          Semantics(
                            liveRegion: true,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: AppColors.lightDanger.withOpacity(.1),
                                borderRadius: BorderRadius.circular(AppRadius.control),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, size: 16, color: AppColors.lightDanger),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(_error!, style: AppTypography.label.copyWith(color: AppColors.lightDanger)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xl),
                        PrimaryButton(
                          label: _isSignUp ? 'Crear cuenta' : 'Entrar',
                          loading: _loading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Center(
                          child: TextButton(
                            onPressed: () => setState(() => _isSignUp = !_isSignUp),
                            child: Text(_isSignUp ? '¿Ya tienes cuenta? Inicia sesión' : '¿Primera vez? Crea tu cuenta'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
