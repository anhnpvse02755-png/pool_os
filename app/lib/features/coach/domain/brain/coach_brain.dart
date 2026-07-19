// Task 15 — Coach Intelligence V2, Layer 3: Coach Brain (the sole decision-maker).
//
// Coach Brain is the ONLY place that turns pure facts into coaching. It consumes
// the derived CoachContext and, using its focused services, decides priority,
// grouping, confidence, timing and next action — then constructs the feed. No
// module and no producer may do any of this. Brain is a thin orchestrator: the
// judgement lives in the small services in coach_services.dart, so no God Object.
//
// Determinism: given the same CoachContext, decide() always returns the same
// ordered output (no randomness, no wall-clock beyond the passed `now`).

import 'package:pool_os/features/coach/domain/brain/coach_output.dart';
import 'package:pool_os/features/coach/domain/brain/coach_services.dart';
import 'package:pool_os/features/coach/domain/context/coach_context.dart';
import 'package:pool_os/features/coach/domain/findings/finding.dart';

class CoachBrain {
  final ConfidenceService _confidence;
  final ActionResolver _actions;
  final ReinforcementService _reinforcement;
  final LevelService _level;
  final PriorityService _priority;

  CoachBrain({
    ConfidenceService? confidence,
    ActionResolver? actions,
    ReinforcementService? reinforcement,
    LevelService? level,
    PriorityService? priority,
  })  : _confidence = confidence ?? ConfidenceService(),
        _actions = actions ?? ActionResolver(),
        _reinforcement = reinforcement ?? ReinforcementService(),
        _level = level ?? LevelService(),
        _priority = priority ?? PriorityService();

  /// The single entry point. Turns a derived context into the coaching output.
  CoachOutput decide(CoachContext ctx, {DateTime? now}) {
    final level = _level.level(ctx);
    final understanding = _level.understanding(ctx);

    // Onboarding: nothing recorded yet → a single guiding action, no analysis.
    if (ctx.isEmpty) {
      final onboarding = CoachInsightV2(
        id: 'onboarding',
        topic: CoachTopic.dataGap,
        priority: CoachPriority.missingData,
        observationKey: 'coach_v2_obs_welcome',
        causeKey: 'coach_v2_cause_no_data',
        confidence: CoachConfidence.insufficient,
        action: _actions.playMatch(),
      );
      return CoachOutput(
        level: level,
        understanding: understanding,
        primaryAction: onboarding.action,
        feed: [onboarding],
      );
    }

    final insights = <CoachInsightV2>[];
    insights.addAll(_shotContextInsights(ctx));
    insights.addAll(_performanceInsights(ctx));
    insights.addAll(_readinessInsights(ctx, now: now));
    insights.addAll(_enduranceInsights(ctx));
    insights.addAll(_missingDataInsights(ctx, understanding));
    insights.addAll(_reinforcement.celebrate(ctx));

    final ranked = _priority.rank(insights);
    final primary = _priority.primaryAction(ranked);

    return CoachOutput(
      level: level,
      understanding: understanding,
      primaryAction: primary,
      feed: ranked,
    );
  }

  /// Performance supplies measurements; only Coach decides whether one of
  /// those facts deserves attention. At most one dimension is emitted here so
  /// the feed does not become a second Statistics screen.
  List<CoachInsightV2> _performanceInsights(CoachContext ctx) {
    final candidates = ctx
        .fromSource(FindingSource.performance)
        .where((finding) =>
            finding.data['coachReady'] == true &&
            finding.value != null &&
            finding.value! < 70)
        .toList()
      ..sort((a, b) => a.value!.compareTo(b.value!));
    if (candidates.isEmpty) return const [];

    final finding = candidates.first;
    final dimension = finding.data['dimension'] as String? ?? 'execution';
    return [
      CoachInsightV2(
        id: 'performance.$dimension',
        topic: CoachTopic.performance,
        priority: CoachPriority.improve,
        observationKey: 'coach_v2_obs_performance_$dimension',
        causeKey: 'coach_v2_cause_competition_sample',
        evidence: '${finding.value!.round()}/100 | n=${finding.sampleSize}',
        confidence: _confidence.forSample(finding.sampleSize),
        action: _actions.forPerformanceDimension(dimension),
        evidenceData: {
          'dimension': dimension,
          'score': finding.value,
          'sampleSize': finding.sampleSize,
          'methodologyId': finding.data['methodologyId'],
        },
      ),
    ];
  }

