// EPIC 04 Phase 1 — abstraction tests for the 5 new layers.
//
// PO direction 2026-07-31 (capability pass):
//   - TournamentFormat (Strategy) — only Single Elim implements.
//   - BracketGenerator — separate interface, every format owns one.
//   - TournamentOverrideService — Phase 1 no audit; Phase 2 adds inside same
//     service so callers do not change.
//   - HandicapPolicy — Phase 1 RacePatchHandicap + NoHandicap.
//   - BracketValidator — sits between generator and service.
// PO direction 2026-07-31 (capability pattern):
//   - Placeholders DO NOT throw. They return NotAvailable result types so the
//     UI can read capability flags and disable the action gracefully.

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/tournament/application/tournament_service.dart';
import 'package:pool_os/features/tournament/domain/bracket_generator.dart';
import 'package:pool_os/features/tournament/domain/bracket_validator.dart';
import 'package:pool_os/features/tournament/domain/capabilities.dart';
import 'package:pool_os/features/tournament/domain/formats/placeholder_formats.dart';
import 'package:pool_os/features/tournament/domain/formats/single_elimination_format.dart';
import 'package:pool_os/features/tournament/domain/formats/tournament_format.dart';
import 'package:pool_os/features/tournament/domain/handicap_policy.dart';
import 'package:pool_os/features/tournament/domain/models/tournament_models.dart';
import 'package:pool_os/features/tournament/domain/override_service.dart';

