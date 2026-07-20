import 'package:flutter/services.dart';
import 'billiard_knowledge.dart';

export 'src/models/models.dart';
export 'src/repositories/repositories.dart';
export 'src/services/services.dart';
export 'src/loaders/loaders.dart';
export 'src/utils/utils.dart';

/// Main entry point for the Billiard Knowledge library.
///
/// Initialize once at app startup, then access repositories via instance.
class BilliardKnowledge {
  BilliardKnowledge._();

  static final BilliardKnowledge instance = BilliardKnowledge._();

  bool _initialized = false;
  bool _initializing = false;

  // Repositories
  KnowledgeRepository? _knowledgeRepository;
  LearningPathRepository? _learningPathRepository;
  CategoryRepository? _categoryRepository;
  TagRepository? _tagRepository;

  // Services
  KnowledgeSearchService? _searchService;
  KnowledgeRecommendationService? _recommendationService;
  RelationshipResolver? _relationshipResolver;

  // Loaders
  late final DrillMappingLoader _drillLoader;
  late final LearningPathLoader _pathLoader;
  late final KnowledgeAssetLoader _assetLoader;

  /// Current version of the knowledge library
  static const String version = '1.0.0';

  /// Check if library is initialized
  bool get isInitialized => _initialized;

  /// Get the knowledge repository
  /// 
  /// Access after [initialize] is called.
  /// 
  /// ```dart
  /// final repo = BilliardKnowledge.instance.knowledgeRepository;
  /// final item = await repo.byId('stroke.fundamentals');
  /// ```
  KnowledgeRepository get knowledgeRepository {
    _ensureInitialized();
    return _knowledgeRepository!;
  }

  /// Alias for [knowledgeRepository]
  KnowledgeRepository get repository => knowledgeRepository;

  /// Get the learning path repository
  LearningPathRepository get learningPathRepository {
    _ensureInitialized();
    return _learningPathRepository!;
  }

  /// Alias for [learningPathRepository]
  LearningPathRepository get learningPath => learningPathRepository;

  /// Get the category repository
  CategoryRepository get categoryRepository {
    _ensureInitialized();
    return _categoryRepository!;
  }

  /// Alias for [categoryRepository]
  CategoryRepository get categories => categoryRepository;

  /// Get the tag repository
  TagRepository get tagRepository {
    _ensureInitialized();
    return _tagRepository!;
  }

  /// Alias for [tagRepository]
  TagRepository get tags => tagRepository;

  /// Get the search service
  KnowledgeSearchService get searchService {
    _ensureInitialized();
    return _searchService!;
  }

  /// Alias for [searchService]
  KnowledgeSearchService get search => searchService;

  /// Get the recommendation service
  KnowledgeRecommendationService get recommendationService {
    _ensureInitialized();
    return _recommendationService!;
  }

  /// Alias for [recommendationService]
  KnowledgeRecommendationService get recommendations => recommendationService;

  /// Get the relationship resolver
  RelationshipResolver get relationshipResolver {
    _ensureInitialized();
    return _relationshipResolver!;
  }

  /// Alias for [relationshipResolver]
  RelationshipResolver get relations => relationshipResolver;

  /// Get the drill loader
  DrillMappingLoader get drillLoader {
    _ensureInitialized();
    return _drillLoader;
  }

  /// Get the learning path loader
  LearningPathLoader get pathLoader {
    _ensureInitialized();
    return _pathLoader;
  }

