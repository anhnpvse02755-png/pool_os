import 'dart:convert';
import 'dart:io';

import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/coach_decision_contracts.dart';
import 'package:pool_os/contracts/coach_decision_lifecycle_contracts.dart';
import 'package:pool_os/contracts/coach_plan_contracts.dart';
import 'package:pool_os/contracts/coach_recommendation_contracts.dart';
import 'package:pool_os/contracts/learning_eligibility_contracts.dart';
import 'package:pool_os/contracts/player_model_contracts.dart';
import 'package:pool_os/contracts/stop_shot_contracts.dart';
import 'package:pool_os/features/coach/application/coach_context_builder.dart';
import 'package:pool_os/features/coach/application/learning_eligibility_projector.dart';
import 'package:pool_os/features/coach/application/learning_runtime.dart';
import 'package:pool_os/features/coach/domain/coach_decision_lifecycle_projector.dart';
import 'package:pool_os/features/coach/domain/coach_planner.dart';
import 'package:pool_os/features/coach/domain/coach_recommendation_builder.dart';
import 'package:pool_os/features/event/domain/stop_shot_evidence_log.dart';
import 'package:pool_os/features/player_model/application/experience_projector.dart';
import 'package:pool_os/features/player_model/application/player_model_projector.dart';

void main() {
  late ExecutableKnowledgePack dependencyPack;
  late ExecutableKnowledgePack unlockPack;
  late ExecutableKnowledgePack mistakePack;
  const eligibilityProjector = LearningEligibilityProjector();
  const lifecycleProjector = CoachDecisionLifecycleProjector();
  const planner = CoachPlanner();
  const builder = CoachRecommendationBuilder();

  setUpAll(() {
    dependencyPack = _pack('lr_2');
    unlockPack = _pack('lr_4');
    mistakePack = _pack('lr_1');
  });

  test('eligibility projects a resolved prerequisite without Evidence',
      () async {
    final snapshot =
        await _runtime(dependencyPack, _MemoryLearningEvidenceLog())
            .replayTechnique('technique.stop_control');

    final projection = eligibilityProjector.project([snapshot]);
    final item = projection.items.single;
    final encoded = jsonEncode(projection.toJson());

    expect(item.sourceKnowledgeId, 'technique.stop_control');
    expect(item.resolvedKnowledgeId, 'technique.straight_stroke');
    expect(item.sourceAvailable, isFalse);
    expect(
      item.blockers.map((reason) => reason.code),
      contains('PREREQUISITE_UNSATISFIED'),
    );
    expect(encoded, isNot(contains('evidence')));
    expect(encoded, isNot(contains('dependencies')));
    expect(encoded, isNot(contains('unlockExpression')));
  });

  test('eligibility changes only after Learning Runtime resolves prerequisite',
      () async {
    final log = _MemoryLearningEvidenceLog();
    final runtime = _runtime(dependencyPack, log);
    await runtime.recordCompletedDrill(
      knowledgeId: 'technique.straight_stroke',
      commandId: 'straight-mastered',
      successes: 8,
    );
    final snapshot = await runtime.replayTechnique('technique.stop_control');

    final item = eligibilityProjector.project([snapshot]).items.single;

    expect(item.sourceAvailable, isTrue);
    expect(item.resolvedKnowledgeId, 'technique.stop_control');
    expect(item.blockers, isEmpty);
  });

  test('eligibility consumes Learning Runtime unlock resolution', () async {
    final snapshot = await _runtime(unlockPack, _MemoryLearningEvidenceLog())
        .replayTechnique('technique.position_control');

    final item = eligibilityProjector.project([snapshot]).items.single;

    expect(item.resolvedKnowledgeId, 'technique.follow_control');
    expect(
      item.blockers.map((reason) => reason.expressionNodeId),
      contains('unlock'),
    );
  });

  test('active Decision is continued by ID and digest without a new target',
      () async {
    final context = await _dependencyContext(dependencyPack);
    final decision = _decision(context);
    final history = CoachDecisionHistoryProjection.create([
      lifecycleProjector.issue(decision),
    ]);
    final plan = planner.plan(context: context, history: history);

    final recommendation = builder.build(
      context: context,
      history: history,
      plan: plan,
    );

    expect(
      recommendation.kind,
      CoachRecommendationKind.continueActiveDecision,
    );
    expect(recommendation.decisionId, decision.id);
    expect(recommendation.decisionDigest, decision.digest);
    expect(recommendation.targetKnowledgeId, isNull);
  });

  test('new Decision plan selects only the resolved eligibility target',
      () async {
    final context = await _dependencyContext(dependencyPack);
    final workflow = _completedWorkflow(context);

    final first = builder.build(
      context: context,
      history: workflow.history,
      plan: workflow.plan,
    );
    final second = builder.build(
      context: context,
      history: workflow.history,
      plan: workflow.plan,
    );
    final encoded = jsonEncode(first.toJson());

    expect(first.kind, CoachRecommendationKind.practiceTechnique);
    expect(first.sourceKnowledgeId, 'technique.stop_control');
    expect(first.targetKnowledgeId, 'technique.straight_stroke');
    expect(second.digest, first.digest);
    expect(second.toJson(), first.toJson());
    expect(encoded, isNot(contains('score')));
    expect(encoded, isNot(contains('prompt')));
    expect(encoded, isNot(contains('prose')));
  });

  test('persistent Mistake has deterministic correction priority', () async {
    final log = _MemoryLearningEvidenceLog();
    final runtime = _runtime(mistakePack, log);
    final technique = await runtime.replayTechnique('technique.bank_shot');
    final mistake = await runtime.recordMistakeObservation(
      knowledgeId: 'mistake.bank_alignment_left',
      commandId: 'alignment-left',
      resolved: false,
      confidence: 1,
    );
    final context = _context([technique, mistake]);
    final workflow = _completedWorkflow(context);

    final recommendation = builder.build(
      context: context,
      history: workflow.history,
      plan: workflow.plan,
    );

    expect(recommendation.kind, CoachRecommendationKind.correctMistake);
    expect(
      recommendation.targetKnowledgeId,
      'mistake.bank_alignment_left',
    );
  });

  test('Recommendation rejects a Plan bound to another Context', () async {
    final context = await _dependencyContext(dependencyPack);
    final workflow = _completedWorkflow(context);
    final log = _MemoryLearningEvidenceLog();
    final runtime = _runtime(dependencyPack, log);
    await runtime.recordCompletedDrill(
      knowledgeId: 'technique.straight_stroke',
      commandId: 'straight-mastered-other',
      successes: 8,
    );
    final otherContext = _context([
      await runtime.replayTechnique('technique.stop_control'),
    ]);

    expect(
      () => builder.build(
        context: otherContext,
        history: workflow.history,
        plan: workflow.plan,
      ),
      throwsArgumentError,
    );
  });

  test('Recommendation is pure and fails closed without resolved candidates',
      () async {
    final context = await _dependencyContext(dependencyPack);
    final emptyContext = CoachContextContract.create(
      profile: context.profile,
      progress: context.progress,
      experience: context.experience,
      eligibility: LearningEligibilityProjection.create(
        knowledgeVersion: context.versions.knowledgeVersion,
        knowledgeDigest: context.versions.knowledgeDigest,
        items: const [],
      ),
    );
    final workflow = _completedWorkflow(emptyContext);
    final beforeContext = jsonEncode(emptyContext.toJson());
    final beforeHistory = jsonEncode(workflow.history.toJson());
    final beforePlan = jsonEncode(workflow.plan.toJson());

    expect(
      () => builder.build(
        context: emptyContext,
        history: workflow.history,
        plan: workflow.plan,
      ),
      throwsStateError,
    );
    expect(jsonEncode(emptyContext.toJson()), beforeContext);
    expect(jsonEncode(workflow.history.toJson()), beforeHistory);
    expect(jsonEncode(workflow.plan.toJson()), beforePlan);
  });
}

