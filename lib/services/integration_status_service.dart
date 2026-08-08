import '../core/app_config.dart';
import 'supabase_service.dart';

class IntegrationStatus {
  final String name;
  final bool ready;
  final String detail;
  const IntegrationStatus(this.name, this.ready, this.detail);
}

class IntegrationStatusService {
  List<IntegrationStatus> get all => [
    IntegrationStatus(
      'Supabase',
      SupabaseService.client != null,
      SupabaseService.client != null
          ? 'Connected'
          : 'Configure SUPABASE_URL / SUPABASE_ANON_KEY',
    ),
    IntegrationStatus(
      'Video/CDN',
      AppConfig.videoProvider != 'unconfigured',
      AppConfig.videoProvider == 'unconfigured'
          ? 'Provider required'
          : AppConfig.videoProvider,
    ),
    IntegrationStatus(
      'Payments',
      AppConfig.paymentProvider != 'unconfigured',
      AppConfig.paymentProvider == 'unconfigured'
          ? 'Provider required'
          : AppConfig.paymentProvider,
    ),
    IntegrationStatus(
      'Age / ID Verification',
      AppConfig.verificationProvider != 'unconfigured',
      AppConfig.verificationProvider == 'unconfigured'
          ? 'Provider required'
          : AppConfig.verificationProvider,
    ),
  ];
}
