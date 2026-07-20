# Knowledge Module - Offline Strategy Specification

## Overview

**Document Date:** 2026-07-17  
**Component:** Knowledge Module - Offline Support  
**Type:** Architecture Specification (No Implementation)  
**Status:** Design Phase

---

## Purpose

Enable full functionality of the Knowledge Module without network connectivity by implementing:

1. **Lazy Loading** - Load knowledge on-demand, not all at once
2. **Index Loading** - Pre-load searchable indices
3. **Memory Optimization** - Efficient resource management
4. **Search Cache** - Cache search results
5. **JSON Compression** - Reduce storage footprint
6. **SQLite Migration Path** - Future database upgrade

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         Knowledge Module - Offline Layer                     │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │                      PRESENTATION LAYER                           │   │
│   │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐              │   │
│   │  │ Knowledge   │ │   Search    │ │ Recommendation│              │   │
│   │  │   Viewer    │ │    Page      │ │     Cards     │              │   │
│   │  └──────────────┘ └──────────────┘ └──────────────┘              │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│                                    │                                     │
│                                    ▼                                     │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │                        SERVICE LAYER                              │   │
│   │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐              │   │
│   │  │ Knowledge   │ │   Search    │ │ Recommendation│              │   │
│   │  │  Service    │ │  Service    │ │    Service    │              │   │
│   │  └──────┬───────┘ └──────┬───────┘ └──────┬───────┘              │   │
│   │         │                │                │                      │   │
│   │         └────────────────┼────────────────┘                      │   │
│   │                          ▼                                       │   │
│   │  ┌───────────────────────────────────────────────────────────┐  │   │
│   │  │               Offline Cache Manager                        │  │   │
│   │  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────┐  │  │   │
│   │  │  │  LRU Cache  │ │  Index    │ │   Compression      │  │  │   │
│   │  │  │  (Items)    │ │  Loader   │ │   Engine          │  │  │   │
│   │  │  └─────────────┘ └─────────────┘ └─────────────────────┘  │  │   │
│   │  └───────────────────────────────────────────────────────────┘  │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│                                    │                                     │
│                                    ▼                                     │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │                        DATA LAYER                                 │   │
│   │  ┌──────────────────────────┐  ┌────────────────────────────┐  │   │
│   │  │     JSON Assets         │  │     Future: SQLite         │  │   │
│   │  │  (Current Implementation) │  │    (Migration Target)     │  │   │
│   │  └──────────────────────────┘  └────────────────────────────┘  │   │
│   │                                                                  │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Strategy 1: Lazy Loading

### Concept

Load knowledge items only when requested, not all at app startup.

### Loading Tiers

```
┌─────────────────────────────────────────────────────────────────┐
│                      Loading Tiers                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   TIER 0: Critical (Immediate Load)                              │
│   ├─ Search index                                                │
│   ├─ Category index                                             │
│   ├─ Learning paths metadata                                     │
│   └─ Size: ~100KB                                                │
│                                                                  │
│   TIER 1: On-Demand (When Needed)                                │
│   ├─ Individual knowledge items                                  │
│   ├─ Drill definitions                                           │
│   └─ Loaded on first access, then cached                        │
│                                                                  │
│   TIER 2: Background (Preload)                                   │
│   ├─ Related items for viewed content                           │
│   ├─ Popular items (based on usage patterns)                    │
│   └─ Loaded when idle / low priority                            │
│                                                                  │
│   TIER 3: Explicit (User Request)                               │
│   ├─ Full learning path content                                  │
│   ├─ Media assets (images, videos)                              │
│   └─ Downloaded only when user requests                         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Load Triggers

```dart
// When to load each tier

// TIER 0 - App Startup
Future<void> initializeKnowledgeModule() async {
  await _loadCriticalIndices();  // Always first
}

// TIER 1 - User Access
Future<KnowledgeItem?> getKnowledgeItem(String id) async {
  // Check cache first
  if (_cache.contains(id)) {
    return _cache.get(id);
  }
  
  // Load from assets
  final item = await _loadFromAssets(id);
  _cache.put(id, item);
  return item;
}

