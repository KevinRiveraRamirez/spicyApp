import 'package:flutter/material.dart';
import '../../services/supabase_client.dart';
import '../auth/lock_screen.dart';
import '../auth/login_screen.dart';
import 'root_shell.dart';

/// Controla el flujo: sesión de Supabase → PIN local → app.
///
///  1. Si no hay sesión de Supabase activa → LoginScreen.
///  2. Si hay sesión pero la app está bloqueada (recién abierta, o
///     inactividad) → LockScreen (PIN/biometría).
///  3. Si todo está desbloqueado → RootShell (la app real).
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> with WidgetsBindingObserver {
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SupabaseClientProvider.client.auth.onAuthStateChange.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Vuelve a pedir el PIN cuando la app regresa de segundo plano.
    if (state == AppLifecycleState.paused) {
      setState(() => _unlocked = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = SupabaseClientProvider.client.auth.currentSession;
    if (session == null) return const LoginScreen();
    if (!_unlocked) {
      return LockScreen(onUnlocked: () => setState(() => _unlocked = true));
    }
    return RootShell(
      onSignedOut: () => setState(() {}),
      onLockNow: () => setState(() => _unlocked = false),
    );
  }
}
