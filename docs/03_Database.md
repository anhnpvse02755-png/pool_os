# Billiard Knowledge Module (BKM) - Database Schema

## Version 1.0
**Last Updated:** July 2026
**Status:** Production Specification

---

## 1. Schema Overview

### 1.1 Design Principles

The BKM database schema is designed with the following principles:

| Principle | Description | Implementation |
|------------|-------------|----------------|
| **Normalization** | Reduce data redundancy | 3NF compliance |
| **Extensibility** | Support future requirements | JSON columns for metadata |
| **Multi-tenancy** | Support multiple languages | Language code on all entities |
| **Soft Deletes** | Preserve data history | `deleted_at` timestamp |
| **Audit Trail** | Track all changes | `created_at`, `updated_at` |
| **Versioning** | Support schema evolution | Version field with migrations |
| **UUID Primary Keys** | Global uniqueness | UUID v4 for all entities |
| **Slug-based URLs** | SEO-friendly, human-readable | Unique slug per language |

### 1.2 Entity Relationship Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              CORE ENTITIES                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────┐      ┌─────────────┐      ┌─────────────┐                   │
│  │  Discipline │◄─────│  Category   │◄─────│    Term     │                   │
│  └─────────────┘      └─────────────┘      └──────┬──────┘                   │
│                                                   │                           │
│         ┌──────────────────┼──────────────────┐   │   ┌──────────────────┐   │
│         │                  │                  │   │   │                  │   │
│         ▼                  ▼                  ▼   ▼   ▼                  ▼   │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ ┌─────────────┐        │
│  │ Translation │    │ Definition │    │   Alias     │ │   Media     │        │
│  └─────────────┘    └──────┬──────┘    └─────────────┘ └─────────────┘        │
│                            │                                                   │
│         ┌──────────────────┼──────────────────┐                                │
│         ▼                  ▼                  ▼                                │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                         │
│  │   Example   │    │   Usage    │    │ Relationship│                         │
│  └─────────────┘    └─────────────┘    └──────┬──────┘                         │
│                                               │                                │
│                              ┌────────────────┼────────────────┐              │
│                              ▼                ▼                ▼              │
│                       ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│                       │     Tag     │  │   Source    │  │    Link     │        │
│                       └─────────────┘  └─────────────┘  └─────────────┘        │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Core Entity Definitions

### 2.1 Discipline Entity

Represents a billiards discipline (Pool, Snooker, Carom, Chinese Eight Ball).

```sql
CREATE TABLE disciplines (
    -- Primary Key
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Identification
    code            VARCHAR(50) NOT NULL UNIQUE,
    
    -- Content
    name            JSONB NOT NULL,           -- {"en": "Pool", "vi": "Bida Lỗ"}
    description     JSONB,                   -- {"en": "...", "vi": "..."}
    variants        JSONB DEFAULT '[]',       -- ["8-ball", "9-ball", "10-ball"]
    
    -- Metadata
    language        VARCHAR(5) NOT NULL DEFAULT 'en',
    status          VARCHAR(20) NOT NULL DEFAULT 'active',
    
    -- Timestamps
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ,
    
    -- Audit
    created_by      UUID REFERENCES users(id),
    updated_by      UUID REFERENCES users(id),
    
    CONSTRAINT valid_status CHECK (status IN ('active', 'archived', 'draft'))
);

CREATE INDEX idx_disciplines_code ON disciplines(code);
CREATE INDEX idx_disciplines_status ON disciplines(status);
```

**JSONB Example:**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "code": "pool",
  "name": {
    "en": "Pool (Pocket Billiards)",
    "vi": "Bida Lỗ"
  },
  "description": {
    "en": "Pool, also known as pocket billiards, refers to any game played on a table with six pockets.",
    "vi": "Bida lỗ, còn gọi là bida tú, là tên gọi chung cho các trò chơi trên bàn có sáu lỗ."
  },
  "variants": ["8-ball", "9-ball", "10-ball", "straight pool", "one-pocket"],
  "language": "en",
  "status": "active",
  "created_at": "2026-07-01T00:00:00Z",
  "updated_at": "2026-07-01T00:00:00Z"
}
```

### 2.2 Category Entity

Hierarchical categorization of terms.

```sql
CREATE TABLE categories (
    -- Primary Key
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Identification
    slug            VARCHAR(255) NOT NULL,
    code            VARCHAR(100),
    
    -- Hierarchy
    parent_id       UUID REFERENCES categories(id) ON DELETE SET NULL,
    path            LTREE,                              -- Materialized path for hierarchy
    level           INTEGER NOT NULL DEFAULT 0,
    
    -- Discipline Link
    discipline_id   UUID REFERENCES disciplines(id) ON DELETE CASCADE,
    
    -- Content
    name            JSONB NOT NULL,                      -- {"en": "...", "vi": "..."}
    description     JSONB,
    icon            VARCHAR(255),                        -- Icon identifier
    color           VARCHAR(7),                          -- Hex color code
    
    -- Metadata
    language        VARCHAR(5) NOT NULL DEFAULT 'en',
    status          VARCHAR(20) NOT NULL DEFAULT 'active',
    version         VARCHAR(20) DEFAULT 'v1',
    slug_version    INTEGER DEFAULT 1,                   -- For slug uniqueness
    
    -- Timestamps
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ,
    
    -- Audit
    created_by      UUID REFERENCES users(id),
    updated_by      UUID REFERENCES users(id),
    
    -- Constraints
    CONSTRAINT unique_slug_lang_per_parent UNIQUE (parent_id, language, slug)
);

