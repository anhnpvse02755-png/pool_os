import 'knowledge_enums.dart';
import 'knowledge_ref.dart';

/// Represents a learning path containing ordered phases and knowledge items
class LearningPath {
  /// Unique identifier (e.g., "complete_beginner")
  final String id;

  /// Path name in English
  final String name;

  /// Path name in Vietnamese
  final String nameVi;

  /// Brief description
  final String description;

  /// Target player level
  final String targetLevel;

  /// Target difficulty
  final KnowledgeDifficulty difficulty;

  /// Total estimated hours
  final int totalHours;

  /// Ordered phases in this path
  final List<LearningPhase> phases;

  /// Learning path tags
  final List<String> tags;

  /// Version string
  final String version;

  const LearningPath({
    required this.id,
    required this.name,
    required this.nameVi,
    required this.description,
    required this.targetLevel,
    required this.difficulty,
    required this.totalHours,
    required this.phases,
    this.tags = const [],
    this.version = '1.0.0',
  });

  factory LearningPath.fromJson(Map<String, dynamic> json) {
    return LearningPath(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameVi: json['nameVi'] as String? ?? '',
      description: json['description'] as String? ?? '',
      targetLevel: json['targetLevel'] as String? ?? 'H',
      difficulty: KnowledgeDifficulty.fromString(
        json['difficulty'] as String? ?? 'beginner',
      ),
      totalHours: json['totalHours'] as int? ?? 0,
      phases: (json['phases'] as List?)
          ?.map((e) => LearningPhase.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      version: json['version'] as String? ?? '1.0.0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameVi': nameVi,
      'description': description,
      'targetLevel': targetLevel,
      'difficulty': difficulty.name,
      'totalHours': totalHours,
      'phases': phases.map((e) => e.toJson()).toList(),
      'tags': tags,
      'version': version,
    };
  }

  /// Get localized name
  String getName(String language) {
    if (language == 'vi' && nameVi.isNotEmpty) {
      return nameVi;
    }
    return name;
  }

  /// Get total number of knowledge items in this path
  int get totalItems {
    return phases.fold(0, (sum, phase) => sum + phase.items.length);
  }

  /// Get phase count
  int get phaseCount => phases.length;

  /// Check if a specific item is in this path
  bool containsItem(String itemId) {
    for (final phase in phases) {
      for (final item in phase.items) {
        if (item.skillId == itemId) {
          return true;
        }
      }
    }
    return false;
  }

  /// Find which phase contains an item
  LearningPhase? findPhaseForItem(String itemId) {
    for (final phase in phases) {
      for (final item in phase.items) {
        if (item.skillId == itemId) {
          return phase;
        }
      }
    }
    return null;
  }

  /// Get index of an item in the path (0-based)
  int? itemIndex(String itemId) {
    int index = 0;
    for (final phase in phases) {
      for (final item in phase.items) {
        if (item.skillId == itemId) {
          return index;
        }
        index++;
      }
    }
    return null;
  }

  /// Get all item IDs in order
  List<String> get itemIds {
    final ids = <String>[];
    for (final phase in phases) {
      for (final item in phase.items) {
        ids.add(item.skillId);
      }
    }
    return ids;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningPath && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// A phase within a learning path
class LearningPhase {
  /// Phase order (1-based)
  final int order;

  /// Phase name
  final String name;

  /// Phase name in Vietnamese
  final String nameVi;

  /// Phase description
  final String description;

  /// Knowledge items in this phase
  final List<LearningItemOrder> items;

  const LearningPhase({
    required this.order,
    required this.name,
    required this.nameVi,
    required this.description,
    required this.items,
  });

  factory LearningPhase.fromJson(Map<String, dynamic> json) {
    return LearningPhase(
      order: json['order'] as int? ?? 1,
      name: json['name'] as String? ?? '',
      nameVi: json['nameVi'] as String? ?? '',
      description: json['description'] as String? ?? '',
      items: (json['items'] as List?)
          ?.map((e) => LearningItemOrder.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': order,
      'name': name,
      'nameVi': nameVi,
      'description': description,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  /// Get localized name
  String getName(String language) {
    if (language == 'vi' && nameVi.isNotEmpty) {
      return nameVi;
    }
    return name;
  }
}

/// An ordered item within a learning phase
class LearningItemOrder {
  /// Order within the phase (1-based)
  final int order;

  /// Knowledge item ID
  final String skillId;

  /// Optional title (can be looked up)
  final String? title;

  /// Whether this item is a checkpoint
  final bool isCheckpoint;

  const LearningItemOrder({
    required this.order,
    required this.skillId,
    this.title,
    this.isCheckpoint = false,
  });

  factory LearningItemOrder.fromJson(Map<String, dynamic> json) {
    return LearningItemOrder(
      order: json['order'] as int? ?? 1,
      skillId: json['skillId'] as String? ?? json['id'] as String? ?? '',
      title: json['title'] as String?,
      isCheckpoint: json['isCheckpoint'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': order,
      'skillId': skillId,
      'title': title,
      'isCheckpoint': isCheckpoint,
    };
  }
}

/// Summary of a learning path (for lists)
class LearningPathSummary {
  final String id;
  final String name;
  final String nameVi;
  final String description;
  final String targetLevel;
  final KnowledgeDifficulty difficulty;
  final int totalHours;
  final int phaseCount;
  final int itemCount;

  const LearningPathSummary({
    required this.id,
    required this.name,
    required this.nameVi,
    required this.description,
    required this.targetLevel,
    required this.difficulty,
    required this.totalHours,
    required this.phaseCount,
    required this.itemCount,
  });

  factory LearningPathSummary.fromPath(LearningPath path) {
    return LearningPathSummary(
      id: path.id,
      name: path.name,
      nameVi: path.nameVi,
      description: path.description,
      targetLevel: path.targetLevel,
      difficulty: path.difficulty,
      totalHours: path.totalHours,
      phaseCount: path.phaseCount,
      itemCount: path.totalItems,
    );
  }

  factory LearningPathSummary.fromJson(Map<String, dynamic> json) {
    return LearningPathSummary(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameVi: json['nameVi'] as String? ?? '',
      description: json['description'] as String? ?? '',
      targetLevel: json['targetLevel'] as String? ?? 'H',
      difficulty: KnowledgeDifficulty.fromString(
        json['difficulty'] as String? ?? 'beginner',
      ),
      totalHours: json['totalHours'] as int? ?? 0,
      phaseCount: json['phaseCount'] as int? ?? 0,
      itemCount: json['itemCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameVi': nameVi,
      'description': description,
      'targetLevel': targetLevel,
      'difficulty': difficulty.name,
      'totalHours': totalHours,
      'phaseCount': phaseCount,
      'itemCount': itemCount,
    };
  }

  String getName(String language) {
    if (language == 'vi' && nameVi.isNotEmpty) {
      return nameVi;
    }
    return name;
  }
}
