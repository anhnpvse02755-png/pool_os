import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/infrastructure/production/deployment_topology_runtime.dart';

const rolloutReadinessRuntimeVersion = 1;
const rolloutReadinessPolicyVersion = 'rollout-readiness-runtime/1.0.0';

enum RolloutStage {
  evidenceAssembly,
  approvalRehearsal,
  boundedTargetPreparation,
  authorizedCandidatePromotion,
  constrainedExposureExpansion,
  hypercare,
  normalOperationsHandover,
}

enum ReadinessGate {
  candidateIdentity,
  architectureTopology,
  functionalContracts,
  operations,
  recoveryDr,
  securityPrivacy,
  performanceCapacity,
  knowledgePublication,
  externalDependencies,
  rollbackRecoveryReadiness,
  productAcceptance,
}

enum CommunicationAudience {
  releaseOwners,
  onCall,
  support,
  securityPrivacy,
  recovery,
  domainOwners,
  productStakeholders,
  affectedUsers,
}

enum HypercareGovernanceItem {
  authorizedEntry,
  dutyCoverage,
  knownRiskRegister,
  observationResponsibility,
  changeConstraints,
  incidentEscalation,
  rollbackAuthority,
  exitCriteria,
}

enum RolloutEvidenceClass {
  candidateManifest,
  gateAttestation,
  knownRiskRegister,
  exceptionRecord,
  decisionRecord,
  promotionRecord,
  rollbackDecision,
  hypercareRecord,
  postReleaseReview,
}

class RolloutReadinessReference {
  const RolloutReadinessReference._({
    required this.category,
    required this.referenceId,
    required this.ownerId,
    required this.evidenceIdentity,
    required this.governanceVersion,
    required this.digest,
  });

  factory RolloutReadinessReference.create({
    required String category,
    required String referenceId,
    required String ownerId,
    required String evidenceIdentity,
    required String governanceVersion,
  }) {
    for (final value in [
      category,
      referenceId,
      ownerId,
      evidenceIdentity,
      governanceVersion,
    ]) {
      if (value.trim().isEmpty || value != value.trim()) {
        throw ArgumentError('Rollout reference is not canonical.');
      }
    }
    final payload = {
      'category': category,
      'referenceId': referenceId,
      'ownerId': ownerId,
      'evidenceIdentity': evidenceIdentity,
      'governanceVersion': governanceVersion,
    };
    return RolloutReadinessReference._(
      category: category,
      referenceId: referenceId,
      ownerId: ownerId,
      evidenceIdentity: evidenceIdentity,
      governanceVersion: governanceVersion,
      digest: _digest(payload),
    );
  }

  final String category;
  final String referenceId;
  final String ownerId;
  final String evidenceIdentity;
  final String governanceVersion;
  final String digest;

  Map<String, dynamic> toJson() => {
        'category': category,
        'referenceId': referenceId,
        'ownerId': ownerId,
        'evidenceIdentity': evidenceIdentity,
        'governanceVersion': governanceVersion,
        'digest': digest,
      };
}

class RolloutReadinessRequest {
  RolloutReadinessRequest._({
    required this.rolloutId,
    required this.rolloutVersion,
    required this.topologyId,
    required this.topologyDigest,
    required this.artifactIdentityDigest,
    required List<RolloutReadinessReference> stages,
    required List<RolloutReadinessReference> gates,
    required List<RolloutReadinessReference> communications,
    required List<RolloutReadinessReference> hypercare,
    required List<RolloutReadinessReference> evidenceReferences,
    required this.provenanceDigest,
    required this.digest,
  })  : stages = List.unmodifiable(stages),
        gates = List.unmodifiable(gates),
        communications = List.unmodifiable(communications),
        hypercare = List.unmodifiable(hypercare),
        evidenceReferences = List.unmodifiable(evidenceReferences);

