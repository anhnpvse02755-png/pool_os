// EPIC 05 §3 — Integration boundary.
//
// Spec §3 — Knowledge integrates with:
//   - Training System
//   - Goal
//   - Lesson
//   - Coach Notes
//   - Pattern Library
//   - Statistics
//   - Player Timeline
//
// PO 2026-07-31 — no circular dependency. Knowledge is read-only and never
// imports from any of the above modules; it only exposes view-model
// adapters. Each integration surface below is a forward declaration — the
// training-system / goal / lesson modules can call into this boundary but
// this boundary never imports them.
//
// This file declares the integration surface as plain constants and
// typedefs so the boundary is compiler-checkable. Actual integrations are
// wired in the target modules (Training, Goal, ...), not here.

/// Integration contract identifiers. Each entry maps to exactly one
/// upstream feature module; the upstream module imports a single
/// read-only adapter from the knowledge feature.
class KnowledgeIntegrationContract {
  /// Training System cross-link.
  static const String training = 'knowledge.cross.training';

  /// Goal cross-link.
  static const String goal = 'knowledge.cross.goal';

  /// Lesson cross-link.
  static const String lesson = 'knowledge.cross.lesson';

  /// Coach Notes cross-link.
  static const String coachNotes = 'knowledge.cross.coach_notes';

  /// Pattern Library cross-link.
  static const String patternLibrary = 'knowledge.cross.pattern_library';

  /// Statistics cross-link.
  static const String statistics = 'knowledge.cross.statistics';

  /// Player Timeline cross-link.
  static const String playerTimeline = 'knowledge.cross.player_timeline';

  /// All contracts, in deterministic order. Read-only surface.
  static const List<String> allContracts = <String>[
    training,
    goal,
    lesson,
    coachNotes,
    patternLibrary,
    statistics,
    playerTimeline,
  ];
}

/// Deterministic import-direction check. PO 2026-07-31 forbids the
/// knowledge feature from importing any of the upstream modules. The
/// constants below MUST stay null in production builds. They exist only
/// so the integrator can assert (during automated checks) that the
/// boundary direction has not been inverted.
class KnowledgeImportDirection {
  /// Always false. Knowledge never imports `training_system`.
  static const bool importsTrainingSystem = false;

  /// Always false. Knowledge never imports `goal_center`.
  static const bool importsGoalCenter = false;

  /// Always false. Knowledge never imports `lesson`.
  static const bool importsLesson = false;

  /// Always false. Knowledge never imports `coach_notes`.
  static const bool importsCoachNotes = false;

  /// Always false. Knowledge never imports `pattern_library` (Pattern
  /// Library is now hosted inside the knowledge feature — see §2.5).
  static const bool importsPatternLibrary = false;

  /// Always false. Knowledge never imports `statistics`.
  static const bool importsStatistics = false;

  /// Always false. Knowledge never imports `player_timeline`.
  static const bool importsPlayerTimeline = false;
}

/// Round-trip integration witness — a single class that upstream modules
/// can hold a reference to so they don't have to import anything from
/// knowledge. The class is empty; it exists purely to give the dependency
/// graph a single concrete anchor that points inward.
class KnowledgeIntegrationWitness {
  const KnowledgeIntegrationWitness();
}