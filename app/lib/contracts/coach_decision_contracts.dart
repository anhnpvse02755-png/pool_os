import 'dart:convert';

import 'package:crypto/crypto.dart';

const coachDecisionContractVersion = 1;
const coachDecisionPolicyVersion = 'coach-decision/1.0.0';

enum CoachDecisionAction {
  correctMistake,
  practiceTechnique,
  readyForNextCapability,
}

enum CoachDecisionReasonCode {
  persistentMistakeRequiresCorrection,
  masteryBelowThreshold,
  allTrackedCapabilitiesMastered,
}

enum CoachDecisionTraceStage {
  contextValidation,
  candidateCollection,
  selection,
  decision,
}

enum CoachDecisionAlternativeReason {
  correctionPriority,
  lowerCanonicalPriority,
}

class CoachDecisionReason {
  const CoachDecisionReason({
    required this.code,
    this.knowledgeId,
    this.observedState,
  });

  final CoachDecisionReasonCode code;
  final String? knowledgeId;
  final String? observedState;

  Map<String, dynamic> toJson() => {
        'code': code.name,
        if (knowledgeId != null) 'knowledgeId': knowledgeId,
        if (observedState != null) 'observedState': observedState,
      };
}

class CoachDecisionTraceStep {
  const CoachDecisionTraceStep({
    required this.sequence,
    required this.stage,
    required this.outcomeCode,
    this.knowledgeId,
  });

  final int sequence;
  final CoachDecisionTraceStage stage;
  final String outcomeCode;
  final String? knowledgeId;

  Map<String, dynamic> toJson() => {
        'sequence': sequence,
        'stage': stage.name,
        'outcomeCode': outcomeCode,
        if (knowledgeId != null) 'knowledgeId': knowledgeId,
      };
}

class CoachDecisionAlternative {
  const CoachDecisionAlternative({
    required this.action,
    required this.knowledgeId,
    required this.reason,
  });

  final CoachDecisionAction action;
  final String knowledgeId;
  final CoachDecisionAlternativeReason reason;

  Map<String, dynamic> toJson() => {
        'action': action.name,
        'knowledgeId': knowledgeId,
        'reason': reason.name,
      };
}

class CoachDecisionVersionBinding {
  const CoachDecisionVersionBinding({
    required this.contextContractVersion,
    required this.contextDigest,
    required this.knowledgeVersion,
    required this.knowledgeDigest,
    required this.policyVersion,
  });

  final int contextContractVersion;
  final String contextDigest;
  final String knowledgeVersion;
  final String knowledgeDigest;
  final String policyVersion;

  Map<String, dynamic> toJson() => {
        'contextContractVersion': contextContractVersion,
        'contextDigest': contextDigest,
        'knowledgeVersion': knowledgeVersion,
        'knowledgeDigest': knowledgeDigest,
        'policyVersion': policyVersion,
      };
}

class CoachDecisionContract {
  const CoachDecisionContract._({
    required this.id,
    required this.effectiveAt,
    required this.action,
    required this.targetKnowledgeId,
    required this.reasons,
    required this.trace,
    required this.alternatives,
    required this.versions,
    required this.digest,
  });

  factory CoachDecisionContract.create({
    required DateTime effectiveAt,
    required CoachDecisionAction action,
    required String? targetKnowledgeId,
    required List<CoachDecisionReason> reasons,
    required List<CoachDecisionTraceStep> trace,
    required List<CoachDecisionAlternative> alternatives,
    required CoachDecisionVersionBinding versions,
  }) {
    if (reasons.isEmpty || trace.isEmpty) {
      throw ArgumentError('Coach Decision requires reasons and trace.');
    }
    if (action == CoachDecisionAction.readyForNextCapability &&
        targetKnowledgeId != null) {
      throw ArgumentError('Readiness decision must not invent a next target.');
    }
    if (action != CoachDecisionAction.readyForNextCapability &&
        (targetKnowledgeId == null || targetKnowledgeId.trim().isEmpty)) {
      throw ArgumentError('Actionable Coach Decision requires a target.');
    }
    final orderedTrace = [...trace]
      ..sort((a, b) => a.sequence.compareTo(b.sequence));
    for (var index = 0; index < orderedTrace.length; index++) {
      if (orderedTrace[index].sequence != index + 1) {
        throw ArgumentError('Coach Decision trace must be contiguous.');
      }
    }
    final orderedAlternatives = [...alternatives]..sort((a, b) {
        final byAction = a.action.name.compareTo(b.action.name);
        return byAction != 0
            ? byAction
            : a.knowledgeId.compareTo(b.knowledgeId);
      });
    final payload = {
      'schemaVersion': coachDecisionContractVersion,
      'effectiveAt': effectiveAt.toUtc().toIso8601String(),
      'action': action.name,
      if (targetKnowledgeId != null) 'targetKnowledgeId': targetKnowledgeId,
      'reasons': reasons.map((reason) => reason.toJson()).toList(),
      'trace': orderedTrace.map((step) => step.toJson()).toList(),
      'alternatives': orderedAlternatives.map((item) => item.toJson()).toList(),
      'versions': versions.toJson(),
    };
    final digest = _digest(payload);
    return CoachDecisionContract._(
      id: 'coach-decision.${digest.substring(0, 16)}',
      effectiveAt: effectiveAt.toUtc(),
      action: action,
      targetKnowledgeId: targetKnowledgeId,
      reasons: List.unmodifiable(reasons),
      trace: List.unmodifiable(orderedTrace),
      alternatives: List.unmodifiable(orderedAlternatives),
      versions: versions,
      digest: digest,
    );
  }

  final String id;
  final DateTime effectiveAt;
  final CoachDecisionAction action;
  final String? targetKnowledgeId;
  final List<CoachDecisionReason> reasons;
  final List<CoachDecisionTraceStep> trace;
  final List<CoachDecisionAlternative> alternatives;
  final CoachDecisionVersionBinding versions;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': coachDecisionContractVersion,
        'id': id,
        'effectiveAt': effectiveAt.toIso8601String(),
        'action': action.name,
        if (targetKnowledgeId != null) 'targetKnowledgeId': targetKnowledgeId,
        'reasons': reasons.map((reason) => reason.toJson()).toList(),
        'trace': trace.map((step) => step.toJson()).toList(),
        'alternatives': alternatives.map((item) => item.toJson()).toList(),
        'versions': versions.toJson(),
        'digest': digest,
      };
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