CREATE INDEX idx_categories_parent ON categories(parent_id);
CREATE INDEX idx_categories_discipline ON categories(discipline_id);
CREATE INDEX idx_categories_path ON categories USING GIST(path);
CREATE INDEX idx_categories_slug ON categories(slug, language);
```

**JSONB Example:**

```json
{
  "id": "660e8400-e29b-41d4-a716-446655440001",
  "slug": "stroke-techniques",
  "code": "STROKE",
  "parent_id": "660e8400-e29b-41d4-a716-446655440002",
  "path": "pool.fundamentals.stroke-techniques",
  "level": 2,
  "discipline_id": "550e8400-e29b-41d4-a716-446655440000",
  "name": {
    "en": "Stroke Techniques",
    "vi": "Kỹ Thuật Gạt Cơ"
  },
  "description": {
    "en": "Fundamental and advanced stroke techniques for billiards.",
    "vi": "Các kỹ thuật gạt cơ cơ bản và nâng cao trong bida."
  },
  "icon": "stroke",
  "color": "#4A90D9",
  "language": "en",
  "status": "active",
  "version": "v1",
  "created_at": "2026-07-01T00:00:00Z",
  "updated_at": "2026-07-01T00:00:00Z"
}
```

### 2.3 Term Entity

Central knowledge entity representing a billiards concept.

```sql
CREATE TABLE terms (
    -- Primary Key
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Identification
    slug            VARCHAR(255) NOT NULL,
    code            VARCHAR(100),                         -- System code (e.g., DRAW_SHOT)
    
    -- Primary Translation (for search indexing)
    name            JSONB NOT NULL,                       -- {"en": "Draw Shot", "vi": "Úp Bóng"}
    summary         JSONB,                                -- Short description
    phonetic        JSONB,                                -- Pronunciation guides
    
    -- Discipline Link (primary)
    discipline_id   UUID REFERENCES disciplines(id) ON DELETE CASCADE,
    
    -- Category Links (many-to-many via junction table)
    
    -- Content Status
    status          VARCHAR(20) NOT NULL DEFAULT 'draft',
    visibility      VARCHAR(20) NOT NULL DEFAULT 'public',
    difficulty      VARCHAR(20),                           -- beginner, intermediate, advanced, professional
    version         VARCHAR(20) DEFAULT 'v1',
    slug_version    INTEGER DEFAULT 1,
    
    -- Metadata
    language        VARCHAR(5) NOT NULL DEFAULT 'en',
    tags            TEXT[] DEFAULT '{}',
    
    -- Statistics
    view_count      INTEGER DEFAULT 0,
    search_count    INTEGER DEFAULT 0,
    bookmark_count  INTEGER DEFAULT 0,
    
    -- Timestamps
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    published_at    TIMESTAMPTZ,
    deleted_at      TIMESTAMPTZ,
    
    -- Audit
    created_by      UUID REFERENCES users(id),
    updated_by      UUID REFERENCES users(id),
    approved_by     UUID REFERENCES users(id),
    approved_at     TIMESTAMPTZ,
    
    -- Constraints
    CONSTRAINT unique_slug_lang UNIQUE (language, slug),
    CONSTRAINT valid_difficulty CHECK (difficulty IS NULL OR difficulty IN ('beginner', 'intermediate', 'advanced', 'professional')),
    CONSTRAINT valid_status CHECK (status IN ('draft', 'review', 'published', 'archived')),
    CONSTRAINT valid_visibility CHECK (visibility IN ('public', 'authenticated', 'premium', 'internal'))
);

CREATE INDEX idx_terms_slug ON terms(slug);
CREATE INDEX idx_terms_language ON terms(language);
CREATE INDEX idx_terms_discipline ON terms(discipline_id);
CREATE INDEX idx_terms_status ON terms(status);
CREATE INDEX idx_terms_difficulty ON terms(difficulty);
CREATE INDEX idx_terms_created ON terms(created_at DESC);
CREATE INDEX idx_terms_view_count ON terms(view_count DESC);

-- Full-text search index
CREATE INDEX idx_terms_fts ON terms USING GIN (
    to_tsvector('english', COALESCE(name->>'en', '')) ||
    to_tsvector('vietnamese', COALESCE(name->>'vi', ''))
);
```

**JSONB Example:**

```json
{
  "id": "770e8400-e29b-41d4-a716-446655440003",
  "slug": "draw-shot",
  "code": "DRAW_SHOT",
  "name": {
    "en": "Draw Shot",
    "vi": "Úp Bóng"
  },
  "summary": {
    "en": "A shot where the cue ball is struck below center, causing it to reverse direction after contact.",
    "vi": "Đòn đánh mà bóng cơ được đánh vào phía dưới tâm, khiến bóng quay ngược lại sau khi chạm bóng."
  },
  "phonetic": {
    "en": "/drɔː ʃɒt/",
    "vi": "/úp bóng/"
  },
  "discipline_id": "550e8400-e29b-41d4-a716-446655440000",
  "status": "published",
  "visibility": "public",
  "difficulty": "intermediate",
  "version": "v1",
  "tags": ["stroke", "spin", "english", "backspin"],
  "language": "en",
  "view_count": 15420,
  "search_count": 8932,
  "bookmark_count": 2341,
  "created_at": "2026-07-01T00:00:00Z",
  "updated_at": "2026-07-15T10:30:00Z",
  "published_at": "2026-07-02T00:00:00Z",
  "created_by": "user-uuid-here"
}
```

---

## 3. Content Entities

### 3.1 Translation Entity

Stores translations for terms and other content.

```sql
CREATE TABLE translations (
    -- Primary Key
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Parent Reference
    entity_type     VARCHAR(50) NOT NULL,                -- term, category, etc.
    entity_id       UUID NOT NULL,
    
    -- Content
    language        VARCHAR(5) NOT NULL,
    name            VARCHAR(500) NOT NULL,
    summary         TEXT,
    description     TEXT,
    phonetic        VARCHAR(255),
    
    -- Quality
    is_verified     BOOLEAN DEFAULT FALSE,
    is_primary      BOOLEAN DEFAULT FALSE,
    confidence      DECIMAL(3,2) DEFAULT 1.00,           -- 0.00 to 1.00
    
    -- Metadata
    translator      VARCHAR(255),
    source          VARCHAR(255),                         -- Original source if translated
    
    -- Timestamps
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT unique_entity_language UNIQUE (entity_type, entity_id, language)
);

CREATE INDEX idx_translations_entity ON translations(entity_type, entity_id);
CREATE INDEX idx_translations_language ON translations(language);
```

### 3.2 Definition Entity

Detailed definition with examples and usage notes.

```sql
CREATE TABLE definitions (
    -- Primary Key
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Term Reference
    term_id         UUID NOT NULL REFERENCES terms(id) ON DELETE CASCADE,
    language        VARCHAR(5) NOT NULL DEFAULT 'en',
    
    -- Content
    definition      TEXT NOT NULL,
    explanation     TEXT,                                 -- Extended explanation
    explanation_html TEXT,                                -- Rich text version
    
    -- Structure
    definition_type VARCHAR(50),                          -- primary, formal, informal, technical
    
    -- Metadata
    source_id       UUID REFERENCES sources(id),
    citation        TEXT,                                -- Short citation
    version         VARCHAR(20) DEFAULT 'v1',
    
    -- Timestamps
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ,
    
    -- Constraints
    CONSTRAINT unique_term_language_def_type UNIQUE (term_id, language, definition_type)
);

