import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Ic391CaseStore {
  static const String storageKey = 'ic391_private_active_cases_v1';

  static Future<List<Map<String, dynamic>>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(List<Map<String, dynamic>> cases) async {
    final prefs = await SharedPreferences.getInstance();
    final result = await prefs.setString(storageKey, jsonEncode(cases));
    if (!result) {
      throw StateError('Local case storage failed');
    }
  }

  static Future<void> add(Map<String, dynamic> record) async {
    final cases = await load();
    final id = record['global_id']?.toString() ?? '';

    if (id.isEmpty) {
      throw StateError('Source record has no global ID');
    }

    if (cases.any((item) => item['global_id'] == id)) return;

    cases.add({
      'global_id': id,
      'title': record['title']?.toString() ?? 'Untitled record',
      'source_id': record['source_id']?.toString() ?? '',
      'source_url': record['source_url']?.toString() ?? '',
      'opened_at': DateTime.now().toUtc().toIso8601String(),
      'internal_status': 'OPEN FOR REVIEW',
      'notes': '',
      'timeline': <dynamic>[],
      'leads': <dynamic>[],
      'official_status': 'NOT INDEPENDENTLY VERIFIED',
    });

    await save(cases);
  }
}
