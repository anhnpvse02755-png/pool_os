import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/ai_capability_registry_contracts.dart';
import 'package:pool_os/contracts/ai_session_contracts.dart';
import 'package:pool_os/contracts/coach_response_contracts.dart';

const aiOrchestrationContractVersion = 1;
const aiOrchestrationPolicyVersion = 'ai-orchestration/1.0.0';

enum AIOrchestrationStatus { completed }

class AIOrchestrationRoute {
  const AIOrchestrationRoute({
    required this.capabilityId,
    required this.providerId,
    required this.providerContractVersion,
  });

  final String capabilityId;
  final String providerId;
  final String providerContractVersion;

  Map<String, dynamic> toJson() => {
        'capabilityId': capabilityId,
        'providerId': providerId,
        'providerContractVersion': providerContractVersion,
      };
}

class AIOrchestrationRequest {
  const AIOrchestrationRequest._({
    required this.id,
    required this.sessionId,
    required this.sessionDigest,
    required this.capabilityRegistryId,
    required this.capabilityRegistryDigest,
    required this.capabilityIds,
    required this.digest,
  });

  factory AIOrchestrationRequest.create({
    required AISessionContract session,
    required AICapabilityRegistryContract capabilityRegistry,
    required List<String> capabilityIds,
  }) {
    if (capabilityIds.isEmpty ||
        capabilityIds.any((capabilityId) => capabilityId.trim().isEmpty)) {
      throw ArgumentError('AI orchestration capabilities are invalid.');
    }
    final ordered = [...capabilityIds]..sort();
    if (ordered.toSet().length != ordered.length) {
      throw ArgumentError('AI orchestration capabilities contain duplicates.');
    }
    final payload = {
      'schemaVersion': aiOrchestrationContractVersion,
      'sessionId': session.id,
      'sessionDigest': session.digest,
      'capabilityRegistryId': capabilityRegistry.id,
      'capabilityRegistryDigest': capabilityRegistry.digest,
      'capabilityIds': ordered,
      'policyVersion': aiOrchestrationPolicyVersion,
    };
    final digest = _digest(payload);
    return AIOrchestrationRequest._(
      id: 'ai-orchestration-request.${digest.substring(0, 16)}',
      sessionId: session.id,
      sessionDigest: session.digest,
      capabilityRegistryId: capabilityRegistry.id,
      capabilityRegistryDigest: capabilityRegistry.digest,
      capabilityIds: List.unmodifiable(ordered),
      digest: digest,
    );
  }

  final String id;
  final String sessionId;
  final String sessionDigest;
  final String capabilityRegistryId;
  final String capabilityRegistryDigest;
  final List<String> capabilityIds;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': aiOrchestrationContractVersion,
        'id': id,
        'sessionId': sessionId,
        'sessionDigest': sessionDigest,
        'capabilityRegistryId': capabilityRegistryId,
        'capabilityRegistryDigest': capabilityRegistryDigest,
        'capabilityIds': capabilityIds,
        'policyVersion': aiOrchestrationPolicyVersion,
        'digest': digest,
      };
}

class AIOrchestrationStepResult {
  const AIOrchestrationStepResult._({
    required this.route,
    required this.sessionId,
    required this.sessionDigest,
    required this.capabilityRegistryDigest,
    required this.capabilityBindingDigest,
    required this.requestDigest,
    required this.responseId,
    required this.responseDigest,
    required this.status,
    required this.digest,
  });

  factory AIOrchestrationStepResult.create({
    required AIOrchestrationRoute route,
    required AICapabilityBinding capabilityBinding,
    required CoachResponseContract response,
  }) {
    if (capabilityBinding.capabilityId != route.capabilityId ||
        response.request.providerId != route.providerId ||
        response.request.providerContractVersion !=
            route.providerContractVersion) {
      throw ArgumentError('AI orchestration step binding is incompatible.');
    }
    final payload = {
      'route': route.toJson(),
      'sessionId': response.sessionId,
      'sessionDigest': response.sessionDigest,
      'capabilityRegistryDigest': capabilityBinding.registryDigest,
      'capabilityBindingDigest': capabilityBinding.digest,
      'requestDigest': response.request.digest,
      'responseId': response.id,
      'responseDigest': response.digest,
      'status': AIOrchestrationStatus.completed.name,
    };
    final digest = _digest(payload);
    return AIOrchestrationStepResult._(
      route: route,
      sessionId: response.sessionId,
      sessionDigest: response.sessionDigest,
      capabilityRegistryDigest: capabilityBinding.registryDigest,
      capabilityBindingDigest: capabilityBinding.digest,
      requestDigest: response.request.digest,
      responseId: response.id,
      responseDigest: response.digest,
      status: AIOrchestrationStatus.completed,
      digest: digest,
    );
  }

  final AIOrchestrationRoute route;
  final String sessionId;
  final String sessionDigest;
  final String capabilityRegistryDigest;
  final String capabilityBindingDigest;
  final String requestDigest;
  final String responseId;
  final String responseDigest;
  final AIOrchestrationStatus status;
  final String digest;

  Map<String, dynamic> toJson() => {
        'route': route.toJson(),
        'sessionId': sessionId,
        'sessionDigest': sessionDigest,
        'capabilityRegistryDigest': capabilityRegistryDigest,
        'capabilityBindingDigest': capabilityBindingDigest,
        'requestDigest': requestDigest,
        'responseId': responseId,
        'responseDigest': responseDigest,
        'status': status.name,
        'digest': digest,
      };
}

class AIOrchestrationResult {
  const AIOrchestrationResult._({
    required this.id,
    required this.requestId,
    required this.requestDigest,
    required this.steps,
    required this.status,
    required this.digest,
  });

  factory AIOrchestrationResult.create({
    required AIOrchestrationRequest request,
    required List<AIOrchestrationStepResult> steps,
  }) {
    if (steps.length != request.capabilityIds.length ||
        steps.asMap().entries.any(
              (entry) =>
                  entry.value.route.capabilityId !=
                      request.capabilityIds[entry.key] ||
                  entry.value.sessionId != request.sessionId ||
                  entry.value.sessionDigest != request.sessionDigest ||
                  entry.value.capabilityRegistryDigest !=
                      request.capabilityRegistryDigest,
            )) {
      throw ArgumentError('AI orchestration result is incomplete or stale.');
    }
    final payload = {
      'schemaVersion': aiOrchestrationContractVersion,
      'requestId': request.id,
      'requestDigest': request.digest,
      'steps': steps.map((step) => step.toJson()).toList(),
      'status': AIOrchestrationStatus.completed.name,
      'policyVersion': aiOrchestrationPolicyVersion,
    };
    final digest = _digest(payload);
    return AIOrchestrationResult._(
      id: 'ai-orchestration-result.${digest.substring(0, 16)}',
      requestId: request.id,
      requestDigest: request.digest,
      steps: List.unmodifiable(steps),
      status: AIOrchestrationStatus.completed,
      digest: digest,
    );
  }

  final String id;
  final String requestId;
  final String requestDigest;
  final List<AIOrchestrationStepResult> steps;
  final AIOrchestrationStatus status;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': aiOrchestrationContractVersion,
        'id': id,
        'requestId': requestId,
        'requestDigest': requestDigest,
        'steps': steps.map((step) => step.toJson()).toList(),
        'status': status.name,
        'policyVersion': aiOrchestrationPolicyVersion,
        'digest': digest,
      };
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
