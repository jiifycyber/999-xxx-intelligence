import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/security_event.dart';

class Level6EventService {
  Level6EventService._();

  static final Level6EventService instance = Level6EventService._();

  SupabaseClient get _db => Supabase.instance.client;

  String? get currentUserId => _db.auth.currentUser?.id;

  Stream<List<SecurityEvent>> watchEvents() {
    final uid = currentUserId;

    if (uid == null) {
      return const Stream<List<SecurityEvent>>.empty();
    }

    return _db
        .from('security_events')
        .stream(primaryKey: ['id'])
        .eq('owner_user_id', uid)
        .order('occurred_at', ascending: false)
        .map(
          (rows) => rows.map((row) => SecurityEvent.fromMap(row)).toList(),
        );
  }

  Future<List<SecurityEvent>> fetchRecent({
    int limit = 100,
  }) async {
    final uid = currentUserId;

    if (uid == null) {
      return const [];
    }

    final rows = await _db
        .from('security_events')
        .select()
        .eq('owner_user_id', uid)
        .order('occurred_at', ascending: false)
        .limit(limit);

    return (rows as List)
        .map(
          (row) => SecurityEvent.fromMap(Map<String, dynamic>.from(row)),
        )
        .toList();
  }

  Future<Map<String, dynamic>?> fetchAttribution(
    String eventId,
  ) async {
    final row = await _db
        .from('attribution_assessments')
        .select()
        .eq('event_id', eventId)
        .maybeSingle();

    if (row == null) {
      return null;
    }

    return Map<String, dynamic>.from(row);
  }

  Future<List<Map<String, dynamic>>> fetchEvidence(
    String eventId,
  ) async {
    final rows = await _db
        .from('security_evidence')
        .select()
        .eq('event_id', eventId)
        .order('captured_at', ascending: false);

    return (rows as List).map((row) => Map<String, dynamic>.from(row)).toList();
  }

  Future<Map<String, dynamic>> requestQuarantineFile(
    SecurityEvent event,
  ) async {
    final uid = currentUserId;

    if (uid == null) {
      throw StateError('No authenticated Level 6 user.');
    }

    final endpointId = (event.endpointId ?? '').trim();
    final targetPath = (event.itemPath ?? event.sanitizedPath ?? '').trim();

    if (!event.hasFileEvidence || targetPath.isEmpty) {
      throw StateError(
        'This event does not contain structured file evidence.',
      );
    }

    if (endpointId.isEmpty) {
      throw StateError(
        'This event does not identify an endpoint.',
      );
    }

    final existing = await _db
        .from('response_commands')
        .select('id,status')
        .eq('owner_user_id', uid)
        .eq('security_event_id', event.id)
        .eq('command_type', 'QUARANTINE_FILE')
        .inFilter(
      'status',
      const [
        'PENDING',
        'ACCEPTED',
        'RUNNING',
      ],
    ).limit(1);

    if ((existing as List).isNotEmpty) {
      throw StateError(
        'A quarantine command is already active for this event.',
      );
    }

    final row = await _db
        .from('response_commands')
        .insert({
          'owner_user_id': uid,
          'security_event_id': event.id,
          'endpoint_id': endpointId,
          'command_type': 'QUARANTINE_FILE',
          'target_path': targetPath,
          'status': 'PENDING',
        })
        .select()
        .single();

    return Map<String, dynamic>.from(row);
  }

  Future<int> resolveHistoricalYaraSelfScans() async {
    final uid = currentUserId;

    if (uid == null) {
      throw StateError('No authenticated Level 6 user.');
    }

    final rows = await _db
        .from('security_events')
        .select('id,sanitized_path,metadata,action,rule_name')
        .eq('owner_user_id', uid);

    final ids = <String>[];

    for (final raw in (rows as List)) {
      final row = Map<String, dynamic>.from(raw);
      final metadataRaw = row['metadata'];
      final metadata = metadataRaw is Map
          ? Map<String, dynamic>.from(metadataRaw)
          : <String, dynamic>{};

      final path = (metadata['item_path'] ?? row['sanitized_path'] ?? '')
          .toString()
          .toLowerCase();

      final ruleName = (row['rule_name'] ?? '').toString().toUpperCase();

      final action = (row['action'] ?? '').toString().toUpperCase();

      // Historical Level 6 self-scan artifacts.
      final internalYaraArtifact = path.contains('endpoint_sensor/yara/') ||
          path.contains('endpoint_sensor/state/yara_production.yarc');

      // Controlled 999 Defense test detections must never remain
      // classified as production threats.
      final controlledTest = ruleName.contains('CIPHER_SAFE_TEST_DETECTION') ||
          ruleName.contains('LEVEL6_CONTROLLED_TEST') ||
          ruleName.startsWith('TEST -');

      if ((internalYaraArtifact || controlledTest) && action != 'RESOLVED') {
        ids.add(row['id'].toString());
      }
    }

    for (var i = 0; i < ids.length; i += 100) {
      final end = (i + 100 < ids.length) ? i + 100 : ids.length;
      final batch = ids.sublist(i, end);

      await _db
          .from('security_events')
          .update({'action': 'RESOLVED'})
          .eq('owner_user_id', uid)
          .inFilter('id', batch);
    }

    return ids.length;
  }

  Future<void> resolveEvent(String eventId) async {
    final uid = currentUserId;

    if (uid == null) {
      throw StateError('No authenticated Level 6 user.');
    }

    final row = await _db
        .from('security_events')
        .update({'action': 'RESOLVED'})
        .eq('id', eventId)
        .eq('owner_user_id', uid)
        .select('id,action')
        .maybeSingle();

    if (row == null ||
        (row['action'] ?? '').toString().toUpperCase() != 'RESOLVED') {
      throw StateError('Supabase did not confirm the event as RESOLVED.');
    }
  }
}
