import '../loaders/knowledge_asset_loader.dart';
import '../models/models.dart';

/// Repository for accessing knowledge tags.
///
/// ```dart
/// final tagRepo = BilliardKnowledge.instance.tagRepository;
///
/// // Get all tags
/// final tags = await tagRepo.getAll();
///
/// // Search tags
/// final matching = await tagRepo.search('stroke');
/// ```
class TagRepository {
  final KnowledgeAssetLoader _assetLoader;

  bool _loaded = false;
  List<Tag>? _tags;
  final Map<String, Tag> _index = {};
  final Map<String, List<Tag>> _categoryIndex = {};

  TagRepository(this._assetLoader);

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    await _loadTags();
  }

  Future<void> _loadTags() async {
    final tags = await _assetLoader.loadTags();
    _tags = tags;
    _index.clear();
    _categoryIndex.clear();
    for (final tag in tags) {
      _index[tag.id] = tag;
      if (tag.category != null) {
        _categoryIndex.putIfAbsent(tag.category!, () => []).add(tag);
      }
    }
    _loaded = true;
  }

  /// Get all tags.
  /// 
  /// ```dart
  /// final tags = await repo.getAll();
  /// ```
  Future<List<Tag>> getAll() async {
    await _ensureLoaded();
    return List.unmodifiable(_tags!);
  }

  /// Get a tag by ID.
  /// 
  /// ```dart
  /// final tag = await repo.byId('power');
  /// ```
  Future<Tag?> byId(String id) async {
    await _ensureLoaded();
    return _index[id];
  }

  /// Get tags by category.
  /// 
  /// ```dart
  /// final techniqueTags = await repo.byCategory('technique');
  /// ```
  Future<List<Tag>> byCategory(String category) async {
    await _ensureLoaded();
    return _categoryIndex[category] ?? [];
  }

  /// Search tags by name.
  /// 
  /// ```dart
  /// final results = await repo.search('power');
  /// ```
  Future<List<Tag>> search(String query) async {
    await _ensureLoaded();
    final lowerQuery = query.toLowerCase();
    return _tags!.where((tag) {
      return tag.name.toLowerCase().contains(lowerQuery) ||
          tag.nameVi.toLowerCase().contains(lowerQuery) ||
          tag.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get most used tags.
  /// 
  /// ```dart
  /// final popular = await repo.mostUsed(10);
  /// ```
  Future<List<Tag>> mostUsed([int limit = 10]) async {
    await _ensureLoaded();
    final sorted = List<Tag>.from(_tags!)
      ..sort((a, b) => b.usageCount.compareTo(a.usageCount));
    return sorted.take(limit).toList();
  }

  /// Clear cache.
  void clearCache() {
    _tags = null;
    _index.clear();
    _categoryIndex.clear();
    _loaded = false;
  }
}
