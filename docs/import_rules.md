# BKM - Term Import Rules

## Version 1.0
**Last Updated:** July 2026
**Status:** Production Standard

---

## 1. Overview

This document defines import rules and validation procedures for bulk importing terms into the BKM Knowledge Graph. Supports multiple file formats with comprehensive error detection and reporting.

---

## 2. Supported Formats

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SUPPORTED IMPORT FORMATS                             │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Format        │ Extension   │ Description                          │
    │   ─────────────┼────────────┼─────────────────────────────────────── │
    │   JSON          │   .json    │ BKM native format                    │
    │   CSV           │   .csv     │ Spreadsheet-compatible               │
    │   Markdown      │   .md      │ Human-readable format                │
    │   SQLite        │   .db/.sqlite│ Database file import               │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘
```

---

## 3. Import Pipeline

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            IMPORT PIPELINE                                    │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │    ┌───────────┐    ┌───────────┐    ┌───────────┐    ┌──────────┐  │
    │    │   FILE   │───►│  PARSE   │───►│ VALIDATE │───►│ TRANSFORM│  │
    │    │ RECEIVED │    │         │    │         │    │         │  │
    │    └───────────┘    └───────────┘    └───────────┘    └──────────┘  │
    │                           │               │                │          │
    │                           ▼               ▼                ▼          │
    │                      ┌───────────┐   ┌───────────┐   ┌──────────┐  │
    │                      │   RAW    │   │  CHECK   │   │  TERM    │  │
    │                      │  TERMS   │   │ DUPLICATES│  │  OBJECTS │  │
    │                      └───────────┘   └───────────┘   └──────────┘  │
    │                                         │                │          │
    │                                         ▼                ▼          │
    │                                  ┌───────────┐   ┌──────────┐  │
    │                                  │  REPORT   │   │ RELATION │  │
    │                                  │  ERRORS   │   │  CHECK   │  │
    │                                  └───────────┘   └──────────┘  │
    │                                                         │       │
    │                                                         ▼       │
    │                                                   ┌──────────┐  │
    │                                                   │  IMPORT  │  │
    │                                                   │ OPTIONS │  │
    │                                                   └──────────┘  │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘

    Stage 1: Parse
    ─────────────────────────────────────────────────────────────────────
    • Detect file format
    • Parse into intermediate representation
    • Handle encoding issues
    
    Stage 2: Validate
    ─────────────────────────────────────────────────────────────────────
    • Check required fields
    • Validate data types
    • Verify format compliance
    
    Stage 3: Transform
    ─────────────────────────────────────────────────────────────────────
    • Convert to internal term format
    • Normalize values
    • Handle defaults
    
    Stage 4: Relation Check
    ─────────────────────────────────────────────────────────────────────
    • Verify category references
    • Check tag validity
    • Validate cross-references
```

---

## 4. Format Specifications

### 4.1 JSON Format

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           JSON FORMAT                                        │
└─────────────────────────────────────────────────────────────────────────────┘

    Single Term:
    ─────────────────────────────────────────────────────────────────────────
    {
      "id": "TERM-000001",
      "slug": "draw-shot",
      "names": {
        "en": "Draw Shot",
        "vi": "Đường Cắt Đít"
      },
      "definition_short": {
        "en": "A shot using backspin to bring the cue ball back",
        "vi": "Đòn đánh tạo lực ngược khiến bóng cơ quay về"
      },
      "definition_full": {
        "en": "A draw shot (also called screw shot) is executed...",
        "vi": "Đường cắt đít (còn gọi là screw shot) được thực hiện..."
      },
      "category_id": "CAT-000020",
      "tags": ["technique", "spin", "advanced"],
      "difficulty": "intermediate",
      "status": "draft",
      "aliases": {
        "en": ["screw-shot", "pull-shot"],
        "vi": ["cắt đít", "lộn đít"]
      },
      "pronunciation": {
        "en": "/drɔː ʃɒt/"
      }
    }
    
    Batch Import (Array):
    ─────────────────────────────────────────────────────────────────────────
    {
      "version": "1.0",
      "source": "manual-export",
      "terms": [
        { ... term 1 ... },
        { ... term 2 ... },
        { ... term 3 ... }
      ]
    }
    
    Field Requirements:
    ─────────────────────────────────────────────────────────────────────────
    • id: String, TERM-NNNNNN format
    • slug: String, kebab-case
    • names: Object with en and vi required
    • definition_short: Object with en and vi required
    • definition_full: Object with en and vi required
    • category_id: String, CAT-NNNNNN format
    • tags: Array of strings (min 1)
    • difficulty: Enum (beginner|intermediate|advanced|professional)
    • status: Enum (draft|review|published|deprecated)
