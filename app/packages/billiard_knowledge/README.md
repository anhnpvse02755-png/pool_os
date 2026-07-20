# Billiard Knowledge Library

A comprehensive billiard and pool knowledge library for Flutter applications.

## Features

- **Structured Knowledge Models** - Techniques, mistakes, strategies, equipment
- **Search Functionality** - Full-text search with filters and relevance ranking
- **Learning Paths** - Organized curricula with phases and checkpoints
- **Skill Recommendations** - Rule-based contextual recommendations
- **Drill Mappings** - Connect knowledge to practice drills
- **Offline Support** - All content bundled with the app
- **Bilingual** - Full English and Vietnamese support

## Installation

```yaml
dependencies:
  billiard_knowledge: ^1.0.0
```

## Quick Start

```dart
import 'package:billiard_knowledge/billiard_knowledge.dart';

void main() async {
  // Initialize the library
  await BilliardKnowledge.initialize();
  
  // Access repositories
  final repo = BilliardKnowledge.instance.repository;
  
  // Get a knowledge item
  final item = await repo.byId('stroke.fundamentals');
  print(item?.title); // "Stroke Fundamentals"
  
  // Search for knowledge
  final results = await BilliardKnowledge.instance.search('draw shot');
  
  // Get recommendations
  final recs = await BilliardKnowledge.instance.recommendations.getRecommendations(
    profile: playerProfile,
    goal: GoalContext(primaryGoal: LearningGoal.improveAccuracy),
  );
}
```

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   Public API                            │
│  BilliardKnowledge (Entry Point)                        │
└────────────────────────┬────────────────────────────────┘
                         │
         ┌───────────────┼───────────────┐
         ▼               ▼               ▼
    ┌─────────┐    ┌───────────┐   ┌────────┐
    │Repository│    │ Services  │   │ Loaders │
    │         │    │           │   │        │
    │-Knowledge│    │- Search   │   │- Asset │
    │-Learning │    │- Recom-   │   │- Drill │
    │  Path    │    │  mendation│   │- Path  │
    │-Category │    │- Relation │   │        │
    │-Tag      │    │           │   │        │
    └─────────┘    └───────────┘   └────────┘
```

## Public API

### Entry Point

```dart
BilliardKnowledge.instance
```

### Repositories

#### KnowledgeRepository

Access knowledge items.

```dart
final repo = BilliardKnowledge.instance.repository;

// Get by ID
final item = await repo.byId('stroke.fundamentals');

// Get all
final all = await repo.getAll();

// By category
final aimItems = await repo.byCategory('aim');

// By type
final techniques = await repo.byType(KnowledgeType.technique);

// Prerequisites
final prereqs = await repo.prerequisites('draw.fundamentals');

// Related items
final related = await repo.related('aim.center_ball');
```

#### LearningPathRepository

Access learning paths.

```dart
final pathRepo = BilliardKnowledge.instance.learningPathRepository;

// Get all paths
final paths = await pathRepo.getAll();

// Get path for item
final path = await pathRepo.forItem('stroke.fundamentals');

// Progress calculation
final progress = await pathRepo.calculateProgress(
  pathId: 'complete_beginner',
  completedItems: {'stroke.fundamentals', 'aim.center_ball'},
);
```

#### CategoryRepository

Access knowledge categories.

```dart
final catRepo = BilliardKnowledge.instance.categoryRepository;

final categories = await catRepo.getAll();
final aim = await catRepo.byId('aim');
```

#### TagRepository

Access knowledge tags.

```dart
final tagRepo = BilliardKnowledge.instance.tagRepository;

final tags = await tagRepo.getAll();
final results = await tagRepo.search('power');
```

### Services

#### KnowledgeSearchService

Full-text search with filters.

```dart
final search = BilliardKnowledge.instance.search;

// Simple search
final results = await search.search('draw shot');

// With filters
final results = await search.search(
  'stroke',
  type: KnowledgeType.technique,
  difficulty: KnowledgeDifficulty.beginner,
  limit: 10,
);

// Autocomplete
final suggestions = await search.suggestions('str');
```

#### KnowledgeRecommendationService

Contextual recommendations.

```dart
final rec = BilliardKnowledge.instance.recommendations;

// Full recommendations
final set = await rec.getRecommendations(
  profile: playerProfile,
  goal: GoalContext(primaryGoal: LearningGoal.improveAccuracy),
  currentItem: currentItem,
);

// Just drills
final drills = await rec.getRecommendedDrills(
  current: item,
  profile: playerProfile,
  goal: goalContext,
);

// Next skills
final next = await rec.getNextSkills(
  current: item,
  profile: playerProfile,
);
```

#### RelationshipResolver

Navigate the knowledge graph.

```dart
final resolver = BilliardKnowledge.instance.relations;

// Get prerequisites
final prereqs = await resolver.getPrerequisites('draw.fundamentals');

// Learning order
final order = await resolver.getLearningOrder('advanced.bank');

// Missing prerequisites
final missing = await resolver.getMissingPrerequisites(
  'draw.fundamentals',
  completedItems: {'stance.fundamentals'},
);

