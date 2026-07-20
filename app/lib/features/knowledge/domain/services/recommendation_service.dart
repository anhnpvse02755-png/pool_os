import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/knowledge/data/knowledge_repository.dart';
import 'package:pool_os/features/knowledge/domain/models/knowledge_item.dart';
import 'package:pool_os/features/knowledge/domain/services/drill_mapping_loader_service.dart';
import 'package:pool_os/features/knowledge/domain/services/learning_path_loader_service.dart';
import 'package:pool_os/features/drill/domain/models/drill.dart';

/// RFC-REC-001 — Recommendation Service
/// 
/// Rule-based recommendation engine with no AI.
/// Provides contextual recommendations based on:
/// - Current knowledge item
/// - Player profile (level, strengths, weaknesses)
/// - Training goals
/// 
/// Algorithm:
/// 1. Collect candidate items (graph-based)
/// 2. Calculate base priority scores
/// 3. Apply context multipliers
/// 4. Check prerequisite status
/// 5. Rank and return results

// ===== PROVIDERS =====

final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  return RecommendationService(
    ref.watch(knowledgeRepositoryProvider),
    ref.watch(drillMappingLoaderProvider),
    ref.watch(learningPathLoaderProvider),
  );
});

// ===== INPUT MODELS =====

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
}

/// Training goal enum
enum TrainingGoal {
  improveAccuracy,
  improvePosition,
  improveBreak,
  improveSafety,
  learnNewShot,
  fixCommonMistakes,
  prepareForTournament,
  warmUp,
  coolDown,
  assessWeaknesses,
  advanceToNextLevel,
  maintainSkill,
  masterFundamentals,
}

/// Goal context for recommendations
class GoalContext {
  final TrainingGoal primaryGoal;
  final List<TrainingGoal> secondaryGoals;
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

// ===== OUTPUT MODELS =====

enum RecommendationType {
  relatedKnowledge,
  recommendedDrill,
  nextSkill,
  learningPath,
}

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
}

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
}

enum PrerequisiteStatus {
  satisfied,
  partial,
  missing,
}

// ===== SERVICE IMPLEMENTATION =====

class RecommendationService {
  final KnowledgeRepository _repository;
  final DrillMappingLoaderService _drillLoader;
  final LearningPathLoaderService _pathLoader;

  RecommendationService(
    this._repository,
    this._drillLoader,
    this._pathLoader,
  );

  /// Get complete recommendation set
  Future<RecommendationSet> getRecommendations({
    required PlayerProfile profile,
    required GoalContext goal,
    KnowledgeItem? currentItem,
  }) async {
    final context = CurrentContext(
      currentItem: currentItem,
      currentType: currentItem?.type,
      currentDifficulty: currentItem?.difficulty,
      currentCategory: currentItem?.category,
    );

    final candidates = _collectCandidates(context, profile, goal);
    final scored = await _scoreCandidates(candidates, context, profile, goal);
    final ranked = _rankRecommendations(scored);

    return _groupByType(ranked);
  }

  /// Get related knowledge
  Future<List<Recommendation>> getRelatedKnowledge({
    required KnowledgeItem current,
    required PlayerProfile profile,
  }) async {
    final context = CurrentContext(currentItem: current);
    final candidates = await _getRelatedKnowledgeCandidates(current);
    final scored = await _scoreCandidates(candidates, context, profile, GoalContext(primaryGoal: TrainingGoal.improveAccuracy));
    final ranked = _rankRecommendations(scored);
    return ranked.where((r) => r.type == RecommendationType.relatedKnowledge).toList();
  }

  /// Get recommended drills
  Future<List<Recommendation>> getRecommendedDrills({
    KnowledgeItem? current,
    required PlayerProfile profile,
    required GoalContext goal,
  }) async {
    final context = current != null 
        ? CurrentContext(currentItem: current)
        : const CurrentContext();
    final candidates = _getDrillCandidates(current, profile, goal);
    final scored = await _scoreCandidates(candidates, context, profile, goal);
    final ranked = _rankRecommendations(scored);
    return ranked.where((r) => r.type == RecommendationType.recommendedDrill).toList();
  }

