// EPIC 01 — Match Engine — focused test: hydrate / replay / undo / redo.

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/match/domain/engine/command.dart';
import 'package:pool_os/features/match/domain/engine/match_aggregate.dart';
import 'package:pool_os/features/match/domain/engine/match_event_log.dart';
import 'package:pool_os/features/match/domain/engine/match_manager.dart';
import 'package:pool_os/features/match/domain/engine/states.dart';
import 'package:pool_os/features/match/domain/engine/value_objects.dart';
import 'package:pool_os/features/match/domain/rule/game_type.dart';
import 'package:pool_os/features/match/domain/rule/placeholder_rule.dart';

class _FixedClock implements MatchClock {
  @override
  DateTime now() => DateTime.utc(2026, 7, 29, 10);
}

void main() {
  group('MatchManager hydrate', () {
    test('hydrated manager restores match state from event log', () async {
      final log = InMemoryMatchEventLog();
      final registry = const GameRuleRegistry();
      final clock = _FixedClock();
      final initial = Match(
        id: const MatchId('m1'),
        gameType: GameType.eightBall,
        raceLength: 5,
        participants: const ['p1', 'p2'],
        state: MatchState.created,
        racks: const [],
        startedAt: clock.now(),
      );
      final original = MatchManagerBuilder(
              eventLog: log, ruleRegistry: registry, clock: clock)
          .buildNew(initial);

      await original
          .issue(StartMatch(matchId: initial.id, issuedAt: clock.now()));
      final rackId = const RackId('r1');
      await original.issue(BeginRack(
        matchId: initial.id,
        issuedAt: clock.now(),
        rackId: rackId,
        breakingParticipantId: 'p1',
      ));
      final turnId = const TurnId('t1');
      await original.issue(BeginTurn(
        matchId: initial.id,
        issuedAt: clock.now(),
        turnId: turnId,
        rackId: rackId,
        participantId: 'p1',
      ));
      await original.issue(RecordShot(
        matchId: initial.id,
        issuedAt: clock.now(),
        shotId: const ShotId('s1'),
        turnId: turnId,
        rackId: rackId,
        participantId: 'p1',
      ));

      // Now hydrate a fresh manager from the log.
      final hydrated = await MatchManagerBuilder(
              eventLog: log, ruleRegistry: registry, clock: clock)
          .hydrate(initial);
      expect(hydrated.engine.match.state, MatchState.inProgress);
      expect(hydrated.engine.match.racks, hasLength(1));
      expect(hydrated.engine.match.racks.single.turns, hasLength(1));
      expect(
          hydrated.engine.match.racks.single.turns.single.shots, hasLength(1));
    });
  });
}
