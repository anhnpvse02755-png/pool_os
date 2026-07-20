# Billiard Knowledge Module (BKM) - Knowledge Graph System

## Version 1.0
**Last Updated:** July 2026
**Status:** Production Specification

---

## 1. Overview

The Pool OS Knowledge Base is NOT a traditional dictionary. It is a **Knowledge Graph** where every concept exists as a **Node** connected to other nodes through **Edges**.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           KNOWLEDGE GRAPH                                    │
│                                                                             │
│   ┌──────────┐          ┌──────────┐          ┌──────────┐                   │
│   │  NODE    │──────────│  NODE    │──────────│  NODE    │                   │
│   │  Draw    │    EDGE  │  Back    │    EDGE  │  Cue Tip │                   │
│   │  Shot    │──────────│  Spin    │──────────│  Contact │                   │
│   └──────────┘          └──────────┘          └──────────┘                   │
│        │                     │                     │                         │
│        │ USES                │ APPLIES             │ REQUIRES               │
│        ▼                     ▼                     ▼                         │
│   ┌──────────┐          ┌──────────┐          ┌──────────┐                   │
│   │ RELATED │          │ RELATED │          │ RELATED │                   │
│   │ TO      │          │ TO      │          │ TO      │                   │
│   └──────────┘          └──────────┘          └──────────┘                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.1 Graph Philosophy

| Principle | Description |
|-----------|-------------|
| **Nodes First** | Every billiard concept is a node with rich metadata |
| **Edges Matter** | Relationships carry weight, confidence, and provenance |
| **Bidirectional** | Most edges are traversable in both directions |
| **Cycle-Free** | Directed edges form DAGs (Directed Acyclic Graphs) |
| **Versioned** | Graph supports multiple versions (v1, v2, v3) |
| **Multi-Language** | Nodes support English, Vietnamese, and future languages |

---

## 2. Node Types

### 2.1 Node Type Taxonomy

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              NODE HIERARCHY                                  │
└─────────────────────────────────────────────────────────────────────────────┘

KNOWLEDGE
├── TECHNIQUE
│   ├── Shot
│   │   ├── Draw Shot
│   │   ├── Follow Shot
│   │   ├── Stun Shot
│   │   ├── Jump Shot
│   │   ├── Masse Shot
│   │   └── Legal Shot (Pool-specific)
│   ├── Stroke
│   │   ├── Power Stroke
│   │   ├── Precision Stroke
│   │   └── Safety Stroke
│   ├── Spin
│   │   ├── Backspin (Draw)
│   │   ├── Topspin (Follow)
│   │   ├── English (Sidespin)
│   │   └── Running English
│   ├── Position
│   │   ├── Position Play
│   │   └── Ghost Ball
│   └── Aim
│       ├── Contact Point
│       └── Object Ball Aiming
│
├── CONCEPT
│   ├── Rule
│   │   ├── Foul Rules
│   │   ├── Ball-in-Hand
│   │   ├── Jump Ball Rules
│   │   └── Safety Rules
│   ├── Pattern
│   │   ├── Pattern Running
│   │   └── Pattern Play
│   ├── Strategy
│   │   ├── Offensive Strategy
│   │   ├── Defensive Strategy
│   │   └── Safety Play
│   ├── Mistake
│   │   ├── Scooping
│   │   ├── Misjudgment
│   │   └── Poor Position
│   └── Mental
│       ├── Focus
│       ├── Pressure
│       └── Visualization
│
├── EQUIPMENT
│   ├── Cue
│   │   ├── One-Piece Cue
│   │   ├── Two-Piece Cue
│   │   └── Jump Cue
│   ├── Shaft
│   │   ├── Maple Shaft
│   │   ├── Ash Shaft
│   │   └── Carbon Fiber Shaft
│   ├── Tip
│   │   ├── Leather Tip
│   │   ├── Layered Tip
│   │   └── Hard Tip
│   ├── Ball
│   │   ├── Cue Ball
│   │   ├── Object Balls
│   │   └── Scratch Ball
│   ├── Table
│   │   ├── Pocket Size
│   │   ├── Cushion Type
│   │   └── Cloth Type
│   └── Accessory
│       ├── Chalk
│       ├── Bridge
│       └── Rack
│
├── TRAINING
│   ├── Drill
│   │   ├── Basic Drill
│   │   ├── Intermediate Drill
│   │   └── Advanced Drill
│   ├── Exercise
│   │   ├── Warm-up Exercise
│   │   └── Practice Exercise
│   ├── Training Plan
│   │   ├── 30-Day Plan
│   │   └── Progressive Plan
│   └── Scenario
│       ├── Common Scenario
│       └── Tournament Scenario
│
├── PHYSICS
│   ├── Math
│   │   ├── Angle Calculation
│   │   ├── Speed Physics
│   │   └── Spin Transfer
│   └── Mechanics
│       ├── Cue Action
│       └── Ball Collision
│
├── ORGANIZATION
│   ├── Tournament
│   │   ├── World Championship
│   │   ├── Regional Tournament
│   │   └── Local Tournament
│   ├── Player
│   │   ├── Professional Player
│   │   └── Amateur Player
│   ├── Organization
│   │   ├── WPA
│   │   ├── IBSA
│   │   └── WPBA
│   └── Coach
│       ├── Certified Coach
│       └── Master Coach
│
├── MEDIA
│   ├── Video
│   │   ├── Tutorial Video
│   │   ├── Analysis Video
│   │   └── Match Video
│   ├── Animation
│   │   ├── Stroke Animation
│   │   └── Ball Path Animation
│   ├── Image
│   │   ├── Diagram
│   │   ├── Photo
│   │   └── Illustration
│   ├── Article
│   │   ├── Technical Article
│   │   └── History Article
│   └── Book
│       ├── Instruction Book
│       └── History Book
│
├── KNOWLEDGE
│   ├── Question
│   │   ├── Definition Question
│   │   ├── Practical Question
│   │   └── Quiz Question
│   ├── Answer
│   │   └── Explanation
│   └── AI Prompt
│       ├── Coaching Prompt
│       └── Analysis Prompt
│
└── GAME VARIANTS
    ├── Pool
    │   ├── 8-Ball
    │   ├── 9-Ball
    │   └── 10-Ball
    ├── Snooker
    ├── Carom
    │   ├── Three-Cushion
    │   └── Straight Rail
    └── Chinese Eight Ball
