# BKM - ID Convention Standard

## Version 1.0
**Last Updated:** July 2026
**Status:** Production Standard

---

## 1. Overview

Every entity in the BKM Knowledge Graph receives a unique, immutable identifier at creation time. IDs follow a consistent format across all entity types to enable:

- **Uniqueness** - No two entities share an ID
- **Immutability** - IDs never change after assignment
- **Traceability** - Easy to locate and reference entities
- **Scalability** - Format supports millions of records

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              ID STRUCTURE                                   │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌──────────┬──────────────┐
    │ PREFIX   │   SEQUENCE    │
    │ (3-5)    │   (6 digits) │
    └──────────┴──────────────┘
         │            │
         │            └── Increments monotonically: 000001, 000002, 000003...
         │
         └── Identifies entity type
```

---

## 2. Entity ID Formats

### 2.1 ID Format Summary

| Entity Type | Prefix | Format | Example |
|-------------|--------|--------|---------|
| Category | `CAT` | `CAT-NNNNNN` | `CAT-000001` |
| Term | `TERM` | `TERM-NNNNNN` | `TERM-000001` |
| Tag | `TAG` | `TAG-NNNNNN` | `TAG-000001` |
| Media | `MEDIA` | `MEDIA-NNNNNN` | `MEDIA-000001` |
| Relation | `REL` | `REL-NNNNNN` | `REL-000001` |
| User | `USR` | `USR-NNNNNN` | `USR-000001` |
| Session | `SES` | `SES-NNNNNN` | `SES-000001` |
| Drill | `DRL` | `DRL-NNNNNN` | `DRL-000001` |
| Quiz | `QUIZ` | `QUIZ-NNNNNN` | `QUIZ-000001` |
| Drill Attempt | `DA` | `DA-NNNNNN` | `DA-000001` |

### 2.2 Format Specification

```
{PREFIX}-{SEQUENCE}

Where:
- PREFIX  = Uppercase ASCII letters (3-5 characters)
- DASH    = Literal hyphen "-"
- SEQUENCE = Zero-padded 6-digit number (000001-999999)
```

### 2.3 Sequence Rules

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           SEQUENCE RULES                                    │
└─────────────────────────────────────────────────────────────────────────────┘

    Entity Type    Start       Increment     Current Max
    ──────────────────────────────────────────────────────
    Category       000001      +1            000001
    Term           000001      +1            000001
    Tag            000001      +1            000001
    Media          000001      +1            000001
    Relation       000001      +1            000001
    User           000001      +1            000001
    Session        000001      +1            000001
    Drill          000001      +1            000001
    Quiz           000001      +1            000001
    Drill Attempt  000001      +1            000001
```

---

## 3. Generation Rules

### 3.1 ID Assignment

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        ID ASSIGNMENT WORKFLOW                               │
└─────────────────────────────────────────────────────────────────────────────┘

    1. CREATE REQUEST
    ┌─────────────────┐
    │  New Entity     │
    │  Submitted      │
    └────────┬────────┘
             │
             ▼
    2. VALIDATE
    ┌─────────────────┐
    │  Check Type     │──── No ────┐
    │  Available?     │            │
    └────────┬────────┘            │
             │ Yes                 │
             ▼                    │
    3. ALLOCATE                     │
    ┌─────────────────┐            │
    │  Get Next ID     │            │
    │  For Type        │            │
    └────────┬────────┘            │
             │                     │
             ▼                     │
    4. RESERVE                      │
    ┌─────────────────┐            │
    │  Lock Sequence   │            │
    │  (Atomic Op)     │            │
    └────────┬────────┘            │
             │                     │
             ▼                     │
    5. ASSIGN                       │
    ┌─────────────────┐            │
    │  ID Assigned     │            │
    │  To Entity      │            │
    └─────────────────┘            │
                                     │
    ┌─────────────────┐            │
    │   REJECT        │◄───────────┘
    │   Duplicate     │
    └─────────────────┘