// TIER 2 - Predictive
void onKnowledgeViewed(KnowledgeItem item) {
  // Preload related items in background
  _preloader.preloadRelated(item);
  
  // Preload next recommended
  if (item.nextRecommended != null) {
    _preloader.preload(item.nextRecommended!.id);
  }
}

// TIER 3 - Explicit
Future<void> downloadPathContent(String pathId) async {
  await _downloader.downloadFullPath(pathId);
  await _mediaLoader.preloadPathMedia(pathId);
}
```

### Loading States

```dart
enum LoadingState {
  notLoaded,      // Never accessed
  loading,        // Currently loading
  loaded,         // In memory
  cached,         // In disk cache
  error,          // Failed to load
}

class KnowledgeLoadStatus {
  final String id;
  final LoadingState state;
  final DateTime? lastAccessed;
  final int? sizeBytes;
}
```

---

## Strategy 2: Index Loading

### Purpose

Pre-load searchable data structures for fast local search.

### Index Types

```
┌─────────────────────────────────────────────────────────────────┐
│                          Index Types                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   1. MASTER INDEX                                                 │
│   ├─ Location: assets/knowledge/index.json                     │
│   ├─ Size: ~50KB                                                │
│   ├─ Contents:                                                  │
│   │   ├─ All item IDs                                           │
│   │   ├─ Category mapping                                        │
│   │   ├─ Type mapping                                            │
│   │   └─ Difficulty mapping                                      │
│   └─ Load: Immediately at startup                                │
│                                                                  │
│   2. SEARCH INDEX                                               │
│   ├─ Location: assets/knowledge/search_index.json               │
│   ├─ Size: ~200KB                                               │
│   ├─ Contents:                                                  │
│   │   ├─ Keywords (EN/VI)                                        │
│   │   ├─ Aliases mapping                                         │
│   │   ├─ Common misspellings                                     │
│   │   └─ Search term weights                                     │
│   └─ Load: Before first search                                   │
│                                                                  │
│   3. RELATION INDEX                                             │
│   ├─ Location: assets/knowledge/relation_index.json              │
│   ├─ Size: ~150KB                                               │
│   ├─ Contents:                                                  │
│   │   ├─ Prerequisite chains                                     │
│   │   ├─ Related items graph                                     │
│   │   ├─ Next-skill recommendations                              │
│   │   └─ Cross-category relationships                            │
│   └─ Load: When knowledge viewer opened                          │
│                                                                  │
│   4. DRILL INDEX                                                 │
│   ├─ Location: assets/knowledge/drill_index.json                 │
│   ├─ Size: ~100KB                                               │
│   ├─ Contents:                                                  │
│   │   ├─ Drill codes                                             │
│   │   ├─ Skill-to-drill mapping                                  │
│   │   └─ Difficulty ratings                                      │
│   └─ Load: When drill page accessed                              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Index Loading Sequence

```dart
class IndexLoader {
  
  /// Load all critical indices at startup
  Future<void> loadCriticalIndices() async {
    await Future.wait([
      _loadMasterIndex(),      // Must be first
      _warmUpCache(),          // Prepare cache
    ]);
  }
  
  /// Load search index on first search
  Future<void> ensureSearchIndexLoaded() async {
    if (_searchIndexLoaded) return;
    
    _searchIndexLoaded = true;
    await _loadSearchIndex();
  }
  
  /// Load relation index when viewing knowledge
  Future<void> ensureRelationIndexLoaded() async {
    if (_relationIndexLoaded) return;
    
    _relationIndexLoaded = true;
    await _loadRelationIndex();
  }
  
  /// Load drill index when accessing drills
  Future<void> ensureDrillIndexLoaded() async {
    if (_drillIndexLoaded) return;
    
    _drillIndexLoaded = true;
    await _loadDrillIndex();
  }
}
```

### Index File Structure

```json
{
  "version": "1.0.0",
  "generated": "2026-07-17",
  "indices": {
    "master": {
      "itemCount": 2500,
      "categories": ["aim", "bridge", "stroke", "..."],
      "types": ["technique", "mistake", "strategy", "..."]
    },
    "search": {
      "keywordCount": 5000,
      "aliasCount": 1200,
      "languages": ["en", "vi"]
    },
    "relations": {
      "edgeCount": 8000,
      "maxDepth": 5,
      "prerequisiteChains": 450
    }
  }
}
```

