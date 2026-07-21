import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/coach_decision_contracts.dart';

const coachDecisionTransitionContractVersion = 1;
const coachDecisionLifecycleProjectionVersion = 1;
const coachDecisionHistoryProjectionVersion = 1;

enum CoachDecisionLifecycleState {
  active,
  completed,
  superseded,
}

enum CoachDecisionTransitionKind {
  issued,
  completed,
  superseded,
}

class CoachDecisionTransitionContract {
  const CoachDecisionTransitionContract._({
    required this.id,
    required this.sequence,
    required this.decisionId,
    required this.decisionDigest,
    required this.kind,
    required this.fromState,
    required this.toState,
    required this.occurredAt,
    required this.supersedingDecisionId,
    required this.supersedingDecisionDigest,
    required this.digest,
  });

  factory CoachDecisionTransitionContract.issued(
    CoachDecisionContract decision,
  ) =>
      CoachDecisionTransitionContract._create(
        sequence: 1,
        decision: decision,
        kind: CoachDecisionTransitionKind.issued,
        fromState: null,
        toState: CoachDecisionLifecycleState.active,
        occurredAt: decision.effectiveAt,
      );

  factory CoachDecisionTransitionContract.completed({
    required int sequence,
    required CoachDecisionContract decision,
    required DateTime occurredAt,
  }) =>
      CoachDecisionTransitionContract._create(
        sequence: sequence,
        decision: decision,
        kind: CoachDecisionTransitionKind.completed,
        fromState: CoachDecisionLifecycleState.active,
        toState: CoachDecisionLifecycleState.completed,
        occurredAt: occurredAt,
      );

  factory CoachDecisionTransitionContract.superseded({
    required int sequence,
    required CoachDecisionContract decision,
    required CoachDecisionContract supersedingDecision,
  }) {
    if (decision.id == supersedingDecision.id) {
      throw ArgumentError('A Coach Decision cannot supersede itself.');
    }
    if (!supersedingDecision.effectiveAt.isAfter(decision.effectiveAt)) {
      throw ArgumentError(
        'A superseding Coach Decision must be newer than the original.',
      );
    }
    return CoachDecisionTransitionContract._create(
      sequence: sequence,
      decision: decision,
      kind: CoachDecisionTransitionKind.superseded,
      fromState: CoachDecisionLifecycleState.active,
      toState: CoachDecisionLifecycleState.superseded,
      occurredAt: supersedingDecision.effectiveAt,
      supersedingDecision: supersedingDecision,
    );
  }

  factory CoachDecisionTransitionContract._create({
    required int sequence,
    required CoachDecisionContract decision,
    required CoachDecisionTransitionKind kind,
    required CoachDecisionLifecycleState? fromState,
    required CoachDecisionLifecycleState toState,
    required DateTime occurredAt,
    CoachDecisionContract? supersedingDecision,
  }) {
    if (sequence < 1) {
      throw ArgumentError(
          'Coach Decision transition sequence must be positive.');
    }
    final normalizedTime = occurredAt.toUtc();
    if (normalizedTime.isBefore(decision.effectiveAt)) {
      throw ArgumentError(
        'Coach Decision transition cannot predate the decision.',
      );
    }
    final payload = {
      'schemaVersion': coachDecisionTransitionContractVersion,
      'sequence': sequence,
      'decisionId': decision.id,
      'decisionDigest': decision.digest,
      'kind': kind.name,
      if (fromState != null) 'fromState': fromState.name,
      'toState': toState.name,
      'occurredAt': normalizedTime.toIso8601String(),
      if (supersedingDecision != null) ...{
        'supersedingDecisionId': supersedingDecision.id,
        'supersedingDecisionDigest': supersedingDecision.digest,
      },
    };
    final digest = _digest(payload);
    return CoachDecisionTransitionContract._(
      id: 'coach-transition.${digest.substring(0, 16)}',
      sequence: sequence,
      decisionId: decision.id,
      decisionDigest: decision.digest,
      kind: kind,
      fromState: fromState,
      toState: toState,
      occurredAt: normalizedTime,
      supersedingDecisionId: supersedingDecision?.id,
      supersedingDecisionDigest: supersedingDecision?.digest,
      digest: digest,
    );
  }

  final String id;
  final int sequence;
  final String decisionId;
  final String decisionDigest;
  final CoachDecisionTransitionKind kind;
  final CoachDecisionLifecycleState? fromState;
  final CoachDecisionLifecycleState toState;
  final DateTime occurredAt;
  final String? supersedingDecisionId;
  final String? supersedingDecisionDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': coachDecisionTransitionContractVersion,
        'id': id,
        'sequence': sequence,
        'decisionId': decisionId,
        'decisionDigest': decisionDigest,
        'kind': kind.name,
        if (fromState != null) 'fromState': fromState!.name,
        'toState': toState.name,
        'occurredAt': occurredAt.toIso8601String(),
        if (supersedingDecisionId != null) ...{
          'supersedingDecisionId': supersedingDecisionId,
          'supersedingDecisionDigest': supersedingDecisionDigest,
        },
        'digest': digest,
      };
}

