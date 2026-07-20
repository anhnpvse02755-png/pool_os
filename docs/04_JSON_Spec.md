# Billiard Knowledge Module (BKM) - JSON Specification

## Version 1.0
**Last Updated:** July 2026
**Status:** Production Specification

---

## 1. JSON File Naming Conventions

### 1.1 File Naming Rules

| Rule | Description | Example |
|------|-------------|---------|
| **Lowercase** | All filenames lowercase | `draw-shot.json` |
| **Hyphens** | Words separated by hyphens | `follow-shot.json` |
| **No Spaces** | Never use spaces | ❌ `draw shot.json` |
| **No Special Chars** | Only alphanumeric + hyphens | ❌ `draw@shot.json` |
| **Language Suffix** | Optional language code | `draw-shot.vi.json` |
| **Version Suffix** | Optional version indicator | `draw-shot.v1.json` |

### 1.2 Naming Patterns by Entity Type

```
terms/
├── {slug}.json                    # Primary term file (English)
├── {slug}.{lang}.json             # Language-specific translation
│
├── shots/
│   ├── draw-shot.json
│   ├── follow-shot.json
│   ├── stun-shot.json
│   ├── massé-shot.json
│   └── jump-shot.json
│
├── techniques/
│   ├── bridge-technique.json
│   ├── stance.json
│   └── aiming-method.json
│
├── rules/
│   ├── fouls/
│   │   ├── scratch.json
│   │   └── ball-in-hand.json
│   └── game-specific/
│       └── 8-ball/
│           └── pocketing-8-ball.json
│
└── concepts/
    ├── cue-ball-control.json
    ├── position-play.json
    └── safety-play.json
```

### 1.3 File Organization by Discipline

```
content/
├── pool/
│   ├── shots/
│   ├── techniques/
│   ├── rules/
│   ├── drills/
│   └── strategy/
│
├── snooker/
│   ├── shots/
│   ├── techniques/
│   ├── rules/
│   └── strategy/
│
├── carom/
│   ├── shots/
│   ├── techniques/
│   └── rules/
│
└── shared/
    ├── fundamentals/
    ├── equipment/
    └── physics/
```

---

## 2. JSON File Structure

### 2.1 Complete Term Structure

