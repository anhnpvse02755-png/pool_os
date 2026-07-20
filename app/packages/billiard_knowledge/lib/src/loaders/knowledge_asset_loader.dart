import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/models.dart';

/// Abstract loader interface for knowledge assets.
///
/// Implement this to support different asset loading strategies
/// (Flutter assets, web assets, network, etc.).
abstract class KnowledgeAssetLoader {
  /// Load the main index file.
  Future<Map<String, dynamic>> loadAsset(String path);

  /// Load and parse the index.
  Future<Map<String, List<String>>> loadIndex() async {
    final data = await loadAsset('assets/knowledge/index.json');
    return _parseIndex(data);
  }

  /// Load and parse search index.
  Future<SearchIndexData> loadSearchIndex() async {
    final data = await loadAsset('assets/knowledge/search_index.json');
    return SearchIndexData.fromJson(data);
  }

  /// Load learning paths.
  Future<List<LearningPath>> loadLearningPaths() async {
    final data = await loadAsset('assets/knowledge/learning_paths.json');
    return _parseLearningPaths(data);
  }

  /// Load categories.
  Future<List<Category>> loadCategories() async {
    final data = await loadAsset('assets/knowledge/categories.json');
    return _parseCategories(data);
  }

  /// Load tags.
  Future<List<Tag>> loadTags() async {
    final data = await loadAsset('assets/knowledge/tags.json');
    return _parseTags(data);
  }

  /// Load a single knowledge item.
  Future<KnowledgeItem?> loadKnowledgeItem(String category, String id) async {
    final path = 'assets/knowledge/$category/$id.json';
    try {
      final data = await loadAsset(path);
      return KnowledgeItem.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// Load multiple knowledge items from a category.
  Future<List<KnowledgeItem?>> loadKnowledgeItems(
    String category,
    List<String> ids,
  ) async {
    final results = <KnowledgeItem?>[];
    for (final id in ids) {
      results.add(await loadKnowledgeItem(category, id));
    }
    return results;
  }

  /// Load drills.
  Future<List<Drill>> loadDrills() async {
    final data = await loadAsset('assets/knowledge/drills.json');
    return _parseDrills(data);
  }

  /// Parse index JSON.
  Map<String, List<String>> _parseIndex(Map<String, dynamic> data) {
    final result = <String, List<String>>{};
    
    for (final entry in data.entries) {
      if (entry.value is List) {
        result[entry.key] = (entry.value as List).cast<String>();
      }
    }
    
    return result;
  }

  /// Parse learning paths JSON.
  List<LearningPath> _parseLearningPaths(Map<String, dynamic> data) {
    final paths = data['paths'] as List? ?? data['learningPaths'] as List? ?? [];
    return paths
        .map((p) => LearningPath.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  /// Parse categories JSON.
  List<Category> _parseCategories(Map<String, dynamic> data) {
    final categories = data['categories'] as List? ?? [];
    return categories
        .map((c) => Category.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  /// Parse tags JSON.
  List<Tag> _parseTags(Map<String, dynamic> data) {
    final tags = data['tags'] as List? ?? [];
    return tags
        .map((t) => Tag.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  /// Parse drills JSON.
  List<Drill> _parseDrills(Map<String, dynamic> data) {
    final drills = data['drills'] as List? ?? data['items'] as List? ?? [];
    return drills
        .map((d) => Drill.fromJson(d as Map<String, dynamic>))
        .toList();
  }
}

/// Flutter asset bundle loader.
class FlutterKnowledgeAssetLoader extends KnowledgeAssetLoader {
  final AssetBundle _bundle;

  FlutterKnowledgeAssetLoader(this._bundle);

  @override
  Future<Map<String, dynamic>> loadAsset(String path) async {
    final string = await _bundle.loadString(path);
    return jsonDecode(string) as Map<String, dynamic>;
  }
}

/// Web-compatible loader using fetch.
class WebKnowledgeAssetLoader extends KnowledgeAssetLoader {
  final Future<ByteData> Function(String) _loader;

  WebKnowledgeAssetLoader(this._loader);

  @override
  Future<Map<String, dynamic>> loadAsset(String path) async {
    final data = await _loader(path);
    final string = utf8.decode(data.buffer.asUint8List());
    return jsonDecode(string) as Map<String, dynamic>;
  }
}

/// Alias for FlutterKnowledgeAssetLoader.
typedef DefaultKnowledgeAssetLoader = FlutterKnowledgeAssetLoader;
