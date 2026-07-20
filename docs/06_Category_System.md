# Billiard Knowledge Module (BKM) - Category System

## Version 1.0
**Last Updated:** July 2026
**Status:** Production Specification

---

## 1. Category System Overview

### 1.1 Design Principles

| Principle | Description | Implementation |
|-----------|-------------|----------------|
| **Hierarchical** | Parent-child relationships | LTREE path structure |
| **Discipline-Specific** | Categories per billiards type | `discipline_id` reference |
| **Multi-Language** | Names translated | JSONB with language keys |
| **Extensible** | Easy to add new categories | Open schema design |
| **Normalized** | No redundant categories | Single source of truth |

### 1.2 Category Tree Structure

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         COMPLETE CATEGORY TREE                                │
└─────────────────────────────────────────────────────────────────────────────┘

BILLIARD KNOWLEDGE
│
├── POOL (pool)
│   │
│   ├── Fundamentals
│   │   ├── Basic Rules
│   │   ├── Table Setup
│   │   ├── Ball Identification
│   │   ├── Aiming Fundamentals
│   │   ├── Stance & Bridge
│   │   └── Grip & Delivery
│   │
│   ├── Stroke
│   │   ├── Stroke Mechanics
│   │   │   ├── Straight Stroke
│   │   │   ├── Pendulum Motion
│   │   │   └── Follow-Through
│   │   ├── Power Control
│   │   │   ├── Light Shot
│   │   │   ├── Medium Shot
│   │   │   └── Power Shot
│   │   └── Tempo & Rhythm
│   │
│   ├── Position
│   │   ├── Natural Angles
│   │   ├── Tangent Lines
│   │   ├── Position Zones
│   │   ├── Cue Ball Control
│   │   └── Shape Play
│   │
│   ├── Spin
│   │   ├── Draw (Backspin)
│   │   │   ├── Light Draw
│   │   │   ├── Medium Draw
│   │   │   └── Power Draw
│   │   ├── Follow (Topspin)
│   │   │   ├── Light Follow
│   │   │   ├── Medium Follow
│   │   │   └── Running English
│   │   └── Stun (Center Ball)
│   │
│   ├── English (Spin Types)
│   │   ├── Left English
│   │   │   ├── Light Left
│   │   │   ├── Medium Left
│   │   │   └── Extra Left
│   │   ├── Right English
│   │   │   ├── Light Right
│   │   │   ├── Medium Right
│   │   │   └── Extra Right
│   │   ├── Combination English
│   │   └── English Application
│   │
│   ├── Break
│   │   ├── Break Setup
│   │   ├── Power Breaks
│   │   ├── Control Breaks
│   │   ├── 8-Ball Break
│   │   ├── 9-Ball Break
│   │   └── Piracy Break
│   │
│   ├── Jump
│   │   ├── Jump Shot Basics
│   │   ├── Jump Cue Technique
│   │   ├── Massey Shot
│   │   ├── Legal Jumping
│   │   └── Jump Safety Play
│   │
│   ├── Safety
│   │   ├── Basic Safety
│   │   ├── Safety Philosophy
│   │   ├── Send-Away Safeties
│   │   ├── Leave-a-Tough-One
│   │   ├── Snookering
│   │   └── Kick Safety
│   │
│   ├── Kicking
│   │   ├── One-Rail Kicks
│   │   ├── Two-Rail Kicks
│   │   ├── Three-Rail Kicks
│   │   ├── System Kicks
│   │   │   ├── 2-Band System
│   │   │   ├── 3-Rail Aiming
│   │   │   └── Fractional System
│   │   └── Ghost Ball Aiming
│   │
│   ├── Banking
│   │   ├── Bank Shot Fundamentals
│   │   ├── Thin Banks
│   │   ├── Thick Banks
│   │   ├── Bank Position
│   │   ├── Double Banks
│   │   └── Control Banks
│   │
│   ├── Equipment
│   │   ├── Cues
│   │   │   ├── Cue Construction
│   │   │   ├── Cue Selection
│   │   │   └── Cue Maintenance
│   │   ├── Tables
│   │   │   ├── Table Types
│   │   │   ├── Cloth & Cushions
│   │   │   └── Table Setup
│   │   ├── Balls
│   │   │   ├── Ball Types
│   │   │   └── Ball Care
│   │   ├── Accessories
│   │   │   ├── Chalk
│   │   │   ├── Bridge
│   │   │   └── racks
│   │   └── Environmental
│   │       ├── Lighting
│   │       └── Room Setup
│   │
│   ├── Rules
│   │   ├── 8-Ball Rules
│   │   │   ├── Break & Pocket Order
│   │   │   ├── Legal Shots
│   │   │   ├── Fouls & Penalties
│   │   │   └── Winning Conditions
│   │   ├── 9-Ball Rules
│   │   │   ├── Combination Shots
│   │   │   ├── Push Out
│   │   │   └── Calling Shots
│   │   ├── 10-Ball Rules
│   │   ├── Straight Pool Rules
│   │   ├── One-Pocket Rules
│   │   ├── Bank Pool Rules
│   │   └── General Fouls
│   │
│   ├── Tournament
│   │   ├── Tournament Formats
│   │   ├── Match Play
│   │   ├── Race Formats
│   │   ├── Handicapping
│   │   └── Etiquette
│   │
│   ├── Training
│   │   ├── Practice Routines
│   │   ├── Warm-Up Exercises
│   │   ├── Skill Drills
│   │   │   ├── Straight Shots
│   │   │   ├── Position Drills
│   │   │   ├── Bank Drills
│   │   │   └── Combination Drills
│   │   └── Progress Tracking
│   │
│   └── Drills
│       ├── Individual Drills
│       │   ├── Straight Line Drill
│       │   ├── Angle Drill
│       │   ├── Distance Drill
│       │   └── Speed Control Drill
│       ├── Game Situation Drills
│       │   ├── 8-Ball Drills
│       │   ├── 9-Ball Drills
│       │   └── Safety Drills
│       └── Competitive Drills
│           ├── Pressure Shots
│           ├── Speed Drills
│           └── Match Play Scenarios
│
│
├── SNOOKER (snooker)
│   │
│   ├── Fundamentals
│   │   ├── Table & Balls
│   │   ├── Basic Rules
│   │   ├── Baulk Line & D
│   │   ├── Point Values
│   │   └── Stance & Grip
│   │
│   ├── Stroke
│   │   ├── Stroke Technique
│   │   ├── Cue Action
│   │   ├── Power Development
│   │   └── Long Potting
│   │
│   ├── Position
│   │   ├── Natural Roll
│   │   ├── Pink & Black Control
│   │   ├── Position After Red
│   │   └── Color Position
│   │
│   ├── Spin
│   │   ├── Side on Reds
│   │   ├── Side on Colors
│   │   ├── Screw Back
│   │   └── Top Spin Application
│   │
│   ├── Break
│   │   ├── Opening Break
│   │   ├── Building Breaks
│   │   ├── Maximum Break (147)
│   │   └── Break Safety
│   │
│   ├── Safety
│   │   ├── Trading
│   │   ├── Snookering
│   │   ├── Escape Techniques
│   │   └── Rest Usage
│   │
│   ├── Equipment
│   │   ├── Snooker Cues
│   │   ├── Snooker Balls
│   │   ├── Snooker Table
│   │   └── Rest & Spider
│   │
│   ├── Rules
│   │   ├── Official Rules
│   │   ├── Foul Points
│   │   ├── Miss Rule
│   │   └── Touching Ball
│   │
│   └── Tournament
│       ├── Ranking System
│       ├── Tournament Formats
│       └── Major Events
│
│
├── CAROM (carom)
│   │
│   ├── Fundamentals
│   │   ├── Table Configuration
│   │   ├── Object Balls Only
│   │   ├── Carom Definition
│   │   └── Basic Techniques
│   │
│   ├── Stroke
│   │   ├── Carom Stroke
│   │   ├── Precision Aiming
│   │   └── Power Control
│   │
│   ├── Position
│   │   ├── Trajectory Control
│   │   ├── Diamond Systems
│   │   └── Three-Cushion Basics
│   │
│   ├── Equipment
│   │   ├── Carom Tables
│   │   ├── Carom Balls
│   │   └── Cushion Rails
│   │
│   └── Rules
│       ├── Three-Cushion Rules
│       ├── Straight Rail Rules
│       ├── Balkline Rules
│       └── Scoring Systems
│
│
├── CHINESE EIGHT BALL (chinese_8ball)
│   │
│   ├── Fundamentals
│   │   ├── Table Setup
│   │   ├── Baulk Rules
│   │   ├── Group Assignment
│   │   └── Basic Objectives
│   │
│   ├── Stroke
│   │   ├── Technique Basics
│   │   └── Shot Delivery
│   │
│   ├── Position
│   │   ├── Position Strategy
│   │   └── Group Control
│   │
│   ├── Equipment
│   │   ├── Table Specifications
│   │   ├── Ball Set
│   │   └── Accessories
│   │
│   └── Rules
│       ├── Foul Rules
│       ├── Ball-in-Hand
│       ├── Safety Rules
│       └── Winning Conditions
│
│
├── TRAINING (Cross-discipline)
│   │
│   ├── Drills
│   │   ├── Fundamental Drills
│   │   │   ├── Alignment Drills
│   │   │   ├── Stroke Drills
│   │   │   └── Aiming Drills
│   │   ├── Advanced Drills
│   │   │   ├── Position Drills
│   │   │   ├── English Drills
│   │   │   └── Bank Drills
│   │   └── Discipline-Specific
│   │       ├── Pool Drills
│   │       ├── Snooker Drills
│   │       └── Carom Drills
│   │
│   ├── Practice Methods
│   │   ├── Solo Practice
│   │   ├── Partner Drills
│   │   ├── Routine Building
│   │   └── Progress Assessment
│   │
│   ├── Physical Training
│   │   ├── Hand-Eye Coordination
│   │   ├── Flexibility
│   │   ├── Strength
│   │   └── Endurance
│   │
│   └── Mental Training
│       ├── Focus Techniques
│       ├── Pressure Management
│       ├── Visualization
│       └── Pre-Shot Routine
│
│
├── PHYSICS
│   │
│   ├── Mechanics
│   │   ├── Force & Momentum
│   │   ├── Friction
│   │   ├── Collision Physics
│   │   └── Energy Transfer
│   │
│   ├── Mathematics
│   │   ├── Angles & Geometry
│   │   ├── Trajectory Calculation
│   │   ├── Diamond Systems
│   │   └── Probability
│   │
│   └── Ball Dynamics
│       ├── Rolling vs Sliding
│       ├── Spin Decay
│       ├── Cushion Interaction
│       └── Pocketing Mechanics
│
│
├── PSYCHOLOGY
│   │
│   ├── Mental Game
│   │   ├── Mindset
│   │   ├── Confidence
│   │   ├── Consistency
│   │   └── Competition Mentality
│   │
│   ├── Focus
│   │   ├── Concentration
│   │   ├── Distraction Management
│   │   ├── Shot Routine
│   │   └── Routine Development
│   │
│   └── Pressure Management
│       ├── Pressure Situations
│       ├── Breathing Techniques
│       ├── Choking Prevention
│       └── Match Pressure
│
│
├── REFEREE
│   │
│   ├── Rules Enforcement
│   │   ├── Foul Recognition
│   │   ├── Ball-in-Hand Administration
│   │   ├── Shot Completion
│   │   └── Interference Calls
│   │
│   └── Match Management
│       ├── Timing
│       ├── Player Conduct
│       ├── Protest Handling
│       └── Documentation
│
│
├── COACHING
│   │
│   ├── Teaching Methods
│   │   ├── Explanation Techniques
│   │   ├── Demonstration
│   │   ├── Feedback Delivery
│   │   └── Lesson Structure
│   │
│   └── Player Development
│       ├── Skill Assessment
│       ├── Training Plans
│       ├── Progress Tracking
│       └── Competition Prep
│
│
└── AI
    │
    ├── Analysis
    │   ├── Shot Analysis
    │   ├── Pattern Detection
    │   ├── Strength & Weakness
    │   └── Match Analysis
    │
    └── Training Assistance
        ├── Drill Recommendations
        ├── Learning Paths
        ├── Performance Prediction
        └── Personalized Coaching
