import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/knowledge/data/knowledge_repository.dart';
import 'package:pool_os/features/knowledge/domain/models/knowledge_item.dart';
import 'package:pool_os/features/knowledge/domain/services/knowledge_service.dart';

/// Category information model
class CategoryInfo {
  final String name;
  final String nameVi;
  final int itemCount;
  final int techniqueCount;
  final int mistakeCount;
  final int strategyCount;
  final List<KnowledgeDifficulty> difficulties;

  const CategoryInfo({
    required this.name,
    required this.nameVi,
    required this.itemCount,
    required this.techniqueCount,
    required this.mistakeCount,
    required this.strategyCount,
    required this.difficulties,
  });
}

/// Category browser service for navigation.
/// Completely independent - Pool OS calls only this service.
final categoryBrowserServiceProvider = Provider<CategoryBrowserService>((ref) {
  return CategoryBrowserService(ref.watch(knowledgeServiceProvider));
});

class CategoryBrowserService {
  final KnowledgeService _knowledgeService;

  CategoryBrowserService(this._knowledgeService);

  /// Get all categories with metadata
  Future<List<CategoryInfo>> getAllCategories() async {
    final grouped = await _knowledgeService.groupedByCategory();
    return grouped.entries.map((entry) {
      return _buildCategoryInfo(entry.key, entry.value);
    }).toList()
      ..sort((a, b) => b.itemCount.compareTo(a.itemCount));
  }

  /// Get info for a specific category
  Future<CategoryInfo> getCategoryInfo(String category) async {
    final items = await _knowledgeService.byCategory(category);
    return _buildCategoryInfo(category, items);
  }

  /// Get all items in a category
  Future<List<KnowledgeItem>> getItemsInCategory(String category) async {
    return _knowledgeService.byCategory(category);
  }

  /// Get categories filtered by type
  Future<List<CategoryInfo>> getCategoriesByType(KnowledgeType type) async {
    final grouped = await _knowledgeService.groupedByType();
    final items = grouped[type] ?? [];
    
    final byCategory = <String, List<KnowledgeItem>>{};
    for (final item in items) {
      byCategory.putIfAbsent(item.category, () => []).add(item);
    }
    
    return byCategory.entries.map((entry) {
      return _buildCategoryInfo(entry.key, entry.value);
    }).toList();
  }

  /// Get categories filtered by difficulty
  Future<List<CategoryInfo>> getCategoriesByDifficulty(KnowledgeDifficulty difficulty) async {
    final all = await _knowledgeService.getAll();
    final filtered = all.where((item) => item.difficulty == difficulty).toList();
    
    final byCategory = <String, List<KnowledgeItem>>{};
    for (final item in filtered) {
      byCategory.putIfAbsent(item.category, () => []).add(item);
    }
    
    return byCategory.entries.map((entry) {
      return _buildCategoryInfo(entry.key, entry.value);
    }).toList();
  }

  /// Get category names in Vietnamese
  Map<String, String> get categoryNamesVi => {
    'stroke': 'Nhát đánh',
    'aim': 'Ngắm',
    'bridge': 'Tay chống',
    'stance': 'Tư thế',
    'grip': 'Cầm gậy',
    'cue_ball': 'Kiểm soát bi trắng',
    'spin': 'Xoáy',
    'bank': 'Đánh băng',
    'kick': 'Kick',
    'jump': 'Nhảy',
    'safety': 'An toàn',
    'pattern': 'Quỹ đạo',
    'strategy': 'Chiến lược',
    'mental': 'Tâm lý',
    'equipment': 'Dụng cụ',
    'mistakes': 'Sai lầm',
    'techniques': 'Kỹ thuật',
    'match_strategy': 'Chiến lược thi đấu',
    'gap_analysis': 'Phân tích khoảng trống',
    'table_reading': 'Đọc bàn',
  };

  CategoryInfo _buildCategoryInfo(String category, List<KnowledgeItem> items) {
    int techniques = 0;
    int mistakes = 0;
    int strategies = 0;
    final difficulties = <KnowledgeDifficulty>{};

    for (final item in items) {
      difficulties.add(item.difficulty);
      switch (item.type) {
        case KnowledgeType.technique:
          techniques++;
          break;
        case KnowledgeType.commonMistake:
          mistakes++;
          break;
        case KnowledgeType.strategy:
          strategies++;
          break;
        case KnowledgeType.equipment:
        case KnowledgeType.mental:
          // Other types
          break;
      }
    }

    return CategoryInfo(
      name: category,
      nameVi: categoryNamesVi[category] ?? category,
      itemCount: items.length,
      techniqueCount: techniques,
      mistakeCount: mistakes,
      strategyCount: strategies,
      difficulties: difficulties.toList(),
    );
  }
}
