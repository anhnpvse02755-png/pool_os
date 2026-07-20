# BKM - Cross Reference System

## Version 1.0
**Last Updated:** July 2026
**Status:** Production Standard

---

## 1. Overview

The Cross Reference System defines semantic relationships between terms in the BKM Knowledge Graph. It enables navigation between related concepts, learning pathways, and context-aware suggestions.

---

## 2. Relationship Types

### 2.1 Relationship Type Definitions

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         RELATIONSHIP TYPE HIERARCHY                           │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                     │
    │                     CROSS REFERENCE SYSTEM                            │
    │                                                                      │
    │   ┌──────────────────────────────────────────────────────────────┐  │
    │   │  LEARN (Learning Relationships)                              │  │
    │   │                                                               │  │
    │   │  ├── Recommended Previous (prerequisite)                     │  │
    │   │  ├── Recommended Next (progression)                         │  │
    │   │  └── Learning Path                                           │  │
    │   └──────────────────────────────────────────────────────────────┘  │
    │                                                                      │
    │   ┌──────────────────────────────────────────────────────────────┐  │
    │   │  SEMANTIC (Meaning Relationships)                          │  │
    │   │                                                               │  │
    │   │  ├── Related Terms (general association)                    │  │
    │   │  ├── Synonym (same meaning)                                │  │
    │   │  ├── Antonym (opposite meaning)                            │  │
    │   │  ├── Parent (broader concept)                              │  │
    │   │  └── Child (narrower concept)                              │  │
    │   └──────────────────────────────────────────────────────────────┘  │
    │                                                                      │
    │   ┌──────────────────────────────────────────────────────────────┐  │
    │   │  CONTEXT (Usage Relationships)                             │  │
    │   │                                                               │  │
    │   │  ├── See Also (related in usage)                           │  │
    │   │  ├── Often Used With (frequently together)                  │  │
    │   │  ├── Part Of (component relationship)                      │  │
    │   │  └── Composed Of (has components)                          │  │
    │   └──────────────────────────────────────────────────────────────┘  │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘
```

### 2.2 Primary Relationship Types

| Type | Code | Description | Directional | Example |
|------|------|-------------|-------------|---------|
| `related` | REL | General semantic relationship | Bidirectional | Draw Shot ↔ Follow Shot |
| `see_also` | SA | Related but not prerequisite | Bidirectional | Bank Shot ↔ Kick Shot |
| `recommended_next` | RN | Next in learning sequence | Unidirectional | Stop Shot → Draw Shot |
| `recommended_previous` | RP | Prerequisite knowledge | Unidirectional | Draw Shot ← Stop Shot |

---

## 3. Data Model

### 3.1 Cross Reference Entity

```json
{
  "id": "XREF-000001",
  "source_term_id": "TERM-000007",
  "target_term_id": "TERM-000008",
  "relationship_type": "related",
  "relationship_direction": "bidirectional",
  "weight": 0.85,
  "context": {
    "en": "Basic shots that form the foundation",
    "vi": "Các đường cơ bản tạo nền tảng"
  },
  "usage_note": {
    "en": "Often compared when teaching shot selection",
    "vi": "Thường được so sánh khi dạy chọn đường"
  },
  "is_curated": true,
  "is_auto_generated": false,
  "confidence_score": 1.0,
  "created_at": "2026-07-17T00:00:00Z",
  "updated_at": "2026-07-17T00:00:00Z"
}
```

### 3.2 Field Definitions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | ID | Yes | XREF-NNNNNN |
| `source_term_id` | ID | Yes | Starting term |
| `target_term_id` | ID | Yes | Related term |
| `relationship_type` | enum | Yes | Type of relationship |
| `relationship_direction` | enum | No | bidirectional/unidirectional |
| `weight` | float | No | Relationship strength (0-1) |
| `context` | object | No | Contextual explanation |
| `usage_note` | object | No | Usage guidance |
| `is_curated` | boolean | Yes | Manually curated |
| `is_auto_generated` | boolean | Yes | System-generated |
| `confidence_score` | float | No | Auto-generation confidence |
| `created_at` | timestamp | Yes | Creation time |
| `updated_at` | timestamp | Yes | Last update |

### 3.3 Relationship Type Enum

```sql
TYPE relationship_type AS ENUM (
    'related',           -- General semantic relationship
    'see_also',         -- Related in usage context
    'recommended_next',  -- Next in learning path
    'recommended_previous', -- Prerequisite
    'synonym',          -- Same meaning
    'antonym',          -- Opposite meaning
    'parent',           -- Broader concept
    'child',            -- Narrower concept
    'part_of',          -- Component relationship
    'composed_of',      -- Has components
    'often_used_with'   -- Frequent co-occurrence
);
```

---

## 4. Relationship Definitions

### 4.1 Related Terms (REL)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              RELATED TERMS                                    │
└─────────────────────────────────────────────────────────────────────────────┘

    Definition:
    Terms that share semantic similarity, are often discussed together,
    or belong to the same conceptual category.
    
    Characteristics:
    • Bidirectional (A ↔ B)
    • Mutual relevance
    • May not have direct dependency
    
    Examples:
    ┌─────────────────────────────────────────────────────────────────────┐
    │ Term A           │ Term B           │ Relationship                │
    ├─────────────────┼──────────────────┼─────────────────────────────┤
    │ Draw Shot        │ Follow Shot      │ Basic control shots        │
    │ Bank Shot        │ Kick Shot        │ Cushion-based shots        │
    │ English          │ Deflection       │ Spin-related physics       │
    │ Stance           │ Grip             │ Fundamental setup          │
    └─────────────────────────────────────────────────────────────────────┘
    
    Weight Guidelines:
    • 0.9-1.0: Very strongly related (often mentioned together)
    • 0.7-0.8: Strongly related (same category)
    • 0.5-0.6: Moderately related (shared concept)
    • 0.3-0.4: Weakly related (some overlap)
```

