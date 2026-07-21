import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/coach_decision_lifecycle_contracts.dart';
import 'package:pool_os/contracts/coach_plan_contracts.dart';

class CoachPlanner {
  const CoachPlanner();

  CoachPlanContract plan({
    required CoachContextContract context,
    required CoachDecisionHistoryProjection history,
  }) {
    final activeIds = history.activeDecisionIds;
    if (activeIds.length > 1) {
      throw StateError(
        'Coach Planner cannot choose between multiple active Decisions.',
      );
    }
    if (activeIds.isEmpty) {
      return CoachPlanContract.create(
        context: context,
        history: history,
        step: CoachPlanStepKind.requestNextDecision,
        decisionId: null,
        decisionDigest: null,
      );
    }
    final decisionId = activeIds.single;
    final lifecycle = history.decisions
        .singleWhere((item) => item.decisionId == decisionId);
    return CoachPlanContract.create(
      context: context,
      history: history,
      step: CoachPlanStepKind.continueActiveDecision,
      decisionId: decisionId,
      decisionDigest: lifecycle.decisionDigest,
    );
  }
}
