# Billiard Knowledge Module (BKM) - System Architecture

## Version 1.0
**Last Updated:** July 2026
**Status:** Production Specification

---

## 1.2 Knowledge Graph Architecture

The BKM is fundamentally a **Knowledge Graph** where every concept is a **Node** and every relationship is an **Edge**. This design enables rich interconnections between concepts, supporting AI-powered features like learning paths, semantic search, and intelligent recommendations.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         KNOWLEDGE GRAPH ARCHITECTURE                         │
└─────────────────────────────────────────────────────────────────────────────┘

                           ┌─────────────────────┐
                           │   KNOWLEDGE GRAPH    │
                           │                     │
                           │  ┌───────────────┐  │
                           │  │  Graph Nodes  │  │
                           │  │  (Concepts)   │  │
                           │  └───────┬───────┘  │
                           │          │           │
                           │  ┌───────▼───────┐  │
                           │  │  Graph Edges  │  │
                           │  │ (Relationships)│  │
                           │  └───────────────┘  │
                           └──────────┬──────────┘
                                      │
         ┌────────────────────────────┼────────────────────────────┐
         │                            │                            │
         ▼                            ▼                            ▼
┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐
│     NODE TYPES   │      │     EDGE TYPES   │      │   NODE STORAGE   │
│                 │      │                 │      │                 │
│ • Technique     │      │ • USES          │      │ • Neo4j        │
│ • Shot          │      │ • REQUIRES      │      │ • PostgreSQL  │
│ • Stroke        │      │ • RELATED_TO    │      │ • SQLite       │
│ • Spin          │      │ • OPPOSITE_OF  │      │ • Vector DB    │
│ • Equipment     │      │ • LEADS_TO     │      │                 │
│ • Rule          │      │ • TRAINED_BY   │      │                 │
│ • Drill         │      │ • ADVANCED_VER │      │                 │
│ • Strategy      │      │ • COMMON_ERROR │      │                 │
│ • Player        │      │ • + 30+ more  │      │                 │
│ • Tournament    │      │                 │      │                 │
│ • Media         │      │                 │      │                 │
│ • AI Prompt     │      │                 │      │                 │
└─────────────────┘      └─────────────────┘      └─────────────────┘
```

### 1.3 Graph vs Dictionary Comparison

| Feature | Traditional Dictionary | BKM Knowledge Graph |
|---------|------------------------|---------------------|
| **Concept Storage** | Isolated entries | Interconnected nodes |
| **Relationships** | See Also references | Typed edges with metadata |
| **Learning Paths** | Manual discovery | Traversible graph |
| **AI Context** | Single document | Connected context |
| **Search** | Keyword matching | Semantic + graph traversal |
| **Recommendations** | Basic | Relationship-based |
| **Versioning** | Document-level | Graph-level (v1, v2, v3) |
| **Offline** | Partial | Full graph sync |

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           PRESENTATION LAYER                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────────────┐   │
│  │   Flutter App   │  │   Web Client    │  │   Third-Party Integration   │   │
│  │   (iOS/Android) │  │   (Browser)     │  │   (External APIs)            │   │
│  └────────┬────────┘  └────────┬────────┘  └──────────────┬──────────────┘   │
│           │                    │                            │                  │
└───────────┼────────────────────┼────────────────────────────┼──────────────────┘
            │                    │                            │
            ▼                    ▼                            ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│                             API GATEWAY LAYER                                  │
│  ┌──────────────────────────────────────────────────────────────────────────┐ │
│  │                           REST API / GraphQL                              │ │
│  │  • Authentication    • Rate Limiting    • Request Validation               │ │
│  │  • Caching           • Load Balancing   • API Versioning                    │ │
│  └──────────────────────────────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────────────────────────────┘
            │                    │                            │
            ▼                    ▼                            ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│                            SERVICE LAYER                                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌────────────────────┐ │
│  │   Term      │  │   Search     │  │   Media      │  │   AI Service       │ │
│  │   Service   │  │   Service    │  │   Service    │  │                    │ │
│  │              │  │              │  │              │  │  • Explanation     │ │
│  │  • CRUD     │  │  • Full-text │  │  • Upload    │  │  • Recommendation │ │
│  │  • Version  │  │  • Vector    │  │  • Transform │  │  • Quiz Generation │ │
│  │  • Validate │  │  • Semantic   │  │  • CDN       │  │  • Learning Paths  │ │
│  └──────────────┘  └──────────────┘  └──────────────┘  └────────────────────┘ │
│                                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌────────────────────┐ │
│  │  Category    │  │ Translation  │  │ Relationship │  │   Sync Service     │ │
│  │  Service     │  │  Service    │  │  Service     │  │                    │ │
│  │              │  │              │  │              │  │  • Offline Queue  │ │
│  │  • Tree      │  │  • Detect    │  │  • Graph DB  │  │  • Conflict Res    │ │
│  │  • Navigate  │  │  • Transform │  │  • Traverse  │  │  • Delta Sync      │ │
│  │  • Hierarchy │  │  • Validate  │  │  • Validate  │  │                    │ │
│  └──────────────┘  └──────────────┘  └──────────────┘  └────────────────────┘ │
└───────────────────────────────────────────────────────────────────────────────┘
            │                    │                            │
            ▼                    ▼                            ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│                            DATA LAYER                                           │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────────────┐     │
│  │   PostgreSQL    │  │    SQLite       │  │   Vector Database           │     │
│  │   (Supabase)    │  │   (Offline)     │  │   (Pinecone/Milvus)         │     │
│  │                  │  │                  │  │                             │     │
│  │  • Primary Store │  │  • Local Cache   │  │  • Semantic Search          │     │
│  │  • Real-time    │  │  • Offline Mode   │  │  • Similarity Search        │     │
│  │  • Relational   │  │  • Sync Target    │  │  • Embeddings Storage       │     │
│  └─────────────────┘  └─────────────────┘  └─────────────────────────────┘     │
│                                                                               │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────────────┐     │
│  │   Object Store  │  │   Graph DB      │  │   Cache Layer               │     │
│  │   (S3/GCS)      │  │   (Neo4j)       │  │   (Redis)                   │     │
│  │                  │  │                  │  │                             │     │
│  │  • Media Files  │  │  • Relationships │  │  • Session Cache            │     │
│  │  • Exports      │  │  • Graph Queries │  │  • Query Results             │     │
│  │  • Backups      │  │  • Path Finding  │  │  • Rate Limit Counters       │     │
│  └─────────────────┘  └─────────────────┘  └─────────────────────────────┘     │
└───────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Technology Stack

#### 1.2.1 Core Technologies

| Layer | Technology | Purpose | Justification |
|-------|------------|---------|---------------|
| **Mobile** | Flutter 3.x | Cross-platform app | Single codebase, performance |
| **Database** | PostgreSQL (Supabase) | Primary data store | Reliability, real-time, RLS |
| **Offline** | SQLite | Local storage | Offline-first, zero latency |
| **Vector** | Pinecone/Milvus | Semantic search | Scalable embeddings |
| **Graph** | Neo4j | Relationship storage | Complex queries, traversal |
| **Cache** | Redis | Caching layer | Speed, rate limiting |
| **LLM** | OpenAI/Claude | AI features | Domain expertise |
| **CDN** | Cloudflare/GCS | Media delivery | Global performance |

#### 1.2.2 Alternative Technology Mappings

| Component | Primary | Alternative 1 | Alternative 2 |
|-----------|---------|--------------|---------------|
| **Relational DB** | Supabase | PostgreSQL Direct | PlanetScale |
| **Offline DB** | SQLite | Hive | ObjectBox |
| **Vector DB** | Pinecone | Milvus | Weaviate |
| **Graph DB** | Neo4j | Dgraph | Amazon Neptune |
| **LLM Provider** | OpenAI | Claude | Local (Ollama) |
| **Object Storage** | GCS | S3 | R2 |

---

## 2. Module Structure

### 2.1 Directory Organization

```
bkm/                          # Billiard Knowledge Module root
├── src/
│   ├── core/                 # Shared utilities and base classes
│   │   ├── base/             # Base entities, interfaces
│   │   ├── constants/        # System-wide constants
│   │   ├── errors/           # Error definitions
│   │   ├── utils/            # Utility functions
│   │   └── types/            # TypeScript/Dart types
│   │
│   ├── domain/               # Domain logic (framework-agnostic)
│   │   ├── entities/         # Business entities
│   │   │   ├── term/
│   │   │   ├── category/
│   │   │   ├── translation/
│   │   │   ├── media/
│   │   │   └── relationship/
│   │   ├── repositories/     # Repository interfaces
│   │   ├── services/         # Domain services
│   │   └── value-objects/    # Immutable value types
│   │
│   ├── application/          # Application services and use cases
│   │   ├── commands/         # Write operations (CQRS)
│   │   ├── queries/          # Read operations
│   │   ├── handlers/        # Command/Query handlers
│   │   └── validators/      # Input validation
│   │
│   ├── infrastructure/       # External implementations
│   │   ├── database/         # Supabase/SQLite implementations
│   │   │   ├── supabase/
│   │   │   └── sqlite/
│   │   ├── vector/           # Vector DB implementations
│   │   ├── graph/            # Graph DB implementations
│   │   ├── cache/            # Redis implementations
│   │   ├── ai/               # LLM implementations
│   │   └── media/            # Media handling
│   │
│   └── presentation/         # API and UI presentation
│       ├── api/              # REST/GraphQL endpoints
│       ├── dto/              # Data transfer objects
│       └── mappers/          # Entity <-> DTO mappers
│
├── docs/                     # Documentation
│   ├── architecture/
│   ├── api/
│   └── guides/
│
├── migrations/               # Database migrations
│   ├── supabase/
│   └── sqlite/
│
└── tests/                    # Test suites
    ├── unit/
    ├── integration/
    └── e2e/
