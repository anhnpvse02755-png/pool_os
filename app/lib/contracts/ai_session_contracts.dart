import 'dart:convert';

import 'package:crypto/crypto.dart';

const aiSessionContractVersion = 1;
const minimumAIContractVersion = 'ai-session/1.0.0';

const Map<String, int> requiredAISessionRuntimeContracts = {
  'coachContext': 2,
  'coachPlan': 1,
  'coachRecommendation': 1,
  'coachExecutionRecord': 1,
};

class AISessionProvenance {
  const AISessionProvenance({
    required this.knowledgeVersion,
    required this.knowledgeDigest,
    required this.contextDigest,
    required this.planDigest,
    required this.recommendationDigest,
    required this.executionDigest,
  });

  final String knowledgeVersion;
  final String knowledgeDigest;
  final String contextDigest;
  final String planDigest;
  final String recommendationDigest;
  final String executionDigest;

  Map<String, dynamic> toJson() => {
        'knowledgeVersion': knowledgeVersion,
        'knowledgeDigest': knowledgeDigest,
        'contextDigest': contextDigest,
        'planDigest': planDigest,
        'recommendationDigest': recommendationDigest,
        'executionDigest': executionDigest,
      };
}

class AISessionContract {
  const AISessionContract._({
    required this.id,
    required this.knowledgeVersion,
    required this.knowledgeDigest,
    required this.contextDigest,
    required this.planDigest,
    required this.recommendationDigest,
    required this.executionDigest,
    required this.provenance,
    required this.requiredRuntimeContracts,
    required this.minimumAIContractVersion,
    required this.contextId,
    required this.planId,
    required this.recommendationId,
    required this.executionId,
    required this.digest,
  });

  factory AISessionContract.create({
    required String contextId,
    required String planId,
    required String recommendationId,
    required String executionId,
    required String knowledgeVersion,
    required String knowledgeDigest,
    required String contextDigest,
    required String planDigest,
    required String recommendationDigest,
    required String executionDigest,
    required AISessionProvenance provenance,
    required Map<String, int> requiredRuntimeContracts,
    required String minimumAIContractVersion,
  }) {
    final values = {
      'contextId': contextId,
      'planId': planId,
      'recommendationId': recommendationId,
      'executionId': executionId,
      'knowledgeVersion': knowledgeVersion,
      'knowledgeDigest': knowledgeDigest,
      'contextDigest': contextDigest,
      'planDigest': planDigest,
      'recommendationDigest': recommendationDigest,
      'executionDigest': executionDigest,
      'minimumAIContractVersion': minimumAIContractVersion,
    };
    for (final entry in values.entries) {
      if (entry.value.trim().isEmpty) {
        throw ArgumentError('${entry.key} must not be empty.');
      }
    }
    if ({contextId, planId, recommendationId, executionId}.length != 4) {
      throw ArgumentError('AISession contains duplicate semantic objects.');
    }
    if (requiredRuntimeContracts.isEmpty ||
        requiredRuntimeContracts.values.any((version) => version < 1)) {
      throw ArgumentError('AISession runtime contracts are invalid.');
    }
    if (provenance.knowledgeVersion != knowledgeVersion ||
        provenance.knowledgeDigest != knowledgeDigest ||
        provenance.contextDigest != contextDigest ||
        provenance.planDigest != planDigest ||
        provenance.recommendationDigest != recommendationDigest ||
        provenance.executionDigest != executionDigest) {
      throw ArgumentError('AISession provenance does not match its inputs.');
    }
    final orderedContracts = <String, int>{
      for (final key in requiredRuntimeContracts.keys.toList()..sort())
        key: requiredRuntimeContracts[key]!,
    };
    final payload = {
      'schemaVersion': aiSessionContractVersion,
      'contextId': contextId,
      'planId': planId,
      'recommendationId': recommendationId,
      'executionId': executionId,
      'knowledgeVersion': knowledgeVersion,
      'knowledgeDigest': knowledgeDigest,
      'contextDigest': contextDigest,
      'planDigest': planDigest,
      'recommendationDigest': recommendationDigest,
      'executionDigest': executionDigest,
      'provenance': provenance.toJson(),
      'requiredRuntimeContracts': orderedContracts,
      'minimumAIContractVersion': minimumAIContractVersion,
    };
    final digest = _digest(payload);
    return AISessionContract._(
      id: 'ai-session.${digest.substring(0, 16)}',
      contextId: contextId,
      planId: planId,
      recommendationId: recommendationId,
      executionId: executionId,
      knowledgeVersion: knowledgeVersion,
      knowledgeDigest: knowledgeDigest,
      contextDigest: contextDigest,
      planDigest: planDigest,
      recommendationDigest: recommendationDigest,
      executionDigest: executionDigest,
      provenance: provenance,
      requiredRuntimeContracts: Map.unmodifiable(orderedContracts),
      minimumAIContractVersion: minimumAIContractVersion,
      digest: digest,
    );
  }

  final String id;
  final String knowledgeVersion;
  final String knowledgeDigest;
  final String contextDigest;
  final String planDigest;
  final String recommendationDigest;
  final String executionDigest;
  final AISessionProvenance provenance;
  final Map<String, int> requiredRuntimeContracts;
  final String minimumAIContractVersion;
  final String contextId;
  final String planId;
  final String recommendationId;
  final String executionId;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': aiSessionContractVersion,
        'id': id,
        'contextId': contextId,
        'planId': planId,
        'recommendationId': recommendationId,
        'executionId': executionId,
        'knowledgeVersion': knowledgeVersion,
        'knowledgeDigest': knowledgeDigest,
        'contextDigest': contextDigest,
        'planDigest': planDigest,
        'recommendationDigest': recommendationDigest,
        'executionDigest': executionDigest,
        'provenance': provenance.toJson(),
        'requiredRuntimeContracts': requiredRuntimeContracts,
        'minimumAIContractVersion': minimumAIContractVersion,
        'digest': digest,
      };
}

typedef AISessionInput = AISessionContract;

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
