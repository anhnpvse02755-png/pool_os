import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/prompt_assembly_contracts.dart';

const promptRenderingContractVersion = 2;
const legacyPromptRenderingContractVersion = 1;
const promptRenderingSectionContractVersion = 1;
const promptRenderingVersion = 1;
const promptRenderingPolicyVersion = 'prompt-rendering/1.0.0';

enum PromptRenderingStrategy { structuredReferences }

enum PromptRenderingSectionKind {
  variables,
  orderedReferences,
  systemBlock,
  userBlock,
  assistantContextBlock,
}

class PromptRenderingSectionContract {
  factory PromptRenderingSectionContract({
    required int position,
    required PromptRenderingSectionKind kind,
    required List<String> referenceIds,
    required Map<String, String> metadata,
  }) =>
      PromptRenderingSectionContract._(
        position: position,
        kind: kind,
        referenceIds: List.unmodifiable(referenceIds),
        metadata: Map.unmodifiable(metadata),
      );

  const PromptRenderingSectionContract._({
    required this.position,
    required this.kind,
    required this.referenceIds,
    required this.metadata,
  });

  final int position;
  final PromptRenderingSectionKind kind;
  final List<String> referenceIds;
  final Map<String, String> metadata;

  Map<String, dynamic> toJson() => {
        'schemaVersion': promptRenderingSectionContractVersion,
        'position': position,
        'kind': kind.name,
        'referenceIds': referenceIds,
        'metadata': metadata,
      };
}

class PromptRenderingContract {
  const PromptRenderingContract._({
    required this.schemaVersion,
    required this.id,
    required this.renderingVersion,
    required this.strategy,
    required this.capabilityId,
    required this.assemblyDigest,
    required this.sessionDigest,
    required this.registryDigest,
    required this.providerTarget,
    required this.sections,
    required this.renderedPayloadDigest,
    required this.digest,
  });

  factory PromptRenderingContract.create({
    required String capabilityId,
    required String assemblyDigest,
    required String sessionDigest,
    required String registryDigest,
    required String providerTarget,
    required PromptRenderingStrategy strategy,
    required List<PromptRenderingSectionContract> sections,
  }) {
    if (capabilityId.trim().isEmpty ||
        assemblyDigest.trim().isEmpty ||
        sessionDigest.trim().isEmpty ||
        registryDigest.trim().isEmpty ||
        providerTarget != 'provider-neutral' ||
        strategy != PromptRenderingStrategy.structuredReferences ||
        sections.length != PromptRenderingSectionKind.values.length) {
      throw ArgumentError('Prompt Rendering metadata is invalid.');
    }
    for (var index = 0; index < sections.length; index++) {
      final section = sections[index];
      if (section.position != index + 1 ||
          section.kind != PromptRenderingSectionKind.values[index] ||
          section.referenceIds.any((id) => id.trim().isEmpty) ||
          section.referenceIds.toSet().length != section.referenceIds.length ||
          section.metadata.keys.any((key) => key.trim().isEmpty) ||
          section.metadata.values.any((value) => value.contains('\n'))) {
        throw ArgumentError('Prompt Rendering section ordering is invalid.');
      }
    }
    final payload = {
      'renderingVersion': promptRenderingVersion,
      'strategy': strategy.name,
      'capabilityId': capabilityId,
      'assemblyDigest': assemblyDigest,
      'sessionDigest': sessionDigest,
      'registryDigest': registryDigest,
      'providerTarget': providerTarget,
      'sections': sections.map((section) => section.toJson()).toList(),
      'policyVersion': promptRenderingPolicyVersion,
    };
    final renderedPayloadDigest = _digest(payload);
    final digest = _digest({
      ...payload,
      'renderedPayloadDigest': renderedPayloadDigest,
    });
    return PromptRenderingContract._(
      id: 'prompt-rendering.${digest.substring(0, 16)}',
      schemaVersion: promptRenderingContractVersion,
      renderingVersion: promptRenderingVersion,
      strategy: strategy,
      capabilityId: capabilityId,
      assemblyDigest: assemblyDigest,
      sessionDigest: sessionDigest,
      registryDigest: registryDigest,
      providerTarget: providerTarget,
      sections: List.unmodifiable(sections),
      renderedPayloadDigest: renderedPayloadDigest,
      digest: digest,
    );
  }

