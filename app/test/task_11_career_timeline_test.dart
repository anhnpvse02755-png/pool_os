import 'package:drift/drift.dart' show QueryExecutor, Value;
import 'package:drift/native.dart' show NativeDatabase;
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/player/data/database/app_database.dart';
import 'package:pool_os/features/career/data/repositories/career_repository.dart';
import 'package:pool_os/features/career/domain/models/career_models.dart';
import 'package:pool_os/features/career/domain/timeline_aggregator.dart';

/// TASK 11 — Player Timeline & Career.
///
/// Exercises (1) the pure [TimelineAggregator] filter + day-grouping with
/// hand-built events, and (2) the read-only [CareerRepository] against an
/// in-memory DB: timeline events aggregated from sessions/matches/cues/training
/// /goals/achievements, and the career summary roll-up. Nothing is written and
/// no new tables exist — the recording pipeline is untouched. No AI.
void main() {
  // A minimal label bundle for repository tests (identity-ish resolver).
  final labels = CareerLabels(
    resolve: (k) => k,
    matchWin: 'Match won',
    matchLoss: 'Match lost',
    race: 'Race to',
    equipmentAdded: 'New equipment',
    trainingSession: 'Training session',
    goalCompleted: 'Goal completed',
    achievementUnlocked: 'Achievement unlocked',
    sessionTitle: (t) => 'Session:$t',
    cueType: (t) => t,
  );

  group('TimelineAggregator (Phần 1/7 — filter + group)', () {
    List<TimelineEvent> sample() => [
          TimelineEvent(
            date: DateTime(2026, 8, 5, 10),
            type: TimelineEventType.training,
            title: 'Training',
          ),
          TimelineEvent(
            date: DateTime(2026, 8, 5, 18),
            type: TimelineEventType.match,
            title: 'Match won',
            win: true,
          ),
          TimelineEvent(
            date: DateTime(2026, 8, 6, 9),
            type: TimelineEventType.goal,
            title: 'Goal completed',
          ),
        ];

    test('groups events by day, newest day and newest event first', () {
      final days = TimelineAggregator.groupByDay(sample());
      expect(days.length, 2);
      // Newest day (Aug 6) first.
      expect(days.first.day, DateTime(2026, 8, 6));
      // Within Aug 5, the 18:00 match comes before the 10:00 training.
      final aug5 = days[1];
      expect(aug5.events.first.date.hour, 18);
      expect(aug5.events.last.date.hour, 10);
    });

    test('filter by type keeps only selected types', () {
      final filtered = TimelineAggregator.filter(
        sample(),
        types: {TimelineEventType.match},
      );
      expect(filtered.length, 1);
      expect(filtered.single.type, TimelineEventType.match);
    });

    test('empty type set means all types', () {
      final filtered =
          TimelineAggregator.filter(sample(), types: <TimelineEventType>{});
      expect(filtered.length, 3);
    });

    test('time bounds filter events inclusive', () {
      final filtered = TimelineAggregator.filter(
        sample(),
        from: DateTime(2026, 8, 6),
      );
      expect(filtered.length, 1);
      expect(filtered.single.type, TimelineEventType.goal);
    });
  });

  group('CareerSummary', () {
    test('daysSinceStart counts inclusive from start', () {
      const summary = CareerSummary(totalMatches: 1);
      final withStart = CareerSummary(startedAt: DateTime(2026, 8, 1));
      expect(summary.daysSinceStart(DateTime(2026, 8, 10)), 0); // null start
      expect(withStart.daysSinceStart(DateTime(2026, 8, 10)), 10);
    });

    test('isEmpty is true only with no activity', () {
      expect(const CareerSummary().isEmpty, isTrue);
      expect(const CareerSummary(totalRacks: 1).isEmpty, isFalse);
    });
  });

  group('CareerRepository (read-only aggregation)', () {
    late AppDatabase db;
    late CareerRepository repo;

    AppDatabase openDb(QueryExecutor executor) {
      final database = AppDatabase.forTesting(executor);
      repo = CareerRepository(database);
      return database;
    }

    setUp(() => db = openDb(NativeDatabase.memory()));
    tearDown(() async => db.close());

    test('empty DB yields empty timeline + empty summary', () async {
      final events = await repo.buildTimeline(labels);
      final summary = await repo.buildSummary();
      expect(events, isEmpty);
      expect(summary.isEmpty, isTrue);
      expect(summary.startedAt, isNull);
    });

    test('aggregates events from every source', () async {
      final sessionId = await db.into(db.sessions).insert(
            SessionsCompanion.insert(
              sessionType: 'match',
              startedAt: DateTime(2026, 8, 1, 10),
              finishedAt: Value(DateTime(2026, 8, 1, 11)),
            ),
          );
      await db.into(db.matches).insert(MatchesCompanion.insert(
            sessionId: sessionId,
            matchNumber: 1,
            gameType: '9ball',
            winner: const Value('Player'),
            raceTo: const Value(9),
            startTime: Value(DateTime(2026, 8, 1, 10, 30)),
          ));
      await db.into(db.cues).insert(CuesCompanion.insert(
            name: 'Revo 12.5',
            shaft: 'carbon',
            tip: 'soft',
            shaftMaterial: 'carbon',
            shaftDiameter: 12.5,
            tipBrand: 'Kamui',
            tipHardness: 'soft',
            weight: 19.0,
            balance: 'neutral',
            joint: 'radial',
          ));
      await db.into(db.trainingCenterSessions).insert(
            TrainingCenterSessionsCompanion.insert(
              startedAt: DateTime(2026, 8, 2, 9),
              completedAt: Value(DateTime(2026, 8, 2, 10)),
            ),
          );
      await db.into(db.goals).insert(GoalsCompanion.insert(
            title: 'Win 10 matches',
            metric: 'matches_won',
            targetValue: 10,
            createdAt: DateTime(2026, 8, 1),
            completedAt: Value(DateTime(2026, 8, 3, 12)),
          ));
      await db.into(db.achievementUnlocks).insert(
            AchievementUnlocksCompanion.insert(
              badgeKey: 'first_match_win',
              unlockedAt: DateTime(2026, 8, 1, 10, 45),
            ),
          );

      final events = await repo.buildTimeline(labels);
      final types = events.map((e) => e.type).toSet();
      expect(types, contains(TimelineEventType.session));
      expect(types, contains(TimelineEventType.match));
      expect(types, contains(TimelineEventType.equipment));
      expect(types, contains(TimelineEventType.training));
      expect(types, contains(TimelineEventType.goal));
      expect(types, contains(TimelineEventType.achievement));

      // The match event carries a win flag.
      final match = events.firstWhere((e) => e.type == TimelineEventType.match);
      expect(match.win, isTrue);
    });

    test('summary rolls up counts, hours and start date', () async {
      final sessionId = await db.into(db.sessions).insert(
            SessionsCompanion.insert(
              sessionType: 'match',
              startedAt: DateTime(2026, 8, 1, 10),
              finishedAt: Value(DateTime(2026, 8, 1, 12)), // 2h
            ),
          );
      final matchId = await db.into(db.matches).insert(
            MatchesCompanion.insert(
              sessionId: sessionId,
              matchNumber: 1,
              gameType: '9ball',
              winner: const Value('Player'),
            ),
          );
      await db.into(db.racks).insert(RacksCompanion.insert(
            matchId: matchId,
            rackNumber: 1,
            result: true,
          ));

      final summary = await repo.buildSummary();
      expect(summary.totalMatches, 1);
      expect(summary.matchesWon, 1);
      expect(summary.totalRacks, 1);
      expect(summary.totalHours, closeTo(2.0, 0.01));
      expect(summary.startedAt, DateTime(2026, 8, 1, 10));
    });
  });
}
