import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/ai_conversation_memory_contracts.dart';
import 'package:pool_os/contracts/ai_provider_contracts.dart';
import 'package:pool_os/contracts/ai_provider_request_v2_contracts.dart';
import 'package:pool_os/contracts/ai_response_processing_v2_contracts.dart';
import 'package:pool_os/contracts/ai_session_contracts.dart';
import 'package:pool_os/contracts/ai_tool_result_projection_contracts.dart';
import 'package:pool_os/contracts/prompt_assembly_contracts.dart';
import 'package:pool_os/contracts/prompt_rendering_contracts.dart';
import 'package:pool_os/contracts/tool_invocation_contracts.dart';

const aiObservabilityProjectionContractVersion = 1;
const aiObservabilityProjectionPolicyVersion = 'ai-observability/1.0.0';

class AIObservabilityStageReference {
  const AIObservabilityStageReference({
    required this.position,
    required this.stage,
    required this.digest,
  });

  final int position;
  final String stage;
  final String digest;

  Map<String, dynamic> toJson() => {
        'position': position,
        'stage': stage,
        'digest': digest,
      };
}

class AIObservabilityProjectionContract {
  const AIObservabilityProjectionContract._({
    required this.id,
    required this.sessionDigest,
    required this.capabilityId,
    required this.renderingDigest,
    required this.providerRequestDigest,
    required this.providerResultDigest,
    required this.processingDigest,
    required this.memoryDigest,
    required this.toolProjectionDigest,
    required this.stages,
    required this.digest,
  });

  factory AIObservabilityProjectionContract.create({
    required AISessionContract session,
    required PromptAssemblyContract assembly,
    required PromptRenderingContract rendering,
    required ToolInvocationPlanContract invocationPlan,
    required AIProviderRequestV2Contract providerRequest,
    required AIProviderResult providerResult,
    required AIResponseProcessingV2Contract processing,
    required AIConversationMemoryContract memory,
    required AIToolResultProjectionContract toolProjection,
  }) {
    final baseProcessing = processing.baseProcessing;
    final memoryMatches = memory.entries
        .where(
            (item) => item.processingDigest == baseProcessing.processingDigest)
        .length;
    final toolMatches = toolProjection.results
        .where(
            (item) => item.processingDigest == baseProcessing.processingDigest)
        .length;
    if (assembly.sessionDigest != session.digest ||
        rendering.assemblyDigest != assembly.digest ||
        rendering.sessionDigest != session.digest ||
        invocationPlan.renderingDigest != rendering.digest ||
        providerRequest.invocationPlanDigest != invocationPlan.digest ||
        providerRequest.sessionDigest != session.digest ||
        providerRequest.renderingDigest != rendering.digest ||
        providerRequest.capabilityId != rendering.capabilityId ||
        providerResult.requestDigest != providerRequest.providerPayloadDigest ||
        processing.providerResultDigest != providerResult.digest ||
        processing.capabilityId != providerRequest.capabilityId ||
        processing.toolId != providerRequest.toolId ||
        memory.capabilityId != processing.capabilityId ||
        toolProjection.capabilityId != processing.capabilityId ||
        memoryMatches != 1 ||
        toolMatches != 1) {
      throw ArgumentError('AI Observability provenance chain is invalid.');
    }
    final stages = [
      AIObservabilityStageReference(
          position: 1, stage: 'session', digest: session.digest),
      AIObservabilityStageReference(
          position: 2, stage: 'assembly', digest: assembly.digest),
      AIObservabilityStageReference(
          position: 3, stage: 'rendering', digest: rendering.digest),
      AIObservabilityStageReference(
          position: 4, stage: 'invocationPlan', digest: invocationPlan.digest),
      AIObservabilityStageReference(
          position: 5,
          stage: 'providerRequest',
          digest: providerRequest.digest),
      AIObservabilityStageReference(
          position: 6, stage: 'providerResult', digest: providerResult.digest),
      AIObservabilityStageReference(
          position: 7, stage: 'responseProcessing', digest: processing.digest),
      AIObservabilityStageReference(
          position: 8, stage: 'conversationMemory', digest: memory.digest),
      AIObservabilityStageReference(
          position: 9,
          stage: 'toolResultProjection',
          digest: toolProjection.digest),
    ];
    final payload = {
      'schemaVersion': aiObservabilityProjectionContractVersion,
      'sessionDigest': session.digest,
      'capabilityId': processing.capabilityId,
      'renderingDigest': rendering.digest,
      'providerRequestDigest': providerRequest.providerRequestDigest,
      'providerResultDigest': providerResult.digest,
      'processingDigest': baseProcessing.processingDigest,
      'memoryDigest': memory.digest,
      'toolProjectionDigest': toolProjection.digest,
      'stages': stages.map((item) => item.toJson()).toList(),
      'policyVersion': aiObservabilityProjectionPolicyVersion,
    };
    final digest = _digest(payload);
    return AIObservabilityProjectionContract._(
      id: 'ai-observability.${digest.substring(0, 16)}',
      sessionDigest: session.digest,
      capabilityId: processing.capabilityId,
      renderingDigest: rendering.digest,
      providerRequestDigest: providerRequest.providerRequestDigest,
      providerResultDigest: providerResult.digest,
      processingDigest: baseProcessing.processingDigest,
      memoryDigest: memory.digest,
      toolProjectionDigest: toolProjection.digest,
      stages: List.unmodifiable(stages),
      digest: digest,
    );
  }

  final String id;
  final String sessionDigest;
  final String capabilityId;
  final String renderingDigest;
  final String providerRequestDigest;
  final String providerResultDigest;
  final String processingDigest;
  final String memoryDigest;
  final String toolProjectionDigest;
  final List<AIObservabilityStageReference> stages;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': aiObservabilityProjectionContractVersion,
        'id': id,
        'sessionDigest': sessionDigest,
        'capabilityId': capabilityId,
        'renderingDigest': renderingDigest,
        'providerRequestDigest': providerRequestDigest,
        'providerResultDigest': providerResultDigest,
        'processingDigest': processingDigest,
        'memoryDigest': memoryDigest,
        'toolProjectionDigest': toolProjectionDigest,
        'stages': stages.map((item) => item.toJson()).toList(),
        'policyVersion': aiObservabilityProjectionPolicyVersion,
        'digest': digest,
      };
}

class AIObservabilityProjector {
  const AIObservabilityProjector();

  AIObservabilityProjectionContract project({
    required AISessionContract session,
    required PromptAssemblyContract assembly,
    required PromptRenderingContract rendering,
    required ToolInvocationPlanContract invocationPlan,
    required AIProviderRequestV2Contract providerRequest,
    required AIProviderResult providerResult,
    required AIResponseProcessingV2Contract processing,
    required AIConversationMemoryContract memory,
    required AIToolResultProjectionContract toolProjection,
  }) =>
      AIObservabilityProjectionContract.create(
        session: session,
        assembly: assembly,
        rendering: rendering,
        invocationPlan: invocationPlan,
        providerRequest: providerRequest,
        providerResult: providerResult,
        processing: processing,
        memory: memory,
        toolProjection: toolProjection,
      );
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
