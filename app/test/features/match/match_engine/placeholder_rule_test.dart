// EPIC 01 — Match Engine — focused test: placeholder rule + Strategy pattern.

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/match/domain/rule/game_type.dart';
import 'package:pool_os/features/match/domain/rule/interfaces.dart';
import 'package:pool_os/features/match/domain/rule/placeholder_rule.dart';

void main() {
  group('DefaultPlaceholderRule', () {
    test('rule type is placeholder for any game type lookup today', () {
      const registry = GameRuleRegistry();
      for (final t in GameType.all) {
        expect(registry.ruleFor(t).gameType, GameType.placeholder);
      }
    });

    test('admitShot always returns true for placeholder', () {
      const rule = DefaultPlaceholderRule();
      expect(rule.admitShot(shotIndex: 1, participantId: 'p1'), isTrue);
    });

    test('resolveRack awards rack to last shooting participant', () {
      const rule = DefaultPlaceholderRule();
      final outcome = rule.resolveRack(
        rackNumber: 1,
        lastShootingParticipantId: 'p2',
        previousRackWins: const {},
        raceLength: 5,
      );
      expect(outcome.winnerParticipantId, 'p2');
      expect(outcome.rackNumber, 1);
    });

    test('BreakStrategy returns first participant for placeholder', () {
      const strategy = DefaultBreakStrategy();
      final id = strategy.participantForBreak(
        gameNumber: 1,
        participants: const ['p1', 'p2'],
        previousWins: const {},
      );
      expect(id, 'p1');
    });

    test('WinCondition selects participant with most rack wins', () {
      const win = DefaultWinCondition();
      final winner = win.determineWinner(
        rackWins: const {'p1': 2, 'p2': 3},
        raceLength: 5,
      );
      expect(winner, 'p2');
    });

    test('WinCondition returns null when no wins yet', () {
      const win = DefaultWinCondition();
      final winner = win.determineWinner(
        rackWins: const {'p1': 0, 'p2': 0},
        raceLength: 5,
      );
      expect(winner, isNull);
    });

    test('FoulPolicy placeholder never auto-fouls', () {
      const foul = DefaultFoulPolicy();
      expect(foul.isFoul(reason: 'any'), isFalse);
    });

    test('SafetyPolicy placeholder accepts any safety call', () {
      const safety = DefaultSafetyPolicy();
      expect(safety.isSafety(reason: 'any'), isTrue);
    });

    test('RackOutcome equality', () {
      const a = RackOutcome(winnerParticipantId: 'p1', rackNumber: 1);
      const b = RackOutcome(winnerParticipantId: 'p1', rackNumber: 1);
      expect(a, b);
    });
  });
}
