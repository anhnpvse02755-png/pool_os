# Billiard Knowledge Module (BKM) - Search System

## Version 1.0
**Last Updated:** July 2026
**Status:** Production Specification

---

## 1. Search Architecture Overview

### 1.1 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          SEARCH ARCHITECTURE                                  │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                              │
│   User Query: "how to do a draw shot"                                         │
│                                                                              │
│                              ▼                                               │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                      QUERY PROCESSING LAYER                           │   │
│   │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                   │   │
│   │  │   Tokenizer │  │  Normalizer │  │  Language   │                   │   │
│   │  │             │──►│             │──►│  Detector  │                   │   │
│   │  └─────────────┘  └─────────────┘  └─────────────┘                   │   │
│   │                                                                      │   │
│   │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                   │   │
│   │  │   Alias     │  │   Fuzzy     │  │   Intent   │                   │   │
│   │  │   Resolver  │  │   Matcher   │  │   Classifier│                   │   │
│   │  └─────────────┘  └─────────────┘  └─────────────┘                   │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                              │                                               │
│                              ▼                                               │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                       SEARCH EXECUTION LAYER                          │   │
│   │                                                                      │   │
│   │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                   │   │
│   │  │    Full     │  │   Vector    │  │    Tag     │                   │   │
│   │  │    Text     │  │   Search    │  │   Search   │                   │   │
│   │  │  (Postgres) │  │  (Pinecone) │  │  (Filter)  │                   │   │
│   │  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘                   │   │
│   │         │                │                │                          │   │
│   │         └────────────────┼────────────────┘                          │   │
│   │                          ▼                                            │   │
│   │                  ┌─────────────┐                                       │   │
│   │                  │    Rank    │                                       │   │
│   │                  │  & Merge   │                                       │   │
│   │                  └──────┬─────┘                                       │   │
│   └─────────────────────────┼─────────────────────────────────────────────┘   │
│                              │                                               │
│                              ▼                                               │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                      RESULTS LAYER                                   │   │
│   │                                                                      │   │
│   │  ┌─────────────────────────────────────────────────────────────┐    │   │
│   │  │                     Response Builder                         │    │   │
│   │  │  • Terms with highlighted snippets                           │    │   │
│   │  │  • Related terms suggestions                                  │    │   │
│   │  │  • Did-you-mean corrections                                  │    │   │
│   │  │  • Category breadcrumb navigation                            │    │   │
│   │  └─────────────────────────────────────────────────────────────┘    │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Search Pipeline

