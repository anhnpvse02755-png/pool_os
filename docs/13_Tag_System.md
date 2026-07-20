# Billiard Knowledge Module (BKM) - Tag System

## Version 1.0
**Last Updated:** July 2026
**Status:** Production Specification

---

## 1. Universal Tagging Standard

### 1.1 Tag Philosophy

The BKM tag system provides a flexible, cross-cutting classification mechanism that transcends category boundaries. Tags enable:

| Purpose | Description | Example |
|---------|-------------|---------|
| **Discovery** | Find content by attribute | `#beginner` |
| **Filtering** | Narrow search results | `#pool #stroke` |
| **Recommendations** | Suggest related content | Users liking `#draw` also like `#follow` |
| **AI Features** | Enable intelligent features | `#coach #analysis` |

### 1.2 Tag Design Principles

| Principle | Description | Implementation |
|-----------|-------------|----------------|
| **Atomic** | One concept per tag | `#draw-shot`, not `#draw-shot-technique` |
| **Consistent** | Universal naming | `#beginner` not `#beginner-level` |
| **Discoverable** | Easy to find and use | Auto-complete suggestions |
| **Hierarchical** | Parent-child relationships | `#physics` → `#spin` → `#draw` |
| **Language-agnostic** | Same tag across languages | `#stroke` works for all languages |

---

## 2. Tag Categories

### 2.1 Category Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              TAG TAXONOMY                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   ┌────────────────────────────────────────────────────────────────────┐   │
│   │  DIFFICULTY                                                        │   │
│   │  #beginner  #intermediate  #advanced  #professional                │   │
│   └────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│   ┌────────────────────────────────────────────────────────────────────┐   │
│   │  EQUIPMENT                                                         │   │
│   │  #cue  #table  #balls  #cloth  #chalk  #bridge  #accessories      │   │
│   └────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│   ┌────────────────────────────────────────────────────────────────────┐   │
│   │  PHYSICS                                                           │   │
│   │  #spin  #english  #sidespin  #draw  #follow  #center-ball         │   │
│   │  #topspin  #backspin  #friction  #collision  #dynamics             │   │
│   └────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│   ┌────────────────────────────────────────────────────────────────────┐   │
│   │  LANGUAGE                                                          │   │
│   │  #english  #vietnamese  #japanese  #korean  #chinese               │   │
│   └────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│   ┌────────────────────────────────────────────────────────────────────┐   │
│   │  ROLE                                                              │   │
│   │  #player  #coach  #referee  #fan  #enthusiast                     │   │
│   └────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│   ┌────────────────────────────────────────────────────────────────────┐   │
│   │  AI FEATURES                                                       │   │
│   │  #coach  #analysis  #training  #quiz  #suggestion  #drill          │   │
│   └────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│   ┌────────────────────────────────────────────────────────────────────┐   │
│   │  PATTERN                                                           │   │
│   │  #strategy  #safety  #offensive  #defensive  #offense  #pattern    │   │
│   └────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│   ┌────────────────────────────────────────────────────────────────────┐   │
│   │  DISCIPLINE                                                        │   │
│   │  #pool  #snooker  #carom  #chinese-eight-ball  #8-ball  #9-ball    │   │
│   └────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Difficulty Tags

| Tag | Description | Usage |
|-----|-------------|-------|
| `#beginner` | Entry-level content | Basic techniques, rules |
| `#intermediate` | Mid-level content | Common techniques, tactics |
| `#advanced` | Complex content | Elite techniques, strategies |
| `#professional` | Expert-level content | Tournament play, elite skills |

### 2.3 Equipment Tags

| Tag | Description | Sub-tags |
|-----|-------------|----------|
| `#cue` | Cue-related content | `#cue-tip`, `#ferrule`, `#shaft` |
| `#table` | Table-related | `#cushion`, `#pocket`, `#bed` |
| `#balls` | Ball-related | `#cue-ball`, `#object-ball`, `#8-ball` |
| `#cloth` | Cloth/felt | `#nap`, `#speed`, `#maintenance` |
| `#chalk` | Chalk usage | `#chalk-color`, `#chalk-frequency` |
| `#bridge` | Bridge techniques | `#open-bridge`, `#closed-bridge` |
| `#accessories` | Other equipment | `#rack`, `#spider`, `# Extensions` |