CREATE INDEX idx_definitions_term ON definitions(term_id);
CREATE INDEX idx_definitions_language ON definitions(language);
```

### 3.3 Example Entity

Usage examples for definitions.

```sql
CREATE TABLE examples (
    -- Primary Key
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Parent Reference
    definition_id   UUID NOT NULL REFERENCES definitions(id) ON DELETE CASCADE,
    term_id         UUID NOT NULL REFERENCES terms(id) ON DELETE CASCADE,
    
    -- Content
    language        VARCHAR(5) NOT NULL DEFAULT 'en',
    text            TEXT NOT NULL,
    translation     TEXT,
    
    -- Context
    context         VARCHAR(100),                         -- when_to_use, proper_form, common_usage
    scenario        TEXT,                                -- When this example applies
    
    -- Media
    media_id        UUID REFERENCES media(id),
    
    -- Order
    sort_order      INTEGER DEFAULT 0,
    
    -- Timestamps
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT unique_term_sort UNIQUE (term_id, sort_order)
);

CREATE INDEX idx_examples_definition ON examples(definition_id);
CREATE INDEX idx_examples_term ON examples(term_id);
CREATE INDEX idx_examples_language ON examples(language);
```

### 3.4 Usage Entity

Usage notes and context for terms.

```sql
CREATE TABLE usage_notes (
    -- Primary Key
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Parent Reference
    definition_id   UUID NOT NULL REFERENCES definitions(id) ON DELETE CASCADE,
    term_id         UUID NOT NULL REFERENCES terms(id) ON DELETE CASCADE,
    
    -- Content
    language        VARCHAR(5) NOT NULL DEFAULT 'en',
    text            TEXT NOT NULL,
    translation     TEXT,
    
    -- Classification
    usage_type      VARCHAR(50),                          -- caution, tip, note, historical, regional
    discipline_code VARCHAR(50),                          -- When specific to discipline
    
    -- Timestamps
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT unique_term_usage UNIQUE (term_id, usage_type, language)
);

CREATE INDEX idx_usage_term ON usage_notes(term_id);
CREATE INDEX idx_usage_definition ON usage_notes(definition_id);
CREATE INDEX idx_usage_type ON usage_notes(usage_type);
```

### 3.5 Alias Entity

Alternative names and spellings for terms.

```sql
CREATE TABLE aliases (
    -- Primary Key
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Term Reference
    term_id         UUID NOT NULL REFERENCES terms(id) ON DELETE CASCADE,
    
    -- Content
    language        VARCHAR(5) NOT NULL DEFAULT 'en',
    text            VARCHAR(255) NOT NULL,
    
    -- Classification
    alias_type      VARCHAR(50),                         -- spelling, abbreviation, colloquial, regional, synonym
    is_official      BOOLEAN DEFAULT FALSE,
    is_common        BOOLEAN DEFAULT FALSE,
    
    -- Search optimization
    normalized_text  VARCHAR(255),                        -- Lowercase, no accents for search
    
    -- Timestamps
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT unique_alias_term_text UNIQUE (term_id, language, text)
);

CREATE INDEX idx_aliases_term ON aliases(term_id);
CREATE INDEX idx_aliases_normalized ON aliases(normalized_text);
CREATE INDEX idx_aliases_language ON aliases(language);
```

---

## 4. Classification Entities

### 4.1 Tag Entity

Flexible tagging system for cross-cutting concerns.

```sql
CREATE TABLE tags (
    -- Primary Key
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Identification
    name            VARCHAR(100) NOT NULL UNIQUE,
    slug            VARCHAR(100) NOT NULL UNIQUE,
    
    -- Classification
    category        VARCHAR(50) NOT NULL,                 -- difficulty, equipment, physics, language, role, etc.
    language        VARCHAR(5),                           -- NULL for universal tags
    
    -- Hierarchy
    parent_id       UUID REFERENCES tags(id) ON DELETE SET NULL,
    
    -- Metadata
    description     TEXT,
    color           VARCHAR(7),
    icon            VARCHAR(50),
    sort_order      INTEGER DEFAULT 0,
    
    -- System
    is_system       BOOLEAN DEFAULT FALSE,                -- System-managed vs user-created
    is_restricted   BOOLEAN DEFAULT FALSE,                -- Requires permission to use
    
    -- Timestamps
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ,
    
    CONSTRAINT unique_slug UNIQUE (slug)
);

CREATE INDEX idx_tags_category ON tags(category);
CREATE INDEX idx_tags_parent ON tags(parent_id);
CREATE INDEX idx_tags_language ON tags(language);
```

**Predefined Tags (System):**

```json
{
  "categories": {
    "difficulty": ["#beginner", "#intermediate", "#advanced", "#professional"],
    "equipment": ["#cue", "#table", "#balls", "#cloth", "#chalk", "#bridge"],
    "physics": ["#spin", "#english", "#sidespin", "#draw", "#follow", "#center-ball"],
    "discipline": ["#pool", "#snooker", "#carom", "#chinese-eight-ball"],
    "role": ["#player", "#coach", "#referee", "#fan"],
    "ai": ["#coach", "#analysis", "#training", "#quiz", "#suggestion"],
    "pattern": ["#strategy", "#safety", "#offensive", "#defensive"]
  }
}
```

### 4.2 Term-Tag Junction Table

```sql
CREATE TABLE term_tags (
    term_id         UUID NOT NULL REFERENCES terms(id) ON DELETE CASCADE,
    tag_id          UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    
    -- Context
    context         VARCHAR(100),                         -- Why this tag applies
    weight          DECIMAL(3,2) DEFAULT 1.00,             -- Relevance weight
    
    -- Audit
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by      UUID REFERENCES users(id),
    
    PRIMARY KEY (term_id, tag_id)
);

CREATE INDEX idx_term_tags_tag ON term_tags(tag_id);
```

### 4.3 Term-Category Junction Table

```sql
CREATE TABLE term_categories (
    term_id         UUID NOT NULL REFERENCES terms(id) ON DELETE CASCADE,
    category_id     UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    
    -- Classification
    is_primary      BOOLEAN DEFAULT FALSE,                -- Primary category
    weight          DECIMAL(3,2) DEFAULT 1.00,              -- Relevance
    
    -- Order
    sort_order      INTEGER DEFAULT 0,
    
    -- Audit
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    PRIMARY KEY (term_id, category_id)
);

