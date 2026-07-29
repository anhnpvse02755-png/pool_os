// EPIC 02 — Statistics & Analytics — Phase F: trend aggregation model.

import 'analytics_period.dart';

enum TrendBucket { daily, weekly, monthly, yearly }

extension TrendBucketX on TrendBucket {
  String get label => switch (this) {
        TrendBucket.daily => 'Daily',
        TrendBucket.weekly => 'Weekly',
        TrendBucket.monthly => 'Monthly',
        TrendBucket.yearly => 'Yearly',
      };

  Duration get span => switch (this) {
        TrendBucket.daily => const Duration(days: 1),
        TrendBucket.weekly => const Duration(days: 7),
        TrendBucket.monthly => const Duration(days: 30),
        TrendBucket.yearly => const Duration(days: 365),
      };

  String bucketKey(DateTime ts) {
    switch (this) {
      case TrendBucket.daily:
        return '${ts.year}-${ts.month.toString().padLeft(2, '0')}-${ts.day.toString().padLeft(2, '0')}';
      case TrendBucket.weekly:
        final jan4 = DateTime.utc(ts.year, 1, 4);
        final delta = ts.difference(jan4).inDays;
        final week = ((delta + jan4.weekday - 1) ~/ 7) + 1;
        return '${ts.year}-W${week.toString().padLeft(2, '0')}';
      case TrendBucket.monthly:
        return '${ts.year}-${ts.month.toString().padLeft(2, '0')}';
      case TrendBucket.yearly:
        return '${ts.year}';
    }
  }
}

class TrendPointValue {
  const TrendPointValue({
    required this.key,
    required this.date,
    required this.winRate,
    required this.trainingCount,
    required this.matchCount,
    required this.practiceFrequency,
  });

  final String key;
  final DateTime date;
  final double winRate;
  final int trainingCount;
  final int matchCount;
  final double practiceFrequency;
}

class TrendSummaryExt {
  const TrendSummaryExt({
    required this.period,
    required this.bucket,
    required this.points,
    required this.movingAverage,
  });

  final AnalyticsPeriod period;
  final TrendBucket bucket;
  final List<TrendPointValue> points;
  final List<double> movingAverage;

  static TrendSummaryExt empty(AnalyticsPeriod period, TrendBucket bucket) =>
      TrendSummaryExt(
        period: period,
        bucket: bucket,
        points: const [],
        movingAverage: const [],
      );
}

class ActivityHeatmap {
  const ActivityHeatmap({
    required this.cells,
    required this.maxCount,
  });

  /// `cells[weekday][hour]` = count of sessions in that weekday-hour cell
  /// over the period.
  final List<List<int>> cells;
  final int maxCount;

  static const ActivityHeatmap empty = ActivityHeatmap(
    cells: [
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    ],
    maxCount: 0,
  );

  static ActivityHeatmap compute({
    required List<DateTime> timestamps,
  }) {
    if (timestamps.isEmpty) return empty;
    final cells = List.generate(7, (_) => List<int>.filled(24, 0));
    var maxCount = 0;
    for (final ts in timestamps) {
      final weekday = ts.weekday % 7;
      final hour = ts.hour;
      cells[weekday][hour] += 1;
      if (cells[weekday][hour] > maxCount) {
        maxCount = cells[weekday][hour];
      }
    }
    return ActivityHeatmap(cells: cells, maxCount: maxCount);
  }
}
