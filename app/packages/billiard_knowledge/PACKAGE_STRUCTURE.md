# Billiard Knowledge Package Structure

## Overview

```
packages/
└── billiard_knowledge/
    ├── lib/
    │   ├── billiard_knowledge.dart      # Main entry point
    │   └── src/
    │       ├── billiard_knowledge.dart  # Core library class
    │       │
    │       ├── models/                  # Data models
    │       │   ├── models.dart         # Barrel export
    │       │   ├── knowledge_item.dart # KnowledgeItem, KnowledgeMedia
    │       │   ├── knowledge_enums.dart # Enums (Difficulty, Type, etc.)
    │       │   ├── knowledge_ref.dart   # KnowledgeRef
    │       │   ├── learning_path.dart  # LearningPath, LearningPhase
    │       │   ├── drill.dart          # Drill, DrillSummary
    │       │   ├── category.dart        # Category, Tag
    │       │   ├── search_result.dart   # SearchResult, SearchQuery
    │       │   └── recommendation.dart # Recommendation, PlayerProfile
    │       │
    │       ├── repositories/            # Data access layer
    │       │   ├── repositories.dart   # Barrel export
    │       │   ├── knowledge_repository.dart
    │       │   ├── learning_path_repository.dart
    │       │   ├── category_repository.dart
    │       │   └── tag_repository.dart
    │       │
    │       ├── services/                # Business logic
    │       │   ├── services.dart       # Barrel export
    │       │   ├── knowledge_search_service.dart
    │       │   ├── knowledge_recommendation_service.dart
    │       │   └── relationship_resolver.dart
    │       │
    │       ├── loaders/                # Asset loading
    │       │   ├── loaders.dart        # Barrel export
    │       │   ├── knowledge_asset_loader.dart
    │       │   ├── drill_mapping_loader.dart
    │       │   └── learning_path_loader.dart
    │       │
    │       └── utils/                  # Utilities
    │           ├── utils.dart         # Barrel export
    │           └── string_utils.dart
    │
    ├── assets/                         # Knowledge content
    │   └── knowledge/
    │       ├── index.json             # Master index
    │       ├── search_index.json      # Search data
    │       ├── learning_paths.json    # Learning paths
    │       ├── categories.json        # Category definitions
    │       ├── tags.json              # Tag definitions
    │       ├── drills.json            # Drill definitions
    │       │
    │       ├── techniques/
    │       │   └── *.json            # Individual technique items
    │       ├── mistakes/
    │       │   └── *.json            # Individual mistake items
    │       ├── strategies/
    │       │   └── *.json
    │       ├── equipment/
    │       │   └── *.json
    │       ├── mental/
    │       │   └── *.json
    │       ├── aim/
    │       │   └── *.json
    │       ├── bridge/
    │       │   └── *.json
    │       ├── cue_ball/
    │       │   └── *.json
    │       ├── bank/
    │       │   └── *.json
    │       └── drills/
    │           └── *.json
    │
    ├── pubspec.yaml                   # Package manifest
    ├── README.md                      # Package documentation
    └── CHANGELOG.md                   # Version history
```

## Public API Surface

```
BilliardKnowledge.instance
├── knowledgeRepository       (KnowledgeRepository)
├── learningPathRepository    (LearningPathRepository)
├── categoryRepository        (CategoryRepository)
├── tagRepository             (TagRepository)
├── searchService             (KnowledgeSearchService)
├── recommendationService     (KnowledgeRecommendationService)
├── relationshipResolver       (RelationshipResolver)
├── drillLoader               (DrillMappingLoader)
├── pathLoader                (LearningPathLoader)
│
├── initialize()              → Future<void>
├── clearCache()              → Future<void>
├── dispose()                 → Future<void>
│
└── isInitialized             → bool
```

## Data Access Patterns

### Repository Pattern

Each repository provides:
- CRUD operations for its domain
- Filtering and querying
- Lazy loading
- Caching

### Service Pattern

Services provide:
- Complex business logic
- Cross-cutting concerns (search, recommendations)
- Aggregation of repository data

### Loader Pattern

Loaders handle:
- Low-level asset loading
- JSON parsing
- Index building

## Separation of Concerns

```
┌─────────────────────────────────────────────────────────────────┐
│                        Pool OS App                               │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │ UI Layer (Widgets, Pages)                                 │ │
│  │ - Displays knowledge items                                 │ │
│  │ - Shows learning paths                                    │ │
│  │ - Renders drill information                                │ │
│  └───────────────────────────┬───────────────────────────────┘ │
│                              │                                   │
│                              ▼                                   │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │ Repository Layer (BilliardKnowledge Public API)           │ │
│  │ - KnowledgeRepository                                      │ │
│  │ - LearningPathRepository                                   │ │
│  │ - CategoryRepository                                       │ │
│  │ - TagRepository                                            │ │
│  └───────────────────────────┬───────────────────────────────┘ │
│                              │                                   │
│                              ▼                                   │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │ Service Layer                                             │ │
│  │ - KnowledgeSearchService                                  │ │
│  │ - KnowledgeRecommendationService                           │ │
│  │ - RelationshipResolver                                     │ │
│  └───────────────────────────┬───────────────────────────────┘ │
│                              │                                   │
│                              ▼                                   │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │ Loader Layer                                              │ │
│  │ - KnowledgeAssetLoader                                    │ │
│  │ - DrillMappingLoader                                      │ │
│  │ - LearningPathLoader                                      │ │
│  └───────────────────────────┬───────────────────────────────┘ │
│                              │                                   │
│                              ▼                                   │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │ Asset Layer (JSON Files)                                  │ │
│  │ - /assets/knowledge/                                       │ │
│  │ - Indexed JSON files                                       │ │
│  │ - Individual knowledge items                               │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Key Principles

1. **Encapsulation** - All JSON loading happens inside the package
2. **Lazy Loading** - Items loaded on-demand, not all at once
3. **Caching** - Frequently accessed items cached in memory
4. **Abstraction** - Repositories hide storage details
5. **Localization** - All content supports EN/VI

## Usage from Pool OS

```dart
// WRONG: Pool OS should never do this
final data = await rootBundle.loadString('assets/knowledge/techniques/stroke.json');
final item = jsonDecode(data);

// CORRECT: Use the package API
await BilliardKnowledge.initialize();
final item = await BilliardKnowledge.instance.repository.byId('stroke.fundamentals');
```

## Version Compatibility

| Pool OS Version | Package Version | Notes |
|----------------|-----------------|-------|
| 1.0.x | 1.0.0 | Initial release |

## Migration Guide

When updating the package:

1. Update `pubspec.yaml` dependency
2. Run `flutter pub get`
3. Rebuild the app
4. Verify knowledge content loads correctly
