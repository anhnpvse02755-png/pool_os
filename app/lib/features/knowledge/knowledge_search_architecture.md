# Knowledge Search Engine Architecture

## Overview

**Document Date:** 2026-07-17  
**Component:** Knowledge Search Engine  
**Type:** Local-only, rank-based search (No AI)

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Search Entry Points                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   quickSearch(query)          │  searchWithFilters(...)          │
│   └── Simple text search      │  └── Full featured search        │
│                               │                                  │
│   builder()                   │  Direct SearchQuery object        │
│   └── Fluent API builder      │                                  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     SearchQuery Parser                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   Query Syntax:                                                  │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │ vi:draw shot #fundamentals                              │   │
│   │ └── Language ─┘└─── Text ──┘└─── Tag ───┘              │   │
│   │                                                           │   │
│   │ en:bank shot difficulty:beginner category:bank            │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│   Parsed into SearchQuery object:                                │
│   - rawQuery, normalizedQuery                                    │
│   - language (vi/en)                                            │
│   - type, difficulty, category                                   │
│   - tags, aliases                                               │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                       SearchIndex                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   Loaded from: assets/knowledge/search_index.json                 │
│                                                                  │
│   ┌─────────────┐  ┌─────────────┐  ┌───────────────────┐     │
│   │ keywordsEn  │  │ keywordsVi  │  │     aliases       │     │
│   │  (1000+)    │  │   (750+)   │  │      (500+)       │     │
│   └─────────────┘  └─────────────┘  └───────────────────┘     │
│                                                                  │
│   Purpose:                                                      │
│   - Map search terms to canonical keywords                       │
│   - Expand aliases (e.g., "stroke" ↔ "swing")                   │
│   - Support Vietnamese keywords                                  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      SearchEngine                                │
├─────────────────────────────────────────────────────────────────┤
                                                                  │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                    Scoring Rules                         │   │
│   ├─────────────────────────────────────────────────────────┤   │
│   │ Field                │ Points │ Match Type              │   │
│   │ ─────────────────────┼────────┼────────────────────── │   │
│   │ Title (EN)           │   50   │ Exact > Prefix > Cont  │   │
│   │ Title (VI)           │   45   │ Exact > Prefix > Cont  │   │
│   │ Keywords             │   30   │ Any keyword match       │   │
│   │ Summary              │   20   │ Contains match         │   │
│   │ Purpose              │   15   │ Contains match         │   │
│   │ Category             │   10   │ Exact match           │   │
│   │ Skill ID             │   10   │ Exact match           │   │
│   │ Mistakes/Corrections │    5   │ Contains match        │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                    Bonus Rules                           │   │
│   ├─────────────────────────────────────────────────────────┤   │
│   │ Language Match    │  +20%  │ Vietnamese query, VI text  │   │
│   │ Difficulty Match  │  +10%  │ Exact difficulty match     │   │
│   │ Alias Match       │  +5%   │ Term found via alias      │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                    Match Types                          │   │
│   ├─────────────────────────────────────────────────────────┤   │
│   │ Exact   │ term == field      │ 1.0                     │   │
│   │ Prefix  │ field.startsWith   │ 0.8                     │   │
│   │ Suffix  │ field.endsWith    │ 0.7                     │   │
│   │ Contains│ field.contains     │ 0.5                     │   │
│   │ Fuzzy   │ Levenshtein ≤ 1   │ 0.3                     │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     SearchResult                                 │
├─────────────────────────────────────────────────────────────────┤
                                                                  │
│   Result:                                                        │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │ SearchResult {                                         │   │
│   │   item: KnowledgeItem          // The matched item       │   │
│   │   score: 85.5                 // Total relevance score   │   │
│   │   matchedTerms: ['draw', 'draw shot', 'backspin']      │   │
│   │   scoreBreakdown: {                                  │   │
│   │     title: 50,                                       │   │
│   │     keywords: 24,                                    │   │
│   │     languageBonus: 11.5                               │   │
│   │   }                                                  │   │
│   │ }                                                     │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│   Output: Sorted by score descending                             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Components

### 1. SearchIndex

**Purpose:** Pre-loaded index from `search_index.json`

**Data Structure:**

```dart
class SearchIndex {
  final Map<String, List<String>> keywordsEn;  // "stroke" → ["stroke", "swing", "hit"]
  final Map<String, List<String>> keywordsVi;  // "động tác" → ["stroke", "đánh"]
  final Map<String, List<String>> aliases;     // "swing" ↔ "stroke"
  final Set<String> supportedLanguages;          // {'en', 'vi'}
}
```

**Loading:**
- Lazy loaded on first search
- Cached in memory (`_instance`)
- Loads from `assets/knowledge/search_index.json`

### 2. SearchQuery

**Purpose:** Parsed query representation

**Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `rawQuery` | String | Original query text |
| `normalizedQuery` | String | Lowercase, trimmed |
| `language` | String? | 'vi' or 'en' |
| `type` | KnowledgeType? | Filter by type |
| `difficulty` | KnowledgeDifficulty? | Filter by difficulty |
| `category` | String? | Filter by category |
| `tags` | List<String> | #hashtag filters |
| `learningPathId` | String? | Filter by path |
| `aliases` | List<String> | Expanded search terms |

**Query Syntax:**

```
[language:][search terms] [#tag1] [#tag2]
```

Examples:
- `draw shot` → Basic search
- `vi:đánh băng` → Vietnamese search
- `bank shot #beginner` → With tag filter
- `en:draw difficulty:beginner` → With difficulty filter

### 3. SearchResult

**Purpose:** Ranked search result

**Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `item` | KnowledgeItem | Matched knowledge item |
| `score` | double | Total relevance score |
| `matchedTerms` | List<String> | Terms that matched |
| `scoreBreakdown` | Map<String, double> | Per-field scores |

### 4. KnowledgeSearchEngine

**Purpose:** Core search logic

**Main Methods:**

| Method | Description |
|--------|-------------|
| `quickSearch(query)` | Simple text search |
| `search(query)` | Full query with filters |
| `searchWithFilters(...)` | Multi-criteria search |
| `builder()` | Fluent query builder |

---

## Scoring Algorithm

### Step 1: Filter Check

Before scoring, items are filtered:

```dart
if (query.type != null && item.type != query.type) → score = 0
if (query.difficulty != null && item.difficulty != query.difficulty) → score = 0
if (query.category != null && item.category != query.category) → score = 0
if (query.tags.isNotEmpty && !item matches any tag) → score = 0
```

### Step 2: Term Expansion

Query terms are expanded using aliases:

```
Input: "swing"
Expanded: ["swing", "stroke", "delivery", "hit", "punch"]
```

### Step 3: Field Scoring

Each field contributes to the score:

```
Total Score = Σ(field_score × field_weight)
```

### Step 4: Bonus Application

After base scoring:

```dart
if (query.language == 'vi' && item.titleVi.isNotEmpty) {
  score *= 1.2;  // +20% for language match
}

if (query.difficulty != null && item.difficulty == query.difficulty) {
  score *= 1.1;  // +10% for difficulty match
}
```

### Step 5: Ranking

Results sorted by `score` descending.

---

## Performance

### Caching Strategy

| Component | Strategy |
|-----------|----------|
| SearchIndex | Lazy load, singleton |
| Repository | In-memory cache after first load |
| Results | Not cached (dynamic per query) |

### Complexity

| Operation | Complexity |
|-----------|------------|
| Load Index | O(n) where n = index entries |
| Search | O(k × m) where k = items, m = fields |
| Sort | O(k log k) where k = results |

### Optimizations

1. **Early termination**: Filters applied before scoring
2. **Partial matching**: Only scores highest field match
3. **Lazy loading**: Index loaded on first search only
4. **Set operations**: Use `Set` for duplicate elimination

---

## Usage Examples

### Basic Search

```dart
final engine = ref.read(knowledgeSearchEngineProvider);
final results = await engine.quickSearch('draw shot');

// Results sorted by relevance
for (final result in results) {
  print('${result.item.title}: ${result.score}');
}
```

### Advanced Search

```dart
final results = await engine.searchWithFilters(
  query: 'bank shot',
  language: 'en',
  type: KnowledgeType.technique,
  difficulty: KnowledgeDifficulty.beginner,
  category: 'bank',
);
```

### Fluent Builder

```dart
final results = await engine.builder()
    .query('stroke')
    .language('en')
    .type(KnowledgeType.technique)
    .difficulty(KnowledgeDifficulty.beginner)
    .tags(['fundamentals'])
    .execute();
```

### With Vietnamese

```dart
// Explicit Vietnamese search
final results = await engine.searchWithFilters(
  query: 'đánh băng',
  language: 'vi',
);

// Or use query syntax
final results = await engine.quickSearch('vi:đánh băng');
```

### Tag Filtering

```dart
// Using # syntax
final results = await engine.quickSearch('shot #fundamentals #beginner');
```

---

## Extension Methods

### SearchResultList

```dart
// Get top 5
results.top(5);

// Filter by minimum score
results.above(50.0);

// Get just items
results.toItems();
```

---

## Future Enhancements

| Feature | Priority | Status |
|---------|----------|--------|
| Phrase search ("exact phrase") | HIGH | Future |
| Negation (NOT query) | MEDIUM | Future |
| Field-specific search (title:stroke) | HIGH | Future |
| TF-IDF ranking | MEDIUM | Future |
| Search analytics | LOW | Future |

---

## Files

| File | Purpose |
|------|---------|
| `knowledge_search_engine.dart` | Core search engine |
| `knowledge_repository.dart` | Data access |
| `knowledge_item.dart` | Domain model |
| `search_index.json` | Alias/keyword data |

---

*Generated: 2026-07-17*
*Pool OS Knowledge Search Engine v1.0*