```

### 3.2 Atomic Generation

```sql
-- PostgreSQL: Atomic sequence allocation
INSERT INTO id_sequences (entity_type, next_id)
VALUES ('TERM', 1)
ON CONFLICT (entity_type)
DO UPDATE SET next_id = id_sequences.next_id + 1
RETURNING next_id;

-- Result: Returns next available ID
```

### 3.3 Generation Code

```typescript
interface IdConfig {
  prefix: string;
  sequenceLength: number;
  currentMax: number;
}

function generateId(config: IdConfig): string {
  const nextSequence = config.currentMax + 1;
  const paddedSequence = String(nextSequence).padStart(
    config.sequenceLength,
    '0'
  );
  return `${config.prefix}-${paddedSequence}`;
}

// Usage
const termId = generateId({ prefix: 'TERM', sequenceLength: 6, currentMax: 1 });
// Output: "TERM-000002"
```

---

## 4. ID Composition Examples

### 4.1 Sequential Examples

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         ID SEQUENCE EXAMPLES                                │
└─────────────────────────────────────────────────────────────────────────────┘

Category IDs:
    CAT-000001  ← First category created
    CAT-000002  ← Second category
    CAT-000003  ← Third category
    ...
    CAT-999999  ← Maximum capacity

Term IDs:
    TERM-000001  ← First term created
    TERM-000002  ← Second term
    TERM-000003  ← Third term
    ...

Tag IDs:
    TAG-000001  ← First tag
    TAG-000002  ← Second tag
    TAG-000003  ← Third tag
    ...

Media IDs:
    MEDIA-000001  ← First media
    MEDIA-000002  ← Second media
    MEDIA-000003  ← Third media
    ...

Relation IDs:
    REL-000001  ← First relation
    REL-000002  ← Second relation
    REL-000003  ← Third relation
    ...
```

### 4.2 Real-World Example

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        ENTITY ID ASSIGNMENT                                 │
└─────────────────────────────────────────────────────────────────────────────┘

Scenario: Creating a new pool term "Draw Shot"

1. Category exists:
   CAT-000001 "Pool Shots"

2. Create new term:
   → Assign next Term ID: TERM-000047
   → Term "Draw Shot" gets ID: TERM-000047

3. Upload tutorial video:
   → Assign next Media ID: MEDIA-000012
   → Video gets ID: MEDIA-000012

4. Create relation to "Follow Shot":
   → Assign next Relation ID: REL-000089
   → Relation gets ID: REL-000089

5. Tag as "Advanced":
   → Assign next Tag ID: TAG-000023
   → Tag gets ID: TAG-000023
```

---

## 5. Database Schema

### 5.1 PostgreSQL

```sql
-- Centralized ID sequence management
CREATE TABLE id_sequences (
    entity_type    VARCHAR(20) PRIMARY KEY,
    prefix         VARCHAR(10) NOT NULL,
    current_max    BIGINT NOT NULL DEFAULT 0,
    min_value      BIGINT NOT NULL DEFAULT 1,
    max_value      BIGINT NOT NULL DEFAULT 999999,
    increment_by   BIGINT NOT NULL DEFAULT 1,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT valid_range CHECK (current_max <= max_value)
);

-- Pre-populate with entity types
INSERT INTO id_sequences (entity_type, prefix, current_max) VALUES
    ('CATEGORY', 'CAT', 0),
    ('TERM', 'TERM', 0),
    ('TAG', 'TAG', 0),
    ('MEDIA', 'MEDIA', 0),
    ('RELATION', 'REL', 0),
    ('USER', 'USR', 0),
    ('SESSION', 'SES', 0),
    ('DRILL', 'DRL', 0),
    ('QUIZ', 'QUIZ', 0),
    ('DRILL_ATTEMPT', 'DA', 0);

-- Atomic ID allocation function
CREATE OR REPLACE FUNCTION allocate_id(p_entity_type VARCHAR)
RETURNS VARCHAR AS $$
DECLARE
    v_prefix VARCHAR;
    v_next_id BIGINT;
    v_result VARCHAR;
