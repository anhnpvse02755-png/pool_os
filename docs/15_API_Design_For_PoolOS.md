# Billiard Knowledge Module (BKM) - API Design for Pool OS

## Version 1.0
**Last Updated:** July 2026
**Status:** Production Specification

---

## 1. API Design Principles

### 1.1 Core Principles

| Principle | Description | Implementation |
|-----------|-------------|----------------|
| **RESTful** | Standard HTTP methods | GET, POST, PUT, DELETE |
| **Resource-Oriented** | Nouns, not verbs | `/terms`, `/categories` |
| **Stateless** | Each request independent | No session state |
| **Consistent** | Uniform interface | Standard patterns |
| **Versioned** | API versioning | `/v1/`, `/v2/` |
| **Documented** | OpenAPI specification | Auto-generated docs |

### 1.2 URL Structure

```
https://api.pool-os.com/{version}/{resource}/{id}/{sub-resource}

Examples:
https://api.pool-os.com/v1/terms/draw-shot
https://api.pool-os.com/v1/terms/draw-shot/relationships
https://api.pool-os.com/v1/categories/pool/strokes
https://api.pool-os.com/v1/search?q=draw+shot
https://api.pool-os.com/v1/ai/explain
```

---

## 2. Endpoints Specification

### 2.1 Terms Endpoints

#### 2.1.1 List Terms

```
GET /v1/terms
```

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | integer | 1 | Page number |
| `limit` | integer | 20 | Items per page (max 100) |
| `discipline` | string | all | Filter by discipline |
| `category` | string | - | Filter by category slug |
| `difficulty` | string | - | Filter by difficulty |
| `language` | string | en | Content language |
| `status` | string | published | Status filter |
| `tags` | string[] | - | Filter by tags |
| `sort` | string | relevance | Sort field |
| `order` | string | desc | Sort order |