```

### 2.2 Flutter App Structure

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   └── utils/
│
├── data/
│   ├── datasources/
│   │   ├── local/            # SQLite datasources
│   │   └── remote/           # Supabase datasources
│   ├── models/               # Data models (JSON serialization)
│   ├── repositories/         # Repository implementations
│   └── mappers/              # Model <-> Entity mappers
│
├── domain/
│   ├── entities/              # Business entities
│   ├── repositories/         # Abstract repository interfaces
│   └── usecases/             # Business logic use cases
│
└── presentation/
    ├── pages/
    ├── widgets/
    ├── blocs/                 # State management
    └── providers/             # Dependency injection
```

---

## 3. Component Relationships

### 3.1 Knowledge Graph Relationship Model

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           KNOWLEDGE GRAPH MODEL                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                              NODE HIERARCHY                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  KNOWLEDGE ─────────────────────────────────────────────────────────────── │
│  ├── TECHNIQUE ────────────────────────────────────────────────────────── │
│  │   ├── Shot (Draw Shot, Follow Shot, Stun Shot, Jump Shot, Masse Shot) │
│  │   ├── Stroke (Power Stroke, Precision Stroke, Safety Stroke)          │
│  │   ├── Spin (Backspin, Topspin, English, Running English)             │
│  │   ├── Position (Position Play, Ghost Ball)                           │
│  │   └── Aim (Contact Point, Object Ball Aiming)                        │
│  │                                                                       │
│  ├── CONCEPT ──────────────────────────────────────────────────────────── │
│  │   ├── Rule (Foul Rules, Ball-in-Hand, Jump Ball Rules)              │
│  │   ├── Pattern (Pattern Running, Pattern Play)                        │
│  │   ├── Strategy (Offensive, Defensive, Safety Play)                    │
│  │   ├── Mistake (Scooping, Misjudgment, Poor Position)                 │
│  │   └── Mental (Focus, Pressure, Visualization)                        │
│  │                                                                       │
│  ├── EQUIPMENT ───────────────────────────────────────────────────────── │
│  │   ├── Cue, Shaft, Tip, Ball, Table, Accessory                        │
│  │                                                                       │
│  ├── TRAINING ─────────────────────────────────────────────────────────── │
│  │   ├── Drill, Exercise, Training Plan, Scenario                        │
│  │                                                                       │
│  ├── PHYSICS ──────────────────────────────────────────────────────────── │
│  │   ├── Math (Angle Calculation, Speed Physics)                        │
│  │   └── Mechanics (Cue Action, Ball Collision)                         │
│  │                                                                       │
│  ├── ORGANIZATION ─────────────────────────────────────────────────────── │
│  │   ├── Tournament, Player, Organization, Coach                         │
│  │                                                                       │
│  ├── MEDIA ────────────────────────────────────────────────────────────── │
│  │   ├── Video, Animation, Image, Article, Book                         │
│  │                                                                       │
│  └── KNOWLEDGE ────────────────────────────────────────────────────────── │
│      ├── Question, Answer, AI Prompt                                      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                           EDGE TYPE TAXONOMY                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  HIERARCHICAL ─────────────────────────────────────────────────────────── │
│  └── IS_A, PART_OF, SAME_AS, SYNONYM, ANTONYM                            │
│                                                                             │
│  DEPENDENCY ───────────────────────────────────────────────────────────── │
│  └── USES, REQUIRES, CAUSES, PREVENTS, CORRECTED_BY                      │
│                                                                             │
│  PROGRESSION ──────────────────────────────────────────────────────────── │
│  └── LEADS_TO, NEXT_LEVEL, ADVANCED_VERSION, TRAINED_BY                  │
│                                                                             │
│  ASSOCIATION ──────────────────────────────────────────────────────────── │
│  └── RELATED_TO, OPPOSITE_OF, CONFUSES_WITH, DISTINGUISHED_FROM           │
│                                                                             │
│  CONTAINER ────────────────────────────────────────────────────────────── │
│  └── CONTAINS, COMPOSED_OF, APPLICABLE_TO                                │
│                                                                             │
│  EVALUATION ───────────────────────────────────────────────────────────── │
│  └── MORE_IMPORTANT_THAN, RECOMMENDED_FOR, NOT_RECOMMENDED_FOR           │
│                                                                             │
│  MEDIA ────────────────────────────────────────────────────────────────── │
│  └── VIDEO_EXPLAINS, IMAGE_SHOWS, ANIMATION_SHOWS, ARTICLE_EXPLAINS      │
│                                                                             │
│  PROVENANCE ───────────────────────────────────────────────────────────── │
│  └── INVENTED_BY, POPULARIZED_BY, TAUGHT_BY, DOCUMENTED_BY               │
│                                                                             │
│  CONTEXT ───────────────────────────────────────────────────────────────── │
│  └── USED_IN, RULE_APPLIES, COMMON_ERROR                                 │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                        EXAMPLE: DRAW SHOT GRAPH                             │
└─────────────────────────────────────────────────────────────────────────────┘

                          ┌─────────────┐
                          │  DRAW SHOT  │
                          │   (Node)    │
                          └──────┬──────┘
                                 │
     ┌───────────────────────────┼───────────────────────────┐
     │                           │                           │
     ▼                           ▼                           ▼