  /// Get next skills
  Future<List<Recommendation>> getNextSkills({
    required KnowledgeItem current,
    required PlayerProfile profile,
  }) async {
    final context = CurrentContext(currentItem: current);
    final candidates = await _getNextSkillCandidates(current, profile);
    final scored = await _scoreCandidates(candidates, context, profile, GoalContext(primaryGoal: TrainingGoal.learnNewShot));
    final ranked = _rankRecommendations(scored);
    return ranked.where((r) => r.type == RecommendationType.nextSkill).toList();
  }

  /// Get learning paths
  Future<List<Recommendation>> getLearningPaths({
    required PlayerProfile profile,
    required GoalContext goal,
  }) async {
    final candidates = await _getLearningPathCandidates(profile, goal);
    final scored = await _scoreCandidates(candidates, const CurrentContext(), profile, goal);
    final ranked = _rankRecommendations(scored);
    return ranked.where((r) => r.type == RecommendationType.learningPath).toList();
  }

  /// Get top recommendation of a type
  Future<Recommendation?> getTopRecommendation({
    required PlayerProfile profile,
    required GoalContext goal,
    required RecommendationType type,
    KnowledgeItem? currentItem,
  }) async {
    final set = await getRecommendations(
      profile: profile,
      goal: goal,
      currentItem: currentItem,
    );

    switch (type) {
      case RecommendationType.relatedKnowledge:
        return set.relatedKnowledge.firstOrNull;
      case RecommendationType.recommendedDrill:
        return set.recommendedDrills.firstOrNull;
      case RecommendationType.nextSkill:
        return set.nextSkills.firstOrNull;
      case RecommendationType.learningPath:
        return set.learningPaths.firstOrNull;
    }
  }

  // ===== CANDIDATE COLLECTION =====

  List<dynamic> _collectCandidates(
    CurrentContext context,
    PlayerProfile profile,
    GoalContext goal,
  ) {
    final candidates = <dynamic>[];

    // From current item context
    if (context.currentItem != null) {
      candidates.addAll(_getRelatedKnowledgeCandidatesSync(context.currentItem!));
      candidates.addAll(_getDrillCandidates(context.currentItem, profile, goal));
      if (context.currentItem!.nextRecommended != null) {
        candidates.add(context.currentItem!.nextRecommended!);
      }
    }

    // From weakness areas
    for (final weakness in profile.weaknessAreas) {
      candidates.addAll(_getItemsByCategory(weakness));
      candidates.addAll(_getDrillsByCategory(weakness));
    }

    // From goal alignment
    candidates.addAll(_getItemsForGoal(goal.primaryGoal));

    return candidates.toSet().toList();
  }

  Future<List<dynamic>> _getRelatedKnowledgeCandidates(KnowledgeItem item) async {
    final related = await _repository.related(item);
    return related;
  }

  List<dynamic> _getRelatedKnowledgeCandidatesSync(KnowledgeItem item) {
    final candidates = <dynamic>[];
    
    // Prerequisites
    for (final prereqId in item.prerequisites) {
      // Will be resolved later
      candidates.add(prereqId);
    }
    
    // Related items
    for (final ref in item.relatedKnowledge) {
      candidates.add(ref.id);
    }
    
    return candidates;
  }

  List<dynamic> _getDrillCandidates(
    KnowledgeItem? item,
    PlayerProfile profile,
    GoalContext goal,
  ) {
    if (item != null) {
      return _drillLoader.getDrillsForKnowledge(item);
    }
    
    // Goal-based drill selection
    return _getDrillsForGoal(goal.primaryGoal);
  }

  Future<List<dynamic>> _getNextSkillCandidates(
    KnowledgeItem current,
    PlayerProfile profile,
  ) async {
    final candidates = <dynamic>[];
    
    // Next recommended from item
    if (current.nextRecommended != null) {
      final next = await _repository.byId(current.nextRecommended!.id);
      if (next != null) candidates.add(next);
    }
    
    // Same category items
    final sameCategory = await _repository.byCategory(current.category);
    for (final item in sameCategory) {
      if (item.id != current.id && !profile.completedItems.contains(item.id)) {
        candidates.add(item);
      }
    }
    
    return candidates;
  }

