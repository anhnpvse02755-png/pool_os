import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/ai_provider_contracts.dart';
import 'package:pool_os/contracts/ai_provider_request_contracts.dart';

const aiResponseProcessingContractVersion = 1;
const aiResponseProcessingPolicyVersion = 'ai-response-processing/1.0.0';

class AIResponseProcessingContract {
  const AIResponseProcessingContract._({
    required this.id,
    required this.providerPayloadDigest,
    required this.providerRequestDigest,
    required this.providerResultDigest,
    required this.capabilityId,
    required this.processingMetadata,
    required this.processingDigest,
  });

  factory AIResponseProcessingContract.create({
    required String providerPayloadDigest,
    required String providerRequestDigest,
    required String providerResultDigest,
    required String capabilityId,
    required Map<String, String> processingMetadata,
  }) {
    if (providerPayloadDigest.trim().isEmpty ||
        providerRequestDigest.trim().isEmpty ||
        providerResultDigest.trim().isEmpty ||
        capabilityId.trim().isEmpty ||
        processingMetadata.isEmpty ||
        processingMetadata.keys.any((key) => key.trim().isEmpty) ||
        processingMetadata.values.any(
          (value) => value.trim().isEmpty || value.contains('\n'),
        )) {
      throw ArgumentError('AI Response Processing metadata is invalid.');
    }
    final orderedMetadata = <String, String>{
      for (final key in processingMetadata.keys.toList()..sort())
        key: processingMetadata[key]!,
    };
    final payload = {
      'schemaVersion': aiResponseProcessingContractVersion,
      'providerPayloadDigest': providerPayloadDigest,
      'providerRequestDigest': providerRequestDigest,
      'providerResultDigest': providerResultDigest,
      'capabilityId': capabilityId,
      'processingMetadata': orderedMetadata,
      'policyVersion': aiResponseProcessingPolicyVersion,
    };
    final processingDigest = _digest(payload);
    return AIResponseProcessingContract._(
      id: 'ai-response-processing.${processingDigest.substring(0, 16)}',
      providerPayloadDigest: providerPayloadDigest,
      providerRequestDigest: providerRequestDigest,
      providerResultDigest: providerResultDigest,
      capabilityId: capabilityId,
      processingMetadata: Map.unmodifiable(orderedMetadata),
      processingDigest: processingDigest,
    );
  }

  final String id;
  final String providerPayloadDigest;
  final String providerRequestDigest;
  final String providerResultDigest;
  final String capabilityId;
  final Map<String, String> processingMetadata;
  final String processingDigest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': aiResponseProcessingContractVersion,
        'id': id,
        'providerPayloadDigest': providerPayloadDigest,
        'providerRequestDigest': providerRequestDigest,
        'providerResultDigest': providerResultDigest,
        'capabilityId': capabilityId,
        'processingMetadata': processingMetadata,
        'policyVersion': aiResponseProcessingPolicyVersion,
        'processingDigest': processingDigest,
      };
}

class AIResponseProcessor {
  const AIResponseProcessor();

  AIResponseProcessingContract process({
    required AIProviderRequestContract request,
    required AIProviderResult result,
  }) {
    final payload = request.providerPayload;
    if (result.requestDigest != request.providerPayloadDigest ||
        request.providerPayloadDigest != payload.digest ||
        result.providerId != payload.providerId ||
        result.providerContractVersion != payload.providerContractVersion ||
        result.status != AIProviderInvocationStatus.stubbed) {
      throw ArgumentError('AI Provider Result provenance is incompatible.');
    }
    return AIResponseProcessingContract.create(
      providerPayloadDigest: request.providerPayloadDigest,
      providerRequestDigest: request.providerRequestDigest,
      providerResultDigest: result.digest,
      capabilityId: request.capabilityId,
      processingMetadata: {
        'providerContractVersion': result.providerContractVersion,
        'providerId': result.providerId,
        'status': result.status.name,
      },
    );
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