  /// Per-shot-type conclusions from the training/match context split — the
  /// headline Coach behaviour ("great in practice, drops under match pressure").
  List<CoachInsightV2> _shotContextInsights(CoachContext ctx) {
    final out = <CoachInsightV2>[];
    for (final f in ctx.fromSource(FindingSource.shots)) {
      final shotType = (f.data['shotType'] as String?) ?? f.metricId;
      final train = f.context(PlayStyleContext.training);
      final match = f.context(PlayStyleContext.match);

      // Case 1: a reliable training-vs-match gap → "apply under pressure".
      if (train.attempts >= CoachThresholds.minReliableSample &&
          match.attempts >= CoachThresholds.minReliableSample) {
        final gap = train.rate - match.rate;
        if (gap >= CoachThresholds.contextGap) {
          out.add(CoachInsightV2(
            id: 'shot_gap.$shotType',
            topic: CoachTopic.underPressure,
            priority: CoachPriority.critical,
            observationKey: 'coach_v2_obs_drops_under_pressure',
            causeKey: 'coach_v2_cause_pressure',
            evidence:
                '${(train.rate * 100).round()}% train / ${(match.rate * 100).round()}% match',
            confidence: _confidence.forContextGap(train, match),
            action: _actions.forShotType(shotType),
            evidenceData: {
              'shotType': shotType,
              'trainRate': train.rate,
              'matchRate': match.rate,
              'trainAttempts': train.attempts,
              'matchAttempts': match.attempts,
            },
          ));
          continue;
        }
      }

      // Case 2: a plain weakness where we have a decent overall sample.
      if (f.sampleSize >= CoachThresholds.minMediumSample &&
          (f.value ?? 1) < CoachThresholds.weakRate) {
        out.add(CoachInsightV2(
          id: 'shot_weak.$shotType',
          topic: CoachTopic.shotSkill,
          priority: CoachPriority.improve,
          observationKey: 'coach_v2_obs_weak_shot',
          causeKey: 'coach_v2_cause_needs_practice',
          evidence:
              '${((f.value ?? 0) * 100).round()}% • ${f.sampleSize} shots',
          confidence: _confidence.forSample(f.sampleSize),
          action: _actions.forShotType(shotType),
          evidenceData: {'shotType': shotType, 'rate': f.value},
        ));
      }
    }
    return out;
  }

  /// Timely nudge: no readiness logged today → a top-of-day action.
  List<CoachInsightV2> _readinessInsights(CoachContext ctx, {DateTime? now}) {
    final readiness = ctx.fromSource(FindingSource.readiness);
    if (readiness.isEmpty) return const [];
    final today = readiness.first;
    final logged = today.data['loggedToday'] == true;
    if (logged) return const [];
    return [
      CoachInsightV2(
        id: 'readiness_missing',
        topic: CoachTopic.readiness,
        priority: CoachPriority.missingData,
        observationKey: 'coach_v2_obs_no_readiness_today',
        causeKey: 'coach_v2_cause_readiness_helps',
        confidence: CoachConfidence.high,
        action: _actions.logReadiness(),
      ),
    ];
  }

  /// Endurance decline → review the learned stamina profile.
  List<CoachInsightV2> _enduranceInsights(CoachContext ctx) {
    final endurance = ctx.fromSource(FindingSource.endurance);
    if (endurance.isEmpty) return const [];
    final e = endurance.first;
    final decline = e.data['averageDeclineRack'];
    if (decline is! int || e.sampleSize < CoachThresholds.minMediumSample) {
      return const [];
    }
    return [
      CoachInsightV2(
        id: 'endurance_decline',
        topic: CoachTopic.endurance,
        priority: CoachPriority.improve,
        observationKey: 'coach_v2_obs_endurance_decline',
        causeKey: 'coach_v2_cause_fatigue',
        evidence: 'rack ~$decline',
        confidence: _confidence.forSample(e.sampleSize),
        action: _actions.reviewEndurance(),
        evidenceData: {'declineRack': decline},
      ),
    ];
  }

  /// When a whole source is missing, prompt to gather it — but only when its
  /// absence actually blocks a conclusion (e.g. training data but no matches).
  List<CoachInsightV2> _missingDataInsights(
    CoachContext ctx,
    CoachUnderstanding understanding,
  ) {
    final out = <CoachInsightV2>[];
    final hasTraining = ctx.coverage.hasAny(FindingSource.training) ||
        ctx
            .fromSource(FindingSource.shots)
            .any((f) => f.context(PlayStyleContext.training).attempts > 0);
    final hasMatch = ctx
        .fromSource(FindingSource.shots)
        .any((f) => f.context(PlayStyleContext.match).attempts > 0);

    // Training data but no match data → can't judge under pressure.
    if (hasTraining && !hasMatch) {
      out.add(CoachInsightV2(
        id: 'need_match_data',
        topic: CoachTopic.dataGap,
        priority: CoachPriority.missingData,
        observationKey: 'coach_v2_obs_need_match_data',
        causeKey: 'coach_v2_cause_only_training',
        confidence: CoachConfidence.high,
        action: _actions.playMatch(),
      ));
    }
    return out;
  }
}
