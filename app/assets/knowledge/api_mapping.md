# Pool OS API Mapping Documentation

## Overview

This document describes the API contracts for accessing the Pool OS Knowledge Base components.

**Version:** 1.0.0  
**Last Updated:** 2026-07-17  
**Knowledge Base Version:** 1.0.0  

---

## Table of Contents

1. [Knowledge Item](#1-knowledge-item)
2. [Category](#2-category)
3. [Search](#3-search)
4. [Relationship](#4-relationship)
5. [Recommendation](#5-recommendation)
6. [Learning Path](#6-learning-path)
7. [Drill Mapping](#7-drill-mapping)
8. [Strategy](#8-strategy)
9. [Mistake](#9-mistake)
10. [Equipment](#10-equipment)
11. [Rules](#11-rules)
12. [Common Response Formats](#12-common-response-formats)

---

## 1. Knowledge Item

### Get Knowledge Item by ID

```
GET /api/v1/knowledge/{category}/{itemId}
```

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `category` | string | Category folder name (e.g., `stroke`, `aim`, `bridge`) |
| `itemId` | string | Knowledge item identifier |

**Example URL:**
```
GET /api/v1/knowledge/stroke/stroke.fundamentals
```

**Response:**

```json
{
  "id": "stroke.fundamentals",
  "category": "stroke",
  "title": "Stroke Fundamentals",
  "title_vi": "Nền tảng Động tác",
  "description": "Master the basic stroke motion...",
  "description_vi": "Nắm vững động tác cơ bản...",
  "level": "I",
  "importance": 100,
  "popularity": 95,
  "tags": ["fundamentals", "stroke", "critical"],
  "relatedSkills": ["stroke.straight_stroke", "bridge.fundamentals"],
  "prerequisites": [],
  "estimatedReadingTime": 5,
  "estimatedPracticeTime": 120,
  "drillIds": ["STROKE001", "STROKE002"],
  "content": {
    "overview": "...",
    "keyPoints": [...],
    "commonMistakes": [...],
    "tips": [...]
  },
  "metadata": {
    "createdAt": "2026-01-01T00:00:00Z",
    "updatedAt": "2026-07-17T00:00:00Z",
    "version": "1.0.0"
  }
}
```

### Get All Knowledge Items

```
GET /api/v1/knowledge
```

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `category` | string | null | Filter by category |
| `level` | string | null | Filter by player level |
| `limit` | integer | 20 | Number of items |
| `offset` | integer | 0 | Pagination offset |
| `sort` | string | "importance" | Sort field |
| `order` | string | "desc" | Sort order |

**Response:**

```json
{
  "items": [...],
  "pagination": {
    "total": 750,
    "limit": 20,
    "offset": 0,
    "hasMore": true
  }
}
```

### Get Knowledge Item by Category

```
GET /api/v1/knowledge/{category}
```

**Example URL:**
```
GET /api/v1/knowledge/stroke
```

**Response:**

```json
{
  "category": "stroke",
  "categoryName": "Stroke",
  "categoryNameVi": "Động tác",
  "items": [
    {
      "id": "stroke.fundamentals",
      "title": "Stroke Fundamentals",
      "level": "I",
      "importance": 100
    }
  ],
  "totalItems": 13
}
```

---

## 2. Category

### Get All Categories

```
GET /api/v1/categories
```

**Response:**

```json
{
  "categories": [
    {
      "id": "stroke",
      "name": "Stroke",
      "nameVi": "Động tác",
      "description": "Stroke mechanics and fundamentals",
      "itemCount": 13,
      "icon": "grip",
      "color": "#4CAF50"
    },
    {
      "id": "aim",
      "name": "Aiming",
      "nameVi": "Ngắm bắn",
      "description": "Aiming techniques",
      "itemCount": 13,
      "icon": "visibility",
      "color": "#2196F3"
    }
  ],
  "totalCategories": 19
}
```

### Get Category by ID

```
GET /api/v1/categories/{categoryId}
```

**Example URL:**
```
GET /api/v1/categories/stroke
```

**Response:**

```json
{
  "id": "stroke",
  "name": "Stroke",
  "nameVi": "Động tác",
  "description": "Stroke mechanics and fundamentals",
  "itemCount": 13,
  "icon": "grip",
  "color": "#4CAF50",
  "items": [...],
  "subcategories": [],
  "relatedCategories": ["aim", "bridge", "grip"]
}
```

---

## 3. Search

### Search Knowledge Base

```
GET /api/v1/search
```

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `q` | string | required | Search query |
| `lang` | string | "en" | Language (en/vi) |
| `category` | string | null | Filter by category |
| `level` | string | null | Filter by level |
| `type` | string | null | Filter by type |
| `limit` | integer | 20 | Results limit |
| `offset` | integer | 0 | Pagination offset |

**Example URL:**
```
GET /api/v1/search?q=draw+shot&lang=en&level=G
```

**Response:**

```json
{
  "query": "draw shot",
  "language": "en",
  "results": [
    {
      "id": "cue_ball.draw",
      "title": "Draw Shot",
      "titleVi": "Cú Lùi",
      "category": "cue_ball",
      "categoryName": "Cue Ball Control",
      "level": "G",
      "score": 95,
      "highlights": {
        "title": "<em>Draw</em> <em>Shot</em>",
        "description": "Learn the <em>draw</em> <em>shot</em> technique..."
      },
      "type": "technique"
    },
    {
      "id": "stroke.speed_control",
      "title": "Speed Control",
      "category": "stroke",
      "score": 75,
      "highlights": {...}
    }
  ],
  "pagination": {
    "total": 15,
    "limit": 20,
    "offset": 0,
    "hasMore": false
  },
  "filters": {
    "categories": ["cue_ball", "stroke"],
    "levels": ["G", "F"]
  }
}
```

### Search with Autocomplete

```
GET /api/v1/search/autocomplete
```

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `q` | string | required | Partial query |
| `limit` | integer | 5 | Suggestions limit |

**Response:**

```json
{
  "suggestions": [
    {
      "text": "draw shot",
      "type": "technique",
      "category": "cue_ball",
      "id": "cue_ball.draw"
    },
    {
      "text": "draw backspin",
      "type": "technique",
      "category": "spin",
      "id": "spin.draw-shot"
    }
  ]
}
```

### Search with Fuzzy Matching

```
GET /api/v1/search/fuzzy
```

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `q` | string | required | Query (may contain misspellings) |
| `threshold` | float | 0.8 | Similarity threshold |

**Response:**

```json
{
  "query": "strok",
  "corrected": "stroke",
  "results": [...],
  "corrections": [
    {
      "original": "strok",
      "corrected": "stroke",
      "confidence": 0.9
    }
  ]
}
```

---

## 4. Relationship

### Get Relationships for Item

```
GET /api/v1/relationships/{itemId}
```

**Example URL:**
```
GET /api/v1/relationships/stroke.fundamentals
```

**Response:**

```json
{
  "itemId": "stroke.fundamentals",
  "relationships": [
    {
      "type": "prerequisite",
      "targetId": "stroke.straight_stroke",
      "targetTitle": "Straight Stroke",
      "weight": 1.0
    },
    {
      "type": "related",
      "targetId": "bridge.fundamentals",
      "targetTitle": "Bridge Fundamentals",
      "weight": 0.8
    },
    {
      "type": "teaches",
      "targetId": "stroke.pendulum_stroke",
      "targetTitle": "Pendulum Stroke",
      "weight": 0.9
    },
    {
      "type": "corrects",
      "targetId": "mistake.Jerky_Stroke",
      "targetTitle": "Jerky Stroke",
      "weight": 1.0
    }
  ],
  "total": 10
}
```

### Get Dependency Graph

```
GET /api/v1/relationships/graph
```

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `rootId` | string | null | Starting node |
| `depth` | integer | 3 | Traversal depth |
| `direction` | string | "both" | Direction (up/down/both) |

**Response:**

```json
{
  "nodes": [
    {
      "id": "stroke.fundamentals",
      "title": "Stroke Fundamentals",
      "level": "I"
    }
  ],
  "edges": [
    {
      "source": "stroke.fundamentals",
      "target": "stroke.straight_stroke",
      "type": "prerequisite"
    }
  ]
}
```

### Get Related Items

```
GET /api/v1/relationships/{itemId}/related
```

**Response:**

```json
{
  "itemId": "cue_ball.draw",
  "relatedItems": [
    {
      "id": "cue_ball.follow",
      "title": "Follow Shot",
      "titleVi": "Cú Theo",
      "category": "cue_ball",
      "relationshipType": "sibling",
      "relevanceScore": 0.9
    },
    {
      "id": "cue_ball.english",
      "title": "English",
      "titleVi": "Xoáy",
      "category": "cue_ball",
      "relationshipType": "advanced",
      "relevanceScore": 0.85
    }
  ]
}
```

---

## 5. Recommendation

### Get Recommendations

```
GET /api/v1/recommendations
```

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `userId` | string | null | User ID for personalization |
| `playerLevel` | string | null | Current player level |
| `category` | string | null | Preferred category |
| `limit` | integer | 10 | Number of recommendations |
| `type` | string | "all" | Recommendation type |

**Response:**

```json
{
  "recommendations": [
    {
      "itemId": "stroke.fundamentals",
      "title": "Stroke Fundamentals",
      "titleVi": "Nền tảng Động tác",
      "category": "stroke",
      "reason": "High importance for your level",
      "reasonCode": "HIGH_IMPORTANCE",
      "priority": 1,
      "estimatedTime": {
        "reading": 5,
        "practice": 120
      },
      "action": {
        "type": "start_learning",
        "label": "Start Learning",
        "path": "/learn/stroke/fundamentals"
      }
    }
  ],
  "total": 10
}
```

### Get Next Topic Recommendation

```
GET /api/v1/recommendations/next
```

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `currentItemId` | string | required | Current item ID |
| `userId` | string | null | User ID |

**Response:**

```json
{
  "currentItem": "stroke.straight_stroke",
  "recommendations": [
    {
      "itemId": "stroke.pendulum_stroke",
      "title": "Pendulum Stroke",
      "confidence": 0.95,
      "reason": "Recommended next topic"
    }
  ]
}
```

### Get Personalized Recommendations

```
POST /api/v1/recommendations/personalized
```

**Request Body:**

```json
{
  "userId": "user123",
  "playerLevel": "G",
  "completedItems": ["stroke.fundamentals", "bridge.fundamentals"],
  "weakAreas": ["cue_ball.control", "safety.play"],
  "timeAvailable": 30
}
```

**Response:**

```json
{
  "userId": "user123",
  "recommendations": [
    {
      "itemId": "cue_ball.draw",
      "title": "Draw Shot",
      "reason": "Addresses weak area: cue_ball.control",
      "priority": 1
    }
  ],
  "estimatedTimeToComplete": 180
}
```

---

## 6. Learning Path

### Get All Learning Paths

```
GET /api/v1/learning-paths
```

**Response:**

```json
{
  "learningPaths": [
    {
      "id": "path_beginner",
      "name": "Beginner Fundamentals",
      "nameVi": "Nền tảng cho người mới",
      "description": "Start your pool journey here",
      "level": "I",
      "duration": "40 hours",
      "itemCount": 15,
      "progress": 0
    },
    {
      "id": "path_intermediate",
      "name": "Intermediate Techniques",
      "nameVi": "Kỹ thuật trung cấp",
      "description": "Level up your game",
      "level": "G",
      "duration": "100 hours",
      "itemCount": 25,
      "progress": 0
    }
  ],
  "total": 10
}
```

### Get Learning Path by ID

```
GET /api/v1/learning-paths/{pathId}
```

**Example URL:**
```
GET /api/v1/learning-paths/path_beginner
```

**Response:**

```json
{
  "id": "path_beginner",
  "name": "Beginner Fundamentals",
  "nameVi": "Nền tảng cho người mới",
  "description": "Start your pool journey here",
  "level": "I",
  "duration": "40 hours",
  "estimatedHoursToComplete": 40,
  "steps": [
    {
      "order": 1,
      "itemId": "stroke.fundamentals",
      "title": "Stroke Fundamentals",
      "titleVi": "Nền tảng Động tác",
      "isRequired": true,
      "estimatedTime": {
        "reading": 5,
        "practice": 120
      },
      "prerequisites": [],
      "drills": ["STROKE001", "STROKE002"]
    },
    {
      "order": 2,
      "itemId": "bridge.fundamentals",
      "title": "Bridge Fundamentals",
      "titleVi": "Nền tảng Tay chống",
      "isRequired": true,
      "estimatedTime": {
        "reading": 5,
        "practice": 60
      },
      "prerequisites": ["stroke.fundamentals"],
      "drills": ["BRIDGE001"]
    }
  ],
  "milestones": [
    {
      "order": 1,
      "title": "Fundamentals Complete",
      "titleVi": "Hoàn thành Nền tảng",
      "requiredItems": ["stroke.fundamentals", "bridge.fundamentals", "grip.fundamentals"]
    }
  ]
}
```

### Get User Progress on Learning Path

```
GET /api/v1/learning-paths/{pathId}/progress
```

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `userId` | string | required | User ID |

**Response:**

```json
{
  "pathId": "path_beginner",
  "userId": "user123",
  "progress": {
    "completedItems": ["stroke.fundamentals"],
    "inProgressItems": ["bridge.fundamentals"],
    "currentItem": "bridge.fundamentals",
    "percentComplete": 6.67,
    "estimatedTimeRemaining": "37 hours",
    "completedMilestones": [],
    "nextMilestone": {
      "title": "Fundamentals Complete",
      "itemsRequired": 3,
      "itemsCompleted": 1
    }
  }
}
```

---

## 7. Drill Mapping

### Get All Drills

```
GET /api/v1/drills
```

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `category` | string | null | Filter by category |
| `difficulty` | string | null | Filter by difficulty |
| `duration` | integer | null | Max duration in minutes |
| `limit` | integer | 50 | Results limit |

**Response:**

```json
{
  "drills": [
    {
      "id": "STROKE001",
      "name": "Straight Stroke Drill",
      "nameVi": "Bài tập Động tác Thẳng",
      "description": "Practice stroke on straight line",
      "category": "stroke",
      "difficulty": "beginner",
      "duration": 15,
      "equipment": ["cue", "balls"],
      "objectives": ["Consistent stroke", "Follow through"],
      "successCriteria": ["100% accuracy on straight shots"]
    }
  ],
  "total": 200
}
```

### Get Drill by ID

```
GET /api/v1/drills/{drillId}
```

**Example URL:**
```
GET /api/v1/drills/STROKE001
```

**Response:**

```json
{
  "id": "STROKE001",
  "name": "Straight Stroke Drill",
  "nameVi": "Bài tập Động tác Thẳng",
  "description": "Practice stroke on straight line",
  "category": "stroke",
  "difficulty": "beginner",
  "duration": 15,
  "equipment": ["cue", "balls"],
  "setup": {
    "ballCount": 1,
    "ballPositions": ["foot spot"],
    "pocketTarget": "center pocket"]
  },
  "steps": [
    {
      "order": 1,
      "instruction": "Place ball on foot spot",
      "instructionVi": "Đặt bi ở điểm chân"
    },
    {
      "order": 2,
      "instruction": "Aim at center of far pocket",
      "instructionVi": "Ngắm vào tâm đáy xa"
    },
    {
      "order": 3,
      "instruction": "Execute smooth stroke",
      "instructionVi": "Thực hiện động tác mượt mà"
    }
  ],
  "tips": [
    "Focus on straight follow through",
    "Keep your head still"
  ],
  "commonMistakes": [
    {
      "mistake": "Jerky stroke",
      "solution": "Practice pendulum motion"
    }
  ],
  "variations": [
    {
      "name": "With guide rail",
      "difficulty": "beginner"
    }
  ]
}
```

### Get Drills for Knowledge Item

```
GET /api/v1/drills/by-item/{itemId}
```

**Example URL:**
```
GET /api/v1/drills/by-item/stroke.fundamentals
```

**Response:**

```json
{
  "itemId": "stroke.fundamentals",
  "drills": [
    {
      "id": "STROKE001",
      "name": "Straight Stroke Drill",
      "purpose": "Practice basic stroke",
      "priority": 1
    },
    {
      "id": "STROKE002",
      "name": "Pendulum Stroke Drill",
      "purpose": "Master pendulum motion",
      "priority": 2
    }
  ]
}
```

### Get Drills for Mistake

```
GET /api/v1/drills/by-mistake/{mistakeId}
```

**Example URL:**
```
GET /api/v1/drills/by-mistake/mistake.Jerky_Stroke
```

**Response:**

```json
{
  "mistakeId": "mistake.Jerky_Stroke",
  "drills": [
    {
      "id": "PEND001",
      "name": "Pendulum Basics",
      "purpose": "Fix jerky stroke with smooth pendulum",
      "priority": 1
    }
  ]
}
```

---

## 8. Strategy

### Get All Strategies

```
GET /api/v1/strategies
```

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `category` | string | null | Filter by category |
| `gameType` | string | null | Filter by game type (8-ball, 9-ball, etc.) |
| `phase` | string | null | Filter by game phase |
| `limit` | integer | 50 | Results limit |

**Response:**

```json
{
  "strategies": [
    {
      "id": "strategy.Play_Safe_When_in_Doubt",
      "title": "Play Safe When in Doubt",
      "titleVi": "Chơi An toàn Khi Nghi Ngờ",
      "category": "strategy",
      "gameTypes": ["8-ball", "9-ball", "straight pool"],
      "phase": "any",
      "description": "When unsure about a shot, play safe"
    }
  ],
  "total": 148
}
```

### Get Strategy by ID

```
GET /api/v1/strategies/{strategyId}
```

**Example URL:**
```
GET /api/v1/strategies/strategy.Play_Safe_When_in_Doubt
```

**Response:**

```json
{
  "id": "strategy.Play_Safe_When_in_Doubt",
  "title": "Play Safe When in Doubt",
  "titleVi": "Chơi An toàn Khi Nghi Ngờ",
  "category": "strategy",
  "gameTypes": ["8-ball", "9-ball", "straight pool"],
  "phase": "any",
  "description": "When unsure about a shot, play safe to avoid giving opponent an easy opportunity",
  "descriptionVi": "Khi không chắc chắn về cú đánh, hãy chơi an toàn để tránh tạo cơ hội dễ cho đối thủ",
  "whenToUse": {
    "situations": [
      "Unfamiliar ball or angle",
      "Difficult position required",
      "Opponent is playing well"
    ],
    "urgency": "medium"
  },
  "howToExecute": {
    "steps": [
      "Assess current balls on table",
      "Identify safe leave options",
      "Select highest percentage safety"
    ]
  },
  "alternatives": [
    "Play percentage shot if odds are good",
    "Play aggressive if ahead"
  ],
  "risks": [
    "Gives control to opponent",
    "May not always work"
  ],
  "relatedStrategies": [
    "strategy.Play_Safe",
    "strategy.Safety_Battle"
  ],
  "relatedTechniques": [
    "technique.Safety_Play",
    "technique.Defensive_Safety"
  ]
}
```

### Get Strategies by Game Type

```
GET /api/v1/strategies/game/{gameType}
```

**Example URL:**
```
GET /api/v1/strategies/game/8-ball
```

**Response:**

```json
{
  "gameType": "8-ball",
  "phases": {
    "break": {
      "title": "Break Phase Strategies",
      "strategies": [...]
    },
    "early": {
      "title": "Early Game Strategies",
      "strategies": [...]
    },
    "middle": {
      "title": "Middle Game Strategies",
      "strategies": [...]
    },
    "late": {
      "title": "Late Game Strategies",
      "strategies": [...]
    }
  }
}
```

---

## 9. Mistake

### Get All Mistakes

```
GET /api/v1/mistakes
```

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `category` | string | null | Filter by related category |
| `severity` | string | null | Filter by severity (low, medium, high) |
| `frequency` | string | null | Filter by frequency |
| `limit` | integer | 50 | Results limit |

**Response:**

```json
{
  "mistakes": [
    {
      "id": "mistake.Jerky_Stroke",
      "title": "Jerky Stroke",
      "titleVi": "Động tác Giật Cục",
      "category": "stroke",
      "severity": "high",
      "frequency": "common"
    }
  ],
  "total": 265
}
```

### Get Mistake by ID

```
GET /api/v1/mistakes/{mistakeId}
```

**Example URL:**
```
GET /api/v1/mistakes/mistake.Jerky_Stroke
```

**Response:**

```json
{
  "id": "mistake.Jerky_Stroke",
  "title": "Jerky Stroke",
  "titleVi": "Động tác Giật Cục",
  "category": "stroke",
  "severity": "high",
  "frequency": "common",
  "description": "The stroke accelerates unevenly, causing inconsistent contact",
  "descriptionVi": "Động tác tăng tốc không đều, gây ra tiếp xúc không nhất quán",
  "causes": [
    {
      "cause": "Tensing during backswing",
      "causeVi": "Căng cơ trong quá trình rút gậy"
    },
    {
      "cause": "Jerky trigger release",
      "causeVi": "Bộ triger nhả không đều"
    }
  ],
  "symptoms": [
    "Ball goes left or right unexpectedly",
    "Inconsistent ball speed",
    "Poor cue ball control"
  ],
  "correctiveActions": [
    {
      "action": "Practice pendulum stroke",
      "actionVi": "Luyện tập động tác con lắc",
      "drillId": "PEND001"
    },
    {
      "action": "Relax grip during backswing",
      "actionVi": "Thả lỏng tay cầm khi rút gậy"
    }
  ],
  "relatedItems": [
    {
      "id": "stroke.pendulum_stroke",
      "title": "Pendulum Stroke",
      "type": "teaches"
    },
    {
      "id": "stroke.rhythm",
      "title": "Rhythm",
      "type": "related"
    }
  ],
  "relatedDrills": [
    {
      "id": "PEND001",
      "name": "Pendulum Basics"
    },
    {
      "id": "RHY001",
      "name": "Metronome Drill"
    }
  ]
}
```

### Get Mistakes by Category

```
GET /api/v1/mistakes/category/{categoryId}
```

**Example URL:**
```
GET /api/v1/mistakes/category/stroke
```

**Response:**

```json
{
  "category": "stroke",
  "mistakes": [
    {
      "id": "mistake.Jerky_Stroke",
      "title": "Jerky Stroke",
      "severity": "high",
      "frequency": "common"
    },
    {
      "id": "mistake.Punch_Stroke",
      "title": "Punch Stroke",
      "severity": "medium",
      "frequency": "occasional"
    }
  ],
  "total": 15
}
```

---

## 10. Equipment

### Get All Equipment

```
GET /api/v1/equipment
```

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `category` | string | null | Filter by equipment category |
| `type` | string | null | Filter by equipment type |
| `limit` | integer | 50 | Results limit |

**Response:**

```json
{
  "equipment": [
    {
      "id": "equipment.playing_cue",
      "title": "Playing Cue",
      "titleVi": "Gậy Đánh Chính",
      "category": "cue",
      "type": "essential",
      "description": "Primary cue for regular play"
    }
  ],
  "total": 42
}
```

### Get Equipment by ID

```
GET /api/v1/equipment/{equipmentId}
```

**Example URL:**
```
GET /api/v1/equipment/equipment.playing_cue
```

**Response:**

```json
{
  "id": "equipment.playing_cue",
  "title": "Playing Cue",
  "titleVi": "Gậy Đánh Chính",
  "category": "cue",
  "type": "essential",
  "description": "The playing cue is your primary tool for executing shots...",
  "descriptionVi": "Gậy đánh chính là công cụ chính của bạn để thực hiện các cú đánh...",
  "specifications": {
    "length": {
      "value": "57-58 inches",
      "metric": "145-147 cm"
    },
    "weight": {
      "value": "18-21 oz",
      "metric": "510-595 g"
    },
    "tipSize": "12-13 mm"
  },
  "parts": [
    {
      "part": "tip",
      "material": "leather",
      "replacementInterval": "2-4 weeks"
    },
    {
      "part": "ferrule",
      "material": "brass or plastic"
    }
  ],
  "maintenance": {
    "cleaning": "Wipe after each session",
    "storage": "Vertical rack or case",
    "temperature": "Avoid extreme temperatures"
  },
  "relatedEquipment": [
    {
      "id": "equipment.jump_cue",
      "title": "Jump Cue",
      "type": "optional"
    },
    {
      "id": "equipment.break_cue",
      "title": "Break Cue",
      "type": "optional"
    }
  ],
  "recommendedProducts": [
    {
      "brand": "Various",
      "priceRange": "$50-500"
    }
  ]
}
```

---

## 11. Rules

### Get All Rules

```
GET /api/v1/rules
```

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `gameType` | string | null | Filter by game type |
| `type` | string | null | Filter by rule type |
| `limit` | integer | 50 | Results limit |

**Response:**

```json
{
  "rules": [
    {
      "id": "rule.8ball.call_shot",
      "title": "Call Shot Rules",
      "gameType": "8-ball",
      "category": "gameplay"
    }
  ],
  "total": 50
}
```

### Get Rules by Game Type

```
GET /api/v1/rules/game/{gameType}
```

**Example URL:**
```
GET /api/v1/rules/game/8-ball
```

**Response:**

```json
{
  "gameType": "8-ball",
  "gameTypeName": "8-Ball",
  "gameTypeNameVi": "Bida 8 Lỗ",
  "description": "The most popular pool game",
  "descriptionVi": "Trò chơi bida phổ biến nhất",
  "categories": {
    "basic": {
      "title": "Basic Rules",
      "rules": [...]
    },
    "break": {
      "title": "Break Rules",
      "rules": [...]
    },
    "fouls": {
      "title": "Foul Rules",
      "rules": [...]
    },
    "winning": {
      "title": "Winning Conditions",
      "rules": [...]
    }
  }
}
```

### Get Rule by ID

```
GET /api/v1/rules/{ruleId}
```

**Example URL:**
```
GET /api/v1/rules/rule.8ball.call_shot
```

**Response:**

```json
{
  "id": "rule.8ball.call_shot",
  "title": "Call Shot Rules",
  "titleVi": "Quy Tắc Gọi Bóng",
  "gameType": "8-ball",
  "category": "gameplay",
  "description": "In 8-ball, players must call their intended ball and pocket before shooting",
  "descriptionVi": "Trong bida 8 lỗ, người chơi phải gọi bóng và lỗ dự định trước khi đánh",
  "keyPoints": [
    {
      "point": "Call both ball and pocket",
      "pointVi": "Gọi cả bóng và lỗ"
    },
    {
      "point": "Ball can go in any called pocket",
      "pointVi": "Bóng có thể vào bất kỳ lỗ nào đã gọi"
    }
  ],
  "exceptions": [
    "Natural rolls (accidental) don't need to be called",
    "In some leagues, only 8-ball needs to be called"
  ],
  "penalties": [
    {
      "violation": "Ball not called",
      "penalty": "Ball remains if pocketed",
      "penaltyVi": "Bóng vẫn được tính nếu vào lỗ"
    }
  ],
  "relatedRules": [
    "rule.8ball.fouls",
    "rule.8ball.scratch"
  ]
}
```

---

## 12. Common Response Formats

### Success Response

```json
{
  "success": true,
  "data": { ... },
  "timestamp": "2026-07-17T09:59:00Z"
}
```

### Error Response

```json
{
  "success": false,
  "error": {
    "code": "ITEM_NOT_FOUND",
    "message": "Knowledge item not found",
    "messageVi": "Không tìm thấy mục kiến thức",
    "details": {
      "itemId": "invalid.id"
    }
  },
  "timestamp": "2026-07-17T09:59:00Z"
}
```

### Pagination Response

```json
{
  "pagination": {
    "total": 750,
    "limit": 20,
    "offset": 0,
    "page": 1,
    "totalPages": 38,
    "hasNext": true,
    "hasPrev": false
  }
}
```

---

## HTTP Status Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request |
| 404 | Not Found |
| 429 | Too Many Requests |
| 500 | Internal Server Error |

---

## Rate Limits

| Endpoint Type | Limit |
|---------------|-------|
| Search | 60 requests/minute |
| Knowledge Items | 100 requests/minute |
| Recommendations | 30 requests/minute |

---

## Caching Strategy

| Data Type | Cache Duration |
|-----------|---------------|
| Categories | 24 hours |
| Knowledge Items | 1 hour |
| Search Results | 5 minutes |
| Recommendations | 15 minutes |
| User Progress | 5 minutes |

---

*Generated: 2026-07-17*
*Pool OS Knowledge Base API v1.0*
