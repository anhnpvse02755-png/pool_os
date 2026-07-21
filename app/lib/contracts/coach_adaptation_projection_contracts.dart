import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/training_outcome_projection_contracts.dart';

const coachAdaptationProjectionContractVersion = 1;
const coachAdaptationItemContractVersion = 1;
const coachAdaptationPolicyVersion = 'coach-adaptation/1.0.0';

enum CoachAdaptationAction { continueAction, repeat, escalate, stop }

CoachAdaptationAction coachAdaptationActionFor(TrainingOutcomeKind outcome) =>
    switch (outcome) {
      TrainingOutcomeKind.completed ||
      TrainingOutcomeKind.pending =>
        CoachAdaptationAction.continueAction,
      TrainingOutcomeKind.deferred => CoachAdaptationAction.repeat,
      TrainingOutcomeKind.rejected => CoachAdaptationAction.escalate,
      TrainingOutcomeKind.expired => CoachAdaptationAction.stop,
    };

extension CoachAdaptationActionJson on CoachAdaptationAction {
  String get wireName => switch (this) {
        CoachAdaptationAction.continueAction => 'continue',
        CoachAdaptationAction.repeat => 'repeat',
        CoachAdaptationAction.escalate => 'escalate',
        CoachAdaptationAction.stop => 'stop',
      };
}

class CoachAdaptationItemContract {
  const CoachAdaptationItemContract({
    required this.position,
    required this.recommendationId,
    required this.outcome,
    required this.action,
  });

  final int position;
  final String recommendationId;
  final TrainingOutcomeKind outcome;
  final CoachAdaptationAction action;

  Map<String, dynamic> toJson() => {
        'schemaVersion': coachAdaptationItemContractVersion,
        'position': position,
        'recommendationId': recommendationId,
        'outcome': outcome.name,
        'action': action.wireName,
      };
}

class CoachAdaptationSummaryContract {
  const CoachAdaptationSummaryContract({
    required this.total,
    required this.continueCount,
    required this.repeatCount,
    required this.escalateCount,
    required this.stopCount,
  });

  final int total;
  final int continueCount;
  final int repeatCount;
  final int escalateCount;
  final int stopCount;

  Map<String, dynamic> toJson() => {
        'total': total,
        'continue': continueCount,
        'repeat': repeatCount,
        'escalate': escalateCount,
        'stop': stopCount,
      };
}

class CoachAdaptationProjectionContract {
  const CoachAdaptationProjectionContract._({
    required this.id,
    required this.playerId,
    required this.sessionId,
    required this.outcomeProjectionDigest,
    required this.sessionDigest,
    required this.contextDigest,
    required this.items,
    required this.summary,
    required this.digest,
  });

  factory CoachAdaptationProjectionContract.create({
    required CoachContextContract context,
    required TrainingOutcomeProjectionContract outcomeProjection,
    required List<CoachAdaptationItemContract> items,
  }) {
    if (outcomeProjection.playerId != context.profile.playerId ||
        outcomeProjection.sessionId.trim().isEmpty ||
        outcomeProjection.sessionDigest.trim().isEmpty ||
        outcomeProjection.digest.trim().isEmpty ||
        items.length != outcomeProjection.items.length) {
      throw ArgumentError('Coach Adaptation inputs are stale or invalid.');
    }
    final seen = <String>{};
    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      final source = outcomeProjection.items[index];
      if (item.position != index + 1 ||
          item.recommendationId != source.recommendationId ||
          item.outcome != source.kind ||
          item.action != coachAdaptationActionFor(source.kind) ||
          !seen.add(item.recommendationId)) {
        throw ArgumentError('Coach Adaptation item provenance is invalid.');
      }
    }
    final summary = CoachAdaptationSummaryContract(
      total: items.length,
      continueCount: items
          .where((item) => item.action == CoachAdaptationAction.continueAction)
          .length,
      repeatCount: items
          .where((item) => item.action == CoachAdaptationAction.repeat)
          .length,
      escalateCount: items
          .where((item) => item.action == CoachAdaptationAction.escalate)
          .length,
      stopCount: items
          .where((item) => item.action == CoachAdaptationAction.stop)
          .length,
    );
    final payload = {
      'schemaVersion': coachAdaptationProjectionContractVersion,
      'playerId': context.profile.playerId,
      'sessionId': outcomeProjection.sessionId,
      'outcomeProjectionDigest': outcomeProjection.digest,
      'sessionDigest': outcomeProjection.sessionDigest,
      'contextDigest': context.digest,
      'items': items.map((item) => item.toJson()).toList(),
      'summary': summary.toJson(),
      'policyVersion': coachAdaptationPolicyVersion,
    };
    final digest = _digest(payload);
    return CoachAdaptationProjectionContract._(
      id: 'coach-adaptation.${digest.substring(0, 16)}',
      playerId: context.profile.playerId,
      sessionId: outcomeProjection.sessionId,
      outcomeProjectionDigest: outcomeProjection.digest,
      sessionDigest: outcomeProjection.sessionDigest,
      contextDigest: context.digest,
      items: List.unmodifiable(items),
      summary: summary,
      digest: digest,
    );
  }

  final String id;
  final String playerId;
  final String sessionId;
  final String outcomeProjectionDigest;
  final String sessionDigest;
  final String contextDigest;
  final List<CoachAdaptationItemContract> items;
  final CoachAdaptationSummaryContract summary;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': coachAdaptationProjectionContractVersion,
        'id': id,
        'playerId': playerId,
        'sessionId': sessionId,
        'outcomeProjectionDigest': outcomeProjectionDigest,
        'sessionDigest': sessionDigest,
        'contextDigest': contextDigest,
        'items': items.map((item) => item.toJson()).toList(),
        'summary': summary.toJson(),
        'policyVersion': coachAdaptationPolicyVersion,
        'digest': digest,
      };
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
