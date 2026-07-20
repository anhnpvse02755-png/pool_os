import '../loaders/knowledge_asset_loader.dart';
import '../models/models.dart';

/// Repository for accessing learning paths.
///
/// ```dart
/// final pathRepo = BilliardKnowledge.instance.learningPathRepository;
///
/// // Get all paths
/// final paths = await pathRepo.getAll();
///
/// // Get path for a specific item
/// final path = await pathRepo.forItem('stroke.fundamentals');
/// ```
class LearningPathRepository {
  final KnowledgeAssetLoader _assetLoader;

  bool _loaded = false;
  List<LearningPath>? _paths;
  final Map<String, LearningPath> _pathIndex = {};

  LearningPathRepository(this._assetLoader);

  /// Ensure paths are loaded.
  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    await _loadPaths();
  }

  Future<void> _loadPaths() async {
    final paths = await _assetLoader.loadLearningPaths();
    _paths = paths;
    _pathIndex.clear();
    for (final path in paths) {
      _pathIndex[path.id] = path;
    }
    _loaded = true;
  }

  /// Get all learning paths.
  /// 
  /// ```dart
  /// final paths = await repo.getAll();
  /// ```
  Future<List<LearningPath>> getAll() async {
    await _ensureLoaded();
    return List.unmodifiable(_paths!);
  }

  /// Get a path by ID.
  /// 
  /// ```dart
  /// final path = await repo.byId('complete_beginner');
  /// ```
  Future<LearningPath?> byId(String id) async {
    await _ensureLoaded();
    return _pathIndex[id];
  }

  /// Get all path summaries.
  /// 
  /// ```dart
  /// final summaries = repo.getSummaries();
  /// ```
  Future<List<LearningPathSummary>> getSummaries() async {
    final paths = await getAll();
    return paths.map((p) => LearningPathSummary.fromPath(p)).toList();
  }

  /// Get paths for a specific player level.
  /// 
  /// ```dart
  /// final beginnerPaths = await repo.forLevel('H');
  /// ```
  Future<List<LearningPath>> forLevel(String level) async {
    await _ensureLoaded();
    return _paths!.where((p) => p.targetLevel == level).toList();
  }

  /// Get the learning path containing a specific item.
  /// 
  /// ```dart
  /// final path = await repo.forItem('stroke.fundamentals');
  /// ```
  Future<LearningPath?> forItem(String itemId) async {
    await _ensureLoaded();
    for (final path in _paths!) {
      if (path.containsItem(itemId)) {
        return path;
      }
    }
    return null;
  }

  /// Get paths for a specific difficulty.
  /// 
  /// ```dart
  /// final beginnerPaths = await repo.forDifficulty(KnowledgeDifficulty.beginner);
  /// ```
  Future<List<LearningPath>> forDifficulty(KnowledgeDifficulty difficulty) async {
    await _ensureLoaded();
    return _paths!.where((p) => p.difficulty == difficulty).toList();
  }

  /// Get the phase containing an item.
  /// 
  /// ```dart
  /// final phase = await repo.phaseForItem('stroke.fundamentals');
  /// ```
  Future<LearningPhase?> phaseForItem(String itemId) async {
    await _ensureLoaded();
    for (final path in _paths!) {
      final phase = path.findPhaseForItem(itemId);
      if (phase != null) {
        return phase;
      }
    }
    return null;
  }

  /// Get item index in its path.
  /// 
  /// Returns 0-based index of item in the path.
  /// 
  /// ```dart
  /// final index = await repo.itemIndex('stroke.fundamentals');
  /// ```
  Future<int?> itemIndex(String itemId) async {
    await _ensureLoaded();
    for (final path in _paths!) {
      final index = path.itemIndex(itemId);
      if (index != null) {
        return index;
      }
    }
    return null;
  }

  /// Get progress through path for completed items.
  /// 
  /// ```dart
  /// final progress = await repo.calculateProgress(
  ///   pathId: 'complete_beginner',
  ///   completedItems: {'stroke.fundamentals', 'aim.center_ball'},
  /// );
  /// ```
  Future<double> calculateProgress({
    required String pathId,
    required Set<String> completedItems,
  }) async {
    final path = await byId(pathId);
    if (path == null) return 0.0;

    final totalItems = path.totalItems;
    if (totalItems == 0) return 0.0;

    int completed = 0;
    for (final id in path.itemIds) {
      if (completedItems.contains(id)) {
        completed++;
      }
    }

    return completed / totalItems;
  }

  /// Clear cached data.
  void clearCache() {
    _paths = null;
    _pathIndex.clear();
    _loaded = false;
  }
}