### 2.4 Physics Tags

| Tag | Description | Related Tags |
|-----|-------------|--------------|
| `#spin` | General spin | `#english`, `#sidespin` |
| `#english` | Side spin terminology | `#left-english`, `#right-english` |
| `#sidespin` | Side rotation | `#left`, `#right` |
| `#draw` | Backspin | `#backspin`, `#draw-shot` |
| `#follow` | Topspin | `#topspin`, `#follow-shot` |
| `#center-ball` | No spin | `#stun`, `#natural` |
| `#topspin` | Forward rotation | `#follow` |
| `#backspin` | Backward rotation | `#draw` |
| `#friction` | Surface interaction | `#collision` |
| `#collision` | Ball-to-ball physics | `#deflection` |
| `#dynamics` | Motion physics | `#momentum`, `#velocity` |

### 2.5 Language Tags

| Tag | Language | ISO Code |
|-----|----------|----------|
| `#english` | English | en |
| `#vietnamese` | Vietnamese | vi |
| `#japanese` | Japanese | ja |
| `#korean` | Korean | ko |
| `#chinese` | Chinese | zh |
| `#thai` | Thai | th |
| `#german` | German | de |
| `#french` | French | fr |
| `#spanish` | Spanish | es |

### 2.6 Role Tags

| Tag | Target Audience |
|-----|----------------|
| `#player` | Players of any level |
| `#coach` | Coaches and instructors |
| `#referee` | Officials and judges |
| `#fan` | Spectators and enthusiasts |
| `#enthusiast` | Hobbyists and learners |

### 2.7 AI Feature Tags

| Tag | AI Application |
|-----|----------------|
| `#coach` | AI coaching content |
| `#analysis` | AI-analyzed content |
| `#training` | Training recommendations |
| `#quiz` | Quiz/assessment content |
| `#suggestion` | AI suggestions |
| `#drill` | Drill content |

### 2.8 Pattern Tags

| Tag | Description |
|-----|-------------|
| `#strategy` | Strategic content |
| `#safety` | Safety play content |
| `#offensive` | Offensive tactics |
| `#defensive` | Defensive tactics |
| `#offense` | Offensive patterns |
| `#pattern` | Pattern play |

### 2.9 Discipline Tags

| Tag | Discipline | Variants |
|-----|------------|----------|
| `#pool` | Pool (general) | #8-ball, #9-ball, #10-ball |
| `#snooker` | Snooker | #snooker-break, #maximum |
| `#carom` | Carom | #3-cushion, #straight-rail |
| `#chinese-eight-ball` | Chinese 8-ball | - |
| `#8-ball` | 8-ball specific | #solid, #stripe |
| `#9-ball` | 9-ball specific | #call-shot |
| `#10-ball` | 10-ball specific | - |
| `#straight-pool` | Straight pool | - |

---

## 3. Tag Hierarchy

### 3.1 Hierarchical Structure

```json
{
  "tags": [
    {
      "id": "tag-physics",
      "name": "physics",
      "display_name": {
        "en": "Physics",
        "vi": "Vật Lý"
      },
      "parent_id": null,
      "level": 0,
      "children": [
        {
          "id": "tag-spin",
          "name": "spin",
          "display_name": {
            "en": "Spin",
            "vi": "Xoáy"
          },
          "parent_id": "tag-physics",
          "level": 1,
          "children": [
            {
              "id": "tag-draw",
              "name": "draw",
              "display_name": {
                "en": "Draw",
                "vi": "Úp"
              },
              "parent_id": "tag-spin",
              "level": 2
            },
            {
              "id": "tag-follow",
              "name": "follow",
              "display_name": {
                "en": "Follow",
                "vi": "Lưng"
              },
              "parent_id": "tag-spin",
              "level": 2
            }
          ]
        }
      ]
    }
  ]
}
```

### 3.2 Hierarchy Rules

| Rule | Description | Example |
|------|-------------|---------|
| **Max Depth** | 4 levels maximum | physics → spin → draw → power-draw |
| **Single Parent** | Each tag has one parent | `#power-draw` parent is `#draw` |
| **Inheritance** | Child inherits parent context | `#draw` implies `#spin` |
| **No Orphan** | All tags have parent (except root) | - |

