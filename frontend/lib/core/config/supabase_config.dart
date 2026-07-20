/// Configuración de conexión a Supabase.
///
/// NUNCA escribas tu URL/clave directamente aquí para producción.
/// Este proyecto las lee de variables de compilación (--dart-define)
/// para que no queden guardadas en el código fuente ni en Git.
///
/// Cómo correr la app en modo desarrollo (VS Code):
///   flutter run \
///     --dart-define=SUPABASE_URL=https://TU-PROYECTO.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=TU_ANON_KEY
///
/// O crea un archivo .vscode/launch.json (ver README) para no
/// tener que escribirlo cada vez.
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
