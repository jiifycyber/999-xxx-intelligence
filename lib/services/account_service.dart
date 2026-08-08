import 'supabase_service.dart';

class AccountService {
  Future<void> toggleFavorite(String contentId) async {
    final c = SupabaseService.client;
    if (c == null) return;
    final uid = c.auth.currentUser?.id;
    if (uid == null) throw Exception('Sign in required');
    final existing = await c
        .from('favorites')
        .select('content_id')
        .eq('user_id', uid)
        .eq('content_id', contentId)
        .maybeSingle();
    if (existing == null) {
      await c.from('favorites').insert({
        'user_id': uid,
        'content_id': contentId,
      });
    } else {
      await c
          .from('favorites')
          .delete()
          .eq('user_id', uid)
          .eq('content_id', contentId);
    }
  }

  Future<void> recordView(String contentId) async {
    final c = SupabaseService.client;
    if (c == null) return;
    final uid = c.auth.currentUser?.id;
    if (uid == null) return;
    await c.from('view_history').upsert({
      'user_id': uid,
      'content_id': contentId,
      'viewed_at': DateTime.now().toIso8601String(),
    });
  }
}
