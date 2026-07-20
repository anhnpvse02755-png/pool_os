# BKM - Term Model Schema

## Version 1.0
**Last Updated:** July 2026
**Status:** Production Specification

---

## 1. Overview

The Term is the central knowledge entity in the BKM Knowledge Graph. Each Term represents a distinct billiard concept that can be connected to other Terms through Edges.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              TERM MODEL                                     │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────────────┐  │
│   │                           TERM ENTITY                                  │  │
│   │                                                                       │  │
│   │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                 │  │
│   │  │ IDENTIFIER  │  │   CONTENT   │  │ METADATA    │                 │  │
│   │  │             │  │             │  │             │                 │  │
│   │  │ • id        │  │ • names     │  │ • difficulty│                 │  │
│   │  │ • slug      │  │ • definition│  │ • status   │                 │  │
│   │  │ • created   │  │ • examples  │  │ • tags     │                 │  │
│   │  │ • updated   │  │ • notes     │  │ • category │                 │  │
│   │  └─────────────┘  └─────────────┘  └─────────────┘                 │  │
│   │                                                                       │  │
│   └─────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Field Definitions

### 2.1 Identifier Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | UUID | Yes | Unique stable identifier |
| `slug` | string | Yes | URL-safe identifier (kebab-case) |
| `created_at` | timestamp | Yes | Creation timestamp (ISO-8601) |
| `updated_at` | timestamp | Yes | Last modification timestamp (ISO-8601) |

### 2.2 Content Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `names` | JSONB | Yes | Multilingual names |
| `pronunciation` | JSONB | No | Phonetic pronunciations |
| `definition_short` | JSONB | Yes | Brief definition (50-150 chars) |
| `definition_full` | JSONB | Yes | Complete detailed definition |
| `aliases` | string[] | No | Alternative names |
| `notes` | JSONB | No | Additional notes and context |

### 2.3 Classification Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `category_id` | UUID | Yes | Primary category reference |
| `difficulty` | enum | Yes | Skill level (beginner/intermediate/advanced/professional) |
| `status` | enum | Yes | Content status (draft/review/published/deprecated) |

---

## 3. Field Specifications

### 3.1 id (UUID)

```
Type: UUID v4
Required: Yes
Immutable: Yes
Description: Globally unique identifier for the term
Example: "550e8400-e29b-41d4-a716-446655440001"
```

**Rules:**
- Generated on creation
- Never changes
- Used as primary key in all references

### 3.2 slug (string)

```
Type: string (255 max)
Required: Yes
Unique: Per language
Pattern: kebab-case (lowercase, hyphens only)
Description: URL-friendly identifier
Example: "draw-shot", "backspin", "open-bridge"
```

**Rules:**
- Lowercase only
- Hyphens for spaces: `draw-shot`
- No special characters
- Unique within same language
- Can include numbers: `8-ball`
- Maximum 255 characters

### 3.3 names (JSONB)

```json
{
  "en": "English Name",
  "vi": "Tên Tiếng Việt"
}
```

**Rules:**
- Must have at least `en` (English)
- All supported languages as keys
- Maximum 500 characters per value
- Future: `ja`, `ko`, `zh`

### 3.4 pronunciation (JSONB)

```json
{
  "en": "/drɔː ʃɒt/",
  "vi": "/úp bóng/"
}
```

**Rules:**
- Optional for all languages
- IPA phonetic notation for English
- Vietnamese phonetic notation for Vietnamese
- Maximum 255 characters per value

### 3.5 definition_short (JSONB)

```json
{
  "en": "A shot using backspin to bring the cue ball back after contact",
  "vi": "Đòn đánh tạo lực ngược khiến bóng cơ quay về sau khi chạm"
}
```

**Rules:**
- Required for English
- 50-150 characters per language
- Concise summary
- No markdown formatting

### 3.6 definition_full (JSONB)

```json
{
  "en": "A draw shot (also called a 'screw shot' or 'pull shot') is executed by striking the cue ball below center with a forward-follow-through motion. The backspin causes the cue ball to reverse direction after contacting the object ball, returning toward the player. This technique is essential for position play and is typically learned after mastering the stop shot.",
  "vi": "Đường cắt đít (còn gọi là screw shot hoặc pull shot) được thực hiện bằng cách đánh vào phần dưới tâm bóng cơ với chuyển động đẩy về phía trước. Lực ngược khiến bóng cơ quay ngược lại sau khi chạm bóng mục tiêu, trở về phía người đánh. Kỹ thuật này rất cần thiết cho việc kiểm soát vị trí và thường được học sau khi thành thạo đường dừng."
}
```

**Rules:**
- Required for English
- 500-2000 characters per language
- Full explanation with context
- Supports markdown formatting
- Includes examples and applications

### 3.7 aliases (string[])

```json
{
  "en": ["screw-shot", "pull-shot", "backspin-shot"],
  "vi": ["cắt đít", "lộn đít"]
}
```

**Rules:**
- Alternative names in each language
- Not unique identifiers
- Used for search and disambiguation
- Maximum 20 aliases per language

### 3.8 category_id (UUID)

```
Type: UUID
Required: Yes
Reference: categories.id
Description: Primary category assignment
Example: "cat-00000021-0000-0000-0000-000000000021"
```

**Rules:**
- Must reference existing category
- Defines primary classification
- Can have secondary categories via junction table

### 3.9 difficulty (enum)

```
Type: enum
Required: Yes
Values: beginner | intermediate | advanced | professional
Default: beginner (for draft)
```

