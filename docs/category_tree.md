# BKM - Category Tree Structure

## Version 1.0
**Last Updated:** July 2026
**Status:** Production Standard

---

## 1. Overview

The BKM Knowledge Graph uses a hierarchical category tree to organize terms. Categories provide logical groupings that help users navigate and discover related concepts.

---

## 2. Category Tree

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         BKM CATEGORY TREE                                  │
└─────────────────────────────────────────────────────────────────────────────┘

    BKM (Root)
    │
    ├── fundamentals
    │   ├── equipment
    │   │   ├── cue-types
    │   │   ├── chalk
    │   │   ├── table-setup
    │   │   └── accessories
    │   ├── stance
    │   │   ├── bridge
    │   │   └── grip
    │   ├── aiming
    │   │   ├── contact-points
    │   │   └── aiming-systems
    │   └── terminology
    │
    ├── pool-shots
    │   ├── basic-shots
    │   │   ├── stop-shot
    │   │   ├── follow-shot
    │   │   └── draw-shot
    │   ├── spin-shots
    │   │   ├── english
    │   │   ├── massé
    │   │   └── jump-shots
    │   ├── cut-shots
    │   │   ├── straight-cut
    │   │   ├── thin-cut
    │   │   └── bank-shots
    │   └── advanced-shots
    │       ├── masse
    │       ├── jump
    │       └── carom
    │
    ├── safety-play
    │   ├── defensive-shots
    │   ├── snookers
    │   └── fouls
    │
    ├── competition
    │   ├── tournament-rules
    │   ├── match-play
    │   └── handicaps
    │
    ├── training
    │   ├── drills
    │   │   ├── beginner-drills
    │   │   ├── intermediate-drills
    │   │   └── advanced-drills
    │   ├── practice-routines
    │   └── mental-game
    │
    ├── disciplines
    │   ├── eight-ball
    │   ├── nine-ball
    │   ├── straight-pool
    │   ├── three-cushion
    │   └── carom
    │
    └── troubleshooting
        ├── common-errors
        └── corrections
```

---

## 3. Category Format

### 3.1 JSON Structure

```json
{
  "id": "CAT-000001",
  "slug": "fundamentals",
  "names": {
    "en": "Fundamentals",
    "vi": "Nền tảng cơ bản"
  },
  "description": {
    "en": "Core concepts every player must master",
    "vi": "Các khái niệm cốt lõi mà mọi người chơi phải thành thạo"
  },
  "parent_id": null,
  "parent_path": [],
  "level": 0,
  "sort_order": 1,
  "icon": "book",
  "color": "#4A90D9",
  "is_active": true
}
```

### 3.2 Category Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | ID | Yes | Unique category identifier (CAT-NNNNNN) |
| `slug` | string | Yes | URL-safe name (kebab-case) |
| `names` | JSONB | Yes | Multilingual names |
| `description` | JSONB | No | Category description |
| `parent_id` | ID | No | Parent category ID (null for root) |
| `parent_path` | string[] | No | Array of ancestor slugs |
| `level` | integer | Yes | Tree depth (0 = root) |
| `sort_order` | integer | Yes | Display order within parent |
| `icon` | string | No | Icon identifier |
| `color` | string | No | Hex color code |
| `is_active` | boolean | Yes | Visibility flag |

---

## 4. Category Relationships

### 4.1 Hierarchy Rules

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           HIERARCHY RULES                                   │
└─────────────────────────────────────────────────────────────────────────────┘

    • Maximum depth: 4 levels (0-3)
    • Root level (0): 1 category (BKM root)
    • Level 1: Max 10 primary categories
    • Level 2: Max 50 secondary categories
    • Level 3: Max 200 tertiary categories
    
    Validation:
    ✓ Level 0 has parent_id = null
    ✓ Level 1 has parent_id pointing to Level 0
    ✓ Level 2 has parent_id pointing to Level 1
    ✓ Level 3 has parent_id pointing to Level 2
    ✓ parent_path matches actual hierarchy
```

### 4.2 Parent Path Example

```
Category: mas-se (masse shot)
├─ level 0: []                           → parent_path = []
├─ level 1: ["pool-shots"]              → parent_path = ["pool-shots"]
├─ level 2: ["pool-shots", "advanced-shots"]  → parent_path = ["pool-shots", "advanced-shots"]
└─ level 3: ["pool-shots", "advanced-shots", "masse"] → parent_path = ["pool-shots", "advanced-shots", "masse"]
```

---

## 5. Root Category

```json
{
  "id": "CAT-000000",
  "slug": "bkm",
  "names": {
    "en": "BKM",
    "vi": "BKM"
  },
  "description": {
    "en": "Billiard Knowledge Map - Complete billiards encyclopedia",
    "vi": "Bản đồ tri thức Bi-a - Từ điển bi-a hoàn chỉnh"
  },
  "parent_id": null,
  "parent_path": [],
  "level": 0,
  "sort_order": 0,
  "icon": "billiard-table",
  "color": "#2E7D32",
  "is_active": true
}
```

---

## 6. Level 1 Categories

### 6.1 Fundamentals

```json
{
  "id": "CAT-000001",
  "slug": "fundamentals",
  "names": {
    "en": "Fundamentals",
    "vi": "Nền tảng cơ bản"
  },
  "description": {
    "en": "Essential knowledge and basic techniques every player needs",
    "vi": "Kiến thức cơ bản và kỹ thuật nền tảng mọi người chơi cần có"
  },
  "parent_id": "CAT-000000",
  "parent_path": ["bkm"],
  "level": 1,
  "sort_order": 1,
  "icon": "school",
  "color": "#4CAF50"
}
```

