import 'package:pool_os/contracts/coach_execution_contracts.dart';
import 'package:pool_os/contracts/training_session_contracts.dart';
import 'package:pool_os/contracts/training_session_execution_contracts.dart';

class SessionExecutionCoordinator {
  const SessionExecutionCoordinator();

  TrainingSessionExecutionContract project({
    required TrainingSessionContract session,
    required List<CoachExecutionRecordContract> executions,
  }) {
    final byRecommendation = <String, CoachExecutionRecordContract>{};
    for (final execution in executions) {
      if (byRecommendation.containsKey(execution.recommendationId)) {
        throw ArgumentError('Session Execution contains a duplicate record.');
      }
      final sessionItem = session.items.where(
        (item) => item.recommendationId == execution.recommendationId,
      );
      if (sessionItem.length != 1 ||
          sessionItem.single.recommendationDigest !=
              execution.recommendationDigest) {
        throw ArgumentError('Session Execution record is orphaned or stale.');
      }
      byRecommendation[execution.recommendationId] = execution;
    }
    final items = session.items.map((source) {
      final execution = byRecommendation[source.recommendationId];
      return TrainingSessionExecutionItemContract(
        position: source.position,
        recommendationId: source.recommendationId,
        sessionItemPlanningNodeId: source.planningNodeId,
        executionRecordId: execution?.id,
        executionRecordDigest: execution?.digest,
        executionState: execution?.state,
      );
    }).toList();
    final state = executions.isEmpty
        ? TrainingSessionExecutionState.pending
        : executions.length == items.length &&
                executions.every(
                  (item) => item.state != CoachExecutionState.accepted,
                )
            ? TrainingSessionExecutionState.completed
            : TrainingSessionExecutionState.inProgress;
    return TrainingSessionExecutionContract.create(
      session: session,
      state: state,
      items: items,
    );
  }
}