```

---

## 2. Category Metadata Requirements

### 2.1 Required Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `id` | UUID | Unique identifier | `550e8400-...` |
| `slug` | String | URL-safe identifier | `stroke-techniques` |
| `name` | JSONB | Localized names | `{"en": "Stroke", "vi": "Gạt Cơ"}` |
| `discipline_id` | UUID | Parent discipline | `550e8400-...` |
| `language` | String | Primary language | `en` |
| `status` | Enum | active/draft/archived | `active` |
| `version` | String | Schema version | `v1` |

### 2.2 Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| `parent_id` | UUID | Parent category |
| `path` | LTREE | Hierarchical path |
| `level` | Integer | Depth level (0 = root) |
| `description` | JSONB | Localized descriptions |
| `icon` | String | Icon identifier |
| `color` | String | Hex color code |
| `sort_order` | Integer | Display order |
| `meta_title` | JSONB | SEO title |
| `meta_description` | JSONB | SEO description |

### 2.3 Category JSON Schema

```json
{
  "$schema": "https://pool-os.dev/bkm/schemas/category/v1.schema.json",
  "id": "660e8400-e29b-41d4-a716-446655440001",
  "version": "v1",
  "status": "active",
  
  "slug": "stroke-techniques",
  "code": "STROKE",
  
  "discipline": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "code": "pool"
  },
  
  "parent": {
    "id": "660e8400-e29b-41d4-a716-446655440002",
    "slug": "fundamentals"
  },
  
  "path": "pool.fundamentals.stroke-techniques",
  "level": 2,
  
  "name": {
    "en": "Stroke Techniques",
    "vi": "Kỹ Thuật Gạt Cơ"
  },
  
  "description": {
    "en": "Fundamental and advanced stroke techniques including draw, follow, and stun shots.",
    "vi": "Các kỹ thuật gạt cơ cơ bản và nâng cao bao gồm úp, đánh lưng và đánh dừng."
  },
  
  "icon": "stroke",
  "color": "#4A90D9",
  "sort_order": 3,
  
  "metadata": {
    "meta_title": {
      "en": "Stroke Techniques | Pool OS",
      "vi": "Kỹ Thuật Gạt Cơ | Pool OS"
    },
    "meta_description": {
      "en": "Learn essential stroke techniques in pool including draw shots, follow shots, and stun shots.",
      "vi": "Tìm hiểu các kỹ thuật gạt cơ thiết yếu trong bida lỗ bao gồm úp bóng, đánh lưng và đánh dừng."
    }
  },
  
  "statistics": {
    "term_count": 25,
    "view_count": 15420,
    "last_updated": "2026-07-15T10:30:00Z"
  },
  
  "created_at": "2026-07-01T00:00:00Z",
  "updated_at": "2026-07-15T10:30:00Z"
}
```

---

## 3. Sub-Category Management

### 3.1 LTREE Path Structure

```sql
-- LTREE enables efficient hierarchical queries
CREATE EXTENSION IF NOT EXISTS ltree;

