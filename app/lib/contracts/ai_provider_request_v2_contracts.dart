import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/ai_provider_request_contracts.dart';
import 'package:pool_os/contracts/coach_response_contracts.dart';
import 'package:pool_os/contracts/tool_invocation_contracts.dart';

const aiProviderRequestV2ContractVersion = 2;
const aiProviderRequestV2PolicyVersion = 'ai-provider-request/2.0.0';

class AIProviderRequestV2Contract {
  const AIProviderRequestV2Contract._({
    required this.id,
    required this.baseRequest,
    required this.toolId,
    required this.digest,
  });

  factory AIProviderRequestV2Contract.create({
    required ToolInvocationPlanContract invocationPlan,
    required CoachAIRequestEnvelope providerPayload,
  }) {
    final toolIds =
        invocationPlan.invocations.map((item) => item.toolId).toSet();
    if (toolIds.length != 1) {
      throw ArgumentError('AI Provider Request tool provenance is ambiguous.');
    }
    final baseRequest = AIProviderRequestContract.create(
      invocationPlan: invocationPlan,
      providerPayload: providerPayload,
    );
    final toolId = toolIds.single;
    final payload = {
      'schemaVersion': aiProviderRequestV2ContractVersion,
      'baseRequest': baseRequest.toJson(),
      'toolId': toolId,
      'policyVersion': aiProviderRequestV2PolicyVersion,
    };
    final digest = _digest(payload);
    return AIProviderRequestV2Contract._(
      id: 'ai-provider-request-v2.${digest.substring(0, 16)}',
      baseRequest: baseRequest,
      toolId: toolId,
      digest: digest,
    );
  }

  final String id;
  final AIProviderRequestContract baseRequest;
  final String toolId;
  final String digest;

  String get capabilityId => baseRequest.capabilityId;
  String get sessionDigest => baseRequest.sessionDigest;
  String get renderingDigest => baseRequest.renderingDigest;
  String get invocationPlanDigest => baseRequest.invocationPlanDigest;
  String get registryDigest => baseRequest.registryDigest;
  String get providerPayloadDigest => baseRequest.providerPayloadDigest;
  String get providerRequestDigest => baseRequest.providerRequestDigest;
  CoachAIRequestEnvelope get providerPayload => baseRequest.providerPayload;

  Map<String, dynamic> toJson() => {
        'schemaVersion': aiProviderRequestV2ContractVersion,
        'id': id,
        'baseRequest': baseRequest.toJson(),
        'toolId': toolId,
        'policyVersion': aiProviderRequestV2PolicyVersion,
        'digest': digest,
      };
}

class AIProviderRequestV2Builder {
  const AIProviderRequestV2Builder();

  AIProviderRequestV2Contract build({
    required ToolInvocationPlanContract invocationPlan,
    required CoachAIRequestEnvelope providerPayload,
  }) =>
      AIProviderRequestV2Contract.create(
        invocationPlan: invocationPlan,
        providerPayload: providerPayload,
      );
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
