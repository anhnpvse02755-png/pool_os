// EPIC 01 — Match Engine — focused test: MatchRecorder pipeline.

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/match/domain/engine/event.dart';
import 'package:pool_os/features/match/domain/engine/match_aggregate.dart';
import 'package:pool_os/features/match/domain/engine/match_event_log.dart';
import 'package:pool_os/features/match/domain/engine/match_manager.dart';
import 'package:pool_os/features/match/domain/engine/states.dart';
import 'package:pool_os/features/match/domain/engine/value_objects.dart';
import 'package:pool_os/features/match/domain/recording/match_recorder.dart';
import 'package:pool_os/features/match/domain/rule/game_type.dart';
import 'package:pool_os/features/match/domain/rule/placeholder_rule.dart';

class _CollectingShotSink implements ShotHistorySink {
  final List<ShotRecorded> shots = [];
  @override
  Future<void> onShotRecorded(ShotRecorded event) async {
    shots.add(event);
  }
}

class _CollectingMatchCompletedSink implements MatchCompletedSink {
  final List<MatchCompleted> completions = [];
  @override
  Future<void> onMatchCompleted(MatchCompleted event) async {
    completions.add(event);
  }
}

void main() {
  group('MatchRecordingPipeline', () {
    late _CollectingShotSink shotSink;
    late _CollectingMatchCompletedSink completedSink;
    late MatchRecordingPipeline pipeline;
    late Match initial;

    setUp(() {
      shotSink = _CollectingShotSink();
      completedSink = _CollectingMatchCompletedSink();
      initial = Match(
        id: const MatchId('m1'),
        gameType: GameType.eightBall,
        raceLength: 5,
        participants: const ['p1', 'p2'],
        state: MatchState.created,
        racks: const [],
        startedAt: DateTime.utc(2026, 7, 29),
      );
      final builder = MatchManagerBuilder(
        eventLog: InMemoryMatchEventLog(),
        ruleRegistry: const GameRuleRegistry(),
      );
      pipeline = MatchRecordingPipeline(
        manager: builder.buildNew(initial),
        ruleRegistry: const GameRuleRegistry(),
        shotHistorySink: shotSink,
        foulSink: const NullRecordingSinks(),
        safetySink: const NullRecordingSinks(),
        completedSink: completedSink,
      );
    });

    test('startMatch + beginRack + recordShot flows to sink', () async {
      await pipeline.startMatch();
      final rackId = const RackId('r1');
      await pipeline.beginRack(rackId, 'p1');
      final turnId = const TurnId('t1');
      await pipeline.beginTurn(turnId, rackId, 'p1');
      await pipeline.recordShot(
        shotId: const ShotId('s1'),
        turnId: turnId,
        rackId: rackId,
        participant: 'p1',
      );
      expect(shotSink.shots, hasLength(1));
      expect(shotSink.shots.single.participantId, 'p1');
    });

    test('concedeMatch emits MatchCompleted event to sink', () async {
      await pipeline.startMatch();
      final rackId = const RackId('r1');
      await pipeline.beginRack(rackId, 'p1');
      await pipeline.endRack(rackId, 'p1');
      await pipeline.concedeMatch('p1');
      expect(completedSink.completions, hasLength(1));
      expect(completedSink.completions.single.winnerParticipantId, 'p2');
    });

    test('completed sink fires on CompleteMatch command', () async {
      await pipeline.startMatch();
      final rackId = const RackId('r1');
      await pipeline.beginRack(rackId, 'p1');
      await pipeline.endRack(rackId, 'p1');
      await pipeline.completeMatch('p1');
      expect(completedSink.completions, hasLength(1));
      expect(completedSink.completions.single.winnerParticipantId, 'p1');
    });
  });
}
