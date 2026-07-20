import '../models/models.dart';
import 'knowledge_asset_loader.dart';

/// Loader for learning paths.
///
/// Provides methods to access and query learning paths,
/// including filtering by level, difficulty, and finding
/// paths containing specific knowledge items.
///
/// ```dart
/// final loader = BilliardKnowledge.instance.pathLoader;
///
/// // Get all paths
/// final paths = await loader.getAllPaths();
///
/// // Get paths for a level
/// final beginner = await loader.getPathsForLevel('H');
///
/// // Get path containing an item
/// final path = await loader.getPathForItem('stroke.fundamentals');
/// ```
class LearningPathLoader {
  final KnowledgeAssetLoader _assetLoader;

  bool _loaded = false;
  List<LearningPath>? _paths;
  final Map<String, LearningPath> _pathIndex = {};
  final Map<String, LearningPath> _itemPathIndex = {};

  LearningPathLoader(this._assetLoader);

  /// Ensure paths are loaded.
  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    await _loadPaths();
  }

  Future<void> _loadPaths() async {
    final paths = await _assetLoader.loadLearningPaths();
    _paths = paths;

    // Build indices
    _pathIndex.clear();
    _itemPathIndex.clear();

    for (final path in paths) {
      _pathIndex[path.id] = path;

      // Index items to paths
      for (final phase in path.phases) {
        for (final item in phase.items) {
          _itemPathIndex[item.skillId] = path;
        }
      }
    }

    _loaded = true;
  }

  /// Get all learning paths.
  /// 
  /// ```dart
  /// final paths = await loader.getAllPaths();
  /// ```
  Future<List<LearningPath>> getAllPaths() async {
    await _ensureLoaded();
    return List.unmodifiable(_paths!);
  }

  /// Get a path by ID.
  /// 
  /// ```dart
  /// final path = await loader.getPath('complete_beginner');
  /// ```
  Future<LearningPath?> getPath(String id) async {
    await _ensureLoaded();
    return _pathIndex[id];
  }

  /// Get paths for a player level.
  /// 
  /// ```dart
  /// final beginner = await loader.getPathsForLevel('H');
  /// ```
  Future<List<LearningPath>> getPathsForLevel(String level) async {
    await _ensureLoaded();
    return _paths!.where((p) => p.targetLevel == level).toList();
  }

  /// Get paths for a difficulty level.
  /// 
  /// ```dart
  /// final beginner = await loader.getPathsForDifficulty(KnowledgeDifficulty.beginner);
  /// ```
  Future<List<LearningPath>> getPathsForDifficulty(KnowledgeDifficulty difficulty) async {
    await _ensureLoaded();
    return _paths!.where((p) => p.difficulty == difficulty).toList();
  }

  /// Get the learning path containing a knowledge item.
  /// 
  /// ```dart
  /// final path = await loader.getPathForItem('stroke.fundamentals');
  /// ```
  Future<LearningPath?> getPathForItem(String itemId) async {
    await _ensureLoaded();
    return _itemPathIndex[itemId];
  }

  /// Get the phase containing an item.
  /// 
  /// ```dart
  /// final phase = await loader.getPhaseForItem('stroke.fundamentals');
  /// ```
  Future<LearningPhase?> getPhaseForItem(String itemId) async {
    final path = await getPathForItem(itemId);
    if (path == null) return null;

    for (final phase in path.phases) {
      for (final item in phase.items) {
        if (item.skillId == itemId) {
          return phase;
        }
      }
    }
    return null;
  }

  /// Get the index of an item in its path (0-based).
  /// 
  /// ```dart
  /// final index = await loader.getItemIndex('stroke.fundamentals');
  /// // Returns 0 if first, 1 if second, etc.
  /// ```
  Future<int?> getItemIndex(String itemId) async {
    final path = await getPathForItem(itemId);
    if (path == null) return null;

    int index = 0;
    for (final phase in path.phases) {
      for (final item in phase.items) {
        if (item.skillId == itemId) {
          return index;
        }
        index++;
      }
    }
    return null;
  }

  /// Get items before an item in its path.
  /// 
  /// Returns all items that come before the given item.
  /// 
  /// ```dart
  /// final before = await loader.getItemsBefore('draw.fundamentals');
  /// ```
  Future<List<String>> getItemsBefore(String itemId) async {
    final path = await getPathForItem(itemId);
    if (path == null) return [];

    final result = <String>[];
    final index = await getItemIndex(itemId);
    if (index == null) return [];

    int currentIndex = 0;
    for (final phase in path.phases) {
      for (final item in phase.items) {
        if (currentIndex >= index) break;
        result.add(item.skillId);
        currentIndex++;
      }
    }

    return result;
  }

  /// Get items after an item in its path.
  /// 
  /// Returns all items that come after the given item.
  /// 
  /// ```dart
  /// final after = await loader.getItemsAfter('stroke.fundamentals');
  /// ```
  Future<List<String>> getItemsAfter(String itemId) async {
    final path = await getPathForItem(itemId);
    if (path == null) return [];

    final result = <String>[];
    final index = await getItemIndex(itemId);
    if (index == null) return null;

    int currentIndex = 0;
    bool found = false;
    for (final phase in path.phases) {
      for (final item in phase.items) {
        if (currentIndex > index) {
          result.add(item.skillId);
        }
        if (currentIndex == index) {
          found = true;
        }
        currentIndex++;
      }
    }

    return result;
  }

  /// Get next item in path after the given item.
  /// 
  /// ```dart
  /// final next = await loader.getNextItem('stroke.fundamentals');
  /// ```
  Future<String?> getNextItem(String itemId) async {
    final after = await getItemsAfter(itemId);
    if (after.isEmpty) return null;
    return after.first;
  }

  /// Calculate progress through a path.
  /// 
  /// ```dart
  /// final progress = await loader.calculateProgress(
  ///   pathId: 'complete_beginner',
  ///   completedItems: {'stroke.fundamentals', 'aim.center_ball'},
  /// );
  /// ```
  Future<double> calculateProgress({
    required String pathId,
    required Set<String> completedItems,
  }) async {
    final path = await getPath(pathId);
    if (path == null) return 0.0;

    int total = 0;
    int completed = 0;

    for (final phase in path.phases) {
      for (final item in phase.items) {
        total++;
        if (completedItems.contains(item.skillId)) {
          completed++;
        }
      }
    }

    if (total == 0) return 0.0;
    return completed / total;
  }

  /// Get all paths as summaries.
  /// 
  /// ```dart
  /// final summaries = await loader.getSummaries();
  /// ```
  Future<List<LearningPathSummary>> getSummaries() async {
    final paths = await getAllPaths();
    return paths.map((p) => LearningPathSummary.fromPath(p)).toList();
  }

  /// Get recommended path for a player level.
  /// 
  /// Returns the primary/recommended path for the level.
  /// 
  /// ```dart
  /// final recommended = await loader.getRecommendedPath('H');
  /// ```
  Future<LearningPath?> getRecommendedPath(String level) async {
    final paths = await getPathsForLevel(level);
    if (paths.isEmpty) return null;

    // Return first path (could be sorted by priority)
    return paths.first;
  }

  /// Search paths by name.
  /// 
  /// ```dart
  /// final results = await loader.searchPaths('beginner');
  /// ```
  Future<List<LearningPath>> searchPaths(String query) async {
    await _ensureLoaded();
    final lowerQuery = query.toLowerCase();

    return _paths!.where((path) {
      return path.name.toLowerCase().contains(lowerQuery) ||
          path.nameVi.toLowerCase().contains(lowerQuery) ||
          path.description.toLowerCase().contains(lowerQuery) ||
          path.tags.any((t) => t.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Clear cached data.
  void clearCache() {
    _paths = null;
    _pathIndex.clear();
    _itemPathIndex.clear();
    _loaded = false;
  }
}