ExecutableKnowledgePack _pack(String fixture) =>
    ExecutableKnowledgePack.fromJsonString(
      File(
        '../packages/billiard_knowledge/test/fixtures/$fixture/generated/'
        'published_candidate.json',
      ).readAsStringSync(),
    );

LearningRuntime _runtime(
  ExecutableKnowledgePack pack,
  LearningEvidenceLog log,
) =>
    LearningRuntime(
      pack: pack,
      evidenceLog: log,
      clock: () => DateTime.utc(2026, 7, 21, 18),
    );

Future<CoachContextContract> _dependencyContext(
  ExecutableKnowledgePack pack,
) async {
  final snapshot = await _runtime(pack, _MemoryLearningEvidenceLog())
      .replayTechnique('technique.stop_control');
  return _context([snapshot]);
}

CoachContextContract _context(List<LearningSnapshot> learning) {
  final profile = PlayerProfileContract(
    playerId: 'player.primary',
    dominantHand: 'right',
    locale: 'vi',
  );
  final progress = const PlayerModelProjector().project(
    profile: profile,
    learningSnapshots: learning,
  );
  final experience = const ExperienceProjector().project(
    progress: progress,
    inputs: [
      for (var index = 0; index < learning.length; index++)
        ExperienceProjectionInput(
          sessionId: 'session.recommendation.$index',
          learningSnapshot: learning[index],
        ),
    ],
  );
  return const CoachContextBuilder().build(
    profile: profile,
    progress: progress,
    experience: experience,
    eligibility: const LearningEligibilityProjector().project(learning),
  );
}

