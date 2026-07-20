import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/knowledge/data/knowledge_repository.dart';
import 'package:pool_os/features/knowledge/domain/models/knowledge_item.dart';

/// Search service for full-text and semantic search capabilities.
/// Completely independent - Pool OS calls only this service.
final knowledgeSearchServiceProvider = Provider<KnowledgeSearchService>((ref) {
  return KnowledgeSearchService(ref.watch(knowledgeRepositoryProvider));
});

class KnowledgeSearchService {
  final KnowledgeRepository _repository;

  KnowledgeSearchService(this._repository);

  /// Search by text query
  Future<List<KnowledgeItem>> search(String query, {KnowledgeType? type}) async {
    final all = await _repository.getAll();
    final normalizedQuery = query.toLowerCase().trim();
    
    if (normalizedQuery.isEmpty) return [];

    var results = all.where((item) {
      return item.title.toLowerCase().contains(normalizedQuery) ||
          item.titleVi.toLowerCase().contains(normalizedQuery) ||
          item.summary.toLowerCase().contains(normalizedQuery) ||
          item.keywords.any((k) => k.toLowerCase().contains(normalizedQuery));
    }).toList();

    if (type != null) {
      results = results.where((item) => item.type == type).toList();
    }

    return results;
  }

  /// Search by keywords
  Future<List<KnowledgeItem>> searchByKeywords(List<String> keywords) async {
    final all = await _repository.getAll();
    final normalizedKeywords = keywords.map((k) => k.toLowerCase()).toSet();
    
    if (normalizedKeywords.isEmpty) return [];

    return all.where((item) {
      return item.keywords.any((k) => 
        normalizedKeywords.any((nk) => k.toLowerCase().contains(nk))
      );
    }).toList();
  }

  /// Fuzzy search with typo tolerance
  Future<List<KnowledgeItem>> fuzzySearch(String query) async {
    final all = await _repository.getAll();
    final normalizedQuery = query.toLowerCase().trim();
    
    if (normalizedQuery.isEmpty) return [];

    return all.where((item) {
      return _fuzzyMatch(normalizedQuery, item.title.toLowerCase()) ||
          _fuzzyMatch(normalizedQuery, item.titleVi.toLowerCase()) ||
          _fuzzyMatch(normalizedQuery, item.summary.toLowerCase());
    }).toList();
  }

  /// Search by language (Vietnamese or English)
  Future<List<KnowledgeItem>> searchByLanguage(String query, bool isVietnamese) async {
    final all = await _repository.getAll();
    final normalizedQuery = query.toLowerCase().trim();
    
    if (normalizedQuery.isEmpty) return [];

    return all.where((item) {
      if (isVietnamese) {
        return item.titleVi.toLowerCase().contains(normalizedQuery) ||
            item.summary.toLowerCase().contains(normalizedQuery);
      } else {
        return item.title.toLowerCase().contains(normalizedQuery) ||
            item.summary.toLowerCase().contains(normalizedQuery);
      }
    }).toList();
  }

  /// Search by multiple criteria
  Future<List<KnowledgeItem>> advancedSearch({
    String? query,
    KnowledgeType? type,
    KnowledgeDifficulty? difficulty,
    String? category,
    List<String>? keywords,
  }) async {
    var results = await _repository.getAll();

    if (query != null && query.isNotEmpty) {
      final normalizedQuery = query.toLowerCase();
      results = results.where((item) {
        return item.title.toLowerCase().contains(normalizedQuery) ||
            item.titleVi.toLowerCase().contains(normalizedQuery) ||
            item.summary.toLowerCase().contains(normalizedQuery);
      }).toList();
    }

    if (type != null) {
      results = results.where((item) => item.type == type).toList();
    }

    if (difficulty != null) {
      results = results.where((item) => item.difficulty == difficulty).toList();
    }

    if (category != null && category.isNotEmpty) {
      results = results.where((item) => item.category == category).toList();
    }

    if (keywords != null && keywords.isNotEmpty) {
      final keywordSet = keywords.map((k) => k.toLowerCase()).toSet();
      results = results.where((item) {
        return item.keywords.any((k) => 
          keywordSet.any((nk) => k.toLowerCase().contains(nk))
        );
      }).toList();
    }

    return results;
  }

  /// Simple fuzzy matching (Levenshtein-based)
  bool _fuzzyMatch(String query, String text) {
    if (text.contains(query)) return true;
    
    // Allow 1-2 character tolerance for short queries
    if (query.length <= 4) {
      for (int i = 0; i <= text.length - query.length; i++) {
        if (_levenshteinDistance(query, text.substring(i, i + query.length)) <= 1) {
          return true;
        }
      }
    }
    return false;
  }

  /// Calculate Levenshtein distance between two strings
  int _levenshteinDistance(String s1, String s2) {
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<int> previousRow = List.generate(s2.length + 1, (i) => i);
    List<int> currentRow = List.filled(s2.length + 1, 0);

    for (int i = 0; i < s1.length; i++) {
      currentRow[0] = i + 1;
      for (int j = 0; j < s2.length; j++) {
        int insertions = previousRow[j + 1] + 1;
        int deletions = currentRow[j] + 1;
        int substitutions = previousRow[j] + (s1[i] == s2[j] ? 0 : 1);
        currentRow[j + 1] = [insertions, deletions, substitutions].reduce((a, b) => a < b ? a : b);
      }
      List<int> temp = previousRow;
      previousRow = currentRow;
      currentRow = temp;
    }

    return previousRow[s2.length];
  }
}
