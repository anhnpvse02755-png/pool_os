import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/ai_observability_projection_contracts.dart';
import 'package:pool_os/contracts/ai_runtime_activation_gate_contracts.dart';

const aiProductionActivationContractVersion = 1;
const aiProductionActivationPolicyVersion = 'ai-production-activation/1.0.0';

enum AIProductionActivationState { activated }

class AIProductionActivationContract {
  const AIProductionActivationContract._({
    required this.id,
    required this.activationKey,
    required this.sessionDigest,
    required this.capabilityId,
    required this.observabilityDigest,
    required this.activationState,
    required this.digest,
  });

  factory AIProductionActivationContract.create({
    required AIRuntimeActivationGateContract gate,
    required AIObservabilityProjectionContract observability,
  }) {
    if (gate.decision != AIRuntimeActivationDecision.activated ||
        gate.reason != AIRuntimeActivationReason.activated ||
        gate.sessionDigest != observability.sessionDigest ||
        gate.capabilityId != observability.capabilityId ||
        gate.activationKey.trim().isEmpty ||
        observability.digest.trim().isEmpty) {
      throw ArgumentError('AI Production Activation provenance is invalid.');
    }
    final payload = {
      'schemaVersion': aiProductionActivationContractVersion,
      'activationKey': gate.activationKey,
      'sessionDigest': gate.sessionDigest,
      'capabilityId': gate.capabilityId,
      'observabilityDigest': observability.digest,
      'activationState': AIProductionActivationState.activated.name,
      'policyVersion': aiProductionActivationPolicyVersion,
    };
    final digest = _digest(payload);
    return AIProductionActivationContract._(
      id: 'ai-production-activation.${digest.substring(0, 16)}',
      activationKey: gate.activationKey,
      sessionDigest: gate.sessionDigest,
      capabilityId: gate.capabilityId,
      observabilityDigest: observability.digest,
      activationState: AIProductionActivationState.activated,
      digest: digest,
    );
  }

  final String id;
  final String activationKey;
  final String sessionDigest;
  final String capabilityId;
  final String observabilityDigest;
  final AIProductionActivationState activationState;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': aiProductionActivationContractVersion,
        'id': id,
        'activationKey': activationKey,
        'sessionDigest': sessionDigest,
        'capabilityId': capabilityId,
        'observabilityDigest': observabilityDigest,
        'activationState': activationState.name,
        'policyVersion': aiProductionActivationPolicyVersion,
        'digest': digest,
      };
}

class AIProductionActivationProjector {
  const AIProductionActivationProjector();

  AIProductionActivationContract project({
    required AIRuntimeActivationGateContract gate,
    required AIObservabilityProjectionContract observability,
  }) =>
      AIProductionActivationContract.create(
        gate: gate,
        observability: observability,
      );
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
