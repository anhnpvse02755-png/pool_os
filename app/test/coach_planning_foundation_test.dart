import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/coach_decision_contracts.dart';
import 'package:pool_os/contracts/coach_decision_lifecycle_contracts.dart';
import 'package:pool_os/contracts/coach_plan_contracts.dart';
import 'package:pool_os/contracts/experience_projection_contracts.dart';
import 'package:pool_os/contracts/learning_eligibility_contracts.dart';
import 'package:pool_os/contracts/player_model_contracts.dart';
import 'package:pool_os/features/coach/domain/coach_decision_lifecycle_projector.dart';
import 'package:pool_os/features/coach/domain/coach_planner.dart';

void main() {
  const planner = CoachPlanner();
  const lifecycleProjector = CoachDecisionLifecycleProjector();

  test('active Decision is continued without creating a new Decision', () {
    final context = _context();
    final decision = _decision(context, DateTime.utc(2026, 7, 21, 10));
    final history = lifecycleProjector.projectHistory(
      decisions: [decision],
      transitions: lifecycleProjector.issue(decision).transitions,
    );

    final plan = planner.plan(context: context, history: history);

    expect(plan.step, CoachPlanStepKind.continueActiveDecision);
    expect(plan.decisionId, decision.id);
    expect(plan.decisionDigest, decision.digest);
    expect(plan.toJson(), isNot(contains('targetKnowledgeId')));
  });

  test('completed history requests a Decision without inventing a target', () {
    final context = _context();
    final decision = _decision(context, DateTime.utc(2026, 7, 21, 10));
    final lifecycle = lifecycleProjector.complete(
      decision: decision,
      lifecycle: lifecycleProjector.issue(decision),
      occurredAt: DateTime.utc(2026, 7, 21, 11),
    );
    final history = CoachDecisionHistoryProjection.create([lifecycle]);

    final plan = planner.plan(context: context, history: history);

    expect(plan.step, CoachPlanStepKind.requestNextDecision);
    expect(plan.decisionId, isNull);
    expect(plan.decisionDigest, isNull);
    expect(plan.toJson(), isNot(contains('targetKnowledgeId')));
  });

  test('superseded history continues its active replacement', () {
    final context = _context();
    final original = _decision(context, DateTime.utc(2026, 7, 21, 10));
    final replacement = _decision(context, DateTime.utc(2026, 7, 21, 11));
    final superseded = lifecycleProjector.supersede(
      decision: original,
      lifecycle: lifecycleProjector.issue(original),
      supersedingDecision: replacement,
    );
    final history = lifecycleProjector.projectHistory(
      decisions: [original, replacement],
      transitions: [
        ...superseded.transitions,
        ...lifecycleProjector.issue(replacement).transitions,
      ],
    );

    final plan = planner.plan(context: context, history: history);

    expect(plan.step, CoachPlanStepKind.continueActiveDecision);
    expect(plan.decisionId, replacement.id);
  });

  test('multiple active Decisions fail instead of being ranked', () {
    final context = _context();
    final first = _decision(context, DateTime.utc(2026, 7, 21, 10));
    final second = _decision(context, DateTime.utc(2026, 7, 21, 11));
    final history = lifecycleProjector.projectHistory(
      decisions: [first, second],
      transitions: [
        ...lifecycleProjector.issue(first).transitions,
        ...lifecycleProjector.issue(second).transitions,
      ],
    );

    expect(
      () => planner.plan(context: context, history: history),
      throwsStateError,
    );
  });

  test('Coach Plan factory rejects bypassing an active Decision', () {
    final context = _context();
    final decision = _decision(context, DateTime.utc(2026, 7, 21, 10));
    final history = lifecycleProjector.projectHistory(
      decisions: [decision],
      transitions: lifecycleProjector.issue(decision).transitions,
    );

    expect(
      () => CoachPlanContract.create(
        context: context,
        history: history,
        step: CoachPlanStepKind.requestNextDecision,
        decisionId: null,
        decisionDigest: null,
      ),
      throwsArgumentError,
    );
  });

  test('same Context and History produce the same Coach Plan digest', () {
    final context = _context();
    final decision = _decision(context, DateTime.utc(2026, 7, 21, 10));
    final history = lifecycleProjector.projectHistory(
      decisions: [decision],
      transitions: lifecycleProjector.issue(decision).transitions,
    );

    final first = planner.plan(context: context, history: history);
    final second = planner.plan(context: context, history: history);

    expect(second.digest, first.digest);
    expect(second.toJson(), first.toJson());
    expect(first.versions.contextDigest, context.digest);
    expect(first.versions.historyDigest, history.digest);
  });

  test('Planner does not mutate Decision History or emit prose', () {
    final context = _context();
    final decision = _decision(context, DateTime.utc(2026, 7, 21, 10));
    final history = lifecycleProjector.projectHistory(
      decisions: [decision],
      transitions: lifecycleProjector.issue(decision).transitions,
    );
    final before = jsonEncode(history.toJson());

    final plan = planner.plan(context: context, history: history);

    expect(jsonEncode(history.toJson()), before);
    final json = jsonEncode(plan.toJson());
    expect(json, isNot(contains('prompt')));
    expect(json, isNot(contains('message')));
    expect(json, isNot(contains('recommendation')));
    expect(json, isNot(contains('score')));
  });
}