---

## Strategy 3: Memory Optimization

### Memory Budget

```
┌─────────────────────────────────────────────────────────────────┐
│                       Memory Budget                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   Total Budget: 100MB (target for mobile)                        │
│                                                                  │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                                                          │   │
│   │   CACHE (LRU)          60MB  ████████████████░░░░░░░░░  │   │
│   │   ├─ Knowledge Items   50MB                           │   │
│   │   └─ Drills             10MB                           │   │
│   │                                                          │   │
│   │   INDICES                20MB  ████████░░░░░░░░░░░░░░░  │   │
│   │   ├─ Master Index        1MB                          │   │
│   │   ├─ Search Index        5MB                          │   │
│   │   ├─ Relation Index     10MB                          │   │
│   │   └─ Drill Index         4MB                          │   │
│   │                                                          │   │
│   │   RUNTIME                15MB  ██████░░░░░░░░░░░░░░░░░  │   │
│   │   ├─ View State          5MB                          │   │
│   │   ├─ Search Results     5MB                           │   │
│   │   └─ Recommendations     5MB                          │   │
│   │                                                          │   │
│   │   BUFFER                  5MB  ██░░░░░░░░░░░░░░░░░░░░░  │   │
│   │   └─ Loading/Decoding   5MB                           │   │
│   │                                                          │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Optimization Techniques

#### 1. Lazy Instantiation

```dart
class KnowledgeRepository {
  // DON'T: Load all items at construction
  // List<KnowledgeItem> _allItems; // ❌ Heavy
  
  // DO: Load on first access
  List<KnowledgeItem>? _allItems;
  
  Future<List<KnowledgeItem>> getAll() async {
    _allItems ??= await _loadAllItems();
    return _allItems!;
  }
}
```

#### 2. Object Pooling

```dart
class KnowledgeItemPool {
  // Reuse KnowledgeItem objects instead of creating new
  final Map<String, KnowledgeItem> _pool = {};
  
  KnowledgeItem get(String id, KnowledgeItem Function() factory) {
    return _pool.putIfAbsent(id, factory);
  }
  
  void release(String id) {
    _pool.remove(id);
  }
  
  void clear() {
    _pool.clear();
  }
}
```

#### 3. Field Pruning

```dart
// For list views, load reduced item
class KnowledgeItemSummary {
  final String id;
  final String title;
  final String titleVi;
  final KnowledgeDifficulty difficulty;
  final String category;
  // NO: summary, keywords, media, commonMistakes, etc.
}

// Full item only when viewing
class KnowledgeItem {
  // All fields
}
```

#### 4. String Interning

```dart
class StringPool {
  static final Set<String> _interned = {};
  
  static String intern(String s) {
    return _interned.putIfAbsent(s, () => s);
  }
}

// Usage
class KnowledgeItem {
  String get title => StringPool.intern(_title);
}
```

#### 5. Memory Monitoring

```dart
class MemoryManager {
  static const _maxMemory = 100 * 1024 * 1024; // 100MB
  
  void checkMemory() {
    final usage = await _getMemoryUsage();
    
    if (usage > _maxMemory * 0.9) {
      _triggerGC();
      _evictOldCache();
    }
    
    if (usage > _maxMemory) {
      _emergencyEvict();
    }
  }
}
```

### Cache Eviction Policy

```dart
class LRUCache<K, V> {
  final int maxSize;
  final _cache = LinkedHashMap<K, V>();
  
