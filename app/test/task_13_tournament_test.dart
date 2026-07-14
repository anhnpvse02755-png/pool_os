import 'package:drift/native.dart' show NativeDatabase;
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/player/data/database/app_database.dart'
    hide Tournament, TournamentParticipant;
import 'package:pool_os/features/tournament/data/repositories/tournament_repository.dart';
import 'package:pool_os/features/tournament/domain/bracket_generator.dart';
import 'package:pool_os/features/tournament/domain/models/tournament_models.dart';
import 'package:pool_os/features/tournament/domain/standing_calculator.dart';

/// TASK 13 — Tournament & League.
///
/// Splits into two layers:
///  - pure-domain (BracketGenerator, StandingCalculator): seeding, byes, round
///    layout, standings sort — no DB.
///  - repository against an in-memory DB: create → add participants → generate
///    bracket → record results → winner auto-advances. Asserts the ONLY link to
///    the recording pipeline is a soft-ref matchId (deleting a tournament never
///    touches recorded matches). No AI.
void main() {
  group('BracketGenerator (Phần 2/4)', () {
    TournamentParticipant p(int id, {int? seed}) => TournamentParticipant(
          id: id,
          tournamentId: 1,
          name: 'P$id',
          seed: seed,
          createdAt: DateTime(2026, 7, 1),
        );

    test('seedOrder pairs top vs bottom seed', () {
      expect(BracketGenerator.seedOrder(2), [0, 1]);
      expect(BracketGenerator.seedOrder(4), [0, 3, 1, 2]);
      expect(BracketGenerator.seedOrder(8), [0, 7, 3, 4, 1, 6, 2, 5]);
    });

    test('nextPowerOfTwo rounds up', () {
      expect(BracketGenerator.nextPowerOfTwo(1), 1);
      expect(BracketGenerator.nextPowerOfTwo(3), 4);
      expect(BracketGenerator.nextPowerOfTwo(5), 8);
      expect(BracketGenerator.nextPowerOfTwo(8), 8);
    });

    test('orderBySeed puts seeded first (asc), unseeded after in order', () {
      final ordered = BracketGenerator.orderBySeed([
        p(1),
        p(2, seed: 2),
        p(3, seed: 1),
        p(4),
      ]);
      expect(ordered.map((e) => e.id).toList(), [3, 2, 1, 4]);
    });

    test('single elimination of 4 builds 2 first-round + 1 final, no byes', () {
      final layout = BracketGenerator.generate(
        type: TournamentType.singleElimination,
        participants: [p(1, seed: 1), p(2, seed: 2), p(3, seed: 3), p(4, seed: 4)],
        tournamentId: 1,
        now: DateTime(2026, 7, 1),
      );
      expect(layout.roundCount, 2);
      final r0 = layout.matches.where((m) => m.roundIndex == 0).toList();
      expect(r0.length, 2);
      // Seed 1 vs seed 4, seed 2 vs seed 3.
      expect(r0[0].participantAId, 1);
      expect(r0[0].participantBId, 4);
      expect(r0[1].participantAId, 2);
      expect(r0[1].participantBId, 3);
      expect(r0.every((m) => !m.isResolved), true); // no byes
    });

    test('3 players => 1 bye auto-resolves the top seed into round 2', () {
      final layout = BracketGenerator.generate(
        type: TournamentType.singleElimination,
        participants: [p(1, seed: 1), p(2, seed: 2), p(3, seed: 3)],
        tournamentId: 1,
        now: DateTime(2026, 7, 1),
      );
      final r0 = layout.matches.where((m) => m.roundIndex == 0).toList();
      // Bracket padded to 4: seed 1 gets a bye (opponent slot empty).
      final bye = r0.firstWhere((m) => m.participantBId == null);
      expect(bye.participantAId, 1);
      expect(bye.winnerParticipantId, 1); // auto-advanced
    });

    test('round robin of 4 builds every unique pair (6 fixtures)', () {
      final layout = BracketGenerator.generate(
        type: TournamentType.roundRobin,
        participants: [p(1), p(2), p(3), p(4)],
        tournamentId: 1,
        now: DateTime(2026, 7, 1),
      );
      expect(layout.matches.length, 6);
      final pairs = layout.matches
          .map((m) => '${m.participantAId}-${m.participantBId}')
          .toSet();
      expect(pairs, {'1-2', '1-3', '1-4', '2-3', '2-4', '3-4'});
    });

    test('parentSlot maps children to the correct next-round slot/side', () {
      // round 0 slot 0 -> round 1 slot 0 side A; slot 1 -> side B.
      expect(BracketGenerator.parentSlot(roundIndex: 0, slotIndex: 0, roundCount: 2),
          (roundIndex: 1, slotIndex: 0, isSideA: true));
      expect(BracketGenerator.parentSlot(roundIndex: 0, slotIndex: 1, roundCount: 2),
          (roundIndex: 1, slotIndex: 0, isSideA: false));
      // The final has no parent.
      expect(
          BracketGenerator.parentSlot(roundIndex: 1, slotIndex: 0, roundCount: 2),
          isNull);
    });
  });

  group('StandingCalculator (Phần 6)', () {
    TournamentParticipant p(int id) => TournamentParticipant(
          id: id,
          tournamentId: 1,
          name: 'P$id',
          createdAt: DateTime(2026, 7, 1),
        );

    TournamentMatch played(int a, int b, int winner,
            {int? sa, int? sb}) =>
        TournamentMatch(
          tournamentId: 1,
          roundIndex: 0,
          slotIndex: 0,
          participantAId: a,
          participantBId: b,
          winnerParticipantId: winner,
          scoreA: sa,
          scoreB: sb,
          createdAt: DateTime(2026, 7, 1),
        );

    test('standings tally W/L and sort by points then rack diff', () {
      final rows = StandingCalculator.standings(
        participants: [p(1), p(2), p(3)],
        matches: [
          played(1, 2, 1, sa: 5, sb: 3),
          played(1, 3, 1, sa: 5, sb: 0),
          played(2, 3, 2, sa: 5, sb: 4),
        ],
      );
      // P1: 2-0 (6 pts), P2: 1-1 (3 pts), P3: 0-2.
      expect(rows[0].participantId, 1);
      expect(rows[0].wins, 2);
      expect(rows[0].points, 6);
      expect(rows[1].participantId, 2);
      expect(rows[2].participantId, 3);
      expect(rows[2].wins, 0);
      expect(rows[2].losses, 2);
    });

    test('rack diff breaks a points tie', () {
      final rows = StandingCalculator.standings(
        participants: [p(1), p(2), p(3)],
        matches: [
          // P1 and P2 both finish 1-1, but P1 has the better rack diff.
          played(1, 3, 1, sa: 5, sb: 1),
          played(2, 3, 2, sa: 5, sb: 4),
          played(1, 2, 2, sa: 2, sb: 5),
        ],
      );
      final top = rows.where((r) => r.points == 3).toList();
      expect(top.first.participantId, 1); // +? diff ahead of P2
    });

    test('empty when nobody has played', () {
      final rows = StandingCalculator.standings(
        participants: [p(1), p(2)],
        matches: [
          TournamentMatch(
            tournamentId: 1,
            roundIndex: 0,
            slotIndex: 0,
            participantAId: 1,
            participantBId: 2,
            createdAt: DateTime(2026, 7, 1),
          ),
        ],
      );
      expect(rows.every((r) => r.matchesPlayed == 0), true);
    });
  });

  group('TournamentRepository (in-memory DB)', () {
    late AppDatabase db;
    late TournamentRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = TournamentRepository(db);
    });
    tearDown(() async => db.close());

    Future<int> makeTournament(TournamentType type) => repo.createTournament(
          Tournament(name: 'Cup', type: type, createdAt: DateTime(2026, 7, 1)),
        );

    Future<int> addP(int tId, String name, {int? seed}) => repo.addParticipant(
          TournamentParticipant(
            tournamentId: tId,
            name: name,
            seed: seed,
            createdAt: DateTime(2026, 7, 1),
          ),
        );

    test('create + read round-trips type and status', () async {
      final id = await makeTournament(TournamentType.league);
      final t = await repo.getTournamentById(id);
      expect(t, isNotNull);
      expect(t!.type, TournamentType.league);
      expect(t.status, TournamentStatus.upcoming);
    });

    test('generateBracket needs >= 2 participants', () async {
      final id = await makeTournament(TournamentType.singleElimination);
      await addP(id, 'Solo');
      expect(() => repo.generateBracket(id), throwsStateError);
    });

    test('recording a result advances the winner into the final', () async {
      final id = await makeTournament(TournamentType.singleElimination);
      final a = await addP(id, 'A', seed: 1);
      final b = await addP(id, 'B', seed: 2);
      final c = await addP(id, 'C', seed: 3);
      final d = await addP(id, 'D', seed: 4);
      await repo.generateBracket(id);

      var matches = await repo.getMatches(id);
      final r0 = matches.where((m) => m.roundIndex == 0).toList();
      // Resolve both first-round fixtures.
      await repo.recordResult(
          fixtureId: r0[0].id!, winnerParticipantId: a, scoreA: 5, scoreB: 2);
      await repo.recordResult(
          fixtureId: r0[1].id!, winnerParticipantId: c, scoreA: 5, scoreB: 1);

      matches = await repo.getMatches(id);
      final finalMatch = matches.firstWhere((m) => m.roundIndex == 1);
      // Winners A and C are fed into the final.
      expect({finalMatch.participantAId, finalMatch.participantBId}, {a, c});
      // B and D did not advance.
      expect(finalMatch.participantAId == b || finalMatch.participantBId == b,
          false);
      expect(finalMatch.participantAId == d || finalMatch.participantBId == d,
          false);
    });

    test('re-seeding refuses once a result exists', () async {
      final id = await makeTournament(TournamentType.singleElimination);
      await addP(id, 'A', seed: 1);
      await addP(id, 'B', seed: 2);
      await repo.generateBracket(id);
      final m = (await repo.getMatches(id)).first;
      await repo.recordResult(
          fixtureId: m.id!, winnerParticipantId: m.participantAId!);
      expect(() => repo.generateBracket(id), throwsStateError);
    });

    test('deleting a tournament removes its rows but keeps recorded matches',
        () async {
      // A recorded Match in the LOCKED pipeline (via a Session).
      final sessionId = await db.into(db.sessions).insert(
            SessionsCompanion.insert(
              sessionType: 'practice',
              startedAt: DateTime(2026, 7, 1),
            ),
          );
      final matchId = await db.into(db.matches).insert(
            MatchesCompanion.insert(
              sessionId: sessionId,
              matchNumber: 1,
              gameType: '9ball',
            ),
          );

      final id = await makeTournament(TournamentType.singleElimination);
      final a = await addP(id, 'A', seed: 1);
      await addP(id, 'B', seed: 2);
      await repo.generateBracket(id);
      final m = (await repo.getMatches(id)).first;
      // Link the fixture to the recorded Match (soft ref).
      await repo.recordResult(
          fixtureId: m.id!, winnerParticipantId: a, matchId: matchId);

      await repo.deleteTournament(id);

      // Tournament rows gone.
      expect(await repo.getTournamentById(id), isNull);
      expect(await repo.getParticipants(id), isEmpty);
      expect(await repo.getMatches(id), isEmpty);
      // The recorded Match is untouched.
      final stillThere = await (db.select(db.matches)
            ..where((t) => t.id.equals(matchId)))
          .getSingleOrNull();
      expect(stillThere, isNotNull);
    });
  });
}
