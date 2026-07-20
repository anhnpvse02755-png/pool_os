import '../loaders/knowledge_asset_loader.dart';
import '../loaders/drill_mapping_loader.dart';
import '../models/models.dart';

/// Repository for accessing knowledge items.
///
/// This is the main entry point for reading knowledge content.
/// All JSON loading happens internally - consumers should never
/// read JSON files directly.
///
/// ```dart
/// final repo = BilliardKnowledge.instance.repository;
///
/// // Get a single item
/// final item = await repo.byId('stroke.fundamentals');
///
/// // Get all items
/// final all = await repo.getAll();
///
/// // Get by category
/// final aim = await repo.byCategory('aim');
/// ```
class KnowledgeRepository {
  final KnowledgeAssetLoader _assetLoader;
  final DrillMappingLoader _drillLoader;

  bool _indexLoaded = false;
  final Map<String, KnowledgeItem> _itemCache = {};
  final Map<String, List<String>> _categoryIndex = {};
  final Map<KnowledgeType, List<String>> _typeIndex = {};
  final Map<KnowledgeDifficulty, List<String>> _difficultyIndex = {};
  List<String> _allIds = [];

  KnowledgeRepository(this._assetLoader, this._drillLoader);

  /// Load the knowledge index.
  /// 
  /// Called automatically by [BilliardKnowledge.initialize].
  /// Can be called manually to refresh.
  Future<void> loadIndex() async {
    if (_indexLoaded) return;

    final index = await _assetLoader.loadIndex();
    
    // Build category index
    _categoryIndex.clear();
    for (final entry in index.entries) {
      final category = entry.key;
      final ids = entry.value as List<String>;
      _categoryIndex[category] = ids;
      _allIds.addAll(ids);
    }

    // Build type index
    _typeIndex.clear();
    for (final category in _categoryIndex.keys) {
      final type = _categoryToType(category);
      _typeIndex.putIfAbsent(type, () => []).addAll(_categoryIndex[category]!);
    }

    _indexLoaded = true;
  }

  /// Ensure the index is loaded.
  void _ensureIndexLoaded() {
    if (!_indexLoaded) {
      throw StateError(
        'Knowledge index not loaded. '
        'Call loadIndex() first or use BilliardKnowledge.initialize().',
      );
    }
  }

  /// Get a knowledge item by ID.
  /// 
  /// Uses lazy loading - item is loaded on first access.
  /// 
  /// ```dart
  /// final item = await repo.byId('stroke.fundamentals');
  /// if (item != null) {
  ///   print(item.title); // "Stroke Fundamentals"
  /// }
  /// ```
  Future<KnowledgeItem?> byId(String id) async {
    _ensureIndexLoaded();

    // Check cache
    if (_itemCache.containsKey(id)) {
      return _itemCache[id];
    }

    // Load from assets
    final item = await _loadItem(id);
    if (item != null) {
      _itemCache[id] = item;
    }
    return item;
  }

  /// Get multiple items by IDs.
  /// 
  /// Efficient batch loading for related items.
  /// 
  /// ```dart
  /// final items = await repo.byIds([
  ///   'stroke.fundamentals',
  ///   'aim.center_ball',
  /// ]);
  /// ```
  Future<List<KnowledgeItem>> byIds(List<String> ids) async {
    _ensureIndexLoaded();

    final results = <KnowledgeItem>[];
    final toLoad = <String>[];

    for (final id in ids) {
      if (_itemCache.containsKey(id)) {
        results.add(_itemCache[id]!);
      } else {
        toLoad.add(id);
      }
    }

    // Load remaining items
    if (toLoad.isNotEmpty) {
      final loaded = await _loadItems(toLoad);
      for (final item in loaded) {
        if (item != null) {
          _itemCache[item.id] = item;
          results.add(item);
        }
      }
    }

    return results;
  }

  /// Get all knowledge items.
  /// 
  /// Returns all items. May trigger loading of all JSON files.
  /// Consider using [byCategory] or [byType] for partial loads.
  /// 
  /// ```dart
  /// final all = await repo.getAll();
  /// print('Total items: ${all.length}');
  /// ```
  Future<List<KnowledgeItem>> getAll() async {
    _ensureIndexLoaded();
    return byIds(_allIds);
  }

  /// Get all item IDs (without loading content).
  /// 
  /// ```dart
  /// final ids = repo.getAllIds();
  /// print('Total: ${ids.length}');
  /// ```
  List<String> getAllIds() {
    _ensureIndexLoaded();
    return List.unmodifiable(_allIds);
  }

  /// Get items by category.
  /// 
  /// Categories: aim, bridge, stroke, techniques, mistakes, etc.
  /// 
  /// ```dart
  /// final aimItems = await repo.byCategory('aim');
  /// ```
  Future<List<KnowledgeItem>> byCategory(String category) async {
    _ensureIndexLoaded();
    final ids = _categoryIndex[category];
    if (ids == null) return [];
    return byIds(ids);
  }

