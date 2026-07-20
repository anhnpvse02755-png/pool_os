# BKM - Tag Schema

## Version 1.0
**Last Updated:** July 2026
**Status:** Production Standard

---

## 1. Overview

Tags provide additional categorization and searchability for terms.

---

## 2. Tag Schema

```json
{
  "id": "TAG-000001",
  "slug": "beginner",
  "names": {
    "en": "Beginner",
    "vi": "Người mới"
  },
  "description": {
    "en": "Suitable for beginners",
    "vi": "Phù hợp cho người mới"
  },
  "color": "#4CAF50",
  "icon": "star",
  "sort_order": 1,
  "is_active": true,
  "created_at": "2026-07-17T00:00:00Z"
}
```

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | ID | Yes | TAG-NNNNNN |
| `slug` | string | Yes | URL-safe identifier |
| `names` | JSONB | Yes | Multilingual names |
| `description` | JSONB | No | Tag description |
| `color` | string | No | Hex color code |
| `icon` | string | No | Icon identifier |
| `sort_order` | integer | No | Display order |
| `is_active` | boolean | Yes | Visibility |
| `created_at` | timestamp | Yes | Creation time |

---

## 3. Predefined Tags

```json
[
  { "slug": "beginner", "names": {"en": "Beginner", "vi": "Người mới"}, "color": "#4CAF50" },
  { "slug": "intermediate", "names": {"en": "Intermediate", "vi": "Trung cấp"}, "color": "#2196F3" },
  { "slug": "advanced", "names": {"en": "Advanced", "vi": "Nâng cao"}, "color": "#9C27B0" },
  { "slug": "professional", "names": {"en": "Professional", "vi": "Chuyên nghiệp"}, "color": "#FF9800" },
  { "slug": "pool", "names": {"en": "Pool", "vi": "Pool"}, "color": "#00BCD4" },
  { "slug": "snooker", "names": {"en": "Snooker", "vi": "Snooker"}, "color": "#795548" },
  { "slug": "carom", "names": {"en": "Carom", "vi": "Carom"}, "color": "#607D8B" },
  { "slug": "drill", "names": {"en": "Drill", "vi": "Bài tập"}, "color": "#E91E63" },
  { "slug": "technique", "names": {"en": "Technique", "vi": "Kỹ thuật"}, "color": "#3F51B5" },
  { "slug": "strategy", "names": {"en": "Strategy", "vi": "Chiến lược"}, "color": "#009688" },
  { "slug": "equipment", "names": {"en": "Equipment", "vi": "Dụng cụ"}, "color": "#CDDC39" },
  { "slug": "rules", "names": {"en": "Rules", "vi": "Luật"}, "color": "#F44336" }
]
```

---

## 4. Database Schema

### PostgreSQL

```sql
CREATE TABLE tags (
    id              VARCHAR(20) PRIMARY KEY,
    slug            VARCHAR(50) NOT NULL UNIQUE,
    names           JSONB NOT NULL,
    description     JSONB,
    color           VARCHAR(7),
    icon            VARCHAR(50),
    sort_order      INTEGER DEFAULT 0,
    is_active       BOOLEAN NOT NULL DEFAULT true,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE term_tags (
    term_id         VARCHAR(20) NOT NULL REFERENCES terms(id),
    tag_id          VARCHAR(20) NOT NULL REFERENCES tags(id),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (term_id, tag_id)
);

CREATE INDEX idx_term_tags_term ON term_tags(term_id);
CREATE INDEX idx_term_tags_tag ON term_tags(tag_id);
```

---

## 5. Related Documents

- [ID Standard](./id_standard.md)
- [Naming Convention](./naming.md)

---

**End of Document**
