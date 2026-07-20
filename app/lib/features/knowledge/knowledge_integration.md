# Knowledge Module Integration Guide

## Overview

**Document Date:** 2026-07-17  
**Module Version:** 1.0.0  
**Knowledge Base Version:** 1.0.0  

This document describes how to integrate the Knowledge Module into Pool OS. The module is designed to be **completely independent** and **future-proof** for database migration.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        Pool OS App                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              Knowledge Integration Layer                 │    │
│  │  ┌─────────────┐  ┌─────────────┐  ┌───────────────┐  │    │
│  │  │  Knowledge  │  │  Category    │  │ Relationship  │  │    │
│  │  │  Service    │  │  Browser    │  │  Resolver     │  │    │
│  │  └─────────────┘  └─────────────┘  └───────────────┘  │    │
│  │  ┌─────────────┐  ┌─────────────┐  ┌───────────────┐  │    │
│  │  │  Search     │  │ Learning    │  │ Recommendation│  │    │
│  │  │  Service    │  │ Path Loader │  │  Loader      │  │    │
│  │  └─────────────┘  └─────────────┘  └───────────────┘  │    │
│  │  ┌─────────────────────────────────────────────────┐  │    │
│  │  │           Drill Mapping Loader                   │  │    │
│  │  └─────────────────────────────────────────────────┘  │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              Knowledge Repository (Data Layer)            │    │
│  │  ┌─────────────┐  ┌─────────────┐  ┌───────────────┐  │    │
│  │  │  Index.json │  │ JSON Files  │  │  Cache        │  │    │
│  │  └─────────────┘  └─────────────┘  └───────────────┘  │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              Metadata Files (Loaded on demand)           │    │
│  │  ┌─────────────┐  ┌─────────────┐  ┌───────────────┐  │    │
│  │  │learning_    │  │drill_       │  │recommendation_│  │    │
│  │  │paths.json   │  │mapping.json │  │metadata.json  │  │    │
│  │  └─────────────┘  └─────────────┘  └───────────────┘  │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Public Interfaces

### 1. KnowledgeRepository

**Location:** `lib/features/knowledge/data/knowledge_repository.dart`

**Purpose:** Low-level data access layer for knowledge items.

```dart
// Provider
final knowledgeRepositoryProvider = Provider<KnowledgeRepository>((ref) {
  return KnowledgeRepository();
});

// Methods
Future<List<KnowledgeItem>> getAll()
Future<List<KnowledgeItem>> byType(KnowledgeType type)
Future<List<KnowledgeItem>> byCategory(String category)
Future<KnowledgeItem?> byId(String id)
Future<KnowledgeItem?> byCoachKnowledgeId(String coachKnowledgeId)
Future<List<KnowledgeItem>> related(KnowledgeItem item)
List<Drill> drillsFor(KnowledgeItem item)
```

### 2. KnowledgeService

**Location:** `lib/features/knowledge/domain/services/knowledge_service.dart`

**Purpose:** High-level business logic facade.

```dart
// Provider
final knowledgeServiceProvider = Provider<KnowledgeService>((ref) {
  return KnowledgeService(ref.watch(knowledgeRepositoryProvider));
});

// Methods
Future<List<KnowledgeItem>> getAll()
Future<List<KnowledgeItem>> byType(KnowledgeType type)
Future<List<KnowledgeItem>> byCategory(String category)
Future<KnowledgeItem?> byId(String id)
Future<Map<String, List<KnowledgeItem>>> groupedByCategory()
Future<Map<KnowledgeDifficulty, List<KnowledgeItem>>> groupedByDifficulty()
Future<List<KnowledgeItem>> getFundamentals()
Future<KnowledgeStatistics> getStatistics()
```

### 3. KnowledgeSearchService

**Location:** `lib/features/knowledge/domain/services/knowledge_search_service.dart`

**Purpose:** Full-text and semantic search capabilities.