**Response:**

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "slug": "draw-shot",
        "name": {
          "en": "Draw Shot",
          "vi": "Úp Bóng"
        },
        "summary": {
          "en": "A shot where the cue ball is struck below center..."
        },
        "discipline": "pool",
        "difficulty": "intermediate",
        "categories": ["stroke-techniques", "spin"],
        "tags": ["#stroke", "#spin"],
        "media_count": 3,
        "relationship_count": 12,
        "view_count": 15420,
        "updated_at": "2026-07-15T10:30:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 500,
      "total_pages": 25,
      "has_next": true,
      "has_prev": false
    }
  }
}
```

#### 2.1.2 Get Term by Slug

```
GET /v1/terms/{slug}
```

**Parameters:**

| Parameter | Type | Location | Description |
|-----------|------|----------|-------------|
| `slug` | string | path | Term slug |
| `language` | string | query | Content language (default: en) |
| `include` | string[] | query | Related data to include |

**Include Options:**

| Option | Description |
|--------|-------------|
| `definitions` | Include full definitions |
| `examples` | Include usage examples |
| `relationships` | Include related terms |
| `media` | Include media references |
| `translations` | Include other languages |

**Response:**

```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "slug": "draw-shot",
    "code": "DRAW_SHOT",
    "discipline": {
      "code": "pool",
      "name": { "en": "Pool", "vi": "Bida Lỗ" }
    },
    "name": {
      "en": "Draw Shot",
      "vi": "Úp Bóng"
    },
    "summary": {
      "en": "A shot where the cue ball is struck below center...",
      "vi": "Đòn đánh mà bóng cơ được đánh vào phía dưới tâm..."
    },
    "phonetic": {
      "en": "/drɔː ʃɒt/",
      "vi": "/úp bóng/"
    },
    "definition": {
      "en": {
        "primary": "A shot executed by striking the cue ball below center...",
        "formal": "Draw is achieved when the cue tip contacts the cue ball..."
      }
    },
    "examples": [
      {
        "id": "example-uuid",
        "language": "en",
        "text": "When you need the cue ball to come back to you...",
        "context": "proper_usage"
      }
    ],
    "categories": [
      {
        "slug": "stroke-techniques",
        "name": { "en": "Stroke Techniques" },
        "is_primary": true
      }
    ],
    "relationships": {
      "uses": [
        { "slug": "backspin", "name": "Backspin", "weight": 1.0 }
      ],
      "prerequisite": [
        { "slug": "stop-shot", "name": "Stop Shot", "weight": 1.0 }
      ],
      "opposite": [
        { "slug": "follow-shot", "name": "Follow Shot", "weight": 1.0 }
      ]
    },
    "media": [
      {
        "id": "media-uuid",
        "type": "video",
        "url": "https://cdn.pool-os.com/...",
        "thumbnail_url": "https://cdn.pool-os.com/...",
        "caption": "Draw shot demonstration"
      }
    ],
    "tags": ["#stroke", "#spin", "#intermediate", "#pool"],
    "difficulty": "intermediate",
    "view_count": 15420,
    "created_at": "2026-07-01T00:00:00Z",
    "updated_at": "2026-07-15T10:30:00Z",
    "published_at": "2026-07-02T00:00:00Z"
  }
}
```

#### 2.1.3 Create Term

```
POST /v1/terms
```

**Request Body:**

```json
{
  "slug": "new-term",
  "name": {
    "en": "New Term",
    "vi": "Thuật Ngữ Mới"
  },
  "discipline_code": "pool",
  "category_slugs": ["stroke-techniques"],
  "definition": {
    "en": {
      "primary": "Definition text..."
    }
  },
  "difficulty": "intermediate",
  "tags": ["#stroke", "#technique"]
}
```

**Response:** `201 Created`

```json
{
  "success": true,
  "data": {
    "id": "new-uuid",
    "slug": "new-term",
    "status": "draft",
    "created_at": "2026-07-17T10:00:00Z"
  },
  "message": "Term created successfully"
}
```

#### 2.1.4 Update Term

```
PUT /v1/terms/{slug}
```

#### 2.1.5 Delete Term

```
DELETE /v1/terms/{slug}
```

---

### 2.2 Categories Endpoints

#### 2.2.1 Get Category Tree

```
GET /v1/categories/tree
```

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `discipline` | string | Filter by discipline |
| `language` | string | Content language |
| `depth` | integer | Max depth to retrieve |

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "slug": "pool",
      "name": { "en": "Pool", "vi": "Bida Lỗ" },
      "level": 0,
      "children": [
        {
          "slug": "fundamentals",
          "name": { "en": "Fundamentals" },
          "level": 1,
          "term_count": 45,
          "children": [
            {
              "slug": "stroke-techniques",
              "name": { "en": "Stroke Techniques" },
              "level": 2,
              "term_count": 25
            }
          ]
        }
      ]
    }
  ]
}
```

#### 2.2.2 Get Category Terms

```
GET /v1/categories/{slug}/terms
```

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `include_subcategories` | boolean | true | Include subcategory terms |
| `page` | integer | 1 | Page number |
| `limit` | integer | 20 | Items per page |

---

### 2.3 Translations Endpoints

#### 2.3.1 Get Translation

```
GET /v1/terms/{slug}/translations/{language}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "term_slug": "draw-shot",
    "language": "vi",
    "name": "Úp Bóng",
    "summary": "Đòn đánh mà bóng cơ được đánh...",
    "definition": "Định nghĩa tiếng Việt...",
    "examples": [...],
    "is_verified": true,
    "translator": "translator-name",
    "updated_at": "2026-07-15T10:30:00Z"
  }
}
```

#### 2.3.2 Update Translation

```
PUT /v1/terms/{slug}/translations/{language}
```

---

### 2.4 Search Endpoints

#### 2.4.1 Search Terms

```
GET /v1/search
POST /v1/search
```

**Query Parameters (GET):**

| Parameter | Type | Description |
|-----------|------|-------------|
| `q` | string | Search query |
| `language` | string | Search language |
| `discipline` | string | Filter by discipline |
| `difficulty` | string | Filter by difficulty |
| `tags` | string | Comma-separated tags |
| `page` | integer | Page number |
| `limit` | integer | Results per page |

**Request Body (POST):**