  /// Get all categories.
  /// 
  /// ```dart
  /// final categories = repo.getCategories();
  /// for (final cat in categories) {
  ///   print(cat);
  /// }
  /// ```
  List<String> getCategories() {
    _ensureIndexLoaded();
    return _categoryIndex.keys.toList();
  }

  /// Get item count per category.
  /// 
  /// ```dart
  /// final counts = repo.getCategoryCounts();
  /// print('Aim: ${counts['aim']}');
  /// ```
  Map<String, int> getCategoryCounts() {
    _ensureIndexLoaded();
    return _categoryIndex.map((k, v) => MapEntry(k, v.length));
  }

  /// Get items by type.
  /// 
  /// ```dart
  /// final techniques = await repo.byType(KnowledgeType.technique);
  /// ```
  Future<List<KnowledgeItem>> byType(KnowledgeType type) async {
    _ensureIndexLoaded();
    final ids = _typeIndex[type];
    if (ids == null) return [];
    return byIds(ids);
  }

  /// Get items by difficulty.
  /// 
  /// ```dart
  /// final beginner = await repo.byDifficulty(KnowledgeDifficulty.beginner);
  /// ```
  Future<List<KnowledgeItem>> byDifficulty(KnowledgeDifficulty difficulty) async {
    _ensureIndexLoaded();
    final ids = _difficultyIndex[difficulty];
    if (ids == null) return [];

    // Load items and filter by difficulty
    final items = await byIds(ids);
    return items.where((i) => i.difficulty == difficulty).toList();
  }

  /// Get prerequisites for an item.
  /// 
  /// ```dart
  /// final prereqs = await repo.prerequisites('draw.fundamentals');
  /// ```
  Future<List<KnowledgeItem>> prerequisites(String itemId) async {
    final item = await byId(itemId);
    if (item == null) return [];
    return byIds(item.prerequisites);
  }

  /// Get related items for an item.
  /// 
  /// ```dart
  /// final related = await repo.related('draw.fundamentals');
  /// ```
  Future<List<KnowledgeItem>> related(String itemId) async {
    final item = await byId(itemId);
    if (item == null) return [];
    return byIds(item.relatedKnowledge.map((r) => r.id).toList());
  }

  /// Get drills for an item.
  /// 
  /// ```dart
  /// final drills = await repo.drills('aim.center_ball');
  /// ```
  List<Drill> drillsFor(String itemId) {
    return _drillLoader.getDrillsForKnowledgeItem(itemId);
  }

  /// Get total item count.
  /// 
  /// ```dart
  /// final count = repo.count();
  /// ```
  int count() {
    _ensureIndexLoaded();
    return _allIds.length;
  }

  /// Clear the item cache.
  /// 
  /// Useful for memory management.
  void clearCache() {
    _itemCache.clear();
  }

  /// Preload items into cache.
  /// 
  /// ```dart
  /// await repo.preload(['stroke.fundamentals', 'aim.center_ball']);
  /// ```
  Future<void> preload(List<String> ids) async {
    await byIds(ids);
  }

  // ===== Private Methods =====

  Future<KnowledgeItem?> _loadItem(String id) async {
    // Determine category from ID
    final parts = id.split('.');
    if (parts.isEmpty) return null;

    final category = parts[0];
    return _assetLoader.loadKnowledgeItem(category, id);
  }

  Future<List<KnowledgeItem?>> _loadItems(List<String> ids) async {
    // Group by category for batch loading
    final byCategory = <String, List<String>>{};
    for (final id in ids) {
      final parts = id.split('.');
      if (parts.isEmpty) continue;
      final category = parts[0];
      byCategory.putIfAbsent(category, () => []).add(id);
    }

    final results = <KnowledgeItem?>[null];
    for (final entry in byCategory.entries) {
      final loaded = await _assetLoader.loadKnowledgeItems(entry.key, entry.value);
      results.addAll(loaded);
    }
    return results;
  }

  KnowledgeType _categoryToType(String category) {
    final mappings = {
      'techniques': KnowledgeType.technique,
      'mistakes': KnowledgeType.mistake,
      'strategies': KnowledgeType.strategy,
      'equipment': KnowledgeType.equipment,
      'mental': KnowledgeType.mental,
      'aim': KnowledgeType.aim,
      'bridge': KnowledgeType.bridge,
      'cue_ball': KnowledgeType.cueBall,
      'bank': KnowledgeType.bank,
      'safety': KnowledgeType.safety,
      'break': KnowledgeType.breakShot,
    };
    return mappings[category] ?? KnowledgeType.other;
  }
}
