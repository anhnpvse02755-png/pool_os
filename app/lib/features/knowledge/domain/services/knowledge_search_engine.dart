import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/knowledge/data/knowledge_repository.dart';
import 'package:pool_os/features/knowledge/domain/models/knowledge_item.dart';

/// RFC-KB-SEARCH — Knowledge Search Engine
/// 
/// Fully local, rank-based search engine with no AI.
/// Supports: keywords, partial match, Vietnamese/English, aliases, tags, 
/// categories, difficulty, and learning path filtering.
/// 
/// Architecture:
/// 1. SearchIndex - Loads alias/keyword mappings from search_index.json
/// 2. SearchEngine - Core ranking algorithm
/// 3. SearchQuery - Parsed query with filters
/// 4. SearchResult - Ranked result with relevance score

// ===== PROVIDERS =====

final knowledgeSearchEngineProvider = Provider<KnowledgeSearchEngine>((ref) {
  return KnowledgeSearchEngine(ref.watch(knowledgeRepositoryProvider));
});

// ===== SEARCH INDEX =====

/// Loaded from assets/knowledge/search_index.json
class SearchIndex {
  final Map<String, List<String>> keywordsEn;
  final Map<String, List<String>> keywordsVi;
  final Map<String, List<String>> aliases;
  final Set<String> supportedLanguages;

  const SearchIndex({
    required this.keywordsEn,
    required this.keywordsVi,
    required this.aliases,
    required this.supportedLanguages,
  });

  static SearchIndex? _instance;
  
  static Future<SearchIndex> load() async {
    if (_instance != null) return _instance!;
    
    try {
      final raw = await rootBundle.loadString('assets/knowledge/search_index.json');
      final json = jsonDecode(raw) as Map<String, dynamic>;
      
      final keywordsEn = <String, List<String>>{};
      final keywordsVi = <String, List<String>>{};
      final aliases = <String, List<String>>{};
      
      // Parse English keywords
      final keywordsJsonEn = json['searchKeywords']?['en'] as Map<String, dynamic>?;
      if (keywordsJsonEn != null) {
        for (final entry in keywordsJsonEn.entries) {
          keywordsEn[entry.key] = (entry.value as List).map((e) => e.toString()).toList();
        }
      }
      
      // Parse Vietnamese keywords
      final keywordsJsonVi = json['searchKeywords']?['vi'] as Map<String, dynamic>?;
      if (keywordsJsonVi != null) {
        for (final entry in keywordsJsonVi.entries) {
          keywordsVi[entry.key] = (entry.value as List).map((e) => e.toString()).toList();
        }
      }
      
      // Parse synonyms/aliases
      final synonymsJson = json['synonyms'] as Map<String, dynamic>?;
      if (synonymsJson != null) {
        for (final entry in synonymsJson.entries) {
          aliases[entry.key] = (entry.value as List).map((e) => e.toString()).toList();
        }
      }
      
      final supportedLangs = (json['metadata']?['supportedLanguages'] as List?)
          ?.map((e) => e.toString())
          .toSet() ?? {'en', 'vi'};
      
      _instance = SearchIndex(
        keywordsEn: keywordsEn,
        keywordsVi: keywordsVi,
        aliases: aliases,
        supportedLanguages: supportedLangs,
      );
      
      return _instance!;
    } catch (e) {
      // Return empty index on error
      _instance = const SearchIndex(
        keywordsEn: {},
        keywordsVi: {},
        aliases: {},
        supportedLanguages: {'en', 'vi'},
      );
      return _instance!;
    }
  }

  /// Get all terms for a keyword (includes aliases)
  List<String> getTerms(String keyword) {
    final terms = <String>[keyword];
    final lowerKeyword = keyword.toLowerCase();
    
    // Add aliases
    for (final entry in aliases.entries) {
      if (entry.value.any((a) => a.toLowerCase() == lowerKeyword)) {
        terms.add(entry.key);
        terms.addAll(entry.value);
      }
    }
    
    // Add keyword mappings
    for (final entry in keywordsEn.entries) {
      if (entry.value.any((k) => k.toLowerCase() == lowerKeyword)) {
        terms.add(entry.key);
      }
    }
    
    return terms.toSet().toList();
  }
}

// ===== SEARCH QUERY =====

/// Represents a parsed search query
class SearchQuery {
  final String rawQuery;
  final String normalizedQuery;
  final String? language;
  final KnowledgeType? type;
  final KnowledgeDifficulty? difficulty;
  final String? category;
  final List<String> tags;
  final String? learningPathId;
  final List<String> aliases;

