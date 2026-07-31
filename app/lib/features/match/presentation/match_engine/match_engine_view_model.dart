// EPIC 01 — Match Engine — Phase 7: Match Engine View Model.
//
// Lightweight presentation-layer wrapper around MatchRecordingPipeline.
// The view model exposes the engine state to widgets and forwards
// user-driven intents back as commands. The view model is the only
// presentation-layer surface that knows about the engine API; widgets
// do not import the domain engine.

import 'package:flutter/foundation.dart';

import '../../domain/engine/match_aggregate.dart';
import '../../domain/engine/match_manager.dart';
import '../../domain/engine/value_objects.dart';
import '../../domain/recording/match_recorder.dart';
import '../../domain/rule/placeholder_rule.dart';

@immutable
class MatchEngineViewModel {
  MatchEngineViewModel._({
    required this.pipeline,
    required this.state,
    required this.ruleRegistry,
  });

  factory MatchEngineViewModel.fromPipeline({
    required MatchRecordingPipeline pipeline,
    required GameRuleRegistry ruleRegistry,
  }) {
    return MatchEngineViewModel._(
      pipeline: pipeline,
      state: pipeline.manager.snapshotSync(),
      ruleRegistry: ruleRegistry,
    );
  }

  final MatchRecordingPipeline pipeline;
  final GameRuleRegistry ruleRegistry;

  /// Last-known snapshot. Widgets use [Listenable] to rebuild on
  /// change. Real callers may upgrade this to ChangeNotifier; for now
  /// the view model is intentionally headless so widgets that opt in
  /// can drive their own rebuild logic.
  final MatchManagerState state;

  Match get match => state.match;

  Future<MatchEngineViewModel> startMatch() async {
    final next = await pipeline.startMatch();
    return _copy(next);
  }

  Future<MatchEngineViewModel> beginRack(RackId rackId, String breaking) async {
    final next = await pipeline.beginRack(rackId, breaking);
    return _copy(next);
  }

  Future<MatchEngineViewModel> beginTurn(
      TurnId turnId, RackId rackId, String participant) async {
    final next = await pipeline.beginTurn(turnId, rackId, participant);
    return _copy(next);
  }

  Future<MatchEngineViewModel> recordShot({
    required ShotId shotId,
    required TurnId turnId,
    required RackId rackId,
    required String participant,
  }) async {
    final next = await pipeline.recordShot(
      shotId: shotId,
      turnId: turnId,
      rackId: rackId,
      participant: participant,
    );
    return _copy(next);
  }

  Future<MatchEngineViewModel> endTurn({
    required TurnId turnId,
    required RackId rackId,
    required String resolution,
  }) async {
    final next = await pipeline.endTurn(
      turnId: turnId,
      rackId: rackId,
      resolution: resolution,
    );
    return _copy(next);
  }

  Future<MatchEngineViewModel> recordFoul({
    required TurnId turnId,
    required RackId rackId,
    required String participant,
    required String reason,
  }) async {
    final next = await pipeline.recordFoul(
      turnId: turnId,
      rackId: rackId,
      participant: participant,
      reason: reason,
    );
    return _copy(next);
  }

  Future<MatchEngineViewModel> recordSafety({
    required TurnId turnId,
    required RackId rackId,
    required String participant,
    required String reason,
  }) async {
    final next = await pipeline.recordSafety(
      turnId: turnId,
      rackId: rackId,
      participant: participant,
      reason: reason,
    );
    return _copy(next);
  }

  Future<MatchEngineViewModel> endRack(RackId rackId, String winner) async {
    final next = await pipeline.endRack(rackId, winner);
    return _copy(next);
  }

  Future<MatchEngineViewModel> concedeMatch(String participant) async {
    final next = await pipeline.concedeMatch(participant);
    return _copy(next);
  }

  Future<MatchEngineViewModel> completeMatch(String winner) async {
    final next = await pipeline.completeMatch(winner);
    return _copy(next);
  }

  Future<MatchEngineViewModel> abandonMatch(String reason) async {
    final next = await pipeline.abandonMatch(reason);
    return _copy(next);
  }

  Future<MatchEngineViewModel> undo() async {
    final next = await pipeline.undo();
    return _copy(next);
  }

  Future<MatchEngineViewModel> redo() async {
    final next = await pipeline.redo();
    return _copy(next);
  }

  MatchEngineViewModel _copy(MatchManagerState next) {
    return MatchEngineViewModel._(
      pipeline: pipeline,
      state: next,
      ruleRegistry: ruleRegistry,
    );
  }
}