```json
{
  "query": "draw shot technique",
  "language": "en",
  "filters": {
    "discipline": "pool",
    "difficulty": ["beginner", "intermediate"],
    "tags": ["#stroke", "#spin"]
  },
  "exclude_tags": ["#advanced"],
  "page": 1,
  "limit": 20,
  "include": ["definitions", "media"]
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "query": {
      "original": "draw shot technique",
      "normalized": "draw shot technique",
      "language_detected": "en"
    },
    "results": [
      {
        "id": "term-uuid",
        "slug": "draw-shot",
        "name": { "en": "Draw Shot", "vi": "Úp Bóng" },
        "summary": { "en": "..." },
        "difficulty": "intermediate",
        "score": 0.95,
        "highlights": {
          "en": ["<em>Draw</em> <em>shot</em> is a fundamental..."]
        },
        "category_path": "pool > fundamentals > stroke techniques",
        "related_suggestions": ["follow-shot", "stop-shot"]
      }
    ],
    "facets": {
      "difficulty": {
        "beginner": 5,
        "intermediate": 12,
        "advanced": 8
      },
      "category": {
        "stroke": 15,
        "spin": 10,
        "position": 8
      }
    },
    "suggestions": {
      "corrected_query": "draw shot technique",
      "did_you_mean": ["draw shot", "basic draw", "pull shot"]
    },
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 47,
      "total_pages": 3
    },
    "meta": {
      "search_time_ms": 45,
      "cache_hit": false
    }
  }
}
```

#### 2.4.2 Semantic Search

```
POST /v1/search/semantic
```

**Request Body:**

```json
{
  "query": "How do I make the cue ball come back after hitting the object ball?",
  "language": "en",
  "top_k": 10,
  "include_scores": true
}
```

---

### 2.5 Tags Endpoints

#### 2.5.1 List Tags

```
GET /v1/tags
```

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `category` | string | Filter by tag category |
| `language` | string | Display language |
| `parent_id` | UUID | Filter by parent tag |

**Response:**

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "tag-uuid",
        "name": "stroke",
        "display_name": { "en": "Stroke", "vi": "Gạt Cơ" },
        "category": "physics",
        "level": 1,
        "term_count": 45,
        "children": [
          {
            "name": "draw",
            "display_name": { "en": "Draw", "vi": "Úp" },
            "term_count": 25
          },
          {
            "name": "follow",
            "display_name": { "en": "Follow", "vi": "Lưng" },
            "term_count": 20
          }
        ]
      }
    ]
  }
}
```

---

### 2.6 Media Endpoints

#### 2.6.1 Get Term Media

```
GET /v1/terms/{slug}/media
```

**Response:**

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "media-uuid",
        "type": "video",
        "url": "https://cdn.pool-os.com/v/1080p/draw-shot/demo.mp4",
        "thumbnail_url": "https://cdn.pool-os.com/t/medium/draw-shot-thumb.jpg",
        "poster_url": "https://cdn.pool-os.com/t/large/draw-shot-poster.jpg",
        "duration": 45,
        "content": {
          "alt_text": {
            "en": "Video showing draw shot technique..."
          },
          "caption": {
            "en": "Draw Shot Demonstration"
          }
        },
        "usage_type": "demonstration",
        "is_primary": true
      }
    ]
  }
}
```

#### 2.6.2 Upload Media

```
POST /v1/media/upload
```

**Request:** `multipart/form-data`

| Field | Type | Description |
|-------|------|-------------|
| `file` | file | Media file |
| `term_slug` | string | Associated term |
| `usage_type` | string | demo, diagram, drill_preview |
| `language` | string | Content language |

---

### 2.7 Relationships Endpoints

#### 2.7.1 Get Term Relationships

```
GET /v1/terms/{slug}/relationships
```

**Response:**

```json
{
  "success": true,
  "data": {
    "uses": [
      {
        "target": {
          "slug": "backspin",
          "name": { "en": "Backspin" }
        },
        "weight": 1.0,
        "description": "Requires backspin application"
      }
    ],
    "prerequisite": [
      {
        "target": {
          "slug": "stop-shot",
          "name": { "en": "Stop Shot" }
        },
        "weight": 1.0
      }
    ],
    "opposite": [
      {
        "target": {
          "slug": "follow-shot",
          "name": { "en": "Follow Shot" }
        }
      }
    ],
    "related": [...],
    "advanced_from": [...],
    "advanced_into": [...],
    "confuses_with": [...]
  }
}
```