  const SearchQuery({
    required this.rawQuery,
    required this.normalizedQuery,
    this.language,
    this.type,
    this.difficulty,
    this.category,
    this.tags = const [],
    this.learningPathId,
    this.aliases = const [],
  });

  bool get hasTextQuery => normalizedQuery.isNotEmpty;
  bool get hasFilters => type != null || difficulty != null || category != null || tags.isNotEmpty;
  bool get isEmpty => !hasTextQuery && !hasFilters && learningPathId == null;
}

// ===== SEARCH RESULT =====

/// A ranked search result
class SearchResult {
  final KnowledgeItem item;
  final double score;
  final List<String> matchedTerms;
  final Map<String, double> scoreBreakdown;

  const SearchResult({
    required this.item,
    required this.score,
    required this.matchedTerms,
    required this.scoreBreakdown,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchResult &&
          runtimeType == other.runtimeType &&
          item.id == other.item.id;

  @override
  int get hashCode => item.id.hashCode;
}

// ===== SEARCH ENGINE =====

class KnowledgeSearchEngine {
  final KnowledgeRepository _repository;
  SearchIndex? _index;

  KnowledgeSearchEngine(this._repository);

  /// Initialize the search index
  Future<void> initialize() async {
    _index = await SearchIndex.load();
  }

  /// Main search method - returns ranked results
  Future<List<SearchResult>> search(SearchQuery query) async {
    if (query.isEmpty) return [];
    
    await initialize();
    final all = await _repository.getAll();
    final results = <SearchResult>[];
    
    for (final item in all) {
      final result = _scoreItem(item, query);
      if (result.score > 0) {
        results.add(result);
      }
    }
    
    // Sort by score descending
    results.sort((a, b) => b.score.compareTo(a.score));
    
    return results;
  }

  /// Quick search with default options
  Future<List<SearchResult>> quickSearch(String query) async {
    return search(SearchQuery(
      rawQuery: query,
      normalizedQuery: _normalize(query),
    ));
  }

  /// Build query from text with filters
  Future<List<SearchResult>> searchWithFilters({
    required String query,
    String? language,
    KnowledgeType? type,
    KnowledgeDifficulty? difficulty,
    String? category,
    List<String>? tags,
    String? learningPathId,
  }) async {
    final parsedQuery = await _parseQuery(query);
    
    return search(SearchQuery(
      rawQuery: query,
      normalizedQuery: _normalize(query),
      language: language ?? parsedQuery.language,
      type: type,
      difficulty: difficulty,
      category: category,
      tags: tags ?? parsedQuery.tags,
      learningPathId: learningPathId,
      aliases: parsedQuery.aliases,
    ));
  }

  /// Parse query for special syntax
  Future<SearchQuery> _parseQuery(String query) async {
    await initialize();
    final index = _index!;
    
    String normalized = query;
    String? language;
    List<String> tags = [];
    List<String> aliases = [];
    
    // Check for language prefix
    if (query.startsWith('vi:')) {
      language = 'vi';
      normalized = query.substring(3).trim();
    } else if (query.startsWith('en:')) {
      language = 'en';
      normalized = query.substring(3).trim();
    }
    
    // Extract tags (#tag)
    final tagRegex = RegExp(r'#(\w+)');
    final tagMatches = tagRegex.allMatches(normalized);
    for (final match in tagMatches) {
      tags.add(match.group(1)!);
    }
    normalized = normalized.replaceAll(tagRegex, '').trim();
    
    // Expand aliases
    if (index != null) {
      final terms = index.getTerms(normalized);
      aliases = terms;
    }
    
    return SearchQuery(
      rawQuery: query,
      normalizedQuery: _normalize(normalized),
      language: language,
      tags: tags,
      aliases: aliases,
    );
  }

  /// Score a single item against a query
  SearchResult _scoreItem(KnowledgeItem item, SearchQuery query) {
    final breakdown = <String, double>{};
    double totalScore = 0;
    final matchedTerms = <String>[];
    
    // Apply filters first - items not matching filters get score 0
    if (query.type != null && item.type != query.type) {
      return SearchResult(item: item, score: 0, matchedTerms: [], scoreBreakdown: {});
    }
    if (query.difficulty != null && item.difficulty != query.difficulty) {
      return SearchResult(item: item, score: 0, matchedTerms: [], scoreBreakdown: {});
    }
    if (query.category != null && item.category != query.category) {
      return SearchResult(item: item, score: 0, matchedTerms: [], scoreBreakdown: {});
    }
    if (query.tags.isNotEmpty) {
      final hasMatchingTag = query.tags.any((tag) => 
        item.keywords.any((k) => k.toLowerCase().contains(tag.toLowerCase()))
      );
      if (!hasMatchingTag) {
        return SearchResult(item: item, score: 0, matchedTerms: [], scoreBreakdown: {});
      }
    }
    
    if (!query.hasTextQuery) {
      // No text query, return items matching filters with base score
      return SearchResult(
        item: item,
        score: 1.0,
        matchedTerms: [],
        scoreBreakdown: {'filter_match': 1.0},
      );
    }
    
    final searchTerms = _getSearchTerms(query);
    
    // ===== SCORING RULES =====
    
    // 1. Exact title match (highest priority) - 50 points
    final titleScore = _scoreFieldMatch(item.title, searchTerms);
    if (titleScore > 0) {
      breakdown['title'] = titleScore * 50;
      totalScore += breakdown['title']!;
      matchedTerms.addAll(_getMatchedTerms(item.title, searchTerms));
    }
    
    // 2. Vietnamese title match - 45 points
    final titleViScore = _scoreFieldMatch(item.titleVi, searchTerms);
    if (titleViScore > 0) {
      breakdown['titleVi'] = titleViScore * 45;
      totalScore += breakdown['titleVi']!;
      matchedTerms.addAll(_getMatchedTerms(item.titleVi, searchTerms));
    }
    
    // 3. Keywords match - 30 points
    final keywordScore = _scoreFieldListMatch(item.keywords, searchTerms);
    if (keywordScore > 0) {
      breakdown['keywords'] = keywordScore * 30;
      totalScore += breakdown['keywords']!;
      matchedTerms.addAll(_getMatchedTermsFromList(item.keywords, searchTerms));
    }
    
    // 4. Summary match - 20 points
    final summaryScore = _scoreFieldMatch(item.summary, searchTerms);
    if (summaryScore > 0) {
      breakdown['summary'] = summaryScore * 20;
      totalScore += breakdown['summary']!;
      matchedTerms.addAll(_getMatchedTerms(item.summary, searchTerms));
    }
    
    // 5. Purpose match - 15 points
    final purposeScore = _scoreFieldMatch(item.purpose, searchTerms);
    if (purposeScore > 0) {
      breakdown['purpose'] = purposeScore * 15;
      totalScore += breakdown['purpose']!;
      matchedTerms.addAll(_getMatchedTerms(item.purpose, searchTerms));
    }
    
    // 6. Category match - 10 points
    final categoryScore = _scoreFieldMatch(item.category, searchTerms);
    if (categoryScore > 0) {
      breakdown['category'] = categoryScore * 10;
      totalScore += breakdown['category']!;
    }
    
    // 7. Skill ID match - 10 points
    if (item.skillId != null) {
      final skillScore = _scoreFieldMatch(item.skillId!, searchTerms);
      if (skillScore > 0) {
        breakdown['skillId'] = skillScore * 10;
        totalScore += breakdown['skillId']!;
      }
    }
    
    // 8. Common mistakes/corrections match - 5 points
    final mistakesScore = _scoreFieldListMatch(item.commonMistakes, searchTerms);
    if (mistakesScore > 0) {
      breakdown['commonMistakes'] = mistakesScore * 5;
      totalScore += breakdown['commonMistakes']!;
    }
    
    // ===== BONUS RULES =====
    
    // Language bonus
    if (query.language == 'vi' && item.titleVi.isNotEmpty) {
      totalScore *= 1.2;
      breakdown['languageBonus'] = totalScore * 0.2;
    }
    
    // Difficulty bonus for exact match
    if (query.difficulty != null && item.difficulty == query.difficulty) {
      totalScore *= 1.1;
      breakdown['difficultyBonus'] = totalScore * 0.1;
    }
    
    return SearchResult(
      item: item,
      score: totalScore,
      matchedTerms: matchedTerms.toSet().toList(),
      scoreBreakdown: breakdown,
    );
  }

  /// Get search terms including aliases
  List<String> _getSearchTerms(SearchQuery query) {
    final terms = <String>[query.normalizedQuery];
    
    if (_index != null) {
      // Add expanded terms from aliases
      terms.addAll(_index!.getTerms(query.normalizedQuery));
      
      // Add Vietnamese terms if searching in Vietnamese
      if (query.language == 'vi') {
        final viTerms = _index!.keywordsVi.entries
            .where((e) => e.value.any((v) => v.contains(query.normalizedQuery)))
            .map((e) => e.key)
            .toList();
        terms.addAll(viTerms);
      }
    }
    
    // Add partial matches
    if (query.normalizedQuery.length >= 2) {
      terms.add('${query.normalizedQuery}%'); // prefix match
    }
    
    return terms.toSet().toList();
  }

  /// Score field match (exact + partial)
  double _scoreFieldMatch(String field, List<String> terms) {
    if (field.isEmpty) return 0;
    
    final lowerField = field.toLowerCase();
    double score = 0;
    
    for (final term in terms) {
      // Exact match
      if (lowerField.contains(term.toLowerCase())) {
        if (term.toLowerCase() == lowerField) {
          score += 1.0; // Exact
        } else if (lowerField.startsWith(term.toLowerCase())) {
          score += 0.8; // Prefix
        } else if (lowerField.endsWith(term.toLowerCase())) {
          score += 0.7; // Suffix
        } else {
          score += 0.5; // Contains
        }
      }
      
      // Partial match (2+ character tolerance)
      if (term.length >= 3 && !term.endsWith('%')) {
        for (int i = 0; i <= lowerField.length - term.length; i++) {
          if (_isPartialMatch(term.toLowerCase(), lowerField.substring(i, i + term.length))) {
            score += 0.3;
            break;
          }
        }
      }
    }
    
    return score > 0 ? (score / terms.length).clamp(0, 1) : 0;
  }

  /// Score list field match
  double _scoreFieldListMatch(List<String> fields, List<String> terms) {
    if (fields.isEmpty) return 0;
    
    double maxScore = 0;
    for (final field in fields) {
      final score = _scoreFieldMatch(field, terms);
      if (score > maxScore) {
        maxScore = score;
      }
    }
    return maxScore;
  }

  /// Check partial match (Levenshtein-based)
  bool _isPartialMatch(String term, String text) {
    if (text.contains(term)) return true;
    
    // Allow small differences for fuzzy matching
    if (term.length <= 5) {
      return _levenshteinDistance(term, text) <= 1;
    }
    return false;
  }

  /// Get matched terms from a field
  List<String> _getMatchedTerms(String field, List<String> terms) {
    final matched = <String>[];
    final lowerField = field.toLowerCase();
    
    for (final term in terms) {
      if (lowerField.contains(term.toLowerCase())) {
        matched.add(term);
      }
    }
    
    return matched;
  }

  /// Get matched terms from a list
  List<String> _getMatchedTermsFromList(List<String> fields, List<String> terms) {
    final matched = <String>[];
    for (final field in fields) {
      matched.addAll(_getMatchedTerms(field, terms));
    }
    return matched;
  }

  /// Normalize query string
  String _normalize(String query) {
    return query
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Levenshtein distance
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

// ===== SEARCH HELPERS =====

extension SearchResultList on List<SearchResult> {
  /// Get top N results
  List<SearchResult> top(int n) => take(n).toList();
  
  /// Filter by minimum score
  List<SearchResult> above(double minScore) => 
      where((r) => r.score >= minScore).toList();
  
  /// Get only items
  List<KnowledgeItem> toItems() => map((r) => r.item).toList();
}

extension SearchQueryBuilder on KnowledgeSearchEngine {
  /// Start building a search query
  SearchQueryBuilderState builder() => SearchQueryBuilderState(this);
}

class SearchQueryBuilderState {
  final KnowledgeSearchEngine _engine;
  String _query = '';
  String? _language;
  KnowledgeType? _type;
  KnowledgeDifficulty? _difficulty;
  String? _category;
  List<String> _tags = [];
  String? _learningPathId;

  SearchQueryBuilderState(this._engine);

  SearchQueryBuilderState query(String q) {
    _query = q;
    return this;
  }

  SearchQueryBuilderState language(String lang) {
    _language = lang;
    return this;
  }

  SearchQueryBuilderState type(KnowledgeType type) {
    _type = type;
    return this;
  }

  SearchQueryBuilderState difficulty(KnowledgeDifficulty difficulty) {
    _difficulty = difficulty;
    return this;
  }

  SearchQueryBuilderState category(String category) {
    _category = category;
    return this;
  }

  SearchQueryBuilderState tags(List<String> tags) {
    _tags = tags;
    return this;
  }

  SearchQueryBuilderState learningPath(String pathId) {
    _learningPathId = pathId;
    return this;
  }

  Future<List<SearchResult>> execute() {
    return _engine.searchWithFilters(
      query: _query,
      language: _language,
      type: _type,
      difficulty: _difficulty,
      category: _category,
      tags: _tags,
      learningPathId: _learningPathId,
    );
  }
}
