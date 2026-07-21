import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/ai_response_processing_v2_contracts.dart';

const aiToolResultProjectionContractVersion = 1;
const aiToolResultProjectionPolicyVersion = 'ai-tool-result-projection/1.0.0';

class AIToolResultReferenceContract {
  const AIToolResultReferenceContract._({
    required this.position,
    required this.toolId,
    required this.capabilityId,
    required this.processingDigest,
    required this.providerPayloadDigest,
    required this.providerRequestDigest,
    required this.providerResultDigest,
    required this.executionStatus,
  });

  factory AIToolResultReferenceContract.fromProcessing({
    required int position,
    required AIResponseProcessingV2Contract processing,
  }) {
    final status = processing.processingMetadata['status'];
    if (position < 1 ||
        processing.toolId.trim().isEmpty ||
        processing.capabilityId.trim().isEmpty ||
        status == null ||
        status.trim().isEmpty) {
      throw ArgumentError('AI Tool Result provenance is malformed.');
    }
    return AIToolResultReferenceContract._(
      position: position,
      toolId: processing.toolId,
      capabilityId: processing.capabilityId,
      processingDigest: processing.processingDigest,
      providerPayloadDigest: processing.providerPayloadDigest,
      providerRequestDigest: processing.providerRequestDigest,
      providerResultDigest: processing.providerResultDigest,
      executionStatus: status,
    );
  }

  final int position;
  final String toolId;
  final String capabilityId;
  final String processingDigest;
  final String providerPayloadDigest;
  final String providerRequestDigest;
  final String providerResultDigest;
  final String executionStatus;

  Map<String, dynamic> toJson() => {
        'position': position,
        'toolId': toolId,
        'capabilityId': capabilityId,
        'processingDigest': processingDigest,
        'providerPayloadDigest': providerPayloadDigest,
        'providerRequestDigest': providerRequestDigest,
        'providerResultDigest': providerResultDigest,
        'executionStatus': executionStatus,
      };
}

class AIToolResultProjectionContract {
  const AIToolResultProjectionContract._({
    required this.id,
    required this.capabilityId,
    required this.results,
    required this.digest,
  });

  factory AIToolResultProjectionContract.create(
    List<AIResponseProcessingV2Contract> processingArtifacts,
  ) {
    if (processingArtifacts.isEmpty ||
        processingArtifacts.map((item) => item.digest).toSet().length !=
            processingArtifacts.length) {
      throw ArgumentError('AI Tool Result Projection inputs are invalid.');
    }
    final ordered = [...processingArtifacts]
      ..sort((a, b) => a.digest.compareTo(b.digest));
    final capabilityId = ordered.first.capabilityId;
    if (ordered.any((item) =>
        item.capabilityId != capabilityId || item.toolId.trim().isEmpty)) {
      throw ArgumentError('AI Tool Result Projection capability is invalid.');
    }
    final results = [
      for (var index = 0; index < ordered.length; index++)
        AIToolResultReferenceContract.fromProcessing(
          position: index + 1,
          processing: ordered[index],
        ),
    ];
    final payload = {
      'schemaVersion': aiToolResultProjectionContractVersion,
      'capabilityId': capabilityId,
      'results': results.map((item) => item.toJson()).toList(),
      'policyVersion': aiToolResultProjectionPolicyVersion,
    };
    final digest = _digest(payload);
    return AIToolResultProjectionContract._(
      id: 'ai-tool-result-projection.${digest.substring(0, 16)}',
      capabilityId: capabilityId,
      results: List.unmodifiable(results),
      digest: digest,
    );
  }

  final String id;
  final String capabilityId;
  final List<AIToolResultReferenceContract> results;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': aiToolResultProjectionContractVersion,
        'id': id,
        'capabilityId': capabilityId,
        'results': results.map((item) => item.toJson()).toList(),
        'policyVersion': aiToolResultProjectionPolicyVersion,
        'digest': digest,
      };
}

class AIToolResultProjector {
  const AIToolResultProjector();

  AIToolResultProjectionContract project(
    List<AIResponseProcessingV2Contract> processingArtifacts,
  ) =>
      AIToolResultProjectionContract.create(processingArtifacts);
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
