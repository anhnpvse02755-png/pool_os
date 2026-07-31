// EPIC 04 — Tournament Format abstraction.
//
// PO direction 2026-07-31 (second pass): placeholders MUST NOT throw
// exceptions. UI reads [TournamentFormatCapability] and disables the action.
// Methods return [FormatGenerationResult] / [FormatParentSlotResult] / etc.
// so the caller can branch cleanly.
//
// Architecture:
//
//   TournamentFormat (interface)
//     ├── SingleEliminationFormat (Beta — wraps existing BracketGenerator)
//     ├── DoubleEliminationFormat (placeholder, returns NotAvailable)
//     ├── RoundRobinFormat (placeholder, returns NotAvailable)
//     └── SwissFormat (lives in EPIC 09 — PO 2026-07-31)

import 'package:pool_os/features/tournament/domain/bracket_generator.dart';
import 'package:pool_os/features/tournament/domain/capabilities.dart';
import 'package:pool_os/features/tournament/domain/formats/placeholder_formats.dart';
import 'package:pool_os/features/tournament/domain/formats/single_elimination_format.dart';
import 'package:pool_os/features/tournament/domain/models/tournament_models.dart';

/// Result of building an initial bracket for a [TournamentFormat]. Either a
/// successful layout or a [NotAvailable] describing why the format is not
/// buildable yet.
class FormatGenerationResult {
  final BracketLayout? layout;
  final NotAvailable? notAvailable;
  const FormatGenerationResult._(this.layout, this.notAvailable);

  bool get isAvailable => layout != null;
  bool get isUnavailable => notAvailable != null;

  factory FormatGenerationResult.ok(BracketLayout layout) =>
      FormatGenerationResult._(layout, null);
  factory FormatGenerationResult.unavailable(NotAvailable na) =>
      FormatGenerationResult._(null, na);
}

/// Result of querying the parent slot for an advance. Either coordinates or
/// a [NotAvailable].
class FormatParentSlotResult {
  final FormatParentSlotRef? slot;
  final NotAvailable? notAvailable;
  const FormatParentSlotResult(this.slot, this.notAvailable);

  bool get isAvailable => slot != null;
  bool get isUnavailable => notAvailable != null;

  factory FormatParentSlotResult.ok(FormatParentSlotRef slot) =>
      FormatParentSlotResult(slot, null);
  factory FormatParentSlotResult.unavailable(NotAvailable na) =>
      FormatParentSlotResult(null, na);

  /// Special factory for "we are at the final — no parent, no error".
  static const atFinal = FormatParentSlotResult(null, null);
}

/// Result of champion detection. Either a participant id or [NotAvailable].
class ChampionResult {
  final int? championId;
  final NotAvailable? notAvailable;
  const ChampionResult._(this.championId, this.notAvailable);

  bool get isAvailable => championId != null;
  bool get isUnavailable => notAvailable != null;

  factory ChampionResult.ok(int championId) =>
      ChampionResult._(championId, null);
  factory ChampionResult.unavailable(NotAvailable na) =>
      ChampionResult._(null, na);
  factory ChampionResult.pending() => const ChampionResult._(null, null);

  bool get isPending => championId == null && notAvailable == null;
}

abstract class TournamentFormat {
  /// Identifier matched against [Tournament.type]. Frozen at creation.
  TournamentType get type;

  /// Capability descriptor — UI reads this and disables the action.
  TournamentFormatCapability get capability;

  /// Build the opening set of [TournamentMatch] slots for [participants].
  /// Implementation may seed, add byes, and pre-resolve byes (auto-advance).
  FormatGenerationResult generateInitialBracket({
    required int tournamentId,
    required List<TournamentParticipant> participants,
    required DateTime now,
    bool includeThirdPlace = false,
  });

  /// Given a resolved fixture, return where its winner should land in the
  /// next round, or [FormatParentSlotResult.unavailable] if the format is
  /// not implemented. SE returns OK coordinates (or null-equivalent
  /// pending at the final).
  FormatParentSlotResult parentSlotFor({
    required int roundIndex,
    required int slotIndex,
    required int roundCount,
  });

  /// True if [match] is the final fixture of this format.
  bool isFinalMatch(TournamentMatch match, int roundCount);

  /// Pick the champion participant id from a fully resolved bracket, or
  /// [ChampionResult.pending] if not yet decided.
  ChampionResult detectChampion(List<TournamentMatch> allMatches);
}

class FormatParentSlot {
  final int roundIndex;
  final int slotIndex;
  final bool isSideA;
  /// 'M' for main / winners' bracket, 'L' for losers' bracket, 'P' for
  /// third-place playoff. Single Elimination only emits 'M'.
  final String bracketGroup;

  const FormatParentSlot({
    required this.roundIndex,
    required this.slotIndex,
    required this.isSideA,
    this.bracketGroup = 'M',
  });
}

/// Factory — returns the concrete format for a given [TournamentType]. Phase 1
/// returns the SE implementation; the other 3 return [NotAvailable] when
/// their methods are actually invoked. They exist so the engine can already
/// surface UI labels and never surprise the caller with a thrown exception.
TournamentFormat tournamentFormatFor(TournamentType type) {
  switch (type) {
    case TournamentType.singleElimination:
      return const SingleEliminationFormat();
    case TournamentType.doubleElimination:
      return const DoubleEliminationFormat();
    case TournamentType.roundRobin:
    case TournamentType.league:
      return const RoundRobinFormat();
  }
  // PO 2026-07-31: Swiss is architecture-ready only. It is intentionally
  // not part of the TournamentType enum yet — when EPIC 09 adds it, this
  // factory gains a new branch.
}