#### 2.7.2 Add Relationship

```
POST /v1/terms/{slug}/relationships
```

**Request:**

```json
{
  "target_slug": "backspin",
  "relationship_type": "uses",
  "weight": 1.0,
  "description": "Requires backspin application"
}
```

---

### 2.8 AI Endpoints

#### 2.8.1 Explain Term

```
POST /v1/ai/explain
```

**Request:**

```json
{
  "term_slug": "draw-shot",
  "skill_level": "intermediate",
  "language": "en",
  "include_examples": true,
  "include_drills": true
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "term": {
      "slug": "draw-shot",
      "name": { "en": "Draw Shot" }
    },
    "explanation": {
      "what": "A shot where the cue ball is struck below center...",
      "why": "Used to control cue ball position after contact...",
      "how": "1. Lower your bridge\n2. Strike below center...",
      "when": "When you need the cue ball to return to you..."
    },
    "examples": [...],
    "common_mistakes": [
      "Striking too far below center",
      "Not following through"
    ],
    "practice_drills": [
      {
        "slug": "basic-draw-drill",
        "name": "Basic Draw Drill",
        "description": "Practice draw at various distances"
      }
    ],
    "citations": [
      {
        "type": "bkm",
        "slug": "backspin",
        "relevance": 0.9
      }
    ]
  }
}
```

#### 2.8.2 Generate Quiz

```
POST /v1/ai/quiz
```

**Request:**

```json
{
  "topics": ["draw-shot", "follow-shot", "stun-shot"],
  "difficulty": "intermediate",
  "count": 10,
  "types": ["definition", "application"],
  "language": "en"
}
```

#### 2.8.3 Generate Learning Path

```
POST /v1/ai/learning-path
```

**Request:**

```json
{
  "target_term": "power-draw",
  "current_skill": "intermediate",
  "time_available": "30",
  "language": "en"
}
```

---

### 2.9 Knowledge Graph Endpoints

The BKM provides dedicated endpoints for graph traversal, learning paths, and relationship discovery.

#### 2.9.1 Get Node Details

```
GET /v1/graph/nodes/{id}
GET /v1/graph/nodes/slug/{slug}
```

**Parameters:**

| Parameter | Type | Location | Description |
|-----------|------|----------|-------------|
| `id` | UUID | path | Node UUID |
| `slug` | string | path | Node slug |
| `language` | string | query | Content language |
| `include_edges` | boolean | query | Include edge metadata |
| `depth` | integer | query | Traversal depth (default: 1) |

**Response:**

```json
{
  "success": true,
  "data": {
    "node": {
      "id": "550e8400-e29b-41d4-a716-446655440001",
      "type": "shot",
      "subtype": "spin-shot",
      "slug": "draw-shot",
      "status": "published",
      "names": {
        "en": { "value": "Draw Shot", "pronunciation": "/drɔː ʃɒt/" },
        "vi": { "value": "Đường Cắt Đít", "pronunciation": "/ɗɨ̛əŋ ɓät ɗit/" }
      },
      "descriptions": {
        "en": {
          "short": "A shot using backspin to bring the cue ball back",
          "full": "A draw shot is executed by striking below center..."
        }
      },
      "difficulty": "intermediate",
      "discipline": ["pool", "snooker"],
      "tags": ["#spin", "#english", "#intermediate"]
    },
    "edges": [
      {
        "id": "edge-001",
        "edge_type": "USES",
        "target_id": "uuid-backspin",
        "strength": 1.0,
        "confidence": 1.0,
        "priority": 1
      },
      {
        "id": "edge-002",
        "edge_type": "OPPOSITE_OF",
        "target_id": "uuid-follow-shot",
        "strength": 1.0,
        "confidence": 1.0,
        "priority": 1
      }
    ]
  }
}
```

#### 2.9.2 Get Related Nodes

