import 'package:pool_os/features/training_center/domain/models/training_center_models.dart';

// Task 09 — Phần 4 Progress. Pure calculator: takes recorded [DrillRun]s and
// produces before/after success-rate comparisons. No AI, no recommendation,
// no fabricated data — a drill with no history simply does not appear, and a
// comparison without both windows reports hasComparison == false.
class ProgressCalculator {
  const ProgressCalculator();

  /// Splits each drill's runs into an "earlier" and "later" window at [now]
  /// minus [windowDays] and compares their success rates. Default window = 30
  /// days, so "previous" ≈ last month, "current" ≈ this month (matches the
  /// spec's Long Pot 58% → 71% example).
  ///
  /// Runs are grouped by [DrillRun.drillKey] so a built-in drill and a custom
  /// drill never merge. Only drills with at least one attempt in either window
  /// are returned, sorted by largest absolute change first (biggest movers on
  /// top). Zero-attempt windows yield rate 0.0 but flag hasComparison false.
  List<DrillProgress> byDrill(
    List<DrillRun> runs, {
    DateTime? now,
    int windowDays = 30,
  }) {
    final reference = now ?? DateTime.now();
    final cutoff = reference.subtract(Duration(days: windowDays));

    final byKey = <String, List<DrillRun>>{};
    for (final run in runs) {
      if (run.drillKey.isEmpty) continue;
      byKey.putIfAbsent(run.drillKey, () => []).add(run);
    }

    final result = <DrillProgress>[];
    byKey.forEach((key, group) {
      final label = group
          .firstWhere((r) => r.drillName.isNotEmpty,
              orElse: () => group.first)
          .drillName;
      final earlier = group.where((r) => r.createdAt.isBefore(cutoff)).toList();
      final later = group.where((r) => !r.createdAt.isBefore(cutoff)).toList();

      final prev = _windowRate(earlier);
      final curr = _windowRate(later);

      // Skip drills with no attempts at all (nothing to show).
      if (prev.$1 == 0 && curr.$1 == 0) return;

      result.add(DrillProgress(
        label: label,
        drillKey: key,
        previousRate: prev.$2,
        currentRate: curr.$2,
        previousAttempts: prev.$1,
        currentAttempts: curr.$1,
      ));
    });

    result.sort((a, b) => b.deltaPoints.abs().compareTo(a.deltaPoints.abs()));
    return result;
  }

  /// Same comparison but aggregated by category instead of individual drill —
  /// used for a higher-level progress view.
  List<DrillProgress> byCategory(
    List<DrillRun> runs, {
    DateTime? now,
    int windowDays = 30,
  }) {
    final reference = now ?? DateTime.now();
    final cutoff = reference.subtract(Duration(days: windowDays));

    final byCat = <String, List<DrillRun>>{};
    for (final run in runs) {
      if (run.category.isEmpty) continue;
      byCat.putIfAbsent(run.category, () => []).add(run);
    }

    final result = <DrillProgress>[];
    byCat.forEach((cat, group) {
      final earlier = group.where((r) => r.createdAt.isBefore(cutoff)).toList();
      final later = group.where((r) => !r.createdAt.isBefore(cutoff)).toList();
      final prev = _windowRate(earlier);
      final curr = _windowRate(later);
      if (prev.$1 == 0 && curr.$1 == 0) return;
      result.add(DrillProgress(
        label: cat,
        drillKey: cat,
        previousRate: prev.$2,
        currentRate: curr.$2,
        previousAttempts: prev.$1,
        currentAttempts: curr.$1,
      ));
    });

    result.sort((a, b) => b.deltaPoints.abs().compareTo(a.deltaPoints.abs()));
    return result;
  }

  /// Returns (totalAttempts, successRate) for one window. Rate is 0.0 when the
  /// window is empty — never NaN, never fabricated.
  (int, double) _windowRate(List<DrillRun> window) {
    var attempts = 0;
    var successes = 0;
    for (final r in window) {
      attempts += r.attempts;
      successes += r.successes;
    }
    final rate = attempts == 0 ? 0.0 : successes / attempts;
    return (attempts, rate);
  }
}
