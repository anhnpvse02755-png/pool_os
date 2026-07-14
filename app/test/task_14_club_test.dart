import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart' show NativeDatabase;
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/club/data/repositories/club_repository.dart';
import 'package:pool_os/features/club/domain/club_calculator.dart';
import 'package:pool_os/features/club/domain/models/club_models.dart';
import 'package:pool_os/features/player/data/database/app_database.dart'
    hide Club, ClubMember, ClubLink;

/// TASK 14 — Club & Community.
///
/// Two layers:
///  - pure-domain (ClubCalculator): ranking tally + sort, streaks, period
///    leaderboard, aggregate statistics — no DB.
///  - repository against an in-memory DB: club CRUD, members, soft-ref links,
///    and the key guarantee that deleting a club never touches the recorded
///    Matches / trainings / tournaments it linked (no FK cascade). No AI.
void main() {
  group('ClubCalculator ranking (Phần 3)', () {
    ClubMember m(int id, String name, {int? playerId}) => ClubMember(
          id: id,
          clubId: 1,
          playerId: playerId,
          name: name,
          joinedAt: DateTime(2026, 7, 1),
        );

    ClubMatchResult result(int a, int b, int winner, DateTime at,
            {int ra = 0, int rb = 0}) =>
        ClubMatchResult(
          matchId: at.millisecondsSinceEpoch,
          memberAId: a,
          memberBId: b,
          winnerMemberId: winner,
          racksA: ra,
          racksB: rb,
          playedAt: at,
        );

    test('tallies wins/losses and sorts by club points', () {
      final rows = ClubCalculator.ranking(
        members: [m(1, 'A'), m(2, 'B'), m(3, 'C')],
        results: [
          result(1, 2, 1, DateTime(2026, 7, 1)),
          result(1, 3, 1, DateTime(2026, 7, 2)),
          result(2, 3, 2, DateTime(2026, 7, 3)),
        ],
      );
      // A: 2-0 => 6pts; B: 1-1 => 3+1=4pts; C: 0-2 => 2pts.
      expect(rows[0].memberId, 1);
      expect(rows[0].wins, 2);
      expect(rows[0].clubPoints, 6);
      expect(rows[1].memberId, 2);
      expect(rows[2].memberId, 3);
      expect(rows[2].clubPoints, 2);
    });

    test('current streak reflects most recent consecutive results', () {
      // A wins, loses, then wins twice => current streak +2.
      final rows = ClubCalculator.ranking(
        members: [m(1, 'A'), m(2, 'B')],
        results: [
          result(1, 2, 1, DateTime(2026, 7, 1)),
          result(1, 2, 2, DateTime(2026, 7, 2)),
          result(1, 2, 1, DateTime(2026, 7, 3)),
          result(1, 2, 1, DateTime(2026, 7, 4)),
        ],
      );
      final a = rows.firstWhere((r) => r.memberId == 1);
      expect(a.currentStreak, 2);
      final b = rows.firstWhere((r) => r.memberId == 2);
      expect(b.currentStreak, -2); // B's last two were losses
    });

    test('members with no matches still appear with zero counts', () {
      final rows = ClubCalculator.ranking(
        members: [m(1, 'A'), m(2, 'B')],
        results: const [],
      );
      expect(rows.length, 2);
      expect(rows.every((r) => r.matchesPlayed == 0), true);
    });

    test('leaderboard filters results to the period window', () {
      final now = DateTime(2026, 7, 14);
      final rows = ClubCalculator.leaderboard(
        members: [m(1, 'A'), m(2, 'B')],
        results: [
          result(1, 2, 1, now.subtract(const Duration(days: 2))), // in week
          result(1, 2, 2, now.subtract(const Duration(days: 40))), // out of week
        ],
        period: LeaderboardPeriod.week,
        now: now,
      );
      final a = rows.firstWhere((r) => r.memberId == 1);
      // Only the in-window win counts for the weekly leaderboard.
      expect(a.wins, 1);
      expect(a.matchesPlayed, 1);
    });

    test('statistics aggregate matches, racks and most-wins', () {
      final stats = ClubCalculator.statistics(
        members: [m(1, 'A'), m(2, 'B')],
        results: [
          result(1, 2, 1, DateTime(2026, 7, 1), ra: 5, rb: 3),
          result(1, 2, 1, DateTime(2026, 7, 2), ra: 5, rb: 2),
        ],
        trainingSecondsByMember: {2: 3600, 1: 600},
      );
      expect(stats.totalMatches, 2);
      expect(stats.totalRacks, 15); // 8 + 7
      expect(stats.mostWinsMemberName, 'A');
      expect(stats.mostActiveMemberName, 'B'); // trained the most seconds
      expect(stats.totalTrainingTime, const Duration(seconds: 4200));
      expect(stats.mostImprovedMemberName, isNull); // not derivable => null
    });
  });

  group('ClubRepository (in-memory DB)', () {
    late AppDatabase db;
    late ClubRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = ClubRepository(db);
    });
    tearDown(() async => db.close());

    Future<int> makeClub() => repo.createClub(
          Club(name: 'City Club', createdAt: DateTime(2026, 7, 1)),
        );

    test('create + read round-trips club info', () async {
      final id = await repo.createClub(Club(
        name: 'Downtown',
        location: 'HCMC',
        managerName: 'Anh',
        createdAt: DateTime(2026, 7, 1),
      ));
      final c = await repo.getClubById(id);
      expect(c, isNotNull);
      expect(c!.location, 'HCMC');
      expect(c.managerName, 'Anh');
    });

    test('members: add saved player and guest, change role, remove', () async {
      final clubId = await makeClub();
      final playerId = await db.into(db.players).insert(
            PlayersCompanion.insert(name: 'Real Player'),
          );
      await repo.addMember(ClubMember(
        clubId: clubId,
        playerId: playerId,
        name: 'Real Player',
        joinedAt: DateTime(2026, 7, 1),
      ));
      final guestId = await repo.addMember(ClubMember(
        clubId: clubId,
        name: 'Guest',
        joinedAt: DateTime(2026, 7, 1),
      ));

      var members = await repo.getMembers(clubId);
      expect(members.length, 2);
      expect(members.firstWhere((m) => m.name == 'Guest').isGuest, true);

      await repo.setMemberRole(guestId, ClubRole.admin);
      members = await repo.getMembers(clubId);
      expect(members.firstWhere((m) => m.id == guestId).role, ClubRole.admin);

      await repo.removeMember(guestId);
      members = await repo.getMembers(clubId);
      expect(members.length, 1);
    });

    test('addLink is idempotent for the same (club, kind, ref)', () async {
      final clubId = await makeClub();
      final first = await repo.addLink(ClubLink(
        clubId: clubId,
        kind: ClubLinkKind.match,
        refId: 42,
        createdAt: DateTime(2026, 7, 1),
      ));
      final second = await repo.addLink(ClubLink(
        clubId: clubId,
        kind: ClubLinkKind.match,
        refId: 42,
        createdAt: DateTime(2026, 7, 2),
      ));
      expect(first, second); // returns existing id, no duplicate
      final links = await repo.getLinks(clubId, kind: ClubLinkKind.match);
      expect(links.length, 1);
    });

    test('club match results resolve winner from recorded racks', () async {
      final clubId = await makeClub();
      final playerId = await db.into(db.players).insert(
            PlayersCompanion.insert(name: 'Me'),
          );
      await repo.addMember(ClubMember(
        clubId: clubId,
        playerId: playerId,
        name: 'Me',
        joinedAt: DateTime(2026, 7, 1),
      ));
      // Recorded match via the LOCKED pipeline (session -> match -> racks).
      final sessionId = await db.into(db.sessions).insert(SessionsCompanion.insert(
        sessionType: 'match',
        startedAt: DateTime(2026, 7, 1),
      ));
      final matchId = await db.into(db.matches).insert(MatchesCompanion.insert(
        sessionId: sessionId,
        matchNumber: 1,
        gameType: '9ball',
        winner: const Value('me'),
      ));
      // 3 racks won, 1 lost.
      for (var i = 0; i < 3; i++) {
        await db.into(db.racks).insert(RacksCompanion.insert(
          matchId: matchId,
          rackNumber: i + 1,
          result: true,
        ));
      }
      await db.into(db.racks).insert(RacksCompanion.insert(
        matchId: matchId,
        rackNumber: 4,
        result: false,
      ));

      await repo.addLink(ClubLink(
        clubId: clubId,
        kind: ClubLinkKind.match,
        refId: matchId,
        createdAt: DateTime(2026, 7, 1),
      ));

      final results = await repo.getClubMatchResults(clubId);
      expect(results.length, 1);
      expect(results.first.racksA, 3);
      expect(results.first.racksB, 1);
      expect(results.first.winnerMemberId, isNotNull);
    });

    test('deleting a club keeps recorded matches and linked rows intact',
        () async {
      final clubId = await makeClub();
      final sessionId = await db.into(db.sessions).insert(SessionsCompanion.insert(
        sessionType: 'match',
        startedAt: DateTime(2026, 7, 1),
      ));
      final matchId = await db.into(db.matches).insert(MatchesCompanion.insert(
        sessionId: sessionId,
        matchNumber: 1,
        gameType: '9ball',
      ));
      await repo.addMember(ClubMember(
        clubId: clubId,
        name: 'Guest',
        joinedAt: DateTime(2026, 7, 1),
      ));
      await repo.addLink(ClubLink(
        clubId: clubId,
        kind: ClubLinkKind.match,
        refId: matchId,
        createdAt: DateTime(2026, 7, 1),
      ));

      await repo.deleteClub(clubId);

      // Club rows gone.
      expect(await repo.getClubById(clubId), isNull);
      expect(await repo.getMembers(clubId), isEmpty);
      expect(await repo.getLinks(clubId), isEmpty);
      // Recorded match untouched.
      final match = await (db.select(db.matches)
            ..where((t) => t.id.equals(matchId)))
          .getSingleOrNull();
      expect(match, isNotNull);
    });
  });
}