```
GET /v1/graph/nodes/{id}/related
```

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `edge_types` | string[] | all | Filter by edge types |
| `min_strength` | decimal | 0.5 | Minimum edge strength |
| `direction` | string | both | forward, backward, both |
| `limit` | integer | 20 | Max results |

**Response:**

```json
{
  "success": true,
  "data": {
    "nodes": [
      {
        "id": "uuid-backspin",
        "slug": "backspin",
        "name": { "en": "Backspin" },
        "edge_type": "USES",
        "strength": 1.0,
        "direction": "forward"
      },
      {
        "id": "uuid-follow-shot",
        "slug": "follow-shot",
        "name": { "en": "Follow Shot" },
        "edge_type": "OPPOSITE_OF",
        "strength": 1.0,
        "direction": "bidirectional"
      }
    ],
    "edge_types_found": ["USES", "OPPOSITE_OF", "PREREQUISITE", "LEADS_TO", "TRAINED_BY"]
  }
}
```

#### 2.9.3 Get Learning Path

```
GET /v1/graph/nodes/{id}/learning-path
```

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `direction` | string | prerequisites | prerequisites or progression |
| `max_depth` | integer | 10 | Maximum path depth |

**Response:**

```json
{
  "success": true,
  "data": {
    "target": {
      "id": "uuid-draw-shot",
      "slug": "draw-shot",
      "name": { "en": "Draw Shot" }
    },
    "path": [
      {
        "position": 1,
        "depth": 3,
        "node": {
          "id": "uuid-stop-shot",
          "slug": "stop-shot",
          "name": { "en": "Stop Shot" }
        },
        "edge_type": "PREREQUISITE"
      },
      {
        "position": 2,
        "depth": 2,
        "node": {
          "id": "uuid-basic-draw",
          "slug": "basic-draw",
          "name": { "en": "Basic Draw" }
        },
        "edge_type": "PREREQUISITE"
      },
      {
        "position": 3,
        "depth": 1,
        "node": {
          "id": "uuid-intermediate-draw",
          "slug": "intermediate-draw",
          "name": { "en": "Intermediate Draw" }
        },
        "edge_type": "NEXT_LEVEL"
      }
    ],
    "total_prerequisites": 5,
    "estimated_time": "2-4 weeks"
  }
}
```

#### 2.9.4 Get Advanced Progression

```
GET /v1/graph/nodes/{id}/progression
```

**Response:**

```json
{
  "success": true,
  "data": {
    "current": {
      "id": "uuid-draw-shot",
      "slug": "draw-shot",
      "name": { "en": "Draw Shot" }
    },
    "progression": [
      {
        "level": 1,
        "node": {
          "id": "uuid-power-draw",
          "slug": "power-draw",
          "name": { "en": "Power Draw" }
        },
        "edge_type": "LEADS_TO",
        "strength": 0.9
      },
      {
        "level": 2,
        "node": {
          "id": "uuid-running-draw",
          "slug": "running-draw",
          "name": { "en": "Running Draw" }
        },
        "edge_type": "ADVANCED_VERSION",
        "strength": 0.8
      },
      {
        "level": 3,
        "node": {
          "id": "uuid-masse-draw",
          "slug": "masse-draw",
          "name": { "en": "Masse Draw" }
        },
        "edge_type": "ADVANCED_VERSION",
        "strength": 0.7
      }
    ]
  }
}
```

#### 2.9.5 Find Shortest Path

```
GET /v1/graph/path/{source_slug}/{target_slug}
```

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `max_depth` | integer | 10 | Maximum traversal depth |
| `edge_types` | string[] | all | Allowed edge types |

**Response:**

```json
{
  "success": true,
  "data": {
    "source": {
      "id": "uuid-stop-shot",
      "slug": "stop-shot",
      "name": { "en": "Stop Shot" }
    },
    "target": {
      "id": "uuid-masse-shot",
      "slug": "masse-shot",
      "name": { "en": "Masse Shot" }
    },
    "path": {
      "nodes": [
        { "slug": "stop-shot", "name": { "en": "Stop Shot" } },
        { "slug": "draw-shot", "name": { "en": "Draw Shot" } },
        { "slug": "power-draw", "name": { "en": "Power Draw" } },
        { "slug": "masse-shot", "name": { "en": "Masse Shot" } }
      ],
      "edges": [
        { "edge_type": "LEADS_TO", "strength": 0.9 },
        { "edge_type": "ADVANCED_VERSION", "strength": 1.0 },
        { "edge_type": "LEADS_TO", "strength": 0.7 }
      ],
      "total_distance": 3
    }
  }
}
```

