import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/responsive_center.dart';
import '../../widgets/spicy_logo.dart';

/// Pantalla de acceso con Supabase Auth (correo + contraseña).
/// Comparte el mismo tratamiento de marca que LockScreen: fondo rojo
/// degradado, logo blanco, alto contraste — la variación "PRINCIPAL
/// sobre rojo" del manual de marca, para las dos pantallas de entrada.
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

 InputDecoration _fieldDecoration(String label) {
  return InputDecoration(
    hintText: label,
    hintStyle: const TextStyle(color: AppColors.asphalt, fontWeight: FontWeight.w600),
    filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: AppColors.carbon, width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.spicyRed, AppColors.spicyRedDark, Color(0xFF1A0405)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: ResponsiveCenter(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: SpicyLogo(width: 200)),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text('STREETWEAR CO.',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10.5,
                              letterSpacing: 2.5,
                              fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      _isSignUp ? 'Crea tu cuenta' : 'Bienvenido de vuelta',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isSignUp ? 'Regístrate para administrar tu tienda.' : 'Ingresa tu correo. Sin rodeos.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontSize: 13.5),
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: AppColors.carbon),
                      decoration: _fieldDecoration('Correo electrónico'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passCtrl,
                      obscureText: true,
                      style: const TextStyle(color: AppColors.carbon),
                      decoration: _fieldDecoration('Contraseña'),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(_error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
                      ),
                    ],
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.spicyRed,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                          textStyle: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: .4),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.spicyRed))
                            : Text(_isSignUp ? 'CREAR CUENTA' : 'ENTRAR'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => setState(() => _isSignUp = !_isSignUp),
                        child: Text(
                          _isSignUp ? '¿Ya tienes cuenta? Inicia sesión' : '¿Primera vez? Crea tu cuenta',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}