```json
{
  "$schema": "https://pool-os.dev/bkm/schemas/term/v1.schema.json",
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "version": "v1",
  "status": "published",
  "visibility": "public",
  
  "slug": "draw-shot",
  "code": "DRAW_SHOT",
  "discipline": {
    "code": "pool",
    "name": {
      "en": "Pool",
      "vi": "Bida Lỗ"
    }
  },
  
  "name": {
    "en": "Draw Shot",
    "vi": "Úp Bóng"
  },
  "summary": {
    "en": "A shot where the cue ball is struck below center, causing it to reverse direction after contact.",
    "vi": "Đòn đánh mà bóng cơ được đánh vào phía dưới tâm, khiến bóng quay ngược lại sau khi chạm bóng."
  },
  "phonetic": {
    "en": "/drɔː ʃɒt/",
    "vi": "/úp bóng/"
  },
  
  "categories": [
    {
      "id": "category-uuid",
      "slug": "stroke-techniques",
      "is_primary": true
    },
    {
      "id": "category-uuid-2",
      "slug": "spin-techniques",
      "is_primary": false
    }
  ],
  
  "definition": {
    "en": {
      "primary": "A shot executed by striking the cue ball below center, applying backspin that causes the cue ball to reverse direction after contact with an object ball or cushion.",
      "formal": "Draw is achieved when the cue tip contacts the cue ball at a point below the equatorial centerline, generating rearward rotational velocity.",
      "technical": "The draw shot induces negative rolling friction and reverses the cue ball's momentum vector upon collision."
    },
    "vi": {
      "primary": "Đòn đánh thực hiện bằng cách đánh bóng cơ ở phía dưới tâm, tạo lực ngược khiến bóng cơ quay ngược hướng sau khi chạm bóng hoặc băng.",
      "formal": "Đòn úp được thực hiện khi đầu cơ chạm bóng cơ ở điểm dưới đường tâm equator, tạo ra vận tốc quay ngược."
    }
  },
  
  "explanation": {
    "en": "<p>The draw shot is one of the most fundamental and essential techniques in pool...</p>",
    "vi": "<p>Đòn úp bóng là một trong những kỹ thuật cơ bản và quan trọng nhất trong bida lỗ...</p>"
  },
  
  "examples": [
    {
      "id": "example-uuid-1",
      "language": "en",
      "text": "When you need the cue ball to come back to you after pocketing an object ball, use a draw shot.",
      "context": "proper_usage",
      "scenario": "Position play after a potting shot"
    },
    {
      "id": "example-uuid-2",
      "language": "en",
      "text": "To increase the draw effect, lower your bridge and strike further below center.",
      "context": "technique_modification",
      "scenario": "Maximizing backspin"
    }
  ],
  
  "usage_notes": [
    {
      "language": "en",
      "text": "Also known as 'pull shot' or 'backspin shot' in some regions.",
      "type": "regional_variant",
      "is_caution": false
    },
    {
      "language": "en",
      "text": "Avoid using excessive draw on delicate position shots - it can cause the cue ball to squirt unexpectedly.",
      "type": "caution",
      "is_caution": true
    }
  ],
  
  "aliases": [
    {
      "language": "en",
      "text": "pull shot",
      "type": "synonym",
      "is_official": false
    },
    {
      "language": "en",
      "text": "backspin",
      "type": "related_concept",
      "is_official": false
    },
    {
      "language": "en",
      "text": "D",
      "type": "abbreviation",
      "is_official": true
    },
    {
      "language": "vi",
      "text": "úp bóng",
      "type": "synonym",
      "is_official": true
    },
    {
      "language": "vi",
      "text": "lửi",
      "type": "colloquial",
      "is_official": false
    }
  ],
  
  "mechanics": {
    "cue_tip_position": "Below center (30-50% down from top)",
    "follow_through": "Extended pull-through motion",
    "power_range": "Light to medium power works best",
    "bridging": "Lower bridge hand for steeper angle"
  },
  
  "physics": {
    "english": {
      "value": "Back spin applied",
      "units": "rpm"
    },
    "ball_dynamics": "Reverse momentum upon collision",
    "friction_coefficient": "Variable based on cloth and ball condition"
  },
  
  "difficulty": {
    "level": "intermediate",
    "prerequisites": [
      {
        "slug": "stop-shot",
        "name": "Stop Shot"
      },
      {
        "slug": "basic-aiming",
        "name": "Basic Aiming"
      }
    ],
    "learn_sequence": 3
  },
  
  "relationships": {
    "uses": [
      {
        "slug": "backspin",
        "name": "Backspin"
      },
      {
        "slug": "cue-tip-control",
        "name": "Cue Tip Control"
      }
    ],
    "opposite": [
      {
        "slug": "follow-shot",
        "name": "Follow Shot"
      }
    ],
    "prerequisite_for": [
      {
        "slug": "power-draw",
        "name": "Power Draw"
      },
      {
        "slug": "massé-shot",
        "name": "Massé Shot"
      }
    ],
    "related": [
      {
        "slug": "cue-ball-control",
        "name": "Cue Ball Control"
      },
      {
        "slug": "english",
        "name": "English (Side Spin)"
      }
    ]
  },
  
  "media": [
    {
      "id": "media-uuid-1",
      "type": "video",
      "url": "https://cdn.pool-os.com/media/draw-shot-demo.mp4",
      "thumbnail": "https://cdn.pool-os.com/media/draw-shot-thumb.jpg",
      "duration": 45,
      "caption": "Demonstration of draw shot technique",
      "usage": "demonstration"
    },
    {
      "id": "media-uuid-2",
      "type": "animation",
      "url": "https://cdn.pool-os.com/media/draw-shot-animation.gif",
      "caption": "Ball path diagram",
      "usage": "diagram"
    }
  ],
  
  "tags": [
    "#stroke",
    "#spin",
    "#english",
    "#backspin",
    "#intermediate",
    "#pool",
    "#cue"
  ],
  
  "cross_references": [
    {
      "type": "term",
      "slug": "follow-shot",
      "description": "Opposite technique using top spin"
    },
    {
      "type": "source",
      "id": "source-uuid",
      "title": "World Standard Pool Rules"
    }
  ],
  
  "difficulty_rating": {
    "pool_8ball": 3,
    "pool_9ball": 3,
    "snooker": 4
  },
  
  "ai_context": {
    "explanation_prompt": "Explain the draw shot as a {skill_level} technique...",
    "teaching_tips": ["...", "..."],
    "common_mistakes": ["...", "..."],
    "practice_drills": ["drill-uuid-1", "drill-uuid-2"]
  },
  
  "metadata": {
    "created_at": "2026-07-01T00:00:00Z",
    "updated_at": "2026-07-15T10:30:00Z",
    "published_at": "2026-07-02T00:00:00Z",
    "created_by": "user-uuid",
    "reviewed_by": "expert-uuid",
    "verified": true,
    "editorial_notes": "Reviewed by Master Coach Nguyen Van A"
  }
}
```

