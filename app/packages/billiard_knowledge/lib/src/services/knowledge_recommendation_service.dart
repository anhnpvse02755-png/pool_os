import '../models/models.dart';
import '../repositories/knowledge_repository.dart';
import '../loaders/drill_mapping_loader.dart';
import '../loaders/learning_path_loader.dart';

/// Service for generating knowledge and drill recommendations.
///
/// Uses rule-based algorithm (no AI) to provide contextual recommendations
/// based on current item, player level, and training goals.
///
/// ```dart
/// final rec = BilliardKnowledge.instance.recommendationService;
///
/// // Get full recommendations
/// final set = await rec.getRecommendations(
///   profile: playerProfile,
///   goal: GoalContext(primaryGoal: LearningGoal.improveAccuracy),
/// );
///
/// // Get just related knowledge
/// final related = await rec.getRelatedKnowledge(
///   current: currentItem,
///   profile: playerProfile,
/// );
/// ```
class KnowledgeRecommendationService {
  final KnowledgeRepository knowledgeRepository;
  final DrillMappingLoader drillLoader;
  final LearningPathLoader pathLoader;

  KnowledgeRecommendationService({
    required KnowledgeRepository knowledgeRepository,
    required DrillMappingLoader drillLoader,
    required LearningPathLoader pathLoader,
  })  : knowledgeRepository = knowledgeRepository,
        drillLoader = drillLoader,
        pathLoader = pathLoader;

  /// Get complete recommendation set.
  /// 
  /// ```dart
  /// final set = await service.getRecommendations(
  ///   profile: playerProfile,
  ///   goal: GoalContext(primaryGoal: LearningGoal.improvePosition),
  ///   currentItem: someItem,
  /// );
  /// 
  /// print('Related: ${set.relatedKnowledge.length}');
  /// print('Drills: ${set.recommendedDrills.length}');
  /// ```
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

  /// Get related knowledge for an item.
  /// 
  /// ```dart
  /// final related = await service.getRelatedKnowledge(
  ///   current: item,
  ///   profile: playerProfile,
  /// );
  /// ```
  Future<List<Recommendation>> getRelatedKnowledge({
    required KnowledgeItem current,
    required PlayerProfile profile,
  }) async {
    final context = CurrentContext(currentItem: current);
    final candidates = await _getRelatedCandidates(current, profile);
    final scored = await _scoreCandidates(candidates, context, profile,
      GoalContext(primaryGoal: LearningGoal.improveAccuracy));
    final ranked = _rankRecommendations(scored);
    return ranked
        .where((r) => r.type == RecommendationType.relatedKnowledge)
        .toList();
  }