-- Path examples:
-- pool                     (depth 0)
-- pool.fundamentals        (depth 1)
-- pool.fundamentals.stroke (depth 2)
-- pool.fundamentals.stroke.techniques (depth 3)

-- Get all descendants of a category
SELECT * FROM categories 
WHERE path <@ 'pool.fundamentals.stroke';

-- Get ancestors of a category
SELECT * FROM categories 
WHERE 'pool.fundamentals.stroke.techniques' <@ path;

-- Get immediate children
SELECT * FROM categories 
WHERE path ~ 'pool.fundamentals.stroke.{1}';
```

### 3.2 Category Management Operations

#### 3.2.1 Create Category

```sql
CREATE OR REPLACE FUNCTION create_category(
  p_slug TEXT,
  p_name JSONB,
  p_discipline_id UUID,
  p_parent_id UUID DEFAULT NULL,
  p_language TEXT DEFAULT 'en'
)
RETURNS UUID AS $$
DECLARE
  v_category_id UUID;
  v_path LTREE;
  v_parent_path LTREE;
  v_level INTEGER;
BEGIN
  -- Get parent path if exists
  IF p_parent_id IS NOT NULL THEN
    SELECT path, level INTO v_parent_path, v_level
    FROM categories WHERE id = p_parent_id;
    v_level := v_level + 1;
  ELSE
    v_parent_path := NULL;
    v_level := 0;
  END IF;
  
  -- Build path
  v_path := COALESCE(v_parent_path, '')::ltree || p_slug::ltree;
  
  -- Insert category
  INSERT INTO categories (slug, name, discipline_id, parent_id, path, level, language)
  VALUES (p_slug, p_name, p_discipline_id, p_parent_id, v_path, v_level, p_language)
  RETURNING id INTO v_category_id;
  
  RETURN v_category_id;