  Future<List<dynamic>> _getLearningPathCandidates(
    PlayerProfile profile,
    GoalContext goal,
  ) async {
    final paths = await _pathLoader.getPathsForLevel(profile.currentLevel);
    
    // Filter by goal if applicable
    return paths.where((path) {
      return true; // TODO: Add goal filtering logic
    }).toList();
  }

  List<dynamic> _getItemsByCategory(String category) {
    // This would query repository - simplified for now
    return [];
  }

  List<dynamic> _getDrillsByCategory(String category) {
    return _drillLoader.getDrillsBySkill(category);
  }

  List<dynamic> _getItemsForGoal(TrainingGoal goal) {
    // Map goals to relevant categories
    switch (goal) {
      case TrainingGoal.improveAccuracy:
        return _getItemsByCategory('aim');
      case TrainingGoal.improvePosition:
        return _getItemsByCategory('cue_ball');
      case TrainingGoal.improveBreak:
        return _getItemsByCategory('break');
      case TrainingGoal.improveSafety:
        return _getItemsByCategory('safety');
      case TrainingGoal.learnNewShot:
        return _getItemsByCategory('techniques');
      case TrainingGoal.fixCommonMistakes:
        return _getItemsByCategory('mistakes');
      default:
        return [];
    }
  }

  List<dynamic> _getDrillsForGoal(TrainingGoal goal) {
    switch (goal) {
      case TrainingGoal.improveAccuracy:
        return _drillLoader.getDrillsBySkill('aim');
      case TrainingGoal.improvePosition:
        return _drillLoader.getDrillsBySkill('cue_ball');
      case TrainingGoal.warmUp:
        return _drillLoader.getDrillsBySkill('fundamentals');
      default:
        return _drillLoader.getAllDrills();
    }
  }

  // ===== SCORING =====

  Future<List<Recommendation>> _scoreCandidates(
    List<dynamic> candidates,
    CurrentContext context,
    PlayerProfile profile,
    GoalContext goal,
  ) async {
    final scored = <Recommendation>[];

    for (final candidate in candidates) {
      double baseScore = _calculateBaseScore(candidate, context, profile, goal);
      double multipliedScore = _applyMultipliers(baseScore, candidate, context, profile);
      
      PrerequisiteStatus prereqStatus = PrerequisiteStatus.satisfied;
      if (candidate is KnowledgeItem) {
        prereqStatus = _checkPrerequisites(candidate, profile);
      }
      
      final finalScore = multipliedScore * _getPrereqModifier(prereqStatus);

      scored.add(_buildRecommendation(
        candidate,
        finalScore,
        context,
        profile,
        goal,
        prereqStatus,
      ));
    }

    return scored;
  }

  double _calculateBaseScore(
    dynamic candidate,
    CurrentContext context,
    PlayerProfile profile,
    GoalContext goal,
  ) {
    double score = 50;

    // Factor 1: Current item relevance (0-30)
    if (context.currentItem != null && candidate is KnowledgeItem) {
      score += _distanceToScore(context.currentItem!, candidate);
    }

    // Factor 2: Level match (0-25)
    final difficulty = _getDifficulty(candidate);
    score += _levelMatchScore(profile.currentLevel, difficulty);

    // Factor 3: Goal alignment (0-20)
    score += _goalAlignmentScore(candidate, goal);

    // Factor 4: Weakness address (0-15)
    if (_addressesWeakness(candidate, profile.weaknessAreas)) {
      score += 15;
    }

    // Factor 5: Freshness (0-10)
    if (candidate is KnowledgeItem) {
      if (!profile.completedItems.contains(candidate.id)) {
        score += 10;
      }
    } else if (candidate is Drill) {
      if (!profile.completedDrills.contains(candidate.code)) {
        score += 10;
      }
    }

    return score.clamp(0, 100);
  }

