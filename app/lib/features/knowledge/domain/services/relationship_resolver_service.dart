import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/knowledge/data/knowledge_repository.dart';
import 'package:pool_os/features/knowledge/domain/models/knowledge_item.dart';

/// Relationship resolver service for graph traversal.
/// Completely independent - Pool OS calls only this service.
final relationshipResolverProvider = Provider<RelationshipResolverService>((ref) {
  return RelationshipResolverService(ref.watch(knowledgeRepositoryProvider));
});

class RelationshipResolverService {
  final KnowledgeRepository _repository;

  RelationshipResolverService(this._repository);

  /// Get all items related to a given item
  Future<List<KnowledgeItem>> getRelated(KnowledgeItem item) async {
    return _repository.related(item);
  }

  /// Get prerequisite items (what should be learned first)
  Future<List<KnowledgeItem>> getPrerequisites(KnowledgeItem item) async {
    if (item.prerequisites.isEmpty) return [];
    return _repository.byIds(item.prerequisites);
  }

  /// Get items that depend on this item
  Future<List<KnowledgeItem>> getDependents(KnowledgeItem item) async {
    final all = await _repository.getAll();
    return all.where((other) {
      return other.prerequisites.contains(item.id);
    }).toList();
  }

  /// Get a learning path between two items
  Future<List<KnowledgeItem>> getLearningPath(String startId, String endId) async {
    final all = await _repository.getAll();
    final itemMap = {for (var item in all) item.id: item};
    
    final start = itemMap[startId];
    final end = itemMap[endId];
    
    if (start == null || end == null) return [];

    // BFS to find shortest path
    final visited = <String>{};
    final queue = <List<KnowledgeItem>>[];
    
    queue.add([start]);
    visited.add(start.id);

    while (queue.isNotEmpty) {
      final path = queue.removeAt(0);
      final current = path.last;

      if (current.id == endId) {
        return path;
      }

      for (final prereqId in current.prerequisites) {
        if (!visited.contains(prereqId) && itemMap.containsKey(prereqId)) {
          visited.add(prereqId);
          queue.add([...path, itemMap[prereqId]!]);
        }
      }

      final dependents = all.where((item) => 
        item.prerequisites.contains(current.id)
      );
      for (final dependent in dependents) {
        if (!visited.contains(dependent.id)) {
          visited.add(dependent.id);
          queue.add([...path, dependent]);
        }
      }
    }

    return [];
  }

  /// Check for circular dependencies
  Future<bool> hasCircularDependency(String itemId) async {
    final all = await _repository.getAll();
    final itemMap = {for (var item in all) item.id: item};
    
    final visited = <String>{};
    final stack = <String>{};

    bool dfs(String id) {
      if (stack.contains(id)) return true;
      if (visited.contains(id)) return false;

      visited.add(id);
      stack.add(id);

      final item = itemMap[id];
      if (item != null) {
        for (final prereqId in item.prerequisites) {
          if (dfs(prereqId)) return true;
        }
      }

      stack.remove(id);
      return false;
    }

    return dfs(itemId);
  }

  /// Get dependency depth for all items
  Future<Map<String, int>> getDependencyDepth() async {
    final all = await _repository.getAll();
    final itemMap = {for (var item in all) item.id: item};
    final depthMap = <String, int>{};
    
    int getDepth(String id, Set<String> visiting) {
      if (depthMap.containsKey(id)) return depthMap[id]!;
      if (visiting.contains(id)) return 0;
      
      visiting.add(id);
      
      final item = itemMap[id];
      if (item == null || item.prerequisites.isEmpty) {
        depthMap[id] = 0;
        return 0;
      }
      
      int maxPrereqDepth = 0;
      for (final prereqId in item.prerequisites) {
        final prereqDepth = getDepth(prereqId, visiting);
        if (prereqDepth > maxPrereqDepth) {
          maxPrereqDepth = prereqDepth;
        }
      }
      
      depthMap[id] = maxPrereqDepth + 1;
      visiting.remove(id);
      return depthMap[id]!;
    }

    for (final item in all) {
      getDepth(item.id, <String>{});
    }

    return depthMap;
  }

  /// Get items with most relationships (hub items)
  Future<List<KnowledgeItem>> getHubItems({int limit = 10}) async {
    final all = await _repository.getAll();
    
    final connectionCounts = <String, int>{};
    for (final item in all) {
      connectionCounts[item.id] = item.prerequisites.length + 
          item.relatedKnowledge.length;
    }

    final sortedIds = connectionCounts.entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topIds = sortedIds.take(limit).map((e) => e.key).toSet();
    return all.where((item) => topIds.contains(item.id)).toList();
  }

  /// Get isolated items (no relationships)
  Future<List<KnowledgeItem>> getIsolatedItems() async {
    final all = await _repository.getAll();
    return all.where((item) {
      return item.prerequisites.isEmpty && 
          item.relatedKnowledge.isEmpty;
    }).toList();
  }

  /// Get graph statistics
  Future<GraphStatistics> getGraphStatistics() async {
    final all = await _repository.getAll();
    
    int totalPrereqs = 0;
    int totalRelations = 0;
    int isolatedCount = 0;
    int hubCount = 0;
    
    for (final item in all) {
      totalPrereqs += item.prerequisites.length;
      totalRelations += item.relatedKnowledge.length;
      
      if (item.prerequisites.isEmpty && item.relatedKnowledge.isEmpty) {
        isolatedCount++;
      }
      if (item.prerequisites.length + item.relatedKnowledge.length >= 5) {
        hubCount++;
      }
    }

    return GraphStatistics(
      totalItems: all.length,
      totalPrerequisites: totalPrereqs,
      totalRelationships: totalRelations,
      isolatedItems: isolatedCount,
      hubItems: hubCount,
      avgConnections: all.isEmpty ? 0 : 
          (totalPrereqs + totalRelations) / all.length,
    );
  }
}

/// Graph statistics model
class GraphStatistics {
  final int totalItems;
  final int totalPrerequisites;
  final int totalRelationships;
  final int isolatedItems;
  final int hubItems;
  final double avgConnections;

  const GraphStatistics({
    required this.totalItems,
    required this.totalPrerequisites,
    required this.totalRelationships,
    required this.isolatedItems,
    required this.hubItems,
    required this.avgConnections,
  });
}
