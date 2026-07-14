// Task 15 — Coach Intelligence V2, Layer 2.5: Coach Context (Derived Coach State).
//
// This is NOT "Coach memory". Coach owns no persistent state. CoachContext is an
// immutable, in-memory snapshot rebuilt FRESH from the finding producers on every
// run. Its job is to let Coach Brain understand the player's CURRENT state and
// TRAJECTORY (improving / stable / declining) — derived on the fly by comparing
// the recent-vs-prior windows already carried inside each Finding's `data`. No
// table, no migration, no remembering "what I said yesterday".

import 'package:pool_os/features/coach/domain/findings/finding.dart';

/// Direction of change for a metric over time. A fact derived from windowed
/// findings, not a judgement — Coach Brain decides what a direction means.
enum TrajectoryDirection { improving, stable, declining, unknown }

/// Per-metric trajectory derived by comparing the recent vs prior windows that
/// [ShotContextProducer] stamped into `finding.data`. Fact-only.
class MetricTrajectory {
  final String metricId;
  final double? recentRate;
  final double? priorRate;
  final int recentSample;
  final int priorSample;

  const MetricTrajectory({
    required this.metricId,
    this.recentRate,
    this.priorRate,
    this.recentSample = 0,
    this.priorSample = 0,
  });

  /// Signed change in rate (recent − prior). Null when either window is empty.
  double? get delta => (recentRate != null && priorRate != null)
      ? recentRate! - priorRate!
      : null;

  /// Direction with a small dead-band so noise isn't read as movement. Needs a
  /// minimum sample in BOTH windows, else `unknown` (never a fabricated trend).
  TrajectoryDirection direction({
    int minSample = 5,
    double deadBand = 0.05,
  }) {
    if (recentSample < minSample || priorSample < minSample) {
      return TrajectoryDirection.unknown;
    }
    final d = delta;
    if (d == null) return TrajectoryDirection.unknown;
    if (d > deadBand) return TrajectoryDirection.improving;
    if (d < -deadBand) return TrajectoryDirection.declining;
    return TrajectoryDirection.stable;
  }
}

/// The whole trajectory view: one [MetricTrajectory] per metric that carried a
/// recent/prior split. Built purely from findings.
class TrajectoryView {
  final Map<String, MetricTrajectory> byMetric;

  const TrajectoryView(this.byMetric);

  MetricTrajectory? forMetric(String metricId) => byMetric[metricId];

  /// Build from any findings that stamped recent/prior counts in `data`
  /// (currently the shot-context findings). Findings without that split are
  /// skipped — trajectory is only claimed where the data supports it.
  factory TrajectoryView.fromFindings(List<Finding> findings) {
    final map = <String, MetricTrajectory>{};
    for (final f in findings) {
      final ra = f.data['recentAttempts'];
      final pa = f.data['priorAttempts'];
      if (ra is! int || pa is! int) continue;
      if (ra == 0 && pa == 0) continue;
      final rm = f.data['recentMade'];
      final pm = f.data['priorMade'];
      map[f.metricId] = MetricTrajectory(
        metricId: f.metricId,
        recentRate: ra > 0 && rm is int ? rm / ra : null,
        priorRate: pa > 0 && pm is int ? pm / pa : null,
        recentSample: ra,
        priorSample: pa,
      );
    }
    return TrajectoryView(map);
  }
}

/// How much data exists per source — the raw material for Coach Understanding
/// (NOT player level). Built from the coverage findings.
class CoverageView {
  /// source → item count (matches, shots, drills, …).
  final Map<FindingSource, int> counts;

  const CoverageView(this.counts);

  int countFor(FindingSource s) => counts[s] ?? 0;

  bool hasAny(FindingSource s) => countFor(s) > 0;

  /// Sources with zero data — used by Brain to prompt "let's get more data".
  List<FindingSource> get missing =>
      counts.entries.where((e) => e.value == 0).map((e) => e.key).toList();

  factory CoverageView.fromFindings(List<Finding> findings) {
    final counts = <FindingSource, int>{};
    for (final f in findings) {
      if (f.source != FindingSource.coverage) continue;
      final name = f.data['coveredSource'];
      if (name is! String) continue;
      final src = FindingSource.values.firstWhere(
        (s) => s.name == name,
        orElse: () => FindingSource.coverage,
      );
      counts[src] = f.sampleSize;
    }
    return CoverageView(counts);
  }
}

/// The derived, in-memory snapshot Coach Brain consumes. Rebuilt every run;
/// never persisted. Brain reads THIS, never raw Drift rows.
class CoachContext {
  final List<Finding> findings;
  final TrajectoryView trajectory;
  final CoverageView coverage;
  final DateTime builtAt;

  const CoachContext({
    required this.findings,
    required this.trajectory,
    required this.coverage,
    required this.builtAt,
  });

  /// Assemble a context from a flat list of findings gathered by the producers.
  factory CoachContext.fromFindings(List<Finding> findings, {DateTime? now}) {
    return CoachContext(
      findings: List.unmodifiable(findings),
      trajectory: TrajectoryView.fromFindings(findings),
      coverage: CoverageView.fromFindings(findings),
      builtAt: now ?? DateTime.now(),
    );
  }

  /// Findings from one source (convenience for Brain services).
  List<Finding> fromSource(FindingSource source) =>
      findings.where((f) => f.source == source).toList();

  /// Whether the player has any recorded data at all (drives onboarding feed).
  bool get isEmpty => findings.every((f) =>
      f.source == FindingSource.coverage
          ? f.sampleSize == 0
          : f.sampleSize == 0 && !f.hasContextData);
}