void main() {
  final now = DateTime.utc(2026, 7, 31, 12);

  TournamentParticipant p(int id, {int? seed}) => TournamentParticipant(
        id: id,
        tournamentId: 1,
        playerId: id,
        name: 'P$id',
        seed: seed,
        createdAt: now,
      );

  TournamentMatch fixture({
    required int id,
    required int roundIndex,
    required int slotIndex,
    int? a,
    int? b,
    int? winner,
    String bracketGroup = 'M',
  }) =>
      TournamentMatch(
        id: id,
        tournamentId: 1,
        roundIndex: roundIndex,
        slotIndex: slotIndex,
        bracketGroup: bracketGroup,
        participantAId: a,
        participantBId: b,
        winnerParticipantId: winner,
        createdAt: now,
      );

  group('Capabilities — UI reads these to disable actions', () {
    test('Single Elimination format capability: implemented + supported', () {
      final fmt = tournamentFormatFor(TournamentType.singleElimination);
      expect(fmt.capability.implemented, isTrue);
      expect(fmt.capability.supported, isTrue);
      expect(fmt.capability.code, 'ready');
    });

    test('Double Elimination format capability: planned (no exception)', () {
      final fmt = tournamentFormatFor(TournamentType.doubleElimination);
      expect(fmt.capability.implemented, isFalse);
      expect(fmt.capability.supported, isTrue);
      expect(fmt.capability.code, 'planned');
    });

    test('Round Robin format capability: planned (no exception)', () {
      final fmt = tournamentFormatFor(TournamentType.roundRobin);
      expect(fmt.capability.implemented, isFalse);
      expect(fmt.capability.supported, isTrue);
      expect(fmt.capability.code, 'planned');
    });

    test('BracketGenerator capability mirrors format capability', () {
      expect(
        const SingleEliminationBracketGenerator().capability.implemented,
        isTrue,
      );
      expect(
        const DoubleEliminationBracketGenerator().capability.implemented,
        isFalse,
      );
      expect(
        const RoundRobinBracketGenerator().capability.implemented,
        isFalse,
      );
    });

    test('BracketValidator capability surfaces Phase 1 permissiveness', () {
      const v = PermissiveBracketValidator();
      expect(v.capability.implemented, isTrue);
      expect(v.capability.code, 'ready');
    });
  });

  group('TournamentFormat factory — no exceptions', () {
    test('singleElimination returns SE implementation', () {
      final fmt = tournamentFormatFor(TournamentType.singleElimination);
      expect(fmt, isA<SingleEliminationFormat>());
    });

    test('doubleElimination returns placeholder with stable code', () {
      final fmt = tournamentFormatFor(TournamentType.doubleElimination);
      expect(fmt, isA<DoubleEliminationFormat>());
      final result = fmt.generateInitialBracket(
        tournamentId: 1,
        participants: const [],
        now: now,
      );
      expect(result.isUnavailable, isTrue);
      expect(result.notAvailable!.code, 'tnmt.de_not_implemented');
    });

    test('roundRobin returns placeholder with stable code', () {
      final fmt = tournamentFormatFor(TournamentType.roundRobin);
      expect(fmt, isA<RoundRobinFormat>());
      final result = fmt.detectChampion(const []);
      expect(result.isUnavailable, isTrue);
      expect(result.notAvailable!.code, 'tnmt.rr_not_implemented');
    });

    test('league returns RoundRobin placeholder (Beta)', () {
      final fmt = tournamentFormatFor(TournamentType.league);
      expect(fmt, isA<RoundRobinFormat>());
    });
  });

  group('SingleEliminationFormat', () {
    test('seed 1 vs seed 2 meet in finals when only 2 entrants', () {
      const fmt = SingleEliminationFormat();
      final result = fmt.generateInitialBracket(
        tournamentId: 1,
        participants: [p(1, seed: 1), p(2, seed: 2)],
        now: now,
      );
      expect(result.isAvailable, isTrue);
      final layout = result.layout!;
      expect(layout.matches.length, 1);
      expect(layout.matches.first.roundIndex, 0);
      expect(layout.matches.first.participantAId, 1);
      expect(layout.matches.first.participantBId, 2);
      expect(layout.matches.first.winnerParticipantId, isNull);
    });

    test('PO bye rule: top seeds receive byes (auto-advance, no Win)', () {
      const fmt = SingleEliminationFormat();
      final result = fmt.generateInitialBracket(
        tournamentId: 1,
        participants: [p(1, seed: 1), p(2, seed: 2), p(3, seed: 3)],
        now: now,
      );
      expect(result.isAvailable, isTrue);
      final layout = result.layout!;
      // 3 entrants → size 4 → 2 round-0 + 1 round-1 = 3 fixtures, with
      // exactly 1 bye (auto-advance).
      expect(layout.matches.length, 3);

      final round0 = layout.matches.where((m) => m.roundIndex == 0).toList();
      final byeFixtures = round0
          .where((m) =>
              (m.participantAId == null) != (m.participantBId == null))
          .toList();
      expect(byeFixtures.length, 1,
          reason: '3 entrants → exactly 1 bye fixture in round 0.');
      final bye = byeFixtures.first;
      expect(bye.winnerParticipantId, isNotNull,
          reason: 'PO: bye is auto-advance — winner is set on generation.');
      final realId = bye.participantAId ?? bye.participantBId;
      expect(bye.winnerParticipantId, realId);
    });

    test('third-place fixture only for SE with hasThirdPlace flag', () {
      const fmt = SingleEliminationFormat();
      final result = fmt.generateInitialBracket(
        tournamentId: 1,
        participants: List.generate(4, (i) => p(i + 1, seed: i + 1)),
        now: now,
        includeThirdPlace: true,
      );
      expect(result.isAvailable, isTrue);
      final has3rd =
          result.layout!.matches.any((m) => m.bracketGroup == 'P');
      expect(has3rd, isTrue);
    });

    test('detectChampion returns pending until final is resolved', () {
      const fmt = SingleEliminationFormat();
      final result = fmt.generateInitialBracket(
        tournamentId: 1,
        participants: List.generate(4, (i) => p(i + 1, seed: i + 1)),
        now: now,
      );
      final champion = fmt.detectChampion(result.layout!.matches);
      expect(champion.isPending, isTrue);
    });

    test('detectChampion returns final winner once resolved', () {
      const fmt = SingleEliminationFormat();
      final result = fmt.generateInitialBracket(
        tournamentId: 1,
        participants: List.generate(2, (i) => p(i + 1, seed: i + 1)),
        now: now,
      );
      expect(result.layout!.matches.length, 1);
      final resolved = result.layout!.matches
          .map((m) => m.copyWith(winnerParticipantId: m.participantAId))
          .toList();
      final champion = fmt.detectChampion(resolved);
      expect(champion.isAvailable, isTrue);
      expect(champion.championId, isIn([1, 2]));
    });
  });

  group('BracketGenerator abstraction — capability-driven', () {
    test('SE generator handles non-power-of-two with byes', () {
      const gen = SingleEliminationBracketGenerator();
      final result = gen.generate(
        participants: [p(1, seed: 1), p(2), p(3), p(4), p(5)],
        tournamentId: 1,
        now: now,
      );
      expect(result.isAvailable, isTrue);
      // 5 entrants → size 8 → 4 round-0 + 2 + 1 = 7 fixtures.
      expect(result.layout!.matches.length, 7);
    });

    test('SE generator parentSlot returns null at final (atFinal sentinel)',
        () {
      const gen = SingleEliminationBracketGenerator();
      final result = gen.generate(
        participants: List.generate(4, (i) => p(i + 1, seed: i + 1)),
        tournamentId: 1,
        now: now,
      );
      final rc = result.layout!.roundCount;
      final lastRound =
          result.layout!.matches.lastWhere((m) => m.roundIndex == rc - 1);
      final out = gen.parentSlot(
        roundIndex: lastRound.roundIndex,
        slotIndex: lastRound.slotIndex,
        roundCount: rc,
      );
      expect(out.slot, isNull);
      expect(out.notAvailable, isNull);
    });

    test('SE generator parentSlot maps 0,0 → 1,0 side A', () {
      const gen = SingleEliminationBracketGenerator();
      final out = gen.parentSlot(
        roundIndex: 0,
        slotIndex: 0,
        roundCount: 3,
      );
      expect(out.isAvailable, isTrue);
      expect(out.slot!.roundIndex, 1);
      expect(out.slot!.slotIndex, 0);
      expect(out.slot!.isSideA, isTrue);
      expect(out.slot!.bracketGroup, 'M');
    });

    test('DE/RR generators return NotAvailable on invoke (NO exception)', () {
      final deResult = const DoubleEliminationBracketGenerator().generate(
        participants: [p(1)],
        tournamentId: 1,
        now: now,
      );
      expect(deResult.isUnavailable, isTrue);
      expect(deResult.notAvailable!.code, 'tnmt.de_not_implemented');

      final rrResult = const RoundRobinBracketGenerator().generate(
        participants: [p(1)],
        tournamentId: 1,
        now: now,
      );
      expect(rrResult.isUnavailable, isTrue);
      expect(rrResult.notAvailable!.code, 'tnmt.rr_not_implemented');

      final rrParent = const RoundRobinBracketGenerator().parentSlot(
        roundIndex: 0,
        slotIndex: 0,
        roundCount: 2,
      );
      expect(rrParent.isUnavailable, isTrue);
    });
  });

  group('BracketValidator (Phase 1 permissive)', () {
    test('validate returns empty report for any bracket', () {
      const v = PermissiveBracketValidator();
      final report = v.validate(participants: const [], bracket: const []);
      expect(report.isValid, isTrue);
      expect(report.issues, isEmpty);
    });

    test('validate works for a populated SE bracket', () {
      const v = PermissiveBracketValidator();
      final fmt = const SingleEliminationFormat();
      final gen = const SingleEliminationBracketGenerator();
      final layout = gen.generate(
        participants: List.generate(4, (i) => p(i + 1, seed: i + 1)),
        tournamentId: 1,
        now: now,
      );
      final report = v.validate(
        participants: [
          p(1, seed: 1),
          p(2, seed: 2),
          p(3, seed: 3),
          p(4, seed: 4),
        ],
        bracket: layout.layout!.matches,
      );
      expect(report.isValid, isTrue);
      // fmt is referenced to keep it alive in case future tests need it.
      expect(fmt.capability.implemented, isTrue);
    });

    test('StrictBracketValidator placeholder returns empty (capability says planned)',
        () {
      const v = StrictBracketValidator();
      expect(v.capability.implemented, isFalse);
      final report = v.validate(participants: const [], bracket: const []);
      expect(report.isValid, isTrue,
          reason: 'Phase 1 placeholder must never false-positive.');
    });
  });

  group('TournamentOverrideService', () {
    test('Phase 1 service: recordsAuditHistory is false', () {
      const svc = SimpleTournamentOverrideService();
      expect(svc.recordsAuditHistory, isFalse);
    });

    test('Phase 1 service: returns updated match, history null', () {
      const svc = SimpleTournamentOverrideService();
      final m = fixture(id: 1, roundIndex: 0, slotIndex: 0, a: 1, b: 2);
      final out = svc.overrideWinner(
        match: m,
        newWinnerId: 2,
        bracket: [m],
        roundCount: 1,
        now: now,
      );
      expect(out.updatedMatch.winnerParticipantId, 2);
      expect(out.history, isNull);
    });
  });

  group('HandicapPolicy — capability-driven', () {
    test('NoHandicap returns baseRace for both sides', () {
      const h = NoHandicap();
      expect(h.implemented, isTrue);
      final r = h.resolveRace(
        participantAId: 1,
        participantBId: 2,
        baseRace: 7,
      );
      expect(r.isAvailable, isTrue);
      expect(r.race!.playerA, 7);
      expect(r.race!.playerB, 7);
      expect(h.code, 'none');
    });

    test('RacePatchHandicap returns per-fixture {playerA, playerB}', () {
      const h = RacePatchHandicap(
        patches: {'1|2': HandicapRace(playerA: 7, playerB: 5)},
      );
      expect(h.implemented, isTrue);
      final r = h.resolveRace(
        participantAId: 1,
        participantBId: 2,
        baseRace: 7,
      );
      expect(r.race!.playerA, 7);
      expect(r.race!.playerB, 5);
      expect(h.code, 'race_patch');
    });

    test('RacePatchHandicap falls back to baseRace when key missing', () {
      const h = RacePatchHandicap();
      final r = h.resolveRace(
        participantAId: 9,
        participantBId: 10,
        baseRace: 9,
      );
      expect(r.race!.playerA, 9);
      expect(r.race!.playerB, 9);
    });

    test('RacePatchHandicap accepts fallback override', () {
      const h = RacePatchHandicap(
        fallback: HandicapRace(playerA: 6, playerB: 6),
      );
      final r = h.resolveRace(
        participantAId: 9,
        participantBId: 10,
        baseRace: 9,
      );
      expect(r.race!.playerA, 6);
      expect(r.race!.playerB, 6);
    });

    test('ApaHandicap placeholder returns NotAvailable (no throw)', () {
      const h = ApaHandicap();
      expect(h.implemented, isFalse);
      final r = h.resolveRace(
        participantAId: 1,
        participantBId: 2,
        baseRace: 7,
      );
      expect(r.isUnavailable, isTrue);
      expect(r.notAvailable!.code, 'tnmt.handicap_apa_not_implemented');
    });

    test('FixedRaceHandicap returns same race both sides', () {
      const h = FixedRaceHandicap(9);
      final r = h.resolveRace(
        participantAId: 1,
        participantBId: 2,
        baseRace: 7,
      );
      expect(r.race!.playerA, 9);
      expect(r.race!.playerB, 9);
    });
  });

  group('TournamentService orchestration', () {
    test('buildOpeningBracket delegates to format + generator', () {
      final svc = TournamentService();
      final t = Tournament(
        id: 1,
        name: 'Open',
        type: TournamentType.singleElimination,
        status: TournamentStatus.upcoming,
        createdAt: now,
      );
      final result = svc.buildOpeningBracket(
        tournament: t,
        participants: List.generate(8, (i) => p(i + 1, seed: i + 1)),
        now: now,
      );
      expect(result.isAvailable, isTrue);
      // 8 entrants → 8 fixtures: 4 + 2 + 1 + 1 final.
      expect(result.layout!.matches.length, 7);
    });

    test('buildOpeningBracket returns NotAvailable for non-SE formats', () {
      final svc = TournamentService();
      final t = Tournament(
        id: 1,
        name: 'RR',
        type: TournamentType.roundRobin,
        hasThirdPlaceMatch: true, // should be ignored for RR
        status: TournamentStatus.upcoming,
        createdAt: now,
      );
      final result = svc.buildOpeningBracket(
        tournament: t,
        participants: [p(1), p(2), p(3), p(4)],
        now: now,
      );
      expect(result.isUnavailable, isTrue,
          reason: 'RR is architecture-ready only — service returns NotAvailable.');
      expect(result.notAvailable!.code, 'tnmt.rr_not_implemented');
    });

    test('validateBracket delegates to validator (service does not validate)',
        () {
      final svc = TournamentService();
      final t = Tournament(
        id: 1,
        name: 'Open',
        type: TournamentType.singleElimination,
        createdAt: now,
      );
      final report = svc.validateBracket(
        tournament: t,
        participants: const [],
        bracket: const [],
      );
      expect(report.isValid, isTrue);
    });

    test('canEditSeeding only in upcoming', () {
      final svc = TournamentService();
      expect(svc.canEditSeeding(TournamentPhase.upcoming), isTrue);
      expect(svc.canEditSeeding(TournamentPhase.running), isFalse);
      expect(svc.canEditSeeding(TournamentPhase.completed), isFalse);
    });

    test('canRegenerateBracket only in upcoming (PO principle 8)', () {
      final svc = TournamentService();
      expect(svc.canRegenerateBracket(TournamentPhase.upcoming), isTrue);
      expect(svc.canRegenerateBracket(TournamentPhase.running), isFalse);
    });

    test('canOverrideWinner allowed in upcoming + running, blocked completed',
        () {
      final svc = TournamentService();
      expect(svc.canOverrideWinner(TournamentPhase.upcoming), isTrue);
      expect(svc.canOverrideWinner(TournamentPhase.running), isTrue);
      expect(svc.canOverrideWinner(TournamentPhase.completed), isFalse);
    });

    test('createMatchRequest carries race from policy (PO principle 7)', () {
      final svc = TournamentService();
      const policy = RacePatchHandicap(
        patches: {'1|2': HandicapRace(playerA: 7, playerB: 5)},
      );
      final t = Tournament(
        id: 1,
        name: 'Open',
        type: TournamentType.singleElimination,
        createdAt: now,
      );
      final m = fixture(id: 1, roundIndex: 0, slotIndex: 0, a: 1, b: 2);
      final result = svc.createMatchRequest(
        tournament: t,
        fixture: m,
        handicapPolicy: policy,
        baseRace: 7,
        requestedAt: now,
      );
      expect(result.isAvailable, isTrue);
      expect(result.request!.racePlayerA, 7);
      expect(result.request!.racePlayerB, 5);
      expect(result.request!.handicapPolicyCode, 'race_patch');
      expect(result.request!.tournamentId, 1);
      expect(result.request!.fixtureId, 1);
    });

    test('createMatchRequest returns NotAvailable when policy unimplemented',
        () {
      final svc = TournamentService();
      const policy = ApaHandicap();
      final t = Tournament(
        id: 1,
        name: 'Open',
        type: TournamentType.singleElimination,
        createdAt: now,
      );
      final m = fixture(id: 1, roundIndex: 0, slotIndex: 0, a: 1, b: 2);
      final result = svc.createMatchRequest(
        tournament: t,
        fixture: m,
        handicapPolicy: policy,
        baseRace: 7,
        requestedAt: now,
      );
      expect(result.isUnavailable, isTrue);
      expect(result.notAvailable!.code, 'tnmt.handicap_unavailable');
    });

    test('advanceWinner returns ParentSlotAdvance coordinates', () {
      final svc = TournamentService();
      final t = Tournament(
        id: 1,
        name: 'Open',
        type: TournamentType.singleElimination,
        createdAt: now,
      );
      final bracket = [
        fixture(id: 1, roundIndex: 0, slotIndex: 0, a: 1, b: 2),
        fixture(id: 2, roundIndex: 1, slotIndex: 0),
      ];
      final resolved =
          bracket.first.copyWith(winnerParticipantId: 1);
      final result = svc.advanceWinner(
        tournament: t,
        resolvedFixture: resolved,
        bracket: bracket,
        roundCount: 2,
        winnerParticipantId: 1,
        now: now,
      );
      expect(result.isAvailable, isTrue);
      final advance = result.advance!;
      expect(advance.roundIndex, 1);
      expect(advance.slotIndex, 0);
      expect(advance.bracketGroup, 'M');
      expect(advance.isSideA, isTrue);
      expect(advance.winnerParticipantId, 1);
    });

    test('advanceWinner returns atFinal sentinel at final (PO principle 6)', () {
      final svc = TournamentService();
      final t = Tournament(
        id: 1,
        name: 'Open',
        type: TournamentType.singleElimination,
        createdAt: now,
      );
      final bracket = [
        fixture(id: 1, roundIndex: 0, slotIndex: 0, a: 1, b: 2, winner: 1),
        fixture(id: 2, roundIndex: 1, slotIndex: 0, a: 1, b: 3, winner: 1),
      ];
      final resolved = bracket.last;
      final result = svc.advanceWinner(
        tournament: t,
        resolvedFixture: resolved,
        bracket: bracket,
        roundCount: 2,
        winnerParticipantId: 1,
        now: now,
      );
      expect(result.isAtFinal, isTrue);
    });

    test('applyManualOverride returns updated match (no audit yet)', () {
      final svc = TournamentService();
      final m = fixture(id: 1, roundIndex: 0, slotIndex: 0, a: 1, b: 2);
      final out = svc.applyManualOverride(
        fixture: m,
        newWinnerId: 2,
        bracket: [m],
        roundCount: 2,
        now: now,
      );
      expect(out.updatedMatch.winnerParticipantId, 2);
      expect(out.history, isNull,
          reason: 'Phase 2 will populate history without changing this API.');
    });
  });
}