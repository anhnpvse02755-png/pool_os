// EPIC 02 — Statistics & Analytics — Revision 4.
//
// Performance calculator. Pure-Dart computation over already-loaded
// match / session / equipment records. Emits a `PerformanceSnapshot`
// that the dashboard + Statistics hub render.

import '../../../equipment/domain/models/cue.dart';
import '../../../equipment/domain/equipment_performance_projection.dart';
import '../../../match/domain/models/match.dart';
import '../../../session/domain/models/session.dart';
import '../models/analytics_period.dart';
import '../models/performance_snapshots.dart';
import '../aggregators/match_statistics_aggregator.dart';

class PerformanceCalculator {
  const PerformanceCalculator();

  PerformanceSnapshot calculate({
    required List<Match> matches,
    required List<Session> sessions,
    required List<EquipmentPerformanceProjection> projections,
    required List<Cue> cues,
    required AnalyticsPeriod period,
    required DateTime now,
    required String activePlayerName,
  }) {
    if (matches.isEmpty && sessions.isEmpty) {
      return PerformanceSnapshot.empty(period);
    }

    final filtered = filterByPeriod<Match>(
      items: matches,
      timestamp: (m) => m.startTime ?? m.endTime ?? now,
      period: period,
      now: now,
    );

    final winRateOverTime = _winRateOverTime(
      matches: filtered,
      activePlayerName: activePlayerName,
    );

    final equipmentEffectiveness = _equipmentEffectiveness(projections);

    final improvementPct = _improvementPct(winRateOverTime);
    final hotStreak = _hotStreak(matches: filtered, activePlayerName: activePlayerName, now: now);
    final coldStreak = _coldStreak(matches: filtered, activePlayerName: activePlayerName, now: now);
    final consistency = _consistency(winRateOverTime);

    final filteredSessions = filterByPeriod<Session>(
      items: sessions,
      timestamp: (s) => s.startedAt,
      period: period,
      now: now,
    );
    final sessionEfficiency = _sessionEfficiency(filteredSessions, filtered);
    final practiceVsMatchRatio = _practiceVsMatchRatio(filteredSessions);

    final days = period.window.inDays.clamp(1, 365).toInt();
    final activity =
        (filteredSessions.length / days).clamp(0.0, 1.0).toDouble();

    return PerformanceSnapshot(
      period: period,
      winRateOverTime: winRateOverTime,
      equipmentEffectiveness: equipmentEffectiveness,
      improvementPct: improvementPct,
      sessionEfficiency: sessionEfficiency,
      practiceVsMatchRatio: practiceVsMatchRatio,
      hotStreak: hotStreak,
      coldStreak: coldStreak,
      consistency: consistency,
      activity: activity,
    );
  }

  List<WinRateOverTimePoint> _winRateOverTime({
    required List<Match> matches,
    required String activePlayerName,
  }) {
    if (matches.isEmpty) return const [];
    final sorted = [...matches]..sort((a, b) {
        final at = a.startTime ?? a.endTime ?? DateTime(1970);
        final bt = b.startTime ?? b.endTime ?? DateTime(1970);
        return at.compareTo(bt);
      });
    final buckets = <DateTime, _Bucket>{};
    for (final m in sorted) {
      final ts = m.startTime ?? m.endTime ?? DateTime(1970);
      final key = DateTime(ts.year, ts.month, ts.day);
      final bucket = buckets.putIfAbsent(key, () => _Bucket());
      bucket.total++;
      final won = (m.winner ?? '').trim().toLowerCase() ==
          activePlayerName.trim().toLowerCase();
      if (won) bucket.wins++;
    }
    final keys = buckets.keys.toList()..sort();
    return [
      for (final k in keys)
        WinRateOverTimePoint(
          date: k,
          winRate: buckets[k]!.total == 0 ? 0 : buckets[k]!.wins / buckets[k]!.total,
        ),
    ];
  }

  List<EquipmentEffectiveness> _equipmentEffectiveness(
    List<EquipmentPerformanceProjection> projections,
  ) {
    return [
      for (final p in projections)
        EquipmentEffectiveness(
          equipmentId: p.equipmentId.toString(),
          usageCount: p.totalMatches,
          winRate: p.matchWinRate,
        ),
    ]..sort((a, b) => b.winRate.compareTo(a.winRate));
  }

  double _improvementPct(List<WinRateOverTimePoint> points) {
    if (points.length < 2) return 0;
    final half = points.length ~/ 2;
    final prev = points.sublist(0, half);
    final cur = points.sublist(half);
    final prevAvg = prev.map((p) => p.winRate).reduce((a, b) => a + b) /
        prev.length;
    final curAvg = cur.map((p) => p.winRate).reduce((a, b) => a + b) /
        cur.length;
    if (prevAvg == 0) return 0;
    return ((curAvg - prevAvg) / prevAvg).clamp(-1.0, 1.0);
  }

  int _hotStreak({
    required List<Match> matches,
    required String activePlayerName,
    required DateTime now,
  }) {
    if (matches.isEmpty) return 0;
    final sorted = [...matches]..sort((a, b) {
        final at = a.startTime ?? a.endTime ?? now;
        final bt = b.startTime ?? b.endTime ?? now;
        return bt.compareTo(at);
      });
    var streak = 0;
    for (final m in sorted) {
      final won = (m.winner ?? '').trim().toLowerCase() ==
          activePlayerName.trim().toLowerCase();
      if (won) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  int _coldStreak({
    required List<Match> matches,
    required String activePlayerName,
    required DateTime now,
  }) {
    if (matches.isEmpty) return 0;
    final sorted = [...matches]..sort((a, b) {
        final at = a.startTime ?? a.endTime ?? now;
        final bt = b.startTime ?? b.endTime ?? now;
        return bt.compareTo(at);
      });
    var streak = 0;
    for (final m in sorted) {
      final won = (m.winner ?? '').trim().toLowerCase() ==
          activePlayerName.trim().toLowerCase();
      if (!won) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  double _consistency(List<WinRateOverTimePoint> points) {
    if (points.length < 2) return 0;
    final values = points.map((p) => p.winRate).toList();
    final mean = values.reduce((a, b) => a + b) / values.length;
    var sum = 0.0;
    for (final v in values) {
      sum += (v - mean) * (v - mean);
    }
    final variance = sum / values.length;
    return (1 - variance.clamp(0.0, 1.0));
  }

  double _sessionEfficiency(List<Session> sessions, List<Match> matches) {
    if (sessions.isEmpty) return 0;
    final totalMinutes = sessions.fold<int>(
      0,
      (acc, s) => acc + s.duration.inMinutes,
    );
    if (totalMinutes == 0) return 0;
    return matches.length / totalMinutes * 60;
  }

  double _practiceVsMatchRatio(List<Session> sessions) {
    var match = 0;
    var practice = 0;
    for (final s in sessions) {
      if (s.sessionType == 'match') {
        match++;
      } else {
        practice++;
      }
    }
    final total = match + practice;
    if (total == 0) return 0;
    return practice / total;
  }
}

class _Bucket {
  int total = 0;
  int wins = 0;
}
