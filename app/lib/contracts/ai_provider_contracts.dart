import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/coach_response_contracts.dart';

const aiProviderContractVersion = 1;
const aiProviderPolicyVersion = 'ai-provider/1.0.0';

enum AIProviderInvocationStatus { stubbed }

class AIProviderResult {
  const AIProviderResult._({
    required this.providerId,
    required this.providerContractVersion,
    required this.requestDigest,
    required this.status,
    required this.digest,
  });

  factory AIProviderResult.create({
    required String providerId,
    required String providerContractVersion,
    required CoachAIRequestEnvelope request,
    required AIProviderInvocationStatus status,
  }) {
    if (providerId.trim().isEmpty || providerContractVersion.trim().isEmpty) {
      throw ArgumentError('AI provider identity must not be empty.');
    }
    if (request.providerId != providerId ||
        request.providerContractVersion != providerContractVersion) {
      throw ArgumentError('AI provider request binding is incompatible.');
    }
    final payload = {
      'schemaVersion': aiProviderContractVersion,
      'providerId': providerId,
      'providerContractVersion': providerContractVersion,
      'requestDigest': request.digest,
      'status': status.name,
      'policyVersion': aiProviderPolicyVersion,
    };
    final digest = _digest(payload);
    return AIProviderResult._(
      providerId: providerId,
      providerContractVersion: providerContractVersion,
      requestDigest: request.digest,
      status: status,
      digest: digest,
    );
  }

  final String providerId;
  final String providerContractVersion;
  final String requestDigest;
  final AIProviderInvocationStatus status;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': aiProviderContractVersion,
        'providerId': providerId,
        'providerContractVersion': providerContractVersion,
        'requestDigest': requestDigest,
        'status': status.name,
        'policyVersion': aiProviderPolicyVersion,
        'digest': digest,
      };
}

abstract class AIProvider {
  String get providerId;

  String get providerContractVersion;

  AIProviderResult invoke(CoachAIRequestEnvelope request);
}

class DeterministicStubAIProvider implements AIProvider {
  const DeterministicStubAIProvider({
    this.providerId = 'stub/deterministic',
    this.providerContractVersion = 'stub-provider/1.0.0',
  });

  @override
  final String providerId;

  @override
  final String providerContractVersion;

  @override
  AIProviderResult invoke(CoachAIRequestEnvelope request) =>
      AIProviderResult.create(
        providerId: providerId,
        providerContractVersion: providerContractVersion,
        request: request,
        status: AIProviderInvocationStatus.stubbed,
      );
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
