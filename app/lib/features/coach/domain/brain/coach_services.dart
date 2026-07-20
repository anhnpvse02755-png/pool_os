// Task 15 — Coach Intelligence V2, Layer 3: Coach Brain internal services.
//
// Coach Brain is a thin orchestrator (coach_brain.dart) over these focused,
// pure-Dart services. Splitting the decision logic this way avoids a God Object
// and lets each rule be unit-tested in isolation. None of these touch Drift or
// Riverpod — they operate on the derived CoachContext and emit decisions.
//
// Every service here is DECISION logic (what a fact means / what to do), which
// is exactly what must NOT live in a module. It lives here, in the Brain, and
// nowhere else.

import 'package:pool_os/features/coach/domain/brain/coach_output.dart';
import 'package:pool_os/features/coach/domain/brain/knowledge_registry.dart';
import 'package:pool_os/features/coach/domain/context/coach_context.dart';
import 'package:pool_os/features/coach/domain/findings/finding.dart';

/// Sample-size thresholds shared across services. Mirrors the equipment
/// service's min-sample convention (=8) and a small gap dead-band (=0.15) so a
/// "gap" is only claimed when it is real, not noise.
class CoachThresholds {
  static const int minReliableSample = 8;
  static const int minMediumSample = 4;
  static const double contextGap = 0.15; // training-vs-match gap that matters
  static const double weakRate = 0.55; // below this a skill reads as weak
  static const double strongRate = 0.80; // at/above this it reads as a strength
}

/// Decides confidence for a single finding or a grouped conclusion.
class ConfidenceService {
  CoachConfidence forSample(int sample) {
    if (sample >= CoachThresholds.minReliableSample) {
      return CoachConfidence.high;
    }
    if (sample >= CoachThresholds.minMediumSample) {
      return CoachConfidence.medium;
    }
    if (sample > 0) return CoachConfidence.low;
    return CoachConfidence.insufficient;
  }

  /// Confidence for a cross-context conclusion (e.g. training-vs-match gap):
  /// only high when BOTH contexts have a reliable sample, so Coach never says
  /// "drops under pressure" off two match shots.
  CoachConfidence forContextGap(ContextValue a, ContextValue b) {
    final minSample = a.attempts < b.attempts ? a.attempts : b.attempts;
    return forSample(minSample);
  }
}

/// Resolves a topic to a KnowledgeId-backed action. Never hard-codes a route.
class ActionResolver {
  CoachAction? forShotType(String shotType) {
    final id = _shotKnowledge[shotType] ?? KnowledgeId.practiceGeneric;
    return CoachAction(labelKey: 'coach_v2_action_practice', knowledgeId: id);
  }

  CoachAction logReadiness() => const CoachAction(
      labelKey: 'coach_v2_action_log_readiness',
      knowledgeId: KnowledgeId.logReadiness);

  CoachAction playMatch() => const CoachAction(
      labelKey: 'coach_v2_action_play_match',
      knowledgeId: KnowledgeId.playMatch);

  CoachAction recordTraining() => const CoachAction(
      labelKey: 'coach_v2_action_record_training',
      knowledgeId: KnowledgeId.recordTraining);

  CoachAction learnEntry(String entryId) => CoachAction(
      labelKey: 'coach_v2_action_learn',
      knowledgeId: KnowledgeId.learningEntry(entryId));

  CoachAction reviewEndurance() => const CoachAction(
      labelKey: 'coach_v2_action_review_endurance',
      knowledgeId: KnowledgeId.reviewEndurance);

  CoachAction reviewEquipment() => const CoachAction(
      labelKey: 'coach_v2_action_review_equipment',
      knowledgeId: KnowledgeId.reviewEquipment);

  CoachAction forPerformanceDimension(String dimension) {
    final knowledgeId = switch (dimension) {
      'breakShot' => KnowledgeId.practiceBreak,
      'safety' => KnowledgeId.practiceSafety,
      'cueBall' => KnowledgeId.practicePosition,
      _ => KnowledgeId.practiceGeneric,
    };
    return CoachAction(
      labelKey: 'coach_v2_action_practice',
      knowledgeId: knowledgeId,
    );
  }

  static const Map<String, String> _shotKnowledge = {
    'stopShot': KnowledgeId.practiceStopShot,
    'straightShot': KnowledgeId.practiceStopShot,
    'longPot': KnowledgeId.practiceLongPot,
    'position': KnowledgeId.practicePosition,
    'break': KnowledgeId.practiceBreak,
    'safety': KnowledgeId.practiceSafety,
    'jump': KnowledgeId.practiceJump,
    'bank': KnowledgeId.practiceBank,
  };
}