CREATE INDEX idx_term_categories_category ON term_categories(category_id);
```

---

## 5. Relationship Entities

### 5.1 Knowledge Graph Tables

The BKM uses a graph-based relationship model where every entity is a **Node** and every connection is an **Edge**. This enables complex traversals, learning paths, and AI-powered recommendations.

```sql
-- ============================================================
-- NODES TABLE - All knowledge entities
-- ============================================================
CREATE TABLE nodes (
    -- Primary Key
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Classification
    type            VARCHAR(50) NOT NULL,
    subtype         VARCHAR(50),
    
    -- Identification
    slug            VARCHAR(255) NOT NULL UNIQUE,
    status          VARCHAR(20) DEFAULT 'draft',
    version         VARCHAR(20) DEFAULT '1.0.0',
    
    -- Language
    language_primary    VARCHAR(5) DEFAULT 'en',
    language_supported  JSONB DEFAULT '["en", "vi"]',
    
    -- Names (multilingual JSON)
    names            JSONB NOT NULL,
    
    -- Descriptions (multilingual JSON)
    descriptions     JSONB NOT NULL,
    
    -- Classification
    difficulty       VARCHAR(20),
    discipline       JSONB DEFAULT '[]',
    category         JSONB DEFAULT '[]',
    tags             JSONB DEFAULT '[]',
    
    -- Aliases and related
    aliases          JSONB DEFAULT '[]',
    related_terms    JSONB DEFAULT '[]',
    synonyms         JSONB DEFAULT '[]',
    antonyms         JSONB DEFAULT '[]',
    
    -- Progression
    prerequisites    JSONB DEFAULT '[]',
    advanced_versions JSONB DEFAULT '[]',
    beginner_versions JSONB DEFAULT '[]',
    
    -- Media references
    media            JSONB DEFAULT '{"images": [], "videos": [], "animations": []}',
    
    -- Metadata
    metadata         JSONB DEFAULT '{}',
    
    -- Provenance
    is_verified      BOOLEAN DEFAULT FALSE,
    verified_by      UUID,
    verified_at      TIMESTAMPTZ,
    contributors     JSONB DEFAULT '[]',
    
    -- Timestamps
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    published_at     TIMESTAMPTZ,
    
    -- Constraints
    CONSTRAINT valid_node_type CHECK (type IN (
        'technique', 'shot', 'stroke', 'spin', 'position',
        'equipment', 'cue', 'shaft', 'tip', 'ball', 'table',
        'rule', 'pattern', 'strategy', 'mistake', 'mental',
        'drill', 'exercise', 'training_plan', 'scenario',
        'tournament', 'player', 'organization', 'coach',
        'video', 'animation', 'image', 'article', 'book',
        'question', 'answer', 'ai_prompt', 'physics', 'math',
        'variant'
    )),
    CONSTRAINT valid_node_status CHECK (status IN (
        'draft', 'review', 'published', 'deprecated'
    )),
    CONSTRAINT valid_node_difficulty CHECK (difficulty IS NULL OR difficulty IN (
        'beginner', 'intermediate', 'advanced', 'professional'
    ))
);

CREATE INDEX idx_nodes_type ON nodes(type);
CREATE INDEX idx_nodes_slug ON nodes(slug);
CREATE INDEX idx_nodes_status ON nodes(status);
CREATE INDEX idx_nodes_difficulty ON nodes(difficulty);
CREATE INDEX idx_nodes_discipline ON nodes USING GIN(discipline);
CREATE INDEX idx_nodes_tags ON nodes USING GIN(tags);
CREATE INDEX idx_nodes_created ON nodes(created_at);
CREATE INDEX idx_nodes_updated ON nodes(updated_at);

-- ============================================================
-- EDGES TABLE - Graph relationships
-- ============================================================
CREATE TABLE edges (
    -- Primary Key
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Endpoints
    source_id       UUID NOT NULL REFERENCES nodes(id) ON DELETE CASCADE,
    target_id       UUID NOT NULL REFERENCES nodes(id) ON DELETE CASCADE,
    
    -- Relationship Type
    edge_type       VARCHAR(50) NOT NULL,
    
    -- Direction
    direction       VARCHAR(20) DEFAULT 'forward',
    is_directional  BOOLEAN DEFAULT FALSE,
    
    -- Metadata
    metadata        JSONB DEFAULT '{}',
    strength        DECIMAL(3,2) DEFAULT 1.00,
    confidence      DECIMAL(3,2) DEFAULT 1.00,
    priority        INTEGER DEFAULT 2,
    
    -- Language-specific descriptions
    descriptions    JSONB DEFAULT '{}',
    
    -- Provenance
    provenance      JSONB DEFAULT '{}',
    source_ref      UUID,
    source_type     VARCHAR(20) DEFAULT 'internal',
    is_verified     BOOLEAN DEFAULT FALSE,
    verified_by     UUID,
    
    -- Constraints
    constraints     JSONB DEFAULT '{}',
    
    -- Timestamps
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Table Constraints
    CONSTRAINT unique_edge UNIQUE (source_id, target_id, edge_type),
    CONSTRAINT no_self_loop CHECK (source_id != target_id),
    CONSTRAINT valid_edge_type CHECK (edge_type IN (
        -- Hierarchy
        'IS_A', 'PART_OF', 'SAME_AS', 'SYNONYM', 'ANTONYM',
        -- Dependency
        'USES', 'USED_BY', 'REQUIRES', 'ENABLES',
        'CAUSES', 'CAUSED_BY', 'PREVENTS', 'PREVENTED_BY', 
        'CORRECTED_BY', 'CORRECTS',
        -- Progression
        'LEADS_TO', 'PRECEDED_BY', 'NEXT_LEVEL', 'PREVIOUS_LEVEL',
        'ADVANCED_VERSION', 'BEGINNER_VERSION', 'TRAINED_BY', 'TRAINS',
        -- Association
        'RELATED_TO', 'OPPOSITE_OF', 'CONFUSES_WITH', 'DISTINGUISHED_FROM',
        -- Container
        'CONTAINS', 'COMPOSED_OF', 'COMPOSES',
        -- Priority
        'MORE_IMPORTANT_THAN', 'LESS_IMPORTANT_THAN',
        'RECOMMENDED_FOR', 'RECOMMENDED_BY', 
        'NOT_RECOMMENDED_FOR', 'NOT_RECOMMENDED_BY',
        -- Media
        'VIDEO_EXPLAINS', 'EXPLAINED_IN_VIDEO',
        'IMAGE_SHOWS', 'SHOWN_IN_IMAGE',
        'ANIMATION_SHOWS', 'SHOWN_IN_ANIMATION',
        'ARTICLE_EXPLAINS', 'EXPLAINED_IN_ARTICLE',
        -- Provenance
        'INVENTED_BY', 'INVENTED', 'POPULARIZED_BY', 'POPULARIZED',
        'TAUGHT_BY', 'TEACHES', 'DOCUMENTED_BY', 'DOCUMENTS',
        -- Context
        'USED_IN', 'USES_CONCEPT', 'APPLICABLE_TO', 'APPLIES',
        'RULE_APPLIES', 'GOVERNS',
        -- Error
        'COMMON_ERROR'
    )),
    CONSTRAINT valid_direction CHECK (direction IN ('forward', 'backward', 'bidirectional')),
    CONSTRAINT valid_strength CHECK (strength >= 0 AND strength <= 1),
    CONSTRAINT valid_confidence CHECK (confidence >= 0 AND confidence <= 1)
);