```

### 4.2 CSV Format

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           CSV FORMAT                                         │
└─────────────────────────────────────────────────────────────────────────────┘

    Column Mapping:
    ─────────────────────────────────────────────────────────────────────────
    id,slug,names_en,names_vi,def_short_en,def_short_vi,def_full_en,
    def_full_vi,category_id,tags,difficulty,status,aliases_en,aliases_vi
    
    Header Row (Required):
    ─────────────────────────────────────────────────────────────────────────
    id,slug,names_en,names_vi,def_short_en,def_short_vi,def_full_en,def_full_vi,category_id,tags,difficulty,status,aliases_en,aliases_vi
    
    Sample Data:
    ─────────────────────────────────────────────────────────────────────────
    id,slug,names_en,names_vi,def_short_en,def_short_vi,def_full_en,def_full_vi,category_id,tags,difficulty,status,aliases_en,aliases_vi
    TERM-000001,draw-shot,Draw Shot,Đường Cắt Đít,A shot using backspin to bring the cue ball back,Đòn đánh tạo lực ngược khiến bóng cơ quay về,A draw shot is executed by striking below center...,Đường cắt đít được thực hiện bằng cách đánh vào phần dưới tâm...,CAT-000020,"technique;spin;advanced",intermediate,draft,"screw-shot;pull-shot","cắt đít;lộn đít"
    TERM-000002,stop-shot,Stop Shot,Đường Dừng,A shot that stops the cue ball completely,Đòn đánh khiến bóng cơ dừng hoàn toàn,A stop shot is executed with a... ,Đường dừng được thực hiện với...,CAT-000020,"technique;fundamentals",beginner,draft,,
    
    Special Handling:
    ─────────────────────────────────────────────────────────────────────────
    • Tags: Separated by semicolons (;)
    • Aliases: Separated by semicolons (;)
    • Multi-line content: Use double quotes, escape internal quotes with ""
    • Empty cells: Interpreted as null/missing
    • Unicode: Full support required
```

### 4.3 Markdown Format

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          MARKDOWN FORMAT                                      │
└─────────────────────────────────────────────────────────────────────────────┘

    File Structure:
    ─────────────────────────────────────────────────────────────────────────
    Each term is a separate file, or terms are separated by H1 headings.
    
    Single Term File (recommended):
    ─────────────────────────────────────────────────────────────────────────
    # Draw Shot
    
    **ID:** TERM-000001
    **Slug:** draw-shot
    **Category:** CAT-000020
    **Difficulty:** intermediate
    **Status:** draft
    **Tags:** technique, spin, advanced
    
    ## English Name
    Draw Shot
    
    ## Vietnamese Name
    Đường Cắt Đít
    
    ## Short Definition (English)
    A shot using backspin to bring the cue ball back after contact.
    
    ## Short Definition (Vietnamese)
    Đòn đánh tạo lực ngược khiến bóng cơ quay về sau khi chạm.
    
    ## Full Definition (English)
    A draw shot (also called a screw shot or pull shot) is executed by 
    striking the cue ball below center with a forward-follow-through motion. 
    The backspin causes the cue ball to reverse direction after contacting 
    the object ball, returning toward the player.
    
    ## Full Definition (Vietnamese)
    Đường cắt đít (còn gọi là screw shot hoặc pull shot) được thực hiện 
    bằng cách đánh vào phần dưới tâm bóng cơ với chuyển động đẩy về phía 
    trước. Lực ngược khiến bóng cơ quay ngược lại sau khi chạm bóng mục tiêu.
    
    ## Aliases (English)
    - screw-shot
    - pull-shot
    - backspin-shot
    
    ## Aliases (Vietnamese)
    - cắt đít
    - lộn đít
    
    ## Notes
    ### When to Use
    Use draw shot when you need to control cue ball position behind the 
    object ball.
    
    ### Common Mistakes
    - Scooping the cue up
    - Not following through
    
    Multi-Term File (legacy support):
    ─────────────────────────────────────────────────────────────────────────
    # Term 1: Draw Shot
    
    ...term content...
    
    ---
    
    # Term 2: Stop Shot
    
    ...term content...
    
    Pattern:
    • H1 heading = term name (or "Term N: Name")
    • Horizontal rule (---) = term separator
    • Key-value pairs in bold format
    • Standard headings for structured content