┌───────────┐             ┌───────────┐             ┌───────────┐
│   USES    │             │ OPPOSITE  │             │PREREQUISITE│
│ Backspin  │             │Follow Shot│             │ Stop Shot  │
└─────┬─────┘             └───────────┘             └─────┬─────┘
      │                                                   │
      ▼                                                   ▼
┌───────────┐             ┌───────────┐             ┌───────────┐
│  USES     │             │LEADS_TO   │             │LEADS_TO   │
│Low Contact│             │Power Draw │             │Stun Shot  │
└─────┬─────┘             └───────────┘             └───────────┘
      │
      ▼
┌───────────┐             ┌───────────┐             ┌───────────┐
│  PART_OF  │             │TRAINED_BY │             │NEXT_LEVEL │
│Spin Tech  │             │ Drill-013 │             │Int. Draw  │
└───────────┘             └───────────┘             └───────────┘


```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           ENTITY RELATIONSHIP MODEL                           │
└─────────────────────────────────────────────────────────────────────────────┘

                                    ┌──────────────┐
                                    │  Discipline  │
                                    │              │
                                    │ • id         │
                                    │ • code       │
                                    │ • name       │
                                    │ • variants[] │
                                    └──────┬───────┘
                                           │
                                           │ 1:N
                                           ▼
┌──────────────┐     N:1     ┌──────────────┐     1:N     ┌──────────────┐
│   Media      │◄────────────│    Term      │────────────►│   Category    │
│              │             │              │             │               │
│ • id         │             │ • id         │             │ • id          │
│ • url        │             │ • slug        │             │ • parent_id   │
│ • type       │             │ • status      │             │ • name        │
│ • metadata   │             │ • created_at  │             │ • path        │
│ • alt_text   │             │ • updated_at  │             │ • discipline  │
└──────────────┘             └──────┬───────┘             └───────────────┘
       │                           │ │
       │                           │ │ N:M (via junction table)
       │                           │ ▼
       │                    ┌──────────────┐
       │                    │   Term_Tag    │
       │                    │               │
       │                    │ • term_id     │
       │                    │ • tag_id      │
       │                    └──────────────┘
       │                           │
       │                           │ N:1
       │                           ▼
       │                    ┌──────────────┐
       │                    │     Tag       │
       │                    │               │
       │                    │ • id          │
       │                    │ • name        │
       │                    │ • category    │
       │                    │ • language    │
       │                    └───────────────┘
       │
       │
       │
┌──────────────┐     N:1     ┌──────────────┐
│   Media_Meta  │◄────────────│   Media       │
│               │             │               │
│ • id          │             │ • id          │
│ • media_id    │             │ • url         │
│ • width       │             │ • type        │
│ • height      │             │ • mime_type   │
│ • duration    │             │ • size        │
│ • thumbnail   │             │ • checksum    │
└───────────────┘             └───────────────┘


┌─────────────────────────────────────────────────────────────────────────────┐
│                           TRANSLATION HIERARCHY                               │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────┐     N:1     ┌──────────────┐
│  Definition   │◄────────────│     Term      │
│               │             │               │
│ • id          │             │ • id          │
│ • term_id     │             │ • slug        │
│ • language    │             └──────┬───────┘
│ • definition  │                    │ 1:N
│ • explanation │                    ▼
│ • examples[]  │             ┌──────────────┐
│ • usage_notes │             │ Translation  │
└───────────────┘             │               │
                              │ • id          │
                              │ • term_id     │
                              │ • language    │
                              │ • name        │
┌──────────────┐     N:1     │ • summary     │
│   Example     │◄────────────┤ • phonetic    │
│               │             └───────────────┘
│ • id          │
│ • definition_id        1:N
│ • text        │             ┌──────────────┐
│ • translation │             │    Alias     │
│ • audio_url   │             │               │
└───────────────┘             │ • id          │
                              │ • term_id     │
┌──────────────┐     N:1     │ • text        │
│    Usage      │◄────────────│ • language    │
│               │             │ • type        │
│ • id          │             │ • is_official │
│ • definition_id             └───────────────┘
│ • text        │
│ • context     │
│ • translation │
└───────────────┘


┌─────────────────────────────────────────────────────────────────────────────┐
│                           RELATIONSHIP GRAPH                                  │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                           │
│   Term A ─────uses────────► Technique                                     │
│     │                                                                      │
│     │                                                                      │
│     ├──prerequisite──► Basic Skill ────advanced_into──► Advanced Skill    │
│     │                                                                      │
│     ├──related────────► Related Concept                                   │
│     │                                                                      │
│     ├──opposite───────► Contrasting Term                                  │
│     │                                                                      │
│     └──part_of───────► Category                                           │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────────┘

                         ┌──────────────┐
                         │ Relationship │
                         │              │
                         │ • source_id │
                         │ • target_id │
                         │ • type      │
                         │ • weight    │
                         │ • metadata  │
                         └──────────────┘
```

