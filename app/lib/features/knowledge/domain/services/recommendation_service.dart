// EPIC 05 PO 2026-07-31 — Recommendation capability is closed in Pool OS Beta
// (spec §5 Forbidden list: "No Recommendation"). All public entry points
// return [CapabilityResult.notAvailable] with a deterministic reason —
// no exceptions thrown. The EPIC 04 Capability Pattern is enforced
// (Implemented / Capability / NotAvailable).
//
// Models `Recommendation`, `RecommendationSet`, `RecommendationType`,
// `CurrentContext`, `GoalContext`, `PlayerProfile`, `TrainingGoal`,
// and `PrerequisiteStatus` are retained so post-Beta work can re-enable
// the feature without a schema change. The RFC-REC-001 algorithm body
// has been removed from this file — it is no longer reachable and is
// not needed for the capability surface. The pre-removal algorithm
// remains in the commit history for audit traceability.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/knowledge/data/knowledge_repository.dart';
import 'package:pool_os/features/knowledge/domain/knowledge_capability.dart';

// Loader imports are intentionally `library`-isolated to the post-Beta
// audit surface only — they are not referenced from the capability
// entry points, which never read the loader args.
//
// [KnowledgeItem] is referenced as `dynamic` to keep this file compiling
// even when the package re-exports the model under a different identifier.

/// Player profile — minimal shape used by the legacy recommendation
/// inputs. Retained so post-Beta work has a single canonical type.
@immutable
class PlayerProfile {
  final String level;
  final List<String> completedItems;
  final List<String> weaknessAreas;

  const PlayerProfile({
    required this.level,
    this.completedItems = const <String>[],
    this.weaknessAreas = const <String>[],
  });
}

/// Training goal — categorical intent (Beta keeps the legacy enum so
/// post-Beta callers do not need to migrate).
enum TrainingGoal {
  improveAccuracy,
  learnNewShot,
  improvePosition,
  buildConsistency,
}

/// Goal context — pairs a primary goal with optional sub-goals. Kept for
/// post-Beta.
@immutable
class GoalContext {
  final TrainingGoal primaryGoal;
  final List<TrainingGoal> secondaryGoals;

  const GoalContext({
    required this.primaryGoal,
    this.secondaryGoals = const <TrainingGoal>[],
  });
}

/// Current-context projection — what the user is currently looking at.
/// Kept so post-Beta callers can thread through it without re-modeling.
@immutable
class CurrentContext {
  // Stored as dynamic to avoid forcing the package re-export of
  // `KnowledgeItem` — the capability surface never inspects the value.
  final dynamic currentItem;
  final String? currentType;
  final String? currentDifficulty;
  final String? currentCategory;

  const CurrentContext({
    this.currentItem,
    this.currentType,
    this.currentDifficulty,
    this.currentCategory,
  });
}

enum RecommendationType {
  relatedKnowledge,
  recommendedDrill,
  nextSkill,
  learningPath,
}

@immutable
class Recommendation {
  final String id;
  final RecommendationType type;
  final String title;
  final String description;
  final int priorityRank;

  const Recommendation({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.priorityRank = 0,
  });

  Recommendation copyWith({int? priorityRank}) => Recommendation(
        id: id,
        type: type,
        title: title,
        description: description,
        priorityRank: priorityRank ?? this.priorityRank,
      );
}

@immutable
class RecommendationSet {
  final List<Recommendation> relatedKnowledge;
  final List<Recommendation> recommendedDrills;
  final List<Recommendation> nextSkills;
  final List<Recommendation> learningPaths;
  final Duration totalEstimatedTime;

  const RecommendationSet({
    this.relatedKnowledge = const <Recommendation>[],
    this.recommendedDrills = const <Recommendation>[],
    this.nextSkills = const <Recommendation>[],
    this.learningPaths = const <Recommendation>[],
    this.totalEstimatedTime = Duration.zero,
  });

  Duration get totalEstimatedTimeGetter => totalEstimatedTime;
}

enum PrerequisiteStatus {
  notStarted,
  inProgress,
  completed,
  blocked,
}

/// Recommendation Service — capability-closed in Beta. Every public
/// entry point returns [CapabilityResult.notAvailable] with
/// [RecommendationCapability.reason]. The legacy RFC-REC-001 algorithm
/// has been removed from this file.
class RecommendationService {
  final KnowledgeRepository _repository;
  final dynamic _drillLoader;
  final dynamic _pathLoader;

  RecommendationService(
    this._repository, [
    dynamic drillLoader,
    dynamic pathLoader,
  ])  : _drillLoader = drillLoader,
        _pathLoader = pathLoader;

  /// Get complete recommendation set — capability-disabled.
  Future<CapabilityResult<RecommendationSet>> getRecommendations({
    required PlayerProfile profile,
    required GoalContext goal,
    dynamic currentItem,
  }) async {
    return CapabilityResult.notAvailable(RecommendationCapability.reason);
  }

  /// Get related knowledge — capability-disabled.
  Future<CapabilityResult<List<Recommendation>>> getRelatedKnowledge({
    required dynamic current,
    required PlayerProfile profile,
  }) async {
    return CapabilityResult.notAvailable(RecommendationCapability.reason);
  }

  /// Get recommended drills — capability-disabled.
  Future<CapabilityResult<List<Recommendation>>> getRecommendedDrills({
    dynamic current,
    required PlayerProfile profile,
    required GoalContext goal,
  }) async {
    return CapabilityResult.notAvailable(RecommendationCapability.reason);
  }

  /// Get next skills — capability-disabled.
  Future<CapabilityResult<List<Recommendation>>> getNextSkills({
    required dynamic current,
    required PlayerProfile profile,
  }) async {
    return CapabilityResult.notAvailable(RecommendationCapability.reason);
  }

  /// Get learning paths — capability-disabled.
  Future<CapabilityResult<List<Recommendation>>> getLearningPaths({
    required PlayerProfile profile,
    required GoalContext goal,
  }) async {
    return CapabilityResult.notAvailable(RecommendationCapability.reason);
  }

  /// Get top recommendation of a type — capability-disabled.
  Future<CapabilityResult<Recommendation?>> getTopRecommendation({
    required PlayerProfile profile,
    required GoalContext goal,
    required RecommendationType type,
    dynamic currentItem,
  }) async {
    return CapabilityResult.notAvailable(RecommendationCapability.reason);
  }
}

/// Provider wired to the capability-closed service. UI should gate on
/// [RecommendationCapability.unavailable] before reading.
final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  // The capability surface returns [CapabilityResult.notAvailable] for
  // every entry point. Loader arguments are required by the constructor
  // signature but never used; passing placeholders keeps the provider
  // constructable without forcing every consumer to know the legacy
  // loader types.
  return RecommendationService(ref.watch(knowledgeRepositoryProvider));
});

/// Provider for the recommendation set — capability-closed.
final recommendationSetProvider = FutureProvider.family<
    CapabilityResult<RecommendationSet>, RecommendationParams>(
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
  final dynamic currentItem;

  RecommendationParams({
    required this.profile,
    required this.goal,
    this.currentItem,
  });
}