  double _distanceToScore(KnowledgeItem current, KnowledgeItem candidate) {
    // Direct relationship
    for (final ref in current.relatedKnowledge) {
      if (ref.id == candidate.id) return 25;
    }
    
    // Prerequisite
    if (current.prerequisites.contains(candidate.id)) return 20;
    if (candidate.prerequisites.contains(current.id)) return 18;
    
    // Next recommended
    if (current.nextRecommended?.id == candidate.id) return 22;
    
    // Same category
    if (current.category == candidate.category) return 12;
    
    // Same type
    if (current.type == candidate.type) return 8;
    
    return 0;
  }

  double _levelMatchScore(String playerLevel, KnowledgeDifficulty difficulty) {
    final expected = _levelToDifficulty(playerLevel);

    if (difficulty == expected) return 25;
    if (difficulty.index == expected.index - 1) return 18; // Easier
    if (difficulty.index == expected.index + 1) return 20; // Slightly harder
    return 5;
  }

  KnowledgeDifficulty _levelToDifficulty(String level) {
    switch (level) {
      case 'I':
      case 'H':
        return KnowledgeDifficulty.beginner;
      case 'G':
      case 'F':
        return KnowledgeDifficulty.intermediate;
      case 'E':
      case 'D':
        return KnowledgeDifficulty.advanced;
      default:
        return KnowledgeDifficulty.professional;
    }
  }

  double _goalAlignmentScore(dynamic candidate, GoalContext goal) {
    final candidateCategory = _getCategory(candidate);

    switch (goal.primaryGoal) {
      case TrainingGoal.improveAccuracy:
        if (candidateCategory == 'aim') return 20;
        break;
      case TrainingGoal.improvePosition:
        if (candidateCategory == 'cue_ball') return 20;
        break;
      case TrainingGoal.improveBreak:
        if (candidateCategory == 'break') return 20;
        break;
      case TrainingGoal.improveSafety:
        if (candidateCategory == 'safety') return 20;
        break;
      case TrainingGoal.learnNewShot:
        if (candidateCategory == 'techniques') return 18;
        break;
      case TrainingGoal.fixCommonMistakes:
        if (candidateCategory == 'mistakes') return 20;
        break;
      case TrainingGoal.warmUp:
        if (candidateCategory == 'fundamentals') return 18;
        break;
      case TrainingGoal.prepareForTournament:
        if (candidateCategory == 'strategy') return 15;
        if (candidateCategory == 'safety') return 15;
        break;
      default:
        break;
    }

    return 0;
  }

  bool _addressesWeakness(dynamic candidate, Set<String> weaknesses) {
    final category = _getCategory(candidate);
    return weaknesses.contains(category);
  }

  double _applyMultipliers(
    double baseScore,
    dynamic candidate,
    CurrentContext context,
    PlayerProfile profile,
  ) {
    double score = baseScore;

    // Vietnamese content
    if (candidate is KnowledgeItem && candidate.titleVi.isNotEmpty) {
      score *= 1.2;
    }

    // Has media
    if (candidate is KnowledgeItem && candidate.media.hasAny) {
      score *= 1.15;
    }

    // Time efficient
    final minutes = _getEstimatedMinutes(candidate);
    if (minutes <= 15) {
      score *= 1.1;
    }

    // Already completed (penalize)
    if (_isCompleted(candidate, profile)) {
      score *= 0.3;
    }

    return score;
  }

  PrerequisiteStatus _checkPrerequisites(KnowledgeItem item, PlayerProfile profile) {
    if (item.prerequisites.isEmpty) {
      return PrerequisiteStatus.satisfied;
    }

    int satisfiedCount = 0;
    for (final prereqId in item.prerequisites) {
      if (profile.completedItems.contains(prereqId)) {
        satisfiedCount++;
      }
    }

    final ratio = satisfiedCount / item.prerequisites.length;

    if (ratio >= 1.0) return PrerequisiteStatus.satisfied;
    if (ratio >= 0.5) return PrerequisiteStatus.partial;
    return PrerequisiteStatus.missing;
  }