  factory RolloutReadinessRequest.create({
    required String rolloutId,
    required String rolloutVersion,
    required DeploymentTopologyRecord topology,
    required Iterable<RolloutReadinessReference> stages,
    required Iterable<RolloutReadinessReference> gates,
    required Iterable<RolloutReadinessReference> communications,
    required Iterable<RolloutReadinessReference> hypercare,
    required Iterable<RolloutReadinessReference> evidenceReferences,
  }) {
    _requireValue(rolloutId, 'Rollout ID');
    _requireValue(rolloutVersion, 'Rollout version');
    _requireValue(topology.id, 'Topology ID');
    _requireValue(topology.digest, 'Topology digest');
    _requireValue(topology.artifactIdentityDigest, 'Artifact identity digest');
    final stageItems = _canonicalize(stages, [
      for (final item in RolloutStage.values) 'stage.${item.name}',
    ]);
    final gateItems = _canonicalize(gates, [
      for (final item in ReadinessGate.values) 'gate.${item.name}',
    ]);
    final communicationItems = _canonicalize(communications, [
      for (final item in CommunicationAudience.values)
        'communication.${item.name}',
    ]);
    final hypercareItems = _canonicalize(hypercare, [
      for (final item in HypercareGovernanceItem.values)
        'hypercare.${item.name}',
    ]);
    final evidenceItems = _canonicalize(evidenceReferences, [
      for (final item in RolloutEvidenceClass.values) 'evidence.${item.name}',
    ]);
    final provenancePayload = {
      'topologyDigest': topology.digest,
      'artifactIdentityDigest': topology.artifactIdentityDigest,
      'stages': stageItems.map((item) => item.toJson()).toList(),
      'gates': gateItems.map((item) => item.toJson()).toList(),
      'communications':
          communicationItems.map((item) => item.toJson()).toList(),
      'hypercare': hypercareItems.map((item) => item.toJson()).toList(),
      'evidenceReferences': evidenceItems.map((item) => item.toJson()).toList(),
    };
    final provenanceDigest = _digest(provenancePayload);
    final payload = {
      'version': rolloutReadinessRuntimeVersion,
      'policyVersion': rolloutReadinessPolicyVersion,
      'rolloutId': rolloutId,
      'rolloutVersion': rolloutVersion,
      'topologyId': topology.id,
      ...provenancePayload,
      'provenanceDigest': provenanceDigest,
    };
    return RolloutReadinessRequest._(
      rolloutId: rolloutId,
      rolloutVersion: rolloutVersion,
      topologyId: topology.id,
      topologyDigest: topology.digest,
      artifactIdentityDigest: topology.artifactIdentityDigest,
      stages: stageItems,
      gates: gateItems,
      communications: communicationItems,
      hypercare: hypercareItems,
      evidenceReferences: evidenceItems,
      provenanceDigest: provenanceDigest,
      digest: _digest(payload),
    );
  }

  final String rolloutId;
  final String rolloutVersion;
  final String topologyId;
  final String topologyDigest;
  final String artifactIdentityDigest;
  final List<RolloutReadinessReference> stages;
  final List<RolloutReadinessReference> gates;
  final List<RolloutReadinessReference> communications;
  final List<RolloutReadinessReference> hypercare;
  final List<RolloutReadinessReference> evidenceReferences;
  final String provenanceDigest;
  final String digest;
}

class RolloutReadinessAuthorization {
  const RolloutReadinessAuthorization._({
    required this.requestDigest,
    required this.topologyDigest,
    required this.provenanceDigest,
    required this.digest,
  });

  factory RolloutReadinessAuthorization.create(
      RolloutReadinessRequest request) {
    final payload = {
      'version': rolloutReadinessRuntimeVersion,
      'requestDigest': request.digest,
      'topologyDigest': request.topologyDigest,
      'provenanceDigest': request.provenanceDigest,
    };
    return RolloutReadinessAuthorization._(
      requestDigest: request.digest,
      topologyDigest: request.topologyDigest,
      provenanceDigest: request.provenanceDigest,
      digest: _digest(payload),
    );
  }

  final String requestDigest;
  final String topologyDigest;
  final String provenanceDigest;
  final String digest;
}

class RolloutReadinessRecord {
  RolloutReadinessRecord._({
    required this.id,
    required this.rolloutVersion,
    required this.topologyId,
    required this.topologyDigest,
    required this.artifactIdentityDigest,
    required List<RolloutReadinessReference> stages,
    required List<RolloutReadinessReference> gates,
    required List<RolloutReadinessReference> communications,
    required List<RolloutReadinessReference> hypercare,
    required List<RolloutReadinessReference> evidenceReferences,
    required this.requestDigest,
    required this.authorizationDigest,
    required this.provenanceDigest,
    required this.digest,
  })  : stages = List.unmodifiable(stages),
        gates = List.unmodifiable(gates),
        communications = List.unmodifiable(communications),
        hypercare = List.unmodifiable(hypercare),
        evidenceReferences = List.unmodifiable(evidenceReferences);

  final String id;
  final String rolloutVersion;
  final String topologyId;
  final String topologyDigest;
  final String artifactIdentityDigest;
  final List<RolloutReadinessReference> stages;
  final List<RolloutReadinessReference> gates;
  final List<RolloutReadinessReference> communications;
  final List<RolloutReadinessReference> hypercare;
  final List<RolloutReadinessReference> evidenceReferences;
  final String requestDigest;
  final String authorizationDigest;
  final String provenanceDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'version': rolloutReadinessRuntimeVersion,
        'policyVersion': rolloutReadinessPolicyVersion,
        'id': id,
        'rolloutVersion': rolloutVersion,
        'topologyId': topologyId,
        'topologyDigest': topologyDigest,
        'artifactIdentityDigest': artifactIdentityDigest,
        'stages': stages.map((item) => item.toJson()).toList(),
        'gates': gates.map((item) => item.toJson()).toList(),
        'communications': communications.map((item) => item.toJson()).toList(),
        'hypercare': hypercare.map((item) => item.toJson()).toList(),
        'evidenceReferences':
            evidenceReferences.map((item) => item.toJson()).toList(),
        'requestDigest': requestDigest,
        'authorizationDigest': authorizationDigest,
        'provenanceDigest': provenanceDigest,
        'digest': digest,
      };
}