BEGIN
    UPDATE id_sequences
    SET 
        current_max = current_max + 1,
        updated_at = NOW()
    WHERE entity_type = p_entity_type
    RETURNING prefix, current_max INTO v_prefix, v_next_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Unknown entity type: %', p_entity_type;
    END IF;
    
    v_result := v_prefix || '-' || LPAD(v_next_id::TEXT, 6, '0');
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- Example usage
-- SELECT allocate_id('TERM');  -- Returns 'TERM-000001'
```

### 5.2 SQLite

```sql
-- SQLite sequence table
CREATE TABLE id_sequences (
    entity_type    TEXT PRIMARY KEY,
    prefix         TEXT NOT NULL,
    current_max    INTEGER NOT NULL DEFAULT 0,
    min_value      INTEGER NOT NULL DEFAULT 1,
    max_value      INTEGER NOT NULL DEFAULT 999999,
    increment_by   INTEGER NOT NULL DEFAULT 1,
    created_at     TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at     TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Pre-populate
INSERT INTO id_sequences (entity_type, prefix) VALUES
    ('CATEGORY', 'CAT'),
    ('TERM', 'TERM'),
    ('TAG', 'TAG'),
    ('MEDIA', 'MEDIA'),
    ('RELATION', 'REL'),
    ('USER', 'USR'),
    ('SESSION', 'SES'),
    ('DRILL', 'DRL'),
    ('QUIZ', 'QUIZ'),
    ('DRILL_ATTEMPT', 'DA');

-- Atomic ID allocation (transaction-safe)
CREATE PROCEDURE allocate_id(p_entity_type TEXT):
BEGIN
    UPDATE id_sequences
    SET current_max = current_max + 1,
        updated_at = datetime('now')
    WHERE entity_type = p_entity_type;
    
    SELECT prefix || '-' || printf('%06d', current_max) AS id
    FROM id_sequences
    WHERE entity_type = p_entity_type;
END;
```

---

## 6. API Endpoints

### 6.1 ID Management

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/v1/ids/allocate` | Allocate next ID for type |
| GET | `/v1/ids/status` | Get current sequences |
| GET | `/v1/ids/validate/{id}` | Validate ID format |

### 6.2 Allocation Request

```typescript
// Request: POST /v1/ids/allocate
{
  "entity_type": "TERM"
}

// Response: 200 OK
{
  "id": "TERM-000047",
  "entity_type": "TERM",
  "allocated_at": "2026-07-17T11:35:00Z",
  "expires_at": "2026-07-17T11:40:00Z"  // 5-minute hold
}
```

### 6.3 Sequence Status

```typescript
// Request: GET /v1/ids/status

// Response: 200 OK
{
  "sequences": [
    { "entity_type": "CATEGORY", "current_max": 15, "prefix": "CAT", "remaining": 999984 },
    { "entity_type": "TERM", "current_max": 47, "prefix": "TERM", "remaining": 999952 },
    { "entity_type": "TAG", "current_max": 23, "prefix": "TAG", "remaining": 999976 },
    { "entity_type": "MEDIA", "current_max": 12, "prefix": "MEDIA", "remaining": 999987 },
    { "entity_type": "RELATION", "current_max": 89, "prefix": "REL", "remaining": 999910 }
  ],
  "total_capacity": 999990,
  "total_allocated": 186
}
```

---

## 7. Validation Rules

### 7.1 Format Validation

```typescript
const ID_PATTERN = /^[A-Z]{3,5}-\d{6}$/;

function isValidId(id: string): boolean {
  return ID_PATTERN.test(id);
}

// Valid examples
isValidId("CAT-000001");    // true
isValidId("TERM-000047");  // true
isValidId("MEDIA-000012"); // true

// Invalid examples
isValidId("CAT-1");        // false - too short
isValidId("CAT-0000001");  // false - too many digits
isValidId("cat-000001");   // false - lowercase
isValidId("TERM_000001");  // false - underscore
isValidId("TERM-00001A");  // false - letter in sequence
```

### 7.2 Entity Type Validation

```typescript
const PREFIX_MAP: Record<string, string[]> = {
  'CATEGORY': ['CAT'],
  'TERM': ['TERM'],
  'TAG': ['TAG'],
  'MEDIA': ['MEDIA'],
  'RELATION': ['REL'],
  'USER': ['USR'],
  'SESSION': ['SES'],
  'DRILL': ['DRL'],
  'QUIZ': ['QUIZ'],
  'DRILL_ATTEMPT': ['DA']
};

function getEntityType(id: string): string | null {
  const prefix = id.split('-')[0];
  for (const [type, prefixes] of Object.entries(PREFIX_MAP)) {
    if (prefixes.includes(prefix)) return type;
  }
  return null;
}

// Usage
getEntityType("TERM-000047");  // "TERM"
getEntityType("CAT-000001");   // "CATEGORY"
```

---

## 8. Golden Rules

### 8.1 Never Reuse IDs

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            ANTI-PATTERNS                                    │
│                                                                              │
│  ✗ WRONG: Delete entity, create new with same ID                            │
│  ✗ WRONG: Archive entity, reassign ID                                       │
│  ✗ WRONG: Recycle IDs for new entities                                      │
│                                                                              │
│  ✓ CORRECT: Deleted entities retain their ID forever                        │
│  ✓ CORRECT: Archived entities retain their ID forever                       │
│  ✓ CORRECT: Every new entity gets next available ID                         │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 8.2 Never Change IDs

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            ANTI-PATTERNS                                    │
│                                                                              │
│  ✗ WRONG: Change ID for "better" sequence number                          │
│  ✗ WRONG: Rename ID prefix for organizational change                        │
│  ✗ WRONG: Modify ID when migrating between systems                          │
│                                                                              │
│  ✓ CORRECT: IDs are immutable once assigned                                │
│  ✓ CORRECT: If format must change, use new IDs and redirect                 │
│  ✓ CORRECT: Store old IDs as reference field                                │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 8.3 ID Stability Policy

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           ID STABILITY POLICY                               │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌────────────────────────────────────────────────────────────────┐
    │                    PERMANENT ID RULES                         │
    ├────────────────────────────────────────────────────────────────┤
    │                                                                │
    │  1. IMMUTABILITY                                             │
    │     - IDs never change after creation                        │
    │     - Not even for "improvement"                            │
    │     - Not even in migrations                                 │
    │                                                                │
    │  2. UNIQUENESS                                               │
    │     - Every ID is assigned once                              │
    │     - No duplicates ever                                     │
    │     - Globally unique across system                          │
    │                                                                │
    │  3. PERMANENCE                                               │
    │     - Deleted entities keep their ID                        │
    │     - Archived entities keep their ID                        │
    │     - Historical records retain original ID                 │
    │                                                                │
    │  4. TRACEABILITY                                             │
    │     - ID references never break                            │
    │     - Foreign keys always valid                             │
    │     - Audit trail always consistent                         │
    │                                                                │
    └────────────────────────────────────────────────────────────────┘
```

---

## 9. Migration Strategy

### 9.1 Adding New Entity Types

```sql
-- Step 1: Register new sequence
INSERT INTO id_sequences (entity_type, prefix, current_max)
VALUES ('PLAYER', 'PLY', 0);

-- Step 2: Use allocation function
SELECT allocate_id('PLAYER');  -- Returns 'PLY-000001'
```

### 9.2 Format Changes (if ever needed)

```
Scenario: Need to extend from 6 to 8 digits

Migration Steps:
1. Add new column: id_new (8-digit format)
2. Add new sequence: current_max_8digit
3. Run migration: Copy all IDs to new format
4. Keep old column: id_old for reference
5. Switch application to use new column
6. Deprecate old column (don't delete)
```

---

## 10. Related Documents

- [Term Schema](./term_schema.md)
- [Category System](./06_Category_System.md)
- [Media Schema](./media_schema.md)
- [Database Schema](./03_Database.md)

---

## 11. Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-07-17 | Initial standard |

---

**Standard Owner:** Architecture Team
**Review Cycle:** Annual
