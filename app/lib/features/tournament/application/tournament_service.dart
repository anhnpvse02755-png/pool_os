// EPIC 04 — Tournament Service.
//
// PO direction 2026-07-31 — 8 architectural principles:
//   1. TournamentFormat       — specifies the rules (Strategy).
//   2. BracketGenerator        — specifies how to lay out the bracket.
//   3. TournamentOverrideService — applies manual override + future audit.
//   4. HandicapPolicy          — resolves race-to per fixture (object).
//   5. RacePatchHandicap       — Beta handicap, {playerA, playerB} object.
//   6. TournamentService       — orchestration ONLY. No business rule.
//   7. Match Engine (EPIC 01)  — single source of truth for Match.
//   8. Bracket immutable after Tournament → Running.
//
// PO 2026-07-31 (second pass):
//   - Capability-based: methods return NotAvailable result types instead of
//     throwing UnsupportedError. UI reads capability and disables.
//   - BracketValidator sits between BracketGenerator and TournamentService.
//     The service composes them and never validates bracket math itself.
//
// The service composes these collaborators and persists through the existing
// TournamentRepository. It NEVER writes to matches / racks / shots — that
// belongs to EPIC 01.

import 'package:pool_os/features/tournament/domain/bracket_generator.dart';
import 'package:pool_os/features/tournament/domain/bracket_validator.dart';
import 'package:pool_os/features/tournament/domain/capabilities.dart';
import 'package:pool_os/features/tournament/domain/formats/tournament_format.dart';
import 'package:pool_os/features/tournament/domain/handicap_policy.dart';
import 'package:pool_os/features/tournament/domain/models/tournament_models.dart';
import 'package:pool_os/features/tournament/domain/override_service.dart';

/// Status the service recognises. Maps to [TournamentStatus] codes.
enum TournamentPhase { upcoming, running, completed }

extension TournamentPhaseX on TournamentPhase {
  TournamentStatus toStatus() {
    switch (this) {
      case TournamentPhase.upcoming:
        return TournamentStatus.upcoming;
      case TournamentPhase.running:
        return TournamentStatus.active;
      case TournamentPhase.completed:
        return TournamentStatus.completed;
    }
  }

  String get code => toStatus().code;
}

class TournamentService {
  final Map<TournamentType, BracketGenerator> _generators;
  final Map<TournamentType, TournamentFormat> _formats;
  final Map<TournamentType, BracketValidator> _validators;
  final TournamentOverrideService _overrideService;

  TournamentService({
    Map<TournamentType, BracketGenerator>? generators,
    Map<TournamentType, TournamentFormat>? formats,
    Map<TournamentType, BracketValidator>? validators,
    TournamentOverrideService? overrideService,
  })  : _generators = generators ??
            const {
              TournamentType.singleElimination:
                  SingleEliminationBracketGenerator(),
              TournamentType.doubleElimination:
                  DoubleEliminationBracketGenerator(),
              TournamentType.roundRobin: RoundRobinBracketGenerator(),
              TournamentType.league: RoundRobinBracketGenerator(),
            },
        _formats = formats ?? const {},
        _validators = validators ??
            const {
              TournamentType.singleElimination: PermissiveBracketValidator(),
            },
        _overrideService = overrideService ??
            const SimpleTournamentOverrideService();

  /// Resolve a format for a tournament.
  TournamentFormat formatFor(TournamentType type) =>
      _formats[type] ?? tournamentFormatFor(type);

  BracketGenerator generatorFor(TournamentType type) =>
      _generators[type] ?? _generators[TournamentType.singleElimination]!;

  BracketValidator validatorFor(TournamentType type) =>
      _validators[type] ?? const PermissiveBracketValidator();

  TournamentOverrideService get overrideService => _overrideService;

  // ---------------------------------------------------------------------------
  // 1. Bracket creation — PO principle 6: no rule logic here.
  // ---------------------------------------------------------------------------

