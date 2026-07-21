import 'package:pool_os/contracts/coach_decision_contracts.dart';
import 'package:pool_os/contracts/coach_decision_lifecycle_contracts.dart';

class CoachDecisionLifecycleProjector {
  const CoachDecisionLifecycleProjector();

  CoachDecisionLifecycleProjection issue(CoachDecisionContract decision) =>
      replay(
        decision: decision,
        transitions: [CoachDecisionTransitionContract.issued(decision)],
      );

  CoachDecisionLifecycleProjection complete({
    required CoachDecisionContract decision,
    required CoachDecisionLifecycleProjection lifecycle,
    required DateTime occurredAt,
  }) {
    _requireActive(decision, lifecycle);
    return replay(
      decision: decision,
      transitions: [
        ...lifecycle.transitions,
        CoachDecisionTransitionContract.completed(
          sequence: lifecycle.transitions.length + 1,
          decision: decision,
          occurredAt: occurredAt,
        ),
      ],
    );
  }

  CoachDecisionLifecycleProjection supersede({
    required CoachDecisionContract decision,
    required CoachDecisionLifecycleProjection lifecycle,
    required CoachDecisionContract supersedingDecision,
  }) {
    _requireActive(decision, lifecycle);
    return replay(
      decision: decision,
      transitions: [
        ...lifecycle.transitions,
        CoachDecisionTransitionContract.superseded(
          sequence: lifecycle.transitions.length + 1,
          decision: decision,
          supersedingDecision: supersedingDecision,
        ),
      ],
    );
  }

  CoachDecisionLifecycleProjection replay({
    required CoachDecisionContract decision,
    required List<CoachDecisionTransitionContract> transitions,
  }) {
    if (transitions.isEmpty) {
      throw ArgumentError('Coach Decision replay requires transitions.');
    }
    final ordered = [...transitions]
      ..sort((a, b) => a.sequence.compareTo(b.sequence));
    CoachDecisionLifecycleState? state;
    DateTime? lastOccurredAt;
    String? supersededByDecisionId;

    for (var index = 0; index < ordered.length; index++) {
      final transition = ordered[index];
      if (transition.sequence != index + 1) {
        throw ArgumentError(
          'Coach Decision transition sequences must be contiguous.',
        );
      }
      if (transition.decisionId != decision.id ||
          transition.decisionDigest != decision.digest) {
        throw ArgumentError('Coach Decision transition binding is invalid.');
      }
      if (transition.fromState != state) {
        throw ArgumentError(
            'Coach Decision transition starts from wrong state.');
      }
      if (lastOccurredAt != null &&
          transition.occurredAt.isBefore(lastOccurredAt)) {
        throw ArgumentError(
            'Coach Decision transitions are not chronological.');
      }
      _validateTransitionShape(transition);
      state = transition.toState;
      lastOccurredAt = transition.occurredAt;
      supersededByDecisionId = transition.supersedingDecisionId;
    }

    if (state == null) {
      throw StateError('Coach Decision replay did not produce a state.');
    }
    return CoachDecisionLifecycleProjection.create(
      decision: decision,
      state: state,
      transitions: ordered,
      supersededByDecisionId: supersededByDecisionId,
    );
  }

  CoachDecisionHistoryProjection projectHistory({
    required List<CoachDecisionContract> decisions,
    required List<CoachDecisionTransitionContract> transitions,
  }) {
    if (decisions.isEmpty) {
      throw ArgumentError('Coach Decision history requires decisions.');
    }
    final byId = <String, CoachDecisionContract>{};
    for (final decision in decisions) {
      if (byId.putIfAbsent(decision.id, () => decision) != decision) {
        throw ArgumentError('Coach Decision history contains duplicate IDs.');
      }
    }
    final grouped = <String, List<CoachDecisionTransitionContract>>{};
    for (final transition in transitions) {
      if (!byId.containsKey(transition.decisionId)) {
        throw ArgumentError('Transition references an unknown Coach Decision.');
      }
      grouped.putIfAbsent(transition.decisionId, () => []).add(transition);
    }
    final lifecycles = decisions
        .map(
          (decision) => replay(
            decision: decision,
            transitions: grouped[decision.id] ?? const [],
          ),
        )
        .toList(growable: false);
    for (final lifecycle in lifecycles) {
      final supersedingId = lifecycle.supersededByDecisionId;
      if (supersedingId == null) continue;
      final target = byId[supersedingId];
      final transition = lifecycle.transitions.last;
      if (target == null ||
          target.digest != transition.supersedingDecisionDigest) {
        throw ArgumentError(
          'Superseding Coach Decision is absent or has the wrong digest.',
        );
      }
    }
    return CoachDecisionHistoryProjection.create(lifecycles);
  }

  void _requireActive(
    CoachDecisionContract decision,
    CoachDecisionLifecycleProjection lifecycle,
  ) {
    if (lifecycle.decisionId != decision.id ||
        lifecycle.decisionDigest != decision.digest) {
      throw ArgumentError('Coach Decision lifecycle binding is invalid.');
    }
    if (lifecycle.state != CoachDecisionLifecycleState.active) {
      throw StateError('Only an active Coach Decision can transition.');
    }
  }

  void _validateTransitionShape(CoachDecisionTransitionContract transition) {
    switch (transition.kind) {
      case CoachDecisionTransitionKind.issued:
        if (transition.sequence != 1 ||
            transition.fromState != null ||
            transition.toState != CoachDecisionLifecycleState.active ||
            transition.supersedingDecisionId != null) {
          throw ArgumentError('Invalid issued Coach Decision transition.');
        }
      case CoachDecisionTransitionKind.completed:
        if (transition.fromState != CoachDecisionLifecycleState.active ||
            transition.toState != CoachDecisionLifecycleState.completed ||
            transition.supersedingDecisionId != null) {
          throw ArgumentError('Invalid completed Coach Decision transition.');
        }
      case CoachDecisionTransitionKind.superseded:
        if (transition.fromState != CoachDecisionLifecycleState.active ||
            transition.toState != CoachDecisionLifecycleState.superseded ||
            transition.supersedingDecisionId == null ||
            transition.supersedingDecisionDigest == null) {
          throw ArgumentError('Invalid superseded Coach Decision transition.');
        }
    }
  }
}