  void put(K key, V value) {
    // Evict oldest if at capacity
    while (_cache.length >= maxSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }
  
  V? get(K key) {
    final value = _cache.remove(key);
    if (value != null) {
      _cache[key] = value; // Move to end (most recent)
    }
    return value;
  }
}

// Sizing strategy
class CacheSizing {
  static int calculateMaxItems() {
    // Estimate: average item ~20KB
    // Budget: 50MB for items
    return (50 * 1024 * 1024) ~/ (20 * 1024); // ~2500 items
  }
}
```

---

## Strategy 4: Search Cache

### Cache Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                       Search Cache Architecture                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                    Search Query                          │   │
│   │                    "draw shot"                          │   │
│   └─────────────────────────┬───────────────────────────────┘   │
│                             │                                     │
│                             ▼                                     │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                  Cache Key Generator                     │   │
│   │                                                          │   │
│   │   Key = hash(query + filters + language + level)        │   │
│   │   e.g., "draw_shot_en_H_30"                            │   │
│   └─────────────────────────┬───────────────────────────────┘   │
│                             │                                     │
│              ┌──────────────┴──────────────┐                   │
│              ▼                              ▼                   │
│   ┌─────────────────────┐     ┌─────────────────────────┐   │
│   │    Memory Cache     │     │      Disk Cache         │   │
│   │   (Hot Results)     │     │   (Persistent Results)   │   │
│   │                     │     │                         │   │
│   │   Max: 100 queries  │     │   Max: 1000 queries     │   │
│   │   TTL: 1 hour      │     │   TTL: 7 days           │   │
│   │   LRU eviction    │     │   Compressed (gzip)     │   │
│   │                     │     │                         │   │
│   └─────────────────────┘     └─────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Cache Key Structure

```dart
class SearchCacheKey {
  final String query;
  final String? language;        // 'en', 'vi', null
  final String? type;           // KnowledgeType string
  final String? difficulty;     // KnowledgeDifficulty string
  final String? category;
  final List<String> tags;
  final String? playerLevel;    // H, G, F, E, D, C, B, A, Pro
  
  String toKey() {
    final parts = [
      query.toLowerCase().trim(),
      language ?? '_',
      type ?? '_',
      difficulty ?? '_',
      category ?? '_',
      tags.join(','),
      playerLevel ?? '_',
    ];
    return parts.join('_');
  }
}
```

### Cache Invalidation

```dart
class SearchCacheManager {
  final Map<String, CacheMetadata> _metadata = {};
  
  // Invalidate when:
  // 1. Knowledge item updated
  void onItemUpdated(String itemId) {
    // Find all cache entries that might include this item
    _invalidateMatching((key, result) {
      return result.itemIds.contains(itemId);
    });
  }
  
  // 2. Learning path modified
  void onPathModified(String pathId) {
    _invalidateAll(); // Safer: paths affect many results
  }
  
  // 3. User completed an item
  void onItemCompleted(String itemId, String userId) {
    // Don't invalidate, just update scores in results
    _updateResultsWithCompletion(itemId, userId);
  }
  
  // 4. Time-based expiry
  void onTimerExpiry() {
    final now = DateTime.now();
    for (final entry in _metadata.entries) {
      if (now.difference(entry.value.createdAt) > entry.value.ttl) {
        _invalidate(entry.key);
      }
    }
  }
}
```

### Cache Configuration

```dart
class SearchCacheConfig {
  // Memory cache (fast, volatile)
  static const memoryCacheSize = 100;      // Max queries
  static const memoryCacheTTL = Duration(hours: 1);
  
  // Disk cache (slower, persistent)
  static const diskCacheSize = 1000;       // Max queries
  static const diskCacheTTL = Duration(days: 7);
  static const compressionEnabled = true;
  
  // Warming
  static const warmOnStartup = true;
  static const warmPopularQueries = true;
  