  /// Get recommended drills.
  /// 
  /// ```dart
  /// final drills = await service.getRecommendedDrills(
  ///   current: item,
  ///   profile: playerProfile,
  ///   goal: goalContext,
  /// );
  /// ```
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
    return ranked
        .where((r) => r.type == RecommendationType.recommendedDrill)
        .toList();
  }

  /// Get next skills to learn.
  /// 
  /// ```dart
  /// final next = await service.getNextSkills(
  ///   current: item,
  ///   profile: playerProfile,
  /// );
  /// ```
  Future<List<Recommendation>> getNextSkills({
    required KnowledgeItem current,
    required PlayerProfile profile,
  }) async {
    final context = CurrentContext(currentItem: current);
    final candidates = await _getNextSkillCandidates(current, profile);
    final scored = await _scoreCandidates(candidates, context, profile,
      GoalContext(primaryGoal: LearningGoal.learnNewShot));
    final ranked = _rankRecommendations(scored);
    return ranked
        .where((r) => r.type == RecommendationType.nextSkill)
        .toList();
  }

  /// Get learning paths for player profile.
  /// 
  /// ```dart
  /// final paths = await service.getLearningPaths(
  ///   profile: playerProfile,
  ///   goal: goalContext,
  /// );
  /// ```
  Future<List<Recommendation>> getLearningPaths({
    required PlayerProfile profile,
    required GoalContext goal,
  }) async {
    final candidates = await _getLearningPathCandidates(profile, goal);
    final scored = await _scoreCandidates(candidates, const CurrentContext(), profile, goal);
    final ranked = _rankRecommendations(scored);
    return ranked
        .where((r) => r.type == RecommendationType.learningPath)
        .toList();
  }

  /// Get top recommendation of a specific type.
  /// 
  /// ```dart
  /// final top = await service.getTopRecommendation(
  ///   profile: playerProfile,
  ///   goal: goalContext,
  ///   type: RecommendationType.recommendedDrill,
  /// );
  /// ```
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

  // ===== Candidate Collection =====

  List<dynamic> _collectCandidates(
    CurrentContext context,
    PlayerProfile profile,
    GoalContext goal,
  ) {
    final candidates = <dynamic>[];

    if (context.currentItem != null) {
      candidates.addAll(_getRelatedCandidatesSync(context.currentItem!));
      candidates.addAll(_getDrillCandidates(context.currentItem, profile, goal));
      if (context.currentItem!.nextRecommended != null) {
        candidates.add(context.currentItem!.nextRecommended!);
      }
    }

    for (final weakness in profile.weaknessAreas) {
      candidates.addAll(drillLoader.getDrillsBySkill(weakness));
    }

    candidates.addAll(_getItemsForGoal(goal.primaryGoal));

    return candidates.toSet().toList();
  }

  Future<List<dynamic>> _getRelatedCandidates(
    KnowledgeItem item,
    PlayerProfile profile,
  ) async {
    final candidates = <dynamic>[];

    for (final prereqId in item.prerequisites) {
      candidates.add(prereqId);
    }

    for (final ref in item.relatedKnowledge) {
      candidates.add(ref.id);
    }

    if (item.nextRecommended != null) {
      candidates.add(item.nextRecommended!.id);
    }

    return candidates;
  }

  List<dynamic> _getRelatedCandidatesSync(KnowledgeItem item) {
    final candidates = <dynamic>[];

    for (final prereqId in item.prerequisites) {
      candidates.add(prereqId);
    }

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
      return drillLoader.getDrillsForKnowledgeItem(item.id);
    }
    return _getDrillsForGoal(goal.primaryGoal);
  }

  Future<List<dynamic>> _getNextSkillCandidates(
    KnowledgeItem current,
    PlayerProfile profile,
  ) async {
    final candidates = <dynamic>[];

    if (current.nextRecommended != null) {
      final next = await knowledgeRepository.byId(current.nextRecommended!.id);
      if (next != null) candidates.add(next);
    }

    return candidates;
  }

  Future<List<dynamic>> _getLearningPathCandidates(
    PlayerProfile profile,
    GoalContext goal,
  ) async {
    final paths = await pathLoader.getPathsForLevel(profile.currentLevel);
    return paths;
  }

  List<dynamic> _getItemsForGoal(LearningGoal goal) {
    switch (goal) {
      case LearningGoal.improveAccuracy:
        return drillLoader.getDrillsBySkill('aim');
      case LearningGoal.improvePosition:
        return drillLoader.getDrillsBySkill('cue_ball');
      case LearningGoal.improveBreak:
        return drillLoader.getDrillsBySkill('break');
      case LearningGoal.improveSafety:
        return drillLoader.getDrillsBySkill('safety');
      case LearningGoal.fixMistakes:
        return drillLoader.getDrillsBySkill('mistakes');
      case LearningGoal.warmUp:
        return drillLoader.getDrillsBySkill('fundamentals');
      default:
        return [];
    }
  }

  List<dynamic> _getDrillsForGoal(LearningGoal goal) {
    switch (goal) {
      case LearningGoal.improveAccuracy:
        return drillLoader.getDrillsBySkill('aim');
      case LearningGoal.improvePosition:
        return drillLoader.getDrillsBySkill('cue_ball');
      case LearningGoal.warmUp:
        return drillLoader.getDrillsBySkill('fundamentals');
      default:
        return drillLoader.getAllDrills();
    }
  }

  // ===== Scoring =====

  Future<List<Recommendation>> _scoreCandidates(
    List<dynamic> candidates,
    CurrentContext context,
    PlayerProfile profile,
    GoalContext goal,
  ) async {
    final scored = <Recommendation>[];

    for (final candidate in candidates) {
      double baseScore = _calculateBaseScore(candidate, context, profile, goal);
      baseScore = _applyMultipliers(baseScore, candidate, context, profile);

      PrereqStatus prereqStatus = PrereqStatus.satisfied;
      if (candidate is String) {
        final item = await knowledgeRepository.byId(candidate);
        if (item != null) {
          prereqStatus = _checkPrerequisites(item, profile);
        }
      }

      final finalScore = baseScore * _getPrereqModifier(prereqStatus);

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
    if (context.currentItem != null && candidate is String) {
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
    if (!_isCompleted(candidate, profile)) {
      score += 10;
    }

    return score.clamp(0, 100);
  }

  double _distanceToScore(KnowledgeItem current, String candidateId) {
    // Prerequisite
    if (current.prerequisites.contains(candidateId)) return 20;
    if (current.relatedKnowledge.any((r) => r.id == candidateId)) return 25;
    if (current.nextRecommended?.id == candidateId) return 22;
    if (current.category == candidateId.split('.').first) return 12;
    return 0;
  }

  double _levelMatchScore(String playerLevel, KnowledgeDifficulty difficulty) {
    final expected = _levelToDifficulty(playerLevel);

    if (difficulty == expected) return 25;
    if (difficulty.index == expected.index - 1) return 18;
    if (difficulty.index == expected.index + 1) return 20;
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
    final category = _getCategory(candidate);

    switch (goal.primaryGoal) {
      case LearningGoal.improveAccuracy:
        if (category == 'aim') return 20;
        break;
      case LearningGoal.improvePosition:
        if (category == 'cue_ball') return 20;
        break;
      case LearningGoal.improveBreak:
        if (category == 'break') return 20;
        break;
      case LearningGoal.improveSafety:
        if (category == 'safety') return 20;
        break;
      case LearningGoal.fixMistakes:
        if (category == 'mistakes') return 20;
        break;
      default:
        break;
    }

    return 0;
  }

  bool _addressesWeakness(dynamic candidate, Set<String> weaknesses) {
    return weaknesses.contains(_getCategory(candidate));
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

  PrereqStatus _checkPrerequisites(KnowledgeItem item, PlayerProfile profile) {
    if (item.prerequisites.isEmpty) {
      return PrereqStatus.satisfied;
    }

    int satisfied = 0;
    for (final prereqId in item.prerequisites) {
      if (profile.completedItems.contains(prereqId)) {
        satisfied++;
      }
    }

    final ratio = satisfied / item.prerequisites.length;

    if (ratio >= 1.0) return PrereqStatus.satisfied;
    if (ratio >= 0.5) return PrereqStatus.partial;
    return PrereqStatus.missing;
  }

  double _getPrereqModifier(PrereqStatus status) {
    switch (status) {
      case PrereqStatus.satisfied:
        return 1.0;
      case PrereqStatus.partial:
        return 0.7;
      case PrereqStatus.missing:
        return 0.3;
    }
  }

  // ===== Helpers =====

  KnowledgeDifficulty _getDifficulty(dynamic candidate) {
    if (candidate is KnowledgeItem) return candidate.difficulty;
    if (candidate is Drill) {
      switch (candidate.difficulty) {
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
    return KnowledgeDifficulty.beginner;
  }

  String _getCategory(dynamic candidate) {
    if (candidate is KnowledgeItem) return candidate.category;
    if (candidate is Drill) return candidate.category;
    if (candidate is String) {
      final parts = candidate.split('.');
      return parts.isNotEmpty ? parts.first : '';
    }
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

  // ===== Build Recommendation =====

  Recommendation _buildRecommendation(
    dynamic candidate,
    double score,
    CurrentContext context,
    PlayerProfile profile,
    GoalContext goal,
    PrereqStatus prereqStatus,
  ) {
    return Recommendation(
      id: _getId(candidate),
      type: _getType(candidate),
      item: candidate,
      title: _getTitle(candidate),
      titleVi: _getTitleVi(candidate),
      priority: score,
      priorityRank: 0,
      reason: _generateReason(candidate, profile),
      reasonFactors: _getReasonFactors(candidate, profile, goal),
      estimatedGain: _estimateGain(candidate, profile),
      estimatedMinutes: _getEstimatedMinutes(candidate),
      isRequired: prereqStatus == PrereqStatus.missing,
    );
  }

  String _getId(dynamic candidate) {
    if (candidate is KnowledgeItem) return candidate.id;
    if (candidate is Drill) return candidate.code;
    if (candidate is LearningPath) return candidate.id;
    if (candidate is String) return candidate;
    return '';
  }

  RecommendationType _getType(dynamic candidate) {
    if (candidate is KnowledgeItem) return RecommendationType.relatedKnowledge;
    if (candidate is Drill) return RecommendationType.recommendedDrill;
    if (candidate is LearningPath) return RecommendationType.learningPath;
    return RecommendationType.relatedKnowledge;
  }

  String _getTitle(dynamic candidate) {
    if (candidate is KnowledgeItem) return candidate.title;
    if (candidate is Drill) return candidate.name;
    if (candidate is LearningPath) return candidate.name;
    return '';
  }

  String _getTitleVi(dynamic candidate) {
    if (candidate is KnowledgeItem) return candidate.titleVi;
    if (candidate is Drill) return candidate.nameVi;
    if (candidate is LearningPath) return candidate.nameVi;
    return '';
  }

  double _estimateGain(dynamic candidate, PlayerProfile profile) {
    if (candidate is KnowledgeItem) {
      final gains = candidate.estimatedSkillGain.values;
      final baseGain = gains.isEmpty ? 10.0 : gains.reduce((a, b) => a + b) / gains.length;
      if (profile.weaknessAreas.contains(candidate.category)) {
        return baseGain * 1.3;
      }
      return baseGain;
    }
    return 10.0;
  }

  String _generateReason(dynamic candidate, PlayerProfile profile) {
    if (profile.weaknessAreas.contains(_getCategory(candidate))) {
      return 'Addresses your ${_getCategory(candidate)} skills';
    }
    if (_isCompleted(candidate, profile)) {
      return 'Review for mastery';
    }
    return 'Recommended for your level';
  }

  List<String> _getReasonFactors(
    dynamic candidate,
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

    return factors;
  }

  // ===== Ranking & Grouping =====

  List<Recommendation> _rankRecommendations(List<Recommendation> recommendations) {
    recommendations.sort((a, b) => b.priority.compareTo(a.priority));

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

enum PrereqStatus { satisfied, partial, missing }
