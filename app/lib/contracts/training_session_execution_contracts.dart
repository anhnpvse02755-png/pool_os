import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/coach_execution_contracts.dart';
import 'package:pool_os/contracts/training_session_contracts.dart';

const trainingSessionExecutionContractVersion = 1;
const trainingSessionExecutionItemContractVersion = 1;
const sessionExecutionCoordinatorPolicyVersion = 'session-execution/1.0.0';

enum TrainingSessionExecutionState { pending, inProgress, completed }

class TrainingSessionExecutionItemContract {
  const TrainingSessionExecutionItemContract({
    required this.position,
    required this.recommendationId,
    required this.sessionItemPlanningNodeId,
    required this.executionRecordId,
    required this.executionRecordDigest,
    required this.executionState,
  });

  final int position;
  final String recommendationId;
  final String sessionItemPlanningNodeId;
  final String? executionRecordId;
  final String? executionRecordDigest;
  final CoachExecutionState? executionState;

  Map<String, dynamic> toJson() => {
        'schemaVersion': trainingSessionExecutionItemContractVersion,
        'position': position,
        'recommendationId': recommendationId,
        'sessionItemPlanningNodeId': sessionItemPlanningNodeId,
        if (executionRecordId != null) 'executionRecordId': executionRecordId,
        if (executionRecordDigest != null)
          'executionRecordDigest': executionRecordDigest,
        if (executionState != null) 'executionState': executionState!.name,
      };
}

class TrainingSessionExecutionContract {
  const TrainingSessionExecutionContract._({
    required this.id,
    required this.playerId,
    required this.sessionId,
    required this.sessionDigest,
    required this.state,
    required this.items,
    required this.digest,
  });

  factory TrainingSessionExecutionContract.create({
    required TrainingSessionContract session,
    required TrainingSessionExecutionState state,
    required List<TrainingSessionExecutionItemContract> items,
  }) {
    if (items.length != session.items.length) {
      throw ArgumentError('Session Execution must cover every Session item.');
    }
    final seen = <String>{};
    var records = 0;
    var accepted = 0;
    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      final source = session.items[index];
      final hasRecord = item.executionRecordId != null;
      if (item.position != index + 1 ||
          item.recommendationId != source.recommendationId ||
          item.sessionItemPlanningNodeId != source.planningNodeId ||
          !seen.add(item.recommendationId) ||
          (hasRecord != (item.executionRecordDigest != null)) ||
          (hasRecord != (item.executionState != null))) {
        throw ArgumentError('Session Execution item provenance is invalid.');
      }
      if (hasRecord) records++;
      if (item.executionState == CoachExecutionState.accepted) accepted++;
    }
    final expected = records == 0
        ? TrainingSessionExecutionState.pending
        : records == items.length && accepted == 0
            ? TrainingSessionExecutionState.completed
            : TrainingSessionExecutionState.inProgress;
    if (state != expected) {
      throw ArgumentError('Session Execution lifecycle state is invalid.');
    }
    final payload = {
      'schemaVersion': trainingSessionExecutionContractVersion,
      'playerId': session.playerId,
      'sessionId': session.sessionId,
      'sessionDigest': session.digest,
      'state': state.name,
      'items': items.map((item) => item.toJson()).toList(),
      'policyVersion': sessionExecutionCoordinatorPolicyVersion,
    };
    final digest = _digest(payload);
    return TrainingSessionExecutionContract._(
      id: 'training-session-execution.${digest.substring(0, 16)}',
      playerId: session.playerId,
      sessionId: session.sessionId,
      sessionDigest: session.digest,
      state: state,
      items: List.unmodifiable(items),
      digest: digest,
    );
  }

  final String id;
  final String playerId;
  final String sessionId;
  final String sessionDigest;
  final TrainingSessionExecutionState state;
  final List<TrainingSessionExecutionItemContract> items;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': trainingSessionExecutionContractVersion,
        'id': id,
        'playerId': playerId,
        'sessionId': sessionId,
        'sessionDigest': sessionDigest,
        'state': state.name,
        'items': items.map((item) => item.toJson()).toList(),
        'policyVersion': sessionExecutionCoordinatorPolicyVersion,
        'digest': digest,
      };
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
