import '../loaders/knowledge_asset_loader.dart';
import '../models/models.dart';

/// Service for searching knowledge items.
///
/// Provides full-text search with filters, caching, and relevance ranking.
///
/// ```dart
/// final search = BilliardKnowledge.instance.searchService;
///
/// // Simple search
/// final results = await search.search('draw shot');
///
/// // Advanced search with filters
/// final results = await search.search(
///   'stroke',
///   type: KnowledgeType.technique,
///   difficulty: KnowledgeDifficulty.beginner,
/// );
/// ```
class KnowledgeSearchService {
  final KnowledgeRepository repository;
  final KnowledgeAssetLoader _assetLoader;

  bool _searchIndexLoaded = false;
  bool _cacheEnabled = true;
  
  // Search index
  final Map<String, List<SearchIndexEntry>> _keywordIndex = {};
  final Map<String, SearchIndexEntry> _itemIndex = {};
  
  // Cache
  final Map<String, List<SearchResult>> _resultCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const _cacheTTL = Duration(hours: 1);
  static const _maxCacheSize = 100;

  KnowledgeSearchService({
    required KnowledgeRepository repository,
    required KnowledgeAssetLoader assetLoader,
  })  : repository = repository,
        _assetLoader = assetLoader;

  /// Load the search index.
  /// 
  /// Called automatically by [BilliardKnowledge.initialize].
  Future<void> loadSearchIndex() async {
    if (_searchIndexLoaded) return;

    final index = await _assetLoader.loadSearchIndex();
    _buildKeywordIndex(index);
    
    _searchIndexLoaded = true;
  }

  /// Search for knowledge items.
  /// 
  /// ```dart
  /// final results = await search.search('draw shot');
  /// for (final result in results) {
  ///   print('${result.item.title}: ${result.score}');
  /// }
  /// ```
  Future<List<SearchResult>> search(
    String query, {
    KnowledgeType? type,
    KnowledgeDifficulty? difficulty,
    String? category,
    List<String>? tags,
    int limit = 20,
    int offset = 0,
  }) async {
    if (query.isEmpty) return [];

    // Check cache
    final cacheKey = _generateCacheKey(query, type, difficulty, category, tags, limit, offset);
    if (_cacheEnabled) {
      final cached = _getCached(cacheKey);
      if (cached != null) return cached;
    }

    // Ensure search index is loaded
    if (!_searchIndexLoaded) {
      await loadSearchIndex();
    }

    // Build query
    final searchQuery = SearchQuery(
      query: query,
      type: type,
      difficulty: difficulty,
      category: category,
      tags: tags,
      limit: limit,
      offset: offset,
    );

    // Execute search
    final results = await _executeSearch(searchQuery);

    // Cache results
    if (_cacheEnabled) {
      _cacheResults(cacheKey, results);
    }

    return results;
  }

  /// Get search suggestions (autocomplete).
  /// 
  /// ```dart
  /// final suggestions = await search.suggestions('str');
  /// // ['stroke', 'stance', 'strategy']
  /// ```
  Future<List<String>> suggestions(String prefix) async {
    if (prefix.isEmpty) return [];
    if (!_searchIndexLoaded) await loadSearchIndex();

    final lowerPrefix = prefix.toLowerCase();
    final suggestions = <String>{};

    // Find matching keywords
    for (final keyword in _keywordIndex.keys) {
      if (keyword.startsWith(lowerPrefix)) {
        suggestions.add(keyword);
        if (suggestions.length >= 10) break;
      }
    }

    return suggestions.toList()..sort();
  }

  /// Get trending/popular searches.
  /// 
  /// ```dart
  /// final trending = await search.trending();
  /// ```
  Future<List<String>> trending() async {
    // Return popular search terms (could be stored in preferences)
    return ['stance', 'draw shot', 'break', 'aiming', 'bridge'];
  }

  /// Enable or disable search caching.
  void setCacheEnabled(bool enabled) {
    _cacheEnabled = enabled;
    if (!enabled) {
      _resultCache.clear();
    }
  }

  /// Clear search cache.
  void clearCache() {
    _resultCache.clear();
    _cacheTimestamps.clear();
  }

  // ===== Private Methods =====

  void _buildKeywordIndex(SearchIndexData data) {
    _keywordIndex.clear();
    _itemIndex.clear();

    // Build keyword -> items index
    for (final entry in data.entries) {
      for (final keyword in entry.keywords) {
        _keywordIndex.putIfAbsent(keyword.toLowerCase(), () => []).add(entry);
      }
      _itemIndex[entry.id] = entry;
    }
  }