#### 2.9.6 Create Edge

```
POST /v1/graph/edges
```

**Request:**

```json
{
  "source_id": "uuid-draw-shot",
  "target_id": "uuid-drill-013",
  "edge_type": "TRAINED_BY",
  "metadata": {
    "strength": 0.95,
    "confidence": 0.9,
    "priority": 1,
    "description": "Drill-013 is the primary training drill for draw shot",
    "examples": ["Practice 20 minutes daily"],
    "exceptions": ["Requires proper equipment"]
  },
  "language": {
    "en": { "description": "Effective training drill for draw shot" },
    "vi": { "description": "Bài tập hiệu quả cho đường cắt đít" }
  }
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "edge": {
      "id": "edge-new-uuid",
      "source_id": "uuid-draw-shot",
      "target_id": "uuid-drill-013",
      "edge_type": "TRAINED_BY",
      "strength": 0.95,
      "confidence": 0.9,
      "priority": 1,
      "created_at": "2026-07-17T10:00:00Z"
    }
  }
}
```

#### 2.9.7 Get Graph Statistics

```
GET /v1/graph/stats
```

**Response:**

```json
{
  "success": true,
  "data": {
    "overview": {
      "total_nodes": 1500,
      "total_edges": 8500,
      "node_types": {
        "shot": 120,
        "technique": 80,
        "equipment": 150,
        "drill": 200,
        "rule": 100,
        "strategy": 75
      },
      "edge_types": {
        "USES": 800,
        "RELATED_TO": 2500,
        "PREREQUISITE": 600,
        "LEADS_TO": 450,
        "OPPOSITE_OF": 120,
        "TRAINED_BY": 300,
        "COMMON_ERROR": 180
      }
    },
    "connectivity": {
      "avg_connections_per_node": 5.67,
      "max_connections": 45,
      "isolated_nodes": 12,
      "graph_density": 0.003
    },
    "languages": {
      "en": { "nodes": 1500, "translations": 0 },
      "vi": { "nodes": 1200, "translations": 1200 }
    },
    "version": {
      "current": "v1",
      "last_updated": "2026-07-17T00:00:00Z"
    }
  }
}
```

#### 2.9.8 Export Graph

```
GET /v1/graph/export
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `format` | string | json, csv, graphml |
| `node_types` | string[] | Filter by node types |
| `edge_types` | string[] | Filter by edge types |
| `include_metadata` | boolean | Include edge metadata |

**Response:**

```json
{
  "success": true,
  "data": {
    "export": {
      "format": "json",
      "nodes": [...],
      "edges": [...],
      "metadata": {
        "node_count": 1500,
        "edge_count": 8500,
        "exported_at": "2026-07-17T10:00:00Z",
        "version": "v1"
      }
    }
  }
}
```

---

## 3. Request/Response Formats

### 3.1 Standard Response Format

```json
{
  "success": true,
  "data": { ... },
  "meta": {
    "request_id": "req-uuid",
    "timestamp": "2026-07-17T10:00:00Z",
    "version": "v1"
  }
}
```

### 3.2 Error Response Format

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request parameters",
    "details": [
      {
        "field": "name.en",
        "message": "Name in English is required"
      }
    ]
  },
  "meta": {
    "request_id": "req-uuid",
    "timestamp": "2026-07-17T10:00:00Z"
  }
}
```

### 3.3 Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `VALIDATION_ERROR` | 400 | Invalid request parameters |
| `UNAUTHORIZED` | 401 | Authentication required |
| `FORBIDDEN` | 403 | Insufficient permissions |
| `NOT_FOUND` | 404 | Resource not found |
| `CONFLICT` | 409 | Resource conflict |
| `RATE_LIMITED` | 429 | Too many requests |
| `INTERNAL_ERROR` | 500 | Server error |

