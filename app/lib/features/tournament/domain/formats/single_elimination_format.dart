// EPIC 04 — Single Elimination format (Beta).
//
// Reuses the existing BracketGenerator / advance logic that has shipped since
// Task 13. No new logic — this is a Strategy wrapper so the engine branches on
// [TournamentFormat] instead of hardcoding SE semantics. Phase II formats
// (Double Elimination, Round Robin, Swiss) live alongside without touching
// this code.

import 'package:pool_os/features/tournament/domain/bracket_generator.dart';
import 'package:pool_os/features/tournament/domain/capabilities.dart';
import 'package:pool_os/features/tournament/domain/formats/tournament_format.dart';
import 'package:pool_os/features/tournament/domain/models/tournament_models.dart';

class SingleEliminationFormat implements TournamentFormat {
  const SingleEliminationFormat();

  @override
  TournamentType get type => TournamentType.singleElimination;

  @override
  TournamentFormatCapability get capability => const TournamentFormatCapability(
        implemented: true,
        supported: true,
      );

  @override
  FormatGenerationResult generateInitialBracket({
    required int tournamentId,
    required List<TournamentParticipant> participants,
    required DateTime now,
    bool includeThirdPlace = false,
  }) {
    final result = const SingleEliminationBracketGenerator().generate(
      participants: participants,
      tournamentId: tournamentId,
      now: now,
      includeThirdPlace: includeThirdPlace,
    );
    if (result.isUnavailable) {
      return FormatGenerationResult.unavailable(result.notAvailable!);
    }
    return FormatGenerationResult.ok(result.layout!);
  }

  @override
  FormatParentSlotResult parentSlotFor({
    required int roundIndex,
    required int slotIndex,
    required int roundCount,
  }) {
    final raw = const SingleEliminationBracketGenerator().parentSlot(
      roundIndex: roundIndex,
      slotIndex: slotIndex,
      roundCount: roundCount,
    );
    if (raw.isUnavailable) {
      return FormatParentSlotResult.unavailable(raw.notAvailable!);
    }
    final slot = raw.slot;
    if (slot == null) {
      return FormatParentSlotResult.atFinal;
    }
    return FormatParentSlotResult.ok(slot);
  }

  @override
  bool isFinalMatch(TournamentMatch match, int roundCount) {
    return match.bracketGroup == 'M' &&
        match.roundIndex == roundCount - 1 &&
        match.roundIndex > 0;
  }

  @override
  ChampionResult detectChampion(List<TournamentMatch> allMatches) {
    final mainMatches = allMatches.where((m) => m.bracketGroup == 'M').toList();
    if (mainMatches.isEmpty) return ChampionResult.pending();
    final maxRound = mainMatches.map((m) => m.roundIndex).reduce(
          (a, b) => a > b ? a : b,
        );
    final finals = mainMatches
        .where((m) => m.roundIndex == maxRound && m.isResolved)
        .toList();
    if (finals.length != 1) return ChampionResult.pending();
    return ChampionResult.ok(finals.first.winnerParticipantId!);
  }
}