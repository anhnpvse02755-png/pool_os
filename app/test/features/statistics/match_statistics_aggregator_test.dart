// EPIC 02 — Statistics & Analytics — focused tests.
//
// Pure-Dart tests of the Phase 3 aggregators. No database fixtures,
// no Drift, no Riverpod. The aggregators accept pre-built domain
// records and emit snapshots; the tests verify that.

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/equipment/domain/models/cue.dart';
import 'package:pool_os/features/equipment/domain/equipment_performance_projection.dart';
import 'package:pool_os/features/match/domain/models/match.dart';
import 'package:pool_os/features/session/domain/models/session.dart';
import 'package:pool_os/features/statistics/domain/aggregators/match_statistics_aggregator.dart';
import 'package:pool_os/features/statistics/domain/models/analytics_period.dart';

Match _match({
  required int id,
  required String winner,
  required DateTime when,
  String opponent = 'O',
}) {
  return Match(
    id: id,
    sessionId: 1,
    matchNumber: 1,
    gameType: 'race_to',
    opponent: opponent,
    winner: winner,
    result: 'completed',
    startTime: when,
    endTime: when.add(const Duration(minutes: 30)),
    createdAt: when,
  );
}

Session _session({required DateTime start, String type = 'practice'}) {
  return Session(
    sessionType: type,
    startedAt: start,
    finishedAt: start.add(const Duration(hours: 1)),
    createdAt: start,
    updatedAt: start,
  );
}