### 4.2 See Also (SA)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                               SEE ALSO                                       │
└─────────────────────────────────────────────────────────────────────────────┘

    Definition:
    Terms that are related in usage context but serve different purposes.
    Used for supplementary information and expanded context.
    
    Characteristics:
    • Bidirectional (A ↔ B)
    • Contextual relevance
    • Not prerequisite relationships
    
    Examples:
    ┌─────────────────────────────────────────────────────────────────────┐
    │ Term A           │ Term B           │ Context                    │
    ├─────────────────┼──────────────────┼─────────────────────────────┤
    │ Bank Shot        │ Kick Shot        │ Both use cushion rebounds  │
    │ Safety Play      │ Snooker          │ Defensive strategies       │
    │ Break Shot      │ Spread           │ Break outcomes             │
    │ English          │ Squirt           │ Related physics concepts   │
    └─────────────────────────────────────────────────────────────────────┘
    
    Usage Guidelines:
    "See Also" links suggest additional topics to explore
    without implying a learning dependency.
```

### 4.3 Recommended Next (RN)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           RECOMMENDED NEXT                                    │
└─────────────────────────────────────────────────────────────────────────────┘

    Definition:
    Terms that logically follow in a learning progression.
    Completing understanding of the current term enables understanding
    of the recommended next term.
    
    Characteristics:
    • Unidirectional (A → B)
    • Learning progression
    • Increasing complexity
    
    Learning Path Example:
    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                   │
    │   [Stop Shot] ──RN──→ [Follow Shot] ──RN──→ [Draw Shot]          │
    │       │                   │                    │                  │
    │       ▼                   ▼                    ▼                  │
    │   Basic ball          Power control         Spin control          │
    │   stopping            and position          and curve            │
    │                                                                   │
    └─────────────────────────────────────────────────────────────────────┘
    
    Weight Guidelines:
    • 0.9-1.0: Direct next step, almost always recommended
    • 0.7-0.8: Common progression path
    • 0.5-0.6: Alternative next step
```