END;
$$ LANGUAGE plpgsql;
```

#### 3.2.2 Move Category

```sql
CREATE OR REPLACE FUNCTION move_category(
  p_category_id UUID,
  p_new_parent_id UUID DEFAULT NULL
)
RETURNS VOID AS $$
DECLARE
  v_old_path LTREE;
  v_new_path LTREE;
  v_new_level INTEGER;
BEGIN
  -- Get current path
  SELECT path INTO v_old_path FROM categories WHERE id = p_category_id;
  
  -- Get new parent's path
  IF p_new_parent_id IS NOT NULL THEN
    SELECT path, level INTO v_new_path, v_new_level FROM categories WHERE id = p_new_parent_id;
    v_new_level := v_new_level + 1;
  ELSE
    -- Moving to root
    SELECT slug INTO v_new_path FROM categories WHERE id = p_category_id;
    v_new_level := 0;
  END IF;
  
  -- Update all descendants' paths
  UPDATE categories
  SET path = v_new_path::ltree || subpath(path, nlevel(v_old_path)),
      level = level - nlevel(v_old_path) + nlevel(v_new_path::ltree) + 1
  WHERE path <@ v_old_path;
  
  -- Update the category itself
  UPDATE categories
  SET path = v_new_path::ltree || p_category_id::text::ltree,
      level = v_new_level,
      parent_id = p_new_parent_id
  WHERE id = p_category_id;