```

### 2.2 Node Schema

Every node MUST contain these base fields:

```json
{
  "id": "uuid-v4",
  "type": "shot | technique | equipment | rule | drill | etc.",
  "subtype": "optional-specific-type",
  
  "slug": "kebab-case-unique-identifier",
  "status": "draft | review | published | deprecated",
  "version": "1.0.0",
  
  "language": {
    "primary": "en | vi",
    "supported": ["en", "vi"]
  },
  
  "names": {
    "en": { "value": "English Name", "pronunciation": "phonetic" },
    "vi": { "value": "Tên Tiếng Việt", "pronunciation": "phiên âm" }
  },
  
  "descriptions": {
    "en": {
      "short": "Brief description (50-100 chars)",
      "full": "Complete detailed description"
    },
    "vi": {
      "short": "Mô tả ngắn (50-100 ký tự)",
      "full": "Mô tả đầy đủ chi tiết"
    }
  },
  
  "difficulty": "beginner | intermediate | advanced | professional",
  "discipline": ["pool", "snooker", "carom", "chinese-eight-ball"],
  "category": ["shot", "spin", "stroke"],
  "tags": ["#english", "#vietnamese", "#coach"],
  
  "aliases": ["alias-one", "alias-two"],
  "related_terms": ["term-one", "term-two"],
  "synonyms": ["synonym-one"],
  "antonyms": ["antonym-one"],
  
  "prerequisites": ["prereq-one", "prereq-two"],
  "advanced_versions": ["advanced-one"],
  "beginner_versions": ["beginner-one"],
  
  "media": {
    "images": ["image-uuid-one"],
    "videos": ["video-uuid-one"],
    "animations": ["anim-uuid-one"]
  },
  
  "metadata": {
    "is_verified": true,
    "verified_by": "uuid",
    "verified_at": "ISO-8601",
    "contributors": ["uuid-one"]
  },
  
  "timestamps": {
    "created_at": "ISO-8601",
    "updated_at": "ISO-8601",
    "published_at": "ISO-8601"
  }
}
```

### 2.3 Node Type Examples

#### Shot Node

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440001",
  "type": "shot",
  "subtype": "spin-shot",
  "slug": "draw-shot",
  "status": "published",
  "version": "1.0.0",
  
  "names": {
    "en": { "value": "Draw Shot", "pronunciation": "/drɔː ʃɒt/" },
    "vi": { "value": "Đường Cắt Đít", "pronunciation": "/ɗɨ̛əŋ ɓät ɗit/" }
  },
  
  "descriptions": {
    "en": {
      "short": "A shot using backspin to bring the cue ball back after contact",
      "full": "A draw shot (also called a 'screw shot') is executed by striking the cue ball below center with a forward-follow-through motion. The backspin causes the cue ball to reverse direction after contacting the object ball, returning toward the player."
    },
    "vi": {
      "short": "Đòn đánh tạo lực ngược khiến bi cái quay về sau khi chạm bi mục tiêu",
      "full": "Đường cắt đít (còn gọi là screw shot) được thực hiện bằng cách đánh vào phần dưới tâm bi cái với chuyển động đẩy về phía trước. Lực ngược khiến bi cái quay ngược lại sau khi chạm bi mục tiêu."
    }
  },
  
  "difficulty": "intermediate",
  "discipline": ["pool", "snooker"],
  "tags": ["#spin", "#english", "#intermediate"],
  "aliases": ["screw-shot", "pull-shot", "cắt đít"],
  
  "prerequisites": ["stop-shot"],
  "advanced_versions": ["power-draw", "running-draw", "masse-draw"]
}
```

#### Equipment Node

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440010",
  "type": "equipment",
  "subtype": "cue-component",
  "slug": "cue-tip",
  "status": "published",
  "version": "1.0.0",
  
  "names": {
    "en": { "value": "Cue Tip", "pronunciation": "/kjuː tɪp/" },
    "vi": { "value": "Đầu Gậy", "pronunciation": "/ɗɐ̛u ɣɯy/" }
  },
  
  "descriptions": {
    "en": {
      "short": "The leather tip at the end of the cue shaft",
      "full": "The cue tip is the leather piece attached to the ferrule at the front of the cue. It contacts the cue ball and is responsible for applying spin, controlling deflection, and affecting ball action."
    }
  },
  
  "difficulty": "beginner",
  "discipline": ["pool", "snooker", "carom", "chinese-eight-ball"],
  "tags": ["#equipment", "#beginner"],
  "aliases": ["tip", "leather-tip"]
}
```

---

## 3. Edge Types

### 3.1 Edge Type Definitions

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              EDGE TYPES                                      │
└─────────────────────────────────────────────────────────────────────────────┘

HIERARCHICAL (IS_A Family)
├── IS_A              → Classification relationship
├── PART_OF           → Component relationship  
├── SAME_AS           → Equivalence (with aliases)
├── SYNONYM           → Alternative naming
└── ANTONYM           → Opposite meaning

DEPENDENCY (REQUIRES Family)
├── USES              → Technique requires component
├── REQUIRES          → Prerequisite relationship
├── CAUSES            → Action produces result
├── PREVENTS          → Action avoids problem
└── CORRECTED_BY      → Error has correction

PROGRESSION (LEVEL Family)
├── LEADS_TO          → Sequential progression
├── NEXT_LEVEL        → Difficulty progression
├── ADVANCED_VERSION  → Advanced form
├── BEGINNER_VERSION  → Basic form
└── TRAINED_BY        → Learning path

ASSOCIATION (RELATED Family)
├── RELATED_TO        → Loose connection
├── OPPOSITE_OF       → Contrast relationship
├── SAME_AS           → Identical concept
├── CONFUSES_WITH     → Common confusion
└── DISTINGUISHED_FROM → Formal difference

CONTAINER (CONTAINS Family)
├── CONTAINS          → Aggregate relationship
├── COMPOSED_OF       → Material relationship
└── APPLICABLE_TO     → Rule/principle applies

EVALUATION (PRIORITY Family)
├── MORE_IMPORTANT_THAN → Priority relationship
├── LESS_IMPORTANT_THAN → Inverse priority
├── RECOMMENDED_FOR   → Suggestion relationship
└── NOT_RECOMMENDED_FOR → Warning relationship

MEDIA (SHOWS Family)
├── VIDEO_EXPLAINS    → Video content relationship
├── IMAGE_SHOWS       → Image content relationship
├── ANIMATION_SHOWS   → Animation content relationship
└── ARTICLE_EXPLAINS → Article content relationship

PROVENANCE (AUTHORSHIP Family)
├── INVENTED_BY       → Origin relationship
├── POPULARIZED_BY    → Fame relationship
├── TAUGHT_BY         → Teaching attribution
└── DOCUMENTED_BY    → Source attribution

CONTEXT (USAGE Family)
├── USED_IN           → Application context
├── APPLIES_TO        → Scope relationship
├── RULE_APPLIES      → Rule scope
└── COMMON_ERROR      → Error association
```

### 3.2 Edge Metadata Schema

Every edge MUST include:

```json
{
  "id": "uuid-v4",
  
  "source_id": "uuid-of-source-node",
  "target_id": "uuid-of-target-node",
  "edge_type": "USES | REQUIRES | RELATED_TO | etc.",
  
  "direction": "forward | backward | bidirectional",
  "is_directional": true,
  
  "metadata": {
    "strength": 0.95,
    "confidence": 0.90,
    "priority": 1,
    "description": "Detailed relationship description",
    "examples": ["Example usage"],
    "exceptions": ["When not to apply"]
  },
  
  "provenance": {
    "source": "source-uuid or external-reference",
    "source_type": "internal | external | ai_generated",
    "cited_by": "uuid",
    "is_verified": true
  },
  
  "constraints": {
    "min_depth": 0,
    "max_depth": null,
    "allow_cycles": false,
    "required_for_completion": false
  },
  
  "language": {
    "en": { "description": "English description" },
    "vi": { "description": "Mô tả tiếng Việt" }
  },
  
  "timestamps": {
    "created_at": "ISO-8601",
    "updated_at": "ISO-8601"
  }
}
```

### 3.3 Edge Type Specifications

#### USES

```yaml
Edge Type: USES
Definition: Source node utilizes target node in its execution
Inverse: USED_BY
Directional: Yes
Symmetric: No

Example:
  Draw Shot ──USES──► Backspin
  Backspin ──USED_BY──► Draw Shot

Metadata Fields:
  strength: 1.0 (required for execution)
  confidence: 1.0 (well-established)
  priority: 1 (critical relationship)

Usage Rules:
  - Target is a component or technique required by source
  - Source cannot function without target
  - Often used for techniques and their components
```

#### REQUIRES

```yaml
Edge Type: REQUIRES
Definition: Source node requires understanding/mastery of target node
Inverse: ENABLES
Directional: Yes
Symmetric: No

Example:
  Power Draw ──REQUIRES──► Basic Draw
  Basic Draw ──ENABLES──► Power Draw

Metadata Fields:
  strength: 0.95 (typically required)
  confidence: 0.85 (learning paths may vary)
  priority: 1 (critical for learning)

Usage Rules:
  - Target is a learning prerequisite
  - Source mastery depends on target mastery
  - Used for learning progressions
```

#### RELATED_TO

```yaml
Edge Type: RELATED_TO
Definition: Source node has loose semantic connection to target node
Inverse: RELATED_TO (self)
Directional: No
Symmetric: Yes

Example:
  Draw Shot ──RELATED_TO──► Stun Shot
  Stun Shot ──RELATED_TO──► Draw Shot

Metadata Fields:
  strength: 0.5-0.8 (variable)
  confidence: 0.7 (contextual)
  priority: 3 (suggested connections)

Usage Rules:
  - Loose association in same domain
  - Same category or similar context
  - Common co-occurrence in content
```