### 4.4 Recommended Previous (RP)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         RECOMMENDED PREVIOUS                                  │
└─────────────────────────────────────────────────────────────────────────────┘

    Definition:
    Prerequisite terms that should be understood before the current term.
    Automatically derived from "Recommended Next" inverse relationship.
    
    Characteristics:
    • Unidirectional (A ← B)
    • Prerequisite relationship
    • Reflects learning order
    
    Note: This is typically the inverse of Recommended Next.
    System may auto-generate RP from RN relationships.
```

---

## 5. Bidirectional vs Unidirectional

### 5.1 Relationship Direction Matrix

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        DIRECTION RULES                                       │
└─────────────────────────────────────────────────────────────────────────────┘

    Bidirectional Relationships:
    ┌─────────────────────────────────────────────────────────────────────┐
    │ Type              │ A ↔ B?    │ Notes                            │
    ├───────────────────┼────────────┼──────────────────────────────────┤
    │ Related           │ Yes        │ Mutual association               │
    │ See Also          │ Yes        │ Mutual context                  │
    │ Synonym           │ Yes        │ Same meaning                    │
    │ Antonym           │ Yes        │ Opposite meaning                │
    │ Often Used With   │ Yes        │ Mutual co-occurrence            │
    └─────────────────────────────────────────────────────────────────────┘
    
    Unidirectional Relationships:
    ┌─────────────────────────────────────────────────────────────────────┐
    │ Type                  │ A → B?      │ Notes                        │
    ├───────────────────────┼─────────────┼──────────────────────────────┤
    │ Recommended Next      │ Yes         │ Learning progression         │
    │ Recommended Previous  │ Yes         │ Prerequisite (inverse)      │
    │ Parent                │ Yes         │ Hierarchy (A is parent)     │
    │ Child                 │ Yes         │ Hierarchy (A is child)      │
    │ Part Of               │ Yes         │ A is part of B              │
    │ Composed Of           │ Yes         │ A has B as component        │
    └─────────────────────────────────────────────────────────────────────┘
```

---

## 6. Learning Path System

### 6.1 Path Generation

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          LEARNING PATHS                                      │
└─────────────────────────────────────────────────────────────────────────────┘

    Learning paths are generated from Recommended Next relationships:
    
    ┌─────────────────────────────────────────────────────────────────────┐
    │                         FUNDAMENTALS PATH                            │
    │                                                                      │
    │   Level 1          Level 2          Level 3          Level 4       │
    │   ───────         ───────         ───────         ───────          │
    │                                                                   │
    │   [Cue Ball]───→[Object Ball]───→[Stop Shot]───→[Follow Shot]   │
    │       │               │               │               │             │
    │       │               │               ▼               ▼             │
    │       │               │          [Draw Shot]───→[English]         │
    │       │               │               │               │             │
    │       │               │               ▼               ▼             │
    │       │               │          [Massé]────────→[Jump Shot]      │
    │       │               │                                               │
    │       └───────────────┴───────────────┘                               │
    │                        BASIC SHOTS                                    │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘
```

### 6.2 Path Types

| Path Type | Description | Example |
|-----------|-------------|---------|
| `fundamentals` | Core concepts | Stance, Grip, Aiming basics |
| `shot_types` | Shot technique progression | Stop → Follow → Draw |
| `spin_mastery` | Spin technique path | Basic → English → Massé |
| `safety_play` | Defensive techniques | Basic Safety → Advanced Safety |
| `competition` | Tournament knowledge | Rules → Formats → Strategy |
| `equipment` | Equipment mastery | Cues → Maintenance → Selection |

---

## 7. Confidence & Curation

### 7.1 Relationship Weights

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            WEIGHT SCALE                                      │
└─────────────────────────────────────────────────────────────────────────────┘

    Weight Range: 0.0 - 1.0
    
    ┌─────────────────────────────────────────────────────────────────────┐
    │  1.0  │██████████████████████████████████████████████│ Strongest  │
    │  0.9  │███████████████████████████████████████      │ Very High  │
    │  0.8  │███████████████████████████████████          │ High       │
    │  0.7  │███████████████████████████████              │ Strong     │
    │  0.6  │███████████████████████████                  │ Moderate   │
    │  0.5  │████████████████████████                    │ Medium     │
    │  0.4  │███████████████████                          │ Weak       │
    │  0.3  │████████████████                            │ Very Weak  │
    │  0.2  │████████████                                │ Minimal    │
    │  0.1  │████████                                    │ Negligible │
    └─────────────────────────────────────────────────────────────────────┘
    
    Default Weight: 0.5 (moderate relationship)
```

