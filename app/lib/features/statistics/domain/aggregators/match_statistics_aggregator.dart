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
    var draws = 0;
    final distribution = <String, int>{
      'one_match': filtered.length,
    };
    final raceDistribution = <String, int>{};
    final matchTypeDistribution = <String, int>{};
    final gameTypeDistribution = <String, int>{};
    final sorted = [...filtered]
      ..sort((a, b) => (b.startTime ?? b.endTime ?? now)
          .compareTo(a.startTime ?? a.endTime ?? now));
    final recentIds = sorted
        .take(5)
        .map((m) => m.id.toString())
        .toList();

    final lower = activePlayerName.trim().toLowerCase();
    for (final m in filtered) {
      final winner = (m.winner ?? '').trim();
      final winnerLower = winner.toLowerCase();
      final isWin = winnerLower == lower;
      if (isWin) {
        wins++;
      } else if (winner.isEmpty) {
        draws++;
      } else {
        losses++;
      }
      if (m.raceTo != null) {
        raceDistribution[m.raceTo.toString()] =
            (raceDistribution[m.raceTo.toString()] ?? 0) + 1;
      }
      final matchType = m.teamMode ?? 'single';
      matchTypeDistribution[matchType] =
          (matchTypeDistribution[matchType] ?? 0) + 1;
      final gameType = m.gameType;
      if (gameType.isNotEmpty) {
        gameTypeDistribution[gameType] =
            (gameTypeDistribution[gameType] ?? 0) + 1;
      }
    }

    final durations = <Duration>[];
    var totalDuration = Duration.zero;
    for (final m in filtered) {
      final start = m.startTime;
      final end = m.endTime;
      if (start != null && end != null && !end.isBefore(start)) {
        final d = end.difference(start);
        durations.add(d);
        totalDuration += d;
      }
    }
    final longestMatch = durations.isEmpty
        ? Duration.zero
        : durations.reduce((a, b) => a > b ? a : b);
    final averageMatchDuration = durations.isEmpty
        ? Duration.zero
        : Duration(
            seconds: totalDuration.inSeconds ~/ durations.length,
          );

    final streak = _currentStreak(
      matches: filtered,
      activePlayerName: activePlayerName,
      now: now,
    );

    final highestStreak = _highestWinStreak(
      matches: filtered,
      activePlayerName: activePlayerName,
      now: now,
    );

    final trend = _buildTrend(
      values: sorted
          .map((m) => (m.winner ?? '').trim().toLowerCase() == lower
              ? 1.0
              : 0.0)
          .toList(),
    );

    final totalMatches = filtered.length;
    final winRate = totalMatches == 0 ? 0.0 : wins / totalMatches;
    final loseRate = totalMatches == 0 ? 0.0 : losses / totalMatches;

    return MatchStatisticsSnapshot(
      period: period,
      totalMatches: totalMatches,
      wins: wins,
      losses: losses,
      draws: draws,
      loseRate: loseRate,
      winRate: winRate,
      averageRacks: 0,
      averageMatchDuration: averageMatchDuration,
      longestMatch: longestMatch,
      currentStreak: streak,
      highestWinStreak: highestStreak,
      raceDistribution: raceDistribution,
      matchTypeDistribution: matchTypeDistribution,
      gameTypeDistribution: gameTypeDistribution,
      distribution: distribution,
      trend: trend,
      recentMatchIds: recentIds,
    );
  }

  int _highestWinStreak({
    required List<Match> matches,
    required String activePlayerName,
    required DateTime now,
  }) {
    if (matches.isEmpty) return 0;
    final sorted = [...matches]..sort((a, b) {
        final at = a.startTime ?? a.endTime ?? now;
        final bt = b.startTime ?? b.endTime ?? now;
        return at.compareTo(bt);
      });
    final lower = activePlayerName.trim().toLowerCase();
    var best = 0;
    var current = 0;
    for (final m in sorted) {
      final isWin =
          (m.winner ?? '').trim().toLowerCase() == lower;
      if (isWin) {
        current++;
        if (current > best) best = current;
      } else {
        current = 0;
      }
    }
    return best;
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
    final isoWeeks = <String>{};
    final yearMonths = <String>{};
    final drillDistribution = <String, int>{};
    for (final s in filtered) {
      final d = s.duration;
      durations.add(d);
      if (s.sessionType == SessionTypes.match) {
        matchSessions++;
      }
      isoWeeks.add(_isoWeekKey(s.startedAt));
      yearMonths.add(_yearMonthKey(s.startedAt));
      final drillType = s.sessionType.isEmpty ? 'general' : s.sessionType;
      drillDistribution[drillType] =
          (drillDistribution[drillType] ?? 0) + 1;
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
    final successRate = filtered.isEmpty
        ? 0.0
        : matchSessions / filtered.length;

    history.sort((a, b) => b.startedAt.compareTo(a.startedAt));

    return SessionStatisticsSnapshot(
      period: period,
      totalSessions: filtered.length,
      totalDuration: totalDuration,
      averageDuration: averageDuration,
      trainingVolume: filtered.length - matchSessions,
      matchVolume: matchSessions,
      weeklySessions: isoWeeks.length,
      monthlySessions: yearMonths.length,
      successRate: successRate,
      drillDistribution: drillDistribution,
      history: history,
    );
  }

  String _isoWeekKey(DateTime d) {
    final utc = d.toUtc();
    final jan4 = DateTime.utc(utc.year, 1, 4);
    final dayDelta = utc.difference(jan4).inDays;
    final isoWeek = ((dayDelta + jan4.weekday - 1) ~/ 7) + 1;
    return '${utc.year}-W${isoWeek.toString().padLeft(2, '0')}';
  }

  String _yearMonthKey(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}';
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
    final lastUsed = <String, DateTime>{};
    final totalHours = <String, Duration>{};
    final avgMatchLength = <String, Duration>{};

    for (final p in projections) {
      final key = p.equipmentId.toString();
      usageFrequency[key] = p.totalMatches;
      winRate[key] = p.matchWinRate;
      trainingSuccess[key] = p.trainingSuccessRate;
      matchSuccess[key] = p.matchWinRate;
      lastUsed[key] = p.lastUsed ?? DateTime(0);
      totalHours[key] = Duration(seconds: p.recordedDurationSeconds);
      if (p.totalMatches > 0 && p.recordedDurationSeconds > 0) {
        avgMatchLength[key] =
            Duration(seconds: p.recordedDurationSeconds ~/ p.totalMatches);
      } else {
        avgMatchLength[key] = Duration.zero;
      }
    }

    final ranked = projections
        .map((p) => EquipmentRankingEntry(
              equipmentId: p.equipmentId.toString(),
              usageCount: p.totalMatches,
              score: _scoreFor(p),
              matchCount: p.totalMatches,
              winRate: p.matchWinRate,
              lastUsed: p.lastUsed,
              totalHours: Duration(seconds: p.recordedDurationSeconds),
            ))
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    return EquipmentStatisticsSnapshot(
      period: period,
      usageFrequency: usageFrequency,
      winRateByEquipment: winRate,
      trainingSuccessByEquipment: trainingSuccess,
      matchSuccessByEquipment: matchSuccess,
      lastUsedByEquipment: lastUsed,
      averageMatchLengthByEquipment: avgMatchLength,
      totalHoursByEquipment: totalHours,
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
    var losses = 0;
    var totalDuration = Duration.zero;
    var durationSamples = 0;
    final opponents = <String, int>{};
    final headToHead = <String, _H2HAccum>{};
    final recent = <PlayerActivityEntry>[];
    final lower = activePlayerName.trim().toLowerCase();
    for (final m in filtered) {
      final winner = (m.winner ?? '').trim();
      final isWin = winner.toLowerCase() == lower;
      if (isWin) {
        wins++;
      } else if (winner.isNotEmpty) {
        losses++;
      }
      final opp = (m.opponent ?? '').trim();
      if (opp.isNotEmpty) {
        opponents[opp] = (opponents[opp] ?? 0) + 1;
        final acc = headToHead.putIfAbsent(opp, () => _H2HAccum());
        acc.matches++;
        if (isWin) {
          acc.wins++;
        } else if (winner.isNotEmpty) {
          acc.losses++;
        }
      }
      final start = m.startTime;
      final end = m.endTime;
      if (start != null && end != null && !end.isBefore(start)) {
        totalDuration += end.difference(start);
        durationSamples++;
      }
      recent.add(PlayerActivityEntry(
        date: m.startTime ?? m.endTime ?? now,
        kind: m.result ?? 'completed',
        title: opp.isEmpty ? 'Match' : 'vs $opp',
      ));
    }
    recent.sort((a, b) => b.date.compareTo(a.date));

    final sortedByTime = [...filtered]..sort((a, b) {
        final at = a.startTime ?? a.endTime ?? now;
        final bt = b.startTime ?? b.endTime ?? now;
        return at.compareTo(bt);
      });
    var bestStreak = 0;
    var current = 0;
    for (final m in sortedByTime) {
      final isWin =
          (m.winner ?? '').trim().toLowerCase() == lower;
      if (isWin) {
        current++;
        if (current > bestStreak) bestStreak = current;
      } else {
        current = 0;
      }
    }

    final trendValues = filtered
        .map((m) => (m.winner ?? '').trim().toLowerCase() == lower
            ? 1.0
            : 0.0)
        .toList();
    final trend = _simpleTrend(trendValues);

    final winRate = filtered.isEmpty ? 0.0 : wins / filtered.length;
    final avgDuration = durationSamples == 0
        ? Duration.zero
        : Duration(seconds: totalDuration.inSeconds ~/ durationSamples);

    final h2h = <String, HeadToHeadSummary>{
      for (final e in headToHead.entries)
        e.key: HeadToHeadSummary(
          opponent: e.key,
          matches: e.value.matches,
          wins: e.value.wins,
          losses: e.value.losses,
          winRate: e.value.matches == 0 ? 0 : e.value.wins / e.value.matches,
        ),
    };
    final h2hSorted = h2h.entries.toList()
      ..sort((a, b) => b.value.matches.compareTo(a.value.matches));
    final h2hMap = <String, HeadToHeadSummary>{
      for (final e in h2hSorted) e.key: e.value,
    };

    return PlayerStatisticsSnapshot(
      period: period,
      matchCount: filtered.length,
      wins: wins,
      losses: losses,
      winRate: winRate,
      averageMatchDuration: avgDuration,
      bestWinStreak: bestStreak,
      headToHead: h2hMap,
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

class _H2HAccum {
  int matches = 0;
  int wins = 0;
  int losses = 0;
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

    final activeEquipment = projections
        .where((p) => p.lastUsed != null)
        .length;

    final totalHours = sessions.fold<Duration>(
      Duration.zero,
      (acc, sess) => acc + sess.duration,
    );

    final playerNames = <String>{};
    for (final m in matches) {
      if (m.winner != null && m.winner!.isNotEmpty) {
        playerNames.add(m.winner!);
      }
      if (m.opponent != null && m.opponent!.isNotEmpty) {
        playerNames.add(m.opponent!);
      }
    }
    final totalPlayers = playerNames.length;

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
      totalHours: totalHours,
      totalPlayers: totalPlayers,
      totalEquipmentUsed: equipmentUsed,
      activeEquipment: activeEquipment,
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