---

## 4. Pagination Standards

### 4.1 Pagination Parameters

| Parameter | Default | Max | Description |
|-----------|---------|-----|-------------|
| `page` | 1 | - | Page number |
| `limit` | 20 | 100 | Items per page |
| `offset` | 0 | - | Alternative to page |

### 4.2 Pagination Response

```json
{
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 500,
    "total_pages": 25,
    "has_next": true,
    "has_prev": false,
    "next_page": 2,
    "prev_page": null
  }
}
```

---

## 5. Filtering Options

### 5.1 Filter Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `=` | Equals | `difficulty=intermediate` |
| `!=` | Not equals | `status!=draft` |
| `in` | In list | `difficulty=beginner,intermediate` |
| `nin` | Not in list | `tags=foo,nin` |
| `gt` | Greater than | `view_count=gt:1000` |
| `gte` | Greater or equal | `view_count=gte:1000` |
| `lt` | Less than | `view_count=lt:100` |
| `lte` | Less or equal | `view_count=lte:100` |

### 5.2 Filter Examples

```
GET /v1/terms?difficulty=intermediate
GET /v1/terms?tags=stroke,spin&difficulty=intermediate
GET /v1/terms?view_count=gte:1000&sort=view_count&order=desc
```

---

## 6. Error Handling

### 6.1 Error Response Structure

```json
{
  "success": false,
  "error": {
    "code": "NOT_FOUND",
    "message": "Term not found",
    "details": {
      "slug": "non-existent-term"
    },
    "suggestion": "Did you mean: draw-shot, follow-shot?"
  }
}
```

### 6.2 Rate Limit Headers

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1626500000
Retry-After: 3600
```

---

## 7. Rate Limiting

### 7.1 Rate Limits

| Tier | Requests/Minute | Requests/Day |
|------|-----------------|--------------|
| **Free** | 60 | 1,000 |
| **Pro** | 300 | 10,000 |
| **Enterprise** | 1,000 | 100,000 |

### 7.2 Rate Limit Headers

```
HTTP/1.1 200 OK
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1626500060
```

---

## 8. Caching Strategies

### 8.1 Cache Headers

```json
{
  "Cache-Control": "public, max-age=3600",
  "ETag": "abc123",
  "Last-Modified": "2026-07-17T10:00:00Z"
}
```

### 8.2 Conditional Requests

```
GET /v1/terms/draw-shot
If-None-Match: "abc123"

HTTP/1.1 304 Not Modified
```

---

## 9. Versioning Strategy

### 9.1 Version Headers

```
Accept: application/vnd.pool-os.v2+json
API-Version: v2
```

### 9.2 Breaking Changes Policy

- **6 months notice** before deprecation
- **12 months support** for deprecated versions
- **Deprecation headers** in responses

---

## 10. Flutter Integration

### 10.1 Flutter Client Example

```dart
class BKMClient {
  static const _baseUrl = 'https://api.pool-os.com';
  final Dio _dio;
  
  BKMClient({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(
    baseUrl: _baseUrl,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/vnd.pool-os.v1+json',
    },
  ));
  
  // Terms
  Future<List<Term>> getTerms({
    int page = 1,
    int limit = 20,
    String? discipline,
    String? difficulty,
  }) async {
    final response = await _dio.get('/v1/terms', queryParameters: {
      'page': page,
      'limit': limit,
      if (discipline != null) 'discipline': discipline,
      if (difficulty != null) 'difficulty': difficulty,
    });
    return ApiResponse.fromJson(response.data).data.items;
  }
  
  Future<Term> getTerm(String slug, {String? language}) async {
    final response = await _dio.get('/v1/terms/$slug', queryParameters: {
      if (language != null) 'language': language,
      'include': 'definitions,examples,relationships,media',
    });
    return Term.fromJson(response.data['data']);
  }
  
  // Search
  Future<SearchResult> search(String query, {Map<String, dynamic>? filters}) async {
    final response = await _dio.post('/v1/search', data: {
      'query': query,
      if (filters != null) 'filters': filters,
    });
    return SearchResult.fromJson(response.data['data']);
  }
  
