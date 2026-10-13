import 'dart:convert';
import 'package:flutter/services.dart';

class FbiIntelligenceService {
  static const String sourceName = 'FBI Wanted API';

  static const String _allAsset = 'data/fbi/fbi_wanted_records.json';

  static const String _reviewAsset = 'data/fbi/child_related_candidates.json';

  List<Map<String, dynamic>> _records = [];
  List<Map<String, dynamic>> _reviewCandidates = [];

  bool _loaded = false;
  DateTime? retrievedAt;

  bool get isLoaded => _loaded;

  int get totalRecords => _records.length;

  int get reviewCandidateCount => _reviewCandidates.length;

  List<Map<String, dynamic>> get allRecords => List.unmodifiable(_records);

  List<Map<String, dynamic>> get reviewCandidates =>
      List.unmodifiable(_reviewCandidates);

  Future<void> load() async {
    final allText = await rootBundle.loadString(_allAsset);
    final reviewText = await rootBundle.loadString(_reviewAsset);

    final allData = jsonDecode(allText) as Map<String, dynamic>;
    final reviewData = jsonDecode(reviewText) as Map<String, dynamic>;

    _records = _parseRecords(allData['records']);
    _reviewCandidates = _parseRecords(reviewData['records']);

    retrievedAt = DateTime.tryParse(
      allData['retrieved_at']?.toString() ?? '',
    );

    _loaded = true;
  }

  List<Map<String, dynamic>> _parseRecords(dynamic value) {
    if (value is! List) return [];

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  List<String> get categories {
    final values = <String>{};

    for (final record in _records) {
      final subjects = record['subjects'];

      if (subjects is List) {
        for (final subject in subjects) {
          values.add(subject.toString());
        }
      }
    }

    final result = values.toList()..sort();
    return result;
  }

  List<Map<String, dynamic>> search({
    String query = '',
    String? category,
    bool reviewOnly = false,
  }) {
    final source = reviewOnly ? _reviewCandidates : _records;
    final normalized = query.trim().toLowerCase();

    return source.where((record) {
      final subjects = record['subjects'];

      final matchesCategory = category == null ||
          category.isEmpty ||
          (subjects is List &&
              subjects.any((value) => value.toString() == category));

      if (!matchesCategory) return false;

      if (normalized.isEmpty) return true;

      final searchable = [
        record['title'],
        record['description'],
        record['details'],
        record['field_offices'],
        record['subjects'],
        record['uid'],
      ].map((value) => value?.toString() ?? '').join(' ').toLowerCase();

      return searchable.contains(normalized);
    }).toList();
  }

  Map<String, dynamic>? findByUid(String uid) {
    for (final record in _records) {
      if (record['uid']?.toString() == uid) {
        return record;
      }
    }
    return null;
  }
}
