import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/coach_decision_contracts.dart';
import 'package:pool_os/contracts/coach_decision_lifecycle_contracts.dart';
import 'package:pool_os/features/coach/domain/coach_decision_lifecycle_projector.dart';

void main() {
  const projector = CoachDecisionLifecycleProjector();

  test('issuing a decision creates an immutable active lifecycle', () {
    final decision = _decision('context.1', DateTime.utc(2026, 7, 21, 10));
    final lifecycle = projector.issue(decision);
    final transition = lifecycle.transitions.single;

    expect(lifecycle.state, CoachDecisionLifecycleState.active);
    expect(transition.kind, CoachDecisionTransitionKind.issued);
    expect(transition.fromState, isNull);
    expect(transition.toState, CoachDecisionLifecycleState.active);
    expect(transition.occurredAt, decision.effectiveAt);
    expect(
      transition.toJson()['schemaVersion'],
      coachDecisionTransitionContractVersion,
    );
    expect(
      lifecycle.toJson()['schemaVersion'],
      coachDecisionLifecycleProjectionVersion,
    );
    expect(() => lifecycle.transitions.add(transition), throwsUnsupportedError);
  });

  test('completion is deterministic and replayable from reordered input', () {
    final decision = _decision('context.1', DateTime.utc(2026, 7, 21, 10));
    final issued = projector.issue(decision);
    final completed = projector.complete(
      decision: decision,
      lifecycle: issued,
      occurredAt: DateTime.utc(2026, 7, 21, 11),
    );
    final replayed = projector.replay(
      decision: decision,
      transitions: completed.transitions.reversed.toList(),
    );

    expect(completed.state, CoachDecisionLifecycleState.completed);
    expect(replayed.digest, completed.digest);
    expect(replayed.toJson(), completed.toJson());
    expect(completed.transitions.map((item) => item.sequence), [1, 2]);
  });

  test('supersede links a newer decision without mutating the original', () {
    final original = _decision('context.1', DateTime.utc(2026, 7, 21, 10));
    final replacement = _decision(
      'context.2',
      DateTime.utc(2026, 7, 21, 11),
      targetKnowledgeId: 'technique.kick_shot',
    );
    final originalJson = jsonEncode(original.toJson());
    final lifecycle = projector.supersede(
      decision: original,
      lifecycle: projector.issue(original),
      supersedingDecision: replacement,
    );

    expect(lifecycle.state, CoachDecisionLifecycleState.superseded);
    expect(lifecycle.supersededByDecisionId, replacement.id);
    expect(
      lifecycle.transitions.last.supersedingDecisionDigest,
      replacement.digest,
    );
    expect(jsonEncode(original.toJson()), originalJson);
  });

  test('history projection validates supersede links and is deterministic', () {
    final original = _decision('context.1', DateTime.utc(2026, 7, 21, 10));
    final replacement = _decision(
      'context.2',
      DateTime.utc(2026, 7, 21, 11),
      targetKnowledgeId: 'technique.kick_shot',
    );
    final superseded = projector.supersede(
      decision: original,
      lifecycle: projector.issue(original),
      supersedingDecision: replacement,
    );
    final active = projector.issue(replacement);
    final transitions = [...superseded.transitions, ...active.transitions];
    final first = projector.projectHistory(
      decisions: [original, replacement],
      transitions: transitions,
    );
    final second = projector.projectHistory(
      decisions: [replacement, original],
      transitions: transitions.reversed.toList(),
    );

    expect(first.activeDecisionIds, [replacement.id]);
    expect(second.digest, first.digest);
    expect(second.toJson(), first.toJson());
    expect(
      first.toJson()['schemaVersion'],
      coachDecisionHistoryProjectionVersion,
    );
  });

  test('history is chronological with decision ID as the stable tie-break', () {
    final later = _decision(
      'context.later',
      DateTime.utc(2026, 7, 21, 12),
      targetKnowledgeId: 'technique.a',
    );
    final earlier = _decision(
      'context.earlier',
      DateTime.utc(2026, 7, 21, 10),
      targetKnowledgeId: 'technique.z',
    );
    final history = projector.projectHistory(
      decisions: [later, earlier],
      transitions: [
        ...projector.issue(later).transitions,
        ...projector.issue(earlier).transitions,
      ],
    );

    expect(
      history.decisions.map((item) => item.decisionId),
      [earlier.id, later.id],
    );
  });

  test('terminal decisions reject additional lifecycle transitions', () {
    final decision = _decision('context.1', DateTime.utc(2026, 7, 21, 10));
    final completed = projector.complete(
      decision: decision,
      lifecycle: projector.issue(decision),
      occurredAt: DateTime.utc(2026, 7, 21, 11),
    );

    expect(
      () => projector.complete(
        decision: decision,
        lifecycle: completed,
        occurredAt: DateTime.utc(2026, 7, 21, 12),
      ),
      throwsStateError,
    );
  });

  test('replay rejects gaps, foreign bindings, and transitions before issue',
      () {
    final first = _decision('context.1', DateTime.utc(2026, 7, 21, 10));
    final second = _decision('context.2', DateTime.utc(2026, 7, 21, 11));
    final firstIssued = CoachDecisionTransitionContract.issued(first);
    final secondIssued = CoachDecisionTransitionContract.issued(second);
    final completed = CoachDecisionTransitionContract.completed(
      sequence: 2,
      decision: first,
      occurredAt: DateTime.utc(2026, 7, 21, 12),
    );

    expect(
      () => projector.replay(decision: first, transitions: [completed]),
      throwsArgumentError,
    );
    expect(
      () => projector.replay(
        decision: first,
        transitions: [firstIssued, secondIssued],
      ),
      throwsArgumentError,
    );
  });

  test('supersede rules reject self, older, and simultaneous decisions', () {
    final original = _decision('context.1', DateTime.utc(2026, 7, 21, 10));
    final older = _decision('context.2', DateTime.utc(2026, 7, 21, 9));
    final simultaneous = _decision(
      'context.3',
      DateTime.utc(2026, 7, 21, 10),
    );
    final issued = projector.issue(original);

    expect(
      () => projector.supersede(
        decision: original,
        lifecycle: issued,
        supersedingDecision: original,
      ),
      throwsArgumentError,
    );
    expect(
      () => projector.supersede(
        decision: original,
        lifecycle: issued,
        supersedingDecision: older,
      ),
      throwsArgumentError,
    );
    expect(
      () => projector.supersede(
        decision: original,
        lifecycle: issued,
        supersedingDecision: simultaneous,
      ),
      throwsArgumentError,
    );
  });

  test('supersede preserves a replacement with newer Knowledge provenance', () {
    final original = _decision('context.1', DateTime.utc(2026, 7, 21, 10));
    final replacement = _decision(
      'context.2',
      DateTime.utc(2026, 7, 21, 11),
      knowledgeVersion: '1.1.0',
      knowledgeDigest: 'knowledge.new',
    );
    final lifecycle = projector.supersede(
      decision: original,
      lifecycle: projector.issue(original),
      supersedingDecision: replacement,
    );

    expect(lifecycle.supersededByDecisionId, replacement.id);
    expect(
      lifecycle.transitions.last.supersedingDecisionDigest,
      replacement.digest,
    );
  });

  test('lifecycle factory rejects a state inconsistent with its transitions',
      () {
    final decision = _decision('context.1', DateTime.utc(2026, 7, 21, 10));
    final issued = CoachDecisionTransitionContract.issued(decision);

    expect(
      () => CoachDecisionLifecycleProjection.create(
        decision: decision,
        state: CoachDecisionLifecycleState.completed,
        transitions: [issued],
        supersededByDecisionId: null,
      ),
      throwsArgumentError,
    );
  });

  test('lifecycle factory rejects terminal states without an issued transition',
      () {
    final decision = _decision('context.1', DateTime.utc(2026, 7, 21, 10));
    final replacement = _decision(
      'context.2',
      DateTime.utc(2026, 7, 21, 11),
      targetKnowledgeId: 'technique.kick_shot',
    );
    final completed = CoachDecisionTransitionContract.completed(
      sequence: 1,
      decision: decision,
      occurredAt: DateTime.utc(2026, 7, 21, 11),
    );
    final superseded = CoachDecisionTransitionContract.superseded(
      sequence: 1,
      decision: decision,
      supersedingDecision: replacement,
    );

    expect(
      () => CoachDecisionLifecycleProjection.create(
        decision: decision,
        state: CoachDecisionLifecycleState.completed,
        transitions: [completed],
        supersededByDecisionId: null,
      ),
      throwsArgumentError,
    );
    expect(
      () => CoachDecisionLifecycleProjection.create(
        decision: decision,
        state: CoachDecisionLifecycleState.superseded,
        transitions: [superseded],
        supersededByDecisionId: replacement.id,
      ),
      throwsArgumentError,
    );
  });

  test('history rejects a missing superseding decision', () {
    final original = _decision('context.1', DateTime.utc(2026, 7, 21, 10));
    final replacement = _decision('context.2', DateTime.utc(2026, 7, 21, 11));
    final superseded = projector.supersede(
      decision: original,
      lifecycle: projector.issue(original),
      supersedingDecision: replacement,
    );

    expect(
      () => projector.projectHistory(
        decisions: [original],
        transitions: superseded.transitions,
      ),
      throwsArgumentError,
    );
  });

  test('lifecycle output remains structured and contains no generated prose',
      () {
    final lifecycle = projector.issue(
      _decision('context.1', DateTime.utc(2026, 7, 21, 10)),
    );
    final json = jsonEncode(lifecycle.toJson());

    expect(json, isNot(contains('prompt')));
    expect(json, isNot(contains('message')));
    expect(json, isNot(contains('explanation')));
    expect(lifecycle.digest, hasLength(64));
  });
}

