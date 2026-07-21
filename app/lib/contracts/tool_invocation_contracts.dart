import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/ai_capability_registry_v2_contracts.dart';
import 'package:pool_os/contracts/prompt_rendering_contracts.dart';

const toolInvocationContractVersion = 1;
const toolInvocationPlanContractVersion = 1;
const toolInvocationPolicyVersion = 'tool-invocation/1.0.0';

class ToolInvocationContract {
  const ToolInvocationContract._({
    required this.id,
    required this.capabilityId,
    required this.toolId,
    required this.invocationReason,
    required this.renderingDigest,
    required this.sessionDigest,
    required this.registryDigest,
    required this.metadata,
    required this.digest,
  });

  factory ToolInvocationContract.create({
    required String capabilityId,
    required String toolId,
    required AIToolInvocationPolicyV2 invocationReason,
    required String renderingDigest,
    required String sessionDigest,
    required String registryDigest,
    required Map<String, String> metadata,
  }) {
    if (capabilityId.trim().isEmpty ||
        toolId.trim().isEmpty ||
        renderingDigest.trim().isEmpty ||
        sessionDigest.trim().isEmpty ||
        registryDigest.trim().isEmpty ||
        invocationReason == AIToolInvocationPolicyV2.none ||
        metadata.keys.any((key) => key.trim().isEmpty) ||
        metadata.values
            .any((value) => value.trim().isEmpty || value.contains('\n'))) {
      throw ArgumentError('Tool Invocation metadata is invalid.');
    }
    final orderedMetadata = <String, String>{
      for (final key in metadata.keys.toList()..sort()) key: metadata[key]!,
    };
    final payload = {
      'schemaVersion': toolInvocationContractVersion,
      'capabilityId': capabilityId,
      'toolId': toolId,
      'invocationReason': invocationReason.name,
      'renderingDigest': renderingDigest,
      'sessionDigest': sessionDigest,
      'registryDigest': registryDigest,
      'metadata': orderedMetadata,
      'policyVersion': toolInvocationPolicyVersion,
    };
    final digest = _digest(payload);
    return ToolInvocationContract._(
      id: 'tool-invocation.${digest.substring(0, 16)}',
      capabilityId: capabilityId,
      toolId: toolId,
      invocationReason: invocationReason,
      renderingDigest: renderingDigest,
      sessionDigest: sessionDigest,
      registryDigest: registryDigest,
      metadata: Map.unmodifiable(orderedMetadata),
      digest: digest,
    );
  }

  final String id;
  final String capabilityId;
  final String toolId;
  final AIToolInvocationPolicyV2 invocationReason;
  final String renderingDigest;
  final String sessionDigest;
  final String registryDigest;
  final Map<String, String> metadata;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': toolInvocationContractVersion,
        'id': id,
        'capabilityId': capabilityId,
        'toolId': toolId,
        'invocationReason': invocationReason.name,
        'renderingDigest': renderingDigest,
        'sessionDigest': sessionDigest,
        'registryDigest': registryDigest,
        'metadata': metadata,
        'policyVersion': toolInvocationPolicyVersion,
        'digest': digest,
      };
}

class ToolInvocationPlanContract {
  const ToolInvocationPlanContract._({
    required this.id,
    required this.renderingDigest,
    required this.registryDigest,
    required this.invocations,
    required this.digest,
  });

  factory ToolInvocationPlanContract.create({
    required String renderingDigest,
    required String registryDigest,
    required List<ToolInvocationContract> invocations,
  }) {
    if (renderingDigest.trim().isEmpty ||
        registryDigest.trim().isEmpty ||
        invocations.isEmpty ||
        invocations.any((item) =>
            item.renderingDigest != renderingDigest ||
            item.registryDigest != registryDigest) ||
        invocations.map((item) => item.id).toSet().length !=
            invocations.length) {
      throw ArgumentError('Tool Invocation Plan binding is invalid.');
    }
    final ordered = [...invocations]..sort((a, b) => a.id.compareTo(b.id));
    final payload = {
      'schemaVersion': toolInvocationPlanContractVersion,
      'renderingDigest': renderingDigest,
      'registryDigest': registryDigest,
      'invocations': ordered.map((item) => item.toJson()).toList(),
      'policyVersion': toolInvocationPolicyVersion,
    };
    final digest = _digest(payload);
    return ToolInvocationPlanContract._(
      id: 'tool-invocation-plan.${digest.substring(0, 16)}',
      renderingDigest: renderingDigest,
      registryDigest: registryDigest,
      invocations: List.unmodifiable(ordered),
      digest: digest,
    );
  }

  final String id;
  final String renderingDigest;
  final String registryDigest;
  final List<ToolInvocationContract> invocations;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': toolInvocationPlanContractVersion,
        'id': id,
        'renderingDigest': renderingDigest,
        'registryDigest': registryDigest,
        'invocations': invocations.map((item) => item.toJson()).toList(),
        'policyVersion': toolInvocationPolicyVersion,
        'digest': digest,
      };
}

class ToolInvocationPlanner {
  const ToolInvocationPlanner();

  ToolInvocationPlanContract plan({
    required PromptRenderingContract rendering,
    required AICapabilityRegistryV2Contract registry,
  }) {
    if (rendering.schemaVersion < promptRenderingContractVersion ||
        rendering.sessionDigest == null ||
        rendering.registryDigest == null ||
        registry.schemaVersion != aiCapabilityRegistryV2ContractVersion ||
        rendering.registryDigest != registry.digest) {
      throw ArgumentError('Tool Invocation provenance is incompatible.');
    }
    final definition = registry.definitionFor(rendering.capabilityId);
    final toolId = definition.defaultToolId;
    if (toolId == null ||
        !definition.allowedToolIds.contains(toolId) ||
        definition.toolInvocationPolicy == AIToolInvocationPolicyV2.none) {
      throw StateError('Capability has no registered default tool.');
    }
    final invocation = ToolInvocationContract.create(
      capabilityId: rendering.capabilityId,
      toolId: toolId,
      invocationReason: definition.toolInvocationPolicy,
      renderingDigest: rendering.digest,
      sessionDigest: rendering.sessionDigest!,
      registryDigest: registry.digest,
      metadata: {'policy': definition.toolInvocationPolicy.name},
    );
    return ToolInvocationPlanContract.create(
      renderingDigest: rendering.digest,
      registryDigest: registry.digest,
      invocations: [invocation],
    );
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