### 7.2 Curation Status

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           CURATION STATUS                                    │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────┐
    │ Curation Matrix                                                     │
    │                                                                      │
    │ is_curated │ is_auto_generated │ Status                             │
    ├───────────┼───────────────────┼────────────────────────────────────┤
    │ true      │ false             │ Expert-curated (highest trust)    │
    │ false     │ true              │ Auto-generated (needs validation)  │
    │ true      │ true              │ Auto + validated                   │
    │ false     │ false             │ Legacy/unknown (review needed)     │
    └─────────────────────────────────────────────────────────────────────┘
    
    Confidence Score:
    • 1.0: High confidence (curated or validated auto)
    • 0.8-0.9: Good confidence (likely correct)
    • 0.5-0.7: Moderate confidence (review recommended)
    • < 0.5: Low confidence (manual review required)
```

---

## 8. Database Schema

### 8.1 PostgreSQL

```sql
-- Cross Reference Table
CREATE TABLE cross_references (
    id                      VARCHAR(20) PRIMARY KEY,
    source_term_id          VARCHAR(20) NOT NULL,
    target_term_id          VARCHAR(20) NOT NULL,
    relationship_type        VARCHAR(30) NOT NULL,
    relationship_direction   VARCHAR(20) NOT NULL DEFAULT 'bidirectional',
    weight                  DECIMAL(3,2) DEFAULT 0.50,
    
    -- Context and notes
    context                 JSONB,
    usage_note              JSONB,
    
    -- Metadata
    is_curated              BOOLEAN NOT NULL DEFAULT false,
    is_auto_generated       BOOLEAN NOT NULL DEFAULT false,
    confidence_score         DECIMAL(3,2) DEFAULT 0.50,
    source_system            VARCHAR(50),
    last_validated_by        VARCHAR(100),
    
    -- Timestamps
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT valid_relationship_type CHECK (
        relationship_type IN (
            'related', 'see_also', 'recommended_next', 'recommended_previous',
            'synonym', 'antonym', 'parent', 'child', 'part_of', 
            'composed_of', 'often_used_with'
        )
    ),
    CONSTRAINT valid_direction CHECK (
        relationship_direction IN ('bidirectional', 'unidirectional')
    ),
    CONSTRAINT valid_weight CHECK (weight >= 0 AND weight <= 1),
    CONSTRAINT unique_source_target_type UNIQUE (
        source_term_id, target_term_id, relationship_type
    ),
    CONSTRAINT no_self_reference CHECK (source_term_id != target_term_id)
);

-- Foreign keys
ALTER TABLE cross_references
ADD CONSTRAINT fk_source_term
FOREIGN KEY (source_term_id) REFERENCES terms(id) ON DELETE CASCADE;

ALTER TABLE cross_references
ADD CONSTRAINT fk_target_term
FOREIGN KEY (target_term_id) REFERENCES terms(id) ON DELETE CASCADE;

-- Indexes
CREATE INDEX idx_xref_source ON cross_references(source_term_id);
CREATE INDEX idx_xref_target ON cross_references(target_term_id);
CREATE INDEX idx_xref_type ON cross_references(relationship_type);
CREATE INDEX idx_xref_weight ON cross_references(weight);
CREATE INDEX idx_xref_curated ON cross_references(is_curated) 
WHERE is_curated = true;
```

### 8.2 Queries

```sql
-- Get all related terms for a term
SELECT t.*, xr.weight, xr.relationship_type, xr.context
FROM cross_references xr
JOIN terms t ON xr.target_term_id = t.id
WHERE xr.source_term_id = 'TERM-000007'
AND xr.relationship_type IN ('related', 'see_also')
ORDER BY xr.weight DESC;