CoachDecisionContract _decision(
  String contextDigest,
  DateTime effectiveAt, {
  String targetKnowledgeId = 'technique.bank_shot',
  String knowledgeVersion = '1.0.0',
  String knowledgeDigest = 'knowledge.digest',
}) =>
    CoachDecisionContract.create(
      effectiveAt: effectiveAt,
      action: CoachDecisionAction.practiceTechnique,
      targetKnowledgeId: targetKnowledgeId,
      reasons: [
        CoachDecisionReason(
          code: CoachDecisionReasonCode.masteryBelowThreshold,
          knowledgeId: targetKnowledgeId,
          observedState: 'inProgress',
        ),
      ],
      trace: [
        const CoachDecisionTraceStep(
          sequence: 1,
          stage: CoachDecisionTraceStage.contextValidation,
          outcomeCode: 'context_valid',
        ),
        CoachDecisionTraceStep(
          sequence: 2,
          stage: CoachDecisionTraceStage.decision,
          outcomeCode: 'semantic_decision_emitted',
          knowledgeId: targetKnowledgeId,
        ),
      ],
      alternatives: const [],
      versions: CoachDecisionVersionBinding(
        contextContractVersion: 1,
        contextDigest: contextDigest,
        knowledgeVersion: knowledgeVersion,
        knowledgeDigest: knowledgeDigest,
        policyVersion: coachDecisionPolicyVersion,
      ),
    );