  // Popular queries to pre-cache
  static const popularQueries = [
    'draw shot',
    'stance',
    'aiming',
    'break',
    'english',
    'safety play',
  ];
}
```

---

## Strategy 5: JSON Compression

### Compression Strategy

```
┌─────────────────────────────────────────────────────────────────┐
│                      Compression Pipeline                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   SOURCE FILES                          COMPRESSED FILES        │
│   ─────────────                         ────────────────         │
│                                                                  │
│   knowledge/                             knowledge/              │
│   ├── index.json (2MB)      →           ├── index.json.br (200KB)│
│   ├── items/                            ├── index.json        │
│   │   ├── aim.json (500KB)              │                     │
│   │   ├── bridge.json (400KB)  →        │                     │
│   │   └── ...                           │                     │
│   │                                     │                     │
│   search_index.json (1MB)    →          search_index.json.br    │
│   │                                     (100KB)                │
│   relation_index.json (2MB)  →          relation_index.json.br   │
│   │                                     (200KB)                │
│   drill_index.json (500KB)    →          drill_index.json.br     │
│                                          (50KB)                 │
│                                                                  │
│   Total: ~8MB → ~700KB = 91% reduction                          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Supported Formats

| Format | Extension | Compression | Pros | Cons |
|--------|-----------|-------------|------|------|
| None | .json | 0% | Universal support | Large size |
| GZIP | .json.gz | 80-90% | Wide support | Extra decode time |
| Brotli | .json.br | 85-95% | Best ratio | Limited support |
| LZ4 | .json.lz4 | 60-70% | Fast decode | Larger than others |

### Recommended: Brotli

```
Reasoning:
- Best compression ratio (25-35% smaller than gzip)
- Supported in Flutter via dart:io + AIO
- Industry standard (used by Google, CDN networks)
- Good decode speed despite high compression
```

### Implementation Pattern

```dart
abstract class AssetLoader {
  
  Future<String> loadAsset(String path) async {
    final compressed = await _tryLoadCompressed(path);
    if (compressed != null) {
      return _decompress(compressed);
    }
    
    // Fallback to uncompressed
    return rootBundle.loadString(path);
  }
  
  Future<ByteData?> _tryLoadCompressed(String path) async {
    final compressedPath = '$path.br';
    try {
      return await rootBundle.load(compressedPath);
    } catch (_) {
      return null;
    }
  }
  
  String _decompress(ByteData data) {
    // Use Brotli decoder
    return brotli.decode(data.buffer.asUint8List());
  }
}
```

### Compression Levels

```dart
enum CompressionLevel {
  none,       // .json (debug only)
  fast,       // LZ4 (mobile, battery-sensitive)
  balanced,   // GZIP level 5 (default)
  maximum,    // Brotli level 11 (storage-constrained)
}

class CompressionConfig {
  static CompressionLevel get level {
    // Based on device/storage
    if (_isLowStorage) return CompressionLevel.maximum;
    if (_isMobile) return CompressionLevel.fast;
    return CompressionLevel.balanced;
  }
}
```

### Build Tool Integration

```dart
// In build.yaml or custom build script
class KnowledgeAssetBuilder extends Builder {
  @override
  Future<void> build(BuildStep buildStep) async {
    // For each .json file in knowledge/
    for (final input in knowledgeAssets) {
      // Generate .json.br version
      await compressWithBrotli(
        input,
        output: '$input.br',
        level: 9,
      );
    }
  }
}
```

---

## Strategy 6: SQLite Migration Path

### Migration Strategy

```
┌─────────────────────────────────────────────────────────────────┐
│                    SQLite Migration Phases                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   PHASE 1: Parallel Operation (v1.x)                             │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                                                          │   │
│   │   JSON Assets ──────┐                                     │   │
│   │                     │                                     │   │
│   │   Search Index ────┼──→ SearchService ──→ UI             │   │
│   │                     │                                     │   │
│   │   SQLite DB ────────┘ (Write-through cache)              │   │
│   │                                                          │   │
│   │   ✓ Search reads from SQLite                             │   │
│   │   ✓ JSON remains source of truth                         │   │
│   │   ✓ Can rollback to JSON-only                             │   │
│   │                                                          │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│   PHASE 2: SQLite as Primary (v2.x)                              │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                                                          │   │
│   │   SQLite DB ──────┬───→ SearchService ──→ UI            │   │
│   │                   │                                     │   │
│   │   JSON Assets ────┘ (Metadata backup)                    │   │
│   │                                                          │   │
│   │   ✓ SQLite is source of truth                            │   │
│   │   ✓ Full query capability (WHERE, JOIN, LIKE)           │   │
│   │   ✓ Indexed searches                                     │   │
│   │   ✓ Partial updates possible                             │   │
│   │                                                          │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│   PHASE 3: Full Migration (v3.x)                                 │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                                                          │   │
│   │   SQLite DB ──────┬───→ App                              │   │
│   │                   │                                     │   │
│   │   JSON Assets ────┘ (Deprecated, removed)                │   │
│   │                                                          │   │
│   │   ✓ JSON assets removed from bundle                      │   │
│   │   ✓ DB ships with app (pre-populated)                    │   │
│   │   ✓ Delta updates possible                               │   │
│   │                                                          │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Target Schema

```sql
-- Knowledge Items
CREATE TABLE knowledge_items (
    id TEXT PRIMARY KEY,
    type TEXT NOT NULL,
    difficulty TEXT NOT NULL,
    category TEXT NOT NULL,
    title TEXT NOT NULL,
    title_vi TEXT,
    summary TEXT,
    purpose TEXT,
    status TEXT DEFAULT 'verified',
    est_minutes INTEGER DEFAULT 15,
    created_at TEXT,
    updated_at TEXT,
    version TEXT
);

-- Full-text search
CREATE VIRTUAL TABLE knowledge_fts USING fts5(
    title, title_vi, summary, purpose,
    content='knowledge_items',
    content_rowid='rowid'
);

-- Keywords (normalized)
CREATE TABLE knowledge_keywords (
    item_id TEXT REFERENCES knowledge_items(id),
    keyword TEXT NOT NULL,
    language TEXT DEFAULT 'en',
    UNIQUE(item_id, keyword, language)
);

CREATE INDEX idx_keywords_keyword ON knowledge_keywords(keyword);

-- Relations
CREATE TABLE knowledge_relations (
    from_id TEXT REFERENCES knowledge_items(id),
    to_id TEXT REFERENCES knowledge_items(id),
    relation_type TEXT NOT NULL,
    weight REAL DEFAULT 1.0,
    PRIMARY KEY(from_id, to_id, relation_type)
);

CREATE INDEX idx_relations_from ON knowledge_relations(from_id);
CREATE INDEX idx_relations_to ON knowledge_relations(to_id);

-- Prerequisites
CREATE TABLE knowledge_prerequisites (
    item_id TEXT REFERENCES knowledge_items(id),
    prereq_id TEXT REFERENCES knowledge_items(id),
    priority INTEGER DEFAULT 1,
    PRIMARY KEY(item_id, prereq_id)
);

-- Drills
CREATE TABLE drills (
    code TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    name_vi TEXT,
    category TEXT NOT NULL,
    difficulty TEXT NOT NULL,
    time_minutes INTEGER DEFAULT 10,
    description TEXT,
    setup TEXT,
    success_criteria TEXT,
    instructions TEXT
);

CREATE INDEX idx_drills_category ON drills(category);
CREATE INDEX idx_drills_difficulty ON drills(difficulty);

-- Drill-Skill Mapping
CREATE TABLE drill_skill_mapping (
    drill_code TEXT REFERENCES drills(code),
    skill_id TEXT REFERENCES knowledge_items(id),
    relevance REAL DEFAULT 1.0,
    PRIMARY KEY(drill_code, skill_id)
);

-- Learning Paths
CREATE TABLE learning_paths (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    name_vi TEXT,
    description TEXT,
    level TEXT NOT NULL,
    total_hours INTEGER,
    version TEXT
);

CREATE TABLE learning_path_phases (
    path_id TEXT REFERENCES learning_paths(id),
    phase_order INTEGER NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    PRIMARY KEY(path_id, phase_order)
);

CREATE TABLE learning_path_items (
    path_id TEXT REFERENCES learning_paths(id),
    phase_order INTEGER,
    item_order INTEGER NOT NULL,
    skill_id TEXT REFERENCES knowledge_items(id),
    PRIMARY KEY(path_id, phase_order, item_order)
);
```

### Migration Utilities

```dart
// Migration entry point
class KnowledgeMigration {
  