-- Get learning path (recommended next terms)
SELECT t.*, xr.weight
FROM cross_references xr
JOIN terms t ON xr.target_term_id = t.id
WHERE xr.source_term_id = 'TERM-000007'
AND xr.relationship_type = 'recommended_next'
ORDER BY xr.weight DESC;

-- Get prerequisites (recommended previous terms)
SELECT t.*, xr.weight
FROM cross_references xr
JOIN terms t ON xr.source_term_id = t.id
WHERE xr.target_term_id = 'TERM-000009'
AND xr.relationship_type = 'recommended_next'
ORDER BY xr.weight DESC;

-- Get bidirectional relationships (both directions)
SELECT 
    CASE 
        WHEN xr.source_term_id = 'TERM-000007' THEN xr.target_term_id
        ELSE xr.source_term_id
    END AS related_term_id,
    xr.relationship_type,
    xr.weight
FROM cross_references xr
WHERE (xr.source_term_id = 'TERM-000007' OR xr.target_term_id = 'TERM-000007')
AND xr.relationship_direction = 'bidirectional';
```

---

## 9. Example Cross References

### 9.1 Shot Technique Relationships

```json
{
  "cross_references": [
    {
      "id": "XREF-000001",
      "source_term_id": "TERM-000007",
      "target_term_id": "TERM-000008",
      "relationship_type": "related",
      "relationship_direction": "bidirectional",
      "weight": 0.95,
      "context": {
        "en": "Basic control shots that are foundational",
        "vi": "Các đường cơ bản tạo nền tảng"
      },
      "is_curated": true,
      "is_auto_generated": false,
      "confidence_score": 1.0
    },
    {
      "id": "XREF-000002",
      "source_term_id": "TERM-000008",
      "target_term_id": "TERM-000009",
      "relationship_type": "recommended_next",
      "relationship_direction": "unidirectional",
      "weight": 0.90,
      "context": {
        "en": "Follow shot mastery enables draw shot learning",
        "vi": "Thành thạo follow shot là tiền đề học draw shot"
      },
      "is_curated": true,
      "is_auto_generated": false,
      "confidence_score": 1.0
    },
    {
      "id": "XREF-000003",
      "source_term_id": "TERM-000017",
      "target_term_id": "TERM-000019",
      "relationship_type": "see_also",
      "relationship_direction": "bidirectional",
      "weight": 0.85,
      "context": {
        "en": "Both techniques utilize cushion rebounds",
        "vi": "Cả hai kỹ thuật đều sử dụng băng"
      },
      "is_curated": true,
      "is_auto_generated": false,
      "confidence_score": 1.0
    }
  ]
}
```

### 9.2 Equipment Relationships

```json
{
  "cross_references": [
    {
      "id": "XREF-000010",
      "source_term_id": "TERM-000026",
      "target_term_id": "TERM-000032",
      "relationship_type": "related",
      "relationship_direction": "bidirectional",
      "weight": 0.90,
      "context": {
        "en": "Cue and tip are inseparable equipment",
        "vi": "Cơ và đầu cơ là thiết bị không thể tách rời"
      },
      "is_curated": true,
      "is_auto_generated": false,
      "confidence_score": 1.0
    },
    {
      "id": "XREF-000011",
      "source_term_id": "TERM-000026",
      "target_term_id": "TERM-000030",
      "relationship_type": "related",
      "relationship_direction": "bidirectional",
      "weight": 0.70,
      "context": {
        "en": "Jump cue is a specialized variant",
        "vi": "Cơ nhảy là biến thể chuyên dụng"
      },
      "is_curated": true,
      "is_auto_generated": false,
      "confidence_score": 1.0
    }
  ]
}
```

### 9.3 Concept Relationships

```json
{
  "cross_references": [
    {
      "id": "XREF-000020",
      "source_term_id": "TERM-000020",
      "target_term_id": "TERM-000021",
      "relationship_type": "see_also",
      "relationship_direction": "bidirectional",
      "weight": 0.80,
      "context": {
        "en": "Safety play often results in snookers",
        "vi": "Đánh an toàn thường dẫn đến kẹt bóng"
      },
      "is_curated": true,
      "is_auto_generated": false,
      "confidence_score": 1.0
    },
    {
      "id": "XREF-000021",
      "source_term_id": "TERM-000021",
      "target_term_id": "TERM-000022",
      "relationship_type": "see_also",
      "relationship_direction": "bidirectional",
      "weight": 0.75,
      "context": {
        "en": "Snookered position often leads to fouls",
        "vi": "Vị trí kẹt thường dẫn đến lỗi"
      },
      "is_curated": true,
      "is_auto_generated": false,
      "confidence_score": 1.0
    }
  ]
}
```

---

## 10. UI Display

### 10.1 Term Card Display

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              TERM CARD                                       │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────┐
    │  Draw Shot                                    [Learn] [Practice]     │
    │  Đường Cắt Đít                                                     │
    │  ───────────────────────────────────────────────────────────────    │
    │                                                                      │
    │  Prerequisite:                                                     │
    │  ← Stop Shot (0.9)    Follow Shot (0.85)                           │
    │                                                                      │
    │  Related:                                                           │
    │  ↔ Screw Shot (0.95)    ↔ Pull Shot (0.90)                         │
    │                                                                      │
    │  Next Steps:                                                       │
    │  → Power Draw (0.85)    → Massé (0.70)                            │
    │                                                                      │
    │  See Also:                                                         │
    │  ↔ Deflection (0.80)    ↔ Spin Transfer (0.75)                     │
    └─────────────────────────────────────────────────────────────────────┘

    Legend:
    ← Recommended Previous
    → Recommended Next
    ↔ Related / See Also
    (0.x) = Weight score
```