```

### 4.4 SQLite Format

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          SQLITE FORMAT                                       │
└─────────────────────────────────────────────────────────────────────────────┘

    Table Schema (Required):
    ─────────────────────────────────────────────────────────────────────────
    CREATE TABLE terms (
        id              TEXT PRIMARY KEY,
        slug            TEXT NOT NULL UNIQUE,
        names           TEXT NOT NULL,        -- JSON string
        definition_short TEXT NOT NULL,        -- JSON string
        definition_full  TEXT NOT NULL,        -- JSON string
        category_id     TEXT NOT NULL,
        tags            TEXT NOT NULL,        -- JSON array string
        difficulty      TEXT NOT NULL,
        status          TEXT NOT NULL,
        aliases         TEXT,                  -- JSON string
        pronunciation   TEXT,                  -- JSON string
        notes           TEXT,                  -- JSON string
        created_at      TEXT,
        updated_at      TEXT
    );
    
    Import Options:
    ─────────────────────────────────────────────────────────────────────────
    • Full database import: Import all tables
    • Terms only: Import only the terms table
    • Merge: Import alongside existing data (conflict handling)
    
    SQLite Detection:
    ─────────────────────────────────────────────────────────────────────────
    1. Check file extension (.db, .sqlite, .sqlite3)
    2. Verify SQLite header (SQLite format 3)
    3. Check for required 'terms' table
    4. Validate table structure
```

---

## 5. Error Detection

### 5.1 Duplicate ID Detection

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          DUPLICATE ID DETECTION                              │
└─────────────────────────────────────────────────────────────────────────────┘

    Error Type: DUPLICATE_ID
    
    Detection Rules:
    ─────────────────────────────────────────────────────────────────────────
    ✓ Within import file: Check all IDs are unique
    ✓ Against existing database: Check for conflicts
    ✓ Case-sensitive matching (TERM-000001 ≠ term-000001)
    
    Within-File Example:
    ─────────────────────────────────────────────────────────────────────────
    File contains:
    ┌─────────────────────────────────────────────────────────────────────┐
    │  Row 1: TERM-000001, draw-shot, ...                                │
    │  Row 2: TERM-000002, stop-shot, ...                                │
    │  Row 3: TERM-000001, follow-shot, ...  ← DUPLICATE!                │
    └─────────────────────────────────────────────────────────────────────┘
    
    Against-Database Example:
    ─────────────────────────────────────────────────────────────────────────
    Database has: TERM-000001 (draw-shot)
    Import contains: TERM-000001 (follow-shot)  ← CONFLICT!
    
    Error Response:
    ─────────────────────────────────────────────────────────────────────────
    {
      "error": "DUPLICATE_ID",
      "code": "IMPORT_001",
      "message": "Duplicate ID found in import file",
      "details": {
        "id": "TERM-000001",
        "occurrences": [
          { "row": 1, "slug": "draw-shot" },
          { "row": 3, "slug": "follow-shot" }
        ]
      },
      "resolution": "UPDATE or SKIP"
    }
```

### 5.2 Duplicate Slug Detection

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         DUPLICATE SLUG DETECTION                             │
└─────────────────────────────────────────────────────────────────────────────┘

    Error Type: DUPLICATE_SLUG
    
    Detection Rules:
    ─────────────────────────────────────────────────────────────────────────
    ✓ Within import file: Check all slugs are unique
    ✓ Against existing database: Check for conflicts
    ✓ Normalize to lowercase before comparison
    ✓ Trim whitespace
    
    Within-File Example:
    ─────────────────────────────────────────────────────────────────────────
    File contains:
    ┌─────────────────────────────────────────────────────────────────────┐
    │  Row 1: TERM-000001, draw-shot, ...                                │
    │  Row 2: TERM-000002, stop-shot, ...                                │
    │  Row 3: TERM-000003, draw-shot, ...  ← DUPLICATE!                  │
    └─────────────────────────────────────────────────────────────────────┘
    
    Against-Database Example:
    ─────────────────────────────────────────────────────────────────────────
    Database has: draw-shot (TERM-000001)
    Import contains: draw-shot (TERM-000099)  ← CONFLICT!
    
    Error Response:
    ─────────────────────────────────────────────────────────────────────────
    {
      "error": "DUPLICATE_SLUG",
      "code": "IMPORT_002",
      "message": "Duplicate slug found in import file",
      "details": {
        "slug": "draw-shot",
        "occurrences": [
          { "row": 1, "id": "TERM-000001" },
          { "row": 3, "id": "TERM-000003" }
        ]
      },
      "resolution": "UPDATE or SKIP"
    }
```