#### OPPOSITE_OF

```yaml
Edge Type: OPPOSITE_OF
Definition: Source node is the inverse or contrast of target node
Inverse: OPPOSITE_OF (self)
Directional: No
Symmetric: Yes

Example:
  Draw Shot ──OPPOSITE_OF──► Follow Shot
  Follow Shot ──OPPOSITE_OF──► Draw Shot

Metadata Fields:
  strength: 1.0 (mutually exclusive)
  confidence: 1.0 (established contrast)
  priority: 1 (critical for understanding)

Usage Rules:
  - Source and target are contrasting concepts
  - Understanding one helps understand the other
  - Cannot be applied simultaneously
```

#### LEADS_TO

```yaml
Edge Type: LEADS_TO
Definition: Source node naturally progresses to target node
Inverse: PRECEDED_BY
Directional: Yes
Symmetric: No

Example:
  Stop Shot ──LEADS_TO──► Draw Shot
  Draw Shot ──PRECEDED_BY──► Stop Shot

Metadata Fields:
  strength: 0.9 (common progression)
  confidence: 0.8 (natural but not mandatory)
  priority: 2 (recommended path)

Usage Rules:
  - Typical next step in learning
  - Natural skill development sequence
  - Common application order
```

#### TRAINED_BY

```yaml
Edge Type: TRAINED_BY
Definition: Source skill is developed through target drill/exercise
Inverse: TRAINS
Directional: Yes
Symmetric: No

Example:
  Draw Shot ──TRAINED_BY──► Drill-013
  Drill-013 ──TRAINS──► Draw Shot

Metadata Fields:
  strength: 0.95 (effective training)
  confidence: 0.9 (verified training method)
  priority: 1 (primary training)

Usage Rules:
  - Target is a practice drill or exercise
  - Source is the skill being trained
  - Links skills to specific training methods
```

#### COMMON_ERROR

```yaml
Edge Type: COMMON_ERROR
Definition: Source node is frequently misunderstood or misapplied as target
Inverse: CAN_BE_CONFUSED_WITH
Directional: No
Symmetric: Yes

Example:
  Draw Shot ──COMMON_ERROR──► Scooping
  Scooping ──COMMON_ERROR──► Draw Shot

Metadata Fields:
  strength: 0.7 (common mistake frequency)
  confidence: 0.95 (well-documented error)
  priority: 1 (must address)

Usage Rules:
  - Target is a frequent mistake
  - Source is what gets done wrong
  - Used for error prevention content
```

#### CORRECTED_BY

```yaml
Edge Type: CORRECTED_BY
Definition: Source error/mistake is fixed by target technique
Inverse: CORRECTS
Directional: Yes
Symmetric: No

Example:
  Scooping ──CORRECTED_BY──► Proper Follow-Through
  Proper Follow-Through ──CORRECTS──► Scooping

Metadata Fields:
  strength: 0.9 (effective correction)
  confidence: 0.9 (proven fix)
  priority: 1 (essential fix)

Usage Rules:
  - Target is the correction method
  - Source is the problem being fixed
  - Links errors to solutions
```

#### NEXT_LEVEL

```yaml
Edge Type: NEXT_LEVEL
Definition: Source node is the next difficulty tier of target
Inverse: PREVIOUS_LEVEL
Directional: Yes
Symmetric: No

Example:
  Basic Draw ──NEXT_LEVEL──► Intermediate Draw
  Intermediate Draw ──NEXT_LEVEL──► Advanced Draw

Metadata Fields:
  strength: 1.0 (level progression)
  confidence: 1.0 (defined levels)
  priority: 1 (mandatory progression)

Usage Rules:
  - Target is the next difficulty level
  - Same fundamental concept, increased complexity
  - Creates structured skill ladders
```

#### ADVANCED_VERSION

```yaml
Edge Type: ADVANCED_VERSION
Definition: Source node is the advanced form of target
Inverse: BEGINNER_VERSION
Directional: Yes
Symmetric: No

Example:
  Basic Draw ──ADVANCED_VERSION──► Power Draw
  Power Draw ──BEGINNER_VERSION──► Basic Draw

Metadata Fields:
  strength: 1.0 (version relationship)
  confidence: 1.0 (defined versions)
  priority: 1 (natural progression)

Usage Rules:
  - Target is the simpler/older version
  - Source adds complexity or refinement
  - Same fundamental concept, enhanced
```

#### VIDEO_EXPLAINS

```yaml
Edge Type: VIDEO_EXPLAINS
Definition: Target video demonstrates or explains source concept
Inverse: EXPLAINED_IN_VIDEO
Directional: Yes
Symmetric: No

Example:
  Draw Shot ──VIDEO_EXPLAINS──► video-uuid-001
  video-uuid-001 ──EXPLAINED_IN_VIDEO──► Draw Shot

Metadata Fields:
  strength: 0.9 (comprehensive coverage)
  confidence: 1.0 (direct content match)
  priority: 1 (primary media)

Usage Rules:
  - Target is video content
  - Source is the explained concept
  - Links concepts to visual media
```

#### IMAGE_SHOWS

```yaml
Edge Type: IMAGE_SHOWS
Definition: Target image demonstrates source concept
Inverse: SHOWN_IN_IMAGE
Directional: Yes
Symmetric: No

Example:
  Bridge Position ──IMAGE_SHOWS──► image-uuid-001
  image-uuid-001 ──SHOWN_IN_IMAGE──► Bridge Position

Metadata Fields:
  strength: 0.85 (demonstrates concept)
  confidence: 1.0 (direct visual)
  priority: 2 (supporting media)

Usage Rules:
  - Target is image content
  - Source is the shown concept
  - Links concepts to static visuals
```

#### RULE_APPLIES

```yaml
Edge Type: RULE_APPLIES
Definition: Source rule applies to target game situation/concept
Inverse: GOVERNS
Directional: Yes
Symmetric: No

Example:
  Foul Rule ──RULE_APPLIES──► Ball-in-Hand
  Ball-in-Hand ──GOVERNS──► Foul Rule

Metadata Fields:
  strength: 1.0 (rule mandate)
  confidence: 1.0 (official rule)
  priority: 1 (binding)

Usage Rules:
  - Target is a game situation
  - Source is the governing rule
  - Links rules to applications
```

#### MORE_IMPORTANT_THAN

```yaml
Edge Type: MORE_IMPORTANT_THAN
Definition: Source node has higher priority/importance than target
Inverse: LESS_IMPORTANT_THAN
Directional: Yes
Symmetric: No

Example:
  Position Play ──MORE_IMPORTANT_THAN──► Power
  Power ──LESS_IMPORTANT_THAN──► Position Play

Metadata Fields:
  strength: 0.8 (relative importance)
  confidence: 0.75 (varies by context)
  priority: 2 (guidance, not absolute)

Usage Rules:
  - Target is lower priority
  - Used for teaching priorities
  - Context-dependent importance
```

#### USED_IN

```yaml
Edge Type: USED_IN
Definition: Source concept is applied in target discipline/game
Inverse: USES_CONCEPT
Directional: Yes
Symmetric: No

Example:
  Draw Shot ──USED_IN──► 8-Ball Pool
  8-Ball Pool ──USES_CONCEPT──► Draw Shot

Metadata Fields:
  strength: 0.95 (core application)
  confidence: 1.0 (established use)
  priority: 1 (primary context)

Usage Rules:
  - Target is the application domain
  - Source is used within target context
  - Cross-discipline connections
```

#### INVENTED_BY

```yaml
Edge Type: INVENTED_BY
Definition: Source technique was invented by target person/organization
Inverse: INVENTED
Directional: Yes
Symmetric: No

Example:
  The 90-Degree Rule ──INVENTED_BY──► Robert Byrne
  Robert Byrne ──INVENTED──► The 90-Degree Rule

Metadata Fields:
  strength: 1.0 (historical fact)
  confidence: 1.0 (documented history)
  priority: 3 (historical context)

Usage Rules:
  - Target is the originator
  - Source is the invention
  - Historical/provenance tracking
```