### 6.2 Pool Shots

```json
{
  "id": "CAT-000010",
  "slug": "pool-shots",
  "names": {
    "en": "Pool Shots",
    "vi": "Các đường đánh Pool"
  },
  "description": {
    "en": "All types of shots in pool billiards",
    "vi": "Tất cả các loại đường đánh trong bi-a pool"
  },
  "parent_id": "CAT-000000",
  "parent_path": ["bkm"],
  "level": 1,
  "sort_order": 10,
  "icon": "sports-cricket",
  "color": "#2196F3"
}
```

### 6.3 Safety Play

```json
{
  "id": "CAT-000030",
  "slug": "safety-play",
  "names": {
    "en": "Safety Play",
    "vi": "Đánh an toàn"
  },
  "description": {
    "en": "Defensive strategies and safety techniques",
    "vi": "Chiến lược phòng thủ và kỹ thuật đánh an toàn"
  },
  "parent_id": "CAT-000000",
  "parent_path": ["bkm"],
  "level": 1,
  "sort_order": 30,
  "icon": "shield",
  "color": "#FF9800"
}
```

### 6.4 Competition

```json
{
  "id": "CAT-000040",
  "slug": "competition",
  "names": {
    "en": "Competition",
    "vi": "Thi đấu"
  },
  "description": {
    "en": "Tournament rules, match play, and competitive strategies",
    "vi": "Luật thi đấu, cách chơi đối kháng và chiến lược cạnh tranh"
  },
  "parent_id": "CAT-000000",
  "parent_path": ["bkm"],
  "level": 1,
  "sort_order": 40,
  "icon": "emoji-events",
  "color": "#9C27B0"
}
```

### 6.5 Training

```json
{
  "id": "CAT-000050",
  "slug": "training",
  "names": {
    "en": "Training",
    "vi": "Huấn luyện"
  },
  "description": {
    "en": "Drills, practice routines, and skill development",
    "vi": "Bài tập, thói quen luyện tập và phát triển kỹ năng"
  },
  "parent_id": "CAT-000000",
  "parent_path": ["bkm"],
  "level": 1,
  "sort_order": 50,
  "icon": "fitness-center",
  "color": "#E91E63"
}
```

### 6.6 Disciplines

```json
{
  "id": "CAT-000060",
  "slug": "disciplines",
  "names": {
    "en": "Disciplines",
    "vi": "Các thể loại"
  },
  "description": {
    "en": "Different billiard game types and their specific rules",
    "vi": "Các loại trò chơi bi-a khác nhau và luật riêng của từng loại"
  },
  "parent_id": "CAT-000000",
  "parent_path": ["bkm"],
  "level": 1,
  "sort_order": 60,
  "icon": "category",
  "color": "#00BCD4"
}
```

### 6.7 Troubleshooting

```json
{
  "id": "CAT-000070",
  "slug": "troubleshooting",
  "names": {
    "en": "Troubleshooting",
    "vi": "Khắc phục sự cố"
  },
  "description": {
    "en": "Common problems and their solutions",
    "vi": "Các vấn đề thường gặp và cách giải quyết"
  },
  "parent_id": "CAT-000000",
  "parent_path": ["bkm"],
  "level": 1,
  "sort_order": 70,
  "icon": "build",
  "color": "#795548"
}
```

---

## 7. Database Schema

### 7.1 PostgreSQL

```sql
CREATE TABLE categories (
    id              VARCHAR(20) PRIMARY KEY,
    slug            VARCHAR(100) NOT NULL UNIQUE,
    names           JSONB NOT NULL,
    description     JSONB,
    
    -- Hierarchy
    parent_id       VARCHAR(20) REFERENCES categories(id),
    parent_path     TEXT[] DEFAULT '{}',
    level           SMALLINT NOT NULL DEFAULT 0,
    sort_order      SMALLINT NOT NULL DEFAULT 0,
    
    -- Display
    icon            VARCHAR(50),
    color           VARCHAR(7),
    
    -- Status
    is_active       BOOLEAN NOT NULL DEFAULT true,
    
    -- Timestamps
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT valid_level CHECK (level >= 0 AND level <= 3),
    CONSTRAINT valid_slug CHECK (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$')
);

CREATE INDEX idx_categories_parent ON categories(parent_id);
CREATE INDEX idx_categories_level ON categories(level);
CREATE INDEX idx_categories_slug ON categories(slug);
CREATE INDEX idx_categories_path ON categories USING GIN(parent_path);
```

### 7.2 SQLite

```sql
CREATE TABLE categories (
    id              TEXT PRIMARY KEY,
    slug            TEXT NOT NULL UNIQUE,
    names           TEXT NOT NULL,
    description     TEXT,
    parent_id       TEXT,
    parent_path     TEXT,
    level           INTEGER NOT NULL DEFAULT 0,
    sort_order      INTEGER NOT NULL DEFAULT 0,
    icon            TEXT,
    color           TEXT,
    is_active       INTEGER NOT NULL DEFAULT 1,
    created_at      TEXT NOT NULL,
    updated_at      TEXT NOT NULL
);
```

---

## 8. Related Documents

- [ID Standard](./id_standard.md)
- [Term Schema](./term_schema.md)
- [Category Seed Data](./category_seed.json)

---

## 9. Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-07-17 | Initial category tree structure |

---

**Standard Owner:** Architecture Team