  /// Check if migration needed
  Future<MigrationStatus> checkMigrationNeeded() async {
    final jsonVersion = await _getJsonVersion();
    final dbVersion = await _getDbVersion();
    
    if (dbVersion == null) return MigrationStatus.notMigrated;
    if (dbVersion < jsonVersion) return MigrationStatus.needsUpdate;
    return MigrationStatus.current;
  }
  
  /// Phase 1: Write-through
  Future<void> enableWriteThrough() async {
    // SQLite is updated alongside JSON reads
    // SQLite used for all queries
    // JSON remains source of truth for updates
  }
  
  /// Phase 2: Primary switch
  Future<void> switchToSqlite() async {
    // Verify all data synced
    // Flip source of truth to SQLite
    // Keep JSON as backup
  }
  
  /// Phase 3: Cleanup
  Future<void> removeJsonAssets() async {
    // Remove JSON from asset bundle
    // SQLite is only source
  }
}
```

---

## Loading Strategy Summary

```
┌─────────────────────────────────────────────────────────────────┐
│                     Complete Loading Sequence                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   APP START                                                       │
│       │                                                           │
│       ▼                                                           │
│   ┌───────────────────┐                                           │
│   │ Load Master Index │ ← Always first (critical)                │
│   └─────────┬─────────┘                                           │
│             │                                                      │
│             ▼                                                      │
│   ┌───────────────────┐                                           │
│   │ Initialize Cache  │ ← Setup LRU cache                         │
│   └─────────┬─────────┘                                           │
│             │                                                      │
│             ▼                                                      │
│   ┌───────────────────────────────────────────────────┐          │
│   │ Check Network Status                                │          │
│   └───────────────────────────┬───────────────────────┘          │
│           │                   │                                   │
│           ▼ Online            ▼ Offline                          │
│   ┌───────────────┐     ┌───────────────┐                       │
│   │ Load from API │     │ Load from DB  │                       │
│   │ Sync SQLite   │     │ or JSON Cache │                       │
│   └───────┬───────┘     └───────┬───────┘                       │
│           │                     │                               │
│           └──────────┬──────────┘                               │
│                      ▼                                           │
│   ┌───────────────────────────────────────────────────┐          │
│   │ Knowledge Page Request                             │          │
│   └───────────────────────────┬───────────────────────┘          │
│                               │                                   │
│              ┌────────────────┴────────────────┐                │
│              ▼                                 ▼                │
│   ┌───────────────────┐           ┌───────────────────┐        │
│   │ Check Item Cache  │           │ Load Item (lazy)  │        │
│   └─────────┬─────────┘           └─────────┬─────────┘        │
│             │                                 │                  │
│             ▼                                 ▼                  │
│   ┌───────────────────┐           ┌───────────────────┐        │
│   │ Return Cached    │           │ Add to Cache      │        │
│   └───────────────────┘           │ Preload Related  │        │
│                                   └───────────────────┘        │
│                                                                  │
│   SEARCH REQUEST                                                  │
│       │                                                           │
│       ▼                                                           │
│   ┌───────────────────┐                                           │
│   │ Load Search Index │ ← First search only                       │
│   └─────────┬─────────┘                                           │
│             │                                                      │
│             ▼                                                      │
│   ┌───────────────────────────────────────────────────┐          │
│   │ Check Search Cache                                 │          │
│   └───────────────────────────┬───────────────────────┘          │
│                               │                                   │
│              ┌────────────────┴────────────────┐                │
│              ▼                                 ▼                │
│   ┌───────────────────┐           ┌───────────────────┐        │
│   │ Return Cached    │           │ Execute Search   │        │
│   │ Results          │           │ Cache Results    │        │
│   └───────────────────┘           └───────────────────┘        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## File Manifest

```
assets/
└── knowledge/
    ├── index.json                    # Master index (compressed)
    ├── index.json.br                  # Brotli compressed
    ├── search_index.json              # Search keywords
    ├── search_index.json.br           # Compressed
    ├── relation_index.json            # Graph relations
    ├── relation_index.json.br         # Compressed
    ├── drill_index.json              # Drill mappings
    ├── drill_index.json.br            # Compressed
    ├── learning_paths.json           # Learning paths
    ├── learning_paths.json.br        # Compressed
    │
    ├── techniques/
    │   ├── stroke.fundamentals.json
    │   ├── stroke.fundamentals.json.br
    │   └── ...
    │
    ├── mistakes/
    │   └── ...
    │
    ├── strategies/
    │   └── ...
    │
    ├── equipment/
    │   └── ...
    │
    └── media/
        ├── images/
        ├── videos/
        └── diagrams/
```

---

## Future Considerations

| Item | Priority | Notes |
|------|----------|-------|
| Delta updates | HIGH | Only download changed items |
| Background sync | HIGH | Sync when on WiFi |
| Conflict resolution | MEDIUM | Last-write-wins or manual merge |
| Encryption | LOW | Sensitive user progress |
| Multi-device sync | LOW | Via user account |

---

*Generated: 2026-07-17*
*Knowledge Module Offline Strategy v1.0*