#### POPULARIZED_BY

```yaml
Edge Type: POPULARIZED_BY
Definition: Source concept became well-known through target
Inverse: POPULARIZED
Directional: Yes
Symmetric: No

Example:
  Modern Draw Technique ──POPULARIZED_BY──► Ronnie O'Sullivan
  Ronnie O'Sullivan ──POPULARIZED──► Modern Draw Technique

Metadata Fields:
  strength: 0.9 (significant influence)
  confidence: 0.85 (attribution may vary)
  priority: 3 (historical context)

Usage Rules:
  - Target popularized the concept
  - Source gained fame through target
  - Attribution and influence tracking
```

---

## 4. Complete Edge Type Matrix

| Edge Type | Inverse | Directional | Symmetric | Strength | Priority | Description |
|-----------|---------|-------------|-----------|----------|----------|-------------|
| `IS_A` | (self) | No | Yes | 1.0 | 1 | Classification |
| `PART_OF` | `CONTAINS` | Yes | No | 1.0 | 1 | Component |
| `SAME_AS` | (self) | No | Yes | 1.0 | 1 | Equivalence |
| `SYNONYM` | (self) | No | Yes | 1.0 | 2 | Alternative name |
| `ANTONYM` | (self) | No | Yes | 1.0 | 2 | Opposite |
| `USES` | `USED_BY` | Yes | No | 1.0 | 1 | Component usage |
| `REQUIRES` | `ENABLES` | Yes | No | 0.95 | 1 | Prerequisite |
| `CAUSES` | `CAUSED_BY` | Yes | No | 0.9 | 2 | Result |
| `PREVENTS` | `PREVENTED_BY` | Yes | No | 0.9 | 2 | Avoidance |
| `CORRECTED_BY` | `CORRECTS` | Yes | No | 0.9 | 1 | Fix |
| `LEADS_TO` | `PRECEDED_BY` | Yes | No | 0.9 | 2 | Progression |
| `NEXT_LEVEL` | `PREVIOUS_LEVEL` | Yes | No | 1.0 | 1 | Difficulty |
| `ADVANCED_VERSION` | `BEGINNER_VERSION` | Yes | No | 1.0 | 1 | Version |
| `TRAINED_BY` | `TRAINS` | Yes | No | 0.95 | 1 | Training |
| `RELATED_TO` | (self) | No | Yes | 0.5-0.8 | 3 | Loose link |
| `OPPOSITE_OF` | (self) | No | Yes | 1.0 | 1 | Contrast |
| `CONFUSES_WITH` | (self) | No | Yes | 0.7 | 2 | Confusion |
| `DISTINGUISHED_FROM` | (self) | No | Yes | 0.8 | 2 | Difference |
| `CONTAINS` | `PART_OF` | Yes | No | 1.0 | 1 | Aggregate |
| `COMPOSED_OF` | `COMPOSES` | Yes | No | 1.0 | 1 | Material |
| `APPLICABLE_TO` | `APPLIES` | Yes | No | 1.0 | 1 | Scope |
| `MORE_IMPORTANT_THAN` | `LESS_IMPORTANT_THAN` | Yes | No | 0.8 | 3 | Priority |
| `RECOMMENDED_FOR` | `RECOMMENDED_BY` | Yes | No | 0.8 | 2 | Suggestion |
| `NOT_RECOMMENDED_FOR` | `NOT_RECOMMENDED_BY` | Yes | No | 0.8 | 2 | Warning |
| `VIDEO_EXPLAINS` | `EXPLAINED_IN_VIDEO` | Yes | No | 0.9 | 1 | Media |
| `IMAGE_SHOWS` | `SHOWN_IN_IMAGE` | Yes | No | 0.85 | 2 | Media |
| `ANIMATION_SHOWS` | `SHOWN_IN_ANIMATION` | Yes | No | 0.85 | 2 | Media |
| `ARTICLE_EXPLAINS` | `EXPLAINED_IN_ARTICLE` | Yes | No | 0.85 | 2 | Media |
| `INVENTED_BY` | `INVENTED` | Yes | No | 1.0 | 3 | Origin |
| `POPULARIZED_BY` | `POPULARIZED` | Yes | No | 0.9 | 3 | Fame |
| `TAUGHT_BY` | `TEACHES` | Yes | No | 0.9 | 2 | Teaching |
| `DOCUMENTED_BY` | `DOCUMENTS` | Yes | No | 0.85 | 3 | Source |
| `USED_IN` | `USES_CONCEPT` | Yes | No | 0.95 | 1 | Context |
| `RULE_APPLIES` | `GOVERNS` | Yes | No | 1.0 | 1 | Rule scope |
| `COMMON_ERROR` | (self) | No | Yes | 0.7 | 1 | Mistake |

---

## 5. Graph Examples

### 5.1 Draw Shot Knowledge Graph

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           DRAW SHOT KNOWLEDGE GRAPH                          │
└─────────────────────────────────────────────────────────────────────────────┘

                              ┌─────────────┐
                              │  DRAW SHOT  │
                              │   (Node)    │
                              └──────┬──────┘
                                     │
     ┌───────────────────────────────┼───────────────────────────────┐
     │                               │                               │
     ▼                               ▼                               ▼
┌───────────┐                 ┌───────────┐                 ┌───────────┐
│   USES    │                 │  OPPOSITE │                 │PREREQUISITE│
│ Backspin  │                 │Follow Shot│                 │ Stop Shot  │
└─────┬─────┘                 └───────────┘                 └─────┬─────┘
      │                                                       │
      ▼                                                       ▼
┌───────────┐                   ┌───────────┐           ┌───────────┐
│  USES     │                   │LEADS_TO   │           │LEADS_TO   │
│Low Contact│                   │Power Draw │           │Stun Shot  │
└─────┬─────┘                   └───────────┘           └───────────┘
      │
      ▼
┌───────────┐                 ┌───────────┐           ┌───────────┐
│  PART_OF  │                 │TRAINED_BY │           │NEXT_LEVEL │
│Spin Tech  │                 │ Drill-013 │           │Int. Draw  │
└───────────┘                 └───────────┘           └───────────┘
                                     │
                                     ▼
                              ┌───────────┐
                              │NEXT_LEVEL │
                              │Adv. Drill │
                              └───────────┘