```
INPUT: "úp bóng cơ bản" (Vietnamese)
                    │
                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ STEP 1: LANGUAGE DETECTION                                                     │
│ • Detected: Vietnamese (vi)                                                   │
│ • Confidence: 0.95                                                           │
└─────────────────────────────────────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ STEP 2: TOKENIZATION                                                          │
│ • Tokens: ["úp", "bóng", "cơ", "bản"]                                        │
│ • Original query preserved                                                    │
│ • Diacritics normalized (optional)                                           │
└─────────────────────────────────────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ STEP 3: ALIAS & VARIANT RESOLUTION                                            │
│ • "úp bóng" → "draw shot" (vi→en alias)                                      │
│ • "cơ bản" → "basic" (term relationship)                                     │
│ • "bóng" → "ball" (semantic expansion)                                      │
└─────────────────────────────────────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ STEP 4: SEARCH EXECUTION                                                      │
│                                                                              │
│ ┌─────────────────────────────────────────┐                                  │
│ │ PostgreSQL Full-Text Search             │                                  │
│ │ • Search name, summary, definition     │                                  │
│ │ • Weight: title (A) > summary (B) > def (C)                               │
│ │ • Rank: ts_rank() + BM25               │                                  │
│ └─────────────────────────────────────────┘                                  │
│                                                                              │
│ ┌─────────────────────────────────────────┐                                  │
│ │ Vector Semantic Search                  │                                  │
│ │ • Query: "draw shot basic technique"    │                                  │
│ │ • Embedding model: text-embedding-3    │                                  │
│ │ • Metric: Cosine similarity             │                                  │
│ │ • Top-K: 20 results                     │                                  │
│ └─────────────────────────────────────────┘                                  │
│                                                                              │
│ ┌─────────────────────────────────────────┐                                  │
│ │ Tag & Category Filter                   │                                  │
│ │ • Discipline: pool                      │                                  │
│ │ • Difficulty: beginner, intermediate    │                                  │
│ │ • Language: vi, en                      │                                  │
│ └─────────────────────────────────────────┘                                  │
└─────────────────────────────────────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ STEP 5: RANKING & FUSION                                                      │
│                                                                              │
│ • Reciprocal Rank Fusion (RRF)                                               │
│ • Final score = Σ (1 / (k + rank_i))                                         │
│ • Boost factors:                                                             │
│   - View count: +0.1                                                         │
│   - Bookmark count: +0.2                                                      │
│   - Recency: +0.05 (last 30 days)                                           │
│   - Verified content: +0.15                                                   │
└─────────────────────────────────────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ OUTPUT                                                                        │
│                                                                              │
│ {                                                                            │
│   "query": "úp bóng cơ bản",                                                 │
│   "language_detected": "vi",                                                  │
│   "total_results": 47,                                                       │
│   "page": 1,                                                                 │
│   "per_page": 10,                                                            │
│   "results": [                                                               │
│     {                                                                         │
│       "slug": "draw-shot",                                                    │
│       "name": { "en": "Draw Shot", "vi": "Úp Bóng" },                         │
│       "summary": { "en": "...", "vi": "..." },                                │
│       "difficulty": "intermediate",                                          │
│       "score": 0.95,                                                         │
│       "highlights": {                                                       │
│         "vi": ["<em>úp bóng</em> là kỹ thuật..."],                           │
│         "en": ["The <em>draw shot</em> is..."]                                │
│       },                                                                     │
│       "related_suggestions": ["follow-shot", "stop-shot"],                    │
│       "category_path": "pool > fundamentals > stroke techniques"            │
│     }                                                                         │
│   ],                                                                          │
│   "facets": {                                                                │
│     "difficulty": { "beginner": 5, "intermediate": 12, "advanced": 8 },      │
│     "category": { "stroke": 15, "spin": 10, "position": 8 }                  │
│   },                                                                         │
│   "suggestions": {                                                          │
│     "corrected_query": "draw shot basics",                                   │
│     "did_you_mean": ["draw shot", "basic draw", "pull shot"]                 │
│   }                                                                          │
│ }                                                                            │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. English Search Capabilities

### 2.1 Full-Text Search Features

| Feature | Example | Behavior |
|---------|---------|----------|
| **Exact Match** | `"draw shot"` | Phrase match, highest priority |
| **AND** | `draw AND shot` | Both terms required |
| **OR** | `draw OR pull` | Either term matches |
| **NOT** | `draw NOT follow` | Exclude follow results |
| **Wildcard** | `dr* shot` | Prefix matching |
| **Fuzzy** | `draw~` | Edit distance ≤ 2 |
| **Proximity** | `"draw shot"~5` | Terms within 5 words |
| **Boost** | `draw^3 shot` | Boost draw term importance |

### 2.2 Searchable Fields

```sql
-- PostgreSQL search weights
CREATE INDEX idx_terms_search ON terms USING GIN (
    setweight(to_tsvector('english', coalesce(name->>'en', '')), 'A') ||
    setweight(to_tsvector('english', coalesce(summary->>'en', '')), 'B') ||
    setweight(to_tsvector('english', coalesce(definition->>'en', '')), 'C') ||
    setweight(to_tsvector('english', coalesce(array_to_string(aliases, ' '), '')), 'D')
);
```

### 2.3 Example English Queries

| Query | Interpretation | Results |
|-------|---------------|---------|
| `draw shot` | Direct search | Terms containing "draw" and "shot" |
| `"draw shot"` | Phrase search | Draw shot as exact phrase |
| `backspin technique` | Multi-word | Both terms in any order |
| `pool basics for beginners` | Natural language | Relevant pool fundamentals |
| `difference between draw and follow` | Comparison | Both terms with comparisons |

---

## 3. Vietnamese Search Capabilities

### 3.1 Vietnamese-Specific Processing

```sql
-- Vietnamese text search configuration
CREATE TEXT SEARCH CONFIGURATION vietnamese_search (COPY simple);

-- Add Vietnamese-specific stemming (requires unaccent extension)
ALTER TEXT SEARCH CONFIGURATION vietnamese_search
  ALTER MAPPING FOR asciiword
  WITH vietnamese_stem;