CoachContextContract _context() {
  const playerId = 'player.primary';
  final profile = PlayerProfileContract(
    playerId: playerId,
    dominantHand: 'right',
    locale: 'vi',
  );
  final progress = PlayerProgressSnapshot.create(
    playerId: playerId,
    knowledgeVersion: '1.0.0',
    knowledgeDigest: 'knowledge.digest',
    sourceDecisionReferences: const ['technique.bank_shot:decision.1'],
    state: PlayerModelState(
      mastery: const [
        PlayerTechniqueState(
          knowledgeId: 'technique.bank_shot',
          successes: 1,
          attempts: 2,
          score: 0.5,
          mastered: false,
          evidenceCount: 1,
        ),
      ],
      mistakes: const [],
      preferences: const [],
      historyReferences: const [],
    ),
  );
  final event = ExperienceEventContract(
    eventId: 'experience.1',
    playerId: playerId,
    sessionId: 'session.1',
    occurredAt: DateTime.utc(2026, 7, 21, 9),
    kind: ExperienceEventKind.techniqueProgress,
    knowledgeId: 'technique.bank_shot',
    state: 'inProgress',
    sourceDecisionReference: 'technique.bank_shot:decision.1',
  );
  final timeline = ExperienceTimelineProjection.create([event]);
  final summary = SessionSummaryProjection.create(
    sessionId: 'session.1',
    events: [event],
  );
  final experience = ExperienceSnapshot.create(
    playerId: playerId,
    playerProgressDigest: progress.digest,
    knowledgeVersion: progress.knowledgeVersion,
    knowledgeDigest: progress.knowledgeDigest,
    timeline: timeline,
    sessions: [summary],
  );
  return CoachContextContract.create(
    profile: profile,
    progress: progress,
    experience: experience,
    eligibility: LearningEligibilityProjection.create(
      knowledgeVersion: progress.knowledgeVersion,
      knowledgeDigest: progress.knowledgeDigest,
      items: const [],
    ),
  );
}

CoachDecisionContract _decision(
  CoachContextContract context,
  DateTime effectiveAt,
) =>
    CoachDecisionContract.create(
      effectiveAt: effectiveAt,
      action: CoachDecisionAction.practiceTechnique,
      targetKnowledgeId: 'technique.bank_shot',
      reasons: const [
        CoachDecisionReason(
          code: CoachDecisionReasonCode.masteryBelowThreshold,
          knowledgeId: 'technique.bank_shot',
          observedState: 'inProgress',
        ),
      ],
      trace: const [
        CoachDecisionTraceStep(
          sequence: 1,
          stage: CoachDecisionTraceStage.contextValidation,
          outcomeCode: 'context_valid',
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