RELATIONSHIP EDGES (with metadata):
─────────────────────────────────────────────────────────────────────────────
Draw Shot ──USES──► Backspin [strength: 1.0, priority: 1]
Draw Shot ──USES──► Low Cue Contact [strength: 1.0, priority: 1]
Draw Shot ──OPPOSITE_OF──► Follow Shot [strength: 1.0, priority: 1]
Draw Shot ──PREREQUISITE──► Stop Shot [strength: 0.95, priority: 1]
Draw Shot ──LEADS_TO──► Power Draw [strength: 0.9, priority: 2]
Draw Shot ──LEADS_TO──► Stun Shot [strength: 0.8, priority: 2]
Draw Shot ──TRAINED_BY──► Drill-013 [strength: 0.95, priority: 1]
Draw Shot ──NEXT_LEVEL──► Intermediate Draw [strength: 1.0, priority: 1]
Draw Shot ──PART_OF──► Spin Techniques [strength: 1.0, priority: 1]
Draw Shot ──COMMON_ERROR──► Scooping [strength: 0.7, priority: 1]
Draw Shot ──VIDEO_EXPLAINS──► [video-uuid-001] [strength: 0.9]
```

### 5.2 Complete Relationship JSON

```json
{
  "node": {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "slug": "draw-shot",
    "names": { "en": "Draw Shot", "vi": "Đường Cắt Đít" }
  },
  
  "edges": [
    {
      "id": "edge-001",
      "source_id": "550e8400-e29b-41d4-a716-446655440001",
      "target_id": "550e8400-e29b-41d4-a716-446655440100",
      "edge_type": "USES",
      "direction": "forward",
      "metadata": {
        "strength": 1.0,
        "confidence": 1.0,
        "priority": 1,
        "description": "Draw shot requires applying backspin to the cue ball",
        "examples": ["Apply 1/4 tip of backspin", "Match spin to shot power"],
        "exceptions": ["Minimal draw for short distances"]
      },
      "provenance": {
        "source": "internal",
        "source_type": "internal",
        "is_verified": true
      },
      "language": {
        "en": { "description": "Draw shot requires applying backspin to the cue ball" },
        "vi": { "description": "Đường cắt đít yêu cầu tạo lực ngược trên bi cái" }
      },
      "timestamps": {
        "created_at": "2026-07-01T00:00:00Z",
        "updated_at": "2026-07-17T10:00:00Z"
      }
    },
    {
      "id": "edge-002",
      "source_id": "550e8400-e29b-41d4-a716-446655440001",
      "target_id": "550e8400-e29b-41d4-a716-446655440200",
      "edge_type": "OPPOSITE_OF",
      "direction": "bidirectional",
      "metadata": {
        "strength": 1.0,
        "confidence": 1.0,
        "priority": 1,
        "description": "Draw applies backspin; follow applies topspin",
        "examples": ["Draw = backspin, Follow = topspin"],
        "exceptions": []
      },
      "provenance": {
        "source": "internal",
        "source_type": "internal",
        "is_verified": true
      },
      "language": {
        "en": { "description": "Draw applies backspin; follow applies topspin" },
        "vi": { "description": "Cắt đít tạo lực ngược; theo đít tạo lực xuôi" }
      },
      "timestamps": {
        "created_at": "2026-07-01T00:00:00Z",
        "updated_at": "2026-07-17T10:00:00Z"
      }
    },
    {
      "id": "edge-003",
      "source_id": "550e8400-e29b-41d4-a716-446655440001",
      "target_id": "550e8400-e29b-41d4-a716-446655440300",
      "edge_type": "PREREQUISITE",
      "direction": "forward",
      "metadata": {
        "strength": 0.95,
        "confidence": 0.9,
        "priority": 1,
        "description": "Must master stop shot before learning draw",
        "examples": ["Practice stop shots for 1 week"],
        "exceptions": ["Natural talent may progress faster"]
      },
      "provenance": {
        "source": "internal",
        "source_type": "internal",
        "is_verified": true
      },
      "language": {
        "en": { "description": "Must master stop shot before learning draw" },
        "vi": { "description": "Phải thành thạo đường dừng trước khi học cắt đít" }
      },
      "timestamps": {
        "created_at": "2026-07-01T00:00:00Z",
        "updated_at": "2026-07-17T10:00:00Z"
      }
    },
    {
      "id": "edge-004",
      "source_id": "550e8400-e29b-41d4-a716-446655440001",
      "target_id": "550e8400-e29b-41d4-a716-446655440400",
      "edge_type": "LEADS_TO",
      "direction": "forward",
      "metadata": {
        "strength": 0.9,
        "confidence": 0.85,
        "priority": 2,
        "description": "Natural progression to power draw",
        "examples": ["After 2 months of practice"],
        "exceptions": ["Some players skip to other techniques"]
      },
      "provenance": {
        "source": "internal",
        "source_type": "internal",
        "is_verified": true
      },
      "language": {
        "en": { "description": "Natural progression to power draw" },
        "vi": { "description": "Phát triển tự nhiên sang cắt đít mạnh" }
      },
      "timestamps": {
        "created_at": "2026-07-01T00:00:00Z",
        "updated_at": "2026-07-17T10:00:00Z"
      }
    },
    {
      "id": "edge-005",
      "source_id": "550e8400-e29b-41d4-a716-446655440001",
      "target_id": "550e8400-e29b-41d4-a716-446655440500",
      "edge_type": "TRAINED_BY",
      "direction": "forward",
      "metadata": {
        "strength": 0.95,
        "confidence": 0.9,
        "priority": 1,
        "description": "Effective training drill for draw shot",
        "examples": ["Practice 20 minutes daily"],
        "exceptions": ["Needs proper equipment"]
      },
      "provenance": {
        "source": "drill-013",
        "source_type": "internal",
        "is_verified": true
      },
      "language": {
        "en": { "description": "Effective training drill for draw shot" },
        "vi": { "description": "Bài tập hiệu quả cho đường cắt đít" }
      },
      "timestamps": {
        "created_at": "2026-07-01T00:00:00Z",
        "updated_at": "2026-07-17T10:00:00Z"
      }
    },
    {
      "id": "edge-006",
      "source_id": "550e8400-e29b-41d4-a716-446655440001",
      "target_id": "550e8400-e29b-41d4-a716-446655440600",
      "edge_type": "COMMON_ERROR",
      "direction": "bidirectional",
      "metadata": {
        "strength": 0.7,
        "confidence": 0.95,
        "priority": 1,
        "description": "Scooping is a common draw shot error",
        "examples": ["Jerking the cue upward"],
        "exceptions": []
      },
      "provenance": {
        "source": "internal",
        "source_type": "internal",
        "is_verified": true
      },
      "language": {
        "en": { "description": "Scooping is a common draw shot error" },
        "vi": { "description": "Múc là lỗi phổ biến khi đánh cắt đít" }
      },
      "timestamps": {
        "created_at": "2026-07-01T00:00:00Z",
        "updated_at": "2026-07-17T10:00:00Z"
      }
    },
    {
      "id": "edge-007",
      "source_id": "550e8400-e29b-41d4-a716-446655440001",
      "target_id": "550e8400-e29b-41d4-a716-446655440700",
      "edge_type": "NEXT_LEVEL",
      "direction": "forward",
      "metadata": {
        "strength": 1.0,
        "confidence": 1.0,
        "priority": 1,
        "description": "Intermediate level draw shot",
        "examples": ["After mastering basic draw"],
        "exceptions": []
      },
      "provenance": {
        "source": "internal",
        "source_type": "internal",
        "is_verified": true
      },
      "language": {
        "en": { "description": "Intermediate level draw shot" },
        "vi": { "description": "Cấp độ trung gian của đường cắt đít" }
      },
      "timestamps": {
        "created_at": "2026-07-01T00:00:00Z",
        "updated_at": "2026-07-17T10:00:00Z"
      }
    },
    {
      "id": "edge-008",
      "source_id": "550e8400-e29b-41d4-a716-446655440001",
      "target_id": "video-uuid-001",
      "edge_type": "VIDEO_EXPLAINS",
      "direction": "forward",
      "metadata": {
        "strength": 0.9,
        "confidence": 1.0,
        "priority": 1,
        "description": "Complete video tutorial on draw shot technique",
        "examples": ["Watch and practice along"],
        "exceptions": ["Requires video player"]
      },
      "provenance": {
        "source": "video-content-001",
        "source_type": "internal",
        "is_verified": true
      },
      "language": {
        "en": { "description": "Complete video tutorial on draw shot technique" },
        "vi": { "description": "Hướng dẫn video đầy đủ về kỹ thuật cắt đít" }
      },
      "timestamps": {
        "created_at": "2026-07-01T00:00:00Z",
        "updated_at": "2026-07-17T10:00:00Z"
      }
    }
  ]
}
```

### 5.3 Learning Path Graph

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        DRAW SHOT LEARNING PATH                               │
└─────────────────────────────────────────────────────────────────────────────┘

LEVEL 1 (Beginner)
─────────────────
    
    ┌─────────────┐
    │  STOP SHOT  │ ◄── ENTRY POINT
    └──────┬──────┘
           │ PREREQUISITE [strength: 0.95]
           ▼
    ┌─────────────┐
    │  STUN SHOT  │
    └──────┬──────┘
           │ LEADS_TO [strength: 0.9]
           ▼
    ┌─────────────┐
    │  BASIC DRAW│ ◄── LEARN DRAW SHOT
    └──────┬──────┘
           │ NEXT_LEVEL [strength: 1.0]
           ▼
    ┌─────────────┐
    │INTERMEDIATE │
    │    DRAW    │
    └──────┬──────┘
           │ NEXT_LEVEL [strength: 1.0]
           ▼
    ┌─────────────┐
    │  POWER DRAW │
    └──────┬──────┘
           │ ADVANCED_VERSION [strength: 1.0]
           ▼
    ┌─────────────┐
    │  RUNNING    │
    │    DRAW     │
    └──────┬──────┘
           │ ADVANCED_VERSION [strength: 0.9]
           ▼
    ┌─────────────┐
    │   MASSE     │
    │    DRAW     │ ◄── EXPERT LEVEL
    └─────────────┘


TRAINING DRILLS (linked via TRAINED_BY):
─────────────────────────────────────────
    Stop Shot      ──TRAINED_BY──► Drill-001: Stop Ball Practice
    Stun Shot      ──TRAINED_BY──► Drill-002: Stun Ball Practice
    Basic Draw     ──TRAINED_BY──► Drill-003: Basic Draw
    Intermediate   ──TRAINED_BY──► Drill-010: Distance Draw
    Power Draw     ──TRAINED_BY──► Drill-015: Power Draw
    Running Draw   ──TRAINED_BY──► Drill-020: Running Draw
    Masse Draw     ──TRAINED_BY──► Drill-025: Masse Technique
```

