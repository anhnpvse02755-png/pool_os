// EPIC 02 — Statistics & Analytics — extended metrics tests.
//
// Verifies Phase A..H additions: draws, lose-rate, longest match,
// highest win streak, race / game / match type distribution,
// best win streak, head-to-head, weekly/monthly sessions, drill
// distribution, heatmap, trend buckets, histograms.

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/equipment/domain/equipment_performance_projection.dart';
import 'package:pool_os/features/match/domain/models/match.dart';
import 'package:pool_os/features/session/domain/models/session.dart';
import 'package:pool_os/features/statistics/domain/aggregators/match_statistics_aggregator.dart';
import 'package:pool_os/features/statistics/domain/models/analytics_period.dart';
import 'package:pool_os/features/statistics/domain/models/trend_aggregations.dart';
import 'package:pool_os/features/statistics/domain/performance/trend_calculator.dart';

Match _match({
  required int id,
  String? winner,
  required DateTime when,
  String opponent = 'O',
  String gameType = 'race_to',
  int? raceTo,
  String? teamMode,
  DateTime? startTime,
  DateTime? endTime,
}) {
  return Match(
    id: id,
    sessionId: 1,
    matchNumber: id,
    gameType: gameType,
    raceTo: raceTo,
    opponent: opponent,
    winner: winner,
    teamMode: teamMode,
    startTime: startTime ?? when,
    endTime: endTime ?? when,
    createdAt: when,
  );
}

Session _session({
  required int id,
  required DateTime startedAt,
  Duration duration = const Duration(minutes: 60),
  String sessionType = 'training',
}) {
  return Session(
    id: id,
    startedAt: startedAt,
    finishedAt: startedAt.add(duration),
    sessionType: sessionType,
  );
}

