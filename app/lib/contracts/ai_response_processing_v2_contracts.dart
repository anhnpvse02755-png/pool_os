import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/ai_provider_contracts.dart';
import 'package:pool_os/contracts/ai_provider_request_v2_contracts.dart';
import 'package:pool_os/contracts/ai_response_processing_contracts.dart';

const aiResponseProcessingV2ContractVersion = 2;
const aiResponseProcessingV2PolicyVersion = 'ai-response-processing/2.0.0';

class AIResponseProcessingV2Contract {
  const AIResponseProcessingV2Contract._({
    required this.id,
    required this.baseProcessing,
    required this.toolId,
    required this.digest,
  });

  factory AIResponseProcessingV2Contract.create({
    required AIProviderRequestV2Contract request,
    required AIProviderResult result,
  }) {
    final baseProcessing = const AIResponseProcessor().process(
      request: request.baseRequest,
      result: result,
    );
    final payload = {
      'schemaVersion': aiResponseProcessingV2ContractVersion,
      'baseProcessing': baseProcessing.toJson(),
      'toolId': request.toolId,
      'policyVersion': aiResponseProcessingV2PolicyVersion,
    };
    final digest = _digest(payload);
    return AIResponseProcessingV2Contract._(
      id: 'ai-response-processing-v2.${digest.substring(0, 16)}',
      baseProcessing: baseProcessing,
      toolId: request.toolId,
      digest: digest,
    );
  }

  final String id;
  final AIResponseProcessingContract baseProcessing;
  final String toolId;
  final String digest;

  String get capabilityId => baseProcessing.capabilityId;
  String get processingDigest => baseProcessing.processingDigest;
  String get providerPayloadDigest => baseProcessing.providerPayloadDigest;
  String get providerRequestDigest => baseProcessing.providerRequestDigest;
  String get providerResultDigest => baseProcessing.providerResultDigest;
  Map<String, String> get processingMetadata =>
      baseProcessing.processingMetadata;

  Map<String, dynamic> toJson() => {
        'schemaVersion': aiResponseProcessingV2ContractVersion,
        'id': id,
        'baseProcessing': baseProcessing.toJson(),
        'toolId': toolId,
        'policyVersion': aiResponseProcessingV2PolicyVersion,
        'digest': digest,
      };
}

class AIResponseProcessorV2 {
  const AIResponseProcessorV2();

  AIResponseProcessingV2Contract process({
    required AIProviderRequestV2Contract request,
    required AIProviderResult result,
  }) =>
      AIResponseProcessingV2Contract.create(request: request, result: result);
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