### 5.3 Missing Field Detection

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          MISSING FIELD DETECTION                             │
└─────────────────────────────────────────────────────────────────────────────┘

    Error Type: MISSING_FIELD
    
    Required Fields:
    ─────────────────────────────────────────────────────────────────────────
    • id
    • slug
    • names.en (or names.vi)
    • definition_short.en (or definition_short.vi)
    • definition_full.en (or definition_full.vi)
    • category_id
    • tags
    
    Detection Rules:
    ─────────────────────────────────────────────────────────────────────────
    ✓ Check for null values
    ✓ Check for empty strings
    ✓ Check for missing JSON keys
    ✓ Check for missing CSV columns
    
    Error Response:
    ─────────────────────────────────────────────────────────────────────────
    {
      "error": "MISSING_FIELD",
      "code": "IMPORT_003",
      "message": "Required field is missing",
      "details": {
        "row": 5,
        "id": "TERM-000005",
        "field": "tags",
        "value": null
      },
      "resolution": "PROVIDE or SKIP"
    }
    
    Severity Levels:
    ─────────────────────────────────────────────────────────────────────────
    • CRITICAL: Blocks import (required fields missing)
    • WARNING: Allows import with default (optional fields)
```

### 5.4 Broken Relation Detection

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         BROKEN RELATION DETECTION                             │
└─────────────────────────────────────────────────────────────────────────────┘

    Error Type: BROKEN_RELATION
    
    Relation Types:
    ─────────────────────────────────────────────────────────────────────────
    • Category Reference: category_id must exist in categories table
    • Tag Reference: tags must exist in tag vocabulary
    • Cross-Reference: related terms must exist in database
    • Media Reference: media IDs must exist in media table
    
    Category Broken Relation:
    ─────────────────────────────────────────────────────────────────────────
    Term references: category_id = "CAT-999999"
    Category does not exist
    
    Error Response:
    ─────────────────────────────────────────────────────────────────────────
    {
      "error": "BROKEN_RELATION",
      "code": "IMPORT_004",
      "message": "Category reference does not exist",
      "details": {
        "row": 10,
        "id": "TERM-000010",
        "field": "category_id",
        "value": "CAT-999999",
        "reason": "Category not found in database"
      },
      "resolution": "CREATE_CATEGORY or MAP_TO_DEFAULT or SKIP"
    }
    
    Tag Broken Relation:
    ─────────────────────────────────────────────────────────────────────────
    Term references: tags = ["technique", "invalid-tag"]
    "invalid-tag" does not exist in vocabulary
    
    Error Response:
    ─────────────────────────────────────────────────────────────────────────
    {
      "error": "BROKEN_RELATION",
      "code": "IMPORT_005",
      "message": "Tag does not exist in vocabulary",
      "details": {
        "row": 15,
        "id": "TERM-000015",
        "field": "tags",
        "invalid_tags": ["invalid-tag"],
        "valid_tags": ["technique", "spin", "advanced"]
      },
      "resolution": "CREATE_TAG or REMOVE_INVALID or SKIP"
    }
    
    Cross-Reference Broken Relation:
    ─────────────────────────────────────────────────────────────────────────
    Term references: related = ["TERM-999999"]
    Referenced term does not exist
    
    Error Response:
    ─────────────────────────────────────────────────────────────────────────
    {
      "error": "BROKEN_RELATION",
      "code": "IMPORT_006",
      "message": "Related term does not exist",
      "details": {
        "row": 20,
        "id": "TERM-000020",
        "field": "related",
        "missing_ids": ["TERM-999999"]
      },
      "resolution": "CREATE_TERM or IGNORE_REFERENCE or SKIP"
    }
```

---

## 6. Validation Rules

