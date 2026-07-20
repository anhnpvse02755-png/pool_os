import '../loaders/knowledge_asset_loader.dart';
import '../models/models.dart';

/// Repository for accessing knowledge categories.
///
/// ```dart
/// final catRepo = BilliardKnowledge.instance.categoryRepository;
///
/// // Get all categories
/// final categories = await catRepo.getAll();
///
/// // Get category by ID
/// final aim = await catRepo.byId('aim');
/// ```
class CategoryRepository {
  final KnowledgeAssetLoader _assetLoader;

  bool _loaded = false;
  List<Category>? _categories;
  final Map<String, Category> _index = {};

  CategoryRepository(this._assetLoader);

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    await _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _assetLoader.loadCategories();
    _categories = categories;
    _index.clear();
    for (final cat in categories) {
      _index[cat.id] = cat;
    }
    _loaded = true;
  }

  /// Get all categories.
  /// 
  /// ```dart
  /// final categories = await repo.getAll();
  /// ```
  Future<List<Category>> getAll() async {
    await _ensureLoaded();
    return List.unmodifiable(_categories!);
  }

  /// Get a category by ID.
  /// 
  /// ```dart
  /// final aim = await repo.byId('aim');
  /// ```
  Future<Category?> byId(String id) async {
    await _ensureLoaded();
    return _index[id];
  }

  /// Get child categories of a parent.
  /// 
  /// ```dart
  /// final children = await repo.children('techniques');
  /// ```
  Future<List<Category>> children(String parentId) async {
    await _ensureLoaded();
    return _categories!.where((c) => c.parentId == parentId).toList();
  }

  /// Get root categories (no parent).
  /// 
  /// ```dart
  /// final roots = await repo.rootCategories();
  /// ```
  Future<List<Category>> rootCategories() async {
    await _ensureLoaded();
    return _categories!.where((c) => c.parentId == null).toList();
  }

  /// Clear cache.
  void clearCache() {
    _categories = null;
    _index.clear();
    _loaded = false;
  }
}
