import 'package:pool_os/contracts/coach_execution_contracts.dart';
import 'package:pool_os/contracts/training_outcome_projection_contracts.dart';
import 'package:pool_os/contracts/training_session_execution_contracts.dart';

class TrainingOutcomeProjector {
  const TrainingOutcomeProjector();

  TrainingOutcomeProjectionContract project({
    required TrainingSessionExecutionContract sessionExecution,
    required List<CoachExecutionRecordContract> executions,
  }) {
    final byId = <String, CoachExecutionRecordContract>{};
    for (final record in executions) {
      if (byId.containsKey(record.id)) {
        throw ArgumentError('Training Outcome has duplicate Execution.');
      }
      byId[record.id] = record;
    }
    final items = sessionExecution.items.map((source) {
      final record = source.executionRecordId == null
          ? null
          : byId[source.executionRecordId];
      if (source.executionRecordId != null &&
          (record == null ||
              record.digest != source.executionRecordDigest ||
              record.recommendationId != source.recommendationId ||
              record.state != source.executionState)) {
        throw ArgumentError('Training Outcome Execution is orphaned or stale.');
      }
      return TrainingOutcomeItemContract(
        position: source.position,
        recommendationId: source.recommendationId,
        kind: _kind(source.executionState),
        executionRecordId: source.executionRecordId,
      );
    }).toList();
    if (byId.length !=
        sessionExecution.items
            .where((item) => item.executionRecordId != null)
            .length) {
      throw ArgumentError('Training Outcome contains an orphan Execution.');
    }
    return TrainingOutcomeProjectionContract.create(
      sessionExecution: sessionExecution,
      items: items,
    );
  }
}

TrainingOutcomeKind _kind(CoachExecutionState? state) => switch (state) {
      CoachExecutionState.completed => TrainingOutcomeKind.completed,
      CoachExecutionState.deferred => TrainingOutcomeKind.deferred,
      CoachExecutionState.rejected => TrainingOutcomeKind.rejected,
      CoachExecutionState.expired => TrainingOutcomeKind.expired,
      null || CoachExecutionState.accepted => TrainingOutcomeKind.pending,
    };