END;
$$ LANGUAGE plpgsql;
```

#### 3.2.3 Delete Category

```sql
CREATE OR REPLACE FUNCTION delete_category(
  p_category_id UUID,
  p_reassign_to UUID DEFAULT NULL
)
RETURNS VOID AS $$
DECLARE
  v_path LTREE;
BEGIN
  -- Get path
  SELECT path INTO v_path FROM categories WHERE id = p_category_id;
  
  -- Reassign terms if specified
  IF p_reassign_to IS NOT NULL THEN
    UPDATE term_categories
    SET category_id = p_reassign_to
    WHERE category_id = p_category_id;
  ELSE
    -- Delete term associations
    DELETE FROM term_categories WHERE category_id = p_category_id;
  END IF;
  
  -- Delete category and descendants
  DELETE FROM categories WHERE path <@ v_path OR id = p_category_id;
END;
$$ LANGUAGE plpgsql;
```

---

## 4. Cross-Discipline Categorization

### 4.1 Shared Categories

Some categories exist across multiple disciplines:

```json
{
  "shared_categories": [
    {
      "slug": "fundamentals",
      "disciplines": ["pool", "snooker", "carom", "chinese_8ball"],
      "description": "Basic skills and concepts applicable to all billiards disciplines"
    },
    {
      "slug": "stroke-mechanics",
      "disciplines": ["pool", "snooker", "carom", "chinese_8ball"],
      "description": "Fundamental stroking technique"
    },
    {
      "slug": "equipment-care",
      "disciplines": ["pool", "snooker", "carom", "chinese_8ball"],
      "description": "Equipment maintenance and selection"
    },
    {
      "slug": "psychology",
      "disciplines": ["pool", "snooker", "carom", "chinese_8ball"],
      "description": "Mental game and pressure management"
    }
  ]
}
```

### 4.2 Category-Discipline Mapping

```sql
CREATE TABLE category_disciplines (
  category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
  discipline_id UUID REFERENCES disciplines(id) ON DELETE CASCADE,
  
  is_primary BOOLEAN DEFAULT FALSE,
  
  PRIMARY KEY (category_id, discipline_id)
);
```

### 4.3 Cross-Reference Relationships

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       CROSS-DISCIPLINE RELATIONSHIPS                         │
└─────────────────────────────────────────────────────────────────────────────┘

Pool: Stroke Mechanics
        │
        │ related_to
        ▼
Snooker: Stroke Technique
        │
        │ both
        ▼
Carom: Stroke Technique
        │
        │ both
        ▼
Chinese Eight Ball: Stroke Mechanics

Note: While related, each discipline has its own specific implementation
of the general concept.
```

