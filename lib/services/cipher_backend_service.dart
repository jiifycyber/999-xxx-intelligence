import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class CipherBackendService {
  CipherBackendService._();

  static final CipherBackendService instance = CipherBackendService._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Uuid _uuid = const Uuid();

  SupabaseClient get _supabase => Supabase.instance.client;

  String get _platform {
    if (kIsWeb) return 'web';

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      TargetPlatform.macOS => 'macos',
      TargetPlatform.windows => 'windows',
      TargetPlatform.linux => 'linux',
      TargetPlatform.fuchsia => 'fuchsia',
    };
  }

  String get _deviceName {
    if (kIsWeb) return '999 Cipher Web';

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => '999 Cipher Android',
      TargetPlatform.iOS => '999 Cipher iPhone/iPad',
      TargetPlatform.macOS => '999 Cipher Mac',
      TargetPlatform.windows => '999 Cipher Windows',
      TargetPlatform.linux => '999 Cipher Linux',
      TargetPlatform.fuchsia => '999 Cipher Device',
    };
  }

  Future<String> _getOrCreateDeviceIdentifier() async {
    const key = '999_cipher_device_identifier';

    var deviceId = await _storage.read(key: key);

    if (deviceId == null || deviceId.isEmpty) {
      deviceId = _uuid.v4();
      await _storage.write(
        key: key,
        value: deviceId,
      );
    }

    return deviceId;
  }

  Future<void> registerDeviceAndStartSession() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw StateError('Cannot register device without an authenticated user.');
    }

    final deviceIdentifier = await _getOrCreateDeviceIdentifier();
    final now = DateTime.now().toUtc().toIso8601String();

    final device = await _supabase
        .from('registered_devices')
        .upsert(
          {
            'user_id': user.id,
            'device_identifier': deviceIdentifier,
            'device_name': _deviceName,
            'platform': _platform,
            'last_seen_at': now,
          },
          onConflict: 'user_id,device_identifier',
        )
        .select('id')
        .single();

    final deviceId = device['id'] as String;
    final sessionIdentifier = _uuid.v4();

    await _supabase.from('app_sessions').insert({
      'user_id': user.id,
      'device_id': deviceId,
      'session_identifier': sessionIdentifier,
      'started_at': now,
      'last_activity_at': now,
    });

    await _storage.write(
      key: '999_cipher_current_session_identifier',
      value: sessionIdentifier,
    );
  }

  Future<void> recordBiometricAssurance({
    required String biometricType,
    required String result,
    String? reason,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw StateError(
        'Cannot record biometric assurance without an authenticated user.',
      );
    }

    final deviceIdentifier = await _getOrCreateDeviceIdentifier();

    final device = await _supabase
        .from('registered_devices')
        .select('id')
        .eq('user_id', user.id)
        .eq('device_identifier', deviceIdentifier)
        .maybeSingle();

    if (device == null) {
      throw StateError('Registered device was not found.');
    }

    final deviceId = device['id'] as String;

    await _supabase.from('biometric_assurance').insert({
      'user_id': user.id,
      'device_id': deviceId,
      'biometric_type': biometricType,
      'result': result,
      'reason': reason,
      'assurance_level': 'local_device',
      'verified_at': DateTime.now().toUtc().toIso8601String(),
    });

    await _supabase
        .from('registered_devices')
        .update({
          'biometric_capable': true,
          'biometric_enabled': result == 'verified',
          'last_seen_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', deviceId)
        .eq('user_id', user.id);
  }
}