CREATE INDEX idx_edges_source ON edges(source_id);
CREATE INDEX idx_edges_target ON edges(target_id);
CREATE INDEX idx_edges_type ON edges(edge_type);
CREATE INDEX idx_edges_both ON edges(source_id, target_id);
CREATE INDEX idx_edges_strength ON edges(strength);
CREATE INDEX idx_edges_confidence ON edges(confidence);
CREATE INDEX idx_edges_priority ON edges(priority);

-- ============================================================
-- GRAPH VERSIONS TABLE - Versioned graph snapshots
-- ============================================================
CREATE TABLE graph_versions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    version         VARCHAR(20) NOT NULL UNIQUE,
    description     TEXT,
    status          VARCHAR(20) DEFAULT 'active',
    
    -- Statistics
    node_count      INTEGER DEFAULT 0,
    edge_count      INTEGER DEFAULT 0,
    
    -- Provenance
    created_by      UUID,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    activated_at    TIMESTAMPTZ,
    deprecated_at   TIMESTAMPTZ,
    
    CONSTRAINT valid_version_status CHECK (status IN ('draft', 'active', 'deprecated'))
);

ALTER TABLE edges ADD COLUMN graph_version VARCHAR(20);
CREATE INDEX idx_edges_version ON edges(graph_version);
```

**Complete Edge Type Reference:**

| Edge Type | Inverse | Description |
|-----------|---------|-------------|
| `IS_A` | (self) | Classification |
| `PART_OF` | `CONTAINS` | Component |
| `SAME_AS` | (self) | Equivalence |
| `SYNONYM` | (self) | Alternative name |
| `ANTONYM` | (self) | Opposite |
| `USES` | `USED_BY` | Component usage |
| `REQUIRES` | `ENABLES` | Prerequisite |
| `CAUSES` | `CAUSED_BY` | Result |
| `PREVENTS` | `PREVENTED_BY` | Avoidance |
| `CORRECTED_BY` | `CORRECTS` | Fix |
| `LEADS_TO` | `PRECEDED_BY` | Progression |
| `NEXT_LEVEL` | `PREVIOUS_LEVEL` | Difficulty |
| `ADVANCED_VERSION` | `BEGINNER_VERSION` | Version |
| `TRAINED_BY` | `TRAINS` | Training |
| `RELATED_TO` | (self) | Loose link |
| `OPPOSITE_OF` | (self) | Contrast |
| `CONFUSES_WITH` | (self) | Confusion |
| `DISTINGUISHED_FROM` | (self) | Difference |
| `MORE_IMPORTANT_THAN` | `LESS_IMPORTANT_THAN` | Priority |
| `RECOMMENDED_FOR` | `RECOMMENDED_BY` | Suggestion |
| `NOT_RECOMMENDED_FOR` | `NOT_RECOMMENDED_BY` | Warning |
| `VIDEO_EXPLAINS` | `EXPLAINED_IN_VIDEO` | Media |
| `IMAGE_SHOWS` | `SHOWN_IN_IMAGE` | Media |
| `ANIMATION_SHOWS` | `SHOWN_IN_ANIMATION` | Media |
| `INVENTED_BY` | `INVENTED` | Origin |
| `POPULARIZED_BY` | `POPULARIZED` | Fame |
| `TAUGHT_BY` | `TEACHES` | Teaching |
| `USED_IN` | `USES_CONCEPT` | Context |
| `RULE_APPLIES` | `GOVERNS` | Rule scope |
| `COMMON_ERROR` | (self) | Mistake |

```sql
CREATE TABLE relationships (
    -- Primary Key
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Endpoints
    source_id       UUID NOT NULL REFERENCES terms(id) ON DELETE CASCADE,
    target_id        UUID NOT NULL REFERENCES terms(id) ON DELETE CASCADE,
    
    -- Relationship Type
    relationship_type VARCHAR(50) NOT NULL,
    
    -- Direction
    is_directional  BOOLEAN DEFAULT FALSE,
    
    -- Metadata
    weight          DECIMAL(3,2) DEFAULT 1.00,              -- Relationship strength
    confidence      DECIMAL(3,2) DEFAULT 1.00,              -- Relationship accuracy
    evidence        TEXT,                                  -- Why this relationship exists
    
    -- Provenance
    source_ref      UUID REFERENCES sources(id),
    is_verified     BOOLEAN DEFAULT FALSE,
    verified_by     UUID REFERENCES users(id),
    
    -- Timestamps
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT unique_relationship UNIQUE (source_id, target_id, relationship_type),
    CONSTRAINT no_self_reference CHECK (source_id != target_id),
    CONSTRAINT valid_relationship_type CHECK (relationship_type IN (
        'uses', 'used_by', 'prerequisite', 'leads_to', 
        'opposite', 'contrast', 'related', 'similar',
        'advanced_from', 'advanced_into', 'part_of', 'contains',
        'applies_to', 'applies', 'confuses_with', 'distinguished_from'
    ))
);

