import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/coach_decision_lifecycle_contracts.dart';

const coachPlanContractVersion = 1;
const coachPlannerPolicyVersion = 'coach-planner/1.0.0';

enum CoachPlanStepKind {
  continueActiveDecision,
  requestNextDecision,
}

class CoachPlanVersionBinding {
  const CoachPlanVersionBinding({
    required this.contextContractVersion,
    required this.contextDigest,
    required this.historyProjectionVersion,
    required this.historyDigest,
    required this.knowledgeVersion,
    required this.knowledgeDigest,
    required this.policyVersion,
  });

  final int contextContractVersion;
  final String contextDigest;
  final int historyProjectionVersion;
  final String historyDigest;
  final String knowledgeVersion;
  final String knowledgeDigest;
  final String policyVersion;

  Map<String, dynamic> toJson() => {
        'contextContractVersion': contextContractVersion,
        'contextDigest': contextDigest,
        'historyProjectionVersion': historyProjectionVersion,
        'historyDigest': historyDigest,
        'knowledgeVersion': knowledgeVersion,
        'knowledgeDigest': knowledgeDigest,
        'policyVersion': policyVersion,
      };
}

class CoachPlanContract {
  const CoachPlanContract._({
    required this.id,
    required this.step,
    required this.decisionId,
    required this.decisionDigest,
    required this.versions,
    required this.digest,
  });

  factory CoachPlanContract.create({
    required CoachContextContract context,
    required CoachDecisionHistoryProjection history,
    required CoachPlanStepKind step,
    required String? decisionId,
    required String? decisionDigest,
  }) {
    final activeIds = history.activeDecisionIds;
    switch (step) {
      case CoachPlanStepKind.continueActiveDecision:
        if (activeIds.length != 1 ||
            decisionId != activeIds.single ||
            decisionDigest != _activeDigest(history, activeIds.single)) {
          throw ArgumentError(
            'Continuing a Coach Decision requires exactly one active binding.',
          );
        }
      case CoachPlanStepKind.requestNextDecision:
        if (activeIds.isNotEmpty || decisionId != null || decisionDigest != null) {
          throw ArgumentError(
            'Requesting a Coach Decision requires no active binding.',
          );
        }
    }

    final versions = CoachPlanVersionBinding(
      contextContractVersion: coachContextContractVersion,
      contextDigest: context.digest,
      historyProjectionVersion: coachDecisionHistoryProjectionVersion,
      historyDigest: history.digest,
      knowledgeVersion: context.versions.knowledgeVersion,
      knowledgeDigest: context.versions.knowledgeDigest,
      policyVersion: coachPlannerPolicyVersion,
    );
    final payload = {
      'schemaVersion': coachPlanContractVersion,
      'step': step.name,
      if (decisionId != null) 'decisionId': decisionId,
      if (decisionDigest != null) 'decisionDigest': decisionDigest,
      'versions': versions.toJson(),
    };
    final digest = _digest(payload);
    return CoachPlanContract._(
      id: 'coach-plan.${digest.substring(0, 16)}',
      step: step,
      decisionId: decisionId,
      decisionDigest: decisionDigest,
      versions: versions,
      digest: digest,
    );
  }

  final String id;
  final CoachPlanStepKind step;
  final String? decisionId;
  final String? decisionDigest;
  final CoachPlanVersionBinding versions;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': coachPlanContractVersion,
        'id': id,
        'step': step.name,
        if (decisionId != null) 'decisionId': decisionId,
        if (decisionDigest != null) 'decisionDigest': decisionDigest,
        'versions': versions.toJson(),
        'digest': digest,
      };
}

String _activeDigest(
  CoachDecisionHistoryProjection history,
  String decisionId,
) =>
    history.decisions
        .singleWhere((item) => item.decisionId == decisionId)
        .decisionDigest;

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
