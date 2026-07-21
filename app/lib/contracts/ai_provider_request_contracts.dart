import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/coach_response_contracts.dart';
import 'package:pool_os/contracts/tool_invocation_contracts.dart';

const aiProviderRequestContractVersion = 1;
const aiProviderRequestPolicyVersion = 'ai-provider-request/1.0.0';

class AIProviderRequestContract {
  const AIProviderRequestContract._({
    required this.id,
    required this.capabilityId,
    required this.sessionDigest,
    required this.renderingDigest,
    required this.invocationPlanDigest,
    required this.registryDigest,
    required this.providerPayload,
    required this.providerPayloadDigest,
    required this.providerRequestDigest,
  });

  factory AIProviderRequestContract.create({
    required ToolInvocationPlanContract invocationPlan,
    required CoachAIRequestEnvelope providerPayload,
  }) {
    final invocations = invocationPlan.invocations;
    if (invocations.isEmpty) {
      throw ArgumentError('AI Provider Request requires an invocation.');
    }
    final capabilityId = invocations.first.capabilityId;
    final sessionDigest = invocations.first.sessionDigest;
    if (invocations.any((item) =>
            item.capabilityId != capabilityId ||
            item.sessionDigest != sessionDigest ||
            item.renderingDigest != invocationPlan.renderingDigest ||
            item.registryDigest != invocationPlan.registryDigest) ||
        providerPayload.sessionDigest != sessionDigest) {
      throw ArgumentError('AI Provider Request provenance is incompatible.');
    }
    final providerPayloadDigest = providerPayload.digest;
    final payload = {
      'schemaVersion': aiProviderRequestContractVersion,
      'capabilityId': capabilityId,
      'sessionDigest': sessionDigest,
      'renderingDigest': invocationPlan.renderingDigest,
      'invocationPlanDigest': invocationPlan.digest,
      'registryDigest': invocationPlan.registryDigest,
      'providerPayload': providerPayload.toJson(),
      'providerPayloadDigest': providerPayloadDigest,
      'policyVersion': aiProviderRequestPolicyVersion,
    };
    final providerRequestDigest = _digest(payload);
    return AIProviderRequestContract._(
      id: 'ai-provider-request.${providerRequestDigest.substring(0, 16)}',
      capabilityId: capabilityId,
      sessionDigest: sessionDigest,
      renderingDigest: invocationPlan.renderingDigest,
      invocationPlanDigest: invocationPlan.digest,
      registryDigest: invocationPlan.registryDigest,
      providerPayload: providerPayload,
      providerPayloadDigest: providerPayloadDigest,
      providerRequestDigest: providerRequestDigest,
    );
  }

  final String id;
  final String capabilityId;
  final String sessionDigest;
  final String renderingDigest;
  final String invocationPlanDigest;
  final String registryDigest;
  final CoachAIRequestEnvelope providerPayload;
  final String providerPayloadDigest;
  final String providerRequestDigest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': aiProviderRequestContractVersion,
        'id': id,
        'capabilityId': capabilityId,
        'sessionDigest': sessionDigest,
        'renderingDigest': renderingDigest,
        'invocationPlanDigest': invocationPlanDigest,
        'registryDigest': registryDigest,
        'providerPayload': providerPayload.toJson(),
        'providerPayloadDigest': providerPayloadDigest,
        'policyVersion': aiProviderRequestPolicyVersion,
        'providerRequestDigest': providerRequestDigest,
      };
}

class AIProviderRequestBuilder {
  const AIProviderRequestBuilder();

  AIProviderRequestContract build({
    required ToolInvocationPlanContract invocationPlan,
    required CoachAIRequestEnvelope providerPayload,
  }) =>
      AIProviderRequestContract.create(
        invocationPlan: invocationPlan,
        providerPayload: providerPayload,
      );
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