### 5.4 Error Correction Graph

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        ERROR CORRECTION GRAPH                               │
└─────────────────────────────────────────────────────────────────────────────┘

COMMON ERRORS                    CORRECTIONS
─────────────────────────────────────────────────────────────────────────────
    │
    ▼
┌───────────────┐
│   SCOOPING    │ ◄── COMMON_ERROR (Draw Shot)
└───────┬───────┘
        │ CORRECTED_BY [strength: 0.9]
        ▼
┌───────────────┐
│  PROPER       │
│  FOLLOW-THROUGH│
└───────┬───────┘
        │ ENABLES [strength: 0.95]
        ▼
┌───────────────┐
│  CLEAN TIP   │
│  CONTACT     │
└───────┬───────┘
        │
        ▼
┌───────────────┐
│   SUCCESSFUL  │
│   DRAW SHOT   │
└───────────────┘


ERROR CHAINS:
─────────────────────────────────────────────────────────────────────────────
Misjudge Distance ──COMMON_ERROR──► Pull Shot ──CORRECTED_BY──► Tip Control
Misjudge Distance ──COMMON_ERROR──► Squirt ──CORRECTED_BY──► Bridge Distance
Poor Position    ──COMMON_ERROR──► Rushed Shot ──CORRECTED_BY──► Pre-Shot Routine
```

---

## 6. Database Schema

### 6.1 Node Table

```sql
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
    prerequisites   JSONB DEFAULT '[]',
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
    CONSTRAINT valid_type CHECK (type IN (
        'technique', 'shot', 'stroke', 'spin', 'position',
        'equipment', 'cue', 'shaft', 'tip', 'ball', 'table',
        'rule', 'pattern', 'strategy', 'mistake', 'mental',
        'drill', 'exercise', 'training_plan', 'scenario',
        'tournament', 'player', 'organization', 'coach',
        'video', 'animation', 'image', 'article', 'book',
        'question', 'answer', 'ai_prompt', 'physics', 'math',
        'variant'
    )),
    CONSTRAINT valid_status CHECK (status IN (
        'draft', 'review', 'published', 'deprecated'
    )),
    CONSTRAINT valid_difficulty CHECK (difficulty IN (
        'beginner', 'intermediate', 'advanced', 'professional'
    ))
);

-- Indexes
CREATE INDEX idx_nodes_type ON nodes(type);
CREATE INDEX idx_nodes_slug ON nodes(slug);
CREATE INDEX idx_nodes_status ON nodes(status);
CREATE INDEX idx_nodes_difficulty ON nodes(difficulty);
CREATE INDEX idx_nodes_discipline ON nodes USING GIN(discipline);
CREATE INDEX idx_nodes_tags ON nodes USING GIN(tags);
CREATE INDEX idx_nodes_names ON nodes USING GIN(names);
CREATE INDEX idx_nodes_created ON nodes(created_at);
CREATE INDEX idx_nodes_updated ON nodes(updated_at);
```

### 6.2 Edge Table

```sql
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
        'IS_A', 'PART_OF', 'SAME_AS', 'SYNONYM', 'ANTONYM',
        'USES', 'USED_BY', 'REQUIRES', 'ENABLES',
        'CAUSES', 'CAUSED_BY', 'PREVENTS', 'PREVENTED_BY', 'CORRECTED_BY', 'CORRECTS',
        'LEADS_TO', 'PRECEDED_BY', 'NEXT_LEVEL', 'PREVIOUS_LEVEL',
        'ADVANCED_VERSION', 'BEGINNER_VERSION',
        'TRAINED_BY', 'TRAINS',
        'RELATED_TO', 'OPPOSITE_OF', 'CONFUSES_WITH', 'DISTINGUISHED_FROM',
        'CONTAINS', 'COMPOSED_OF', 'COMPOSES',
        'MORE_IMPORTANT_THAN', 'LESS_IMPORTANT_THAN',
        'RECOMMENDED_FOR', 'RECOMMENDED_BY', 'NOT_RECOMMENDED_FOR', 'NOT_RECOMMENDED_BY',
        'VIDEO_EXPLAINS', 'EXPLAINED_IN_VIDEO',
        'IMAGE_SHOWS', 'SHOWN_IN_IMAGE',
        'ANIMATION_SHOWS', 'SHOWN_IN_ANIMATION',
        'ARTICLE_EXPLAINS', 'EXPLAINED_IN_ARTICLE',
        'INVENTED_BY', 'INVENTED', 'POPULARIZED_BY', 'POPULARIZED',
        'TAUGHT_BY', 'TEACHES', 'DOCUMENTED_BY', 'DOCUMENTS',
        'USED_IN', 'USES_CONCEPT', 'APPLICABLE_TO', 'APPLIES',
        'RULE_APPLIES', 'GOVERNS',
        'COMMON_ERROR'
    )),
    CONSTRAINT valid_direction CHECK (direction IN ('forward', 'backward', 'bidirectional')),
    CONSTRAINT valid_strength CHECK (strength >= 0 AND strength <= 1),
    CONSTRAINT valid_confidence CHECK (confidence >= 0 AND confidence <= 1)
);

-- Indexes
CREATE INDEX idx_edges_source ON edges(source_id);
CREATE INDEX idx_edges_target ON edges(target_id);
CREATE INDEX idx_edges_type ON edges(edge_type);
CREATE INDEX idx_edges_both ON edges(source_id, target_id);
CREATE INDEX idx_edges_strength ON edges(strength);
CREATE INDEX idx_edges_confidence ON edges(confidence);
CREATE INDEX idx_edges_priority ON edges(priority);
```

### 6.3 Graph Version Table

```sql
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
    
    CONSTRAINT valid_version_status CHECK (status IN (
        'draft', 'active', 'deprecated'
    ))
);

-- Link edges to specific versions
ALTER TABLE edges ADD COLUMN graph_version VARCHAR(20);
CREATE INDEX idx_edges_version ON edges(graph_version);
```

---

## 7. Validation Rules

### 7.1 Node Validation

```sql
-- Ensure node has required names
CREATE OR REPLACE FUNCTION validate_node_names()
RETURNS TRIGGER AS $$
BEGIN
    -- Must have at least English name
    IF NOT (NEW.names ? 'en' AND NEW.names->'en'->>'value' IS NOT NULL) THEN
        RAISE EXCEPTION 'Node must have English name';
    END IF;
    
    -- English name cannot be empty
    IF TRIM(NEW.names->'en'->>'value') = '' THEN
        RAISE EXCEPTION 'English name cannot be empty';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER node_names_validation
BEFORE INSERT OR UPDATE ON nodes
FOR EACH ROW
EXECUTE FUNCTION validate_node_names();

