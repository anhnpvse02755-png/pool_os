// EPIC 05 §2.3 — Search facets + Recent + History + deterministic Ranking.
//
// Spec §2.3:
//   - Full-text Search          (existing [KnowledgeSearchService.search])
//   - Keyword Search            (existing [KnowledgeSearchService.searchByKeywords])
//   - Alias Search              (existing)
//   - Tag Search                (existing)
//   - Category Filter           (existing)
//   - Difficulty Filter         (existing [KnowledgeSearchService.advancedSearch])
//   - Language Filter           (existing [KnowledgeSearchService.searchByLanguage])
//   - Recent Search             (this file)
//   - Search History            (this file)
//   - Search Result Ranking     (this file)
//
// PO 2026-07-31 — no AI ranking. All scores are deterministic counts of
// matches over the existing asset; no heuristic learning.
//
// This facets module is independent of the existing
// `KnowledgeSearchService` and operates on plain callback-based item
// projections. The existing service continues to surface full-text and
// alias search; facets + Recent + History + Ranking sit on top as a
// pure adapter.

/// One row of the user's recent-search list. Stored in-memory per session.
/// Read-only by callers; never persisted to disk in Beta (Beta stays
/// session-local for ephemeral UX signals — this matches the EPIC 05
/// read-only constraint for cross-feature surfaces).
class RecentSearchEntry {
  final String query;
  final DateTime timestamp;
  const RecentSearchEntry({required this.query, required this.timestamp});
}

/// A scored search result, surfaced in deterministic order (score desc,
/// then id asc for stability).
class ScoredSearchResult<T> {
  final T item;
  final int score;
  const ScoredSearchResult({required this.item, required this.score});
}

/// Lightweight, deterministic scoring over a free-text query and an item
/// that already exposes title / tags / keywords / aliases as plain strings.
///
///   score = match-counts
///         + 3 if any token is exact-prefix in title
///         + 2 if any token is exact-substring in title
///         + 1 per token matching a tag or keyword
///
/// No machine-learning, no embeddings, no semantic distance.
class DeterministicSearchRanker {
  /// Rank [items] against [query]. Items must expose text via the [titleOf],
  /// [aliasesOf], [tagsOf], and [keywordsOf] callbacks.
  static List<ScoredSearchResult<T>> rank<T>({
    required String query,
    required Iterable<T> items,
    required String Function(T) titleOf,
    required List<String> Function(T) aliasesOf,
    required List<String> Function(T) tagsOf,
    required List<String> Function(T) keywordsOf,
  }) {
    final tokens = _tokenize(query);
    if (tokens.isEmpty) {
      return [for (final i in items) ScoredSearchResult(item: i, score: 0)];
    }
    final scored = <ScoredSearchResult<T>>[];
    for (final item in items) {
      final title = titleOf(item).toLowerCase();
      final tags = tagsOf(item).map((s) => s.toLowerCase()).toList();
      final keywords =
          keywordsOf(item).map((s) => s.toLowerCase()).toList();
      final aliases =
          aliasesOf(item).map((s) => s.toLowerCase()).toList();

      var score = 0;
      for (final t in tokens) {
        if (title.startsWith(t)) {
          score += 3;
        } else if (title.contains(t)) {
          score += 2;
        }
        if (tags.contains(t)) score += 1;
        if (keywords.contains(t)) score += 1;
        if (aliases.any((a) => a.contains(t))) score += 1;
      }
      if (score > 0) scored.add(ScoredSearchResult(item: item, score: score));
    }
    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return titleOf(a.item).compareTo(titleOf(b.item));
    });
    return scored;
  }

  static List<String> _tokenize(String query) {
    return query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.trim().isNotEmpty)
        .toList();
  }
}

/// In-memory recent-search list. Bounded to [maxEntries] (default 10).
/// Read-only callers do not mutate; the service [recordSearch] entry is
/// the single writer.
class RecentSearchLog {
  final List<RecentSearchEntry> _entries;
  final int maxEntries;

  RecentSearchLog({List<RecentSearchEntry>? initial, this.maxEntries = 10})
      : _entries = List.of(initial ?? const <RecentSearchEntry>[]);

  List<RecentSearchEntry> get entries =>
      List.unmodifiable(_entries.reversed);

  /// Append [query] at the head. De-duplicates (case-insensitive) and
  /// trims to [maxEntries]. Pure deterministic operation.
  void recordSearch(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    _entries.removeWhere((e) => e.query.toLowerCase() == q.toLowerCase());
    _entries.add(RecentSearchEntry(query: q, timestamp: DateTime.now()));
    while (_entries.length > maxEntries) {
      _entries.removeAt(0);
    }
  }
}

/// Public façade for facets + Recent + History. UI consumers
/// instantiate this layer with their own ranking strategies; it does
/// NOT depend on the legacy `KnowledgeSearchService`. Future post-Beta
/// work that needs the legacy service can re-introduce the dependency
/// here behind a capability check.
class KnowledgeSearchFacets {
  final RecentSearchLog recent;

  KnowledgeSearchFacets({
    RecentSearchLog? recent,
  }) : recent = recent ?? RecentSearchLog();
}