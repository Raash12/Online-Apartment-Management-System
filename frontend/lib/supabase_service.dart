import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart';

class SupabaseService {
  static Future<void> init() async {
    await Supabase.initialize(
      url: Config.supabaseUrl,
      anonKey: Config.supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }
}
