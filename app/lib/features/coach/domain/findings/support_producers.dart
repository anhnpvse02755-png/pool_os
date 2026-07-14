// Task 15 — Coach Intelligence V2, Layer 2: supporting finding producers.
//
// Each function turns already-computed, REAL data from an existing module into
// pure-fact [Finding]s. They are deliberately input-driven (the coordinator
// fetches from repos/providers and passes the data in) so they stay pure and
// unit-testable, and so this file has no Riverpod/Drift dependency. Fact-only:
// no wording, no severity, no priority, no action — Coach Brain decides those.
//
// NOTE: these intentionally consume only real measured numbers. The fabricated
// constants in StatisticsRepository.getAllStatistics and the proxy metrics in
// SkillEngineService are NOT used here (see plan Pitfalls).

import 'package:pool_os/features/coach/domain/findings/finding.dart';

/// Career win rate + accuracy (Phần: "what level am I / how am I doing").
/// [totalMatches]/[matchesWon] and [totalShots]/[shotsMade] are real counts.
class CareerFacts {
  final int totalMatches;
  final int matchesWon;
  final int totalShots;
  final int shotsMade;
  const CareerFacts({
    this.totalMatches = 0,
    this.matchesWon = 0,
    this.totalShots = 0,
    this.shotsMade = 0,
  });
}

List<Finding> produceCareerFindings(CareerFacts f) {
  final findings = <Finding>[];
  if (f.totalMatches > 0) {
    findings.add(Finding(
      metricId: 'career.win_rate',
      source: FindingSource.statistics,
      value: f.matchesWon / f.totalMatches,
      sampleSize: f.totalMatches,
      data: {'matchesWon': f.matchesWon, 'totalMatches': f.totalMatches},
    ));
  }
  if (f.totalShots > 0) {
    findings.add(Finding(
      metricId: 'career.accuracy',
      source: FindingSource.statistics,
      value: f.shotsMade / f.totalShots,
      sampleSize: f.totalShots,
      data: {'shotsMade': f.shotsMade, 'totalShots': f.totalShots},
    ));
  }
  return findings;
}

/// One persisted skill score (0–100 or 0–1 — passed through as-is with its
/// sample confidence). [category] is a skill category code; [trend] is the
/// stored trend string (fact, not a decision).
class SkillFact {
  final String category;
  final double score;
  final double confidence;
  final String? trend;
  const SkillFact({
    required this.category,
    required this.score,
    this.confidence = 0,
    this.trend,
  });
}

List<Finding> produceSkillFindings(List<SkillFact> skills) {
  return skills
      .map((s) => Finding(
            metricId: 'skill.${s.category}',
            source: FindingSource.skill,
            value: s.score,
            // Confidence 0–1 → a coarse sample proxy so Brain can weight it.
            sampleSize: (s.confidence * 100).round(),
            data: {'category': s.category, 'trend': s.trend},
          ))
      .toList();
}

/// Per-drill training success (inherently training context). [drillKey] is a
/// stable key; [category] a DrillCategory code.
class DrillFact {
  final String drillKey;
  final String category;
  final int attempts;
  final int successes;
  const DrillFact({
    required this.drillKey,
    required this.category,
    this.attempts = 0,
    this.successes = 0,
  });
}

List<Finding> produceTrainingFindings(List<DrillFact> drills) {
  // Aggregate by category so Brain sees "Stop Shot training success", not one
  // finding per run.
  final byCat = <String, List<int>>{}; // category -> [attempts, successes]
  for (final d in drills) {
    final acc = byCat.putIfAbsent(d.category, () => [0, 0]);
    acc[0] += d.attempts;
    acc[1] += d.successes;
  }
  return byCat.entries
      .where((e) => e.value[0] > 0)
      .map((e) => Finding(
            metricId: 'training.${e.key}',
            source: FindingSource.training,
            value: e.value[1] / e.value[0],
            sampleSize: e.value[0],
            byContext: {
              PlayStyleContext.training:
                  ContextValue(attempts: e.value[0], made: e.value[1]),
            },
            data: {'category': e.key},
          ))
      .toList();
}

/// Today's readiness (present/absent + score). Absence is itself a fact Brain
/// uses to prompt "log your readiness".
List<Finding> produceReadinessFindings({
  required bool loggedToday,
  int? overallScore,
  DateTime? observedAt,
}) {
  return [
    Finding(
      metricId: 'readiness.today',
      source: FindingSource.readiness,
      value: overallScore?.toDouble(),
      sampleSize: loggedToday ? 1 : 0,
      observedAt: observedAt,
      data: {'loggedToday': loggedToday},
    ),
  ];
}

/// Endurance profile numbers (fact-only).
List<Finding> produceEnduranceFindings({
  double? enduranceScore,
  int? averageDeclineRack,
  int sampleMatches = 0,
}) {
  if (enduranceScore == null && averageDeclineRack == null) return const [];
  return [
    Finding(
      metricId: 'endurance.profile',
      source: FindingSource.endurance,
      value: enduranceScore,
      sampleSize: sampleMatches,
      data: {'averageDeclineRack': averageDeclineRack},
    ),
  ];
}

/// Per-(cue,role) equipment success facts. [cueName]/[role] identify the pair.
class EquipmentFact {
  final String cueName;
  final String role;
  final int attempts;
  final int made;
  const EquipmentFact({
    required this.cueName,
    required this.role,
    this.attempts = 0,
    this.made = 0,
  });
}

List<Finding> produceEquipmentFindings(List<EquipmentFact> stats) {
  return stats
      .where((s) => s.attempts > 0)
      .map((s) => Finding(
            metricId: 'equipment.${s.cueName}.${s.role}',
            source: FindingSource.equipment,
            value: s.made / s.attempts,
            sampleSize: s.attempts,
            data: {'cueName': s.cueName, 'role': s.role},
          ))
      .toList();
}

/// Per-source data coverage — how much data exists for each area. This is the
/// raw material for Coach Understanding (NOT player level). One finding per
/// source with the count in [sampleSize].
List<Finding> produceCoverageFindings(Map<FindingSource, int> countsBySource) {
  return countsBySource.entries
      .map((e) => Finding(
            metricId: 'coverage.${e.key.name}',
            source: FindingSource.coverage,
            value: e.value.toDouble(),
            sampleSize: e.value,
            data: {'coveredSource': e.key.name},
          ))
      .toList();
}
