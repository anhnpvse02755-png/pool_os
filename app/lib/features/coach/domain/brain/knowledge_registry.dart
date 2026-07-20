// Task 15 — Coach Intelligence V2, Layer 3 support: KnowledgeId registry.
//
// Coach Brain never hard-codes a route or a specific lesson. It attaches a
// stable KnowledgeId to an action; the presentation layer resolves that id to a
// concrete destination through this registry. This keeps Brain independent of
// navigation and lets destinations evolve without touching decision logic.
//
// A destination is either an EXISTING app route (never a new one) or a training
// drill category that the Training Center opens. Nothing here creates routes.

/// Stable knowledge identifiers Coach Brain may reference. Adding coaching topics
/// means adding an id here + a registry entry — Brain stays route-agnostic.
class KnowledgeId {
  static const String learningEntryPrefix = 'learning_entry:';

  static String learningEntry(String entryId) => '$learningEntryPrefix$entryId';
  // Data-gathering prompts (onboarding / blocked-by-missing-data).
  static const String logReadiness = 'log_readiness';
  static const String playMatch = 'play_match';
  static const String playGhost = 'play_ghost';
  static const String recordTraining = 'record_training';

  // Review / understand destinations.
  static const String reviewStatistics = 'review_statistics';
  static const String reviewEquipment = 'review_equipment';
  static const String reviewEndurance = 'review_endurance';

  // Practice a specific skill (resolves to a Training Center drill category).
  static const String practiceStopShot = 'practice_stop_shot';
  static const String practiceLongPot = 'practice_long_pot';
  static const String practicePosition = 'practice_position';
  static const String practiceBreak = 'practice_break';
  static const String practiceSafety = 'practice_safety';
  static const String practiceJump = 'practice_jump';
  static const String practiceBank = 'practice_bank';
  static const String practiceGeneric = 'practice_generic';
}

/// How a KnowledgeId resolves. Exactly one of [route] / [drillCategory] is set.
/// [route] must be an EXISTING route (see app_router.dart). [isBranch] = the
/// destination is a bottom-nav branch (switch tab) vs a pushed top-level route.
class KnowledgeDestination {
  final String? route;
  final bool isBranch;
  final String? drillCategory;

  const KnowledgeDestination.route(this.route, {this.isBranch = false})
      : drillCategory = null;

  const KnowledgeDestination.drill(this.drillCategory)
      : route = null,
        isBranch = false;
}

/// Pure map from KnowledgeId → destination. No navigation happens here — the
/// screen reads this to decide how to route when the user taps an action.
class KnowledgeRegistry {
  static const Map<String, KnowledgeDestination> _map = {
    // Data prompts → the session tab (matches + ghost are started there).
    KnowledgeId.playMatch:
        KnowledgeDestination.route('/session/match', isBranch: true),
    KnowledgeId.playGhost: KnowledgeDestination.route('/training-center'),
    KnowledgeId.recordTraining: KnowledgeDestination.route('/training-center'),
    KnowledgeId.logReadiness: KnowledgeDestination.route('/readiness'),

    // Review destinations (existing routes / branches).
    KnowledgeId.reviewStatistics: KnowledgeDestination.route('/statistics'),
    KnowledgeId.reviewEquipment: KnowledgeDestination.route('/equipment'),
    KnowledgeId.reviewEndurance: KnowledgeDestination.route('/endurance'),

    // Practice a skill → Training Center opened on a drill category. The screen
    // passes the category through to the Training Center (which already filters
    // by category); the route itself stays '/training-center'.
    KnowledgeId.practiceStopShot: KnowledgeDestination.drill('straightShot'),
    KnowledgeId.practiceLongPot: KnowledgeDestination.drill('longPot'),
    KnowledgeId.practicePosition: KnowledgeDestination.drill('position'),
    KnowledgeId.practiceBreak: KnowledgeDestination.drill('break'),
    KnowledgeId.practiceSafety: KnowledgeDestination.drill('safety'),
    KnowledgeId.practiceJump: KnowledgeDestination.drill('jump'),
    KnowledgeId.practiceBank: KnowledgeDestination.drill('bank'),
    KnowledgeId.practiceGeneric: KnowledgeDestination.route('/training-center'),
  };

  /// Exact article mappings only. Missing topics fall back to drill categories;
  /// they must never be redirected to a merely similar article.
  static const Map<String, String> _coachToArticle = {
    KnowledgeId.practiceStopShot: 'control.stop_shot',
    KnowledgeId.practicePosition: 'position.zone_planning',
    KnowledgeId.practiceBreak: 'break.controlled_power',
    KnowledgeId.practiceSafety: 'strategy.safety.objective',
  };

  /// The Knowledge Pack article id a Coach KnowledgeId should open, or null when
  /// there is no article (caller falls back to [resolve]/[routeFor]).
  static String? articleFor(String knowledgeId) {
    if (knowledgeId.startsWith(KnowledgeId.learningEntryPrefix)) {
      final entryId =
          knowledgeId.substring(KnowledgeId.learningEntryPrefix.length);
      return entryId.isEmpty ? null : entryId;
    }
    return _coachToArticle[knowledgeId];
  }

  /// Resolve a knowledge id to its destination, or null if unknown.
  static KnowledgeDestination? resolve(String knowledgeId) {
    if (articleFor(knowledgeId) != null) {
      return const KnowledgeDestination.route('/training-center');
    }
    return _map[knowledgeId];
  }

  /// The route a knowledge id ultimately opens. Drill categories open the
  /// Training Center route; explicit routes pass through. Null if unknown.
  static String? routeFor(String knowledgeId) {
    if (articleFor(knowledgeId) != null) return '/training-center';
    final dest = _map[knowledgeId];
    if (dest == null) return null;
    if (dest.drillCategory != null) return '/training-center';
    return dest.route;
  }

  /// Whether the destination is a bottom-nav branch switch (vs a pushed route).
  static bool isBranch(String knowledgeId) =>
      _map[knowledgeId]?.isBranch ?? false;
}
