import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/coach_context_contracts.dart';

const orderedRecommendationViewContractVersion = 1;
const recommendationPriorityItemContractVersion = 1;
const adaptiveRecommendationPolicyVersion = 'adaptive-recommendation/1.0.0';

enum RecommendationPriorityBand {
  continueAcceptedExecution,
  retryDeferredExecution,
  correctPersistentMistake,
  continueRecentExperience,
  practiceUnmasteredTechnique,
  pendingRecommendation,
  terminalExecution,
}

enum RecommendationPriorityReason {
  acceptedExecutionMustContinue,
  deferredExecutionMayResume,
  persistentMistakeNeedsCorrection,
  targetAppearsInExperience,
  targetIsNotMastered,
  noExecutionRecorded,
  executionIsTerminal,
  canonicalIdTieBreak,
}

class RecommendationPriorityItemContract {
  const RecommendationPriorityItemContract({
    required this.position,
    required this.recommendationId,
    required this.recommendationDigest,
    required this.band,
    required this.reasons,
    required this.executionId,
    required this.executionDigest,
  });

  final int position;
  final String recommendationId;
  final String recommendationDigest;
  final RecommendationPriorityBand band;
  final List<RecommendationPriorityReason> reasons;
  final String? executionId;
  final String? executionDigest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': recommendationPriorityItemContractVersion,
        'position': position,
        'recommendationId': recommendationId,
        'recommendationDigest': recommendationDigest,
        'band': band.name,
        'reasons': reasons.map((item) => item.name).toList(),
        if (executionId != null) 'executionId': executionId,
        if (executionDigest != null) 'executionDigest': executionDigest,
      };
}

class OrderedRecommendationViewContract {
  const OrderedRecommendationViewContract._({
    required this.id,
    required this.playerId,
    required this.items,
    required this.contextDigest,
    required this.policyVersion,
    required this.digest,
  });

  factory OrderedRecommendationViewContract.create({
    required CoachContextContract context,
    required List<RecommendationPriorityItemContract> items,
  }) {
    if (items.isEmpty) {
      throw ArgumentError('Ordered Recommendation View requires items.');
    }
    final recommendationIds = <String>{};
    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      if (item.position != index + 1 ||
          item.recommendationId.trim().isEmpty ||
          item.recommendationDigest.trim().isEmpty ||
          item.reasons.isEmpty ||
          !recommendationIds.add(item.recommendationId) ||
          ((item.executionId == null) != (item.executionDigest == null))) {
        throw ArgumentError('Ordered Recommendation item is invalid.');
      }
    }
    final payload = {
      'schemaVersion': orderedRecommendationViewContractVersion,
      'playerId': context.profile.playerId,
      'items': items.map((item) => item.toJson()).toList(),
      'contextDigest': context.digest,
      'policyVersion': adaptiveRecommendationPolicyVersion,
    };
    final digest = _digest(payload);
    return OrderedRecommendationViewContract._(
      id: 'ordered-recommendations.${digest.substring(0, 16)}',
      playerId: context.profile.playerId,
      items: List.unmodifiable(items),
      contextDigest: context.digest,
      policyVersion: adaptiveRecommendationPolicyVersion,
      digest: digest,
    );
  }

  final String id;
  final String playerId;
  final List<RecommendationPriorityItemContract> items;
  final String contextDigest;
  final String policyVersion;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': orderedRecommendationViewContractVersion,
        'id': id,
        'playerId': playerId,
        'items': items.map((item) => item.toJson()).toList(),
        'contextDigest': contextDigest,
        'policyVersion': policyVersion,
        'digest': digest,
      };
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