### 3.2 Data Flow Diagrams

#### 3.2.1 Term Search Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           SEARCH DATA FLOW                                    │
└─────────────────────────────────────────────────────────────────────────────┘

User Input: "draw shot"
     │
     ▼
┌─────────────────┐
│  Input Parser   │
│  • Tokenize     │
│  • Normalize    │
│  • Detect lang  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐      ┌─────────────────┐
│  Alias Resolver  │─────►│  Term Lookup    │
│  (misspellings)  │      │  (slug match)   │
└────────┬────────┘      └────────┬────────┘
         │                         │
         │                         ▼
         │                ┌─────────────────┐
         │                │  SQLite Cache   │
         │                │  (offline)      │
         │                └────────┬────────┘
         │                         │
         │                         ▼
         │                ┌─────────────────┐
         └───────────────►│  Full-Text      │◄──── PostgreSQL
                          │  Search (FTS5)  │      (Supabase)
                          └────────┬────────┘
                                   │
                                   ▼
                          ┌─────────────────┐
                          │  Vector Search  │
                          │  (semantic)     │
                          └────────┬────────┘
                                   │
                                   ▼
                          ┌─────────────────┐
                          │  Rank & Merge   │
                          │  • TF-IDF       │
                          │  • BM25         │
                          │  • Vector sim   │
                          └────────┬────────┘
                                   │
                                   ▼
                          ┌─────────────────┐
                          │  Results        │
                          │  • Terms        │
                          │  • Related      │
                          │  • Suggestions │
                          └─────────────────┘
