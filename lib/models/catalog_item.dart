class CatalogItem {
  final String id;
  final String title;
  final String creatorId;
  final String creatorName;
  final String? thumbnailUrl;
  final String? playbackUrl;
  final String category;
  final int views;
  final double rating;
  final DateTime createdAt;

  const CatalogItem({
    required this.id,
    required this.title,
    required this.creatorId,
    required this.creatorName,
    required this.category,
    required this.views,
    required this.rating,
    required this.createdAt,
    this.thumbnailUrl,
    this.playbackUrl,
  });

  factory CatalogItem.fromMap(Map<String, dynamic> m) => CatalogItem(
    id: '${m['id']}',
    title: '${m['title'] ?? ''}',
    creatorId: '${m['creator_id'] ?? ''}',
    creatorName: '${m['creator_name'] ?? 'Creator'}',
    category: '${m['category'] ?? 'Other'}',
    views: (m['views'] as num?)?.toInt() ?? 0,
    rating: (m['rating'] as num?)?.toDouble() ?? 0,
    createdAt: DateTime.tryParse('${m['created_at']}') ?? DateTime.now(),
    thumbnailUrl: m['thumbnail_url'] as String?,
    playbackUrl: m['playback_url'] as String?,
  );
}