---

## 3. Required vs Optional Fields

### 3.1 Field Classification

| Field Category | Required | Optional | Conditional |
|----------------|----------|----------|-------------|
| **Identification** | | | |
| `id` | ✅ | | |
| `slug` | ✅ | | |
| `version` | ✅ | | |
| **Content** | | | |
| `name` | ✅ | | |
| `discipline` | ✅ | | |
| `definition` | | ✅ | Required for published |
| `summary` | | ✅ | Required for published |
| **Relationships** | | | |
| `categories` | | ✅ | Recommended |
| `tags` | | ✅ | Recommended |
| `relationships` | | ✅ | Recommended |
| **Media** | | | |
| `media` | | ✅ | |
| **AI** | | | |
| `ai_context` | | ✅ | Required for AI features |
| **Audit** | | | |
| `metadata` | ✅ | | |

### 3.2 Minimum Viable Term (Draft)

```json
{
  "$schema": "https://pool-os.dev/bkm/schemas/term/v1.schema.json",
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "slug": "draw-shot",
  "version": "v1",
  
  "name": {
    "en": "Draw Shot"
  },
  
  "discipline": {
    "code": "pool"
  },
  
  "metadata": {
    "created_at": "2026-07-01T00:00:00Z"
  }
}
```

### 3.3 Full Published Term

```json
{
  "$schema": "https://pool-os.dev/bkm/schemas/term/v1.schema.json",
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "version": "v1",
  "status": "published",
  "visibility": "public",
  
  "slug": "draw-shot",
  "code": "DRAW_SHOT",
  "discipline": { ... },
  
  "name": { ... },
  "summary": { ... },
  "phonetic": { ... },
  
  "categories": [ ... ],
  
  "definition": { ... },
  "explanation": { ... },
  "examples": [ ... ],
  "usage_notes": [ ... ],
  "aliases": [ ... ],
  
  "mechanics": { ... },
  "physics": { ... },
  
  "difficulty": { ... },
  
  "relationships": { ... },
  
  "media": [ ... ],
  "tags": [ ... ],
  "cross_references": [ ... ],
  
  "difficulty_rating": { ... },
  
  "ai_context": { ... },
  
  "metadata": { ... }
}
```

---

## 4. Schema Examples

### 4.1 Draw Shot (draw-shot.json)

