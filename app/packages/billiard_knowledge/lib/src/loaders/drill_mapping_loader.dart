import '../models/models.dart';
import 'knowledge_asset_loader.dart';

/// Loader for drill-to-knowledge mappings.
///
/// This loader reads drill definitions and provides methods to:
/// - Get drills for a knowledge item
/// - Get knowledge items for a drill
/// - Get drills by category or difficulty
///
/// ```dart
/// final loader = BilliardKnowledge.instance.drillLoader;
///
/// // Get drills for a skill
/// final drills = loader.getDrillsForKnowledgeItem('aim.center_ball');
///
/// // Get drills by category
/// final aimDrills = loader.getDrillsBySkill('aim');
/// ```
class DrillMappingLoader {
  final KnowledgeAssetLoader _assetLoader;

  bool _loaded = false;
  List<Drill>? _drills;
  final Map<String, List<Drill>> _skillIndex = {};
  final Map<String, List<Drill>> _categoryIndex = {};
  final Map<String, List<Drill>> _difficultyIndex = {};

  // Mapping from knowledge item ID to drills
  final Map<String, List<String>> _itemToDrillCodes = {};
  // Mapping from drill code to knowledge item IDs
  final Map<String, List<String>> _drillToItemIds = {};

  DrillMappingLoader(this._assetLoader);

  /// Ensure drills are loaded.
  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    await _loadDrills();
  }

  Future<void> _loadDrills() async {
    final drills = await _assetLoader.loadDrills();
    _drills = drills;

    // Build indices
    for (final drill in drills) {
      // Category index
      _categoryIndex.putIfAbsent(drill.category, () => []).add(drill);

      // Difficulty index
      _difficultyIndex.putIfAbsent(drill.difficulty.name, () => []).add(drill);

      // Skill index (from tags)
      for (final tag in drill.tags) {
        _skillIndex.putIfAbsent(tag, () => []).add(drill);
      }
      // Also index by category
      _skillIndex.putIfAbsent(drill.category, () => []).add(drill);
    }

    // Build item-to-drill mappings
    // This would ideally come from a separate mapping file
    _buildMappings();

    _loaded = true;
  }

  void _buildMappings() {
    // Build mappings based on category and tags
    for (final drill in _drills!) {
      final itemIds = <String>[];

      // Map by category
      itemIds.add(drill.category);

      // Map by tags
      itemIds.addAll(drill.tags);

      _drillToItemIds[drill.code] = itemIds;

      for (final itemId in itemIds) {
        _itemToDrillCodes.putIfAbsent(itemId, () => []).add(drill.code);
      }
    }
  }

  /// Get all drills.
  /// 
  /// ```dart
  /// final all = loader.getAllDrills();
  /// ```
  Future<List<Drill>> getAllDrills() async {
    await _ensureLoaded();
    return List.unmodifiable(_drills!);
  }

  /// Get a drill by code.
  /// 
  /// ```dart
  /// final drill = await loader.getDrill('D001');
  /// ```
  Future<Drill?> getDrill(String code) async {
    await _ensureLoaded();
    return _drills!.cast<Drill?>().firstWhere(
      (d) => d!.code == code,
      orElse: () => null,
    );
  }

  /// Get drills for a knowledge item ID.
  /// 
  /// Returns drills associated with the given skill/item.
  /// 
  /// ```dart
  /// final drills = loader.getDrillsForKnowledgeItem('aim.center_ball');
  /// ```
  Future<List<Drill>> getDrillsForKnowledgeItem(String itemId) async {
    await _ensureLoaded();

    final codes = _itemToDrillCodes[itemId];
    if (codes == null) return [];

    return _drills!.where((d) => codes.contains(d.code)).toList();
  }

  /// Get drills by skill/category.
  /// 
  /// ```dart
  /// final aimDrills = loader.getDrillsBySkill('aim');
  /// ```
  Future<List<Drill>> getDrillsBySkill(String skill) async {
    await _ensureLoaded();
    return _skillIndex[skill] ?? [];
  }

  /// Get drills by category.
  /// 
  /// ```dart
  /// final categoryDrills = loader.getDrillsByCategory('techniques');
  /// ```
  Future<List<Drill>> getDrillsByCategory(String category) async {
    await _ensureLoaded();
    return _categoryIndex[category] ?? [];
  }

  /// Get drills by difficulty.
  /// 
  /// ```dart
  /// final beginnerDrills = loader.getDrillsByDifficulty(DrillDifficulty.beginner);
  /// ```
  Future<List<Drill>> getDrillsByDifficulty(DrillDifficulty difficulty) async {
    await _ensureLoaded();
    return _difficultyIndex[difficulty.name] ?? [];
  }

  /// Get knowledge item IDs for a drill.
  /// 
  /// ```dart
  /// final items = loader.getKnowledgeItemsForDrill('D001');
  /// ```
  Future<List<String>> getKnowledgeItemsForDrill(String code) async {
    await _ensureLoaded();
    return _drillToItemIds[code] ?? [];
  }

  /// Get all unique categories.
  /// 
  /// ```dart
  /// final categories = loader.getCategories();
  /// ```
  Future<List<String>> getCategories() async {
    await _ensureLoaded();
    return _categoryIndex.keys.toList();
  }

  /// Get all unique skills/tags.
  /// 
  /// ```dart
  /// final skills = loader.getSkills();
  /// ```
  Future<List<String>> getSkills() async {
    await _ensureLoaded();
    return _skillIndex.keys.toList();
  }

  /// Search drills by name.
  /// 
  /// ```dart
  /// final results = await loader.searchDrills('draw');
  /// ```
  Future<List<Drill>> searchDrills(String query) async {
    await _ensureLoaded();
    final lowerQuery = query.toLowerCase();
    
    return _drills!.where((drill) {
      return drill.name.toLowerCase().contains(lowerQuery) ||
          drill.nameVi.toLowerCase().contains(lowerQuery) ||
          drill.description.toLowerCase().contains(lowerQuery) ||
          drill.tags.any((t) => t.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Get drill count.
  /// 
  /// ```dart
  /// final count = loader.count();
  /// ```
  Future<int> count() async {
    await _ensureLoaded();
    return _drills!.length;
  }

  /// Clear cached data.
  void clearCache() {
    _drills = null;
    _skillIndex.clear();
    _categoryIndex.clear();
    _difficultyIndex.clear();
    _itemToDrillCodes.clear();
    _drillToItemIds.clear();
    _loaded = false;
  }
}