```

#### 3.2.2 Content Sync Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SYNC DATA FLOW                                       │
└─────────────────────────────────────────────────────────────────────────────┘

                    ┌─────────────────────────────────────────────┐
                    │                 Cloud                       │
                    │  ┌─────────────────────────────────────┐   │
                    │  │         Supabase (PostgreSQL)        │   │
                    │  │  • Terms    • Categories            │   │
                    │  │  • Translations • Media             │   │
                    │  │  • Relationships                     │   │
                    │  └──────────────┬────────────────────────┘   │
                    │                 │                           │
                    │                 │ Change Detection          │
                    │                 ▼                           │
                    │  ┌─────────────────────────────────────┐   │
                    │  │            Sync Log                 │   │
                    │  │  • Entity    • Operation           │   │
                    │  │  • Timestamp • Checksum            │   │
                    │  └──────────────┬────────────────────────┘   │
                    │                 │                           │
                    └─────────────────┼───────────────────────────┘
                                      │ Delta Sync
                                      │ WebSocket / Polling
                                      │
┌─────────────────────────────────────┼───────────────────────────────────────┐
│                                     ▼                                        │
│                    ┌─────────────────────────────────────┐                    │
│                    │           Sync Service              │                    │
│                    │  • Conflict Detection               │                    │
│                    │  • Resolution Strategy             │                    │
│                    │  • Delta Compression                │                    │
│                    └──────────────┬──────────────────────┘                    │
│                                     │                                        │
│                                     ▼                                        │
│                    ┌─────────────────────────────────────┐                    │
│                    │           SQLite (Local)             │                    │
│                    │  • Full knowledge copy              │                    │
│                    │  • Indexed for search               │                    │
│                    │  • Pending changes queue             │                    │
│                    └─────────────────────────────────────┘                    │
│                                      │                                        │
│                                      ▼                                        │
│                    ┌─────────────────────────────────────┐                    │
│                    │           Flutter App               │                    │
│                    │  • Immediate local access           │                    │
│                    │  • Background sync                  │                    │
│                    │  • Offline-first UI                 │                    │
│                    └─────────────────────────────────────┘                    │
│                                      │                                        │
│                         User Interaction / Queries                            │
└──────────────────────────────────────┴────────────────────────────────────────┘
```

