// EPIC 04 — Bracket Generator abstraction.
//
// PO direction 2026-07-31: every [TournamentFormat] owns its own bracket
// generator. Keeps [TournamentFormat] from bloating and lets Phase II formats
// (Double Elim, RR, Swiss) plug in their own layout algorithm without
// touching the engine.
//
// PO direction 2026-07-31 (second pass): placeholders DO NOT throw. They
// return [NotAvailable] from the [generate] / [parentSlot] methods and the
// caller (UI / service) checks for it. Single Elimination is the only Beta
// implementation. Round Robin, Double Elimination, Swiss return the
// appropriate [NotAvailable] sentinel.

import 'package:pool_os/features/tournament/domain/capabilities.dart';
import 'package:pool_os/features/tournament/domain/models/tournament_models.dart';

/// Result type for bracket generation. Either a successful [BracketLayout]
/// or a [NotAvailable] describing why the format is not buildable yet.
class BracketGenerationResult {
  final BracketLayout? layout;
  final NotAvailable? notAvailable;
  const BracketGenerationResult._(this.layout, this.notAvailable);

  bool get isAvailable => layout != null;
  bool get isUnavailable => notAvailable != null;

  factory BracketGenerationResult.ok(BracketLayout layout) =>
      BracketGenerationResult._(layout, null);
  factory BracketGenerationResult.unavailable(NotUnavailable na) =>
      BracketGenerationResult._(null, na);
}

// Typed alias kept here so the imports stay short at call sites.
typedef NotUnavailable = NotAvailable;

/// Result type for the parent-slot query. Either coordinates or [NotAvailable].
class BracketParentSlotResult {
  final FormatParentSlotRef? slot;
  final NotAvailable? notAvailable;
  const BracketParentSlotResult._(this.slot, this.notAvailable);

  bool get isAvailable => slot != null;
  bool get isUnavailable => notAvailable != null;

  factory BracketParentSlotResult.ok(FormatParentSlotRef slot) =>
      BracketParentSlotResult._(slot, null);
  factory BracketParentSlotResult.unavailable(NotAvailable na) =>
      BracketParentSlotResult._(null, na);
}

/// Output of laying out a bracket: the fixtures to persist, keyed by round.
class BracketLayout {
  final List<TournamentMatch> matches;

  const BracketLayout(this.matches);

  int get roundCount => matches.isEmpty
      ? 0
      : (matches.map((m) => m.roundIndex).reduce(
            (a, b) => a > b ? a : b,
          )) +
          1;
}

abstract class BracketGenerator {
  /// Identifier matched against [TournamentFormat.type].
  TournamentType get type;

  /// Capability descriptor — PO 2026-07-31: UI reads this and disables the
  /// action. No exception, no error pop-up.
  BracketGeneratorCapability get capability;

  /// Build the opening layout. Implementations may seed, add byes, and
  /// pre-resolve byes (auto-advance, no fake Match, no Win/Stat/Rank).
  /// Returns [BracketGenerationResult.ok] on success; placeholders return
  /// [BracketGenerationResult.unavailable] with a [NotAvailable] payload.
  BracketGenerationResult generate({
    required List<TournamentParticipant> participants,
    required int tournamentId,
    required DateTime now,
    bool includeThirdPlace = false,
  });

  /// Given a resolved fixture, return where its winner lands in the next
  /// round, or null-equivalent via [BracketParentSlotResult.unavailable] if
  /// this format is not implemented. Elimination formats return OK with
  /// coordinates; non-elimination formats return OK with null in [slot].
  BracketParentSlotResult parentSlot({
    required int roundIndex,
    required int slotIndex,
    required int roundCount,
  });
}

/// Reference shape kept here so [BracketGenerator.parentSlot] can be
/// implemented without importing [TournamentFormat]. Same fields.
class FormatParentSlotRef {
  final int roundIndex;
  final int slotIndex;
  final bool isSideA;
  final String bracketGroup;

  const FormatParentSlotRef({
    required this.roundIndex,
    required this.slotIndex,
    required this.isSideA,
    this.bracketGroup = 'M',
  });
}

/// Phase 1 — Single Elimination. Reuses the proven helpers since Task 13.
class SingleEliminationBracketGenerator implements BracketGenerator {
  const SingleEliminationBracketGenerator();

  @override
  TournamentType get type => TournamentType.singleElimination;

  @override
  BracketGeneratorCapability get capability => const BracketGeneratorCapability(
        implemented: true,
        supported: true,
      );

  @override
  BracketGenerationResult generate({
    required List<TournamentParticipant> participants,
    required int tournamentId,
    required DateTime now,
    bool includeThirdPlace = false,
  }) {
    return BracketGenerationResult.ok(
      BracketGeneratorStatic._elimination(
        participants: participants,
        tournamentId: tournamentId,
        now: now,
        includeThirdPlace: includeThirdPlace,
      ),
    );
  }

  @override
  BracketParentSlotResult parentSlot({
    required int roundIndex,
    required int slotIndex,
    required int roundCount,
  }) {
    final raw = BracketGeneratorStatic.parentSlot(
      roundIndex: roundIndex,
      slotIndex: slotIndex,
      roundCount: roundCount,
    );
    if (raw == null) {
      // No parent (we are at the final). Caller treats this as "no work".
      return const BracketParentSlotResult._(null, null);
    }
    return BracketParentSlotResult.ok(FormatParentSlotRef(
      roundIndex: raw.$1,
      slotIndex: raw.$2,
      isSideA: raw.$3,
      bracketGroup: 'M',
    ));
  }
}