### 10.2 Learning Path Display

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SHOT TECHNIQUE PATH                                   │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │  Level 1          Level 2          Level 3          Level 4         │
    │  ───────         ───────         ───────         ───────          │
    │                                                                      │
    │  ┌──────────┐                                                        │
    │  │ Stop Shot │◄───prerequisite───►┌──────────┐                       │
    │  └──────────┘                    │Follow Shot│◄──prerequisite──►┌──┤
    │       │                          └──────────┘                   │  │
    │       │                               │                          │  │
    │       │                               ▼                          │  │
    │       │                          ┌──────────┐                     │  │
    │       └─────────────────────────►│ Draw Shot│─────────────────────┘  │
    │                                  └──────────┘                       │
    │                                       │                              │
    │                                       ▼                              │
    │                                  ┌──────────┐                        │
    │                                  │  English │                        │
    │                                  └──────────┘                        │
    │                                       │                              │
    │                                       ▼                              │
    │                                  ┌──────────┐                        │
    │                                  │  Massé   │                        │
    │                                  └──────────┘                        │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘
```

---

## 11. Auto-Generation Rules

### 11.1 Generation Criteria

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        AUTO-GENERATION RULES                                  │
└─────────────────────────────────────────────────────────────────────────────┘

    Auto-generate "related" when:
    • Same primary category (weight: 0.6)
    • Same secondary category (weight: 0.8)
    • Shared parent category (weight: 0.5)
    
    Auto-generate "see_also" when:
    • Terms frequently appear together in content (weight: based on co-occurrence)
    • Cross-category but semantic similarity detected
    
    Auto-generate "recommended_next" when:
    • Secondary category progression detected
    • Complexity increase pattern observed
    
    Do NOT auto-generate:
    • Prerequisite relationships (always curate)
    • Antonym relationships (curation required)
    • Parent/child hierarchy (use category tree)
```

---

## 12. Related Documents

- [Term Schema](./term_schema.md)
- [Alias System](./alias_schema.md)
- [Category Tree](./category_tree.md)
- [Search System](./05_Search_System.md)

---

## 13. Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-07-17 | Initial cross-reference system |

---

**Standard Owner:** Content Team
**Next Review:** Q4 2026
