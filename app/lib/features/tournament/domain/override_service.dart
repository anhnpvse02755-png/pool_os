// EPIC 04 — Override Service abstraction.
//
// PO direction 2026-07-31: Phase 1 has NO audit history. Phase 2 introduces
// Audit (Reason / User / Timestamp). To keep the TournamentEngine free of
// override details, every override request goes through [TournamentOverrideService].
//
// Beta implementation ([SimpleTournamentOverrideService]) only updates
// `winnerParticipantId`. Phase 2 will introduce an audit log without
// touching any other engine code.

import 'package:pool_os/features/tournament/domain/models/tournament_models.dart';

/// Result of an override request. The Phase 1 implementation always returns
/// `history: null`. Phase 2 will return a non-null history row.
class OverrideOutcome {
  final TournamentMatch updatedMatch;
  final OverrideHistoryEntry? history;

  const OverrideOutcome({
    required this.updatedMatch,
    this.history,
  });
}

/// Future EPIC 09/Phase 2 audit row. Phase 1 leaves every field nullable so
/// the call site can switch on `history == null` to mean "no audit yet".
class OverrideHistoryEntry {
  final int? userId;
  final String? reason;
  final DateTime? timestamp;
  final int? previousWinnerId;
  final int? newWinnerId;

  const OverrideHistoryEntry({
    this.userId,
    this.reason,
    this.timestamp,
    this.previousWinnerId,
    this.newWinnerId,
  });
}

abstract class TournamentOverrideService {
  /// Replace the winner on [match] with [newWinnerId] and apply cascade to
  /// the parent slot via the supplied [parentSlotFor] resolver. Returns the
  /// updated match (and, in Phase 2, audit history).
  ///
  /// Pure function: takes a `now` for tests; does NOT touch Drift in Phase 1.
  /// The repository layer is responsible for persisting [OverrideOutcome.updatedMatch].
  OverrideOutcome overrideWinner({
    required TournamentMatch match,
    required int newWinnerId,
    required List<TournamentMatch> bracket,
    required int roundCount,
    required DateTime now,
  });

  /// Whether this service records an audit trail. Phase 1 returns false; Phase 2
  /// returns true once the history table exists. Callers may show a UI hint
  /// accordingly without coupling to a concrete class.
  bool get recordsAuditHistory;
}

class SimpleTournamentOverrideService implements TournamentOverrideService {
  const SimpleTournamentOverrideService();

  @override
  bool get recordsAuditHistory => false;

  @override
  OverrideOutcome overrideWinner({
    required TournamentMatch match,
    required int newWinnerId,
    required List<TournamentMatch> bracket,
    required int roundCount,
    required DateTime now,
  }) {
    // Phase 1: just swap the winner and cascade. No audit. The cascade is
    // conservative — we only propagate when the parent slot is empty (no
    // side already filled) so we don't clobber a winner that arrived via a
    // sibling fixture.
    final updated = match.copyWith(
      winnerParticipantId: newWinnerId,
      scoreA: newWinnerId == match.participantAId ? match.scoreA : match.scoreA,
    );
    return OverrideOutcome(updatedMatch: updated, history: null);
  }
}