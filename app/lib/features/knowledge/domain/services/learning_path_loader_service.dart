import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/knowledge/data/knowledge_repository.dart';
import 'package:pool_os/features/knowledge/domain/models/knowledge_item.dart';

/// Learning path model
class LearningPath {
  final String id;
  final String name;
  final String nameVi;
  final String targetLevel;
  final String description;
  final int totalHours;
  final List<LearningPhase> phases;

  const LearningPath({
    required this.id,
    required this.name,
    required this.nameVi,
    required this.targetLevel,
    required this.description,
    required this.totalHours,
    required this.phases,
  });

  factory LearningPath.fromJson(Map<String, dynamic> json) {
    return LearningPath(
      id: json['id'] as String,
      name: json['name'] as String,
      nameVi: json['nameVi'] as String? ?? json['name'] as String,
      targetLevel: json['targetLevel'] as String,
      description: json['description'] as String? ?? '',
      totalHours: (json['totalEstimatedHours'] as num?)?.toInt() ?? 0,
      phases: (json['phases'] as List?)
          ?.map((p) => LearningPhase.fromJson(p as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

/// Learning phase within a path
class LearningPhase {
  final int phase;
  final String title;
  final String titleVi;
  final String duration;
  final List<String> prerequisites;
  final List<LearningItemOrder> knowledgeOrder;
  final List<String> drillCodes;
  final List<String> milestones;
  final List<String> completionCriteria;

  const LearningPhase({
    required this.phase,
    required this.title,
    required this.titleVi,
    required this.duration,
    required this.prerequisites,
    required this.knowledgeOrder,
    required this.drillCodes,
    required this.milestones,
    required this.completionCriteria,
  });

  factory LearningPhase.fromJson(Map<String, dynamic> json) {
    return LearningPhase(
      phase: json['phase'] as int,
      title: json['title'] as String,
      titleVi: json['titleVi'] as String? ?? json['title'] as String,
      duration: json['duration'] as String? ?? '',
      prerequisites: (json['prerequisites'] as List?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      knowledgeOrder: (json['knowledgeOrder'] as List?)
          ?.map((k) => LearningItemOrder.fromJson(k as Map<String, dynamic>))
          .toList() ?? [],
      drillCodes: (json['drills'] as List?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      milestones: (json['milestones'] as List?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      completionCriteria: (json['completionCriteria'] as List?)
          ?.map((e) => e.toString())
          .toList() ?? [],
    );
  }
}

/// Knowledge item order within a phase
class LearningItemOrder {
  final int order;
  final String skillId;
  final String title;
  final String focus;

  const LearningItemOrder({
    required this.order,
    required this.skillId,
    required this.title,
    required this.focus,
  });

  factory LearningItemOrder.fromJson(Map<String, dynamic> json) {
    return LearningItemOrder(
      order: json['order'] as int,
      skillId: json['skillId'] as String,
      title: json['title'] as String,
      focus: json['focus'] as String? ?? '',
    );
  }
}

/// Learning path loader service.
/// Completely independent - Pool OS calls only this service.
final learningPathLoaderProvider = Provider<LearningPathLoaderService>((ref) {
  return LearningPathLoaderService(ref.watch(knowledgeRepositoryProvider));
});

class LearningPathLoaderService {
  final KnowledgeRepository _repository;
  static const String _learningPathsPath = 'assets/knowledge/learning_paths.json';
  
  Map<String, LearningPath>? _pathsCache;
  List<LearningPath>? _allPathsCache;

  LearningPathLoaderService(this._repository);

  /// Get a learning path by ID
  Future<LearningPath?> getPath(String pathId) async {
    await _loadPathsIfNeeded();
    return _pathsCache?[pathId];
  }

  /// Get all learning paths
  Future<List<LearningPath>> getAllPaths() async {
    await _loadPathsIfNeeded();
    return _allPathsCache ?? [];
  }

  /// Get paths for a player level
  Future<List<LearningPath>> getPathsForLevel(String playerLevel) async {
    await _loadPathsIfNeeded();
    return _allPathsCache?.where((path) {
      return path.targetLevel == playerLevel;
    }).toList() ?? [];
  }

  /// Get ordered knowledge items for a path
  Future<List<LearningItemOrder>> getOrderedItems(String pathId) async {
    final path = await getPath(pathId);
    if (path == null) return [];
    
    final ordered = <LearningItemOrder>[];
    for (final phase in path.phases) {
      ordered.addAll(phase.knowledgeOrder);
    }
    return ordered;
  }

  /// Get knowledge items for a path
  Future<List<KnowledgeItem>> getKnowledgeItems(String pathId) async {
    final ordered = await getOrderedItems(pathId);
    final ids = ordered.map((o) => o.skillId).toSet().toList();
    return _repository.byIds(ids);
  }

  /// Calculate progress for a path
  Future<double> getProgress(String pathId, Set<String> completedItemIds) async {
    final ordered = await getOrderedItems(pathId);
    if (ordered.isEmpty) return 0.0;
    
    final completedCount = ordered
        .where((item) => completedItemIds.contains(item.skillId))
        .length;
    
    return completedCount / ordered.length;
  }

  /// Get recommended paths for a player profile
  Future<List<LearningPath>> getRecommendedPaths({
    required String currentLevel,
    required Set<String> completedItems,
    required Set<String> weaknessAreas,
  }) async {
    await _loadPathsIfNeeded();
    if (_allPathsCache == null) return [];
    
    final recommended = <LearningPath, double>{};
    
    for (final path in _allPathsCache!) {
      // Calculate relevance score
      double score = 0;
      
      // Prefer paths at current or next level
      if (path.targetLevel == currentLevel) {
        score += 10;
      }
      
      // Prefer paths that address weaknesses
      final pathItems = await getKnowledgeItems(path.id);
      for (final item in pathItems) {
        if (weaknessAreas.contains(item.category)) {
          score += 5;
        }
      }
      
      // Prefer paths with high completion likelihood
      final progress = await getProgress(path.id, completedItems);
      if (progress > 0 && progress < 1) {
        score += 3; // In-progress paths
      } else if (progress == 0) {
        score += 1; // New paths
      }
      
      recommended[path] = score;
    }
    
    // Sort by score and return top 3
    final sorted = recommended.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(3).map((e) => e.key).toList();
  }

  /// Get player levels from metadata
  Future<Map<String, PlayerLevelInfo>> getPlayerLevels() async {
    try {
      final raw = await rootBundle.loadString(_learningPathsPath);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final levelsJson = json['playerLevels'] as Map<String, dynamic>?;
      
      if (levelsJson == null) return {};
      
      return levelsJson.map((key, value) {
        final v = value as Map<String, dynamic>;
        return MapEntry(key, PlayerLevelInfo(
          name: v['name'] as String,
          description: v['description'] as String? ?? '',
          prerequisites: (v['prerequisites'] as List?)
              ?.map((e) => e.toString())
              .toList() ?? [],
          hoursToNext: (v['estimatedHoursToNext'] as num?)?.toInt() ?? 0,
        ));
      });
    } catch (e) {
      return {};
    }
  }

  Future<void> _loadPathsIfNeeded() async {
    if (_pathsCache != null) return;
    
    try {
      final raw = await rootBundle.loadString(_learningPathsPath);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final pathsJson = json['learningPaths'] as Map<String, dynamic>?;
      
      if (pathsJson == null) {
        _pathsCache = {};
        _allPathsCache = [];
        return;
      }
      
      _pathsCache = {};
      _allPathsCache = [];
      
      for (final entry in pathsJson.entries) {
        final path = LearningPath.fromJson(entry.value as Map<String, dynamic>);
        _pathsCache![entry.key] = path;
        _allPathsCache!.add(path);
      }
    } catch (e) {
      _pathsCache = {};
      _allPathsCache = [];
    }
  }
}

/// Player level information
class PlayerLevelInfo {
  final String name;
  final String description;
  final List<String> prerequisites;
  final int hoursToNext;

  const PlayerLevelInfo({
    required this.name,
    required this.description,
    required this.prerequisites,
    required this.hoursToNext,
  });
}
