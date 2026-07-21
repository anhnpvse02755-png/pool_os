import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/ai_capability_registry_contracts.dart';
import 'package:pool_os/contracts/ai_session_contracts.dart';
import 'package:pool_os/contracts/coach_adaptation_projection_contracts.dart';

const aiRuntimeActivationGateContractVersion = 1;
const aiRuntimeActivationGatePolicyVersion = 'ai-runtime-activation-gate/1.0.0';

enum AIRuntimeActivationDecision { activated, notActivated }

enum AIRuntimeActivationReason {
  activated,
  invalidSession,
  staleContext,
  contractMismatch,
  capabilityUnavailable,
  mixedPlayer,
  brokenProvenance,
  duplicateActivation,
}

class AIRuntimeActivationGateContract {
  const AIRuntimeActivationGateContract._({
    required this.id,
    required this.decision,
    required this.reason,
    required this.sessionDigest,
    required this.adaptationDigest,
    required this.registryDigest,
    required this.capabilityId,
    required this.activationKey,
    required this.digest,
  });

  factory AIRuntimeActivationGateContract.create({
    required AIRuntimeActivationDecision decision,
    required AIRuntimeActivationReason reason,
    required String sessionDigest,
    required String adaptationDigest,
    required String registryDigest,
    required String capabilityId,
    required String activationKey,
  }) {
    final values = {
      'sessionDigest': sessionDigest,
      'adaptationDigest': adaptationDigest,
      'registryDigest': registryDigest,
      'capabilityId': capabilityId,
      'activationKey': activationKey,
    };
    if (values.values.any((value) => value.trim().isEmpty)) {
      throw ArgumentError('AI Runtime Activation provenance is invalid.');
    }
    if ((decision == AIRuntimeActivationDecision.activated) !=
        (reason == AIRuntimeActivationReason.activated)) {
      throw ArgumentError(
          'AI Runtime Activation decision and reason disagree.');
    }
    final payload = {
      'schemaVersion': aiRuntimeActivationGateContractVersion,
      'decision': decision.name,
      'reason': reason.name,
      'sessionDigest': sessionDigest,
      'adaptationDigest': adaptationDigest,
      'registryDigest': registryDigest,
      'capabilityId': capabilityId,
      'activationKey': activationKey,
      'policyVersion': aiRuntimeActivationGatePolicyVersion,
    };
    final digest = _digest(payload);
    return AIRuntimeActivationGateContract._(
      id: 'ai-runtime-activation.${digest.substring(0, 16)}',
      decision: decision,
      reason: reason,
      sessionDigest: sessionDigest,
      adaptationDigest: adaptationDigest,
      registryDigest: registryDigest,
      capabilityId: capabilityId,
      activationKey: activationKey,
      digest: digest,
    );
  }

  final String id;
  final AIRuntimeActivationDecision decision;
  final AIRuntimeActivationReason reason;
  final String sessionDigest;
  final String adaptationDigest;
  final String registryDigest;
  final String capabilityId;
  final String activationKey;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': aiRuntimeActivationGateContractVersion,
        'id': id,
        'decision': decision.name,
        'reason': reason.name,
        'sessionDigest': sessionDigest,
        'adaptationDigest': adaptationDigest,
        'registryDigest': registryDigest,
        'capabilityId': capabilityId,
        'activationKey': activationKey,
        'policyVersion': aiRuntimeActivationGatePolicyVersion,
        'digest': digest,
      };
}

class AIRuntimeActivationGate {
  const AIRuntimeActivationGate();

  AIRuntimeActivationGateContract evaluate({
    required AISessionContract session,
    required CoachAdaptationProjectionContract adaptation,
    required AICapabilityRegistryContract registry,
    required String capabilityId,
    List<String> priorActivationKeys = const [],
  }) {
    final key = _activationKey(
      session: session,
      adaptation: adaptation,
      registry: registry,
      capabilityId: capabilityId,
    );
    if (priorActivationKeys.contains(key)) {
      return _notActivated(
        session: session,
        adaptation: adaptation,
        registry: registry,
        capabilityId: capabilityId,
        key: key,
        reason: AIRuntimeActivationReason.duplicateActivation,
      );
    }
    if (session.digest.trim().isEmpty || session.contextDigest.trim().isEmpty) {
      return _notActivated(
        session: session,
        adaptation: adaptation,
        registry: registry,
        capabilityId: capabilityId,
        key: key,
        reason: AIRuntimeActivationReason.invalidSession,
      );
    }
    if (session.contextDigest != adaptation.contextDigest) {
      return _notActivated(
        session: session,
        adaptation: adaptation,
        registry: registry,
        capabilityId: capabilityId,
        key: key,
        reason: AIRuntimeActivationReason.staleContext,
      );
    }
    try {
      final binding = registry.resolveForSession(
        session: session,
        capabilityId: capabilityId,
      );
      if (binding.registryDigest != registry.digest) {
        return _notActivated(
          session: session,
          adaptation: adaptation,
          registry: registry,
          capabilityId: capabilityId,
          key: key,
          reason: AIRuntimeActivationReason.brokenProvenance,
        );
      }
    } on StateError {
      return _notActivated(
        session: session,
        adaptation: adaptation,
        registry: registry,
        capabilityId: capabilityId,
        key: key,
        reason: AIRuntimeActivationReason.capabilityUnavailable,
      );
    } on ArgumentError {
      return _notActivated(
        session: session,
        adaptation: adaptation,
        registry: registry,
        capabilityId: capabilityId,
        key: key,
        reason: AIRuntimeActivationReason.contractMismatch,
      );
    }
    return AIRuntimeActivationGateContract.create(
      decision: AIRuntimeActivationDecision.activated,
      reason: AIRuntimeActivationReason.activated,
      sessionDigest: session.digest,
      adaptationDigest: adaptation.digest,
      registryDigest: registry.digest,
      capabilityId: capabilityId,
      activationKey: key,
    );
  }

  AIRuntimeActivationGateContract _notActivated({
    required AISessionContract session,
    required CoachAdaptationProjectionContract adaptation,
    required AICapabilityRegistryContract registry,
    required String capabilityId,
    required String key,
    required AIRuntimeActivationReason reason,
  }) =>
      AIRuntimeActivationGateContract.create(
        decision: AIRuntimeActivationDecision.notActivated,
        reason: reason,
        sessionDigest: session.digest,
        adaptationDigest: adaptation.digest,
        registryDigest: registry.digest,
        capabilityId: capabilityId,
        activationKey: key,
      );
}

String _activationKey({
  required AISessionContract session,
  required CoachAdaptationProjectionContract adaptation,
  required AICapabilityRegistryContract registry,
  required String capabilityId,
}) =>
    '${session.digest}|${adaptation.digest}|${registry.digest}|$capabilityId';

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