```dart
// Provider
final knowledgeSearchServiceProvider = Provider<KnowledgeSearchService>((ref) {
  return KnowledgeSearchService(ref.watch(knowledgeRepositoryProvider));
});

// Methods
Future<List<KnowledgeItem>> search(String query, {KnowledgeType? type})
Future<List<KnowledgeItem>> searchByKeywords(List<String> keywords)
Future<List<KnowledgeItem>> fuzzySearch(String query)
Future<List<KnowledgeItem>> searchByLanguage(String query, bool isVietnamese)
```

### 4. CategoryBrowserService

**Location:** `lib/features/knowledge/domain/services/category_browser_service.dart`

**Purpose:** Category navigation and browsing.

```dart
// Provider
final categoryBrowserServiceProvider = Provider<CategoryBrowserService>((ref) {
  return CategoryBrowserService(ref.watch(knowledgeRepositoryProvider));
});

// Methods
Future<List<CategoryInfo>> getAllCategories()
Future<CategoryInfo> getCategoryInfo(String category)
Future<List<KnowledgeItem>> getItemsInCategory(String category)
Future<List<CategoryInfo>> getCategoriesByType(KnowledgeType type)
Future<List<CategoryInfo>> getCategoriesByDifficulty(KnowledgeDifficulty difficulty)
```

### 5. RelationshipResolverService

**Location:** `lib/features/knowledge/domain/services/relationship_resolver_service.dart`

**Purpose:** Graph traversal and relationship resolution.

```dart
// Provider
final relationshipResolverProvider = Provider<RelationshipResolverService>((ref) {
  return RelationshipResolverService(ref.watch(knowledgeRepositoryProvider));
});

// Methods
Future<List<KnowledgeItem>> getRelated(KnowledgeItem item)
Future<List<KnowledgeItem>> getPrerequisites(KnowledgeItem item)
Future<List<KnowledgeItem>> getDependents(KnowledgeItem item)
Future<List<KnowledgeItem>> getLearningPath(String startId, String endId)
Future<bool> hasCircularDependency(String itemId)
Future<Map<String, int>> getDependencyDepth()
```

### 6. LearningPathLoaderService

**Location:** `lib/features/knowledge/domain/services/learning_path_loader_service.dart`

**Purpose:** Learning path management and progression tracking.

```dart
// Provider
final learningPathLoaderProvider = Provider<LearningPathLoaderService>((ref) {
  return LearningPathLoaderService(ref.watch(knowledgeRepositoryProvider));
});

// Methods
Future<LearningPath?> getPath(String pathId)
Future<List<LearningPath>> getAllPaths()
Future<List<LearningPath>> getPathsForLevel(String playerLevel)
Future<List<LearningItem>> getOrderedItems(String pathId)
Future<double> getProgress(String pathId, PlayerProgress progress)
Future<List<LearningPath>> getRecommendedPaths(PlayerProfile profile)
```

### 7. RecommendationLoaderService

**Location:** `lib/features/knowledge/domain/services/recommendation_loader_service.dart`

**Purpose:** Personalized recommendations based on player profile.

```dart
// Provider
final recommendationLoaderProvider = Provider<RecommendationLoaderService>((ref) {
  return RecommendationLoaderService(ref.watch(knowledgeRepositoryProvider));
});

// Methods
Future<List<KnowledgeItem>> getRecommended(PlayerProfile profile)
Future<List<KnowledgeItem>> getRecommendedForSkill(String skillId, String level)
Future<List<KnowledgeItem>> getRelatedRecommendations(KnowledgeItem item)
Future<List<KnowledgeItem>> getBasedOnMistakes(List<String> mistakeIds)
Future<RecommendationMetadata> getMetadata()
```

### 8. DrillMappingLoaderService

**Location:** `lib/features/knowledge/domain/services/drill_mapping_loader_service.dart`

**Purpose:** Drill-to-knowledge mapping and drill lookup.