CREATE INDEX idx_relationships_source ON relationships(source_id);
CREATE INDEX idx_relationships_target ON relationships(target_id);
CREATE INDEX idx_relationships_type ON relationships(relationship_type);
CREATE INDEX idx_relationships_both ON relationships(source_id, target_id);
```

**Relationship Types:**

| Type | Description | Inverse | Example |
|------|-------------|---------|---------|
| `uses` | Term A uses Term B | `used_by` | Draw Shot → Back Spin |
| `prerequisite` | Must know A before B | `leads_to` | Stop Shot → Draw Shot |
| `opposite` | Contrasting meanings | (symmetric) | Draw Shot ↔ Follow Shot |
| `related` | Loose association | (symmetric) | Draw Shot ↔ Cue Ball Control |
| `advanced_from` | Basic version of advanced | `advanced_into` | Basic Spin → Power Draw |
| `part_of` | Component of larger concept | `contains` | Bridge → Stroke Mechanics |
| `applies_to` | General rule applied to specific | `applies` | Ball Dynamics → Draw Shot |
| `confuses_with` | Commonly confused with | (symmetric) | English ↔ Sidespin |
| `distinguished_from` | Different from similar term | (symmetric) | Draw Shot ↔ Stop Shot |

### 5.2 Relationship Metadata

```sql
CREATE TABLE relationship_metadata (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    relationship_id     UUID NOT NULL REFERENCES relationships(id) ON DELETE CASCADE,
    
    -- Context
    context             VARCHAR(255),                     -- When this relationship applies
    discipline_code     VARCHAR(50),                      -- When specific to discipline
    
    -- Content
    description         TEXT,
    
    -- Timestamps
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT unique_relationship_context UNIQUE (relationship_id, context, discipline_code)
);
```

---

## 6. Media Entities

### 6.1 Media Entity

```sql
CREATE TABLE media (
    -- Primary Key
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Type Classification
    media_type      VARCHAR(50) NOT NULL,                 -- image, video, animation, audio, svg
    
    -- File Information
    filename        VARCHAR(255) NOT NULL,
    original_name   VARCHAR(255),
    mime_type       VARCHAR(100) NOT NULL,
    file_size       BIGINT NOT NULL,                      -- Bytes
    
    -- Storage
    storage_path    VARCHAR(500) NOT NULL,                -- S3/GCS path
    cdn_url         VARCHAR(500),                         -- CDN URL
    thumbnail_url   VARCHAR(500),
    
    -- Dimensions (for images/videos)
    width           INTEGER,
    height          INTEGER,
    duration        DECIMAL(10,2),                         -- Seconds for video/audio
    
    -- Quality Metrics
    quality         INTEGER,                               -- 1-100 scale
    format_version  VARCHAR(20),                          -- e.g., "1080p", "720p"
    
    -- Attribution
    source_url      VARCHAR(500),
    attribution     TEXT,
    license         VARCHAR(100),                          -- CC BY 4.0, etc.
    
    -- Status
    status          VARCHAR(20) DEFAULT 'processing',
    
    -- Timestamps
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    processed_at    TIMESTAMPTZ,
    
    -- Checksum
    checksum        VARCHAR(64),                           -- SHA-256
    
    CONSTRAINT valid_media_type CHECK (media_type IN ('image', 'video', 'animation', 'audio', 'svg', 'document')),
    CONSTRAINT valid_status CHECK (status IN ('uploading', 'processing', 'ready', 'error', 'archived'))
);

CREATE INDEX idx_media_type ON media(media_type);
CREATE INDEX idx_media_cdn ON media(cdn_url);
CREATE INDEX idx_media_status ON media(status);
```

### 6.2 Media Metadata

```sql
CREATE TABLE media_metadata (
    -- Primary Key
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    media_id        UUID NOT NULL REFERENCES media(id) ON DELETE CASCADE,
    
    -- Content
    language        VARCHAR(5) NOT NULL DEFAULT 'en',
    alt_text        TEXT NOT NULL,                        -- Required for accessibility
    caption         TEXT,
    description     TEXT,
    
    -- SEO
    title           VARCHAR(255),
    keywords        TEXT[],
    
    -- Technical (transcoded variants)
    variant_of      UUID REFERENCES media(id),
    variant_type     VARCHAR(50),                          -- thumbnail, preview, full, hd
    
    -- Accessibility
    transcript      TEXT,                                  -- For video/audio
    duration_ms     BIGINT,                                -- For precise sync
    
    -- Timestamps
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT unique_media_language UNIQUE (media_id, language)
);

CREATE INDEX idx_media_metadata_media ON media_metadata(media_id);
CREATE INDEX idx_media_metadata_language ON media_metadata(language);
```

### 6.3 Term-Media Junction

```sql
CREATE TABLE term_media (
    term_id         UUID NOT NULL REFERENCES terms(id) ON DELETE CASCADE,
    media_id        UUID NOT NULL REFERENCES media(id) ON DELETE CASCADE,
    
    -- Context
    usage_type      VARCHAR(50),                          -- primary_example, demonstration, diagram, drill_preview
    caption         TEXT,
    sort_order      INTEGER DEFAULT 0,
    weight          DECIMAL(3,2) DEFAULT 1.00,
    
    -- Timestamp
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    PRIMARY KEY (term_id, media_id)
);

CREATE INDEX idx_term_media_media ON term_media(media_id);
```

---

## 7. Reference Entities

### 7.1 Source Entity

External references and sources.

```sql
CREATE TABLE sources (
    -- Primary Key
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Identification
    source_type     VARCHAR(50) NOT NULL,                 -- book, article, video, website, official_rule, expert
    title           VARCHAR(500) NOT NULL,
    
    -- Identification Details
    authors         TEXT[],
    editors         TEXT[],
    translators     TEXT[],
    
    -- Publication Info
    publisher       VARCHAR(255),
    published_date  DATE,
    edition         VARCHAR(100),
    isbn            VARCHAR(20),
    url             VARCHAR(500),
    
    -- Content
    abstract        TEXT,
    
    -- Access
    access_type     VARCHAR(50),                          -- free, subscription, purchase, official
    access_url      VARCHAR(500),
    
    -- Quality
    credibility     VARCHAR(20),                          -- official, authoritative, peer_reviewed, general
    is_verified     BOOLEAN DEFAULT FALSE,
    
    -- Language
    language        VARCHAR(5) DEFAULT 'en',
    
    -- Timestamps
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT valid_source_type CHECK (source_type IN ('book', 'article', 'video', 'website', 'official_rule', 'expert', 'tournament', 'organization')),
    CONSTRAINT valid_credibility CHECK (credibility IN ('official', 'authoritative', 'peer_reviewed', 'general', 'unverified'))
);