class CoachDecisionLifecycleProjection {
  const CoachDecisionLifecycleProjection._({
    required this.decisionId,
    required this.decisionDigest,
    required this.state,
    required this.transitions,
    required this.supersededByDecisionId,
    required this.digest,
  });

  factory CoachDecisionLifecycleProjection.create({
    required CoachDecisionContract decision,
    required CoachDecisionLifecycleState state,
    required List<CoachDecisionTransitionContract> transitions,
    required String? supersededByDecisionId,
  }) {
    if (transitions.isEmpty) {
      throw ArgumentError('Coach Decision lifecycle requires transitions.');
    }
    final ordered = List<CoachDecisionTransitionContract>.unmodifiable(
      [...transitions]..sort((a, b) => a.sequence.compareTo(b.sequence)),
    );
    for (var index = 0; index < ordered.length; index++) {
      final transition = ordered[index];
      if (transition.sequence != index + 1 ||
          transition.decisionId != decision.id ||
          transition.decisionDigest != decision.digest) {
        throw ArgumentError(
          'Coach Decision lifecycle transition binding is invalid.',
        );
      }
    }
    final terminal = ordered.last;
    if (state != CoachDecisionLifecycleState.active &&
        ordered.first.kind != CoachDecisionTransitionKind.issued) {
      throw ArgumentError(
        'A terminal Coach Decision lifecycle requires an issued transition.',
      );
    }
    if (terminal.toState != state ||
        terminal.supersedingDecisionId != supersededByDecisionId ||
        (state == CoachDecisionLifecycleState.superseded) !=
            (supersededByDecisionId != null)) {
      throw ArgumentError('Coach Decision lifecycle state is inconsistent.');
    }
    final payload = {
      'schemaVersion': coachDecisionLifecycleProjectionVersion,
      'decisionId': decision.id,
      'decisionDigest': decision.digest,
      'state': state.name,
      'transitions': ordered.map((item) => item.toJson()).toList(),
      if (supersededByDecisionId != null)
        'supersededByDecisionId': supersededByDecisionId,
    };
    return CoachDecisionLifecycleProjection._(
      decisionId: decision.id,
      decisionDigest: decision.digest,
      state: state,
      transitions: ordered,
      supersededByDecisionId: supersededByDecisionId,
      digest: _digest(payload),
    );
  }

  final String decisionId;
  final String decisionDigest;
  final CoachDecisionLifecycleState state;
  final List<CoachDecisionTransitionContract> transitions;
  final String? supersededByDecisionId;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': coachDecisionLifecycleProjectionVersion,
        'decisionId': decisionId,
        'decisionDigest': decisionDigest,
        'state': state.name,
        'transitions': transitions.map((item) => item.toJson()).toList(),
        if (supersededByDecisionId != null)
          'supersededByDecisionId': supersededByDecisionId,
        'digest': digest,
      };
}

class CoachDecisionHistoryProjection {
  const CoachDecisionHistoryProjection._({
    required this.decisions,
    required this.activeDecisionIds,
    required this.digest,
  });

  factory CoachDecisionHistoryProjection.create(
    List<CoachDecisionLifecycleProjection> decisions,
  ) {
    if (decisions.isEmpty) {
      throw ArgumentError('Coach Decision history must not be empty.');
    }
    final ordered = List<CoachDecisionLifecycleProjection>.unmodifiable(
      [...decisions]..sort((a, b) {
          final byIssuedAt = a.transitions.first.occurredAt.compareTo(
            b.transitions.first.occurredAt,
          );
          return byIssuedAt != 0
              ? byIssuedAt
              : a.decisionId.compareTo(b.decisionId);
        }),
    );
    if (ordered.map((item) => item.decisionId).toSet().length !=
        ordered.length) {
      throw ArgumentError(
          'Coach Decision history contains duplicate decisions.');
    }
    final activeIds = List<String>.unmodifiable(
      ordered
          .where((item) => item.state == CoachDecisionLifecycleState.active)
          .map((item) => item.decisionId),
    );
    final payload = {
      'schemaVersion': coachDecisionHistoryProjectionVersion,
      'decisions': ordered.map((item) => item.toJson()).toList(),
      'activeDecisionIds': activeIds,
    };
    return CoachDecisionHistoryProjection._(
      decisions: ordered,
      activeDecisionIds: activeIds,
      digest: _digest(payload),
    );
  }

  final List<CoachDecisionLifecycleProjection> decisions;
  final List<String> activeDecisionIds;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': coachDecisionHistoryProjectionVersion,
        'decisions': decisions.map((item) => item.toJson()).toList(),
        'activeDecisionIds': activeDecisionIds,
        'digest': digest,
      };
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