---

## 5. Category Statistics

### 5.1 Tracking Fields

| Field | Type | Description |
|-------|------|-------------|
| `term_count` | Integer | Total terms in category |
| `view_count` | Integer | Total category views |
| `last_updated` | Timestamp | Last statistics update |

### 5.2 Statistics Update Trigger

```sql
CREATE OR REPLACE FUNCTION update_category_statistics()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE categories SET
    term_count = (
      SELECT COUNT(*) FROM term_categories 
      WHERE category_id = NEW.category_id
    ),
    last_updated = NOW()
  WHERE id = NEW.category_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER term_category_statistics
AFTER INSERT OR DELETE ON term_categories
FOR EACH ROW
EXECUTE FUNCTION update_category_statistics();
```

---

## 6. Category Navigation

### 6.1 Navigation API Response

```json
{
  "navigation": {
    "disciplines": [
      {
        "code": "pool",
        "name": { "en": "Pool", "vi": "Bida Lỗ" },
        "categories": [
          {
            "slug": "fundamentals",
            "name": { "en": "Fundamentals", "vi": "Cơ Bản" },
            "children": [
              {
                "slug": "stroke-techniques",
                "name": { "en": "Stroke Techniques", "vi": "Kỹ Thuật Gạt Cơ" },
                "term_count": 25,
                "children": []
              }
            ]
          }
        ]
      }
    ]
  }
}
```

### 6.2 Breadcrumb Generation

```sql
CREATE OR REPLACE FUNCTION get_category_breadcrumb(p_category_id UUID)
RETURNS TABLE(path_name JSONB, path_slug TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.name,
    c.slug
  FROM categories c,
       (SELECT path FROM categories WHERE id = p_category_id) AS cat_path
  WHERE cat_path.path <@ c.path
  ORDER BY nlevel(c.path);
END;
$$ LANGUAGE plpgsql;
```

---

## 7. Appendix

### 7.1 Category ID Reference

| Category | Slug | Discipline |
|----------|------|------------|
| Pool Root | `pool` | pool |
| Snooker Root | `snooker` | snooker |
| Carom Root | `carom` | carom |
| Chinese Eight Ball Root | `chinese_8ball` | chinese_8ball |
| Training (Cross-discipline) | `training` | shared |
| Physics | `physics` | shared |
| Psychology | `psychology` | shared |

### 7.2 Related Documents

- [BKM Database Schema](./03_Database.md)
- [BKM JSON Spec](./04_JSON_Spec.md)
- [BKM Search System](./05_Search_System.md)
- [BKM API Design](./15_API_Design_For_PoolOS.md)

---

**End of Document**