-- Ensure unique slug per version
CREATE OR REPLACE FUNCTION validate_node_slug()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM nodes 
        WHERE slug = NEW.slug 
        AND version = NEW.version
        AND id != NEW.id
    ) THEN
        RAISE EXCEPTION 'Slug must be unique within version: %', NEW.slug;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER node_slug_validation
BEFORE INSERT OR UPDATE ON nodes
FOR EACH ROW
EXECUTE FUNCTION validate_node_slug();
```

### 7.2 Edge Validation

```sql
-- Prevent self-references
CREATE OR REPLACE FUNCTION validate_edge_self_reference()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.source_id = NEW.target_id THEN
        RAISE EXCEPTION 'Edge cannot connect a node to itself';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER edge_self_reference_validation
BEFORE INSERT OR UPDATE ON edges
FOR EACH ROW
EXECUTE FUNCTION validate_edge_self_reference();

-- Validate bidirectional edges
CREATE OR REPLACE FUNCTION validate_bidirectional_edge()
RETURNS TRIGGER AS $$
BEGIN
    -- For symmetric edge types, create reverse automatically
    IF NEW.edge_type IN ('OPPOSITE_OF', 'RELATED_TO', 'CONFUSES_WITH', 
                         'DISTINGUISHED_FROM', 'SYNONYM', 'SAME_AS', 'ANTONYM',
                         'COMMON_ERROR') THEN
        -- Check if reverse exists
        IF NOT EXISTS (
            SELECT 1 FROM edges 
            WHERE source_id = NEW.target_id 
            AND target_id = NEW.source_id 
            AND edge_type = NEW.edge_type
        ) THEN
            -- Insert reverse edge
            INSERT INTO edges (source_id, target_id, edge_type, direction, 
                             is_directional, strength, confidence, priority, metadata)
            VALUES (NEW.target_id, NEW.source_id, NEW.edge_type, 'bidirectional',
                   TRUE, NEW.strength, NEW.confidence, NEW.priority, NEW.metadata);
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER edge_bidirectional_sync
AFTER INSERT ON edges
FOR EACH ROW
EXECUTE FUNCTION validate_bidirectional_edge();

-- Cycle detection for directional edges
CREATE OR REPLACE FUNCTION would_create_cycle()
RETURNS TRIGGER AS $$
DECLARE
    v_has_cycle BOOLEAN;
BEGIN
    -- Only check for hierarchical edge types
    IF NEW.edge_type NOT IN ('REQUIRES', 'LEADS_TO', 'NEXT_LEVEL', 
                             'ADVANCED_VERSION', 'PREREQUISITE', 'PART_OF') THEN
        RETURN NEW;
    END IF;
    
    -- Check if adding this edge would create a cycle
    WITH RECURSIVE path AS (
        SELECT target_id, ARRAY[source_id] as path, 1 as depth
        FROM edges
        WHERE source_id = NEW.target_id
        AND edge_type IN ('REQUIRES', 'LEADS_TO', 'NEXT_LEVEL', 'ADVANCED_VERSION', 'PREREQUISITE', 'PART_OF')
        
        UNION ALL
        
        SELECT e.target_id, p.path || e.source_id, p.depth + 1
        FROM edges e
        JOIN path p ON e.source_id = p.target_id
        WHERE e.edge_type IN ('REQUIRES', 'LEADS_TO', 'NEXT_LEVEL', 'ADVANCED_VERSION', 'PREREQUISITE', 'PART_OF')
        AND NOT e.target_id = ANY(p.path)
        AND p.depth < 10
    )
    SELECT EXISTS (
        SELECT 1 FROM path WHERE target_id = NEW.source_id
    ) INTO v_has_cycle;
    
    IF v_has_cycle THEN
        RAISE EXCEPTION 'Adding this edge would create a cycle in the graph';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER edge_cycle_detection
BEFORE INSERT ON edges
FOR EACH ROW
EXECUTE FUNCTION would_create_cycle();
```

---

## 8. Graph Queries

### 8.1 Traversal Functions

#### Get All Related Nodes

```sql
CREATE OR REPLACE FUNCTION get_related_nodes(
    p_node_id UUID,
    p_edge_types TEXT[] DEFAULT NULL,
    p_min_strength DECIMAL DEFAULT 0.5,
    p_direction TEXT DEFAULT 'both'
)
RETURNS TABLE (
    node_id UUID,
    slug TEXT,
    names JSONB,
    edge_type VARCHAR(50),
    strength DECIMAL,
    confidence DECIMAL,
    direction VARCHAR(20)
) AS $$
BEGIN
    RETURN QUERY
    -- Forward edges
    SELECT 
        n.id, n.slug, n.names,
        e.edge_type, e.strength, e.confidence,
        'forward'::VARCHAR as direction
    FROM edges e
    JOIN nodes n ON n.id = e.target_id
    WHERE e.source_id = p_node_id
    AND (p_edge_types IS NULL OR e.edge_type = ANY(p_edge_types))
    AND e.strength >= p_min_strength
    AND (p_direction = 'both' OR p_direction = 'forward')
    
    UNION
    
    -- Backward edges
    SELECT 
        n.id, n.slug, n.names,
        e.edge_type, e.strength, e.confidence,
        'backward'::VARCHAR as direction
    FROM edges e
    JOIN nodes n ON n.id = e.source_id
    WHERE e.target_id = p_node_id
    AND (p_edge_types IS NULL OR e.edge_type = ANY(p_edge_types))
    AND e.strength >= p_min_strength
    AND (p_direction = 'both' OR p_direction = 'backward')
    AND e.is_directional = FALSE;
