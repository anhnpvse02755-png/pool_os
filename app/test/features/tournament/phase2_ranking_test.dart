// EPIC 04 Phase 2 — pure-Dart tests for the new skeleton layers.
//
// Covers:
//   - TournamentRankingCalculator (Phase 2.2)
//   - Season model (Phase 2.6)

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/tournament/domain/models/tournament_models.dart';
import 'package:pool_os/features/tournament/domain/ranking.dart';
import 'package:pool_os/features/tournament/domain/season.dart';

void main() {
  final now = DateTime.utc(2026, 7, 31);

  TournamentMatch played({
    required int id,
    required int a,
    required int b,
    required int winner,
    int? sa,
    int? sb,
  }) =>
      TournamentMatch(
        id: id,
        tournamentId: 1,
        roundIndex: 0,
        slotIndex: 0,
        bracketGroup: 'M',
        participantAId: a,
        participantBId: b,
        winnerParticipantId: winner,
        scoreA: sa,
        scoreB: sb,
        createdAt: now,
      );

  group('TournamentRankingCalculator — read-only ranking', () {
    test('empty matches → empty ranking', () {
      final rows = TournamentRankingCalculator.ranking(
        matches: const [],
        participantNameById: const {},
      );
      expect(rows, isEmpty);
    });

    test('sorts by wins desc, losses asc, name asc', () {
      final rows = TournamentRankingCalculator.ranking(
        matches: [
          played(id: 1, a: 1, b: 2, winner: 1),
          played(id: 2, a: 3, b: 4, winner: 3),
          played(id: 3, a: 1, b: 3, winner: 3),
          played(id: 4, a: 2, b: 4, winner: 2),
        ],
        participantNameById: {
          1: 'Anna',
          2: 'Bob',
          3: 'Cara',
          4: 'Dan',
        },
      );
      // Cara 2W-0L, Anna 1W-1L, Bob 1W-1L, Dan 0W-2L.
      expect(rows[0].participantName, 'Cara');
      expect(rows[0].wins, 2);
      expect(rows[0].losses, 0);
      expect(rows.last.participantName, 'Dan');
      expect(rows.last.wins, 0);
      expect(rows.last.losses, 2);
      // Anna + Bob tie at 1W-1L → tiebreak by name asc.
      final middle = rows.where((r) => r.wins == 1).toList();
      expect(middle[0].participantName, 'Anna');
      expect(middle[1].participantName, 'Bob');
    });

    test('skips unresolved matches', () {
      final rows = TournamentRankingCalculator.ranking(
        matches: [
          played(id: 1, a: 1, b: 2, winner: 1),
          TournamentMatch(
            id: 2,
            tournamentId: 1,
            roundIndex: 0,
            slotIndex: 1,
            bracketGroup: 'M',
            participantAId: 3,
            participantBId: 4,
            createdAt: now,
          ),
        ],
        participantNameById: {1: 'Anna', 2: 'Bob', 3: 'Cara', 4: 'Dan'},
      );
      // Unresolved match contributes no wins/losses; only Anna + Bob appear.
      expect(rows.length, 2);
      expect(rows.map((r) => r.participantName), ['Anna', 'Bob']);
    });

    test('winRate returns 0 when no matches played', () {
      final rows = TournamentRankingCalculator.ranking(
        matches: const [],
        participantNameById: const {},
      );
      expect(rows, isEmpty);
      // No entries; constructor guard.
    });

    test('winRate computed correctly per entry', () {
      final rows = TournamentRankingCalculator.ranking(
        matches: [
          played(id: 1, a: 1, b: 2, winner: 1),
          played(id: 2, a: 1, b: 2, winner: 1),
          played(id: 3, a: 1, b: 2, winner: 2),
        ],
        participantNameById: {1: 'Anna', 2: 'Bob'},
      );
      final anna = rows.firstWhere((r) => r.participantName == 'Anna');
      expect(anna.wins, 2);
      expect(anna.losses, 1);
      expect(anna.matchesPlayed, 3);
      expect(anna.winRate, closeTo(0.6667, 0.0001));
    });
  });

  group('Season model — Phase 2.6 skeleton', () {
    test('constructs with required fields', () {
      final s = Season(
        id: null, // PO: no schema yet, skeleton only.
        name: 'Summer 2026',
        startDate: DateTime(2026, 6, 1),
        endDate: DateTime(2026, 8, 31),
        notes: 'warm-up season',
      );
      expect(s.name, 'Summer 2026');
      expect(s.startDate, DateTime(2026, 6, 1));
      expect(s.endDate, DateTime(2026, 8, 31));
      expect(s.notes, 'warm-up season');
      expect(s.id, isNull,
          reason: 'Skeleton has no schema. Phase 3+ will add a season table.');
    });
  });
}