void main() {
  group('MatchStatisticsAggregator — extended metrics', () {
    const agg = MatchStatisticsAggregator();
    final now = DateTime(2026, 1, 15, 12, 0);

    test('reports draws and lose rate', () {
      final matches = [
        _match(id: 1, winner: 'P', when: now),
        _match(id: 2, winner: null, when: now), // draw
        _match(id: 3, winner: 'O', when: now),
      ];
      final snap = agg.aggregate(
        matches: matches,
        period: AnalyticsPeriod.sevenDays,
        now: now,
        activePlayerName: 'P',
      );
      expect(snap.wins, 1);
      expect(snap.losses, 1);
      expect(snap.draws, 1);
      expect(snap.loseRate, closeTo(1 / 3, 0.01));
    });

    test('reports longest match and average duration', () {
      final matches = [
        _match(
          id: 1,
          winner: 'P',
          when: now,
          startTime: now.subtract(const Duration(minutes: 30)),
          endTime: now,
        ),
        _match(
          id: 2,
          winner: 'P',
          when: now,
          startTime: now.subtract(const Duration(minutes: 90)),
          endTime: now,
        ),
      ];
      final snap = agg.aggregate(
        matches: matches,
        period: AnalyticsPeriod.sevenDays,
        now: now,
        activePlayerName: 'P',
      );
      expect(snap.longestMatch, const Duration(minutes: 90));
      expect(snap.averageMatchDuration.inMinutes, 60);
    });

    test('reports highest win streak across history', () {
      final matches = [
        _match(id: 1, winner: 'P', when: now.subtract(const Duration(days: 4))),
        _match(id: 2, winner: 'P', when: now.subtract(const Duration(days: 3))),
        _match(id: 3, winner: 'P', when: now.subtract(const Duration(days: 2))),
        _match(id: 4, winner: 'O', when: now.subtract(const Duration(days: 1))),
        _match(id: 5, winner: 'P', when: now),
      ];
      final snap = agg.aggregate(
        matches: matches,
        period: AnalyticsPeriod.thirtyDays,
        now: now,
        activePlayerName: 'P',
      );
      expect(snap.highestWinStreak, 3);
      expect(snap.currentStreak, 1);
    });

    test('reports race / game / match type distributions', () {
      final matches = [
        _match(id: 1, winner: 'P', when: now, raceTo: 7, gameType: '8-ball', teamMode: 'single'),
        _match(id: 2, winner: 'P', when: now, raceTo: 7, gameType: '9-ball', teamMode: 'single'),
        _match(id: 3, winner: 'P', when: now, raceTo: 9, gameType: '9-ball', teamMode: 'double'),
      ];
      final snap = agg.aggregate(
        matches: matches,
        period: AnalyticsPeriod.sevenDays,
        now: now,
        activePlayerName: 'P',
      );
      expect(snap.raceDistribution['7'], 2);
      expect(snap.raceDistribution['9'], 1);
      expect(snap.gameTypeDistribution['9-ball'], 2);
      expect(snap.matchTypeDistribution['single'], 2);
      expect(snap.matchTypeDistribution['double'], 1);
    });
  });

  group('PlayerStatisticsAggregator — head-to-head + best streak', () {
    const agg = PlayerStatisticsAggregator();
    final now = DateTime(2026, 1, 15, 12, 0);

    test('computes head-to-head summary per opponent', () {
      final matches = [
        _match(id: 1, winner: 'P', when: now, opponent: 'Alice'),
        _match(id: 2, winner: 'Alice', when: now, opponent: 'Alice'),
        _match(id: 3, winner: 'P', when: now, opponent: 'Bob'),
      ];
      final snap = agg.aggregate(
        matches: matches,
        period: AnalyticsPeriod.sevenDays,
        now: now,
        activePlayerName: 'P',
      );
      expect(snap.headToHead['Alice']!.matches, 2);
      expect(snap.headToHead['Alice']!.wins, 1);
      expect(snap.headToHead['Bob']!.matches, 1);
      expect(snap.headToHead['Bob']!.wins, 1);
    });

    test('reports best win streak across full history', () {
      final matches = [
        _match(id: 1, winner: 'P', when: now.subtract(const Duration(days: 5)), opponent: 'Alice'),
        _match(id: 2, winner: 'P', when: now.subtract(const Duration(days: 4)), opponent: 'Alice'),
        _match(id: 3, winner: 'P', when: now.subtract(const Duration(days: 3)), opponent: 'Alice'),
        _match(id: 4, winner: 'Alice', when: now.subtract(const Duration(days: 2)), opponent: 'Alice'),
        _match(id: 5, winner: 'P', when: now.subtract(const Duration(days: 1)), opponent: 'Alice'),
      ];
      final snap = agg.aggregate(
        matches: matches,
        period: AnalyticsPeriod.thirtyDays,
        now: now,
        activePlayerName: 'P',
      );
      expect(snap.bestWinStreak, 3);
    });
  });

  group('SessionStatisticsAggregator — extended metrics', () {
    const agg = SessionStatisticsAggregator();
    final now = DateTime(2026, 1, 15);

    test('counts weekly + monthly sessions, drill distribution, success rate', () {
      final sessions = [
        _session(id: 1, startedAt: DateTime(2025, 12, 28)),
        _session(id: 2, startedAt: DateTime(2025, 12, 30)),
        _session(id: 3, startedAt: DateTime(2026, 1, 5), sessionType: 'match'),
        _session(id: 4, startedAt: DateTime(2026, 1, 8), sessionType: 'match'),
        _session(id: 5, startedAt: DateTime(2026, 1, 10)),
      ];
      final snap = agg.aggregate(
        sessions: sessions,
        period: AnalyticsPeriod.thirtyDays,
        now: now,
      );
      expect(snap.totalSessions, 5);
      expect(snap.weeklySessions, greaterThanOrEqualTo(2));
      expect(snap.monthlySessions, 2); // 2025-12 + 2026-01
      expect(snap.drillDistribution['training'], 3);
      expect(snap.drillDistribution['match'], 2);
      expect(snap.successRate, closeTo(2 / 5, 0.01));
    });
  });

  group('DashboardAggregator — totalHours + activeEquipment + totalPlayers', () {
    const dashboard = DashboardAggregator(
      match: MatchStatisticsAggregator(),
      equipment: EquipmentStatisticsAggregator(),
      session: SessionStatisticsAggregator(),
    );
    final now = DateTime(2026, 1, 15, 12, 0);

    test('sums totalHours and counts distinct players + active equipment', () {
      final matches = [
        _match(id: 1, winner: 'P', when: now, opponent: 'A'),
        _match(id: 2, winner: 'A', when: now, opponent: 'A'),
      ];
      final sessions = [
        _session(id: 1, startedAt: now, duration: const Duration(minutes: 90)),
        _session(id: 2, startedAt: now, duration: const Duration(minutes: 30)),
      ];
      final projections = <EquipmentPerformanceProjection>[
        EquipmentPerformanceProjection.create(
          playerId: 1,
          equipmentId: 1,
          totalMatches: 2,
          matchWinRate: 0.5,
          totalTrainingSessions: 1,
          trainingSuccessRate: 0.5,
          recordedDurationSeconds: 0,
          lastUsed: now.subtract(const Duration(days: 2)),
          sourceDigest: 'p1e1',
        ),
        EquipmentPerformanceProjection.create(
          playerId: 1,
          equipmentId: 2,
          totalMatches: 0,
          matchWinRate: 0,
          totalTrainingSessions: 0,
          trainingSuccessRate: 0,
          recordedDurationSeconds: 0,
          lastUsed: null,
          sourceDigest: 'p1e2',
        ),
      ];
      final snap = dashboard.aggregate(
        matches: matches,
        sessions: sessions,
        cues: const [],
        projections: projections,
        period: AnalyticsPeriod.sevenDays,
        now: now,
        activePlayerName: 'P',
      );
      expect(snap.totalHours.inMinutes, 120);
      expect(snap.totalPlayers, 2);
      expect(snap.activeEquipment, 1);
    });
  });

  group('TrendCalculator + ActivityHeatmap', () {
    const calc = TrendCalculator();
    final now = DateTime(2026, 1, 15);

    test('buckets matches and sessions daily', () {
      final matches = [
        _match(id: 1, winner: 'P', when: DateTime(2026, 1, 10)),
        _match(id: 2, winner: 'P', when: DateTime(2026, 1, 11)),
      ];
      final sessions = [
        _session(id: 1, startedAt: DateTime(2026, 1, 12)),
      ];
      final snap = calc.aggregate(
        matches: matches,
        sessions: sessions,
        bucket: TrendBucket.daily,
        period: AnalyticsPeriod.thirtyDays,
        now: now,
        activePlayerName: 'P',
      );
      expect(snap.points.length, 3);
      expect(snap.movingAverage.isNotEmpty, true);
    });

    test('heatmap bins by weekday × hour', () {
      final heatmap = ActivityHeatmap.compute(timestamps: [
        DateTime(2026, 1, 12, 10),
        DateTime(2026, 1, 12, 10),
        DateTime(2026, 1, 14, 18),
      ]);
      expect(heatmap.maxCount, 2);
      expect(heatmap.cells[DateTime(2026, 1, 12).weekday % 7][10], 2);
    });
  });
}