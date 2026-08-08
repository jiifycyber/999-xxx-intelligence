import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_config.dart';

class SupabaseService {
  static bool initialized = false;

  static Future<void> initialize() async {
    if (!AppConfig.hasSupabase) return;
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    initialized = true;
  }

  static SupabaseClient? get client =>
      initialized ? Supabase.instance.client : null;
}