### 6.1 ID Format Validation

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           ID FORMAT VALIDATION                                │
└─────────────────────────────────────────────────────────────────────────────┘

    Valid Pattern: TERM-NNNNNN
    ─────────────────────────────────────────────────────────────────────────
    • Must start with "TERM-"
    • Followed by exactly 6 digits
    • Zero-padded: TERM-000001 (not TERM-1)
    • Case-sensitive: uppercase only
    
    Valid Examples:
    ─────────────────────────────────────────────────────────────────────────
    • TERM-000001
    • TERM-000010
    • TERM-123456
    • TERM-999999
    
    Invalid Examples:
    ─────────────────────────────────────────────────────────────────────────
    • term-000001      ← lowercase
    • TERM-1           ← not zero-padded
    • TERM-0000001     ← 7 digits
    • TERM_000001      ← underscore
    • 000001           ← missing prefix
```

### 6.2 Slug Format Validation

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SLUG FORMAT VALIDATION                                │
└─────────────────────────────────────────────────────────────────────────────┘

    Valid Pattern: kebab-case
    ─────────────────────────────────────────────────────────────────────────
    • Lowercase letters (a-z)
    • Numbers (0-9)
    • Hyphens (-) for word separation
    • No consecutive hyphens
    • No leading/trailing hyphens
    • Maximum 255 characters
    
    Valid Examples:
    ─────────────────────────────────────────────────────────────────────────
    • draw-shot
    • stop-shot
    • follow-through
    • 8-ball
    • cue-ball-123
    
    Invalid Examples:
    ─────────────────────────────────────────────────────────────────────────
    • DrawShot          ← camelCase
    • draw_shot         ← underscore
    • Draw-Shot         ← uppercase
    • draw--shot        ← consecutive hyphens
    • -draw-shot        ← leading hyphen
    • draw-shot-        ← trailing hyphen
```

### 6.3 Name Validation

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           NAME VALIDATION                                    │
└─────────────────────────────────────────────────────────────────────────────┘

    English Name (names.en):
    ─────────────────────────────────────────────────────────────────────────
    • Required
    • Minimum 1 character
    • Maximum 500 characters
    • No empty/whitespace-only
    
    Vietnamese Name (names.vi):
    ─────────────────────────────────────────────────────────────────────────
    • Required
    • Minimum 1 character
    • Maximum 500 characters
    • Should use proper diacritics (warning if missing)
    • No empty/whitespace-only
```

### 6.4 Definition Validation

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        DEFINITION VALIDATION                                 │
└─────────────────────────────────────────────────────────────────────────────┘

    Short Definition (definition_short):
    ─────────────────────────────────────────────────────────────────────────
    • Required for EN and VI
    • EN: 50-150 characters
    • VI: 50-150 characters
    • No markdown/HTML
    
    Full Definition (definition_full):
    ─────────────────────────────────────────────────────────────────────────
    • Required for EN and VI
    • EN: 500-2000 characters
    • VI: 500-2000 characters
    • Markdown supported
    • Should include: what, how, when/where
```

### 6.5 Tag Validation

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            TAG VALIDATION                                    │
└─────────────────────────────────────────────────────────────────────────────┘

    Rules:
    ─────────────────────────────────────────────────────────────────────────
    • Minimum 1 tag required
    • Maximum 10 tags per term
    • All tags must be lowercase
    • Tags separated by semicolons (;) in CSV
    • Tags in JSON array format
    
    Valid Tags:
    ─────────────────────────────────────────────────────────────────────────
    • technique
    • fundamentals
    • beginner-friendly
    • advanced
    • must-know
    • equipment
    
    Invalid Tags:
    ─────────────────────────────────────────────────────────────────────────
    • Technique          ← uppercase
    • technique skill    ← space
    • technique,skill    ← comma
```

---

## 7. Import Options

### 7.1 Conflict Resolution

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       CONFLICT RESOLUTION OPTIONS                            │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Option          │ Behavior                                          │
    │   ────────────────┼─────────────────────────────────────────────────── │
    │   UPDATE          │ Replace existing record with imported data        │
    │   SKIP            │ Keep existing record, skip import for conflicts  │
    │   RENAME          │ Create new ID with suffix (_v2, _v3, etc.)       │
    │   MERGE           │ Merge fields (import wins for conflicts)         │
    │   ERROR           │ Stop import, report all conflicts                 │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘
    
    Default: ERROR (fail-safe)
    
    Resolution by Error Type:
    ─────────────────────────────────────────────────────────────────────────
    • DUPLICATE_ID: UPDATE | SKIP | RENAME | ERROR
    • DUPLICATE_SLUG: UPDATE | SKIP | RENAME | ERROR
    • MISSING_FIELD: PROVIDE_DEFAULT | SKIP | ERROR
    • BROKEN_RELATION: CREATE | MAP_DEFAULT | SKIP | ERROR
```

