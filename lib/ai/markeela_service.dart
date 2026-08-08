import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import 'markeela_models.dart';

class MarkeelaService {
  Future<MarkeelaResponse> ask({
    required String message,
    String mode = 'assistant',
    Map<String, dynamic> context = const {},
  }) async {
    final c = SupabaseService.client;
    if (c == null) {
      return MarkeelaResponse(
        text: _localFallback(message, mode),
        mode: mode,
        model: 'local-guidance',
        suggestedActions: _localSuggestions(mode),
      );
    }

    try {
      final res = await c.functions.invoke(
        'markeela-agent',
        body: {'message': message, 'mode': mode, 'context': context},
      );
      final data = (res.data is Map<String, dynamic>)
          ? res.data as Map<String, dynamic>
          : <String, dynamic>{'text': '${res.data}'};
      return MarkeelaResponse.fromMap(data);
    } catch (e) {
      return MarkeelaResponse(
        text:
            'Markeela AI backend is not deployed yet. The app is ready, but the '
            'markeela-agent Edge Function / 999 Intelligence gateway must be configured. '
            'Backend error: $e',
        mode: mode,
        model: 'offline',
      );
    }
  }

  String _localFallback(String message, String mode) {
    switch (mode) {
      case 'creator':
        return 'I can guide creator onboarding, verification, rights records, and submission '
            'status. Live AI reasoning becomes available after the Markeela backend is deployed.';
      case 'admin':
        return 'I can summarize moderation, rights, reports, and analytics once the secure AI '
            'backend is connected. Privileged approvals always remain human-authorized.';
      case 'discovery':
        return 'I can help search and recommend catalog items. Connect the live AI gateway for '
            'semantic recommendations and personalized reasoning.';
      default:
        return 'I am Markeela, the 999XXX AI assistant. My secure AI backend is not connected yet, '
            'but the app-side assistant and tool interface are installed.';
    }
  }

  List<String> _localSuggestions(String mode) {
    if (mode == 'creator') {
      return [
        'Review verification status',
        'Check rights requirements',
        'Prepare submission',
      ];
    }
    if (mode == 'admin') {
      return [
        'Summarize moderation queue',
        'Review open reports',
        'Explain analytics',
      ];
    }
    return ['Search catalog', 'Open Creator Studio', 'Check system status'];
  }
}