#### 3.2.3 AI Context Injection Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        AI INTEGRATION FLOW                                    │
└─────────────────────────────────────────────────────────────────────────────┘

User Query: "How do I execute a draw shot?"
     │
     ▼
┌─────────────────┐
│  Query Analysis │
│  • Intent       │
│  • Entities     │
│  • Context      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐      ┌─────────────────┐
│  Context Loader │─────►│   Term Lookup   │
│                 │      │   (Draw Shot)   │
└────────┬────────┘      └────────┬────────┘
         │                          │
         │                          ▼
         │                 ┌─────────────────┐
         │                 │ Relationship    │
         │                 │ Graph Traverse  │
         │                 │ • Prerequisites │
         │                 │ • Related Terms │
         │                 │ • Examples      │
         │                 └────────┬────────┘
         │                          │
         │                          ▼
         │                 ┌─────────────────┐
         │                 │   Media        │
         │                 │   Assets       │
         │                 │ • Videos       │
         │                 │ • Animations   │
         │                 │ • Diagrams     │
         │                 └────────┬────────┘
         │                          │
         └──────────────────────────┼──────────────────────┐
                                    │                      │
                                    ▼                      ▼
                         ┌─────────────────┐      ┌─────────────────┐
                         │  Prompt Builder │      │  Vector Search  │
                         │                 │      │  (Similar docs) │
                         │ • System prompt │      └────────┬────────┘
                         │ • Context       │               │
                         │ • Few-shot     │               │
                         │ • Constraints   │               │
                         └────────┬────────┘               │
                                  │                         │
                                  ▼                         │
                         ┌─────────────────┐               │
                         │     LLM API      │◄──────────────┘
                         │  (GPT-4/Claude)  │
                         └────────┬────────┘
                                  │
                                  ▼
                         ┌─────────────────┐
                         │ Response Parser │
                         │ • Format        │
                         │ • Citation      │
                         │ • Validation    │
                         └────────┬────────┘
                                  │
                                  ▼
                         ┌─────────────────┐
                         │   UI Render     │
                         │ • Markdown      │
                         │ • Media embed   │
                         │ • Actions       │
                         └─────────────────┘
```

---

## 4. Scalability Considerations

### 4.1 Horizontal Scaling Strategy

| Component | Scaling Strategy | Maximum Scale |
|-----------|-----------------|---------------|
| **API Servers** | Stateless, load-balanced | 100+ instances |
| **Database** | Read replicas, sharding | 10M+ records |
| **Vector DB** | Distributed index | 1B+ vectors |
| **Cache** | Redis Cluster | 1M+ ops/sec |
| **Media CDN** | Global edge network | Unlimited |

### 4.2 Performance Targets

| Metric | Target | Measurement |
|--------|--------|-------------|
| **API p50 Latency** | <50ms | APM tracking |
| **API p99 Latency** | <200ms | APM tracking |
| **Search p50** | <100ms | Search analytics |
| **Sync Latency** | <5s | Sync monitoring |
| **Offline Query** | <10ms | Local benchmarks |

### 4.3 Capacity Planning

```
Term Count Projections:
────────────────────────────────────────────────────────
Version │ Terms    │ Translations │ Total Entities
────────────────────────────────────────────────────────
v1.0   │ 500      │ 2 (EN, VI)  │ ~15,000
v2.0   │ 2,000    │ 5 languages │ ~80,000
v3.0   │ 5,000    │ 10 languages│ ~250,000
────────────────────────────────────────────────────────