  /// Build the opening bracket layout for [tournament]. Returns
  /// [FormatGenerationResult] so the caller can branch on NotAvailable.
  FormatGenerationResult buildOpeningBracket({
    required Tournament tournament,
    required List<TournamentParticipant> participants,
    required DateTime now,
  }) {
    final format = formatFor(tournament.type);
    // Format owns whether 3rd place is allowed for this type. SE: yes when
    // flag set. DE/RR: format decides (Phase 2+).
    final includeThird = tournament.hasThirdPlaceMatch &&
        format.capability.implemented &&
        format.type == TournamentType.singleElimination;
    return format.generateInitialBracket(
      tournamentId: tournament.id ?? 0,
      participants: participants,
      now: now,
      includeThirdPlace: includeThird,
    );
  }

  /// Validate a freshly built bracket before persisting. The service does
  /// NOT itself validate — it delegates to [BracketValidator] (PO 2026-07-31).
  /// Returns [BracketValidationReport]; the caller checks `.isValid`.
  BracketValidationReport validateBracket({
    required Tournament tournament,
    required List<TournamentParticipant> participants,
    required List<TournamentMatch> bracket,
  }) {
    return validatorFor(tournament.type).validate(
      participants: participants,
      bracket: bracket,
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Start gate — PO principle 8: bracket is immutable after this point.
  // ---------------------------------------------------------------------------

  bool canEditSeeding(TournamentPhase phase) =>
      phase == TournamentPhase.upcoming;

  bool canRegenerateBracket(TournamentPhase phase) =>
      phase == TournamentPhase.upcoming;

  bool canOverrideWinner(TournamentPhase phase) =>
      phase == TournamentPhase.running || phase == TournamentPhase.upcoming;

  // ---------------------------------------------------------------------------
  // 3. Match request — PO principle 7.
  // ---------------------------------------------------------------------------

  /// Request to record a match for a bracket fixture. The Match pipeline is
  /// the single source of truth — this object carries the data the caller
  /// hands to EPIC 01. If the handicap policy returns [NotAvailable], the
  /// caller decides whether to surface that to the user or fall back.
  MatchRequestResult createMatchRequest({
    required Tournament tournament,
    required TournamentMatch fixture,
    required HandicapPolicy handicapPolicy,
    int baseRace = 7,
    DateTime? requestedAt,
  }) {
    if (!handicapPolicy.implemented) {
      return MatchRequestResult.unavailable(
        NotAvailable(
          code: 'tnmt.handicap_unavailable',
          reason: 'Handicap policy "${handicapPolicy.code}" is not implemented '
              'in Beta. Use NoHandicap or RacePatchHandicap.',
        ),
      );
    }
    final result = handicapPolicy.resolveRace(
      participantAId: fixture.participantAId ?? 0,
      participantBId: fixture.participantBId ?? 0,
      baseRace: baseRace,
    );
    if (result.isUnavailable) {
      return MatchRequestResult.unavailable(result.notAvailable!);
    }
    return MatchRequestResult.ok(MatchRequest(
      tournamentId: tournament.id ?? 0,
      fixtureId: fixture.id ?? 0,
      participantAId: fixture.participantAId,
      participantBId: fixture.participantBId,
      racePlayerA: result.race!.playerA,
      racePlayerB: result.race!.playerB,
      handicapPolicyCode: handicapPolicy.code,
      requestedAt: requestedAt ?? DateTime.now(),
    ));
  }

  // ---------------------------------------------------------------------------
  // 4. Advance — PO principle 6: the format decides where the winner goes.
  // ---------------------------------------------------------------------------

  /// Cascade a resolved winner into its parent slot. Returns
  /// [AdvanceResult]; NotAvailable if the format is not implemented.
  AdvanceResult advanceWinner({
    required Tournament tournament,
    required TournamentMatch resolvedFixture,
    required List<TournamentMatch> bracket,
    required int roundCount,
    required int winnerParticipantId,
    required DateTime now,
  }) {
    final format = formatFor(tournament.type);
    if (!format.capability.implemented) {
      // The placeholder surfaces its own NotAvailable when invoked.
    }
    final slotResult = format.parentSlotFor(
      roundIndex: resolvedFixture.roundIndex,
      slotIndex: resolvedFixture.slotIndex,
      roundCount: roundCount,
    );
    if (slotResult.isUnavailable) {
      return AdvanceResult.unavailable(slotResult.notAvailable!);
    }
    final slot = slotResult.slot;
    if (slot == null) {
      // No parent — we are at the final.
      return const AdvanceResult._null(null, null);
    }
    final parentExists = bracket.any(
      (m) =>
          m.roundIndex == slot.roundIndex &&
          m.slotIndex == slot.slotIndex &&
          m.bracketGroup == slot.bracketGroup,
    );
    if (!parentExists) {
      return AdvanceResult.unavailable(NotAvailable(
        code: 'tnmt.parent_slot_missing',
        reason: 'Parent slot ${slot.roundIndex}/${slot.slotIndex}/'
            '${slot.bracketGroup} missing from bracket — engine invariant '
            'violated.',
      ));
    }
    return AdvanceResult.ok(ParentSlotAdvance(
      roundIndex: slot.roundIndex,
      slotIndex: slot.slotIndex,
      bracketGroup: slot.bracketGroup,
      isSideA: slot.isSideA,
      winnerParticipantId: winnerParticipantId,
    ));
  }

  // ---------------------------------------------------------------------------
  // 5. Manual override — PO principle 3.
  // ---------------------------------------------------------------------------

  OverrideOutcome applyManualOverride({
    required TournamentMatch fixture,
    required int newWinnerId,
    required List<TournamentMatch> bracket,
    required int roundCount,
    required DateTime now,
  }) {
    return _overrideService.overrideWinner(
      match: fixture,
      newWinnerId: newWinnerId,
      bracket: bracket,
      roundCount: roundCount,
      now: now,
    );
  }

  // ---------------------------------------------------------------------------
  // 6. Champion — PO principle 6.
  // ---------------------------------------------------------------------------

  ChampionResult detectChampion(
    List<TournamentMatch> bracket,
    TournamentType type,
  ) {
    return formatFor(type).detectChampion(bracket);
  }
}

/// Result of [TournamentService.advanceWinner]. Coordinates when available,
/// `null` if at the final (parent slot is null-equivalent), or NotAvailable.
class AdvanceResult {
  final ParentSlotAdvance? advance;
  final NotAvailable? notAvailable;
  const AdvanceResult._(this.advance, this.notAvailable);

  bool get isAvailable => advance != null;
  bool get isUnavailable => notAvailable != null;

  factory AdvanceResult.ok(ParentSlotAdvance advance) =>
      AdvanceResult._(advance, null);
  factory AdvanceResult.unavailable(NotAvailable na) =>
      AdvanceResult._(null, na);
  // ignore: unused_element_parameter
  const AdvanceResult._null(ParentSlotAdvance? a, NotAvailable? n) : this._(null, null);

  bool get isAtFinal => advance == null && notAvailable == null;
}

/// Result of [TournamentService.createMatchRequest]. Either a populated
/// [MatchRequest] or a [NotAvailable].
class MatchRequestResult {
  final MatchRequest? request;
  final NotAvailable? notAvailable;
  const MatchRequestResult._(this.request, this.notAvailable);

  bool get isAvailable => request != null;
  bool get isUnavailable => notAvailable != null;

  factory MatchRequestResult.ok(MatchRequest req) =>
      MatchRequestResult._(req, null);
  factory MatchRequestResult.unavailable(NotAvailable na) =>
      MatchRequestResult._(null, na);
}

/// Coordinates returned by [TournamentService.advanceWinner]. The repository
/// uses these to locate the parent row in Drift and write the winner.
class ParentSlotAdvance {
  final int roundIndex;
  final int slotIndex;
  final String bracketGroup;
  final bool isSideA;
  final int winnerParticipantId;

  const ParentSlotAdvance({
    required this.roundIndex,
    required this.slotIndex,
    required this.bracketGroup,
    required this.isSideA,
    required this.winnerParticipantId,
  });
}

/// A pure-Dart record handed to the Match pipeline (EPIC 01). The service
/// does not implement matching, recording, or scoring.
class MatchRequest {
  final int tournamentId;
  final int fixtureId;
  final int? participantAId;
  final int? participantBId;
  final int racePlayerA;
  final int racePlayerB;
  final String handicapPolicyCode;
  final DateTime requestedAt;

  const MatchRequest({
    required this.tournamentId,
    required this.fixtureId,
    required this.participantAId,
    required this.participantBId,
    required this.racePlayerA,
    required this.racePlayerB,
    required this.handicapPolicyCode,
    required this.requestedAt,
  });
}