```json
{
  "$schema": "https://pool-os.dev/bkm/schemas/term/v1.schema.json",
  "id": "660e8400-e29b-41d4-a716-446655440001",
  "version": "v1",
  "status": "published",
  
  "slug": "draw-shot",
  "code": "DRAW_SHOT",
  "discipline": {
    "code": "pool",
    "name": {
      "en": "Pool",
      "vi": "Bida Lỗ"
    }
  },
  
  "name": {
    "en": "Draw Shot",
    "vi": "Úp Bóng"
  },
  "summary": {
    "en": "A shot where the cue ball is struck below center, causing it to reverse direction after contact.",
    "vi": "Đòn đánh mà bóng cơ được đánh vào phía dưới tâm, khiến bóng quay ngược lại sau khi chạm bóng."
  },
  "phonetic": {
    "en": "/drɔː ʃɒt/"
  },
  
  "categories": [
    {
      "slug": "stroke-techniques",
      "is_primary": true
    }
  ],
  
  "definition": {
    "en": {
      "primary": "A shot executed by striking the cue ball below center, applying backspin that causes the cue ball to reverse direction after contact with an object ball or cushion.",
      "technical": "Draw is achieved when the cue tip contacts the cue ball at a point below the equatorial centerline, generating rearward rotational velocity."
    }
  },
  
  "explanation": {
    "en": "<p>The draw shot is one of the most fundamental and essential techniques in pool. It allows you to control the cue ball's position after contact, enabling advanced position play and safeties.</p><h3>How to Execute</h3><ol><li>Position your bridge hand lower than usual</li><li>Level your cue slightly downward</li><li>Strike the cue ball approximately 1/3 to 1/2 below center</li><li>Follow through with a pulling motion</li></ol>"
  },
  
  "examples": [
    {
      "language": "en",
      "text": "When you need the cue ball to come back to you after pocketing an object ball, use a draw shot.",
      "context": "proper_usage"
    }
  ],
  
  "aliases": [
    {
      "language": "en",
      "text": "pull shot",
      "type": "synonym"
    },
    {
      "language": "en",
      "text": "backspin",
      "type": "related_concept"
    },
    {
      "language": "vi",
      "text": "úp bóng",
      "type": "synonym"
    }
  ],
  
  "mechanics": {
    "cue_tip_position": "Below center (30-50% down from top)",
    "follow_through": "Extended pull-through motion",
    "power_range": "Light to medium power works best",
    "bridging": "Lower bridge hand for steeper angle"
  },
  
  "difficulty": {
    "level": "intermediate",
    "prerequisites": [
      {
        "slug": "stop-shot",
        "name": "Stop Shot"
      }
    ],
    "learn_sequence": 3
  },
  
  "relationships": {
    "uses": [
      {
        "slug": "backspin",
        "name": "Backspin"
      }
    ],
    "opposite": [
      {
        "slug": "follow-shot",
        "name": "Follow Shot"
      }
    ],
    "prerequisite_for": [
      {
        "slug": "power-draw",
        "name": "Power Draw"
      }
    ]
  },
  
  "media": [
    {
      "type": "video",
      "url": "https://cdn.pool-os.com/media/draw-shot-demo.mp4",
      "thumbnail": "https://cdn.pool-os.com/media/draw-shot-thumb.jpg",
      "duration": 45
    }
  ],
  
  "tags": [
    "#stroke",
    "#spin",
    "#intermediate",
    "#pool"
  ],
  
  "ai_context": {
    "teaching_tips": [
      "Start with gentle draw before progressing to power draw",
      "Keep your eyes on the contact point during the stroke"
    ],
    "common_mistakes": [
      "Lifting the cue during follow-through",
      "Striking too far below center initially"
    ]
  },
  
  "metadata": {
    "created_at": "2026-07-01T00:00:00Z",
    "updated_at": "2026-07-15T10:30:00Z",
    "published_at": "2026-07-02T00:00:00Z",
    "verified": true
  }
}
```

### 4.2 Stun Shot (stun-shot.json)

```json
{
  "$schema": "https://pool-os.dev/bkm/schemas/term/v1.schema.json",
  "id": "660e8400-e29b-41d4-a716-446655440002",
  "version": "v1",
  "status": "published",
  
  "slug": "stun-shot",
  "code": "STUN_SHOT",
  "discipline": {
    "code": "pool",
    "name": {
      "en": "Pool",
      "vi": "Bida Lỗ"
    }
  },
  
  "name": {
    "en": "Stun Shot",
    "vi": "Đánh Dừng"
  },
  "summary": {
    "en": "A shot where the cue ball has no forward or backward spin at the moment of contact, causing it to travel in a straight line off the object ball.",
    "vi": "Đòn đánh mà bóng cơ không có xoáy tiến hay lùi khi chạm bóng, khiến bóng đi thẳng ra khỏi bóng đối tượng."
  },
  
  "categories": [
    {
      "slug": "stroke-techniques",
      "is_primary": true
    }
  ],
  
  "definition": {
    "en": {
      "primary": "A shot in which the cue ball has minimal or no spinning motion at the moment of impact with an object ball, causing it to travel in a near-straight line after contact.",
      "technical": "The stun shot occurs when the cue ball's center of mass travels directly toward the contact point, with angular velocity neutralized upon object ball impact."
    }
  },
  
  "explanation": {
    "en": "<p>The stun shot is a fundamental technique that forms the basis for many advanced position plays. It is achieved by striking the cue ball at center ball, allowing for predictable deflection angles.</p><h3>Key Characteristics</h3><ul><li>90-degree angle off object ball (natural cut)</li><li>Predictable trajectory</li><li>Essential for position play</li></ul>"
  },
  
  "examples": [
    {
      "language": "en",
      "text": "Use a stun shot when you need the cue ball to travel at a precise angle after contacting the object ball.",
      "context": "proper_usage"
    }
  ],
  
  "aliases": [
    {
      "language": "en",
      "text": "center ball",
      "type": "synonym"
    },
    {
      "language": "en",
      "text": "natural roll",
      "type": "description"
    }
  ],
  
  "mechanics": {
    "cue_tip_position": "Center ball (exactly center)",
    "follow_through": "Smooth, level through",
    "power_range": "Any power level",
    "bridging": "Standard bridge height"
  },
  
  "difficulty": {
    "level": "beginner",
    "prerequisites": [],
    "learn_sequence": 1
  },
  
  "relationships": {
    "uses": [
      {
        "slug": "center-ball-hit",
        "name": "Center Ball Hit"
      }
    ],
    "opposite": [
      {
        "slug": "draw-shot",
        "name": "Draw Shot"
      },
      {
        "slug": "follow-shot",
        "name": "Follow Shot"
      }
    ],
    "related": [
      {
        "slug": "natural-angle",
        "name": "Natural Angle"
      }
    ]
  },
  
  "tags": [
    "#stroke",
    "#fundamental",
    "#beginner",
    "#pool"
  ],
  
  "metadata": {
    "created_at": "2026-07-01T00:00:00Z",
    "updated_at": "2026-07-15T10:30:00Z",
    "published_at": "2026-07-02T00:00:00Z",
    "verified": true
  }
}
```

