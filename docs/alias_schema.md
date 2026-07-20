# BKM - Alias System

## Version 1.0
**Last Updated:** July 2026
**Status:** Production Standard

---

## 1. Overview

The Alias System provides alternative names, spellings, and variations for terms. This enables comprehensive search, supports multiple dialects, and captures the rich terminology used by different communities.

---

## 2. Alias Types

### 2.1 Type Definitions

| Type | Code | Description | Example |
|------|------|-------------|---------|
| `official` | OFF | Primary official name | "Draw Shot" |
| `common` | COM | Widely used common name | "Screw Shot" |
| `nickname` | NIK | Informal nickname | "The Pull" |
| `abbreviation` | ABB | Shortened form | "DB" for "Double Ball" |
| `alt_spelling` | ALT | Alternative spelling | "Masé" vs "Massé" |
| `british` | BRI | British English | "Cue Ball" vs "White Ball" |
| `american` | AME | American English | Standard usage |
| `vietnamese` | VIE | Vietnamese variation | "Cắt đít" vs "Lộn đít" |
| `regional` | REG | Regional variation | "Pool" vs "Pocket Billiards" |
| `technical` | TEC | Technical term | "Contact-Induced Throw" |
| `slang` | SLG | Slang expression | "Scratch" for foul |
| `archaic` | ARC | Historical/old term | "Balk" for safety |

### 2.2 Type Properties

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           ALIAS TYPE PROPERTIES                             │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                     │
    │  Type Properties:                                                   │
    │                                                                     │
    │  ┌───────────┬─────────┬──────────┬──────────┬──────────────────┐   │
    │  │ Type      │ Search  │ Display  │ Language │ Frequency        │   │
    │  ├───────────┼─────────┼──────────┼──────────┼──────────────────┤   │
    │  │ OFFICIAL  │ ✓       │ ✓        │ any      │ primary          │   │
    │  │ COMMON    │ ✓       │ ✓        │ any      │ high             │   │
    │  │ NICKNAME  │ ✓       │ ✓        │ any      │ medium           │   │
    │  │ ABBREV    │ ✓       │ ✓        │ any      │ high             │   │
    │  │ ALT_SPELL │ ✓       │ ○        │ any      │ low              │   │
    │  │ BRITISH   │ ✓       │ ✓        │ en       │ regional         │   │
    │  │ AMERICAN  │ ✓       │ ○        │ en       │ standard         │   │
    │  │ VIETNAMESE│ ✓       │ ✓        │ vi       │ native           │   │
    │  │ REGIONAL  │ ✓       │ ○        │ any      │ regional         │   │
    │  │ TECHNICAL │ ✓       │ ✓        │ any      │ specialized      │   │
    │  │ SLANG     │ ✓       │ ○        │ any      │ informal         │   │
    │  │ ARCHAIC   │ ✓       │ ○        │ any      │ historical       │   │
    │  └───────────┴─────────┴──────────┴──────────┴──────────────────┘   │
    │                                                                     │
    │  Legend: ✓ = Yes, Include  ○ = Optional                            │
    │                                                                     │
    └─────────────────────────────────────────────────────────────────────┘
```

---

## 3. Data Model

### 3.1 Alias Entity

```json
{
  "id": "ALIAS-000001",
  "term_id": "TERM-000009",
  "type": "COMMON",
  "value": "screw-shot",
  "display_value": "Screw Shot",
  "language": "en",
  "region": null,
  "usage_level": "high",
  "is_preferred": false,
  "notes": {
    "en": "Common alternative name used in UK",
    "vi": "Tên thay thế phổ biến ở Anh"
  },
  "created_at": "2026-07-17T00:00:00Z"
}
```

### 3.2 Alias Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | ID | Yes | ALIAS-NNNNNN |
| `term_id` | ID | Yes | Reference to term |
| `type` | enum | Yes | Alias type code |
| `value` | string | Yes | Lowercase searchable value |
| `display_value` | string | Yes | Display form |
| `language` | string | Yes | ISO code (en/vi/...) |
| `region` | string | No | Regional code |
| `usage_level` | enum | No | high/medium/low |
| `is_preferred` | boolean | No | Preferred alternative |
| `notes` | JSONB | No | Additional notes |
| `created_at` | timestamp | Yes | Creation time |

### 3.3 Usage Level

| Level | Description | Usage |
|-------|-------------|-------|
| `high` | Very common, widely understood | Show in search results |
| `medium` | Common in specific regions/contexts | Include in suggestions |
| `low` | Rare, specialized usage | Internal reference only |

---

## 4. Search Integration

### 4.1 Search Priority

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          SEARCH PRIORITY ORDER                               │
└─────────────────────────────────────────────────────────────────────────────┘

    Priority 1: Term official name (exact match)
    Priority 2: Term slug (exact match)
    Priority 3: Aliases with is_preferred = true
    Priority 4: Aliases with usage_level = high
    Priority 5: Aliases with usage_level = medium
    Priority 6: Aliases with usage_level = low
```

