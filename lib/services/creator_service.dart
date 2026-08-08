import 'supabase_service.dart';

class CreatorService {
  Future<String> submitContent({
    required String title,
    required String category,
    String? storageKey,
  }) async {
    final c = SupabaseService.client;
    if (c == null) throw Exception('Supabase is not configured');
    final uid = c.auth.currentUser?.id;
    if (uid == null) throw Exception('Sign in required');
    final creator = await c
        .from('creator_profiles')
        .select('id')
        .eq('user_id', uid)
        .single();
    final row = await c
        .from('content_submissions')
        .insert({
          'creator_id': creator['id'],
          'title': title,
          'category': category,
          'storage_key': storageKey,
          'moderation_status': 'pending',
          'rights_status': 'pending',
          'publish_status': 'blocked',
        })
        .select('id')
        .single();
    return '${row['id']}';
  }
}
