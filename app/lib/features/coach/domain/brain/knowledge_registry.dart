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
        KnowledgeDestination.route('/session', isBranch: true),
    KnowledgeId.playGhost:
        KnowledgeDestination.route('/session', isBranch: true),
    KnowledgeId.recordTraining: KnowledgeDestination.route('/training-center'),
    KnowledgeId.logReadiness: KnowledgeDestination.route('/readiness'),

    // Review destinations (existing routes / branches).
    KnowledgeId.reviewStatistics:
        KnowledgeDestination.route('/statistics', isBranch: true),
    KnowledgeId.reviewEquipment:
        KnowledgeDestination.route('/equipment', isBranch: true),
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

  /// RFC-KB-002: map a Coach KnowledgeId to a Knowledge Pack article id, when a
  /// real article exists. The Coach screen prefers this (deep-link
  /// `/training-center?knowledgeId=<id>` → the exact article with the "Coach
  /// recommends this" banner) and only falls back to the drill-category / route
  /// destination below when there is no article. Coach still only emits a
  /// KnowledgeId — the Learning Hub decides rendering.
  static const Map<String, String> _coachToArticle = {
    KnowledgeId.practiceStopShot: 'tech.stop_shot',
    KnowledgeId.practiceLongPot: 'tech.long_pot',
    KnowledgeId.practicePosition: 'tech.position_play',
    KnowledgeId.practiceBreak: 'tech.break_basic',
    KnowledgeId.practiceSafety: 'tech.safety_basic',
  };

  /// The Knowledge Pack article id a Coach KnowledgeId should open, or null when
  /// there is no article (caller falls back to [resolve]/[routeFor]).
  static String? articleFor(String knowledgeId) => _coachToArticle[knowledgeId];

  /// Resolve a knowledge id to its destination, or null if unknown.
  static KnowledgeDestination? resolve(String knowledgeId) => _map[knowledgeId];

  /// The route a knowledge id ultimately opens. Drill categories open the
  /// Training Center route; explicit routes pass through. Null if unknown.
  static String? routeFor(String knowledgeId) {
    final dest = _map[knowledgeId];
    if (dest == null) return null;
    if (dest.drillCategory != null) return '/training-center';
    return dest.route;
  }

  /// Whether the destination is a bottom-nav branch switch (vs a pushed route).
  static bool isBranch(String knowledgeId) => _map[knowledgeId]?.isBranch ?? false;
}