class RolloutOperationalReadinessRuntime {
  const RolloutOperationalReadinessRuntime();

  RolloutReadinessRecord assemble({
    required RolloutReadinessRequest request,
    required RolloutReadinessAuthorization authorization,
  }) {
    _validateRequest(request);
    final expected = RolloutReadinessAuthorization.create(request);
    if (authorization.requestDigest != expected.requestDigest ||
        authorization.topologyDigest != expected.topologyDigest ||
        authorization.provenanceDigest != expected.provenanceDigest ||
        authorization.digest != expected.digest) {
      throw ArgumentError('Rollout authorization is stale.');
    }
    final payload = {
      'version': rolloutReadinessRuntimeVersion,
      'policyVersion': rolloutReadinessPolicyVersion,
      'rolloutId': request.rolloutId,
      'rolloutVersion': request.rolloutVersion,
      'topologyId': request.topologyId,
      'topologyDigest': request.topologyDigest,
      'artifactIdentityDigest': request.artifactIdentityDigest,
      'stages': request.stages.map((item) => item.toJson()).toList(),
      'gates': request.gates.map((item) => item.toJson()).toList(),
      'communications':
          request.communications.map((item) => item.toJson()).toList(),
      'hypercare': request.hypercare.map((item) => item.toJson()).toList(),
      'evidenceReferences':
          request.evidenceReferences.map((item) => item.toJson()).toList(),
      'requestDigest': request.digest,
      'authorizationDigest': authorization.digest,
      'provenanceDigest': request.provenanceDigest,
    };
    final digest = _digest(payload);
    return RolloutReadinessRecord._(
      id: '${request.rolloutId}.${digest.substring(0, 16)}',
      rolloutVersion: request.rolloutVersion,
      topologyId: request.topologyId,
      topologyDigest: request.topologyDigest,
      artifactIdentityDigest: request.artifactIdentityDigest,
      stages: request.stages,
      gates: request.gates,
      communications: request.communications,
      hypercare: request.hypercare,
      evidenceReferences: request.evidenceReferences,
      requestDigest: request.digest,
      authorizationDigest: authorization.digest,
      provenanceDigest: request.provenanceDigest,
      digest: digest,
    );
  }

  RolloutReadinessRecord replay({
    required RolloutReadinessRequest request,
    required RolloutReadinessAuthorization authorization,
    required RolloutReadinessRecord expected,
  }) {
    final replayed = assemble(request: request, authorization: authorization);
    if (jsonEncode(replayed.toJson()) != jsonEncode(expected.toJson())) {
      throw StateError('Rollout replay does not match.');
    }
    return replayed;
  }
}

List<RolloutReadinessReference> _canonicalize(
  Iterable<RolloutReadinessReference> input,
  List<String> expected,
) {
  final byCategory = <String, RolloutReadinessReference>{};
  final references = <String>{};
  final evidence = <String>{};
  for (final item in input) {
    final canonical = RolloutReadinessReference.create(
      category: item.category,
      referenceId: item.referenceId,
      ownerId: item.ownerId,
      evidenceIdentity: item.evidenceIdentity,
      governanceVersion: item.governanceVersion,
    );
    if (item.digest != canonical.digest ||
        byCategory.containsKey(item.category) ||
        !references.add(item.referenceId) ||
        !evidence.add(item.evidenceIdentity)) {
      throw ArgumentError('Rollout provenance is invalid.');
    }
    byCategory[item.category] = item;
  }
  if (byCategory.length != expected.length ||
      expected.any((category) => !byCategory.containsKey(category))) {
    throw ArgumentError('Rollout catalog coverage is incomplete.');
  }
  return List.unmodifiable(
      [for (final category in expected) byCategory[category]!]);
}

void _validateRequest(RolloutReadinessRequest request) {
  _canonicalize(request.stages, [
    for (final item in RolloutStage.values) 'stage.${item.name}',
  ]);
  _canonicalize(request.gates, [
    for (final item in ReadinessGate.values) 'gate.${item.name}',
  ]);
  _canonicalize(request.communications, [
    for (final item in CommunicationAudience.values)
      'communication.${item.name}',
  ]);
  _canonicalize(request.hypercare, [
    for (final item in HypercareGovernanceItem.values) 'hypercare.${item.name}',
  ]);
  _canonicalize(request.evidenceReferences, [
    for (final item in RolloutEvidenceClass.values) 'evidence.${item.name}',
  ]);
}

void _requireValue(String value, String field) {
  if (value.trim().isEmpty || value != value.trim()) {
    throw ArgumentError('$field must be a non-empty canonical value.');
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
