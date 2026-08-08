import '../models/catalog_item.dart';
import 'supabase_service.dart';

class CatalogService {
  static final _demo = <CatalogItem>[
    CatalogItem(
      id: 'demo-1',
      title: 'Featured Creator Release',
      creatorId: 'c1',
      creatorName: 'Verified Creator',
      category: 'Featured',
      views: 12840,
      rating: 4.8,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    CatalogItem(
      id: 'demo-2',
      title: 'Trending Release',
      creatorId: 'c2',
      creatorName: 'Studio 999',
      category: 'Trending',
      views: 9431,
      rating: 4.6,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    CatalogItem(
      id: 'demo-3',
      title: 'New Creator Upload',
      creatorId: 'c3',
      creatorName: 'New Creator',
      category: 'New',
      views: 2381,
      rating: 4.5,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  Future<List<CatalogItem>> list({String? query, String? category}) async {
    final client = SupabaseService.client;
    if (client == null) {
      return _demo.where((e) {
        final qOk =
            query == null ||
            query.isEmpty ||
            e.title.toLowerCase().contains(query.toLowerCase()) ||
            e.creatorName.toLowerCase().contains(query.toLowerCase());
        final cOk =
            category == null || category == 'All' || e.category == category;
        return qOk && cOk;
      }).toList();
    }
    var q = client.from('catalog_public').select();
    if (query != null && query.trim().isNotEmpty) {
      q = q.or(
        'title.ilike.%${query.trim()}%,creator_name.ilike.%${query.trim()}%',
      );
    }
    if (category != null && category != 'All') {
      q = q.eq('category', category);
    }
    final rows = await q.order('created_at', ascending: false).limit(100);
    return (rows as List).map((e) => CatalogItem.fromMap(e)).toList();
  }
}
