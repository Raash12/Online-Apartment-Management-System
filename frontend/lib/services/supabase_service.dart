import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static late final SupabaseClient client;

  static Future<void> init() async {
    await dotenv.load(fileName: ".env");

    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    client = SupabaseClient(url, anonKey);
  }
}