### 4.3 Follow Shot (follow-shot.json)

```json
{
  "$schema": "https://pool-os.dev/bkm/schemas/term/v1.schema.json",
  "id": "660e8400-e29b-41d4-a716-446655440003",
  "version": "v1",
  "status": "published",
  
  "slug": "follow-shot",
  "code": "FOLLOW_SHOT",
  "discipline": {
    "code": "pool",
    "name": {
      "en": "Pool",
      "vi": "Bida Lỗ"
    }
  },
  
  "name": {
    "en": "Follow Shot",
    "vi": "Đánh Lưng"
  },
  "summary": {
    "en": "A shot where the cue ball is struck above center, causing it to continue rolling forward after contact with an object ball.",
    "vi": "Đòn đánh mà bóng cơ được đánh vào phía trên tâm, khiến bóng tiếp tục lăn về phía trước sau khi chạm bóng đối tượng."
  },
  
  "categories": [
    {
      "slug": "stroke-techniques",
      "is_primary": true
    }
  ],
  
  "definition": {
    "en": {
      "primary": "A shot executed by striking the cue ball above center, applying top spin that causes the cue ball to continue rolling forward after contact with an object ball or cushion.",
      "technical": "Follow is achieved when the cue tip contacts the cue ball above the equatorial centerline, generating forward rotational velocity."
    }
  },
  
  "explanation": {
    "en": "<p>The follow shot, also known as a 'top spin' shot, is used when you want the cue ball to continue moving forward after contacting the object ball. It's essential for position play and runningenglish.</p><h3>How to Execute</h3><ol><li>Elevate your bridge hand slightly</li><li>Level your cue upward</li><li>Strike the cue ball above center (top 1/3)</li><li>Follow through with a pushing motion</li></ol>"
  },
  
  "aliases": [
    {
      "language": "en",
      "text": "top spin",
      "type": "synonym"
    },
    {
      "language": "en",
      "text": "top",
      "type": "abbreviation"
    },
    {
      "language": "vi",
      "text": "đánh lưng",
      "type": "synonym"
    }
  ],
  
  "mechanics": {
    "cue_tip_position": "Above center (top 1/3)",
    "follow_through": "Extended push-through motion",
    "power_range": "Medium to high power for effect",
    "bridging": "Higher bridge for upward angle"
  },
  
  "difficulty": {
    "level": "beginner",
    "prerequisites": [],
    "learn_sequence": 2
  },
  
  "relationships": {
    "uses": [
      {
        "slug": "topspin",
        "name": "Topspin"
      }
    ],
    "opposite": [
      {
        "slug": "draw-shot",
        "name": "Draw Shot"
      }
    ],
    "prerequisite_for": [
      {
        "slug": "running-english",
        "name": "Running English"
      }
    ]
  },
  
  "tags": [
    "#stroke",
    "#spin",
    "#topspin",
    "#beginner",
    "#pool"
  ],
  
  "metadata": {
    "created_at": "2026-07-01T00:00:00Z",
    "updated_at": "2026-07-15T10:30:00Z",
    "published_at": "2026-07-02T00:00:00Z",
    "verified": true
  }
}
```

---

## 5. Metadata Standards

### 5.1 Required Metadata Fields

```json
{
  "metadata": {
    "created_at": "2026-07-01T00:00:00Z",
    "updated_at": "2026-07-15T10:30:00Z",
    "created_by": "user-uuid",
    "version": "v1"
  }
}
```

### 5.2 Optional Metadata Fields