  Future<List<SearchResult>> _executeSearch(SearchQuery query) async {
    final queryTerms = _tokenize(query.query);
    final scored = <String, double>{};
    final matchedFields = <String, List<String>>{};

    // Score each item
    for (final itemId in _itemIndex.keys) {
      final entry = _itemIndex[itemId]!;
      double score = 0;
      final fields = <String>[];

      for (final term in queryTerms) {
        // Title match (highest weight)
        if (entry.title.toLowerCase().contains(term)) {
          score += 30;
          fields.add('title');
        }

        // Keyword match
        for (final keyword in entry.keywords) {
          if (keyword.toLowerCase().contains(term)) {
            score += 20;
            fields.add('keywords');
          }
        }

        // Summary match
        if (entry.summary.toLowerCase().contains(term)) {
          score += 10;
          fields.add('summary');
        }

        // Vietnamese match
        if (entry.titleVi.toLowerCase().contains(term)) {
          score += 25;
          fields.add('titleVi');
        }
      }

      if (score > 0) {
        // Apply filters
        if (query.type != null && entry.type != query.type!.name) {
          continue;
        }
        if (query.difficulty != null && entry.difficulty != query.difficulty!.name) {
          continue;
        }
        if (query.category != null && entry.category != query.category) {
          continue;
        }

        scored[itemId] = score;
        matchedFields[itemId] = fields;
      }
    }

    // Sort by score
    final sorted = scored.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Build results
    final results = <SearchResult>[];
    final start = query.offset;
    final end = start + query.limit;

    for (int i = start; i < sorted.length && i < end; i++) {
      final itemId = sorted[i].key;
      final score = sorted[i].value;

      // Load full item for result
      final item = await repository.byId(itemId);
      if (item == null) continue;

      results.add(SearchResult(
        item: KnowledgeItemSummary.fromItem(item),
        score: (score / 100).clamp(0.0, 1.0),
        matchedFields: matchedFields[itemId] ?? [],
        highlights: _buildHighlights(item, queryTerms),
      ));
    }

    return results;
  }

  List<String> _tokenize(String query) {
    return query
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.length >= 2)
        .toList();
  }

  Map<String, String> _buildHighlights(KnowledgeItem item, List<String> terms) {
    final highlights = <String, String>{};

    for (final term in terms) {
      if (item.title.toLowerCase().contains(term)) {
        highlights['title'] = _highlight(item.title, term);
      }
      if (item.titleVi.isNotEmpty && item.titleVi.toLowerCase().contains(term)) {
        highlights['titleVi'] = _highlight(item.titleVi, term);
      }
    }

    return highlights;
  }

  String _highlight(String text, String term) {
    final regex = RegExp(term, caseSensitive: false);
    return text.replaceAllMapped(regex, (m) => '**${m.group(0)}**');
  }

  String _generateCacheKey(
    String query,
    KnowledgeType? type,
    KnowledgeDifficulty? difficulty,
    String? category,
    List<String>? tags,
    int limit,
    int offset,
  ) {
    return [
      query.toLowerCase().trim(),
      type?.name ?? '_',
      difficulty?.name ?? '_',
      category ?? '_',
      tags?.join(',') ?? '_',
      limit.toString(),
      offset.toString(),
    ].join('_');
  }

  List<SearchResult>? _getCached(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return null;

    if (DateTime.now().difference(timestamp) > _cacheTTL) {
      _resultCache.remove(key);
      _cacheTimestamps.remove(key);
      return null;
    }

    return _resultCache[key];
  }

  void _cacheResults(String key, List<SearchResult> results) {
    // Evict old entries if at capacity
    while (_resultCache.length >= _maxCacheSize) {
      final oldest = _cacheTimestamps.keys.first;
      _resultCache.remove(oldest);
      _cacheTimestamps.remove(oldest);
    }

    _resultCache[key] = results;
    _cacheTimestamps[key] = DateTime.now();
  }
}

/// Search index entry
class SearchIndexEntry {
  final String id;
  final String title;
  final String titleVi;
  final String summary;
  final String type;
  final String difficulty;
  final String category;
  final List<String> keywords;

  const SearchIndexEntry({
    required this.id,
    required this.title,
    required this.titleVi,
    required this.summary,
    required this.type,
    required this.difficulty,
    required this.category,
    required this.keywords,
  });

  factory SearchIndexEntry.fromJson(Map<String, dynamic> json) {
    return SearchIndexEntry(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      titleVi: json['titleVi'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      type: json['type'] as String? ?? 'other',
      difficulty: json['difficulty'] as String? ?? 'beginner',
      category: json['category'] as String? ?? '',
      keywords: (json['keywords'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

/// Search index data
class SearchIndexData {
  final List<SearchIndexEntry> entries;
  final String version;

  const SearchIndexData({
    required this.entries,
    required this.version,
  });

  factory SearchIndexData.fromJson(Map<String, dynamic> json) {
    return SearchIndexData(
      entries: (json['entries'] as List?)
          ?.map((e) => SearchIndexEntry.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      version: json['version'] as String? ?? '1.0.0',
    );
  }
}
