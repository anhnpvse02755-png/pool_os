# BKM - Relationship System

## Version 1.0
**Last Updated:** July 2026
**Status:** Production Standard

---

## 1. Overview

Relationships connect terms into a knowledge graph, enabling navigation, discovery, and contextual learning.

---

## 2. Relationship Types

| Type | Symbol | Description | Example |
|------|--------|-------------|---------|
| `prerequisite` | `→` | Must learn before | Stop Shot → Draw Shot |
| `leads_to` | `↗` | Advanced progression | Draw Shot → Power Draw |
| `synonym` | `≡` | Same concept | Screw Shot ≡ Draw Shot |
| `opposite` | `⇏` | Contrast relation | Follow Shot ⇏ Draw Shot |
| `part_of` | `⊂` | Component of system | English ⊂ Spin Techniques |
| `uses` | `⟹` | Uses/requires | Draw Shot ⟹ Backspin |
| `trained_by` | `◆` | Practice drill | Draw Shot ◆ Drill-001 |
| `opposite_of` | `⇔` | Bidirectional contrast | Follow Shot ⇔ Draw Shot |

---

## 3. Relationship Schema

```json
{
  "id": "REL-000001",
  "source_id": "TERM-000001",
  "target_id": "TERM-000002",
  "relationship_type": "prerequisite",
  "weight": 1.0,
  "notes": {
    "en": "Stop shot fundamentals required",
    "vi": "Nền tảng đường dừng bắt buộc"
  },
  "is_bidirectional": false,
  "created_at": "2026-07-17T00:00:00Z"
}
```

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | ID | Yes | REL-NNNNNN |
| `source_id` | ID | Yes | Origin term |
| `target_id` | ID | Yes | Target term |
| `relationship_type` | enum | Yes | One of above types |
| `weight` | float | No | 0.0-1.0 relevance |
| `notes` | JSONB | No | Additional context |
| `is_bidirectional` | boolean | No | Auto-create reverse |
| `created_at` | timestamp | Yes | Creation time |

---

## 4. Database Schema

### PostgreSQL

```sql
CREATE TABLE relationships (
    id                  VARCHAR(20) PRIMARY KEY,
    source_id           VARCHAR(20) NOT NULL REFERENCES terms(id),
    target_id          VARCHAR(20) NOT NULL REFERENCES terms(id),
    relationship_type   VARCHAR(30) NOT NULL,
    weight              DECIMAL(3,2) DEFAULT 1.0,
    notes               JSONB,
    is_bidirectional    BOOLEAN DEFAULT false,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT unique_relationship UNIQUE (source_id, target_id, relationship_type),
    CONSTRAINT valid_weight CHECK (weight >= 0 AND weight <= 1)
);

CREATE INDEX idx_relationships_source ON relationships(source_id);
CREATE INDEX idx_relationships_target ON relationships(target_id);
CREATE INDEX idx_relationships_type ON relationships(relationship_type);
```

---

## 5. Related Documents

- [ID Standard](./id_standard.md)
- [Term Schema](./term_schema.md)

---

**End of Document**
