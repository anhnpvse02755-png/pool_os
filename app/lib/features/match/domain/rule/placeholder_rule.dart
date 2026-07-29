// EPIC 01 — Match Engine — Phase 1: default placeholder rule set.
//
// Concrete placeholder implementations of the rule interfaces. They
// run the engine end-to-end without encoding any specific pool
// league's rules. Real rule implementations (Eight Ball / Nine Ball /
// Ten Ball) will replace these via the Strategy Pattern without
// modifying the Match Engine.

import 'game_type.dart';
import 'interfaces.dart';

class DefaultWinCondition implements WinCondition {
  const DefaultWinCondition();
  @override
  String? determineWinner({
    required Map<String, int> rackWins,
    required int raceLength,
  }) {
    String? top;
    var topWins = -1;
    rackWins.forEach((participantId, wins) {
      if (wins > topWins) {
        top = participantId;
        topWins = wins;
      }
    });
    if (top == null || topWins < 1) return null;
    return top;
  }
}

class DefaultBreakStrategy implements BreakStrategy {
  const DefaultBreakStrategy();
  @override
  String participantForBreak({
    required int gameNumber,
    required List<String> participants,
    required Map<String, int> previousWins,
  }) {
    if (participants.isEmpty) {
      throw StateError('Cannot determine break with no participants');
    }
    return participants.first;
  }
}

class DefaultFoulPolicy implements FoulPolicy {
  const DefaultFoulPolicy();
  @override
  bool isFoul({required String reason}) => false;
}

class DefaultSafetyPolicy implements SafetyPolicy {
  const DefaultSafetyPolicy();
  @override
  bool isSafety({required String reason}) => true;
}

class DefaultPlaceholderRule implements GameRule {
  const DefaultPlaceholderRule();
  @override
  GameType get gameType => GameType.placeholder;

  @override
  bool canStartRack({required int rackNumber, required int raceLength}) => true;

  @override
  bool admitShot({required int shotIndex, required String participantId}) =>
      true;

  @override
  RackOutcome resolveRack({
    required int rackNumber,
    required String lastShootingParticipantId,
    required Map<String, int> previousRackWins,
    required int raceLength,
  }) {
    return RackOutcome(
      winnerParticipantId: lastShootingParticipantId,
      rackNumber: rackNumber,
    );
  }
}

/// Factory that produces a [GameRule] for any [GameType]. Today it
/// returns the placeholder; future EPIC Rule System will return
/// specialised rules (EightBall / NineBall / TenBall).
class GameRuleRegistry {
  const GameRuleRegistry();

  GameRule ruleFor(GameType gameType) {
    switch (gameType.value) {
      case 'eight_ball':
      case 'nine_ball':
      case 'ten_ball':
      case 'placeholder':
        return const DefaultPlaceholderRule();
      default:
        throw ArgumentError.value(
          gameType.value,
          'gameType',
          'No GameRule registered for this GameType',
        );
    }
  }

  WinCondition winCondition() => const DefaultWinCondition();
  BreakStrategy breakStrategy() => const DefaultBreakStrategy();
  FoulPolicy foulPolicy() => const DefaultFoulPolicy();
  SafetyPolicy safetyPolicy() => const DefaultSafetyPolicy();
}