### 4.2 Search Behavior

| Query Type | Example | Matches |
|------------|---------|---------|
| Exact match | "draw-shot" | slug, aliases.value |
| Fuzzy match | "dra shot" | aliases (fuzzy) |
| Partial match | "screw" | aliases.value |
| Abbreviation | "DB" | aliases.type=ABB |
| Dialect | "white ball" | aliases.type=BRITISH |

---

## 5. Display Rules

### 5.1 Display Priority

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           DISPLAY PRIORITY                                   │
└─────────────────────────────────────────────────────────────────────────────┘

    Primary Display: Term names (from term entity)
    Alternatives:    Aliases with display_value AND type IN (COMMON, NICKNAME, VIETNAMESE)
    
    Types excluded from display suggestions:
    - ALT_SPELL (internal only)
    - BRITISH / AMERICAN (shown in dialect toggle)
    - REGIONAL (shown in regional filter)
    - SLANG (informal only)
    - ARCHAIC (historical only)
```

### 5.2 UI Display

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              TERM CARD                                       │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────┐
    │  Draw Shot                                    [EN] [VI] [+]       │
    │  ─────────────────────────────────────────────────────────────    │
    │  Đường Cắt Đít / Cắt đít                                        │
    │                                                                     │
    │  Also known as:                                                     │
    │  • Screw Shot (common)                                             │
    │  • Pull Shot (nickname)                                            │
    │  • Cắt đít (Vietnamese)                                           │
    │  • Cắt ngược (regional)                                           │
    └─────────────────────────────────────────────────────────────────────┘
```

---

## 6. Multi-Language Support

### 6.1 Language Priority

| Priority | Language | Display | Search |
|----------|----------|---------|--------|
| 1 | English (en) | Primary | Full |
| 2 | Vietnamese (vi) | Secondary | Full |
| 3 | Others (ja, ko, zh) | TBD | Partial |

### 6.2 Dialect Display

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           DIALECT TOGGLE                                     │
└─────────────────────────────────────────────────────────────────────────────┘

    [American] [British]
    
    American: Cue Ball, Object Ball
    British:  White Ball, Coloured Ball
```

---

## 7. Database Schema

### 7.1 PostgreSQL

```sql
CREATE TABLE aliases (
    id              VARCHAR(20) PRIMARY KEY,
    term_id         VARCHAR(20) NOT NULL REFERENCES terms(id) ON DELETE CASCADE,
    type            VARCHAR(10) NOT NULL,
    value           VARCHAR(255) NOT NULL,
    display_value   VARCHAR(255) NOT NULL,
    language        VARCHAR(5) NOT NULL DEFAULT 'en',
    region          VARCHAR(10),
    usage_level     VARCHAR(10) DEFAULT 'medium',
    is_preferred    BOOLEAN DEFAULT false,
    notes           JSONB,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT valid_alias_type CHECK (type IN (
        'OFFICIAL', 'COMMON', 'NICKNAME', 'ABBREV', 
        'ALT_SPELL', 'BRITISH', 'AMERICAN', 'VIETNAMESE',
        'REGIONAL', 'TECHNICAL', 'SLANG', 'ARCHAIC'
    )),
    CONSTRAINT valid_usage_level CHECK (usage_level IN ('high', 'medium', 'low')),
    CONSTRAINT unique_alias UNIQUE (term_id, type, value, language)
);