---

## 4. Tag Naming Conventions

### 4.1 Naming Rules

| Rule | Correct | Incorrect |
|------|---------|----------|
| **Lowercase** | `#beginner` | `#Beginner` |
| **Hyphens** | `#draw-shot` | `#drawshot` or `#draw_shot` |
| **No Spaces** | `#intermediate-level` | `#intermediate level` |
| **No Special** | `#8-ball` | `#8ball!` |
| **Singular** | `#player` | `#players` |
| **Atomic** | `#stroke` | `#stroke-mechanics` |
| **English-origin** | `#cue` | `#gậy` (unless native term) |

### 4.2 Naming Format

```
{scope}-{concept}[-{qualifier}]

Examples:
├── physics-spin         # scope=physics, concept=spin
├── equipment-cue        # scope=equipment, concept=cue
├── difficulty-beginner  # scope=difficulty, concept=beginner
├── discipline-pool-8ball # scope=discipline, concept=pool, qualifier=8ball
```

### 4.3 Reserved Tags

| Tag | Purpose | Restricted |
|-----|---------|------------|
| `#system` | System use only | Yes |
| `#featured` | Featured content | Yes |
| `#new` | Recently added | Auto |
| `#updated` | Recently modified | Auto |
| `#deprecated` | Deprecated content | Yes |
| `#premium` | Premium content | Yes |

---

## 5. Tag Management

### 5.1 Tag Lifecycle

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           TAG LIFECYCLE                                       │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│Proposed │────►│Approved │────►│Active   │────►│Archived │
└─────────┘     └─────────┘     └─────────┘     └─────────┘
     │               │               │               │
     ▼               ▼               ▼               ▼
  Submit         Expert          Use in         Keep for
  for review     approval        content        reference
```

### 5.2 Tag Creation Request

```markdown
## New Tag Request

**Tag Name:** #power-draw
**Category:** physics.spin.draw
**Description:** Advanced draw shot technique with high power

**Proposed Definition:**
Advanced draw shot variation requiring precise cue tip contact and power control.

**Use Cases:**
- High-power position shots
- Long-distance draw
- Defensive draw shots

**Related Existing Tags:**
- #draw
- #power
- #advanced

**Proposed By:** [Name]
**Date:** [Date]
```

### 5.3 Tag Merge/Split

**Merge (combining tags):**
```markdown
## Tag Merge Request

**Tags to Merge:**
- #sidespin
- #side-spin
- #side_spin

**Result Tag:** #sidespin

**Reason:** Standardization
**Redirect:** All #side-spin and #side_spin → #sidespin
```

**Split (separating tags):**
```markdown
## Tag Split Request

**Tag to Split:** #stroke

**Result Tags:**
- #stroke-technique (technique focus)
- #stroke-mechanics (mechanics focus)
- #stroke-rhythm (rhythm focus)

**Reason:** Semantic clarity
```

---

## 6. Tag Search Optimization

### 6.1 Search Index

```sql
-- Tag search optimization index
CREATE INDEX idx_tags_name ON tags(LOWER(name));
CREATE INDEX idx_tags_category ON tags(category);
CREATE INDEX idx_tags_parent ON tags(parent_id);

-- Tag search with content count
CREATE VIEW tag_with_counts AS
SELECT 
    t.*,
    COUNT(DISTINCT tt.term_id) AS term_count,
    COUNT(DISTINCT tt.term_id) FILTER (WHERE t.updated_at > NOW() - INTERVAL '30 days') AS recent_count
FROM tags t
LEFT JOIN term_tags tt ON tt.tag_id = t.id
GROUP BY t.id;
```

### 6.2 Search Performance

| Operation | Target | Method |
|-----------|--------|--------|
| **Tag Autocomplete** | <50ms | Prefix index |
| **Tag Filter Query** | <100ms | Bitmap index |
| **Tag Suggestions** | <100ms | Trigram match |
| **Popular Tags** | <50ms | Cached aggregation |

### 6.3 Caching Strategy

```python
# Cache popular tags
POPULAR_TAGS_CACHE_KEY = "tags:popular"
CACHE_TTL = 3600  # 1 hour

