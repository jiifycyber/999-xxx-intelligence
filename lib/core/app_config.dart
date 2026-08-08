class AppConfig {
  static const brand = '999XXX';
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  // External providers are intentionally runtime-configured.
  static const videoProvider = String.fromEnvironment(
    'VIDEO_PROVIDER',
    defaultValue: 'unconfigured',
  );
  static const paymentProvider = String.fromEnvironment(
    'PAYMENT_PROVIDER',
    defaultValue: 'unconfigured',
  );
  static const verificationProvider = String.fromEnvironment(
    'VERIFICATION_PROVIDER',
    defaultValue: 'unconfigured',
  );
}