```dart
// Provider
final drillMappingLoaderProvider = Provider<DrillMappingLoaderService>((ref) {
  return DrillMappingLoaderService(
    ref.watch(knowledgeRepositoryProvider),
    ref.watch(drillLibraryProvider),
  );
});

// Methods
Future<List<Drill>> getDrillsForKnowledge(KnowledgeItem item)
Future<List<KnowledgeItem>> getKnowledgeForDrill(Drill drill)
Future<Map<String, List<Drill>>> getDrillsByCategory()
Future<Map<String, List<Drill>>> getDrillsByDifficulty()
Future<DrillMappingMetadata> getMetadata()
```

---

## Usage Examples

### Basic Usage

```dart
// Get all knowledge items
final allItems = await ref.read(knowledgeServiceProvider).getAll();

// Get items by category
final techniques = await ref.read(knowledgeServiceProvider).byType(KnowledgeType.technique);

// Get single item
final item = await ref.read(knowledgeServiceProvider).byId('stroke.fundamentals');
```

### Search

```dart
// Text search
final results = await ref.read(knowledgeSearchServiceProvider)
    .search('draw shot');

// Filter by type
final techniqueResults = await ref.read(knowledgeSearchServiceProvider)
    .search('draw shot', type: KnowledgeType.technique);
```

### Browse Categories

```dart
// Get all categories with counts
final categories = await ref.read(categoryBrowserServiceProvider).getAllCategories();

// Get items in category
final aimItems = await ref.read(categoryBrowserServiceProvider)
    .getItemsInCategory('aim');
```

### Get Related Items

```dart
// Get related knowledge
final related = await ref.read(relationshipResolverProvider)
    .getRelated(item);

// Get prerequisites
final prereqs = await ref.read(relationshipResolverProvider)
    .getPrerequisites(item);
```

### Learning Paths

```dart
// Get recommended paths for player level
final paths = await ref.read(learningPathLoaderProvider)
    .getPathsForLevel('G'); // Intermediate

// Get progress
final progress = await ref.read(learningPathLoaderProvider)
    .getProgress('complete_beginner', playerProgress);
```

### Recommendations

```dart
// Get personalized recommendations
final recs = await ref.read(recommendationLoaderProvider)
    .getRecommended(playerProfile);

// Get based on mistakes
final fromMistakes = await ref.read(recommendationLoaderProvider)
    .getBasedOnMistakes(['mistake.Draw_Too_Much', 'mistake.Draw_Too_Little']);
```

### Drill Mapping

```dart
// Get drills for knowledge item
final drills = await ref.read(drillMappingLoaderProvider)
    .getDrillsForKnowledge(item);

// Get drills by difficulty
final drills = await ref.read(drillMappingLoaderProvider)
    .getDrillsByDifficulty()['beginner'];
```

---

## File Structure

```
lib/features/knowledge/
├── data/
│   └── knowledge_repository.dart          # Data access layer
├── domain/
│   ├── models/
│   │   ├── knowledge_item.dart           # Domain model
│   │   ├── category_info.dart            # Category metadata
│   │   ├── learning_path.dart            # Learning path model
│   │   ├── drill_mapping.dart             # Drill mapping model
│   │   └── recommendation.dart          # Recommendation model
│   └── services/
│       ├── knowledge_service.dart         # Main service facade
│       ├── knowledge_search_service.dart  # Search functionality
│       ├── category_browser_service.dart  # Category navigation
│       ├── relationship_resolver_service.dart  # Graph traversal
│       ├── learning_path_loader_service.dart   # Learning paths
│       ├── recommendation_loader_service.dart  # Recommendations
│       └── drill_mapping_loader_service.dart  # Drill mapping
└── presentation/
    ├── providers/
    │   └── knowledge_providers.dart       # Riverpod providers
    ├── screens/
    │   └── knowledge_screen.dart         # Main knowledge UI
    └── widgets/
        ├── knowledge_card.dart           # Item card widget
        ├── category_grid.dart            # Category grid widget
        └── search_bar.dart               # Search widget
```