  double _getPrereqModifier(PrerequisiteStatus status) {
    switch (status) {
      case PrerequisiteStatus.satisfied:
        return 1.0;
      case PrerequisiteStatus.partial:
        return 0.7;
      case PrerequisiteStatus.missing:
        return 0.3;
    }
  }

  // ===== BUILD RECOMMENDATION =====

  Recommendation _buildRecommendation(
    dynamic candidate,
    double score,
    CurrentContext context,
    PlayerProfile profile,
    GoalContext goal,
    PrerequisiteStatus prereqStatus,
  ) {
    return Recommendation(
      id: _getId(candidate),
      type: _getType(candidate),
      item: candidate,
      title: _getTitle(candidate),
      titleVi: _getTitleVi(candidate),
      priority: score,
      priorityRank: 0,
      reason: _generateReason(candidate, context, profile, goal),
      reasonFactors: _getReasonFactors(candidate, context, profile, goal),
      estimatedGain: _estimateGain(candidate, profile),
      estimatedMinutes: _getEstimatedMinutes(candidate),
      isRequired: prereqStatus == PrerequisiteStatus.missing,
    );
  }

  // ===== HELPERS =====

  String _getId(dynamic candidate) {
    if (candidate is KnowledgeItem) return candidate.id;
    if (candidate is Drill) return candidate.code;
    if (candidate is LearningPath) return candidate.id;
    if (candidate is KnowledgeRef) return candidate.id;
    if (candidate is String) return candidate;
    return '';
  }

  RecommendationType _getType(dynamic candidate) {
    if (candidate is KnowledgeItem) return RecommendationType.relatedKnowledge;
    if (candidate is Drill) return RecommendationType.recommendedDrill;
    if (candidate is LearningPath) return RecommendationType.learningPath;
    if (candidate is KnowledgeRef) return RecommendationType.relatedKnowledge;
    return RecommendationType.relatedKnowledge;
  }

  String _getTitle(dynamic candidate) {
    if (candidate is KnowledgeItem) return candidate.title;
    if (candidate is Drill) return candidate.name;
    if (candidate is LearningPath) return candidate.name;
    if (candidate is KnowledgeRef) return candidate.id;
    return '';
  }

  String _getTitleVi(dynamic candidate) {
    if (candidate is KnowledgeItem) return candidate.titleVi;
    if (candidate is Drill) return candidate.nameVi;
    if (candidate is LearningPath) return candidate.nameVi;
    return '';
  }

  KnowledgeDifficulty _getDifficulty(dynamic candidate) {
    if (candidate is KnowledgeItem) return candidate.difficulty;
    if (candidate is Drill) {
      return _drillDifficultyToKnowledge(candidate.difficulty);
    }
    return KnowledgeDifficulty.beginner;
  }

  KnowledgeDifficulty _drillDifficultyToKnowledge(DrillDifficulty difficulty) {
    switch (difficulty) {
      case DrillDifficulty.beginner:
        return KnowledgeDifficulty.beginner;
      case DrillDifficulty.intermediate:
        return KnowledgeDifficulty.intermediate;
      case DrillDifficulty.advanced:
        return KnowledgeDifficulty.advanced;
      case DrillDifficulty.expert:
        return KnowledgeDifficulty.professional;
    }
  }

  String _getCategory(dynamic candidate) {
    if (candidate is KnowledgeItem) return candidate.category;
    if (candidate is Drill) return candidate.category.name;
    return '';
  }

  int _getEstimatedMinutes(dynamic candidate) {
    if (candidate is KnowledgeItem) return candidate.estLearningMinutes;
    if (candidate is Drill) return candidate.timeLimitMinutes;
    if (candidate is LearningPath) return candidate.totalHours * 60;
    return 15;
  }

  bool _isCompleted(dynamic candidate, PlayerProfile profile) {
    if (candidate is KnowledgeItem) {
      return profile.completedItems.contains(candidate.id);
    }
    if (candidate is Drill) {
      return profile.completedDrills.contains(candidate.code);
    }
    return false;
  }

