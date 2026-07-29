// EPIC 02 — Statistics & Analytics — Phase 2: domain model.
//
// Time-window + direction types reused across Match / Equipment / Player
// / Session statistics. The dashboard and detail screens use the same
// period selectors so trend, chart, and summary data can be aligned.

enum AnalyticsPeriod {
  today,
  sevenDays,
  thirtyDays,
  allTime;

  String get id {
    switch (this) {
      case AnalyticsPeriod.today:
        return 'today';
      case AnalyticsPeriod.sevenDays:
        return '7d';
      case AnalyticsPeriod.thirtyDays:
        return '30d';
      case AnalyticsPeriod.allTime:
        return 'all';
    }
  }

  Duration get window {
    switch (this) {
      case AnalyticsPeriod.today:
        return const Duration(days: 1);
      case AnalyticsPeriod.sevenDays:
        return const Duration(days: 7);
      case AnalyticsPeriod.thirtyDays:
        return const Duration(days: 30);
      case AnalyticsPeriod.allTime:
        return const Duration(days: 365 * 50);
    }
  }

  String label(String languageCode) {
    final vi = languageCode == 'vi';
    switch (this) {
      case AnalyticsPeriod.today:
        return vi ? 'Hôm nay' : 'Today';
      case AnalyticsPeriod.sevenDays:
        return vi ? '7 ngày' : '7 days';
      case AnalyticsPeriod.thirtyDays:
        return vi ? '30 ngày' : '30 days';
      case AnalyticsPeriod.allTime:
        return vi ? 'Tất cả' : 'All time';
    }
  }
}

enum TrendDirection {
  unknown,
  flat,
  up,
  down;

  String label(String languageCode) {
    final vi = languageCode == 'vi';
    switch (this) {
      case TrendDirection.unknown:
        return vi ? 'Chưa rõ' : 'No data';
      case TrendDirection.flat:
        return vi ? 'Ổn định' : 'Flat';
      case TrendDirection.up:
        return vi ? 'Tăng' : 'Up';
      case TrendDirection.down:
        return vi ? 'Giảm' : 'Down';
    }
  }
}

/// Single time-series datum. Used by TrendChart / Trend computation.
class TrendPoint {
  const TrendPoint({required this.date, required this.value});
  final DateTime date;
  final double value;
}

/// Result of a trend computation. `direction` is `up` when the latest
/// value is meaningfully greater than the prior baseline, `down` when
/// lower, `flat` when within tolerance, `unknown` when there is
/// insufficient data.
class TrendSummary {
  const TrendSummary({
    required this.direction,
    required this.current,
    required this.previous,
    required this.delta,
    required this.points,
  });

  final TrendDirection direction;
  final double current;
  final double previous;
  final double delta;
  final List<TrendPoint> points;

  static TrendSummary empty() => const TrendSummary(
        direction: TrendDirection.unknown,
        current: 0,
        previous: 0,
        delta: 0,
        points: [],
      );
}