---

## Database Migration Strategy

The Knowledge Module is designed to support future database migration without breaking changes.

### Phase 1: Asset-Backed (Current)

```dart
class KnowledgeRepository {
  Future<List<KnowledgeItem>> getAll() async {
    // Load from assets/knowledge/index.json
  }
}
```

### Phase 2: Hybrid (Future)

```dart
class KnowledgeRepository {
  final bool _useDatabase;
  
  Future<List<KnowledgeItem>> getAll() async {
    if (_useDatabase) {
      return _loadFromDatabase();
    }
    return _loadFromAssets();
  }
}
```

### Phase 3: Database-Backed (Future)

```dart
class KnowledgeRepository {
  Future<List<KnowledgeItem>> getAll() async {
    // Load from Knowledge API / Database
  }
}
```

### Migration Checklist

- [ ] Create database tables matching `KnowledgeItem` schema
- [ ] Create API endpoints for CRUD operations
- [ ] Update repository to use new data source
- [ ] Update cache invalidation logic
- [ ] Add offline sync capabilities
- [ ] Update documentation

---

## Configuration

### Asset Paths

Default paths are defined in `KnowledgeRepository`:

```dart
static const String _indexPath = 'assets/knowledge/index.json';
static const String _metadataPath = 'assets/knowledge/';
```

To override, create a custom repository:

```dart
class CustomKnowledgeRepository extends KnowledgeRepository {
  static const String _customIndexPath = 'assets/custom/knowledge_index.json';
  
  @override
  Future<List<KnowledgeItem>> getAll() async {
    // Use custom path
  }
}
```

### Supported Languages

Currently supported: `en`, `vi`

To add new language:

1. Add language code to `KnowledgeItem.title{Lang}` fields
2. Update search index with translations
3. Update localization files

---

## Error Handling

All services return `null` or empty lists on error:

```dart
Future<KnowledgeItem?> byId(String id) async {
  try {
    return await _repository.byId(id);
  } catch (e) {
    debugPrint('Error loading knowledge item: $e');
    return null;
  }
}
```

---

## Performance Considerations

### Caching

- `KnowledgeRepository` caches all items in memory after first load
- Subsequent calls return from cache instantly
- Cache is cleared on app restart

### Lazy Loading

Metadata files are loaded on-demand:

```dart
// Learning paths loaded only when needed
Future<LearningPath?> getPath(String pathId) async {
  if (_pathsCache == null) {
    _pathsCache = await _loadLearningPaths();
  }
  return _pathsCache![pathId];
}
```

### Pagination

For large result sets, use pagination:

```dart
Future<List<KnowledgeItem>> getAll({int page = 1, int pageSize = 50}) async {
  final all = await getAllCached();
  final start = (page - 1) * pageSize;
  return all.skip(start).take(pageSize).toList();
}
```

---

## Testing

### Unit Tests

```dart
test('KnowledgeService returns all items', () async {
  final service = KnowledgeService(MockRepository());
  final items = await service.getAll();
  expect(items, isNotEmpty);
});
```

### Integration Tests

```dart
testWidgets('Knowledge screen displays items', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(home: KnowledgeScreen()),
    ),
  );
  expect(find.byType(KnowledgeCard), findsWidgets);
});
```

---

## Future Enhancements

| Feature | Priority | Status |
|---------|----------|--------|
| Semantic Search | HIGH | Future |
| ML Recommendations | MEDIUM | Future |
| Video Integration | MEDIUM | Future |
| Offline Sync | HIGH | Future |
| Multi-language Support | MEDIUM | Planned |
| CMS Integration | HIGH | Future |

---

*Generated: 2026-07-17*
*Pool OS Knowledge Integration Guide v1.0*
