// EPIC 04 — Placeholder formats (architecture-ready only).
//
// Per PO direction 2026-07-31, Double Elimination / Round Robin / Swiss
// are NOT implemented in Beta. These classes exist so:
//   - The TournamentFormat surface is complete and stable.
//   - The UI can surface labels and a friendly "coming soon" tooltip via
//     [TournamentFormatCapability].
//   - Future EPIC 09 (Advanced Tournament) adds implementations WITHOUT
//     touching TournamentService or MatchEngine.
//
// Every concrete method returns a [NotAvailable]-typed result instead of
// throwing [UnsupportedError]. The UI reads capability and disables the
// action; the service returns NotAvailable without forcing every caller to
// wrap a try/catch.

import 'package:pool_os/features/tournament/domain/capabilities.dart';
import 'package:pool_os/features/tournament/domain/formats/tournament_format.dart';
import 'package:pool_os/features/tournament/domain/models/tournament_models.dart';

class DoubleEliminationFormat implements TournamentFormat {
  const DoubleEliminationFormat();

  @override
  TournamentType get type => TournamentType.doubleElimination;

  @override
  TournamentFormatCapability get capability => const TournamentFormatCapability(
        implemented: false,
        supported: true, // planned, but not built yet
      );

  @override
  FormatGenerationResult generateInitialBracket({
    required int tournamentId,
    required List<TournamentParticipant> participants,
    required DateTime now,
    bool includeThirdPlace = false,
  }) {
    return FormatGenerationResult.unavailable(notAvailableDoubleElimination);
  }

  @override
  FormatParentSlotResult parentSlotFor({
    required int roundIndex,
    required int slotIndex,
    required int roundCount,
  }) {
    return FormatParentSlotResult.unavailable(notAvailableDoubleElimination);
  }

  @override
  bool isFinalMatch(TournamentMatch match, int roundCount) {
    // Even when not implemented, we expose a deterministic no-op so the UI
    // can safely call this for any bracket row.
    return false;
  }

  @override
  ChampionResult detectChampion(List<TournamentMatch> allMatches) {
    return ChampionResult.unavailable(notAvailableDoubleElimination);
  }
}

class RoundRobinFormat implements TournamentFormat {
  const RoundRobinFormat();

  @override
  TournamentType get type => TournamentType.roundRobin;

  @override
  TournamentFormatCapability get capability => const TournamentFormatCapability(
        implemented: false,
        supported: true,
      );

  @override
  FormatGenerationResult generateInitialBracket({
    required int tournamentId,
    required List<TournamentParticipant> participants,
    required DateTime now,
    bool includeThirdPlace = false,
  }) {
    return FormatGenerationResult.unavailable(notAvailableRoundRobin);
  }

  @override
  FormatParentSlotResult parentSlotFor({
    required int roundIndex,
    required int slotIndex,
    required int roundCount,
  }) {
    return FormatParentSlotResult.unavailable(notAvailableRoundRobin);
  }

  @override
  bool isFinalMatch(TournamentMatch match, int roundCount) => false;

  @override
  ChampionResult detectChampion(List<TournamentMatch> allMatches) {
    return ChampionResult.unavailable(notAvailableRoundRobin);
  }
}

// NOTE: Swiss is intentionally absent. PO 2026-07-31 placed Swiss in EPIC 09,
// outside the Beta scope. The factory at tournament_format.dart will gain a
// SwissFormat class when that Epic starts.