  // AI
  Future<AIExplanation> explainTerm(String slug, {String? skillLevel}) async {
    final response = await _dio.post('/v1/ai/explain', data: {
      'term_slug': slug,
      if (skillLevel != null) 'skill_level': skillLevel,
      'include_examples': true,
      'include_drills': true,
    });
    return AIExplanation.fromJson(response.data['data']);
  }
}
```

---

## 11. Supabase Integration

### 11.1 Supabase Client Setup

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseBKM {
  final SupabaseClient _client;
  
  SupabaseBKM() : _client = Supabase.instance.client;
  
  // Real-time subscriptions
  Stream<dynamic> subscribeToTermChanges(String slug) {
    return _client
        .channel('term_$slug')
        .onPostgresChanges(
          schema: 'public',
          table: 'terms',
          filter: 'slug=eq.$slug',
          event: '*',
        )
        .stream();
  }
  
  // Offline queries
  Future<List<Term>> getCachedTerms() async {
    final db = await _client.db.database;
    final results = await db.query('terms', where: 'status = ?', whereArgs: ['published']);
    return results.map((r) => Term.fromDb(r)).toList();
  }
}
```

---

## 12. SQLite Offline Support

### 12.1 Local Database Schema

```dart
class LocalDatabase {
  static const _dbName = 'pool_os_bkm.db';
  static const _version = 1;
  
  Future<Database> get database async {
    return await openDatabase(
      _dbName,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE terms (
        id TEXT PRIMARY KEY,
        slug TEXT NOT NULL,
        language TEXT NOT NULL DEFAULT 'en',
        name TEXT NOT NULL,
        summary TEXT,
        discipline TEXT,
        difficulty TEXT,
        status TEXT DEFAULT 'published',
        view_count INTEGER DEFAULT 0,
        updated_at TEXT NOT NULL,
        UNIQUE(slug, language)
      )
    ''');
    
    await db.execute('''
      CREATE VIRTUAL TABLE terms_fts USING fts5(
        slug, name, summary,
        content='terms',
        content_rowid='rowid'
      )
    ''');
  }
  
  Future<List<Term>> searchLocal(String query) async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT * FROM terms 
      WHERE slug IN (
        SELECT slug FROM terms_fts WHERE terms_fts MATCH ?
      )
      LIMIT 20
    ''', ['$query*']);
    
    return results.map((r) => Term.fromDb(r)).toList();
  }
}
```

### 12.2 Sync Strategy

```dart
class SyncService {
  final RemoteBKM _remote;
  final LocalDatabase _local;
  
  Future<void> sync() async {
    // 1. Get last sync timestamp
    final lastSync = await _local.getLastSyncTime();
    
    // 2. Fetch changes from server
    final changes = await _remote.getChanges(since: lastSync);
    
    // 3. Apply changes locally
    await _local.applyChanges(changes);
    
    // 4. Update sync timestamp
    await _local.setLastSyncTime(DateTime.now());
  }
}
```

---

## 13. Appendix

### 13.1 API Summary

| Resource | Endpoints | Methods |
|----------|-----------|---------|
| **Terms** | `/terms`, `/terms/{slug}` | GET, POST, PUT, DELETE |
| **Categories** | `/categories`, `/categories/tree` | GET |
| **Translations** | `/terms/{slug}/translations/{lang}` | GET, PUT |
| **Search** | `/search`, `/search/semantic` | GET, POST |
| **Tags** | `/tags` | GET |
| **Media** | `/terms/{slug}/media`, `/media/upload` | GET, POST |
| **Relationships** | `/terms/{slug}/relationships` | GET, POST |
| **AI** | `/ai/explain`, `/ai/quiz`, `/ai/learning-path` | POST |

### 13.2 Related Documents

- [BKM Architecture](./02_Architecture.md)
- [BKM Database Schema](./03_Database.md)
- [BKM Search System](./05_Search_System.md)
- [BKM AI Integration](./08_AI_Integration.md)

---

**End of Document**
