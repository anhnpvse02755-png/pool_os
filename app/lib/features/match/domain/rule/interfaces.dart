// EPIC 01 — Match Engine — Phase 1: rule interfaces.
//
// Strategy pattern. The Match Engine depends only on these
// abstractions. Concrete rule logic for Eight Ball / Nine Ball /
// Ten Ball will be implemented by EPIC Rule System post-Beta; in
// EPIC 01 a `DefaultPlaceholderRule` provides enough behaviour to
// run the engine end-to-end.

import 'package:meta/meta.dart';

import 'game_type.dart';

/// Decision returned by a rule when a rack resolves.
@immutable
class RackOutcome {
  const RackOutcome(
      {required this.winnerParticipantId, required this.rackNumber});

  final String winnerParticipantId;
  final int rackNumber;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RackOutcome &&
          other.winnerParticipantId == winnerParticipantId &&
          other.rackNumber == rackNumber;

  @override
  int get hashCode => Object.hash(winnerParticipantId, rackNumber);
}

/// Strategy that decides the overall match winner once the race is
/// decided. Real implementations compute a winner based on rack wins
/// vs. race length. EPIC 01 placeholder returns the participant
/// with the most rack wins; the real variant comes from EPIC Rule
/// System.
abstract class WinCondition {
  String? determineWinner({
    required Map<String, int> rackWins,
    required int raceLength,
  });
}

/// Strategy for break selection. Real strategies cover alternating,
/// winner-breaks, or first-game-only. EPIC 01 placeholder always
/// returns the participant who is listed first in Match participants.
abstract class BreakStrategy {
  String participantForBreak({
    required int gameNumber,
    required List<String> participants,
    required Map<String, int> previousWins,
  });
}

/// Strategy that classifies whether a turn-ending event should be
/// considered a foul. Real strategies encode league-specific foul
/// rules (BCA / APA / WPA / etc.). EPIC 01 placeholder never
/// auto-classifies a foul — the caller must explicitly invoke
/// `RecordFoul`.
abstract class FoulPolicy {
  bool isFoul({required String reason});
}

/// Strategy that decides whether a shot is classified as a "safety"
/// (defensive). Real strategies encode league-specific safety
/// definitions. EPIC 01 placeholder accepts any explicit safety call.
abstract class SafetyPolicy {
  bool isSafety({required String reason});
}

/// Strategy that determines the legality of ball contact, pocketing,
/// push-out, three-foul, etc. Real strategies encode full rule sets.
/// EPIC 01 placeholder accepts any shot (the placeholder does not
/// reject illegal shots); real implementations arrive with EPIC Rule
/// System.
///
/// The interface exists so the Match Engine can declare its
/// dependency surface today; implementations may grow without
/// touching engine code.
abstract class GameRule {
  GameType get gameType;

  /// Called when a new rack starts; returns whether the rack may
  /// begin. Real rules may forbid starting a rack until break is
  /// resolved; placeholder always returns true.
  bool canStartRack({required int rackNumber, required int raceLength});

  /// Called when a shot is recorded. Returns true if the shot is
  /// admissible. Placeholder always returns true.
  bool admitShot({required int shotIndex, required String participantId});

  /// Called when a rack closes; returns the rack outcome that the
  /// engine should record. Real rules compute the outcome from the
  /// shot log; placeholder deterministically awards the rack to the
  /// participant who recorded the last shot in the rack.
  RackOutcome resolveRack({
    required int rackNumber,
    required String lastShootingParticipantId,
    required Map<String, int> previousRackWins,
    required int raceLength,
  });
}
