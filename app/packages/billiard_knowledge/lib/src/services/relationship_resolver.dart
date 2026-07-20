import '../models/models.dart';
import '../repositories/knowledge_repository.dart';

/// Service for resolving relationships between knowledge items.
///
/// Provides methods to traverse the knowledge graph, find prerequisites,
/// and resolve related items with full content.
///
/// ```dart
/// final resolver = BilliardKnowledge.instance.relationshipResolver;
///
/// // Get prerequisites chain
/// final prereqs = await resolver.getPrerequisites('draw.fundamentals');
///
/// // Get related items
/// final related = await resolver.getRelated('aim.center_ball');
///
/// // Get learning order
/// final order = await resolver.getLearningOrder('advanced.bank');
/// ```
class RelationshipResolver {
  final KnowledgeRepository _repository;

  // Cache for graph traversal
  final Map<String, List<KnowledgeItem>> _prereqCache = {};
  final Map<String, List<KnowledgeItem>> _relatedCache = {};

  RelationshipResolver({
    required KnowledgeRepository repository,
  }) : _repository = repository;

  /// Get all prerequisites for an item (recursive).
  /// 
  /// Returns items that must be learned before this one.
  /// 
  /// ```dart
  /// final prereqs = await resolver.getPrerequisites('draw.fundamentals');
  /// // Returns: [stance.fundamentals, aim.center_ball, ...]
  /// ```
  Future<List<KnowledgeItem>> getPrerequisites(String itemId) async {
    if (_prereqCache.containsKey(itemId)) {
      return _prereqCache[itemId]!;
    }

    final item = await _repository.byId(itemId);
    if (item == null) return [];

    final prereqs = <KnowledgeItem>[];
    final visited = <String>{itemId};

    for (final prereqId in item.prerequisites) {
      if (!visited.contains(prereqId)) {
        visited.add(prereqId);
        final prereq = await _repository.byId(prereqId);
        if (prereq != null) {
          prereqs.add(prereq);
          // Recursively get prerequisites
          final nestedPrereqs = await getPrerequisites(prereqId);
          for (final nested in nestedPrereqs) {
            if (!visited.contains(nested.id)) {
              visited.add(nested.id);
              prereqs.add(nested);
            }
          }
        }
      }
    }

    _prereqCache[itemId] = prereqs;
    return prereqs;
  }

  /// Get direct prerequisites only (non-recursive).
  /// 
  /// ```dart
  /// final direct = await resolver.getDirectPrerequisites('draw.fundamentals');
  /// ```
  Future<List<KnowledgeItem>> getDirectPrerequisites(String itemId) async {
    final item = await _repository.byId(itemId);
    if (item == null) return [];
    return _repository.byIds(item.prerequisites);
  }

  /// Get all related items for an item (recursive).
  /// 
  /// Returns items connected through the knowledge graph.
  /// 
  /// ```dart
  /// final related = await resolver.getRelated('aim.center_ball');
  /// ```
  Future<List<KnowledgeItem>> getRelated(String itemId) async {
    if (_relatedCache.containsKey(itemId)) {
      return _relatedCache[itemId]!;
    }

    final item = await _repository.byId(itemId);
    if (item == null) return [];

    final related = <KnowledgeItem>[];
    final visited = <String>{itemId};

    for (final ref in item.relatedKnowledge) {
      if (!visited.contains(ref.id)) {
        visited.add(ref.id);
        final relatedItem = await _repository.byId(ref.id);
        if (relatedItem != null) {
          related.add(relatedItem);
        }
      }
    }

    // Also check items that reference this one
    // This is more expensive, so limit depth
    final allItems = await _repository.getAll();
    for (final candidate in allItems) {
      if (visited.contains(candidate.id)) continue;
      
      final refs = candidate.relatedKnowledge.map((r) => r.id).toList();
      if (refs.contains(itemId)) {
        visited.add(candidate.id);
        related.add(candidate);
      }
    }

    _relatedCache[itemId] = related;
    return related;
  }

  /// Get related items by relation type.
  /// 
  /// ```dart
  /// final similar = await resolver.getRelatedByType(
  ///   'aim.center_ball',
  ///   RelationType.similarTo,
  /// );
  /// ```
  Future<List<KnowledgeItem>> getRelatedByType(
    String itemId,
    RelationType type,
  ) async {
    final item = await _repository.byId(itemId);
    if (item == null) return [];

    final result = <KnowledgeItem>[];
    for (final ref in item.relatedKnowledge) {
      if (ref.relationType == type) {
        final relatedItem = await _repository.byId(ref.id);
        if (relatedItem != null) {
          result.add(relatedItem);
        }
      }
    }

    return result;
  }

  /// Get the learning order for an item.
  /// 
  /// Returns items in the order they should be learned,
  /// including prerequisites and the item itself.
  /// 
  /// ```dart
  /// final order = await resolver.getLearningOrder('draw.fundamentals');
  /// // Returns prerequisites first, then the item
  /// ```
  Future<List<KnowledgeItem>> getLearningOrder(String itemId) async {
    final prereqs = await getPrerequisites(itemId);
    final item = await _repository.byId(itemId);
    
    if (item == null) return prereqs;
    
    return [...prereqs, item];
  }

  /// Check if prerequisites are satisfied.
  /// 
  /// ```dart
  /// final satisfied = await resolver.arePrerequisitesSatisfied(
  ///   'draw.fundamentals',
  ///   completedItems: {'stance.fundamentals', 'aim.center_ball'},
  /// );
  /// ```
  Future<bool> arePrerequisitesSatisfied(
    String itemId,
    required Set<String> completedItems,
  ) async {
    final prereqs = await getDirectPrerequisites(itemId);
    
    for (final prereq in prereqs) {
      if (!completedItems.contains(prereq.id)) {
        return false;
      }
    }
    
    return true;
  }

  /// Get missing prerequisites.
  /// 
  /// ```dart
  /// final missing = await resolver.getMissingPrerequisites(
  ///   'draw.fundamentals',
  ///   completedItems: {'stance.fundamentals'},
  /// );
  /// // Returns items that need to be completed first
  /// ```
  Future<List<KnowledgeItem>> getMissingPrerequisites(
    String itemId,
    required Set<String> completedItems,
  ) async {
    final prereqs = await getDirectPrerequisites(itemId);
    
    return prereqs
        .where((prereq) => !completedItems.contains(prereq.id))
        .toList();
  }

  /// Find items that depend on this item.
  /// 
  /// Useful for understanding what will be unlocked.
  /// 
  /// ```dart
  /// final dependents = await resolver.getDependents('aim.center_ball');
  /// // Returns items that require this as prerequisite
  /// ```
  Future<List<KnowledgeItem>> getDependents(String itemId) async {
    final allItems = await _repository.getAll();
    final dependents = <KnowledgeItem>[];

    for (final item in allItems) {
      if (item.prerequisites.contains(itemId)) {
        dependents.add(item);
      }
    }

    return dependents;
  }

  /// Get items in the same learning path phase.
  /// 
  /// ```dart
  /// final siblings = await resolver.getSiblings('stroke.fundamentals');
  /// ```
  Future<List<KnowledgeItem>> getSiblings(String itemId) async {
    // Find a learning path containing this item
    final path = await _repository.byId(itemId);
    if (path == null) return [];

    // For now, return items in same category
    final category = path.category.split('.').first;
    return _repository.byCategory(category);
  }

  /// Clear relationship cache.
  void clearCache() {
    _prereqCache.clear();
    _relatedCache.clear();
  }
}
