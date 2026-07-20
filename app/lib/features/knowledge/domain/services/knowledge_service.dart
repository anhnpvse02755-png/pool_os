import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/knowledge/data/knowledge_repository.dart';
import 'package:pool_os/features/knowledge/domain/models/knowledge_item.dart';

/// RFC-KB-002 — Knowledge Service: High-level business logic facade.
/// Wraps KnowledgeRepository and provides domain-specific operations.
/// Completely independent - Pool OS calls only this service.
final knowledgeServiceProvider = Provider<KnowledgeService>((ref) {
  return KnowledgeService(ref.watch(knowledgeRepositoryProvider));
});

class KnowledgeService {
  final KnowledgeRepository _repository;

  KnowledgeService(this._repository);

  /// Get all knowledge items
  Future<List<KnowledgeItem>> getAll() => _repository.getAll();

  /// Get items by type
  Future<List<KnowledgeItem>> byType(KnowledgeType type) =>
      _repository.byType(type);

  /// Get items by category
  Future<List<KnowledgeItem>> byCategory(String category) =>
      _repository.byCategory(category);

  /// Get single item by ID
  Future<KnowledgeItem?> byId(String id) => _repository.byId(id);

  /// Get items grouped by category
  Future<Map<String, List<KnowledgeItem>>> groupedByCategory() async {
    final all = await getAll();
    final grouped = <String, List<KnowledgeItem>>{};
    for (final item in all) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    return grouped;
  }

  /// Get items grouped by difficulty
  Future<Map<KnowledgeDifficulty, List<KnowledgeItem>>> groupedByDifficulty() async {
    final all = await getAll();
    final grouped = <KnowledgeDifficulty, List<KnowledgeItem>>{};
    for (final item in all) {
      grouped.putIfAbsent(item.difficulty, () => []).add(item);
    }
    return grouped;
  }

  /// Get items grouped by type
  Future<Map<KnowledgeType, List<KnowledgeItem>>> groupedByType() async {
    final all = await getAll();
    final grouped = <KnowledgeType, List<KnowledgeItem>>{};
    for (final item in all) {
      grouped.putIfAbsent(item.type, () => []).add(item);
    }
    return grouped;
  }

  /// Get all fundamental items
  Future<List<KnowledgeItem>> getFundamentals() async {
    final all = await getAll();
    return all.where((item) => 
      item.id.contains('fundamentals') || 
      item.difficulty == KnowledgeDifficulty.beginner
    ).toList();
  }

  /// Get items by skill ID
  Future<List<KnowledgeItem>> bySkillId(String skillId) async {
    final all = await getAll();
    return all.where((item) => item.skillId == skillId).toList();
  }

  /// Get items by multiple IDs
  Future<List<KnowledgeItem>> byIds(List<String> ids) async {
    final all = await getAll();
    final idSet = ids.toSet();
    return all.where((item) => idSet.contains(item.id)).toList();
  }

  /// Get statistics about the knowledge base
  Future<KnowledgeStatistics> getStatistics() async {
    final all = await getAll();
    return KnowledgeStatistics.fromItems(all);
  }
}

/// Statistics about the knowledge base
class KnowledgeStatistics {
  final int totalItems;
  final int totalCategories;
  final int totalTechniques;
  final int totalMistakes;
  final int totalStrategies;
  final int totalEquipment;
  final int totalMental;
  final Map<KnowledgeDifficulty, int> byDifficulty;
  final Map<String, int> byCategory;

  const KnowledgeStatistics({
    required this.totalItems,
    required this.totalCategories,
    required this.totalTechniques,
    required this.totalMistakes,
    required this.totalStrategies,
    required this.totalEquipment,
    required this.totalMental,
    required this.byDifficulty,
    required this.byCategory,
  });

  factory KnowledgeStatistics.fromItems(List<KnowledgeItem> items) {
    final categories = <String>{};
    final byDiff = <KnowledgeDifficulty, int>{};
    final byCat = <String, int>{};
    
    int techniques = 0;
    int mistakes = 0;
    int strategies = 0;
    int equipment = 0;
    int mental = 0;

    for (final item in items) {
      categories.add(item.category);
      byCat[item.category] = (byCat[item.category] ?? 0) + 1;
      byDiff[item.difficulty] = (byDiff[item.difficulty] ?? 0) + 1;

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
          equipment++;
          break;
        case KnowledgeType.mental:
          mental++;
          break;
      }
    }

    return KnowledgeStatistics(
      totalItems: items.length,
      totalCategories: categories.length,
      totalTechniques: techniques,
      totalMistakes: mistakes,
      totalStrategies: strategies,
      totalEquipment: equipment,
      totalMental: mental,
      byDifficulty: byDiff,
      byCategory: byCat,
    );
  }
}
