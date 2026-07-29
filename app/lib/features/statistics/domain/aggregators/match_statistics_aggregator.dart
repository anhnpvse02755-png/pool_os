// EPIC 02 — Statistics & Analytics — Phase 3: aggregators.
//
// Pure-Dart aggregators. Each aggregator accepts records already
// loaded from the existing repositories, applies the period window,
// and emits a snapshot. The aggregators do NOT touch the database
// directly — the calling layer (the analytics services / Riverpod
// providers) loads records and passes them in. This keeps the
// aggregator unit-testable without a database fixture.

import '../../../match/domain/models/match.dart';
import '../../../session/domain/models/session.dart';
import '../../../equipment/domain/models/cue.dart';
import '../../../equipment/domain/equipment_performance_projection.dart';
import '../models/analytics_period.dart';
import '../models/analytics_snapshots.dart';

/// Filter helper: returns the subset of [items] whose `timestamp`
/// falls within [period] relative to [now].
List<T> filterByPeriod<T>({
  required List<T> items,
  required DateTime Function(T) timestamp,
  required AnalyticsPeriod period,
  required DateTime now,
}) {
  final cutoff = now.subtract(period.window);
  return items.where((item) {
    final ts = timestamp(item);
    return ts.isAfter(cutoff) || ts.isAtSameMomentAs(cutoff);
  }).toList();
}

class MatchStatisticsAggregator {
  const MatchStatisticsAggregator();

  MatchStatisticsSnapshot aggregate({
    required List<Match> matches,
    required AnalyticsPeriod period,
    required DateTime now,
    required String activePlayerName,
  }) {
    if (matches.isEmpty) {
      return MatchStatisticsSnapshot.empty(period);
    }
    final filtered = filterByPeriod<Match>(
      items: matches,
      timestamp: (m) => m.startTime ?? m.endTime ?? now,
      period: period,
      now: now,
    );
    if (filtered.isEmpty) {
      return MatchStatisticsSnapshot.empty(period);
    }

    var wins = 0;
    var losses = 0;
    final distribution = <String, int>{
      'one_match': filtered.length,
    };
    final sorted = [...filtered]
      ..sort((a, b) => (b.startTime ?? b.endTime ?? now)
          .compareTo(a.startTime ?? a.endTime ?? now));
    final recentIds = sorted
        .take(5)
        .map((m) => m.id.toString())
        .toList();

    for (final m in filtered) {
      final isWin = (m.winner ?? '').trim().toLowerCase() ==
          activePlayerName.trim().toLowerCase();
      if (isWin) {
        wins++;
      } else if ((m.winner ?? '').trim().isNotEmpty) {
        losses++;
      }
    }

    final streak = _currentStreak(
      matches: filtered,
      activePlayerName: activePlayerName,
      now: now,
    );

    final trend = _buildTrend(
      values: sorted
          .map((m) => (m.winner ?? '').trim().toLowerCase() ==
                  activePlayerName.trim().toLowerCase()
              ? 1.0
              : 0.0)
          .toList(),
    );

    final totalMatches = filtered.length;
    final winRate = totalMatches == 0 ? 0.0 : wins / totalMatches;

    return MatchStatisticsSnapshot(
      period: period,
      totalMatches: totalMatches,
      wins: wins,
      losses: losses,
      winRate: winRate,
      averageRacks: 0,
      currentStreak: streak,
      distribution: distribution,
      trend: trend,
      recentMatchIds: recentIds,
    );
  }

