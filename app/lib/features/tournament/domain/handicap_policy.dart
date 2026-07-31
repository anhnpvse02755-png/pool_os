// EPIC 04 — Handicap Policy abstraction.
//
// PO direction 2026-07-31:
//   - Handicap is a RELATIONSHIP between two players, not an attribute of
//     a tournament.
//   - Phase 1 implements RacePatch (object {playerA, playerB}). Other policies
//     (FixedRace, APA) are architecture-ready only.
//   - PO 2026-07-31 (second pass): placeholders return NotAvailable instead
//     of throwing [UnsupportedError].
//
// Architecture:
//
//   HandicapPolicy (interface)
//     ├── RacePatch (Beta — {playerA: int, playerB: int})
//     ├── FixedRace (placeholder, returns baseRace)
//     └── ApaHandicap (placeholder, returns NotAvailable)
//
// HandicapPolicy is consumed by MatchEngine when recording a tournament
// fixture. It returns the race-to number for each side based on the two
// participant IDs and an optional base race length.

import 'package:pool_os/features/tournament/domain/capabilities.dart';

/// Race-to numbers for both sides of a single fixture. Pure data, no
/// behaviour.
class HandicapRace {
  /// Race-to number for the participant on side A of the bracket slot.
  final int playerA;

  /// Race-to number for the participant on side B of the bracket slot.
  final int playerB;

  const HandicapRace({required this.playerA, required this.playerB});
}

/// Result type. Either a [HandicapRace] or [NotAvailable].
class HandicapRaceResult {
  final HandicapRace? race;
  final NotAvailable? notAvailable;
  const HandicapRaceResult._(this.race, this.notAvailable);

  bool get isAvailable => race != null;
  bool get isUnavailable => notAvailable != null;

  factory HandicapRaceResult.ok(HandicapRace race) =>
      HandicapRaceResult._(race, null);
  factory HandicapRaceResult.unavailable(NotAvailable na) =>
      HandicapRaceResult._(null, na);
}

abstract class HandicapPolicy {
  /// Stable identifier persisted alongside the bracket row. Frozen
  /// per-tournament.
  String get code;

  /// Human-readable label for the UI.
  String get labelKey;

  /// Whether this policy is implemented in this build. UI reads this and
  /// disables the action when false.
  bool get implemented;

  /// Compute the race-to numbers for the two sides of [participantAId] vs
  /// [participantBId]. [baseRace] is the tournament-wide default race length
  /// (e.g. 7 for race-to-7). Returns a [HandicapRaceResult]; placeholder
  /// policies return [HandicapRaceResult.unavailable].
  HandicapRaceResult resolveRace({
    required int participantAId,
    required int participantBId,
    required int baseRace,
  });
}

/// Phase 1 — RacePatch. Stored per-fixture as `{playerA, playerB}`. When the
/// bracket is generated without per-fixture patches, the policy falls back to
/// [baseRace] for both sides (i.e. a fair race).
class RacePatchHandicap implements HandicapPolicy {
  /// Per-fixture overrides keyed by `participantAId|participantBId`. Keying on
  /// ordered pair keeps both `A vs B` and `B vs A` lookups consistent — the
  /// bracket always picks the slot's perspective, so the caller passes the
  /// two ids in slot order.
  final Map<String, HandicapRace> patches;

  /// Optional default patch applied when no entry in [patches] matches.
  final HandicapRace? fallback;

  const RacePatchHandicap({this.patches = const {}, this.fallback});

  @override
  String get code => 'race_patch';

  @override
  String get labelKey => 'tnmt_handicap_race_patch';

  @override
  bool get implemented => true;

  @override
  HandicapRaceResult resolveRace({
    required int participantAId,
    required int participantBId,
    required int baseRace,
  }) {
    final key = '$participantAId|$participantBId';
    final hit = patches[key];
    if (hit != null) return HandicapRaceResult.ok(hit);
    if (fallback != null) return HandicapRaceResult.ok(fallback!);
    return HandicapRaceResult.ok(
      HandicapRace(playerA: baseRace, playerB: baseRace),
    );
  }
}

/// Phase 2+ — FixedRace. Fixed total race applied to every fixture (e.g. a
/// 9-ball race-to-9 across the board).
class FixedRaceHandicap implements HandicapPolicy {
  final int race;
  const FixedRaceHandicap(this.race);

  @override
  String get code => 'fixed_race';

  @override
  String get labelKey => 'tnmt_handicap_fixed_race';

  @override
  bool get implemented => true;

  @override
  HandicapRaceResult resolveRace({
    required int participantAId,
    required int participantBId,
    required int baseRace,
  }) {
    return HandicapRaceResult.ok(
      HandicapRace(playerA: race, playerB: race),
    );
  }
}

/// Phase 2+ — APA-style handicap. 9-ball with skill-level-based slashes.
/// Pure placeholder so the engine surface is complete; no math in Beta.
/// Returns [NotAvailable] from resolveRace so the UI can disable the option.
class ApaHandicap implements HandicapPolicy {
  const ApaHandicap();

  @override
  String get code => 'apa';

  @override
  String get labelKey => 'tnmt_handicap_apa';

  @override
  bool get implemented => false;

  @override
  HandicapRaceResult resolveRace({
    required int participantAId,
    required int participantBId,
    required int baseRace,
  }) {
    return HandicapRaceResult.unavailable(notAvailableApaHandicap);
  }
}

/// Default no-handicap policy: both sides race to [baseRace]. Used when a
/// tournament is created without a custom policy.
class NoHandicap implements HandicapPolicy {
  const NoHandicap();

  @override
  String get code => 'none';

  @override
  String get labelKey => 'tnmt_handicap_none';

  @override
  bool get implemented => true;

  @override
  HandicapRaceResult resolveRace({
    required int participantAId,
    required int participantBId,
    required int baseRace,
  }) {
    return HandicapRaceResult.ok(
      HandicapRace(playerA: baseRace, playerB: baseRace),
    );
  }
}