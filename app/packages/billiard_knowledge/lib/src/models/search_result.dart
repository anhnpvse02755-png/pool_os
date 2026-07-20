import 'knowledge_item.dart';
import 'knowledge_enums.dart';

/// Search result with relevance score
class SearchResult {
  /// The matched knowledge item
  final KnowledgeItemSummary item;

  /// Relevance score (0.0 - 1.0)
  final double score;

  /// Matched fields
  final List<String> matchedFields;

  /// Highlighted snippets
  final Map<String, String> highlights;

  const SearchResult({
    required this.item,
    required this.score,
    this.matchedFields = const [],
    this.highlights = const {},
  });

  SearchResult copyWith({
    KnowledgeItemSummary? item,
    double? score,
    List<String>? matchedFields,
    Map<String, String>? highlights,
  }) {
    return SearchResult(
      item: item ?? this.item,
      score: score ?? this.score,
      matchedFields: matchedFields ?? this.matchedFields,
      highlights: highlights ?? this.highlights,
    );
  }
}

/// Search query parameters
class SearchQuery {
  /// Search text
  final String query;

  /// Filter by type
  final KnowledgeType? type;

  /// Filter by difficulty
  final KnowledgeDifficulty? difficulty;

  /// Filter by category
  final String? category;

  /// Filter by tags
  final List<String>? tags;

  /// Filter by status
  final KnowledgeStatus? status;

  /// Maximum results
  final int limit;

  /// Offset for pagination
  final int offset;

  /// Sort order
  final SearchSortOrder sortBy;

  const SearchQuery({
    required this.query,
    this.type,
    this.difficulty,
    this.category,
    this.tags,
    this.status,
    this.limit = 20,
    this.offset = 0,
    this.sortBy = SearchSortOrder.relevance,
  });

  SearchQuery copyWith({
    String? query,
    KnowledgeType? type,
    KnowledgeDifficulty? difficulty,
    String? category,
    List<String>? tags,
    KnowledgeStatus? status,
    int? limit,
    int? offset,
    SearchSortOrder? sortBy,
  }) {
    return SearchQuery(
      query: query ?? this.query,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  /// Generate cache key
  String get cacheKey {
    final parts = <String>[
      query.toLowerCase().trim(),
      type?.name ?? '_',
      difficulty?.name ?? '_',
      category ?? '_',
      tags?.join(',') ?? '_',
      status?.name ?? '_',
      limit.toString(),
      offset.toString(),
      sortBy.name,
    ];
    return parts.join('_');
  }
}

/// Sort order for search results
enum SearchSortOrder {
  /// Sort by relevance (default)
  relevance,

  /// Sort by title
  title,

  /// Sort by difficulty
  difficulty,

  /// Sort by estimated time
  duration,
}
