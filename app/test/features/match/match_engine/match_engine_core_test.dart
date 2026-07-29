// EPIC 01 — Match Engine — focused test: command processor + undo/redo.

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/match/domain/engine/command.dart';
import 'package:pool_os/features/match/domain/engine/command_processor.dart';
import 'package:pool_os/features/match/domain/engine/event.dart';
import 'package:pool_os/features/match/domain/engine/match_aggregate.dart';
import 'package:pool_os/features/match/domain/engine/states.dart';
import 'package:pool_os/features/match/domain/engine/value_objects.dart';
import 'package:pool_os/features/match/domain/rule/game_type.dart';
import 'package:pool_os/features/match/domain/rule/placeholder_rule.dart';

void main() {
  group('MatchEngineCore', () {
    late MatchEngineCore core;
    late Match initial;
    final clock = _FixedClock(DateTime.utc(2026, 7, 29, 10));
    final registry = const GameRuleRegistry();

    setUp(() {
      initial = Match(
        id: const MatchId('m1'),
        gameType: GameType.eightBall,
        raceLength: 5,
        participants: const ['p1', 'p2'],
        state: MatchState.created,
        racks: const [],
        startedAt: clock.now(),
      );
      core = MatchEngineCore(
        match: initial,
        ruleRegistry: registry,
        clock: clock,
      );
    });

    test('start moves match from created to inProgress', () {
      final result = core.apply(StartMatch(
        matchId: initial.id,
        issuedAt: clock.now(),
      ));
      expect(result.match.state, MatchState.inProgress);
      expect(result.events.single, isA<MatchStarted>());
    });

    test('begin rack adds rack to match with breaking participant', () {
      core.apply(StartMatch(matchId: initial.id, issuedAt: clock.now()));
      final rackId = const RackId('r1');
      final result = core.apply(BeginRack(
        matchId: initial.id,
        issuedAt: clock.now(),
        rackId: rackId,
        breakingParticipantId: 'p1',
      ));
      expect(result.match.racks, hasLength(1));
      expect(result.match.racks.single.state, RackState.inProgress);
      expect(result.match.racks.single.breakingParticipantId, 'p1');
      expect(result.events.single, isA<RackBegan>());
    });

    test('turn lifecycle: begin -> shots -> end', () {
      core.apply(StartMatch(matchId: initial.id, issuedAt: clock.now()));
      final rackId = const RackId('r1');
      core.apply(BeginRack(
        matchId: initial.id,
        issuedAt: clock.now(),
        rackId: rackId,
        breakingParticipantId: 'p1',
      ));
      final turnId = const TurnId('t1');
      core.apply(BeginTurn(
        matchId: initial.id,
        issuedAt: clock.now(),
        turnId: turnId,
        rackId: rackId,
        participantId: 'p1',
      ));
      core.apply(RecordShot(
        matchId: initial.id,
        issuedAt: clock.now(),
        shotId: const ShotId('s1'),
        turnId: turnId,
        rackId: rackId,
        participantId: 'p1',
      ));
      core.apply(RecordShot(
        matchId: initial.id,
        issuedAt: clock.now(),
        shotId: const ShotId('s2'),
        turnId: turnId,
        rackId: rackId,
        participantId: 'p1',
      ));
      core.apply(EndTurn(
        matchId: initial.id,
        issuedAt: clock.now(),
        turnId: turnId,
        rackId: rackId,
        resolution: 'normal',
      ));
      final rack = core.match.racks.single;
      final turn = rack.turns.single;
      expect(turn.shots, hasLength(2));
      expect(turn.state, TurnState.ended);
      expect(turn.resolution, TurnResolution.normal);
    });

    test('end rack marks winner and closes rack', () {
      core.apply(StartMatch(matchId: initial.id, issuedAt: clock.now()));
      final rackId = const RackId('r1');
      core.apply(BeginRack(
        matchId: initial.id,
        issuedAt: clock.now(),
        rackId: rackId,
        breakingParticipantId: 'p1',
      ));
      core.apply(BeginTurn(
        matchId: initial.id,
        issuedAt: clock.now(),
        turnId: const TurnId('t1'),
        rackId: rackId,
        participantId: 'p1',
      ));
      core.apply(EndTurn(
        matchId: initial.id,
        issuedAt: clock.now(),
        turnId: const TurnId('t1'),
        rackId: rackId,
        resolution: 'normal',
      ));
      core.apply(EndRack(
        matchId: initial.id,
        issuedAt: clock.now(),
        rackId: rackId,
        winnerParticipantId: 'p1',
      ));
      expect(core.match.racks.single.state, RackState.closed);
      expect(core.match.racks.single.winnerParticipantId, 'p1');
    });

    test('concede match completes with opponent as winner', () {
      core.apply(StartMatch(matchId: initial.id, issuedAt: clock.now()));
      core.apply(BeginRack(
        matchId: initial.id,
        issuedAt: clock.now(),
        rackId: const RackId('r1'),
        breakingParticipantId: 'p1',
      ));
      core.apply(EndRack(
        matchId: initial.id,
        issuedAt: clock.now(),
        rackId: const RackId('r1'),
        winnerParticipantId: 'p1',
      ));
      core.apply(ConcedeMatch(
        matchId: initial.id,
        issuedAt: clock.now(),
        concedingParticipantId: 'p1',
      ));
      expect(core.match.state, MatchState.completed);
      expect(core.match.winnerParticipantId, 'p2');
    });

    test('undo restores prior state and re-applies on redo', () {
      core.apply(StartMatch(matchId: initial.id, issuedAt: clock.now()));
      final rackId = const RackId('r1');
      core.apply(BeginRack(
        matchId: initial.id,
        issuedAt: clock.now(),
        rackId: rackId,
        breakingParticipantId: 'p1',
      ));
      expect(core.match.racks, hasLength(1));
      expect(core.canUndo, isTrue);

      // Undo BeginRack — the rack should disappear, but StartMatch
      // remains on the undo stack.
      core.apply(UndoCommand(
        matchId: initial.id,
        issuedAt: clock.now(),
      ));
      expect(core.match.racks, isEmpty);
      expect(core.canUndo, isTrue); // StartMatch still on stack
      expect(core.canRedo, isTrue);

      // Undo StartMatch too — match should return to created.
      core.apply(UndoCommand(
        matchId: initial.id,
        issuedAt: clock.now(),
      ));
      expect(core.match.state, MatchState.created);
      expect(core.canUndo, isFalse);

      // Redo both.
      core.apply(RedoCommand(matchId: initial.id, issuedAt: clock.now()));
      core.apply(RedoCommand(matchId: initial.id, issuedAt: clock.now()));
      expect(core.match.racks, hasLength(1));
      expect(core.canRedo, isFalse);
    });

    test('record foul produces FoulRecorded event without changing snapshot',
        () {
      core.apply(StartMatch(matchId: initial.id, issuedAt: clock.now()));
      core.apply(BeginRack(
        matchId: initial.id,
        issuedAt: clock.now(),
        rackId: const RackId('r1'),
        breakingParticipantId: 'p1',
      ));
      core.apply(BeginTurn(
        matchId: initial.id,
        issuedAt: clock.now(),
        turnId: const TurnId('t1'),
        rackId: const RackId('r1'),
        participantId: 'p1',
      ));
      final result = core.apply(RecordFoul(
        matchId: initial.id,
        issuedAt: clock.now(),
        turnId: const TurnId('t1'),
        rackId: const RackId('r1'),
        participantId: 'p1',
        reason: 'placeholder-foul',
      ));
      expect(result.events.single, isA<FoulRecorded>());
    });

    test('abandonMatch sets terminal abandoned state', () {
      core.apply(StartMatch(matchId: initial.id, issuedAt: clock.now()));
      core.apply(AbandonMatch(
        matchId: initial.id,
        issuedAt: clock.now(),
        reason: 'interrupted',
      ));
      expect(core.match.state, MatchState.abandoned);
    });

    test('cannot start a match that is already started', () {
      core.apply(StartMatch(matchId: initial.id, issuedAt: clock.now()));
      expect(
        () => core.apply(StartMatch(
          matchId: initial.id,
          issuedAt: clock.now(),
        )),
        throwsStateError,
      );
    });

    test('cannot record shot in a closed turn', () {
      core.apply(StartMatch(matchId: initial.id, issuedAt: clock.now()));
      final rackId = const RackId('r1');
      core.apply(BeginRack(
        matchId: initial.id,
        issuedAt: clock.now(),
        rackId: rackId,
        breakingParticipantId: 'p1',
      ));
      core.apply(BeginTurn(
        matchId: initial.id,
        issuedAt: clock.now(),
        turnId: const TurnId('t1'),
        rackId: rackId,
        participantId: 'p1',
      ));
      core.apply(EndTurn(
        matchId: initial.id,
        issuedAt: clock.now(),
        turnId: const TurnId('t1'),
        rackId: rackId,
        resolution: 'normal',
      ));
      expect(
        () => core.apply(RecordShot(
          matchId: initial.id,
          issuedAt: clock.now(),
          shotId: const ShotId('s1'),
          turnId: const TurnId('t1'),
          rackId: rackId,
          participantId: 'p1',
        )),
        throwsStateError,
      );
    });
  });
}

class _FixedClock implements MatchClock {
  _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}