```json
{
  "metadata": {
    "published_at": "2026-07-02T00:00:00Z",
    "reviewed_by": "expert-uuid",
    "verified": true,
    "editorial_notes": "Reviewed by Master Coach",
    "change_reason": "Initial creation",
    "next_review_date": "2026-10-01T00:00:00Z"
  }
}
```

---

## 6. Validation Rules

### 6.1 JSON Schema Validation

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://pool-os.dev/bkm/schemas/term/v1.schema.json",
  "type": "object",
  "required": ["id", "slug", "name", "metadata"],
  "properties": {
    "id": {
      "type": "string",
      "format": "uuid"
    },
    "slug": {
      "type": "string",
      "pattern": "^[a-z0-9]+(-[a-z0-9]+)*$",
      "minLength": 1,
      "maxLength": 255
    },
    "name": {
      "type": "object",
      "minProperties": 1,
      "additionalProperties": {
        "type": "string",
        "minLength": 1,
        "maxLength": 500
      }
    },
    "definition": {
      "type": "object"
    },
    "status": {
      "type": "string",
      "enum": ["draft", "review", "published", "archived"]
    }
  }
}
```

### 6.2 Custom Validation Rules

| Rule | Description | Error Message |
|------|-------------|---------------|
| **Slug Format** | Only lowercase, numbers, hyphens | "Slug must contain only lowercase letters, numbers, and hyphens" |
| **UUID Format** | Valid UUID v4 | "ID must be a valid UUID" |
| **Language Code** | Valid ISO 639-1 | "Language code must be valid (e.g., 'en', 'vi')" |
| **Slug Uniqueness** | Unique per language | "A term with this slug already exists in this language" |
| **Required Definition** | Must have for published | "Definition is required for published terms" |
| **Media URLs** | Valid URL format | "Media URL must be valid" |

---

## 7. Versioning Format

### 7.1 Version Format

```
v{_major}.{minor}[.{patch}]

Examples:
- v1        - Major version 1
- v1.0      - Same as v1
- v1.2      - Version 1, minor 2
- v2.0.1    - Version 2, patch 1
```

### 7.2 Version Lifecycle

| Status | Description | Migration |
|--------|-------------|-----------|
| **Current** | Active version, full support | N/A |
| **Deprecated** | Still works, will be removed | Migrate to Current |
| **Removed** | No longer functional | Manual migration |

### 7.3 Schema Version Examples

```json
{
  "v1": {
    "status": "deprecated",
    "sunset_date": "2027-07-01"
  },
  "v2": {
    "status": "current",
    "release_date": "2026-07-01"
  },
  "v3": {
    "status": "planned",
    "estimated_release": "2027-01-01"
  }
}
```

---

## 8. Appendix

### 8.1 Full Schema Reference

```json
{
  "$schema": "https://pool-os.dev/bkm/schemas/term/v1.schema.json",
  
  "id": "string (uuid)",
  "version": "string (v1, v2, etc.)",
  "status": "string (draft|review|published|archived)",
  "visibility": "string (public|authenticated|premium|internal)",
  
  "slug": "string",
  "code": "string",
  "discipline": {
    "code": "string",
    "name": "object (language code -> text)"
  },
  
  "name": "object (language code -> text)",
  "summary": "object (language code -> text)",
  "phonetic": "object (language code -> text)",
  
  "categories": "array of category references",
  
  "definition": "object (language code -> object with definition types)",
  "explanation": "object (language code -> HTML text)",
  "examples": "array of example objects",
  "usage_notes": "array of usage note objects",
  "aliases": "array of alias objects",
  
  "mechanics": "object with technique details",
  "physics": "object with physics details",
  
  "difficulty": "object with difficulty info",
  
  "relationships": "object with relationship arrays",
  
  "media": "array of media references",
  "tags": "array of tag strings",
  "cross_references": "array of cross-reference objects",
  
  "difficulty_rating": "object (discipline -> rating)",
  
  "ai_context": "object for AI features",
  
  "metadata": {
    "created_at": "ISO8601 timestamp",
    "updated_at": "ISO8601 timestamp",
    "published_at": "ISO8601 timestamp",
    "created_by": "uuid",
    "reviewed_by": "uuid",
    "verified": "boolean",
    "editorial_notes": "string"
  }
}
```

### 8.2 Related Documents

- [BKM Database Schema](./03_Database.md)
- [BKM Search System](./05_Search_System.md)
- [BKM API Design](./15_API_Design_For_PoolOS.md)

---

**End of Document**