  /// Initialize the library
  /// 
  /// Call this once at app startup before using any repository or service.
  /// 
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   await BilliardKnowledge.initialize();
  ///   runApp(MyApp());
  /// }
  /// ```
  /// 
  /// [rootBundle] Optional custom asset bundle. Uses [ServicesBinding.rootBundle] if null.
  /// [config] Optional configuration for the library.
  Future<void> initialize({
    AssetBundle? rootBundle,
    BilliardKnowledgeConfig? config,
  }) async {
    if (_initialized) return;
    if (_initializing) {
      // Wait for existing initialization
      while (_initializing) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return;
    }

    _initializing = true;

    try {
      final bundle = rootBundle ?? ServicesBinding.rootBundle;
      config ??= BilliardKnowledgeConfig.defaultConfig;

      _assetLoader = KnowledgeAssetLoader(bundle);

      _drillLoader = DrillMappingLoader(_assetLoader);
      _pathLoader = LearningPathLoader(_assetLoader);

      _knowledgeRepository = KnowledgeRepository(_assetLoader, _drillLoader);
      _learningPathRepository = LearningPathRepository(_assetLoader);
      _categoryRepository = CategoryRepository(_assetLoader);
      _tagRepository = TagRepository(_assetLoader);

      _searchService = KnowledgeSearchService(
        repository: _knowledgeRepository!,
        assetLoader: _assetLoader,
      );

      _recommendationService = KnowledgeRecommendationService(
        knowledgeRepository: _knowledgeRepository!,
        drillLoader: _drillLoader,
        pathLoader: _pathLoader,
      );

      _relationshipResolver = RelationshipResolver(
        knowledgeRepository: _knowledgeRepository!,
      );

      // Load critical indices first
      await _knowledgeRepository!.loadIndex();
      await _searchService!.loadSearchIndex();

      _initialized = true;
    } finally {
      _initializing = false;
    }
  }

  /// Initialize with async assets (for web platform)
  /// 
  /// Use this for web or when using custom asset loading.
  Future<void> initializeWithLoader(
    Future<ByteData> Function(String) assetLoader,
    BilliardKnowledgeConfig? config,
  ) async {
    if (_initialized) return;

    final webLoader = WebKnowledgeAssetLoader(assetLoader);
    config ??= BilliardKnowledgeConfig.defaultConfig;

    _assetLoader = webLoader;

    _drillLoader = DrillMappingLoader(_assetLoader);
    _pathLoader = LearningPathLoader(_assetLoader);

    _knowledgeRepository = KnowledgeRepository(_assetLoader, _drillLoader);
    _learningPathRepository = LearningPathRepository(_assetLoader);
    _categoryRepository = CategoryRepository(_assetLoader);
    _tagRepository = TagRepository(_assetLoader);

    _searchService = KnowledgeSearchService(
      repository: _knowledgeRepository!,
      assetLoader: _assetLoader,
    );

    _recommendationService = KnowledgeRecommendationService(
      knowledgeRepository: _knowledgeRepository!,
      drillLoader: _drillLoader,
      pathLoader: _pathLoader,
    );

    _relationshipResolver = RelationshipResolver(
      knowledgeRepository: _knowledgeRepository!,
    );

    await _knowledgeRepository!.loadIndex();
    await _searchService!.loadSearchIndex();

    _initialized = true;
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'BilliardKnowledge not initialized. '
        'Call BilliardKnowledge.initialize() first.',
      );
    }
  }

  /// Clear all cached data
  /// 
  /// Useful for testing or when memory is low.
  Future<void> clearCache() async {
    _knowledgeRepository?.clearCache();
    _searchService?.clearCache();
    _drillLoader.clearCache();
    _pathLoader.clearCache();
  }

  /// Dispose the library
  /// 
  /// Call when disposing the app to clean up resources.
  Future<void> dispose() async {
    await clearCache();
    _initialized = false;
  }
}

/// Configuration for the Billiard Knowledge library
class BilliardKnowledgeConfig {
  /// Enable search caching
  final bool enableSearchCache;

  /// Enable lazy loading of items
  final bool enableLazyLoading;

  /// Maximum cache size in MB
  final int maxCacheSizeMb;

  /// Default search result limit
  final int defaultSearchLimit;

  /// Default language for search
  final String defaultLanguage;

  const BilliardKnowledgeConfig({
    this.enableSearchCache = true,
    this.enableLazyLoading = true,
    this.maxCacheSizeMb = 100,
    this.defaultSearchLimit = 20,
    this.defaultLanguage = 'en',
  });

  /// Default configuration
  static const BilliardKnowledgeConfig defaultConfig = BilliardKnowledgeConfig();

  /// Configuration optimized for memory-constrained devices
  static const BilliardKnowledgeConfig lowMemory = BilliardKnowledgeConfig(
    enableSearchCache: true,
    enableLazyLoading: true,
    maxCacheSizeMb: 50,
    defaultSearchLimit: 10,
  );

  /// Configuration optimized for web
  static const BilliardKnowledgeConfig web = BilliardKnowledgeConfig(
    enableSearchCache: true,
    enableLazyLoading: true,
    maxCacheSizeMb: 200,
    defaultSearchLimit: 30,
  );
}