  double _estimateGain(dynamic candidate, PlayerProfile profile) {
    if (candidate is KnowledgeItem) {
      // Base gain from estimatedSkillGain
      final baseGain = candidate.estimatedSkillGain.values.isEmpty
          ? 10.0
          : candidate.estimatedSkillGain.values.reduce((a, b) => a + b) / 
            candidate.estimatedSkillGain.length;
      
      // Boost for weakness areas
      if (profile.weaknessAreas.contains(candidate.category)) {
        return baseGain * 1.3;
      }
      
      return baseGain;
    }
    return 10.0;
  }

  String _generateReason(
    dynamic candidate,
    CurrentContext context,
    PlayerProfile profile,
    GoalContext goal,
  ) {
    if (profile.weaknessAreas.contains(_getCategory(candidate))) {
      return 'Addresses your ${_getCategory(candidate)} skills';
    }
    
    if (_addressesWeakness(candidate, profile.weaknessAreas)) {
      return 'Helps fix identified weakness';
    }
    
    if (_isCompleted(candidate, profile)) {
      return 'Review for mastery';
    }
    
    return 'Recommended for your level';
  }

  List<String> _getReasonFactors(
    dynamic candidate,
    CurrentContext context,
    PlayerProfile profile,
    GoalContext goal,
  ) {
    final factors = <String>[];
    
    if (profile.weaknessAreas.contains(_getCategory(candidate))) {
      factors.add('Addresses weakness area');
    }
    
    if (_getDifficulty(candidate) == _levelToDifficulty(profile.currentLevel)) {
      factors.add('Matches your level');
    }
    
    if (_isCompleted(candidate, profile)) {
      factors.add('Already completed');
    } else {
      factors.add('New learning opportunity');
    }
    
    if (candidate is KnowledgeItem && candidate.titleVi.isNotEmpty) {
      factors.add('Vietnamese content available');
    }
    
    return factors;
  }

  // ===== RANKING & GROUPING =====

  List<Recommendation> _rankRecommendations(List<Recommendation> recommendations) {
    // Sort by priority descending
    recommendations.sort((a, b) => b.priority.compareTo(a.priority));
    
    // Assign ranks
    final ranked = <Recommendation>[];
    for (int i = 0; i < recommendations.length; i++) {
      ranked.add(recommendations[i].copyWith(priorityRank: i + 1));
    }
    
    return ranked;
  }

  RecommendationSet _groupByType(List<Recommendation> recommendations) {
    final relatedKnowledge = <Recommendation>[];
    final recommendedDrills = <Recommendation>[];
    final nextSkills = <Recommendation>[];
    final learningPaths = <Recommendation>[];

    for (final r in recommendations) {
      switch (r.type) {
        case RecommendationType.relatedKnowledge:
          relatedKnowledge.add(r);
          break;
        case RecommendationType.recommendedDrill:
          recommendedDrills.add(r);
          break;
        case RecommendationType.nextSkill:
          nextSkills.add(r);
          break;
        case RecommendationType.learningPath:
          learningPaths.add(r);
          break;
      }
    }

    return RecommendationSet(
      relatedKnowledge: relatedKnowledge,
      recommendedDrills: recommendedDrills,
      nextSkills: nextSkills,
      learningPaths: learningPaths,
    );
  }
}

// ===== PROVIDER HELPERS =====

final recommendationSetProvider = FutureProvider.family<RecommendationSet, RecommendationParams>(
  (ref, params) async {
    final service = ref.watch(recommendationServiceProvider);
    return service.getRecommendations(
      profile: params.profile,
      goal: params.goal,
      currentItem: params.currentItem,
    );
  },
);

class RecommendationParams {
  final PlayerProfile profile;
  final GoalContext goal;
  final KnowledgeItem? currentItem;

  const RecommendationParams({
    required this.profile,
    required this.goal,
    this.currentItem,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecommendationParams &&
          runtimeType == other.runtimeType &&
          profile.id == other.profile.id &&
          goal.primaryGoal == other.goal.primaryGoal &&
          currentItem?.id == other.currentItem?.id;

  @override
  int get hashCode =>
      profile.id.hashCode ^
      goal.primaryGoal.hashCode ^
      currentItem?.id.hashCode;
}