void main() {
  group('MatchStatisticsAggregator', () {
    const agg = MatchStatisticsAggregator();
    final now = DateTime(2026, 7, 29, 12);

    test('returns empty snapshot when no matches', () {
      final snap = agg.aggregate(
        matches: const [],
        period: AnalyticsPeriod.allTime,
        now: now,
        activePlayerName: 'Me',
      );
      expect(snap.totalMatches, 0);
      expect(snap.winRate, 0);
    });

    test('computes wins, losses, win rate and streak', () {
      final matches = [
        _match(id: 1, winner: 'Me', when: now.subtract(const Duration(days: 1))),
        _match(id: 2, winner: 'Me', when: now.subtract(const Duration(days: 2))),
        _match(id: 3, winner: 'Other', when: now.subtract(const Duration(days: 3))),
        _match(id: 4, winner: 'Me', when: now.subtract(const Duration(days: 4))),
      ];
      final snap = agg.aggregate(
        matches: matches,
        period: AnalyticsPeriod.thirtyDays,
        now: now,
        activePlayerName: 'Me',
      );
      expect(snap.totalMatches, 4);
      expect(snap.wins, 3);
      expect(snap.losses, 1);
      expect(snap.winRate, closeTo(0.75, 1e-9));
      expect(snap.currentStreak, 2);
    });

    test('respects period window (today filters out older matches)', () {
      final matches = [
        _match(id: 1, winner: 'Me', when: now.subtract(const Duration(days: 2))),
        _match(id: 2, winner: 'Me', when: now.subtract(const Duration(days: 10))),
      ];
      final snap = agg.aggregate(
        matches: matches,
        period: AnalyticsPeriod.today,
        now: now,
        activePlayerName: 'Me',
      );
      // today = 1 day window
      expect(snap.totalMatches, 0);
    });

    test('trend direction is up when recent half is better than prior half', () {
      final matches = [
        _match(id: 1, winner: 'Other', when: now.subtract(const Duration(days: 6))),
        _match(id: 2, winner: 'Other', when: now.subtract(const Duration(days: 5))),
        _match(id: 3, winner: 'Me', when: now.subtract(const Duration(days: 4))),
        _match(id: 4, winner: 'Me', when: now.subtract(const Duration(days: 3))),
      ];
      final snap = agg.aggregate(
        matches: matches,
        period: AnalyticsPeriod.thirtyDays,
        now: now,
        activePlayerName: 'Me',
      );
      // sorted newest-first: [Me, Me, Other, Other]
      // current = [Me, Me] (1,1) -> 1.0
      // previous = [Other, Other] (0,0) -> 0.0
      // delta = 1.0 > 0.05 -> up
      expect(snap.trend.direction, TrendDirection.up);
    });
  });

  group('SessionStatisticsAggregator', () {
    const agg = SessionStatisticsAggregator();
    final now = DateTime(2026, 7, 29, 12);

    test('aggregates session volume + average duration', () {
      final sessions = [
        _session(start: now.subtract(const Duration(days: 1))),
        _session(start: now.subtract(const Duration(days: 2))),
        _session(start: now.subtract(const Duration(days: 3)), type: 'match'),
      ];
      final snap = agg.aggregate(
        sessions: sessions,
        period: AnalyticsPeriod.sevenDays,
        now: now,
      );
      expect(snap.totalSessions, 3);
      expect(snap.trainingVolume, 2);
      expect(snap.matchVolume, 1);
      expect(snap.totalDuration, const Duration(hours: 3));
      expect(snap.averageDuration, const Duration(hours: 1));
      expect(snap.history.length, 3);
    });

    test('returns empty when no sessions', () {
      final snap = agg.aggregate(
        sessions: const [],
        period: AnalyticsPeriod.allTime,
        now: now,
      );
      expect(snap.totalSessions, 0);
    });
  });

  group('EquipmentStatisticsAggregator', () {
    const agg = EquipmentStatisticsAggregator();
    final now = DateTime(2026, 7, 29, 12);

    EquipmentPerformanceProjection _proj(int id, double wr) {
      return EquipmentPerformanceProjection.create(
        playerId: 1,
        equipmentId: id,
        totalMatches: 10,
        matchWinRate: wr,
        totalTrainingSessions: 5,
        trainingSuccessRate: 0.5,
        recordedDurationSeconds: 1000,
        lastUsed: now,
        sourceDigest: 'src-$id',
      );
    }

    test('ranks equipment by usage * win-rate', () {
      final projections = [_proj(1, 0.6), _proj(2, 0.9)];
      final snap = agg.aggregate(
        cues: const <Cue>[],
        projections: projections,
        period: AnalyticsPeriod.allTime,
        now: now,
      );
      expect(snap.ranked, hasLength(2));
      // Same usage; higher win-rate wins.
      expect(snap.ranked.first.equipmentId, '2');
    });

    test('returns empty when no projections', () {
      final snap = agg.aggregate(
        cues: const <Cue>[],
        projections: const [],
        period: AnalyticsPeriod.allTime,
        now: now,
      );
      expect(snap.ranked, isEmpty);
    });
  });

  group('PlayerStatisticsAggregator', () {
    const agg = PlayerStatisticsAggregator();
    final now = DateTime(2026, 7, 29, 12);

    test('computes opponent history', () {
      final matches = [
        _match(id: 1, winner: 'Me', when: now.subtract(const Duration(days: 1)), opponent: 'Alice'),
        _match(id: 2, winner: 'Other', when: now.subtract(const Duration(days: 2)), opponent: 'Alice'),
        _match(id: 3, winner: 'Me', when: now.subtract(const Duration(days: 3)), opponent: 'Bob'),
      ];
      final snap = agg.aggregate(
        matches: matches,
        period: AnalyticsPeriod.thirtyDays,
        now: now,
        activePlayerName: 'Me',
      );
      expect(snap.matchCount, 3);
      expect(snap.opponentHistory['Alice'], 2);
      expect(snap.opponentHistory['Bob'], 1);
    });
  });

  group('DashboardAggregator', () {
    const dashboard = DashboardAggregator(
      match: MatchStatisticsAggregator(),
      session: SessionStatisticsAggregator(),
      equipment: EquipmentStatisticsAggregator(),
    );
    final now = DateTime(2026, 7, 29, 12);

    test('combines match + session + equipment counts', () {
      final matches = [
        _match(id: 1, winner: 'Me', when: now.subtract(const Duration(days: 1))),
      ];
      final sessions = [
        _session(start: now.subtract(const Duration(days: 1))),
      ];
      final snap = dashboard.aggregate(
        matches: matches,
        sessions: sessions,
        cues: const <Cue>[],
        projections: const <EquipmentPerformanceProjection>[],
        period: AnalyticsPeriod.thirtyDays,
        now: now,
        activePlayerName: 'Me',
      );
      expect(snap.totalMatches, 1);
      expect(snap.totalSessions, 1);
    });
  });

  group('filterByPeriod', () {
    final now = DateTime(2026, 7, 29, 12);

    test('keeps only items inside the window', () {
      final items = [
        _match(id: 1, winner: 'Me', when: now.subtract(const Duration(hours: 2))),
        _match(id: 2, winner: 'Me', when: now.subtract(const Duration(days: 10))),
      ];
      final kept = filterByPeriod<Match>(
        items: items,
        timestamp: (m) => m.startTime ?? now,
        period: AnalyticsPeriod.today,
        now: now,
      );
      expect(kept, hasLength(1));
      expect(kept.single.id, 1);
    });
  });
}