```

### 3.2 Vietnamese Search Features

| Feature | Example | Behavior |
|---------|---------|----------|
| **Exact Match** | `"úp bóng"` | Phrase with diacritics |
| **Without Diacritics** | `up bong` | Normalized form |
| **Combined** | `úp bóng cơ bản` | Full phrase with normalization |
| **English Translation** | `draw shot tiếng việt` | Cross-language |
| **Romanization** | `up bong` | Vietnamese without diacritics |

### 3.3 Vietnamese-English Cross Search

```sql
-- Cross-language search function
CREATE OR REPLACE FUNCTION search_vi_to_en(query TEXT)
RETURNS TABLE(term_id UUID, score REAL) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    t.id,
    ts_rank(
      to_tsvector('english', coalesce(t.name->>'en', '')),
      plainto_tsquery('english', translate(query, 'áàảãạăắằẳẵặâấầẩẫậéèẻẽẹêếềểễệíìỉĩịóòỏõọôốồổỗộơớờởỡợúùủũụưứừửữựýỳỷỹỵ', 'aaaaaaaaaaaaaaaaeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyy'))
    ) AS score
  FROM terms t
  WHERE 
    to_tsvector('english', coalesce(t.name->>'en', '')) @@ 
    plainto_tsquery('english', query);
END;
$$ LANGUAGE plpgsql;
```

### 3.4 Example Vietnamese Queries

| Query | Interpretation | Results |
|-------|---------------|---------|
| `úp bóng` | Direct Vietnamese | Draw shot terms |
| `up bong` | Without diacritics | Draw shot (normalized) |
| `kỹ thuật cơ bản` | Technique basics | Fundamental techniques |
| `bida lỗ 8 bi` | Pool 8-ball | 8-ball specific |
| `cách đánh úp` | How to draw | Instructional content |

---

## 4. Alias and Misspelling Handling

### 4.1 Alias Resolution System

```json
{
  "aliases": {
    "draw shot": {
      "canonical_term": "draw-shot",
      "variants": [
        "pull shot",
        "backspin shot",
        "pulling shot",
        "D shot"
      ],
      "language": "en"
    },
    "úp bóng": {
      "canonical_term": "draw-shot",
      "variants": [
        "đánh úp",
        "lửi",
        "úp"
      ],
      "language": "vi"
    }
  }
}
```

### 4.2 Misspelling Correction

```sql
-- Build trigram index for fuzzy matching
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE INDEX idx_aliases_trgm ON aliases USING GIN (text gin_trgm_ops);

-- Fuzzy search function
CREATE OR REPLACE FUNCTION fuzzy_match_alias(search_term TEXT)
RETURNS TABLE(alias_id UUID, term_slug TEXT, similarity REAL) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    a.id,
    t.slug,
    similarity(a.normalized_text, search_term)
  FROM aliases a
  JOIN terms t ON t.id = a.term_id
  WHERE a.normalized_text % search_term
  ORDER BY similarity DESC
  LIMIT 5;
END;
$$ LANGUAGE plpgsql;
```

### 4.3 Common Misspellings Database

| Misspelling | Correction | Language |
|------------|------------|----------|
| `drwa shot` | draw shot | en |
| `draws hot` | draw shot | en |
| `folow shot` | follow shot | en |
| `upp bong` | úp bóng | vi |
| `up bong` | úp bóng | vi |
| `bida lo` | bida lỗ | vi |
| `masse shot` | massé shot | en |

### 4.4 Phonetic Matching

```sql
-- Soundex for phonetic matching (English)
CREATE OR REPLACE FUNCTION soundex(text) RETURNS TEXT AS $$
  -- Simplified soundex implementation
$$ LANGUAGE plpgsql IMMUTABLE;

-- Metaphone for better English phonetic matching
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;