### 7.2 Import Modes

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            IMPORT MODES                                       │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                      │
    │   Mode           │ Description                                      │
    │   ───────────────┼─────────────────────────────────────────────────── │
    │   VALIDATE_ONLY  │ Parse and validate, do not import                 │
    │   DRY_RUN        │ Validate + show what would be imported            │
    │   FULL_IMPORT   │ Complete import with all validations              │
    │   PARTIAL        │ Import valid terms, report invalid                │
    │   REPLACE        │ Delete all existing, import fresh                 │
    │                                                                      │
    └─────────────────────────────────────────────────────────────────────┘
```

---

## 8. Import Report

### 8.1 Report Structure

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          IMPORT REPORT STRUCTURE                              │
└─────────────────────────────────────────────────────────────────────────────┘

    {
      "import_id": "IMP-20260717-001",
      "timestamp": "2026-07-17T12:00:00Z",
      "source": {
        "format": "json",
        "filename": "terms_batch_001.json",
        "size_bytes": 102400,
        "term_count": 150
      },
      "results": {
        "imported": 145,
        "skipped": 3,
        "updated": 2
      },
      "errors": [
        {
          "code": "DUPLICATE_ID",
          "count": 1,
          "rows": [...]
        },
        {
          "code": "MISSING_FIELD",
          "count": 1,
          "rows": [...]
        }
      ],
      "warnings": [
        {
          "code": "MISSING_DIACRITICS",
          "count": 5,
          "rows": [...]
        }
      ],
      "relations": {
        "categories_created": 0,
        "tags_created": 2
      },
      "duration_ms": 1250
    }
```

### 8.2 Error Summary

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          ERROR SUMMARY EXAMPLE                                │
└─────────────────────────────────────────────────────────────────────────────┘

    Import Report - terms_batch_001.json
    ─────────────────────────────────────────────────────────────────────────
    
    Status: PARTIAL SUCCESS
    
    Summary:
    ─────────────────────────────────────────────────────────────────────────
    Total Terms:     150
    Imported:        145  (96.7%)
    Updated:           2  (1.3%)
    Skipped:           3  (2.0%)
    
    Errors (Blocking):
    ─────────────────────────────────────────────────────────────────────────
    • DUPLICATE_ID:       1 occurrence
      └─ Row 45: TERM-000100 (conflicts with Row 12)
    
    • MISSING_FIELD:       1 occurrence
      └─ Row 78: TERM-000133 (tags array empty)
    
    • BROKEN_RELATION:    1 occurrence
      └─ Row 99: TERM-000155 (invalid category CAT-999999)
    
    Warnings (Non-Blocking):
    ─────────────────────────────────────────────────────────────────────────
    • MISSING_DIACRITICS: 5 occurrences
    • SHORT_DEFINITION:   3 occurrences (below 50 char minimum)
    • UNKNOWN_TAG:        2 occurrences (added as new tags)
```

---

## 9. API Endpoints

### 9.1 Import Endpoint

```
POST /v1/import
Content-Type: multipart/form-data

Form Fields:
─────────────────────────────────────────────────────────────────────────────
• file: Binary file data
• format: "json" | "csv" | "markdown" | "sqlite"
• mode: "validate_only" | "dry_run" | "full_import" | "partial"
• conflict_resolution: "update" | "skip" | "rename" | "merge" | "error"
• default_category: Category ID for broken category relations
• default_difficulty: "beginner" | "intermediate" | "advanced" | "professional"
• create_missing_tags: boolean
```

### 9.2 Validation Endpoint

```
POST /v1/import/validate
Content-Type: application/json

{
  "terms": [...],
  "format": "json",
  "check_duplicates": true,
  "check_relations": true
}
```

---

## 10. Related Documents

- [Term Schema](./term_schema.md)
- [Category Tree](./category_tree.md)
- [Validation Rules](./validation_rules.md)
- [Tag System](./tag_schema.md)

---

## 11. Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-07-17 | Initial import rules |

---

**Standard Owner:** Content Team
**Next Review:** Quarterly