CREATE INDEX idx_sources_type ON sources(source_type);
CREATE INDEX idx_sources_credibility ON sources(credibility);
CREATE INDEX idx_sources_isbn ON sources(isbn);
```

### 7.2 Cross Reference Entity

```sql
CREATE TABLE cross_references (
    -- Primary Key
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Reference From
    source_type     VARCHAR(50) NOT NULL,                 -- term, definition, example
    source_id       UUID NOT NULL,
    
    -- Reference To
    target_type     VARCHAR(50) NOT NULL,                 -- term, source, external
    target_id       UUID,
    target_url      VARCHAR(500),
    
    -- Content
    reference_type  VARCHAR(50),                         -- see_also, citation, related, external_link
    description     TEXT,
    
    -- Context
    context         TEXT,                                 -- When this reference applies
    
    -- Order
    sort_order      INTEGER DEFAULT 0,
    
    -- Timestamps
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT valid_reference_type CHECK (reference_type IN ('see_also', 'citation', 'related', 'external_link', 'learn_more'))
);

CREATE INDEX idx_cross_refs_source ON cross_references(source_type, source_id);
CREATE INDEX idx_cross_refs_target ON cross_references(target_type, target_id);
```

---

## 8. Audit and Versioning Entities

### 8.1 Version History

```sql
CREATE TABLE version_history (
    -- Primary Key
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Entity Reference
    entity_type     VARCHAR(50) NOT NULL,
    entity_id       UUID NOT NULL,
    
    -- Version Info
    version         VARCHAR(20) NOT NULL,
    change_type     VARCHAR(50) NOT NULL,                -- created, updated, deleted, restored
    
    -- Change Details
    changes         JSONB,                                -- {"field": {"old": "x", "new": "y"}}
    change_summary  TEXT,
    
    -- Attribution
    changed_by      UUID REFERENCES users(id),
    changed_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Revert Support
    previous_data   JSONB,                               -- Full entity state before change
    is_reverted     BOOLEAN DEFAULT FALSE,
    reverted_at     TIMESTAMPTZ,
    
    CONSTRAINT unique_entity_version UNIQUE (entity_type, entity_id, version)
);

CREATE INDEX idx_version_history_entity ON version_history(entity_type, entity_id);
CREATE INDEX idx_version_history_version ON version_history(version);
CREATE INDEX idx_version_history_changed ON version_history(changed_at DESC);
```

### 8.2 Content Change Log

```sql
CREATE TABLE change_log (
    -- Primary Key
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Reference
    entity_type     VARCHAR(50) NOT NULL,
    entity_id       UUID NOT NULL,
    
    -- Change Details
    field_name      VARCHAR(100),
    old_value       TEXT,
    new_value       TEXT,
    
    -- Context
    change_reason   TEXT,
    change_type     VARCHAR(50),                         -- content, format, translation, correction
    
    -- Attribution
    changed_by      UUID REFERENCES users(id),
    reviewed_by     UUID REFERENCES users(id),
    reviewed_at     TIMESTAMPTZ,
    
    -- Status
    status          VARCHAR(20) DEFAULT 'pending',       -- pending, approved, rejected
    notes           TEXT,
    
    -- Timestamps
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT valid_change_status CHECK (status IN ('pending', 'approved', 'rejected'))
);

CREATE INDEX idx_change_log_entity ON change_log(entity_type, entity_id);
CREATE INDEX idx_change_log_status ON change_log(status);
CREATE INDEX idx_change_log_created ON change_log(created_at DESC);
```

---

## 9. Indexing Strategy

### 9.1 Composite Indexes

```sql
-- Terms: Common query patterns
CREATE INDEX idx_terms_lang_status ON terms(language, status);
CREATE INDEX idx_terms_disc_lang ON terms(discipline_id, language);
CREATE INDEX idx_terms_lang_difficulty ON terms(language, difficulty);
CREATE INDEX idx_terms_lang_status_pub ON terms(language, status, published_at DESC);

-- Search optimization
CREATE INDEX idx_terms_slug_normalized ON terms(LOWER(slug));
CREATE INDEX idx_terms_name_trgm ON terms USING GIN (name gin_trgm_ops);

-- Categories: Hierarchy queries
CREATE INDEX idx_categories_path_prefix ON categories USING GIST (path gist_ltree_ops);
CREATE INDEX idx_categories_disc_lang ON categories(discipline_id, language);
```

### 9.2 Full-Text Search Configuration

```sql
-- PostgreSQL FTS Configuration
ALTER TEXT SEARCH CONFIGURATION english_config
  ADD MAPPING FOR asciiword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION vietnamese_config
  ADD MAPPING FOR asciiword WITH simple;

-- Combined FTS index for terms
CREATE INDEX idx_terms_combined_fts ON terms USING GIN (
    setweight(to_tsvector('english_config', COALESCE(name->>'en', '')), 'A') ||
    setweight(to_tsvector('english_config', COALESCE(summary->>'en', '')), 'B') ||
    setweight(to_tsvector('english_config', COALESCE((SELECT string_agg(value, ' ') FROM jsonb_each_text(name)), '')), 'C')
);
```

### 9.3 Vector Index

```sql
-- For semantic search (requires pgvector extension)
CREATE EXTENSION IF NOT EXISTS vector;

ALTER TABLE terms ADD COLUMN embedding vector(1536);

CREATE INDEX idx_terms_embedding ON terms 
  USING ivfflat (embedding vector_cosine_ops)
  WITH (lists = 100);
```

---

## 10. Migration Strategy

### 10.1 Migration File Structure

```
migrations/
├── supabase/
│   ├── 001_initial_schema.sql
│   ├── 002_add_disciplines.sql
│   ├── 003_add_categories.sql
│   ├── 004_add_terms.sql
│   ├── 005_add_translations.sql
│   ├── 006_add_media.sql
│   ├── 007_add_relationships.sql
│   ├── 008_add_tags.sql
│   ├── 009_add_sources.sql
│   └── 010_add_fulltext_search.sql
│
└── sqlite/
    ├── 001_initial_schema.sql
    ├── 002_sync_additions.sql
    └── 003_fts_setup.sql
```

### 10.2 Migration Template

```sql
-- Migration: 011_add_ai_features.sql
-- Description: Add AI-related fields for enhanced context
-- Created: 2026-07-01
-- Author: Pool OS Team

-- This migration is idempotent and reversible

