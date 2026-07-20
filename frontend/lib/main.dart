import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'features/shell/auth_gate.dart';
import 'services/supabase_client.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseClientProvider.init();
  runApp(const SpicyAdminApp());
}

class SpicyAdminApp extends StatelessWidget {
  const SpicyAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Consumer<AppState>(
        builder: (context, app, _) {
          return MaterialApp(
            title: 'SPICY Streetwear · Admin',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: app.darkMode ? ThemeMode.dark : ThemeMode.light,
            home: SupabaseConfig.isConfigured
                ? const AuthGate()
                : const _MissingConfigScreen(),
          );
        },
      ),
    );
  }
}

/// Se muestra si la app corrió sin --dart-define=SUPABASE_URL/ANON_KEY.
/// Evita crashes confusos y le dice al desarrollador exactamente qué falta.
class _MissingConfigScreen extends StatelessWidget {
  const _MissingConfigScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.warning_amber_rounded, size: 40, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Falta configurar Supabase',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Corre la app con:\n\n'
                'flutter run \\\n'
                '  --dart-define=SUPABASE_URL=https://tu-proyecto.supabase.co \\\n'
                '  --dart-define=SUPABASE_ANON_KEY=tu_anon_key\n\n'
                'O configura .vscode/launch.json (ver README).',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