CREATE OR REPLACE FUNCTION metaphone_match(term1 TEXT, term2 TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN metaphone(term1, 6) = metaphone(term2, 6);
END;
$$ LANGUAGE plpgsql;
```

---

## 5. Fuzzy Search Implementation

### 5.1 Edit Distance Configuration

| Setting | Value | Use Case |
|---------|-------|----------|
| **Max Edit Distance** | 2 | Default fuzzy matching |
| **Prefix Length** | 2 | Minimum chars before fuzzy |
| **Transposition** | true | Allow ab↔ba swaps |

### 5.2 Fuzzy Search Implementation

```sql
-- PostgreSQL trigram-based fuzzy search
CREATE OR REPLACE FUNCTION fuzzy_search_terms(
  search_query TEXT,
  max_distance INT DEFAULT 2,
  lang TEXT DEFAULT 'en'
)
RETURNS TABLE(
  term_id UUID,
  slug TEXT,
  name JSONB,
  similarity REAL,
  distance INT
) AS $$
BEGIN
  RETURN QUERY
  WITH normalized_query AS (
    SELECT lower(unaccent(search_query)) AS query
  ),
  tokenized AS (
    SELECT unnest(string_to_array(query, ' ')) AS token
    FROM normalized_query
  )
  SELECT 
    t.id,
    t.slug,
    t.name,
    word_similarity(nq.query, a.normalized_text) AS similarity,
    levenshtein_less_equal(nq.query, a.normalized_text, max_distance) AS distance
  FROM normalized_query nq
  CROSS JOIN tokenized tkn
  JOIN aliases a ON a.normalized_text % tkn.token
  JOIN terms t ON t.id = a.term_id
  WHERE t.language = lang
  ORDER BY similarity DESC, distance ASC
  LIMIT 20;
END;
$$ LANGUAGE plpgsql;
```

### 5.3 Fuzzy Match Examples

| Query | Target | Distance | Match? |
|-------|--------|----------|--------|
| `draw` | draw | 0 | ✅ Exact |
| `dra` | draw | 1 | ✅ Fuzzy |
| `drwa` | draw | 1 | ✅ Typo |
| `dray` | draw | 1 | ✅ Typo |
| `dfaw` | draw | 2 | ✅ Fuzzy |
| `abcd` | draw | 4 | ❌ No match |

---

## 6. Synonym Search

### 6.1 Synonym Configuration

```json
{
  "synonym_groups": [
    {
      "group_id": "spin-types",
      "terms": [
        "english",
        "side spin",
        "sidespin",
        "sidespin",
        "spin"
      ],
      "language": "en"
    },
    {
      "group_id": "shot-types-vi",
      "terms": [
        "úp bóng",
        "lửi",
        "đánh úp"
      ],
      "language": "vi",
      "canonical": "úp bóng"
    }
  ]
}
```

### 6.2 Synonym Search Implementation

```sql
-- Build synonym index
CREATE TABLE synonym_groups (
  id UUID PRIMARY KEY,
  group_id VARCHAR(100) NOT NULL,
  language VARCHAR(5) NOT NULL,
  canonical_term_id UUID REFERENCES terms(id)
);

CREATE TABLE synonym_terms (
  id UUID PRIMARY KEY,
  group_id UUID REFERENCES synonym_groups(id),
  term_text TEXT NOT NULL,
  is_canonical BOOLEAN DEFAULT FALSE
);

-- Synonym expansion query
CREATE OR REPLACE FUNCTION expand_with_synonyms(search_term TEXT, lang TEXT)
RETURNS TABLE(expanded_term TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT st.term_text
  FROM synonym_terms st
  JOIN synonym_groups sg ON sg.id = st.group_id
  WHERE sg.language = lang
    AND st.term_text = search_term;
  
  -- Also return original if no synonyms found
  IF NOT FOUND THEN
    RETURN QUERY SELECT search_term;
  END IF;
END;
$$ LANGUAGE plpgsql;
```

---

## 7. Tag-Based Search

### 7.1 Tag Search Implementation

```sql
-- Tag-based search with filtering
CREATE OR REPLACE FUNCTION search_by_tags(
  tag_list TEXT[],
  include_all BOOLEAN DEFAULT TRUE,
  lang TEXT DEFAULT 'en'
)
RETURNS TABLE(
  term_id UUID,
  slug TEXT,
  name JSONB,
  matched_tags TEXT[],
  match_count INT
) AS $$
BEGIN
  IF include_all THEN
    -- All tags must match (AND)
    RETURN QUERY
    SELECT 
      t.id,
      t.slug,
      t.name,
      ARRAY_AGG(tt.name) AS matched_tags,
      COUNT(*) AS match_count
    FROM terms t
    JOIN term_tags tgt ON tgt.term_id = t.id
    JOIN tags tt ON tt.id = tgt.tag_id
    WHERE tt.name = ANY(tag_list)
      AND t.language = lang
    GROUP BY t.id, t.slug, t.name
    HAVING COUNT(DISTINCT tt.id) = array_length(tag_list, 1);
  ELSE
    -- Any tag matches (OR)
    RETURN QUERY
    SELECT 
      t.id,
      t.slug,
      t.name,
      ARRAY_AGG(DISTINCT tt.name) AS matched_tags,
      COUNT(*) AS match_count
    FROM terms t
    JOIN term_tags tgt ON tgt.term_id = t.id
    JOIN tags tt ON tt.id = tgt.tag_id
    WHERE tt.name = ANY(tag_list)
      AND t.language = lang
    GROUP BY t.id, t.slug, t.name
    ORDER BY COUNT(*) DESC;
  END IF;
END;
$$ LANGUAGE plpgsql;
```

### 7.2 Tag Search Examples

| Query | Result |
|-------|--------|
| `tags=["#stroke", "#intermediate"]` | Intermediate stroke techniques |
| `tags=["#spin", "#english"]` | English/spin techniques |
| `tags=["#pool", "#beginner"]` | Beginner pool content |

---

## 8. Category-Based Search

### 8.1 Category Navigation

```sql
-- Get terms in category and subcategories
CREATE OR REPLACE FUNCTION search_by_category(
  category_slug TEXT,
  include_subcategories BOOLEAN DEFAULT TRUE,
  lang TEXT DEFAULT 'en'
)
RETURNS TABLE(
  term_id UUID,
  slug TEXT,
  name JSONB,
  category_path LTREE
) AS $$
BEGIN
  IF include_subcategories THEN
    -- Get all descendant categories
    RETURN QUERY
    SELECT DISTINCT ON (t.id)
      t.id,
      t.slug,
      t.name,
      c.path
    FROM terms t
    JOIN term_categories tc ON tc.term_id = t.id
    JOIN categories c ON c.id = tc.category_id
    WHERE c.path <@ (
      SELECT path FROM categories 
      WHERE slug = category_slug AND language = lang
    )
    AND t.language = lang
    ORDER BY t.id, nlevel(c.path) DESC;
  ELSE
    -- Only direct category
    RETURN QUERY
    SELECT 
      t.id,
      t.slug,
      t.name,
      c.path
    FROM terms t
    JOIN term_categories tc ON tc.term_id = t.id
    JOIN categories c ON c.id = tc.category_id
    WHERE c.slug = category_slug
    AND t.language = lang;
  END IF;
END;
$$ LANGUAGE plpgsql;
```

### 8.2 Category Path Queries

```
Input: category = "stroke-techniques"
Output: All terms in stroke-techniques and its subcategories

Category Tree:
pool
└── fundamentals
    └── stroke-techniques      ← This category
        ├── basic-strokes      ← Included
        ├── advanced-strokes   ← Included
        └── power-control      ← Included
```

---

## 9. Abbreviation Support

### 9.1 Abbreviation Expansion

```json
{
  "abbreviations": {
    "en": {
      "CB": ["cue ball", "cue-ball"],
      "OB": ["object ball", "object-ball"],
      "F": ["follow", "follow shot"],
      "D": ["draw", "draw shot"],
      "S": ["stun", "stun shot"],
      "EE": ["extra english", "extra english spin"],
      "J": ["jump", "jump shot"]
    },
    "vi": {
      "BC": ["bóng cơ"],
      "BĐ": ["bóng đối tượng"],
      "Ú": ["úp", "úp bóng"]
    }
  }
}
```

### 9.2 Abbreviation Search Implementation

```sql
CREATE OR REPLACE FUNCTION expand_abbreviation(term TEXT, lang TEXT)
RETURNS TEXT[] AS $$
DECLARE
  expansions TEXT[];
BEGIN
  SELECT ARRAY_AGG(value)
  INTO expansions
  FROM jsonb_each_text(
    (SELECT abbreviations FROM language_abbreviations WHERE language = lang))
  WHERE key = upper(term);
  
  IF expansions IS NULL THEN
    RETURN ARRAY[term];
  END IF;
  
  RETURN expansions;
END;
$$ LANGUAGE plpgsql;
```

---

## 10. Voice Search Preparation

### 10.1 Voice Search Pipeline (Future)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       VOICE SEARCH PIPELINE (Future)                          │
└─────────────────────────────────────────────────────────────────────────────┘

User Speech: "How do I do a draw shot?"
                    │
                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ STT (Speech-to-Text)                                                          │
│ • Provider: Whisper / Google Speech                                           │
│ • Output: "how do i do a draw shot"                                           │
└─────────────────────────────────────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ NLP Processing                                                                 │
│ • Punctuation restoration                                                      │
│ • Query normalization                                                          │
│ • Intent detection: "how to" → tutorial/search                                │
└─────────────────────────────────────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ Standard Search Flow                                                           │
│ • Query processing                                                            │
│ • Search execution                                                            │
│ • Result ranking                                                               │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 10.2 Voice Search Features

| Feature | Status | Notes |
|---------|--------|-------|
| **Speech-to-Text** | Future v2 | Whisper integration |
| **Natural Language** | v1 | "how to" queries |
| **Commands** | Future v2 | "show me", "explain" |
| **Continuous** | Future v3 | Multi-turn dialogue |

---

## 11. Full-Text Search Design

### 11.1 PostgreSQL FTS Configuration

```sql
-- Create custom text search configuration
CREATE TEXT SEARCH CONFIGURATION bkm_english (COPY english);

-- Add domain-specific dictionaries
ALTER TEXT SEARCH CONFIGURATION bkm_english
  ADD MAPPING FOR asciiword 
  WITH english_stem, bkm_synonyms, bkm_thesaurus;

-- Create thesaurus for billiards terms
CREATE TEXT SEARCH THESAURUS bkm_thesaurus;
ALTER TEXT SEARCH THESAURUS bkm_thesaurus ADD MAPPING
  'draw', 'draw shot', 'backspin';

-- Weighted search index
CREATE INDEX idx_terms_bkm_fts ON terms USING GIN (
  setweight(to_tsvector('bkm_english', coalesce(name->>'en', '')), 'A') ||
  setweight(to_tsvector('bkm_english', coalesce(summary->>'en', '')), 'B') ||
  setweight(to_tsvector('bkm_english', coalesce(definition->>'en', '')), 'C')
);
```

### 11.2 Search Query Builder

```dart
class SearchQueryBuilder {
  String _query = '';
  final List<String> _filters = [];
  final List<String> _boosts = [];
  
  SearchQueryBuilder text(String query) {
    _query = query;
    return this;
  }
  
  SearchQueryBuilder filter(String field, dynamic value) {
    _filters.add('"$field":$value');
    return this;
  }
  
  SearchQueryBuilder boost(String field, double weight) {
    _boosts.add('$field^$weight');
    return this;
  }
  
  SearchQueryBuilder language(String lang) {
    return filter('language', lang);
  }
  
  SearchQueryBuilder difficulty(String level) {
    return filter('difficulty', level);
  }
  
  SearchQueryBuilder discipline(String code) {
    return filter('discipline', code);
  }
  
  String build() {
    final parts = <String>[];
    if (_query.isNotEmpty) {
      final boosted = _boosts.isNotEmpty 
          ? _boosts.join(' ') + ' ' + _query
          : _query;
      parts.add('($boosted)');
    }
    if (_filters.isNotEmpty) {
      parts.add('(${_filters.join(' AND ')})');
    }
    return parts.join(' AND ');
  }
}

// Usage
final query = SearchQueryBuilder()
    .text('draw shot technique')
    .language('en')
    .difficulty('intermediate')
    .discipline('pool')
    .build();
// Result: "(draw shot technique) AND (language:en AND difficulty:intermediate AND discipline:pool)"
```

---

## 12. Ranking Algorithm

### 12.1 Ranking Factors

| Factor | Weight | Description |
|--------|--------|-------------|
| **Text Relevance** | 0.40 | TF-IDF / BM25 score |
| **Semantic Similarity** | 0.25 | Vector embedding similarity |
| **Popularity** | 0.15 | View + bookmark counts |
| **Recency** | 0.10 | Content freshness |
| **Quality** | 0.10 | Verification status |

### 12.2 Reciprocal Rank Fusion

```sql
-- RRF ranking for multi-source results
CREATE OR REPLACE FUNCTION reciprocal_rank_fusion(
  results_a UUID[],
  results_b UUID[],
  results_c UUID[] DEFAULT NULL,
  k INT DEFAULT 60
)
RETURNS TABLE(item_id UUID, rrf_score REAL) AS $$
BEGIN
  RETURN QUERY
  WITH combined AS (
    -- Results from source A
    SELECT unnest, ROW_NUMBER() OVER () AS rank FROM unnest(results_a)
    UNION ALL
    -- Results from source B
    SELECT unnest, ROW_NUMBER() OVER () AS rank FROM unnest(results_b)
    UNION ALL
    -- Results from source C (optional)
    SELECT unnest, ROW_NUMBER() OVER () AS rank FROM unnest(results_c)
  )
  SELECT 
    combined.unnest AS item_id,
    SUM(1.0 / (k + combined.rank)) AS rrf_score
  FROM combined
  GROUP BY combined.unnest
  ORDER BY rrf_score DESC;
END;
$$ LANGUAGE plpgsql;
```

### 12.3 Final Score Calculation

```dart
double calculateFinalScore(SearchResult result, SearchContext context) {
  // Text relevance (0-1)
  final textScore = result.bm25Score / 100.0;
  
  // Semantic similarity (0-1)
  final semanticScore = result.vectorSimilarity;
  
  // Popularity boost (0-0.2)
  final popularityScore = calculatePopularityScore(result);
  
  // Recency boost (0-0.1)
  final recencyScore = calculateRecencyScore(result);
  
  // Quality boost (0-0.15)
  final qualityScore = result.isVerified ? 0.15 : 0.0;
  
  // Weighted combination
  return (textScore * 0.40) +
         (semanticScore * 0.25) +
         (popularityScore * 0.15) +
         (recencyScore * 0.10) +
         (qualityScore * 0.10);
}

double calculatePopularityScore(SearchResult result) {
  // Logarithmic scaling to prevent popular terms from dominating
  final views = log(result.viewCount + 1) / log(100000);
  final bookmarks = log(result.bookmarkCount + 1) / log(10000);
  
  return min(0.2, (views * 0.7 + bookmarks * 0.3) * 0.2);
}
```

---

## 13. Performance Considerations

### 13.1 Search Performance Targets

| Metric | Target | Maximum |
|--------|--------|-----------------|
| **Query Latency (p50)** | <50ms | 100ms |
| **Query Latency (p99)** | <200ms | 500ms |
| **Throughput** | 1000 QPS | 5000 QPS |
| **Index Size** | <10GB | 50GB |

### 13.2 Caching Strategy

```sql
-- Redis cache for frequent searches
-- Key pattern: search:{query_hash}:{filters_hash}:{lang}
-- TTL: 5 minutes for common queries, 1 hour for rare

-- Cache invalidation on content update
-- Pattern: delete all keys matching search:*
```

### 13.3 Index Optimization

```sql
-- Partial indexes for common filters
CREATE INDEX idx_terms_published_en 
ON terms USING GIN(to_tsvector('english', name->>'en'))
WHERE status = 'published' AND language = 'en';

CREATE INDEX idx_terms_published_vi 
ON terms USING GIN(to_tsvector('vietnamese', name->>'vi'))
WHERE status = 'published' AND language = 'vi';

-- Covering indexes for search results
CREATE INDEX idx_terms_search_cover 
ON terms(slug, name, summary, difficulty)
WHERE status = 'published';
```

---

## 14. Appendix

### 14.1 API Response Format

```json
{
  "success": true,
  "data": {
    "query": {
      "original": "draw shot basics",
      "normalized": "draw shot basic",
      "language_detected": "en",
      "intent": "search"
    },
    "results": {
      "items": [...],
      "total": 45,
      "page": 1,
      "per_page": 10,
      "total_pages": 5
    },
    "facets": {
      "difficulty": {...},
      "category": {...},
      "tags": {...}
    },
    "suggestions": {
      "did_you_mean": ["draw shot basic", "basic draw shot"],
      "related_searches": ["draw shot technique", "backspin"]
    },
    "meta": {
      "search_time_ms": 45,
      "cache_hit": false
    }
  }
}
```

### 14.2 Error Responses

```json
{
  "success": false,
  "error": {
    "code": "SEARCH_ERROR",
    "message": "Unable to process search query",
    "details": "Query too short (minimum 2 characters)"
  }
}
```

### 14.3 Related Documents

- [BKM Architecture](./02_Architecture.md)
- [BKM Database Schema](./03_Database.md)
- [BKM API Design](./15_API_Design_For_PoolOS.md)

---

**End of Document**