CoachDecisionContract _decision(CoachContextContract context) =>
    CoachDecisionContract.create(
      effectiveAt: DateTime.utc(2026, 7, 21, 18),
      action: CoachDecisionAction.practiceTechnique,
      targetKnowledgeId: 'technique.straight_stroke',
      reasons: const [
        CoachDecisionReason(
          code: CoachDecisionReasonCode.masteryBelowThreshold,
          knowledgeId: 'technique.straight_stroke',
        ),
      ],
      trace: const [
        CoachDecisionTraceStep(
          sequence: 1,
          stage: CoachDecisionTraceStage.decision,
          outcomeCode: 'PRACTICE_TECHNIQUE',
          knowledgeId: 'technique.straight_stroke',
        ),
      ],
      alternatives: const [],
      versions: CoachDecisionVersionBinding(
        contextContractVersion: coachContextContractVersion,
        contextDigest: context.digest,
        knowledgeVersion: context.versions.knowledgeVersion,
        knowledgeDigest: context.versions.knowledgeDigest,
        policyVersion: coachDecisionPolicyVersion,
      ),
    );

_Workflow _completedWorkflow(CoachContextContract context) {
  const lifecycleProjector = CoachDecisionLifecycleProjector();
  const planner = CoachPlanner();
  final decision = _decision(context);
  final history = CoachDecisionHistoryProjection.create([
    lifecycleProjector.complete(
      decision: decision,
      lifecycle: lifecycleProjector.issue(decision),
      occurredAt: DateTime.utc(2026, 7, 21, 19),
    ),
  ]);
  return _Workflow(
    history: history,
    plan: planner.plan(context: context, history: history),
  );
}

class _Workflow {
  const _Workflow({required this.history, required this.plan});

  final CoachDecisionHistoryProjection history;
  final CoachPlanContract plan;
}

class _MemoryLearningEvidenceLog implements LearningEvidenceLog {
  final List<LearningEvidenceBatch> _batches = [];

  @override
  Future<bool> append(LearningEvidenceBatch batch) async {
    if (_batches.any((item) => item.commandId == batch.commandId)) return false;
    _batches.add(batch);
    return true;
  }

  @override
  Future<List<LearningEvidenceBatch>> readAll() async =>
      List.unmodifiable(_batches);
}
