// Task 15 — Coach Intelligence V2, Layer 1: Findings (PURE FACTS).
//
// A Finding is a measured fact about the player, produced by a finding-producer
// that reads already-persisted domain data. It carries ONLY data — a metric id,
// a value, a sample size, an optional per-context breakdown, and the time it was
// observed. It has NO wording, NO severity, NO priority, NO recommendation and
// NO next action. Those are decisions, and decisions belong exclusively to Coach
// Brain (Layer 3). This file therefore has zero dependency on the Feed model.
//
// This separation is the core of the Task 15 architecture: modules state facts,
// Coach Brain decides what they mean. Keeping findings decision-free is what lets
// the Brain be the single source of priority, grouping, confidence and action.

/// Which module/data-area a [Finding] came from. Used by Coach Brain to group,
/// weight and route findings — never for display text.
enum FindingSource {
  shots,
  statistics,
  skill,
  training,
  equipment,
  readiness,
  form,
  endurance,
  matchContext,
  ghost,
  coverage,
}

/// The play context a measurement was taken in. The same skill can behave very
/// differently across these (e.g. strong in training, weaker under match
/// pressure) — Coach Brain reads that split to decide confidence and cause.
enum PlayStyleContext { training, match, ghost }

/// A made/attempts tally for one [PlayStyleContext]. Fact-only.
class ContextValue {
  final int attempts;
  final int made;

  const ContextValue({this.attempts = 0, this.made = 0});

  /// Success rate 0.0–1.0; zero attempts → 0.0 (never a fabricated value).
  double get rate => attempts == 0 ? 0.0 : made / attempts;

  ContextValue add({required bool made, int count = 1}) => ContextValue(
        attempts: attempts + count,
        made: this.made + (made ? count : 0),
      );
}

/// A single measured fact. Immutable and decision-free.
///
/// [metricId] is a stable identifier (e.g. `shot.stop_shot`, `career.win_rate`,
/// `readiness.today`) that Coach Brain maps to knowledge/actions — it is NOT a
/// display string. [value] is the headline number when the fact is scalar
/// (a win rate, a skill score); [byContext] holds the training/match/ghost split
/// when the fact is context-aware. [sampleSize] lets Brain decide how much to
/// trust the fact. [observedAt] lets Brain derive trajectory (past vs now)
/// WITHOUT Coach ever storing anything. [data] carries any extra raw numerics a
/// producer measured (still fact-only, e.g. `{'declineRack': 7}`).
class Finding {
  final String metricId;
  final FindingSource source;
  final double? value;
  final int sampleSize;
  final Map<PlayStyleContext, ContextValue> byContext;
  final DateTime? observedAt;
  final Map<String, Object?> data;

  const Finding({
    required this.metricId,
    required this.source,
    this.value,
    this.sampleSize = 0,
    this.byContext = const {},
    this.observedAt,
    this.data = const {},
  });

  /// Total attempts across every recorded context (0 when not context-based).
  int get totalContextAttempts =>
      byContext.values.fold(0, (sum, c) => sum + c.attempts);

  /// Convenience: the [ContextValue] for [context], or an empty tally.
  ContextValue context(PlayStyleContext context) =>
      byContext[context] ?? const ContextValue();

  /// Whether this fact has any measured context data at all.
  bool get hasContextData => byContext.values.any((c) => c.attempts > 0);
}
