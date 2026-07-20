import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';

/// Punto único de acceso al cliente de Supabase. Inicializar una sola
/// vez en main.dart con [SupabaseClientProvider.init].
class SupabaseClientProvider {
  SupabaseClientProvider._();

  static Future<void> init() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static String? get currentUserId => client.auth.currentUser?.id;

  static bool get isLoggedIn => client.auth.currentUser != null;
}