# Cache tag hierarchy
TAG_HIERARCHY_CACHE_KEY = "tags:hierarchy:{language}"
CACHE_TTL = 86400  # 24 hours

# Cache user tag preferences
USER_TAGS_CACHE_KEY = "tags:user:{user_id}:recent"
CACHE_TTL = 604800  # 1 week
```

---

## 7. Tag Usage Examples

### 7.1 Multi-Tag Queries

```markdown
# Find advanced pool stroke techniques
filter: #pool #stroke #advanced

# Find drills for beginners
filter: #drill #beginner

# Find coaching content
filter: #coach #training

# Find physics explanations
filter: #physics #spin #english
```

### 7.2 Tag Combinations

```json
{
  "query": "draw shot",
  "filters": {
    "tags": ["#pool", "#stroke", "#spin"],
    "difficulty": "#intermediate"
  },
  "exclude": ["#advanced"]
}
```

### 7.3 Tag Display Format

```markdown
**Tags:**
#physics #spin #draw #intermediate #pool #cue
```

---

## 8. Tag System Schema

### 8.1 Database Schema

```sql
CREATE TABLE tags (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Identification
    name            VARCHAR(100) NOT NULL UNIQUE,
    slug            VARCHAR(100) NOT NULL UNIQUE,
    
    -- Display
    display_name    JSONB NOT NULL,
    description     JSONB,
    
    -- Classification
    category        VARCHAR(50) NOT NULL,
    parent_id       UUID REFERENCES tags(id) ON DELETE SET NULL,
    
    -- Hierarchy
    level           INTEGER NOT NULL DEFAULT 0,
    path            LTREE,
    
    -- Metadata
    language        VARCHAR(5),
    color           VARCHAR(7),
    icon            VARCHAR(50),
    sort_order      INTEGER DEFAULT 0,
    
    -- System
    is_system       BOOLEAN DEFAULT FALSE,
    is_restricted   BOOLEAN DEFAULT FALSE,
    
    -- Timestamps
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ,
    
    -- Constraints
    CONSTRAINT unique_tag_slug UNIQUE (slug),
    CONSTRAINT valid_category CHECK (category IN (
        'difficulty', 'equipment', 'physics', 'language', 
        'role', 'ai', 'pattern', 'discipline'
    ))
);

CREATE INDEX idx_tags_slug ON tags(slug);
CREATE INDEX idx_tags_category ON tags(category);
CREATE INDEX idx_tags_parent ON tags(parent_id);
CREATE INDEX idx_tags_path ON tags USING GIST(path);
```

### 8.2 Term-Tag Junction

```sql
CREATE TABLE term_tags (
    term_id         UUID NOT NULL REFERENCES terms(id) ON DELETE CASCADE,
    tag_id          UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    
    -- Context
    context         VARCHAR(100),
    weight          DECIMAL(3,2) DEFAULT 1.00,
    
    -- Audit
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by      UUID REFERENCES users(id),
    
    PRIMARY KEY (term_id, tag_id)
);

CREATE INDEX idx_term_tags_tag ON term_tags(tag_id);
```

---

## 9. Appendix

### 9.1 Tag Reference

| Category | Tags | Count |
|----------|------|-------|
| **Difficulty** | beginner, intermediate, advanced, professional | 4 |
| **Equipment** | cue, table, balls, cloth, chalk, bridge, accessories | 7 |
| **Physics** | spin, english, sidespin, draw, follow, center-ball, topspin, backspin, friction, collision, dynamics | 11 |
| **Language** | english, vietnamese, japanese, korean, chinese | 5 |
| **Role** | player, coach, referee, fan, enthusiast | 5 |
| **AI** | coach, analysis, training, quiz, suggestion, drill | 6 |
| **Pattern** | strategy, safety, offensive, defensive, offense, pattern | 6 |
| **Discipline** | pool, snooker, carom, chinese-eight-ball, 8-ball, 9-ball, 10-ball, straight-pool | 8 |
| **Total** | | **52+** |

### 9.2 Related Documents

- [BKM Project Vision](./01_Project_Vision.md)
- [BKM Database Schema](./03_Database.md)
- [BKM Category System](./06_Category_System.md)
- [BKM Search System](./05_Search_System.md)

---

**End of Document**