// Check if ready to learn
final ready = await resolver.arePrerequisitesSatisfied(
  'draw.fundamentals',
  completedItems: {'stance.fundamentals', 'aim.center_ball'},
);
```

### Models

#### KnowledgeItem

```dart
final item = await repo.byId('stroke.fundamentals');

item.id              // 'stroke.fundamentals'
item.title           // 'Stroke Fundamentals'
item.titleVi         // 'Nhát đánh cơ bản'
item.type            // KnowledgeType.technique
item.difficulty      // KnowledgeDifficulty.beginner
item.category        // 'stroke'
item.summary         // Brief overview
item.purpose         // Why this matters
item.setup           // Setup steps
item.execution       // How to do it
item.successCriteria // What success looks like
item.commonMistakes  // Common errors and fixes
item.media           // Images, videos, diagrams
item.relatedKnowledge // Related items
item.prerequisites   // Required prior knowledge
item.estLearningMinutes // Time to learn
item.tags            // Searchable tags
item.keywords        // Search keywords
```

#### LearningPath

```dart
final path = await pathRepo.byId('complete_beginner');

path.id            // 'complete_beginner'
path.name          // 'Complete Beginner Path'
path.nameVi        // 'Lộ trình người mới'
path.targetLevel   // 'H'
path.difficulty    // KnowledgeDifficulty.beginner
path.totalHours    // 40
path.phases        // [LearningPhase, ...]
path.totalItems    // Total knowledge items
path.containsItem('stroke.fundamentals') // true
```

#### Drill

```dart
final drill = await loader.getDrill('D001');

drill.code           // 'D001'
drill.name           // 'Basic Stroke Practice'
drill.nameVi         // 'Bài tập nhát đánh cơ bản'
drill.category       // 'stroke'
drill.difficulty     // DrillDifficulty.beginner
drill.timeLimitMinutes // 10
drill.description    // Description
drill.successCriteria // Success criteria
```

#### PlayerProfile

```dart
final profile = PlayerProfile(
  id: 'user_123',
  currentLevel: 'G',
  strengthAreas: {'aim', 'stance'},
  weaknessAreas: {'position', 'english'},
  completedItems: {'stroke.fundamentals'},
  completedDrills: {'D001', 'D002'},
  practiceHoursPerWeek: 5,
  goals: {'improve_position'},
);
```

## Enums

### KnowledgeDifficulty

- `beginner` - Fundamental skills
- `intermediate` - Basic techniques
- `advanced` - Complex skills
- `professional` - Expert techniques

### KnowledgeType

- `technique` - Technique skill
- `mistake` - Common mistake
- `strategy` - Strategic knowledge
- `equipment` - Equipment info
- `mental` - Mental game
- `aim` - Aiming fundamentals
- `bridge` - Bridge technique
- `cueBall` - Cue ball control
- `bank` - Bank shot
- `safety` - Safety play

### LearningGoal

- `improveAccuracy` - Better pocketing
- `improvePosition` - Better cue ball control
- `improveBreak` - Better breaks
- `improveSafety` - Better defense
- `learnNewShot` - New technique
- `fixMistakes` - Fix errors
- `tournamentPrep` - Tournament prep
- `warmUp` - Warm up
- `levelUp` - Advance level

## Configuration

```dart
await BilliardKnowledge.initialize(
  config: BilliardKnowledgeConfig(
    enableSearchCache: true,
    enableLazyLoading: true,
    maxCacheSizeMb: 100,
    defaultSearchLimit: 20,
    defaultLanguage: 'en',
  ),
);
```

### Presets

```dart
// Default configuration
BilliardKnowledgeConfig.defaultConfig

// Low memory devices
BilliardKnowledgeConfig.lowMemory

// Web platforms
BilliardKnowledgeConfig.web
```

## Memory Management

```dart
// Clear all caches
await BilliardKnowledge.instance.clearCache();

// Dispose when done
await BilliardKnowledge.instance.dispose();
```

## Data Flow

```
┌──────────────┐
│    Pool OS   │
└──────┬───────┘
       │
       ▼
┌──────────────────┐
│ BilliardKnowledge│
│   .initialize()  │
└──────┬───────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────┐
│                   Load Indices                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │ Master Index│  │ Search Index│  │ Learning Paths  │  │
│  └─────────────┘  └─────────────┘  └─────────────────┘  │
└──────┬───────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────┐
│              Request Knowledge Item                       │
│                                                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │ Check Cache │──▶│ Return     │  │ Load from JSON │  │
│  └─────────────┘  └─────────────┘  │ and Cache     │  │
│                                   └─────────────────┘  │
└──────────────────────────────────────────────────────────┘
```

## Best Practices

1. **Initialize Early** - Call `initialize()` at app startup
2. **Use Repositories** - Don't read JSON files directly
3. **Cache Wisely** - Use lazy loading for large datasets
4. **Handle Null** - Not all items may exist
5. **Check Language** - Use `getTitle(language)` for localization

## License

Proprietary - Pool OS