BEGIN;

-- Add new columns
ALTER TABLE terms 
ADD COLUMN IF NOT EXISTS ai_context JSONB,
ADD COLUMN IF NOT EXISTS embedding vector(1536);

-- Create index for embeddings
CREATE INDEX IF NOT EXISTS idx_terms_embedding ON terms 
  USING ivfflat (embedding vector_cosine_ops)
  WITH (lists = 100);

-- Add embedding timestamp
ALTER TABLE terms 
ADD COLUMN IF NOT EXISTS embedding_updated_at TIMESTAMPTZ;

-- Create function to update embedding timestamp
CREATE OR REPLACE FUNCTION update_embedding_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.embedding IS DISTINCT FROM OLD.embedding THEN
    NEW.embedding_updated_at = NOW();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
DROP TRIGGER IF EXISTS terms_embedding_update ON terms;
CREATE TRIGGER terms_embedding_update
  BEFORE UPDATE ON terms
  FOR EACH ROW
  EXECUTE FUNCTION update_embedding_timestamp();

-- Add comments for documentation
COMMENT ON COLUMN terms.ai_context IS 'Pre-computed AI context for faster LLM responses';
COMMENT ON COLUMN terms.embedding IS 'Vector embedding for semantic search';
COMMENT ON COLUMN terms.embedding_updated_at IS 'When the embedding was last computed';

COMMIT;

-- Rollback instruction
-- ROLLBACK;
```

---

## 11. SQLite Schema (Offline)

### 11.1 Local Database Structure

```sql
-- SQLite schema mirrors Supabase with local optimizations
-- Stored in app documents directory

PRAGMA foreign_keys = ON;
PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;
PRAGMA cache_size = -64000;  -- 64MB cache
PRAGMA temp_store = MEMORY;

-- Terms table (core)
CREATE TABLE IF NOT EXISTS terms (
    id              TEXT PRIMARY KEY,                    -- UUID as text
    slug            TEXT NOT NULL,
    language        TEXT NOT NULL DEFAULT 'en',
    name            TEXT NOT NULL,                       -- JSON string
    summary         TEXT,
    discipline_id   TEXT,
    status          TEXT DEFAULT 'published',
    difficulty      TEXT,
    version         TEXT DEFAULT 'v1',
    view_count      INTEGER DEFAULT 0,
    created_at      TEXT NOT NULL,
    updated_at      TEXT NOT NULL,
    
    UNIQUE(slug, language)
);

-- Simplified indexes for SQLite
CREATE INDEX IF NOT EXISTS idx_terms_slug ON terms(slug);
CREATE INDEX IF NOT EXISTS idx_terms_language ON terms(language);
CREATE INDEX IF NOT EXISTS idx_terms_discipline ON terms(discipline_id);

-- Full-text search table
CREATE VIRTUAL TABLE IF NOT EXISTS terms_fts USING fts5(
    slug,
    name,
    summary,
    content='terms',
    content_rowid='rowid'
);

-- Triggers to keep FTS in sync
CREATE TRIGGER IF NOT EXISTS terms_ai AFTER INSERT ON terms BEGIN
    INSERT INTO terms_fts(rowid, slug, name, summary) 
    VALUES (new.rowid, new.slug, new.name, new.summary);
END;

CREATE TRIGGER IF NOT EXISTS terms_ad AFTER DELETE ON terms BEGIN
    INSERT INTO terms_fts(terms_fts, rowid, slug, name, summary) 
    VALUES('delete', old.rowid, old.slug, old.name, old.summary);
END;

CREATE TRIGGER IF NOT EXISTS terms_au AFTER UPDATE ON terms BEGIN
    INSERT INTO terms_fts(terms_fts, rowid, slug, name, summary) 
    VALUES('delete', old.rowid, old.slug, old.name, old.summary);
    INSERT INTO terms_fts(rowid, slug, name, summary) 
    VALUES (new.rowid, new.slug, new.name, new.summary);
END;

-- Categories table
CREATE TABLE IF NOT EXISTS categories (
    id              TEXT PRIMARY KEY,
    slug            TEXT NOT NULL,
    parent_id       TEXT,
    discipline_id   TEXT,
    name            TEXT NOT NULL,                       -- JSON string
    path            TEXT,
    language        TEXT NOT NULL DEFAULT 'en',
    sort_order      INTEGER DEFAULT 0,
    
    UNIQUE(slug, language)
);

CREATE INDEX IF NOT EXISTS idx_categories_parent ON categories(parent_id);
CREATE INDEX IF NOT EXISTS idx_categories_language ON categories(language);

-- Translations table
CREATE TABLE IF NOT EXISTS translations (
    id              TEXT PRIMARY KEY,
    entity_type     TEXT NOT NULL,
    entity_id       TEXT NOT NULL,
    language        TEXT NOT NULL,
    name            TEXT,
    summary         TEXT,
    
    UNIQUE(entity_type, entity_id, language)
);

CREATE INDEX IF NOT EXISTS idx_translations_entity ON translations(entity_type, entity_id);

-- Sync metadata
CREATE TABLE IF NOT EXISTS sync_metadata (
    key             TEXT PRIMARY KEY,
    value           TEXT,
    updated_at      TEXT NOT NULL
);

-- Insert current sync state
INSERT OR REPLACE INTO sync_metadata (key, value, updated_at) 
VALUES ('schema_version', '1.0', datetime('now'));
```

---

## 12. Appendix

### 12.1 Entity Summary

| Entity | Description | Key Fields |
|--------|-------------|------------|
| `disciplines` | Billiards variants | code, name, variants |
| `categories` | Term categorization | slug, parent_id, path |
| `terms` | Core knowledge unit | slug, name, discipline_id |
| `translations` | Multi-language content | language, name, summary |
| `definitions` | Detailed definitions | definition, explanation |
| `examples` | Usage examples | text, context |
| `aliases` | Alternative names | text, alias_type |
| `relationships` | Term connections | source_id, target_id, type |
| `tags` | Flexible classification | name, category |
| `media` | Images, videos | url, media_type |
| `sources` | External references | source_type, title |
| `version_history` | Change tracking | version, changes |

### 12.2 Related Documents

- [BKM Architecture](./02_Architecture.md)
- [BKM JSON Spec](./04_JSON_Spec.md)
- [BKM API Design](./15_API_Design_For_PoolOS.md)
- [BKM Search System](./05_Search_System.md)

---

**End of Document**
