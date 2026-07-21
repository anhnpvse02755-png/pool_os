import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/coach_recommendation_contracts.dart';

const coachExecutionTransitionContractVersion = 1;
const coachExecutionRecordContractVersion = 1;
const coachExecutionPolicyVersion = 'coach-execution/1.0.0';

enum CoachExecutionState {
  accepted,
  rejected,
  deferred,
  expired,
  completed,
}

class CoachExecutionTransitionContract {
  const CoachExecutionTransitionContract._({
    required this.id,
    required this.sequence,
    required this.recommendationId,
    required this.recommendationDigest,
    required this.kind,
    required this.fromState,
    required this.toState,
    required this.occurredAt,
    required this.digest,
  });

  factory CoachExecutionTransitionContract.accepted({
    required CoachRecommendationContract recommendation,
    required DateTime occurredAt,
  }) =>
      CoachExecutionTransitionContract._create(
        sequence: 1,
        recommendation: recommendation,
        fromState: null,
        toState: CoachExecutionState.accepted,
        occurredAt: occurredAt,
      );

  factory CoachExecutionTransitionContract.rejected({
    required CoachRecommendationContract recommendation,
    required DateTime occurredAt,
  }) =>
      CoachExecutionTransitionContract._create(
        sequence: 1,
        recommendation: recommendation,
        fromState: null,
        toState: CoachExecutionState.rejected,
        occurredAt: occurredAt,
      );

  factory CoachExecutionTransitionContract.deferred({
    required CoachRecommendationContract recommendation,
    required DateTime occurredAt,
  }) =>
      CoachExecutionTransitionContract._create(
        sequence: 1,
        recommendation: recommendation,
        fromState: null,
        toState: CoachExecutionState.deferred,
        occurredAt: occurredAt,
      );

  factory CoachExecutionTransitionContract.expired({
    required CoachRecommendationContract recommendation,
    required DateTime occurredAt,
  }) =>
      CoachExecutionTransitionContract._create(
        sequence: 1,
        recommendation: recommendation,
        fromState: null,
        toState: CoachExecutionState.expired,
        occurredAt: occurredAt,
      );

  factory CoachExecutionTransitionContract.completed({
    required int sequence,
    required CoachRecommendationContract recommendation,
    required DateTime occurredAt,
  }) =>
      CoachExecutionTransitionContract._create(
        sequence: sequence,
        recommendation: recommendation,
        fromState: CoachExecutionState.accepted,
        toState: CoachExecutionState.completed,
        occurredAt: occurredAt,
      );

  factory CoachExecutionTransitionContract._create({
    required int sequence,
    required CoachRecommendationContract recommendation,
    required CoachExecutionState? fromState,
    required CoachExecutionState toState,
    required DateTime occurredAt,
  }) {
    if (sequence < 1) {
      throw ArgumentError(
          'Coach Execution transition sequence must be positive.');
    }
    final normalizedTime = occurredAt.toUtc();
    final payload = {
      'schemaVersion': coachExecutionTransitionContractVersion,
      'sequence': sequence,
      'recommendationId': recommendation.id,
      'recommendationDigest': recommendation.digest,
      if (fromState != null) 'fromState': fromState.name,
      'toState': toState.name,
      'occurredAt': normalizedTime.toIso8601String(),
    };
    final digest = _digest(payload);
    return CoachExecutionTransitionContract._(
      id: 'coach-execution-transition.${digest.substring(0, 16)}',
      sequence: sequence,
      recommendationId: recommendation.id,
      recommendationDigest: recommendation.digest,
      kind: toState,
      fromState: fromState,
      toState: toState,
      occurredAt: normalizedTime,
      digest: digest,
    );
  }

  final String id;
  final int sequence;
  final String recommendationId;
  final String recommendationDigest;
  final CoachExecutionState kind;
  final CoachExecutionState? fromState;
  final CoachExecutionState toState;
  final DateTime occurredAt;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': coachExecutionTransitionContractVersion,
        'id': id,
        'sequence': sequence,
        'recommendationId': recommendationId,
        'recommendationDigest': recommendationDigest,
        'kind': kind.name,
        if (fromState != null) 'fromState': fromState!.name,
        'toState': toState.name,
        'occurredAt': occurredAt.toIso8601String(),
        'digest': digest,
      };
}