  factory PromptRenderingContract.fromJson(Map<String, dynamic> json) {
    final schemaVersion = json['schemaVersion'] as int?;
    if (schemaVersion != legacyPromptRenderingContractVersion &&
        schemaVersion != promptRenderingContractVersion) {
      throw ArgumentError('Prompt Rendering version is unsupported.');
    }
    final strategy = PromptRenderingStrategy.values.singleWhere(
      (value) => value.name == json['strategy'],
      orElse: () =>
          throw ArgumentError('Prompt Rendering strategy is invalid.'),
    );
    final sections = (json['sections'] as List)
        .cast<Map<String, dynamic>>()
        .map((section) => PromptRenderingSectionContract(
              position: section['position'] as int,
              kind: PromptRenderingSectionKind.values.singleWhere(
                (value) => value.name == section['kind'],
                orElse: () => throw ArgumentError(
                    'Prompt Rendering section kind is invalid.'),
              ),
              referenceIds: (section['referenceIds'] as List).cast<String>(),
              metadata: (section['metadata'] as Map).cast<String, String>(),
            ))
        .toList();
    final payload = {
      'renderingVersion': json['renderingVersion'],
      'strategy': strategy.name,
      'capabilityId': json['capabilityId'],
      'assemblyDigest': json['assemblyDigest'],
      if (schemaVersion! >= promptRenderingContractVersion)
        'sessionDigest': json['sessionDigest'],
      if (schemaVersion >= promptRenderingContractVersion)
        'registryDigest': json['registryDigest'],
      'providerTarget': json['providerTarget'],
      'sections': sections.map((section) => section.toJson()).toList(),
      'policyVersion': json['policyVersion'],
    };
    final payloadDigest = _digest(payload);
    final contractDigest = _digest({
      ...payload,
      'renderedPayloadDigest': payloadDigest,
    });
    if (json['renderedPayloadDigest'] != payloadDigest ||
        json['digest'] != contractDigest ||
        json['id'] != 'prompt-rendering.${contractDigest.substring(0, 16)}') {
      throw ArgumentError('Prompt Rendering artifact digest is invalid.');
    }
    return PromptRenderingContract._(
      id: json['id'] as String,
      schemaVersion: schemaVersion,
      renderingVersion: json['renderingVersion'] as int,
      strategy: strategy,
      capabilityId: json['capabilityId'] as String,
      assemblyDigest: json['assemblyDigest'] as String,
      sessionDigest: json['sessionDigest'] as String?,
      registryDigest: json['registryDigest'] as String?,
      providerTarget: json['providerTarget'] as String,
      sections: List.unmodifiable(sections),
      renderedPayloadDigest: payloadDigest,
      digest: contractDigest,
    );
  }

  final int schemaVersion;
  final String id;
  final int renderingVersion;
  final PromptRenderingStrategy strategy;
  final String capabilityId;
  final String assemblyDigest;
  final String? sessionDigest;
  final String? registryDigest;
  final String providerTarget;
  final List<PromptRenderingSectionContract> sections;
  final String renderedPayloadDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'id': id,
        'renderingVersion': renderingVersion,
        'strategy': strategy.name,
        'capabilityId': capabilityId,
        'assemblyDigest': assemblyDigest,
        if (sessionDigest != null) 'sessionDigest': sessionDigest,
        if (registryDigest != null) 'registryDigest': registryDigest,
        'providerTarget': providerTarget,
        'sections': sections.map((section) => section.toJson()).toList(),
        'renderedPayloadDigest': renderedPayloadDigest,
        'policyVersion': promptRenderingPolicyVersion,
        'digest': digest,
      };
}

class PromptRenderer {
  const PromptRenderer();

  PromptRenderingContract render(PromptAssemblyContract assembly) {
    final sections = [
      PromptRenderingSectionContract(
        position: 1,
        kind: PromptRenderingSectionKind.variables,
        referenceIds: const [],
        metadata: assembly.metadata,
      ),
      PromptRenderingSectionContract(
        position: 2,
        kind: PromptRenderingSectionKind.orderedReferences,
        referenceIds: List.unmodifiable([
          ...assembly.planningNodeIds,
          ...assembly.recommendationIds,
        ]),
        metadata: const {},
      ),
      PromptRenderingSectionContract(
        position: 3,
        kind: PromptRenderingSectionKind.systemBlock,
        referenceIds:
            List.unmodifiable([assembly.contextId, assembly.sessionDigest]),
        metadata: const {},
      ),
      PromptRenderingSectionContract(
        position: 4,
        kind: PromptRenderingSectionKind.userBlock,
        referenceIds: List.unmodifiable(
            [assembly.recommendationId, assembly.executionId]),
        metadata: const {},
      ),
      PromptRenderingSectionContract(
        position: 5,
        kind: PromptRenderingSectionKind.assistantContextBlock,
        referenceIds: List.unmodifiable(assembly.adaptationIds),
        metadata: const {},
      ),
    ];
    return PromptRenderingContract.create(
      capabilityId: assembly.header.capabilityId,
      assemblyDigest: assembly.digest,
      sessionDigest: assembly.sessionDigest,
      registryDigest: assembly.registryDigest,
      providerTarget: 'provider-neutral',
      strategy: PromptRenderingStrategy.structuredReferences,
      sections: sections,
    );
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