Storage Requirements:
────────────────────────────────────────────────────────
Component      │ v1.0    │ v2.0    │ v3.0
────────────────────────────────────────────────────────
PostgreSQL     │ 50 MB   │ 200 MB  │ 500 MB
SQLite (local) │ 30 MB   │ 120 MB  │ 300 MB
Vector DB      │ 10 GB   │ 40 GB   │ 100 GB
Media Storage  │ 50 GB   │ 200 GB  │ 500 GB
────────────────────────────────────────────────────────
```

---

## 5. Technology-Agnostic Design Principles

### 5.1 Abstraction Layers

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         ABSTRACTION LAYER MODEL                               │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                              │
│   ┌─────────────────────────────────────────────────────────────────────┐    │
│   │                    PRESENTATION LAYER                                 │    │
│   │   Flutter │ Web │ Mobile │ Third-Party                               │    │
│   └─────────────────────────────────────────────────────────────────────┘    │
│                                    │                                         │
│                                    ▼                                         │
│   ┌─────────────────────────────────────────────────────────────────────┐    │
│   │                      APPLICATION LAYER                              │    │
│   │                                                                      │    │
│   │   ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐    │    │
│   │   │  Use Cases  │  │  Validators │  │  DTOs & Mappers        │    │    │
│   │   └─────────────┘  └─────────────┘  └─────────────────────────┘    │    │
│   │                                                                      │    │
│   │   Contracts (Interfaces):                                           │    │
│   │   • ITermRepository                                                 │    │
│   │   • ISearchService                                                  │    │
│   │   • ITranslationService                                             │    │
│   │   • IAIContextProvider                                              │    │
│   │                                                                      │    │
│   └─────────────────────────────────────────────────────────────────────┘    │
│                                    │                                         │
│                                    ▼                                         │
│   ┌─────────────────────────────────────────────────────────────────────┐    │
│   │                       DOMAIN LAYER                                   │    │
│   │                                                                      │    │
│   │   Entities: Term, Category, Translation, Media, Relationship       │    │
│   │   Value Objects: Slug, Language, Status, Tag                       │    │
│   │   Domain Events: TermCreated, TranslationAdded, RelationshipLinked │    │
│   │                                                                      │    │
│   └─────────────────────────────────────────────────────────────────────┘    │
│                                    │                                         │
│                                    ▼                                         │
│   ┌─────────────────────────────────────────────────────────────────────┐    │
│   │                    INFRASTRUCTURE LAYER                             │    │
│   │                                                                      │    │
│   │   ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐    │    │
│   │   │  Supabase   │  │   SQLite    │  │   Vector DB             │    │    │
│   │   │  (Remote)   │  │  (Local)    │  │   (Semantic)            │    │    │
│   │   └─────────────┘  └─────────────┘  └─────────────────────────┘    │    │
│   │                                                                      │    │
│   │   ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐    │    │
│   │   │  Neo4j      │  │   Redis     │  │   LLM Providers         │    │    │
│   │   │  (Graph)    │  │  (Cache)    │  │   (AI)                  │    │    │
│   │   └─────────────┘  └─────────────┘  └─────────────────────────┘    │    │
│   │                                                                      │    │
│   └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.2 Repository Pattern Implementation

```dart
// Domain Layer - Interface
abstract class ITermRepository {
  Future<Term?> getById(String id);
  Future<Term?> getBySlug(String slug, Language language);
  Future<List<Term>> search(SearchQuery query);
  Future<List<Term>> getRelated(String termId);
  Future<Term> create(CreateTermCommand command);
  Future<Term> update(UpdateTermCommand command);
  Future<void> delete(String id);
  Stream<Term> watch(String id);
}

// Infrastructure Layer - Implementations

// Supabase Implementation
class SupabaseTermRepository implements ITermRepository {
  final SupabaseClient _client;
  
  @override
  Future<Term?> getBySlug(String slug, Language language) async {
    final response = await _client
        .from('terms')
        .select('*, translations(*), definitions(*)')
        .eq('slug', slug)
        .eq('language', language.code)
        .single();
    return TermMapper.fromSupabase(response);
  }
}

// SQLite Implementation (Offline)
class SQLiteTermRepository implements ITermRepository {
  final Database _db;
  
  @override
  Future<Term?> getBySlug(String slug, Language language) async {
    final result = await _db.query(
      'terms',
      where: 'slug = ? AND language = ?',
      whereArgs: [slug, language.code],
    );
    if (result.isEmpty) return null;
    return TermMapper.fromSQLite(result.first);
  }
}
```

### 5.3 Service Locator / DI Pattern

```dart
// Flutter - Service Registration
class ServiceLocator {
  static final _locator = ServiceLocator._();
  factory ServiceLocator() => _locator;
  
  void register<T>(T instance) => _services[T] = instance;
  void registerFactory<T>(FactoryFunc<T> factory) => _factories[T] = factory;
  void registerLazy<T>(FactoryFunc<T> factory) => _lazy[T] = factory;
  
  T get<T>() {
    if (_services.containsKey(T)) return _services[T] as T;
    if (_factories.containsKey(T)) return _factories[T]!();
    if (_lazy.containsKey(T)) {
      _services[T] = _lazy[T]!();
      return _services[T] as T;
    }
    throw Exception('Service $T not registered');
  }
}

