import 'knowledge_enums.dart';
import 'knowledge_item.dart';
import 'drill.dart';
import 'learning_path.dart';

/// Player profile for recommendations
class PlayerProfile {
  final String id;
  final String currentLevel;
  final Set<String> strengthAreas;
  final Set<String> weaknessAreas;
  final Set<String> completedItems;
  final Set<String> completedDrills;
  final int practiceHoursPerWeek;
  final String preferredGameType;
  final Set<String> goals;

  const PlayerProfile({
    required this.id,
    required this.currentLevel,
    this.strengthAreas = const {},
    this.weaknessAreas = const {},
    this.completedItems = const {},
    this.completedDrills = const {},
    this.practiceHoursPerWeek = 0,
    this.preferredGameType = '8-ball',
    this.goals = const {},
  });

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      id: json['id'] as String? ?? '',
      currentLevel: json['currentLevel'] as String? ?? 'H',
      strengthAreas: (json['strengthAreas'] as List?)
          ?.map((e) => e.toString())
          .toSet() ?? {},
      weaknessAreas: (json['weaknessAreas'] as List?)
          ?.map((e) => e.toString())
          .toSet() ?? {},
      completedItems: (json['completedItems'] as List?)
          ?.map((e) => e.toString())
          .toSet() ?? {},
      completedDrills: (json['completedDrills'] as List?)
          ?.map((e) => e.toString())
          .toSet() ?? {},
      practiceHoursPerWeek: json['practiceHoursPerWeek'] as int? ?? 0,
      preferredGameType: json['preferredGameType'] as String? ?? '8-ball',
      goals: (json['goals'] as List?)
          ?.map((e) => e.toString())
          .toSet() ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'currentLevel': currentLevel,
      'strengthAreas': strengthAreas.toList(),
      'weaknessAreas': weaknessAreas.toList(),
      'completedItems': completedItems.toList(),
      'completedDrills': completedDrills.toList(),
      'practiceHoursPerWeek': practiceHoursPerWeek,
      'preferredGameType': preferredGameType,
      'goals': goals.toList(),
    };
  }

  PlayerProfile copyWith({
    String? id,
    String? currentLevel,
    Set<String>? strengthAreas,
    Set<String>? weaknessAreas,
    Set<String>? completedItems,
    Set<String>? completedDrills,
    int? practiceHoursPerWeek,
    String? preferredGameType,
    Set<String>? goals,
  }) {
    return PlayerProfile(
      id: id ?? this.id,
      currentLevel: currentLevel ?? this.currentLevel,
      strengthAreas: strengthAreas ?? this.strengthAreas,
      weaknessAreas: weaknessAreas ?? this.weaknessAreas,
      completedItems: completedItems ?? this.completedItems,
      completedDrills: completedDrills ?? this.completedDrills,
      practiceHoursPerWeek: practiceHoursPerWeek ?? this.practiceHoursPerWeek,
      preferredGameType: preferredGameType ?? this.preferredGameType,
      goals: goals ?? this.goals,
    );
  }
}

/// Goal context for recommendations
class GoalContext {
  final LearningGoal primaryGoal;
  final List<LearningGoal> secondaryGoals;
  final Duration? timeBudget;
  final bool isUrgent;

  const GoalContext({
    required this.primaryGoal,
    this.secondaryGoals = const [],
    this.timeBudget,
    this.isUrgent = false,
  });
}

/// Current viewing context
class CurrentContext {
  final KnowledgeItem? currentItem;
  final KnowledgeType? currentType;
  final KnowledgeDifficulty? currentDifficulty;
  final String? currentCategory;

  const CurrentContext({
    this.currentItem,
    this.currentType,
    this.currentDifficulty,
    this.currentCategory,
  });
}

/// Types of recommendations
enum RecommendationType {
  relatedKnowledge,
  recommendedDrill,
  nextSkill,
  learningPath,
}

/// A single recommendation
class Recommendation {
  final String id;
  final RecommendationType type;
  final dynamic item;
  final String title;
  final String titleVi;
  final double priority;
  final int priorityRank;
  final String reason;
  final List<String> reasonFactors;
  final double estimatedGain;
  final int estimatedMinutes;
  final bool isRequired;

  const Recommendation({
    required this.id,
    required this.type,
    required this.item,
    required this.title,
    required this.titleVi,
    required this.priority,
    required this.priorityRank,
    required this.reason,
    required this.reasonFactors,
    this.estimatedGain = 0.0,
    this.estimatedMinutes = 0,
    this.isRequired = false,
  });

  Recommendation copyWith({int? priorityRank}) {
    return Recommendation(
      id: id,
      type: type,
      item: item,
      title: title,
      titleVi: titleVi,
      priority: priority,
      priorityRank: priorityRank ?? this.priorityRank,
      reason: reason,
      reasonFactors: reasonFactors,
      estimatedGain: estimatedGain,
      estimatedMinutes: estimatedMinutes,
      isRequired: isRequired,
    );
  }

  /// Get the item as specific type
  KnowledgeItem? get asKnowledgeItem => item is KnowledgeItem ? item as KnowledgeItem : null;
  Drill? get asDrill => item is Drill ? item as Drill : null;
  LearningPath? get asLearningPath => item is LearningPath ? item as LearningPath : null;

  String getTitle(String language) {
    if (language == 'vi' && titleVi.isNotEmpty) {
      return titleVi;
    }
    return title;
  }
}

/// Complete recommendation set
class RecommendationSet {
  final List<Recommendation> relatedKnowledge;
  final List<Recommendation> recommendedDrills;
  final List<Recommendation> nextSkills;
  final List<Recommendation> learningPaths;

  const RecommendationSet({
    this.relatedKnowledge = const [],
    this.recommendedDrills = const [],
    this.nextSkills = const [],
    this.learningPaths = const [],
  });

  bool get isEmpty =>
      relatedKnowledge.isEmpty &&
      recommendedDrills.isEmpty &&
      nextSkills.isEmpty &&
      learningPaths.isEmpty;

  int get totalCount =>
      relatedKnowledge.length +
      recommendedDrills.length +
      nextSkills.length +
      learningPaths.length;

  Duration get totalEstimatedTime {
    int minutes = 0;
    for (final r in relatedKnowledge) minutes += r.estimatedMinutes;
    for (final r in recommendedDrills) minutes += r.estimatedMinutes;
    for (final r in nextSkills) minutes += r.estimatedMinutes;
    return Duration(minutes: minutes);
  }

  RecommendationSet copyWith({
    List<Recommendation>? relatedKnowledge,
    List<Recommendation>? recommendedDrills,
    List<Recommendation>? nextSkills,
    List<Recommendation>? learningPaths,
  }) {
    return RecommendationSet(
      relatedKnowledge: relatedKnowledge ?? this.relatedKnowledge,
      recommendedDrills: recommendedDrills ?? this.recommendedDrills,
      nextSkills: nextSkills ?? this.nextSkills,
      learningPaths: learningPaths ?? this.learningPaths,
    );
  }
}