END;
$$ LANGUAGE plpgsql;
```

#### Get Learning Path

```sql
CREATE OR REPLACE FUNCTION get_learning_path(
    p_node_id UUID,
    p_max_depth INTEGER DEFAULT 10
)
RETURNS TABLE (
    node_id UUID,
    slug TEXT,
    names JSONB,
    depth INTEGER,
    path_position INTEGER,
    edge_type VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    WITH RECURSIVE learning_path AS (
        -- Base case: direct prerequisites
        SELECT 
            n.id, n.slug, n.names,
            1 as depth,
            ARRAY[n.id] as path_ids,
            e.edge_type
        FROM edges e
        JOIN nodes n ON n.id = e.source_id
        WHERE e.target_id = p_node_id
        AND e.edge_type IN ('PREREQUISITE', 'REQUIRES', 'BEGINNER_VERSION')
        
        UNION ALL
        
        -- Recursive: prerequisites of prerequisites
        SELECT 
            n.id, n.slug, n.names,
            lp.depth + 1,
            lp.path_ids || n.id,
            e.edge_type
        FROM edges e
        JOIN nodes n ON n.id = e.source_id
        JOIN learning_path lp ON e.target_id = lp.id
        WHERE e.edge_type IN ('PREREQUISITE', 'REQUIRES', 'BEGINNER_VERSION')
        AND NOT n.id = ANY(lp.path_ids)
        AND lp.depth < p_max_depth
    )
    SELECT 
        lp.id, lp.slug, lp.names, lp.depth,
        ROW_NUMBER() OVER (ORDER BY lp.depth DESC) as path_position,
        lp.edge_type
    FROM learning_path lp
    ORDER BY lp.depth DESC;
END;
$$ LANGUAGE plpgsql;
```

#### Get Advanced Progression

```sql
CREATE OR REPLACE FUNCTION get_advanced_progression(
    p_node_id UUID,
    p_max_levels INTEGER DEFAULT 10
)
RETURNS TABLE (
    node_id UUID,
    slug TEXT,
    names JSONB,
    level INTEGER,
    edge_type VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    WITH RECURSIVE progression AS (
        -- Base case: direct advanced versions
        SELECT 
            n.id, n.slug, n.names,
            1 as level,
            e.edge_type
        FROM edges e
        JOIN nodes n ON n.id = e.target_id
        WHERE e.source_id = p_node_id
        AND e.edge_type IN ('ADVANCED_VERSION', 'NEXT_LEVEL', 'LEADS_TO')
        
        UNION ALL
        
        -- Recursive: advanced of advanced
        SELECT 
            n.id, n.slug, n.names,
            p.level + 1,
            e.edge_type
        FROM edges e
        JOIN nodes n ON n.id = e.target_id
        JOIN progression p ON e.source_id = p.id
        WHERE e.edge_type IN ('ADVANCED_VERSION', 'NEXT_LEVEL', 'LEADS_TO')
        AND p.level < p_max_levels
    )
    SELECT DISTINCT ON (p.id) p.id, p.slug, p.names, p.level, p.edge_type
    FROM progression p
    ORDER BY p.id, p.level;
END;
$$ LANGUAGE plpgsql;
```

#### Find Shortest Path

```sql
CREATE OR REPLACE FUNCTION find_shortest_path(
    p_start_id UUID,
    p_end_id UUID,
    p_max_depth INTEGER DEFAULT 10
)
RETURNS TABLE (
    path UUID[],
    path_slugs TEXT[],
    total_distance INTEGER,
    path_types TEXT[]
) AS $$
BEGIN
    RETURN QUERY
    WITH RECURSIVE path_finder AS (
        -- Start from source node
        SELECT 
            ARRAY[e.target_id] as path,
            ARRAY(SELECT slug FROM nodes WHERE id = e.target_id) as path_slugs,
            ARRAY[e.edge_type] as path_types,
            1 as distance
        FROM edges e
        WHERE e.source_id = p_start_id
        
        UNION ALL
        
        -- Continue path
        SELECT 
            pf.path || e.target_id,
            pf.path_slugs || (SELECT slug FROM nodes WHERE id = e.target_id),
            pf.path_types || e.edge_type,
            pf.distance + 1
        FROM edges e
        JOIN path_finder pf ON e.source_id = pf.path[array_length(pf.path, 1)]
        WHERE NOT e.target_id = ANY(pf.path)
        AND pf.distance < p_max_depth
    )
    SELECT 
        pf.path,
        pf.path_slugs,
        pf.distance,
        pf.path_types
    FROM path_finder pf
    WHERE pf.path[array_length(pf.path, 1)] = p_end_id
    ORDER BY pf.distance
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;
```

### 8.2 Graph Statistics

```sql
-- Get node connectivity stats
CREATE OR REPLACE FUNCTION get_node_connectivity(p_node_id UUID)
RETURNS TABLE (
    total_connections INTEGER,
    incoming_connections INTEGER,
    outgoing_connections INTEGER,
    bidirectional_connections INTEGER,
    edge_type_counts JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*) FROM edges WHERE source_id = p_node_id OR target_id = p_node_id) as total,
        (SELECT COUNT(*) FROM edges WHERE target_id = p_node_id AND is_directional = TRUE) as incoming,
        (SELECT COUNT(*) FROM edges WHERE source_id = p_node_id AND is_directional = TRUE) as outgoing,
        (SELECT COUNT(*) FROM edges WHERE (source_id = p_node_id OR target_id = p_node_id) AND is_directional = FALSE) as bidirectional,
        (SELECT jsonb_object_agg(edge_type, count)
         FROM edges 
         WHERE source_id = p_node_id OR target_id = p_node_id
         GROUP BY edge_type) as type_counts;
END;
$$ LANGUAGE plpgsql;

-- Get graph density
CREATE OR REPLACE FUNCTION get_graph_density()
RETURNS DECIMAL AS $$
DECLARE
    v_nodes INTEGER;
    v_edges INTEGER;
    v_max_edges INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_nodes FROM nodes WHERE status = 'published';
    SELECT COUNT(*) INTO v_edges FROM edges;
    
    -- For undirected graph: n*(n-1)/2
    v_max_edges := v_nodes * (v_nodes - 1) / 2;
    
    IF v_max_edges = 0 THEN
        RETURN 0;
    END IF;
    
    RETURN ROUND((v_edges::DECIMAL / v_max_edges) * 100, 2);
END;
$$ LANGUAGE plpgsql;
```

---

## 9. API Endpoints

### 9.1 Node Endpoints

```
GET    /api/v1/nodes                    - List all nodes (paginated)
GET    /api/v1/nodes/:id               - Get node by ID
GET    /api/v1/nodes/slug/:slug         - Get node by slug
POST   /api/v1/nodes                   - Create node
PUT    /api/v1/nodes/:id               - Update node
DELETE /api/v1/nodes/:id               - Delete node

GET    /api/v1/nodes/:id/edges         - Get all edges for node
GET    /api/v1/nodes/:id/related       - Get related nodes
GET    /api/v1/nodes/:id/learning-path - Get learning path
GET    /api/v1/nodes/:id/progression   - Get advanced progression
```

### 9.2 Edge Endpoints

```
GET    /api/v1/edges                    - List all edges (paginated)
GET    /api/v1/edges/:id                - Get edge by ID
POST   /api/v1/edges                    - Create edge
PUT    /api/v1/edges/:id                - Update edge
DELETE /api/v1/edges/:id                - Delete edge

GET    /api/v1/edges/path/:start/:end   - Find path between nodes
```

### 9.3 Graph Endpoints

```
GET    /api/v1/graph/stats              - Get graph statistics
GET    /api/v1/graph/export             - Export entire graph
POST   /api/v1/graph/import             - Import graph data
GET    /api/v1/graph/density            - Get graph density
```

---

## 10. Appendix

### 10.1 Complete Edge Type Reference

| Type | Inverse | Description |
|------|---------|-------------|
| IS_A | (self) | Classification |
| PART_OF | CONTAINS | Component |
| SAME_AS | (self) | Equivalence |
| SYNONYM | (self) | Alternative name |
| ANTONYM | (self) | Opposite |
| USES | USED_BY | Component usage |
| REQUIRES | ENABLES | Prerequisite |
| CAUSES | CAUSED_BY | Result |
| PREVENTS | PREVENTED_BY | Avoidance |
| CORRECTED_BY | CORRECTS | Fix |
| LEADS_TO | PRECEDED_BY | Progression |
| NEXT_LEVEL | PREVIOUS_LEVEL | Difficulty |
| ADVANCED_VERSION | BEGINNER_VERSION | Version |
| TRAINED_BY | TRAINS | Training |
| RELATED_TO | (self) | Loose link |
| OPPOSITE_OF | (self) | Contrast |
| CONFUSES_WITH | (self) | Confusion |
| DISTINGUISHED_FROM | (self) | Difference |
| CONTAINS | PART_OF | Aggregate |
| COMPOSED_OF | COMPOSES | Material |
| APPLICABLE_TO | APPLIES | Scope |
| MORE_IMPORTANT_THAN | LESS_IMPORTANT_THAN | Priority |
| RECOMMENDED_FOR | RECOMMENDED_BY | Suggestion |
| NOT_RECOMMENDED_FOR | NOT_RECOMMENDED_BY | Warning |
| VIDEO_EXPLAINS | EXPLAINED_IN_VIDEO | Media |
| IMAGE_SHOWS | SHOWN_IN_IMAGE | Media |
| ANIMATION_SHOWS | SHOWN_IN_ANIMATION | Media |
| ARTICLE_EXPLAINS | EXPLAINED_IN_ARTICLE | Media |
| INVENTED_BY | INVENTED | Origin |
| POPULARIZED_BY | POPULARIZED | Fame |
| TAUGHT_BY | TEACHES | Teaching |
| DOCUMENTED_BY | DOCUMENTS | Source |
| USED_IN | USES_CONCEPT | Context |
| RULE_APPLIES | GOVERNS | Rule scope |
| COMMON_ERROR | (self) | Mistake |

### 10.2 Related Documents

- [BKM Project Vision](./01_Project_Vision.md)
- [BKM Database Schema](./03_Database.md)
- [BKM Search System](./05_Search_System.md)
- [BKM Tag System](./13_Tag_System.md)
- [BKM API Design](./15_API_Design_For_PoolOS.md)

---

**End of Document**