class CoachExecutionRecordContract {
  const CoachExecutionRecordContract._({
    required this.id,
    required this.recommendationId,
    required this.recommendationDigest,
    required this.state,
    required this.transitions,
    required this.versions,
    required this.digest,
  });

  factory CoachExecutionRecordContract.create({
    required CoachRecommendationContract recommendation,
    required CoachExecutionState state,
    required List<CoachExecutionTransitionContract> transitions,
  }) {
    if (transitions.isEmpty) {
      throw ArgumentError('Coach Execution requires transitions.');
    }
    final ordered = [...transitions]
      ..sort((a, b) => a.sequence.compareTo(b.sequence));
    CoachExecutionState? replayed;
    DateTime? previousTime;
    for (var index = 0; index < ordered.length; index++) {
      final transition = ordered[index];
      if (transition.sequence != index + 1 ||
          transition.recommendationId != recommendation.id ||
          transition.recommendationDigest != recommendation.digest ||
          transition.fromState != replayed ||
          (previousTime != null &&
              transition.occurredAt.isBefore(previousTime))) {
        throw ArgumentError('Coach Execution transition binding is invalid.');
      }
      _validateShape(transition);
      replayed = transition.toState;
      previousTime = transition.occurredAt;
    }
    if (replayed != state) {
      throw ArgumentError('Coach Execution state does not match transitions.');
    }
    final versions = CoachExecutionVersionBinding(
      recommendationContractVersion: coachRecommendationContractVersion,
      recommendationId: recommendation.id,
      recommendationDigest: recommendation.digest,
      policyVersion: coachExecutionPolicyVersion,
    );
    final payload = {
      'schemaVersion': coachExecutionRecordContractVersion,
      'recommendationId': recommendation.id,
      'recommendationDigest': recommendation.digest,
      'state': state.name,
      'transitions': ordered.map((item) => item.toJson()).toList(),
      'versions': versions.toJson(),
    };
    final digest = _digest(payload);
    return CoachExecutionRecordContract._(
      id: 'coach-execution.${digest.substring(0, 16)}',
      recommendationId: recommendation.id,
      recommendationDigest: recommendation.digest,
      state: state,
      transitions: List.unmodifiable(ordered),
      versions: versions,
      digest: digest,
    );
  }

  final String id;
  final String recommendationId;
  final String recommendationDigest;
  final CoachExecutionState state;
  final List<CoachExecutionTransitionContract> transitions;
  final CoachExecutionVersionBinding versions;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': coachExecutionRecordContractVersion,
        'id': id,
        'recommendationId': recommendationId,
        'recommendationDigest': recommendationDigest,
        'state': state.name,
        'transitions': transitions.map((item) => item.toJson()).toList(),
        'versions': versions.toJson(),
        'digest': digest,
      };
}

class CoachExecutionVersionBinding {
  const CoachExecutionVersionBinding({
    required this.recommendationContractVersion,
    required this.recommendationId,
    required this.recommendationDigest,
    required this.policyVersion,
  });

  final int recommendationContractVersion;
  final String recommendationId;
  final String recommendationDigest;
  final String policyVersion;

  Map<String, dynamic> toJson() => {
        'recommendationContractVersion': recommendationContractVersion,
        'recommendationId': recommendationId,
        'recommendationDigest': recommendationDigest,
        'policyVersion': policyVersion,
      };
}

void _validateShape(CoachExecutionTransitionContract transition) {
  if (transition.sequence == 1) {
    if (transition.kind == CoachExecutionState.completed ||
        transition.fromState != null) {
      throw ArgumentError('Coach Execution initial transition is invalid.');
    }
    return;
  }
  if (transition.sequence != 2 ||
      transition.fromState != CoachExecutionState.accepted ||
      transition.toState != CoachExecutionState.completed) {
    throw ArgumentError('Coach Execution terminal transition is invalid.');
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