  int _currentStreak({
    required List<Match> matches,
    required String activePlayerName,
    required DateTime now,
  }) {
    if (matches.isEmpty) return 0;
    final sorted = [...matches]
      ..sort((a, b) => (b.startTime ?? b.endTime ?? now)
          .compareTo(a.startTime ?? a.endTime ?? now));
    var streak = 0;
    var first = true;
    for (final m in sorted) {
      final won = (m.winner ?? '').trim().toLowerCase() ==
          activePlayerName.trim().toLowerCase();
      if (first) {
        if (!won) return 0;
        streak = 1;
        first = false;
        continue;
      }
      if (won) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  TrendSummary _buildTrend({required List<double> values}) {
    if (values.length < 2) {
      return TrendSummary.empty();
    }
    // `values` is sorted newest-first (the aggregator's `sorted`
    // list). Split into "current = first half (newer)" and
    // "previous = second half (older)".
    final half = values.length ~/ 2;
    final current = values.sublist(0, half);
    final previous = values.sublist(half);
    final prevAvg = previous.reduce((a, b) => a + b) / previous.length;
    final curAvg = current.reduce((a, b) => a + b) / current.length;
    final delta = curAvg - prevAvg;
    final direction = delta > 0.05
        ? TrendDirection.up
        : delta < -0.05
            ? TrendDirection.down
            : TrendDirection.flat;
    final points = <TrendPoint>[
      for (var i = 0; i < values.length; i++)
        TrendPoint(
            date: DateTime(0, 1, 1).add(Duration(days: i)),
            value: values[i]),
    ];
    return TrendSummary(
      direction: direction,
      current: curAvg,
      previous: prevAvg,
      delta: delta,
      points: points,
    );
  }
}

class SessionStatisticsAggregator {
  const SessionStatisticsAggregator();

  SessionStatisticsSnapshot aggregate({
    required List<Session> sessions,
    required AnalyticsPeriod period,
    required DateTime now,
  }) {
    if (sessions.isEmpty) {
      return SessionStatisticsSnapshot.empty(period);
    }
    final filtered = filterByPeriod<Session>(
      items: sessions,
      timestamp: (s) => s.startedAt,
      period: period,
      now: now,
    );
    if (filtered.isEmpty) {
      return SessionStatisticsSnapshot.empty(period);
    }

    final durations = <Duration>[];
    var matchSessions = 0;
    final history = <SessionHistoryEntry>[];
    for (final s in filtered) {
      final d = s.duration;
      durations.add(d);
      if (s.sessionType == SessionTypes.match) {
        matchSessions++;
      }
      history.add(SessionHistoryEntry(
        sessionId: s.id?.toString() ?? '',
        startedAt: s.startedAt,
        duration: d,
        trainingVolume: 0,
        matchVolume: 1,
      ));
    }
    final totalDuration =
        durations.fold<Duration>(Duration.zero, (a, b) => a + b);
    final averageDuration = Duration(
      microseconds: durations.isEmpty
          ? 0
          : totalDuration.inMicroseconds ~/ durations.length,
    );

    history.sort((a, b) => b.startedAt.compareTo(a.startedAt));

    return SessionStatisticsSnapshot(
      period: period,
      totalSessions: filtered.length,
      totalDuration: totalDuration,
      averageDuration: averageDuration,
      trainingVolume: filtered.length - matchSessions,
      matchVolume: matchSessions,
      history: history,
    );
  }
}

class EquipmentStatisticsAggregator {
  const EquipmentStatisticsAggregator();

  EquipmentStatisticsSnapshot aggregate({
    required List<Cue> cues,
    required List<EquipmentPerformanceProjection> projections,
    required AnalyticsPeriod period,
    required DateTime now,
  }) {
    if (projections.isEmpty) {
      return EquipmentStatisticsSnapshot.empty(period);
    }
    final usageFrequency = <String, int>{};
    final winRate = <String, double>{};
    final trainingSuccess = <String, double>{};
    final matchSuccess = <String, double>{};

    for (final p in projections) {
      usageFrequency[p.equipmentId.toString()] = p.totalMatches;
      winRate[p.equipmentId.toString()] = p.matchWinRate;
      trainingSuccess[p.equipmentId.toString()] = p.trainingSuccessRate;
      matchSuccess[p.equipmentId.toString()] = p.matchWinRate;
    }

    final ranked = projections
        .map((p) => EquipmentRankingEntry(
              equipmentId: p.equipmentId.toString(),
              usageCount: p.totalMatches,
              score: _scoreFor(p),
            ))
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    return EquipmentStatisticsSnapshot(
      period: period,
      usageFrequency: usageFrequency,
      winRateByEquipment: winRate,
      trainingSuccessByEquipment: trainingSuccess,
      matchSuccessByEquipment: matchSuccess,
      ranked: ranked,
    );
  }

  double _scoreFor(EquipmentPerformanceProjection p) {
    final usage = p.totalMatches;
    final wr = p.matchWinRate;
    final ts = p.trainingSuccessRate;
    final ms = p.matchWinRate;
    return usage * (0.4 * wr + 0.3 * ts + 0.3 * ms);
  }
}

class PlayerStatisticsAggregator {
  const PlayerStatisticsAggregator();

  PlayerStatisticsSnapshot aggregate({
    required List<Match> matches,
    required AnalyticsPeriod period,
    required DateTime now,
    required String activePlayerName,
  }) {
    if (matches.isEmpty) {
      return PlayerStatisticsSnapshot.empty(period);
    }
    final filtered = filterByPeriod<Match>(
      items: matches,
      timestamp: (m) => m.startTime ?? m.endTime ?? now,
      period: period,
      now: now,
    );
    var wins = 0;
    final opponents = <String, int>{};
    final recent = <PlayerActivityEntry>[];
    for (final m in filtered) {
      final isWin = (m.winner ?? '').trim().toLowerCase() ==
          activePlayerName.trim().toLowerCase();
      if (isWin) wins++;
      final opp = (m.opponent ?? '').trim();
      if (opp.isNotEmpty) {
        opponents[opp] = (opponents[opp] ?? 0) + 1;
      }
      recent.add(PlayerActivityEntry(
        date: m.startTime ?? m.endTime ?? now,
        kind: m.result ?? 'completed',
        title: opp.isEmpty ? 'Match' : 'vs $opp',
      ));
    }
    recent.sort((a, b) => b.date.compareTo(a.date));

    final trendValues = filtered
        .map((m) => (m.winner ?? '').trim().toLowerCase() ==
                activePlayerName.trim().toLowerCase()
            ? 1.0
            : 0.0)
        .toList();
    final trend = _simpleTrend(trendValues);

    final winRate = filtered.isEmpty ? 0.0 : wins / filtered.length;

    return PlayerStatisticsSnapshot(
      period: period,
      matchCount: filtered.length,
      winRate: winRate,
      opponentHistory: opponents,
      recentActivity: recent.take(10).toList(),
      performanceTrend: trend,
    );
  }

  TrendSummary _simpleTrend(List<double> values) {
    if (values.length < 2) return TrendSummary.empty();
    final half = values.length ~/ 2;
    final prev = values.sublist(0, half).reduce((a, b) => a + b) / half;
    final cur = values.sublist(half).reduce((a, b) => a + b) /
        (values.length - half);
    final delta = cur - prev;
    final dir = delta > 0.05
        ? TrendDirection.up
        : delta < -0.05
            ? TrendDirection.down
            : TrendDirection.flat;
    return TrendSummary(
      direction: dir,
      current: cur,
      previous: prev,
      delta: delta,
      points: [
        for (var i = 0; i < values.length; i++)
          TrendPoint(
              date: DateTime(0, 1, 1).add(Duration(days: i)),
              value: values[i]),
      ],
    );
  }
}

class DashboardAggregator {
  const DashboardAggregator({
    required this.match,
    required this.equipment,
    required this.session,
  });

  final MatchStatisticsAggregator match;
  final EquipmentStatisticsAggregator equipment;
  final SessionStatisticsAggregator session;

  DashboardSnapshot aggregate({
    required List<Match> matches,
    required List<Session> sessions,
    required List<Cue> cues,
    required List<EquipmentPerformanceProjection> projections,
    required AnalyticsPeriod period,
    required DateTime now,
    required String activePlayerName,
  }) {
    final m = match.aggregate(
        matches: matches,
        period: period,
        now: now,
        activePlayerName: activePlayerName);
    final s =
        session.aggregate(sessions: sessions, period: period, now: now);
    equipment.aggregate(
        cues: cues,
        projections: projections,
        period: period,
        now: now);

    final equipmentUsed = projections.isEmpty
        ? 0
        : projections
            .where((p) => p.totalMatches > 0 || p.totalTrainingSessions > 0)
            .length;

    final recentActivity = <DashboardActivityEntry>[];
    for (final sess in sessions.take(5)) {
      recentActivity.add(DashboardActivityEntry(
        date: sess.startedAt,
        title: 'Session',
        subtitle: sess.location ?? sess.sessionType,
      ));
    }
    recentActivity.sort((a, b) => b.date.compareTo(a.date));

    return DashboardSnapshot(
      period: period,
      totalMatches: m.totalMatches,
      winRate: m.winRate,
      totalSessions: s.totalSessions,
      totalEquipmentUsed: equipmentUsed,
      recentPerformance: m.trend,
      recentActivity: recentActivity,
      trend: m.trend,
    );
  }
}

class PerformanceIndicatorsCalculator {
  const PerformanceIndicatorsCalculator();

  PerformanceIndicators calculate({
    required MatchStatisticsSnapshot matchSnapshot,
    required SessionStatisticsSnapshot sessionSnapshot,
    required EquipmentStatisticsSnapshot equipmentSnapshot,
    required DateTime periodStart,
    required DateTime periodEnd,
    required int totalEquipmentOwned,
  }) {
    final trend = matchSnapshot.trend;
    final improvement = trend.direction == TrendDirection.up
        ? (trend.delta.abs() * 2).clamp(0.0, 1.0)
        : 0.0;
    final decline = trend.direction == TrendDirection.down
        ? (trend.delta.abs() * 2).clamp(0.0, 1.0)
        : 0.0;
    final variance = _winRateVariance(matchSnapshot);
    final consistency = (1 - variance).clamp(0.0, 1.0);

    final days =
        periodEnd.difference(periodStart).inDays.clamp(1, 365).toInt();
    final activeDays = sessionSnapshot.history.length;
    final activity = days == 0 ? 0.0 : (activeDays / days).clamp(0.0, 1.0);

    final used = equipmentSnapshot.usageFrequency.values
        .where((c) => c > 0)
        .length;
    final utilization = totalEquipmentOwned == 0
        ? 0.0
        : (used / totalEquipmentOwned).clamp(0.0, 1.0);

    return PerformanceIndicators(
      improvement: improvement,
      decline: decline,
      consistency: consistency,
      activity: activity,
      utilization: utilization,
    );
  }

  double _winRateVariance(MatchStatisticsSnapshot m) {
    final trend = m.trend;
    if (trend.points.length < 2) return 0;
    final values = trend.points.map((p) => p.value).toList();
    final mean = values.reduce((a, b) => a + b) / values.length;
    var sum = 0.0;
    for (final v in values) {
      sum += (v - mean) * (v - mean);
    }
    final variance = sum / values.length;
    return variance.clamp(0.0, 1.0);
  }
}