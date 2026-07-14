// Task 15 — Coach Intelligence V2, Layer 3: Coach Brain output model.
//
// This is the UNIFIED coaching model. Every piece of coaching the user sees is a
// CoachInsightV2, and ONLY Coach Brain constructs them. It replaces the three
// fragmented legacy models (CoachInsight / CoachRecommendation / CoachAdvice).
//
// Design points from the approved plan:
//  - Player Level and Coach Understanding are SEPARATE, never-conflated concepts.
//  - Exactly one primary Next Action is surfaced at a time (the hero CTA).
//  - Positive reinforcement is a first-class priority tier.
//  - Actions reference a stable KnowledgeId, not a hard route.
//  - Feed items carry a schema version and a lifecycle state.

import 'package:pool_os/features/coach/domain/context/coach_context.dart'
    show TrajectoryDirection;
import 'package:pool_os/features/coach/domain/findings/finding.dart';

/// Current Coach Feed schema version. Bump when [CoachInsightV2]'s shape changes
/// so the UI can migrate/guard old shapes.
const int kCoachFeedVersion = 1;

/// The standardized, ORDERED priority hierarchy Coach Brain ranks by. Declared
/// top-to-bottom = most to least urgent. Deliberately GENERIC (not tied to the
/// rule engine) so future sources — an AI coach or CMS-authored Knowledge — can
/// emit insights at the same tiers without new priority types:
///  - critical  : a confirmed, high-impact problem to fix now (e.g. a reliable
///                weakness, a shot that drops badly under match pressure).
///  - improve   : something worth working on (an opportunity, a declining trend).
///  - missingData: a conclusion is blocked until the player records more data.
///  - knowledge : a teaching card (technique / common mistakes / why) — the tier
///                CMS- or AI-authored Knowledge content will use.
///  - celebrate : positive reinforcement (achievement, progress, effort).
/// `celebrate` is first-class but ordered last, so encouragement never buries an
/// actionable item yet always has a place in the feed.
enum CoachPriority {
  critical,
  improve,
  missingData,
  knowledge,
  celebrate,
}

/// How much Coach trusts a conclusion. Derived by Brain from sample size,
/// cross-context agreement, and trajectory stability — never fabricated.
enum CoachConfidence { high, medium, low, insufficient }

/// Feed-item lifecycle so the UI can evolve safely (hide resolved, dim snoozed).
/// Coach owns no storage, so lifecycle is recomputed each run — `resolved` means
/// the underlying condition no longer holds in the current data.
enum CoachLifecycle { active, snoozed, resolved }

/// A topic bucket for grouping/labeling. Maps to an l10n label key in the UI.
enum CoachTopic {
  overallLevel,
  shotSkill,
  underPressure,
  consistency,
  readiness,
  endurance,
  equipment,
  training,
  progress,
  dataGap,
}

/// A next action. References a stable [knowledgeId] that the presentation layer
/// resolves to a destination via the knowledge registry — Brain never hard-codes
/// a route or a specific lesson. [labelKey] is an l10n key for the button text.
class CoachAction {
  final String labelKey;
  final String knowledgeId;

  const CoachAction({required this.labelKey, required this.knowledgeId});
}

/// One unified coaching insight. Observation/cause are l10n keys (Brain decides
/// the message, the screen renders the language); [evidence] is a short,
/// already-formatted factual string (e.g. "40 shots: 95% train / 61% match") and
/// [evidenceData] carries the raw numbers behind it for the UI to format richly.
class CoachInsightV2 {
  final int version;
  final String id;
  final CoachTopic topic;
  final CoachPriority priority;
  final String observationKey;
  final String causeKey;
  final String evidence;
  final CoachConfidence confidence;
  final CoachLifecycle lifecycle;
  final CoachAction? action;
  final bool isPositive;
  final Map<String, Object?> evidenceData;

  const CoachInsightV2({
    this.version = kCoachFeedVersion,
    required this.id,
    required this.topic,
    required this.priority,
    required this.observationKey,
    this.causeKey = '',
    this.evidence = '',
    this.confidence = CoachConfidence.medium,
    this.lifecycle = CoachLifecycle.active,
    this.action,
    this.isPositive = false,
    this.evidenceData = const {},
  });
}

/// How good the player is. SEPARATE from Coach Understanding — a beginner can be
/// well-understood, a strong player can be poorly-understood. [levelKey] is an
/// l10n key (beginner/intermediate/…); [levelConfidence] is null/low when data
/// is too thin to place the level reliably (rendered as "provisional").
class PlayerLevel {
  final String levelKey;
  final TrajectoryDirection trajectory;
  final double? levelConfidence;

  const PlayerLevel({
    required this.levelKey,
    this.trajectory = TrajectoryDirection.unknown,
    this.levelConfidence,
  });

  bool get isProvisional =>
      levelConfidence == null || levelConfidence! < 0.34;
}

/// How complete Coach's own data picture is. SEPARATE from player level.
/// [dataCompleteness] is 0.0–1.0 across the tracked sources; [missing] lists
/// sources with no data yet (drives "let's get more data" prompts).
class CoachUnderstanding {
  final double dataCompleteness;
  final Map<FindingSource, double> coverage;
  final List<FindingSource> missing;

  const CoachUnderstanding({
    this.dataCompleteness = 0,
    this.coverage = const {},
    this.missing = const [],
  });
}

/// Everything the Coach screen renders. [primaryAction] is the SINGLE highest-
/// priority next action for right now (the hero CTA); [feed] is the full ranked
/// list of insights.
class CoachOutput {
  final int version;
  final PlayerLevel level;
  final CoachUnderstanding understanding;
  final CoachAction? primaryAction;
  final List<CoachInsightV2> feed;

  const CoachOutput({
    this.version = kCoachFeedVersion,
    required this.level,
    required this.understanding,
    this.primaryAction,
    this.feed = const [],
  });

  /// True when there is no recorded data at all — screen shows onboarding.
  bool get isOnboarding => feed.isEmpty && understanding.dataCompleteness == 0;
}