// Usage in Flutter
void setupServices() {
  final locator = ServiceLocator();
  
  // Repositories
  locator.registerLazy<ITermRepository>(() => 
    SQLiteTermRepository(DatabaseService.instance));
  locator.registerLazy<IRemoteTermRepository>(() => 
    SupabaseTermRepository(Supabase.instance));
  
  // Services
  locator.registerLazy<ISearchService>(() => 
    SearchService(
      localRepo: locator.get<ITermRepository>(),
      remoteRepo: locator.get<IRemoteTermRepository>(),
      vectorRepo: locator.get<IVectorRepository>(),
    ));
  
  // AI
  locator.registerLazy<IAIContextProvider>(() => 
    OpenAIContextProvider(locator.get<ITermRepository>()));
}
```

---

## 6. Data Consistency Guarantees

### 6.1 Consistency Model

| Operation | Consistency Level | Mechanism |
|-----------|------------------|----------|
| **Read** | Eventual (default) | Async replication |
| **Search** | Eventual | Index refresh delay |
| **Write** | Strong | Transaction + Sync |
| **Delete** | Soft delete | `deleted_at` timestamp |
| **Relation** | Cascading | Application logic |

### 6.2 Conflict Resolution

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      CONFLICT RESOLUTION STRATEGY                             │
└─────────────────────────────────────────────────────────────────────────────┘

Scenario: Same term edited on multiple devices

┌─────────────┐                     ┌─────────────┐
│  Device A   │                     │  Device B   │
│  Edit v1→v2 │                     │  Edit v1→v3 │
└──────┬──────┘                     └──────┬──────┘
       │                                   │
       │           ┌─────────────┐          │
       └──────────►│   Sync     │◄────────┘
                   │   Server    │
                   └──────┬──────┘
                          │
                          ▼
            ┌─────────────────────────────┐
            │     Conflict Detection      │
            │  • Same entity modified     │
            │  • Different versions       │
            └──────────────┬──────────────┘
                           │
            ┌──────────────┴──────────────┐
            │     Resolution Strategy     │
            ├──────────────────────────────┤
            │ 1. Last-Write-Wins (default) │
            │ 2. Field-level merge        │
            │ 3. Manual conflict UI       │
            │ 4. Domain expert review     │
            └──────────────────────────────┘
                           │
                           ▼
                   ┌───────────────┐
                   │   Resolved    │
                   │   Version     │
                   └───────────────┘
```

---

## 7. Security Architecture

### 7.1 Authentication Flow (Future)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         AUTHENTICATION FLOW                                   │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│  Client  │────►│  Supabase│────►│   Auth   │────►│  JWT     │
│          │     │  Client  │     │  Service │     │  Token   │
└──────────┘     └──────────┘     └──────────┘     └──────────┘
     │                                                    │
     │                                                    ▼
     │                                           ┌──────────────┐
     │                                           │   Resource   │
     │                                           │   Server     │
     │                                           └───────┬──────┘
     │                                                   │
     │◄──────────────────────────────────────────────────┘
```

### 7.2 Row-Level Security (Supabase)

```sql
-- Enable RLS on terms table
ALTER TABLE terms ENABLE ROW LEVEL SECURITY;

-- Public read for published terms
CREATE POLICY "Public read published" ON terms
  FOR SELECT USING (
    status = 'published' 
    OR auth.role() = 'admin'
    OR auth.uid() = created_by
  );

-- Authenticated users can create
CREATE POLICY "Authenticated create" ON terms
  FOR INSERT WITH CHECK (auth.role() IN ('authenticated', 'admin'));

-- Only admins can delete
CREATE POLICY "Admin delete" ON terms
  FOR DELETE USING (auth.role() = 'admin');
```

---

## 8. Monitoring and Observability

### 8.1 Metrics Collection

| Metric Category | Examples | Collection |
|-----------------|----------|------------|
| **Infrastructure** | CPU, Memory, Disk | System monitors |
| **Application** | Request count, latency | APM agent |
| **Business** | Search queries, term views | Custom events |
| **Error** | Exception rate, stack traces | Error tracker |

### 8.2 Logging Strategy

```
Log Levels:
────────────────────────────────────────────────────────
Level    │ Use Case                          │ Retention
────────────────────────────────────────────────────────
DEBUG    │ Development, troubleshooting      │ 7 days
INFO     │ Normal operations                 │ 30 days
WARNING  │ Recoverable issues               │ 90 days
ERROR    │ Failures requiring attention      │ 1 year
CRITICAL │ System down, data corruption      │ 5 years
────────────────────────────────────────────────────────
```

---

## 9. Appendix

### 9.1 Related Documents

- [BKM Project Vision](./01_Project_Vision.md)
- [BKM Database Schema](./03_Database.md)
- [BKM API Design](./15_API_Design_For_PoolOS.md)
- [BKM Search System](./05_Search_System.md)

### 9.2 Technology References

- Flutter: https://flutter.dev
- Supabase: https://supabase.com
- SQLite: https://sqlite.org
- Neo4j: https://neo4j.com
- Pinecone: https://pinecone.io
- Redis: https://redis.io

---

**End of Document**
