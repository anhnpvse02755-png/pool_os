import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/ai_session_contracts.dart';

const coachResponseContractVersion = 1;
const coachResponsePolicyVersion = 'coach-response/1.0.0';
const coachAIAdapterContractVersion = 1;

enum CoachResponseKind { structuredSessionAcknowledged }

enum CoachResponseGenerationStatus { notGenerated }

class CoachResponseGeneration {
  const CoachResponseGeneration({required this.status});

  final CoachResponseGenerationStatus status;

  Map<String, dynamic> toJson() => {'status': status.name};
}

class CoachAIRequestEnvelope {
  const CoachAIRequestEnvelope._({
    required this.id,
    required this.sessionId,
    required this.sessionDigest,
    required this.minimumAIContractVersion,
    required this.providerContractVersion,
    required this.providerId,
    required this.digest,
  });

  factory CoachAIRequestEnvelope.create({
    required AISessionContract session,
    required String providerId,
    required String providerContractVersion,
  }) {
    if (providerId.trim().isEmpty || providerContractVersion.trim().isEmpty) {
      throw ArgumentError('AI adapter identity must not be empty.');
    }
    final payload = {
      'schemaVersion': coachAIAdapterContractVersion,
      'sessionId': session.id,
      'sessionDigest': session.digest,
      'minimumAIContractVersion': session.minimumAIContractVersion,
      'providerContractVersion': providerContractVersion,
      'providerId': providerId,
    };
    final digest = _digest(payload);
    return CoachAIRequestEnvelope._(
      id: 'ai-request.${digest.substring(0, 16)}',
      sessionId: session.id,
      sessionDigest: session.digest,
      minimumAIContractVersion: session.minimumAIContractVersion,
      providerContractVersion: providerContractVersion,
      providerId: providerId,
      digest: digest,
    );
  }

  final String id;
  final String sessionId;
  final String sessionDigest;
  final String minimumAIContractVersion;
  final String providerContractVersion;
  final String providerId;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': coachAIAdapterContractVersion,
        'id': id,
        'sessionId': sessionId,
        'sessionDigest': sessionDigest,
        'minimumAIContractVersion': minimumAIContractVersion,
        'providerContractVersion': providerContractVersion,
        'providerId': providerId,
        'digest': digest,
      };
}

class CoachResponseContract {
  const CoachResponseContract._({
    required this.id,
    required this.kind,
    required this.sessionId,
    required this.sessionDigest,
    required this.contextDigest,
    required this.knowledgeVersion,
    required this.knowledgeDigest,
    required this.recommendationId,
    required this.executionDigest,
    required this.request,
    required this.generation,
    required this.digest,
  });

  factory CoachResponseContract.create({
    required AISessionContract session,
    required CoachAIRequestEnvelope request,
    required CoachResponseKind kind,
    required CoachResponseGeneration generation,
  }) {
    if (request.sessionId != session.id ||
        request.sessionDigest != session.digest) {
      throw ArgumentError('Coach Response request is stale or incompatible.');
    }
    final payload = {
      'schemaVersion': coachResponseContractVersion,
      'kind': kind.name,
      'sessionId': session.id,
      'sessionDigest': session.digest,
      'contextDigest': session.contextDigest,
      'knowledgeVersion': session.knowledgeVersion,
      'knowledgeDigest': session.knowledgeDigest,
      'recommendationId': session.recommendationId,
      'executionDigest': session.executionDigest,
      'request': request.toJson(),
      'generation': generation.toJson(),
      'policyVersion': coachResponsePolicyVersion,
    };
    final digest = _digest(payload);
    return CoachResponseContract._(
      id: 'coach-response.${digest.substring(0, 16)}',
      kind: kind,
      sessionId: session.id,
      sessionDigest: session.digest,
      contextDigest: session.contextDigest,
      knowledgeVersion: session.knowledgeVersion,
      knowledgeDigest: session.knowledgeDigest,
      recommendationId: session.recommendationId,
      executionDigest: session.executionDigest,
      request: request,
      generation: generation,
      digest: digest,
    );
  }

  final String id;
  final CoachResponseKind kind;
  final String sessionId;
  final String sessionDigest;
  final String contextDigest;
  final String knowledgeVersion;
  final String knowledgeDigest;
  final String recommendationId;
  final String executionDigest;
  final CoachAIRequestEnvelope request;
  final CoachResponseGeneration generation;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': coachResponseContractVersion,
        'id': id,
        'kind': kind.name,
        'sessionId': sessionId,
        'sessionDigest': sessionDigest,
        'contextDigest': contextDigest,
        'knowledgeVersion': knowledgeVersion,
        'knowledgeDigest': knowledgeDigest,
        'recommendationId': recommendationId,
        'executionDigest': executionDigest,
        'request': request.toJson(),
        'generation': generation.toJson(),
        'policyVersion': coachResponsePolicyVersion,
        'digest': digest,
      };
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
