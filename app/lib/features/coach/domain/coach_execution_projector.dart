import 'package:pool_os/contracts/coach_execution_contracts.dart';
import 'package:pool_os/contracts/coach_recommendation_contracts.dart';

class CoachExecutionProjector {
  const CoachExecutionProjector();

  CoachExecutionRecordContract accept({
    required CoachRecommendationContract recommendation,
    required DateTime occurredAt,
  }) =>
      replay(
        recommendation: recommendation,
        transitions: [
          CoachExecutionTransitionContract.accepted(
            recommendation: recommendation,
            occurredAt: occurredAt,
          ),
        ],
      );

  CoachExecutionRecordContract reject({
    required CoachRecommendationContract recommendation,
    required DateTime occurredAt,
  }) =>
      replay(
        recommendation: recommendation,
        transitions: [
          CoachExecutionTransitionContract.rejected(
            recommendation: recommendation,
            occurredAt: occurredAt,
          ),
        ],
      );

  CoachExecutionRecordContract defer({
    required CoachRecommendationContract recommendation,
    required DateTime occurredAt,
  }) =>
      replay(
        recommendation: recommendation,
        transitions: [
          CoachExecutionTransitionContract.deferred(
            recommendation: recommendation,
            occurredAt: occurredAt,
          ),
        ],
      );

  CoachExecutionRecordContract expire({
    required CoachRecommendationContract recommendation,
    required DateTime occurredAt,
  }) =>
      replay(
        recommendation: recommendation,
        transitions: [
          CoachExecutionTransitionContract.expired(
            recommendation: recommendation,
            occurredAt: occurredAt,
          ),
        ],
      );

  CoachExecutionRecordContract complete({
    required CoachRecommendationContract recommendation,
    required CoachExecutionRecordContract record,
    required DateTime occurredAt,
  }) =>
      _complete(
        recommendation: recommendation,
        record: record,
        occurredAt: occurredAt,
      );

  CoachExecutionRecordContract replay({
    required CoachRecommendationContract recommendation,
    required List<CoachExecutionTransitionContract> transitions,
  }) {
    if (transitions.isEmpty) {
      throw ArgumentError('Coach Execution replay requires transitions.');
    }
    final record = CoachExecutionRecordContract.create(
      recommendation: recommendation,
      state:
          transitions.reduce((a, b) => a.sequence > b.sequence ? a : b).toState,
      transitions: transitions,
    );
    return record;
  }

  CoachExecutionRecordContract _complete({
    required CoachRecommendationContract recommendation,
    required CoachExecutionRecordContract record,
    required DateTime occurredAt,
  }) {
    _requireAccepted(recommendation, record);
    return replay(
      recommendation: recommendation,
      transitions: [
        ...record.transitions,
        CoachExecutionTransitionContract.completed(
          sequence: record.transitions.length + 1,
          recommendation: recommendation,
          occurredAt: occurredAt,
        ),
      ],
    );
  }

  void _requireAccepted(
    CoachRecommendationContract recommendation,
    CoachExecutionRecordContract record,
  ) {
    if (record.recommendationId != recommendation.id ||
        record.recommendationDigest != recommendation.digest) {
      throw ArgumentError('Coach Execution recommendation binding is invalid.');
    }
    if (record.state != CoachExecutionState.accepted) {
      throw StateError('Only an accepted Coach Execution can transition.');
    }
  }
}