/// Phase 2+ — placeholder generators. Return [NotAvailable] when invoked
/// so accidental use is loud at the call site without exception.
class DoubleEliminationBracketGenerator implements BracketGenerator {
  const DoubleEliminationBracketGenerator();

  @override
  TournamentType get type => TournamentType.doubleElimination;

  @override
  BracketGeneratorCapability get capability => const BracketGeneratorCapability(
        implemented: false,
        supported: true, // planned, but not built yet
      );

  @override
  BracketGenerationResult generate({
    required List<TournamentParticipant> participants,
    required int tournamentId,
    required DateTime now,
    bool includeThirdPlace = false,
  }) {
    return BracketGenerationResult.unavailable(notAvailableDoubleElimination);
  }

  @override
  BracketParentSlotResult parentSlot({
    required int roundIndex,
    required int slotIndex,
    required int roundCount,
  }) {
    return BracketParentSlotResult.unavailable(notAvailableDoubleElimination);
  }
}

class RoundRobinBracketGenerator implements BracketGenerator {
  const RoundRobinBracketGenerator();

  @override
  TournamentType get type => TournamentType.roundRobin;

  @override
  BracketGeneratorCapability get capability => const BracketGeneratorCapability(
        implemented: false,
        supported: true,
      );

  @override
  BracketGenerationResult generate({
    required List<TournamentParticipant> participants,
    required int tournamentId,
    required DateTime now,
    bool includeThirdPlace = false,
  }) {
    return BracketGenerationResult.unavailable(notAvailableRoundRobin);
  }

  @override
  BracketParentSlotResult parentSlot({
    required int roundIndex,
    required int slotIndex,
    required int roundCount,
  }) {
    return BracketParentSlotResult.unavailable(notAvailableRoundRobin);
  }
}

// NOTE: Swiss generator lives in EPIC 09 (PO 2026-07-31).

/// Pure helpers preserved from the Task 13 implementation. They are private
/// static functions so the abstraction above can reuse the proven math
/// without exposing the legacy global API. New formats (DE/RR/Swiss) will
/// bring their own helpers when implemented.
class BracketGeneratorStatic {
  BracketGeneratorStatic._();

  /// Order participants by seed (1 = top). Null seeds keep their incoming
  /// order but sort after all seeded entries.
  static List<TournamentParticipant> orderBySeed(
    List<TournamentParticipant> participants,
  ) {
    final seeded = participants.where((p) => p.seed != null).toList()
      ..sort((a, b) => a.seed!.compareTo(b.seed!));
    final unseeded = participants.where((p) => p.seed == null).toList();
    return [...seeded, ...unseeded];
  }

  /// Standard 1-vs-N seeding order for a single-elimination bracket of
  /// [size] slots (a power of two). Returns 0-based seed indices. E.g.
  /// size 4 → [0,3,1,2].
  static List<int> seedOrder(int size) {
    assert(size > 0 && (size & (size - 1)) == 0, 'size must be a power of two');
    var rounds = <int>[0];
    while (rounds.length < size) {
      final next = <int>[];
      final n = rounds.length * 2;
      for (final r in rounds) {
        next.add(r);
        next.add(n - 1 - r);
      }
      rounds = next;
    }
    return rounds;
  }

  /// Smallest power of two >= n (min 1).
  static int nextPowerOfTwo(int n) {
    if (n <= 1) return 1;
    var p = 1;
    while (p < n) {
      p <<= 1;
    }
    return p;
  }

  static BracketLayout _elimination({
    required List<TournamentParticipant> participants,
    required int tournamentId,
    required DateTime now,
    required bool includeThirdPlace,
  }) {
    final ordered = orderBySeed(participants);
    final size = nextPowerOfTwo(ordered.length);
    final order = seedOrder(size);

    final matches = <TournamentMatch>[];
    for (var i = 0; i < size ~/ 2; i++) {
      final aSlot = order[i * 2];
      final bSlot = order[i * 2 + 1];
      final a = aSlot < ordered.length ? ordered[aSlot] : null;
      final b = bSlot < ordered.length ? ordered[bSlot] : null;

      int? winner;
      if (a != null && b == null) winner = a.id;
      if (b != null && a == null) winner = b.id;

      matches.add(TournamentMatch(
        tournamentId: tournamentId,
        roundIndex: 0,
        slotIndex: i,
        bracketGroup: 'M',
        participantAId: a?.id,
        participantBId: b?.id,
        winnerParticipantId: winner,
        createdAt: now,
      ));
    }

    var slotsThisRound = size ~/ 2;
    var round = 1;
    while (slotsThisRound > 1) {
      slotsThisRound ~/= 2;
      for (var i = 0; i < slotsThisRound; i++) {
        matches.add(TournamentMatch(
          tournamentId: tournamentId,
          roundIndex: round,
          slotIndex: i,
          bracketGroup: 'M',
          createdAt: now,
        ));
      }
      round++;
    }

    if (includeThirdPlace && ordered.length >= 4) {
      matches.add(TournamentMatch(
        tournamentId: tournamentId,
        roundIndex: round - 1,
        slotIndex: 0,
        bracketGroup: 'P',
        createdAt: now,
      ));
    }

    return BracketLayout(matches);
  }

  /// Returns (roundIndex, slotIndex, isSideA) or null if final. Exposed for
  /// the SE generator's parentSlot implementation.
  static (int, int, bool)? parentSlot({
    required int roundIndex,
    required int slotIndex,
    required int roundCount,
  }) {
    final nextRound = roundIndex + 1;
    if (nextRound >= roundCount) return null;
    final parentSlotIndex = slotIndex ~/ 2;
    final isSideA = slotIndex.isEven;
    return (nextRound, parentSlotIndex, isSideA);
  }
}