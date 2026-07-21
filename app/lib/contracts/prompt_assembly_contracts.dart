import 'dart:convert';

import 'package:crypto/crypto.dart';

const promptAssemblyContractVersion = 1;
const promptAssemblyHeaderContractVersion = 1;
const promptAssemblyPolicyVersion = 'prompt-assembly/1.0.0';

class PromptAssemblyHeaderContract {
  const PromptAssemblyHeaderContract({
    required this.schemaVersion,
    required this.policyVersion,
    required this.capabilityId,
  });

  final int schemaVersion;
  final String policyVersion;
  final String capabilityId;

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'policyVersion': policyVersion,
        'capabilityId': capabilityId,
      };
}

class PromptAssemblyContract {
  const PromptAssemblyContract._({
    required this.id,
    required this.header,
    required this.sessionDigest,
    required this.registryDigest,
    required this.contextDigest,
    required this.planningDigest,
    required this.recommendationDigest,
    required this.adaptationDigest,
    required this.contextId,
    required this.planId,
    required this.recommendationId,
    required this.executionId,
    required this.planningNodeIds,
    required this.recommendationIds,
    required this.executionIds,
    required this.adaptationIds,
    required this.metadata,
    required this.digest,
  });

  factory PromptAssemblyContract.create({
    required String capabilityId,
    required String sessionDigest,
    required String registryDigest,
    required String contextDigest,
    required String planningDigest,
    required String recommendationDigest,
    required String adaptationDigest,
    required String contextId,
    required String planId,
    required String recommendationId,
    required String executionId,
    required List<String> planningNodeIds,
    required List<String> recommendationIds,
    required List<String> executionIds,
    required List<String> adaptationIds,
    required Map<String, String> metadata,
  }) {
    final values = {
      'capabilityId': capabilityId,
      'sessionDigest': sessionDigest,
      'registryDigest': registryDigest,
      'contextDigest': contextDigest,
      'planningDigest': planningDigest,
      'recommendationDigest': recommendationDigest,
      'adaptationDigest': adaptationDigest,
      'contextId': contextId,
      'planId': planId,
      'recommendationId': recommendationId,
      'executionId': executionId,
    };
    if (values.values.any((value) => value.trim().isEmpty)) {
      throw ArgumentError('Prompt Assembly provenance is invalid.');
    }
    final lists = [
      planningNodeIds,
      recommendationIds,
      executionIds,
      adaptationIds,
    ];
    if (lists.any((items) => items.any((item) => item.trim().isEmpty))) {
      throw ArgumentError('Prompt Assembly references are invalid.');
    }
    if (_hasDuplicates(planningNodeIds) ||
        _hasDuplicates(recommendationIds) ||
        _hasDuplicates(executionIds) ||
        _hasDuplicates(adaptationIds)) {
      throw ArgumentError('Prompt Assembly contains duplicate references.');
    }
    if (metadata.keys.any((key) =>
            !RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(key) ||
            key.trim().isEmpty) ||
        metadata.values.any((value) =>
            value.trim().isEmpty ||
            value.contains('\n') ||
            value.contains('\r'))) {
      throw ArgumentError('Prompt Assembly metadata is invalid.');
    }
    final orderedPlanning = [...planningNodeIds]..sort();
    final orderedRecommendations = [...recommendationIds]..sort();
    final orderedExecutions = [...executionIds]..sort();
    final orderedAdaptations = [...adaptationIds]..sort();
    final orderedMetadata = <String, String>{
      for (final key in metadata.keys.toList()..sort()) key: metadata[key]!,
    };
    final header = PromptAssemblyHeaderContract(
      schemaVersion: promptAssemblyHeaderContractVersion,
      policyVersion: promptAssemblyPolicyVersion,
      capabilityId: capabilityId,
    );
    final payload = {
      'schemaVersion': promptAssemblyContractVersion,
      'header': header.toJson(),
      'sessionDigest': sessionDigest,
      'registryDigest': registryDigest,
      'contextDigest': contextDigest,
      'planningDigest': planningDigest,
      'recommendationDigest': recommendationDigest,
      'adaptationDigest': adaptationDigest,
      'contextId': contextId,
      'planId': planId,
      'recommendationId': recommendationId,
      'executionId': executionId,
      'planningNodeIds': orderedPlanning,
      'recommendationIds': orderedRecommendations,
      'executionIds': orderedExecutions,
      'adaptationIds': orderedAdaptations,
      'metadata': orderedMetadata,
    };
    final digest = _digest(payload);
    return PromptAssemblyContract._(
      id: 'prompt-assembly.${digest.substring(0, 16)}',
      header: header,
      sessionDigest: sessionDigest,
      registryDigest: registryDigest,
      contextDigest: contextDigest,
      planningDigest: planningDigest,
      recommendationDigest: recommendationDigest,
      adaptationDigest: adaptationDigest,
      contextId: contextId,
      planId: planId,
      recommendationId: recommendationId,
      executionId: executionId,
      planningNodeIds: List.unmodifiable(orderedPlanning),
      recommendationIds: List.unmodifiable(orderedRecommendations),
      executionIds: List.unmodifiable(orderedExecutions),
      adaptationIds: List.unmodifiable(orderedAdaptations),
      metadata: Map.unmodifiable(orderedMetadata),
      digest: digest,
    );
  }

  final String id;
  final PromptAssemblyHeaderContract header;
  final String sessionDigest;
  final String registryDigest;
  final String contextDigest;
  final String planningDigest;
  final String recommendationDigest;
  final String adaptationDigest;
  final String contextId;
  final String planId;
  final String recommendationId;
  final String executionId;
  final List<String> planningNodeIds;
  final List<String> recommendationIds;
  final List<String> executionIds;
  final List<String> adaptationIds;
  final Map<String, String> metadata;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': promptAssemblyContractVersion,
        'id': id,
        'header': header.toJson(),
        'sessionDigest': sessionDigest,
        'registryDigest': registryDigest,
        'contextDigest': contextDigest,
        'planningDigest': planningDigest,
        'recommendationDigest': recommendationDigest,
        'adaptationDigest': adaptationDigest,
        'contextId': contextId,
        'planId': planId,
        'recommendationId': recommendationId,
        'executionId': executionId,
        'planningNodeIds': planningNodeIds,
        'recommendationIds': recommendationIds,
        'executionIds': executionIds,
        'adaptationIds': adaptationIds,
        'metadata': metadata,
        'digest': digest,
      };
}

bool _hasDuplicates(List<String> values) =>
    values.toSet().length != values.length;

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
