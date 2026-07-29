// EPIC 02 — Statistics & Analytics — Phase F: trend calculator.
//
// Pure-Dart aggregation of historical events into bucketed trend
// summaries. Supports Daily / Weekly / Monthly / Yearly buckets
// plus a moving-average series and an activity heatmap.

import '../../../match/domain/models/match.dart';
import '../../../session/domain/models/session.dart';
import '../models/analytics_period.dart';
import '../models/trend_aggregations.dart';

class TrendCalculator {
  const TrendCalculator();

  TrendSummaryExt aggregate({
    required List<Match> matches,
    required List<Session> sessions,
    required TrendBucket bucket,
    required AnalyticsPeriod period,
    required DateTime now,
    required String activePlayerName,
  }) {
    if (matches.isEmpty && sessions.isEmpty) {
      return TrendSummaryExt.empty(period, bucket);
    }
    final lower = activePlayerName.trim().toLowerCase();

    final filteredMatches = matches
        .where((m) =>
            (m.startTime ?? m.endTime ?? now)
                .isAfter(now.subtract(period.window)) ||
            (m.startTime ?? m.endTime ?? now)
                .isAtSameMomentAs(now.subtract(period.window)))
        .toList();
    final filteredSessions = sessions
        .where((s) =>
            s.startedAt.isAfter(now.subtract(period.window)) ||
            s.startedAt.isAtSameMomentAs(now.subtract(period.window)))
        .toList();

    final keys = <String>{};
    for (final m in filteredMatches) {
      keys.add(bucket.bucketKey(m.startTime ?? m.endTime ?? now));
    }
    for (final s in filteredSessions) {
      keys.add(bucket.bucketKey(s.startedAt));
    }

    final orderedKeys = keys.toList()..sort();
    final points = <TrendPointValue>[];
    for (final k in orderedKeys) {
      final bucketMatches = filteredMatches
          .where((m) => bucket.bucketKey(m.startTime ?? m.endTime ?? now) == k)
          .toList();
      final bucketSessions = filteredSessions
          .where((s) => bucket.bucketKey(s.startedAt) == k)
          .toList();
      var wins = 0;
      for (final m in bucketMatches) {
        if ((m.winner ?? '').trim().toLowerCase() == lower) wins++;
      }
      final total = bucketMatches.length;
      final date = _approximateDate(k);
      final trainingCount = bucketSessions
          .where((s) => s.sessionType != 'match')
          .length;
      final matchCount = bucketSessions
              .where((s) => s.sessionType == 'match')
              .length +
          bucketMatches.length;
      final practiceFrequency =
          total == 0 ? 0.0 : (total - wins).toDouble() / total;
      points.add(TrendPointValue(
        key: k,
        date: date,
        winRate: total == 0 ? 0 : wins / total,
        trainingCount: trainingCount,
        matchCount: matchCount,
        practiceFrequency: practiceFrequency,
      ));
    }

    final movingAverage = _movingAverage(
      points.map((p) => p.winRate).toList(),
      window: 7,
    );

    return TrendSummaryExt(
      period: period,
      bucket: bucket,
      points: points,
      movingAverage: movingAverage,
    );
  }

  DateTime _approximateDate(String key) {
    final parts = key.split('-');
    if (parts.length >= 3) {
      final year = int.tryParse(parts[0]) ?? 1970;
      final month = int.tryParse(parts[1]) ?? 1;
      final day = int.tryParse(parts[2]) ?? 1;
      return DateTime(year, month, day);
    } else if (parts.length == 2) {
      final year = int.tryParse(parts[0]) ?? 1970;
      final month = int.tryParse(parts[1]) ?? 1;
      return DateTime(year, month, 1);
    } else if (parts.length == 1) {
      final year = int.tryParse(parts[0]) ?? 1970;
      return DateTime(year, 1, 1);
    }
    return DateTime(1970);
  }

  List<double> _movingAverage(List<double> values, {required int window}) {
    if (values.isEmpty) return const [];
    final out = <double>[];
    for (var i = 0; i < values.length; i++) {
      final start = (i - window + 1).clamp(0, values.length);
      final slice = values.sublist(start, i + 1);
      final avg = slice.reduce((a, b) => a + b) / slice.length;
      out.add(avg);
    }
    return out;
  }
}