| Value | Description |
|-------|-------------|
| `beginner` | Fundamental concepts, basic techniques |
| `intermediate` | Advanced fundamentals, common techniques |
| `advanced` | Complex techniques, strategic concepts |
| `professional` | Expert-level, tournament strategies |

### 3.10 status (enum)

```
Type: enum
Required: Yes
Values: draft | review | published | deprecated
Default: draft
```

| Value | Description |
|-------|-------------|
| `draft` | Work in progress, not visible |
| `review` | Under review, limited visibility |
| `published` | Live, fully visible |
| `deprecated` | Hidden, replaced by new version |

### 3.11 notes (JSONB)

```json
{
  "en": {
    "when_to_use": "Use draw shot when you need to control cue ball position behind the object ball",
    "when_not_to_use": "Avoid on very short shots where draw is ineffective",
    "common_mistakes": ["Scooping the cue up", "Not following through", "Insufficient power"],
    "professional_tips": ["Match spin to shot distance", "Use acceleration, not force", "Watch the tip contact"]
  },
  "vi": {
    "when_to_use": "Sử dụng đường cắt đít khi cần kiểm soát vị trí bóng cơ phía sau bóng mục tiêu",
    "when_not_to_use": "Tránh đường ngắn quá nơi cắt đít không hiệu quả",
    "common_mistakes": ["Múc cơ lên", "Không theo đuổi", "Lực không đủ"],
    "professional_tips": ["Điều chỉnh xoáy theo khoảng cách", "Dùng gia tốc không phải lực", "Quan sát điểm chạm đầu cơ"]
  }
}
```

### 3.12 created_at (timestamp)

```
Type: timestamp
Format: ISO-8601
Required: Yes
Immutable: Yes
Example: "2026-07-17T10:00:00Z"
```

### 3.13 updated_at (timestamp)

```
Type: timestamp
Format: ISO-8601
Required: Yes
Auto-update: On every modification
Example: "2026-07-17T15:30:00Z"
```

---

## 4. Related Entities

### 4.1 Relationships (Edges)

Terms connect to other Terms via Edges:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           TERM RELATIONSHIPS                                │
└─────────────────────────────────────────────────────────────────────────────┘

    Draw Shot
       │
       ├── USES ────────────► Backspin
       │
       ├── PREREQUISITE ────► Stop Shot
       │
       ├── LEADS_TO ────────► Power Draw
       │
       ├── OPPOSITE_OF ─────► Follow Shot
       │
       ├── TRAINED_BY ──────► Drill-013
       │
       ├── COMMON_ERROR ─────► Scooping
       │
       ├── PART_OF ─────────► Spin Techniques
       │
       └── VIDEO_EXPLAINS ──► [video-uuid]
```

### 4.2 Media Attachments

Terms can have associated media:

```
• images[] - Diagrams, photos
• videos[] - Demonstrations, tutorials
• animations[] - Stroke animations, ball paths
```

---

## 5. Database Schema

### 5.1 PostgreSQL

```sql
CREATE TABLE terms (
    -- Primary Key
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Identification
    slug            VARCHAR(255) NOT NULL,
    
    -- Content
    names           JSONB NOT NULL,
    pronunciation   JSONB,
    definition_short JSONB NOT NULL,
    definition_full  JSONB NOT NULL,
    aliases         JSONB DEFAULT '{}',
    notes           JSONB,
    
    -- Classification
    category_id     UUID NOT NULL REFERENCES categories(id),
    difficulty      VARCHAR(20) NOT NULL DEFAULT 'beginner',
    status          VARCHAR(20) NOT NULL DEFAULT 'draft',
    
    -- Timestamps
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT unique_slug UNIQUE (slug),
    CONSTRAINT valid_difficulty CHECK (difficulty IN ('beginner', 'intermediate', 'advanced', 'professional')),
    CONSTRAINT valid_status CHECK (status IN ('draft', 'review', 'published', 'deprecated'))
);

CREATE INDEX idx_terms_slug ON terms(slug);
CREATE INDEX idx_terms_category ON terms(category_id);
CREATE INDEX idx_terms_difficulty ON terms(difficulty);
CREATE INDEX idx_terms_status ON terms(status);
```

### 5.2 SQLite

```sql
CREATE TABLE terms (
    id              TEXT PRIMARY KEY,
    slug            TEXT NOT NULL UNIQUE,
    names           TEXT NOT NULL,        -- JSON string
    pronunciation   TEXT,
    definition_short TEXT NOT NULL,       -- JSON string
    definition_full  TEXT NOT NULL,      -- JSON string
    aliases         TEXT DEFAULT '{}',    -- JSON string
    notes           TEXT,
    category_id     TEXT NOT NULL,
    difficulty      TEXT NOT NULL DEFAULT 'beginner',
    status          TEXT NOT NULL DEFAULT 'draft',
    created_at      TEXT NOT NULL,
    updated_at      TEXT NOT NULL
);
```

---

## 6. API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/v1/terms` | List terms (paginated) |
| GET | `/v1/terms/{slug}` | Get term by slug |
| POST | `/v1/terms` | Create term |
| PUT | `/v1/terms/{slug}` | Update term |
| DELETE | `/v1/terms/{slug}` | Delete term |
| GET | `/v1/terms/{slug}/relationships` | Get term relationships |
| GET | `/v1/terms/{slug}/media` | Get term media |

---

## 7. Related Documents

- [BKM Database Schema](./03_Database.md)
- [BKM Relationship System](./14_Relationship_System.md)
- [BKM Category System](./category_tree.md)
- [BKM JSON Spec](./04_JSON_Spec.md)
- [BKM API Design](./15_API_Design_For_PoolOS.md)

---

**End of Document**