/// Emits positive-reinforcement insights from improving trajectories. First
/// class: Coach encourages, not only corrects.
class ReinforcementService {
  List<CoachInsightV2> celebrate(CoachContext ctx) {
    final out = <CoachInsightV2>[];
    ctx.trajectory.byMetric.forEach((metricId, traj) {
      if (traj.direction() == TrajectoryDirection.improving) {
        final recentPct = ((traj.recentRate ?? 0) * 100).round();
        final priorPct = ((traj.priorRate ?? 0) * 100).round();
        out.add(CoachInsightV2(
          id: 'positive.$metricId',
          topic: CoachTopic.progress,
          priority: CoachPriority.celebrate,
          observationKey: 'coach_v2_obs_improving',
          causeKey: 'coach_v2_cause_practice_paying_off',
          evidence: '$priorPct% → $recentPct%',
          confidence: CoachConfidence.high,
          isPositive: true,
          evidenceData: {
            'metricId': metricId,
            'recentPct': recentPct,
            'priorPct': priorPct,
          },
        ));
      }
    });
    return out;
  }
}

/// Computes the TWO separate summaries. Player level and Coach understanding are
/// intentionally derived from different inputs and never share a number.
class LevelService {
  /// The set of sources that count toward "how complete is the Coach's picture".
  static const List<FindingSource> _trackedSources = [
    FindingSource.shots,
    FindingSource.performance,
    FindingSource.skill,
    FindingSource.training,
    FindingSource.mastery,
    FindingSource.equipment,
    FindingSource.readiness,
    FindingSource.endurance,
  ];

  CoachUnderstanding understanding(CoachContext ctx) {
    final coverage = <FindingSource, double>{};
    final missing = <FindingSource>[];
    for (final s in _trackedSources) {
      final count = ctx.coverage.countFor(s);
      coverage[s] = count > 0 ? 1.0 : 0.0;
      if (count == 0) missing.add(s);
    }
    final have = _trackedSources.length - missing.length;
    return CoachUnderstanding(
      dataCompleteness: have / _trackedSources.length,
      coverage: coverage,
      missing: missing,
    );
  }

  /// Player level from skill scores (real) + overall accuracy, tagged with
  /// trajectory. Provisional (low confidence) when the sample behind it is thin.
  PlayerLevel level(CoachContext ctx) {
    final skills = ctx.fromSource(FindingSource.skill);
    double? avgScore;
    if (skills.isNotEmpty) {
      final vals = skills.map((f) => f.value ?? 0).toList();
      avgScore = vals.reduce((a, b) => a + b) / vals.length;
    } else {
      // Fall back to competition execution when skills haven't been computed.
      final acc = ctx.findings
          .where((f) => f.metricId == 'performance.execution')
          .map((f) => f.value)
          .whereType<double>()
          .toList();
      if (acc.isNotEmpty) avgScore = acc.first;
    }

    // Overall trajectory = the most common shot-type direction.
    final dir = _dominantTrajectory(ctx);

    if (avgScore == null) {
      return PlayerLevel(levelKey: 'coach_v2_level_unknown', trajectory: dir);
    }
    final levelKey = avgScore >= 75
        ? 'coach_v2_level_advanced'
        : avgScore >= 50
            ? 'coach_v2_level_intermediate'
            : 'coach_v2_level_beginner';

    // Confidence in the level placement scales with total shot sample.
    final shotSample = ctx
        .fromSource(FindingSource.shots)
        .fold<int>(0, (s, f) => s + f.sampleSize);
    final levelConfidence = (shotSample / 50).clamp(0.0, 1.0);

    return PlayerLevel(
      levelKey: levelKey,
      trajectory: dir,
      levelConfidence: levelConfidence,
    );
  }

  TrajectoryDirection _dominantTrajectory(CoachContext ctx) {
    final counts = <TrajectoryDirection, int>{};
    for (final t in ctx.trajectory.byMetric.values) {
      final d = t.direction();
      if (d == TrajectoryDirection.unknown) continue;
      counts[d] = (counts[d] ?? 0) + 1;
    }
    if (counts.isEmpty) return TrajectoryDirection.unknown;
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
}

/// Orders a list of insights by the standardized [CoachPriority] hierarchy, then
/// picks the single primary action. Positive-reinforcement items are ranked last
/// and are never chosen as the primary action.
class PriorityService {
  List<CoachInsightV2> rank(List<CoachInsightV2> insights) {
    final sorted = [...insights]
      ..sort((a, b) => a.priority.index.compareTo(b.priority.index));
    return sorted;
  }

  /// The single hero action: the top-ranked ACTIONABLE, non-positive insight.
  CoachAction? primaryAction(List<CoachInsightV2> rankedInsights) {
    for (final i in rankedInsights) {
      if (i.isPositive) continue;
      if (i.action != null) return i.action;
    }
    return null;
  }
}