CREATE INDEX idx_aliases_term ON aliases(term_id);
CREATE INDEX idx_aliases_type ON aliases(type);
CREATE INDEX idx_aliases_value ON aliases(value);
CREATE INDEX idx_aliases_language ON aliases(language);
CREATE INDEX idx_aliases_search ON aliases USING gin(to_tsvector('english', value));
```

### 7.2 Full-Text Search

```sql
-- Combined search view
CREATE OR REPLACE FUNCTION search_terms(query TEXT)
RETURNS TABLE(
    term_id VARCHAR,
    term_slug VARCHAR,
    term_names JSONB,
    match_type VARCHAR,
    rank REAL
) AS $$
BEGIN
    RETURN QUERY
    -- Match term slug
    SELECT 
        t.id,
        t.slug,
        t.names,
        'slug'::VARCHAR,
        ts_rank(to_tsvector('english', t.slug), plainto_tsquery('english', query))
    FROM terms t
    WHERE t.slug ILIKE '%' || query || '%'
    
    UNION ALL
    
    -- Match aliases
    SELECT 
        a.term_id,
        t.slug,
        t.names,
        a.type,
        ts_rank(to_tsvector('english', a.value), plainto_tsquery('english', query))
    FROM aliases a
    JOIN terms t ON a.term_id = t.id
    WHERE a.value ILIKE '%' || query || '%'
    ORDER BY rank DESC;
END;
$$ LANGUAGE plpgsql;
```

---

## 8. Example Aliases

### 8.1 Draw Shot Aliases

```json
{
  "term_id": "TERM-000009",
  "term_slug": "draw-shot",
  "aliases": [
    {
      "type": "COMMON",
      "value": "screw-shot",
      "display_value": "Screw Shot",
      "language": "en",
      "usage_level": "high",
      "notes": { "en": "Common in UK and Australia", "vi": "Phổ biến ở Anh và Úc" }
    },
    {
      "type": "NICKNAME",
      "value": "pull-shot",
      "display_value": "Pull Shot",
      "language": "en",
      "usage_level": "medium"
    },
    {
      "type": "VIETNAMESE",
      "value": "cắt đít",
      "display_value": "Cắt đít",
      "language": "vi",
      "is_preferred": true
    },
    {
      "type": "VIETNAMESE",
      "value": "lộn đít",
      "display_value": "Lộn đít",
      "language": "vi",
      "usage_level": "medium"
    },
    {
      "type": "VIETNAMESE",
      "value": "xoáy ngược",
      "display_value": "Xoáy ngược",
      "language": "vi",
      "usage_level": "low"
    },
    {
      "type": "SLANG",
      "value": "pull",
      "display_value": "Pull",
      "language": "en",
      "usage_level": "low"
    }
  ]
}
```

### 8.2 Cue Ball Aliases

```json
{
  "term_id": "TERM-000001",
  "term_slug": "cue-ball",
  "aliases": [
    {
      "type": "BRITISH",
      "value": "white-ball",
      "display_value": "White Ball",
      "language": "en",
      "region": "GB",
      "usage_level": "high",
      "notes": { "en": "Standard British term" }
    },
    {
      "type": "AMERICAN",
      "value": "cue-ball",
      "display_value": "Cue Ball",
      "language": "en",
      "region": "US",
      "is_preferred": true
    },
    {
      "type": "VIETNAMESE",
      "value": "bóng cơ",
      "display_value": "Bóng cơ",
      "language": "vi",
      "is_preferred": true
    },
    {
      "type": "VIETNAMESE",
      "value": "bi cơ",
      "display_value": "Bi cơ",
      "language": "vi",
      "usage_level": "medium"
    }
  ]
}
```

---

## 9. Validation Rules

### 9.1 Uniqueness Constraints

- One official name per language per term
- Unique alias value per type per term
- Preferred alias only one per language

### 9.2 Business Rules

```sql
-- One official per language
CONSTRAINT one_official_per_language CHECK (
    NOT EXISTS (
        SELECT 1 FROM aliases a1, aliases a2
        WHERE a1.term_id = a2.term_id
        AND a1.type = 'OFFICIAL' AND a2.type = 'OFFICIAL'
        AND a1.language = a2.language
        AND a1.id != a2.id
    )
);

-- One preferred per language
CONSTRAINT one_preferred_per_language CHECK (
    NOT EXISTS (
        SELECT 1 FROM aliases a1, aliases a2
        WHERE a1.term_id = a2.term_id
        AND a1.language = a2.language
        AND a1.is_preferred = true AND a2.is_preferred = true
        AND a1.id != a2.id
    )
);
```

---

## 10. Related Documents

- [Term Schema](./term_schema.md)
- [ID Standard](./id_standard.md)
- [Naming Convention](./naming.md)
- [Search System](./05_Search_System.md)

---

## 11. Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-07-17 | Initial alias system |

---

**Standard Owner:** Architecture Team
