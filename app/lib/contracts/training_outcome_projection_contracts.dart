import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/coach_execution_contracts.dart';
import 'package:pool_os/contracts/training_session_execution_contracts.dart';

const trainingOutcomeProjectionContractVersion = 1;
const trainingOutcomeItemContractVersion = 1;
const trainingOutcomePolicyVersion = 'training-outcome-projection/1.0.0';

enum TrainingOutcomeKind { completed, pending, deferred, rejected, expired }

class TrainingOutcomeItemContract {
  const TrainingOutcomeItemContract({
    required this.position,
    required this.recommendationId,
    required this.kind,
    required this.executionRecordId,
  });

  final int position;
  final String recommendationId;
  final TrainingOutcomeKind kind;
  final String? executionRecordId;

  Map<String, dynamic> toJson() => {
        'schemaVersion': trainingOutcomeItemContractVersion,
        'position': position,
        'recommendationId': recommendationId,
        'kind': kind.name,
        if (executionRecordId != null) 'executionRecordId': executionRecordId,
      };
}

class TrainingOutcomeSummaryContract {
  const TrainingOutcomeSummaryContract({
    required this.total,
    required this.completed,
    required this.pending,
    required this.deferred,
    required this.rejected,
    required this.expired,
  });

  final int total;
  final int completed;
  final int pending;
  final int deferred;
  final int rejected;
  final int expired;

  Map<String, dynamic> toJson() => {
        'total': total,
        'completed': completed,
        'pending': pending,
        'deferred': deferred,
        'rejected': rejected,
        'expired': expired,
      };
}

class TrainingOutcomeProjectionContract {
  const TrainingOutcomeProjectionContract._({
    required this.id,
    required this.playerId,
    required this.sessionId,
    required this.sessionExecutionDigest,
    required this.sessionDigest,
    required this.items,
    required this.summary,
    required this.digest,
  });

  factory TrainingOutcomeProjectionContract.create({
    required TrainingSessionExecutionContract sessionExecution,
    required List<TrainingOutcomeItemContract> items,
  }) {
    if (items.length != sessionExecution.items.length) {
      throw ArgumentError('Training Outcome coverage is invalid.');
    }
    final seen = <String>{};
    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      final source = sessionExecution.items[index];
      if (item.position != index + 1 ||
          item.recommendationId != source.recommendationId ||
          item.executionRecordId != source.executionRecordId ||
          item.kind != _outcome(source.executionState) ||
          !seen.add(item.recommendationId)) {
        throw ArgumentError('Training Outcome item provenance is invalid.');
      }
    }
    int count(TrainingOutcomeKind kind) =>
        items.where((item) => item.kind == kind).length;
    final summary = TrainingOutcomeSummaryContract(
      total: items.length,
      completed: count(TrainingOutcomeKind.completed),
      pending: count(TrainingOutcomeKind.pending),
      deferred: count(TrainingOutcomeKind.deferred),
      rejected: count(TrainingOutcomeKind.rejected),
      expired: count(TrainingOutcomeKind.expired),
    );
    final payload = {
      'schemaVersion': trainingOutcomeProjectionContractVersion,
      'playerId': sessionExecution.playerId,
      'sessionId': sessionExecution.sessionId,
      'sessionExecutionDigest': sessionExecution.digest,
      'sessionDigest': sessionExecution.sessionDigest,
      'items': items.map((item) => item.toJson()).toList(),
      'summary': summary.toJson(),
      'policyVersion': trainingOutcomePolicyVersion,
    };
    final digest = _digest(payload);
    return TrainingOutcomeProjectionContract._(
      id: 'training-outcome.${digest.substring(0, 16)}',
      playerId: sessionExecution.playerId,
      sessionId: sessionExecution.sessionId,
      sessionExecutionDigest: sessionExecution.digest,
      sessionDigest: sessionExecution.sessionDigest,
      items: List.unmodifiable(items),
      summary: summary,
      digest: digest,
    );
  }

  final String id;
  final String playerId;
  final String sessionId;
  final String sessionExecutionDigest;
  final String sessionDigest;
  final List<TrainingOutcomeItemContract> items;
  final TrainingOutcomeSummaryContract summary;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': trainingOutcomeProjectionContractVersion,
        'id': id,
        'playerId': playerId,
        'sessionId': sessionId,
        'sessionExecutionDigest': sessionExecutionDigest,
        'sessionDigest': sessionDigest,
        'items': items.map((item) => item.toJson()).toList(),
        'summary': summary.toJson(),
        'policyVersion': trainingOutcomePolicyVersion,
        'digest': digest,
      };
}

TrainingOutcomeKind _outcome(CoachExecutionState? state) => switch (state) {
      CoachExecutionState.completed => TrainingOutcomeKind.completed,
      CoachExecutionState.deferred => TrainingOutcomeKind.deferred,
      CoachExecutionState.rejected => TrainingOutcomeKind.rejected,
      CoachExecutionState.expired => TrainingOutcomeKind.expired,
      null || CoachExecutionState.accepted => TrainingOutcomeKind.pending,
    };

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
