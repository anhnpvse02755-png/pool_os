import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/infrastructure/production/deployment_topology_runtime.dart';

const readinessFinalGateRuntimeVersion = 1;
const readinessFinalGatePolicyVersion = 'readiness-final-gate-runtime/1.0.0';

enum FinalGateCriterion {
  planningAuthority,
  topologyIdentity,
  operationalReadiness,
  recoveryReadiness,
  securityPrivacyReadiness,
  performanceCapacityReadiness,
  acceptanceLaunchReadiness,
  candidateIntegrity,
  frozenFoundations,
  knowledgePublication,
  domainContractBehavior,
  externalDependencies,
  rollbackRecoveryAuthority,
  evidenceIntegrity,
  productDecision,
}

enum FinalGateSignOffRole {
  releaseManager,
  architecture,
  applicationDomain,
  knowledgeIntegration,
  dataRecovery,
  securityPrivacy,
  operations,
  platform,
  finalReadinessAuditor,
  productOwner,
}

enum ReleaseDecisionMetadata {
  decisionIdentity,
  gateVersion,
  candidateTargetScope,
  evidenceAuditIdentity,
  criterionSummary,
  signOffSummary,
  risksExceptions,
  limitations,
  rollbackRecoveryIdentity,
  communicationHypercareOwners,
  abortGovernance,
  decisionExpiryRationale,
}

enum ExceptionGovernanceMetadata {
  failedRequirement,
  permissibility,
  boundedScopeDuration,
  compensatingGovernance,
  detectionEvidence,
  abortTrigger,
  ownershipApprovers,
  resolutionExpiry,
}

enum FinalGateEvidenceSource {
  releaseIdentity,
  deploymentTopology,
  operations,
  recovery,
  security,
  performanceCapacity,
  rolloutReadiness,
}

class FinalGateGovernanceReference {
  const FinalGateGovernanceReference._({
    required this.category,
    required this.referenceId,
    required this.ownerId,
    required this.evidenceIdentity,
    required this.governanceVersion,
    required this.digest,
  });

  factory FinalGateGovernanceReference.create({
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
        throw ArgumentError('Final-gate reference is not canonical.');
      }
    }
    final payload = {
      'category': category,
      'referenceId': referenceId,
      'ownerId': ownerId,
      'evidenceIdentity': evidenceIdentity,
      'governanceVersion': governanceVersion,
    };
    return FinalGateGovernanceReference._(
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

class ReadinessFinalGateRequest {
  ReadinessFinalGateRequest._({
    required this.gateId,
    required this.gateVersion,
    required this.topologyId,
    required this.topologyDigest,
    required this.artifactIdentityDigest,
    required List<FinalGateGovernanceReference> criteria,
    required List<FinalGateGovernanceReference> signOffSequence,
    required List<FinalGateGovernanceReference> decisionMetadata,
    required List<FinalGateGovernanceReference> exceptionMetadata,
    required List<FinalGateGovernanceReference> evidenceReferences,
    required this.provenanceDigest,
    required this.digest,
  })  : criteria = List.unmodifiable(criteria),
        signOffSequence = List.unmodifiable(signOffSequence),
        decisionMetadata = List.unmodifiable(decisionMetadata),
        exceptionMetadata = List.unmodifiable(exceptionMetadata),
        evidenceReferences = List.unmodifiable(evidenceReferences);

  factory ReadinessFinalGateRequest.create({
    required String gateId,
    required String gateVersion,
    required DeploymentTopologyRecord topology,
    required Iterable<FinalGateGovernanceReference> criteria,
    required Iterable<FinalGateGovernanceReference> signOffSequence,
    required Iterable<FinalGateGovernanceReference> decisionMetadata,
    required Iterable<FinalGateGovernanceReference> exceptionMetadata,
    required Iterable<FinalGateGovernanceReference> evidenceReferences,
  }) {
    _requireValue(gateId, 'Gate ID');
    _requireValue(gateVersion, 'Gate version');
    _requireValue(topology.id, 'Topology ID');
    _requireValue(topology.digest, 'Topology digest');
    _requireValue(topology.artifactIdentityDigest, 'Artifact identity digest');
    final criterionItems = _canonicalize(criteria, [
      for (final item in FinalGateCriterion.values) 'criterion.${item.name}',
    ]);
    final signOffItems = _canonicalize(signOffSequence, [
      for (final item in FinalGateSignOffRole.values) 'signoff.${item.name}',
    ]);
    final decisionItems = _canonicalize(decisionMetadata, [
      for (final item in ReleaseDecisionMetadata.values)
        'decision.${item.name}',
    ]);
    final exceptionItems = _canonicalize(exceptionMetadata, [
      for (final item in ExceptionGovernanceMetadata.values)
        'exception.${item.name}',
    ]);
    final evidenceItems = _canonicalize(evidenceReferences, [
      for (final item in FinalGateEvidenceSource.values)
        'evidence.${item.name}',
    ]);
    final provenancePayload = {
      'topologyDigest': topology.digest,
      'artifactIdentityDigest': topology.artifactIdentityDigest,
      'criteria': criterionItems.map((item) => item.toJson()).toList(),
      'signOffSequence': signOffItems.map((item) => item.toJson()).toList(),
      'decisionMetadata': decisionItems.map((item) => item.toJson()).toList(),
      'exceptionMetadata': exceptionItems.map((item) => item.toJson()).toList(),
      'evidenceReferences': evidenceItems.map((item) => item.toJson()).toList(),
    };
    final provenanceDigest = _digest(provenancePayload);
    final payload = {
      'version': readinessFinalGateRuntimeVersion,
      'policyVersion': readinessFinalGatePolicyVersion,
      'gateId': gateId,
      'gateVersion': gateVersion,
      'topologyId': topology.id,
      ...provenancePayload,
      'provenanceDigest': provenanceDigest,
    };
    return ReadinessFinalGateRequest._(
      gateId: gateId,
      gateVersion: gateVersion,
      topologyId: topology.id,
      topologyDigest: topology.digest,
      artifactIdentityDigest: topology.artifactIdentityDigest,
      criteria: criterionItems,
      signOffSequence: signOffItems,
      decisionMetadata: decisionItems,
      exceptionMetadata: exceptionItems,
      evidenceReferences: evidenceItems,
      provenanceDigest: provenanceDigest,
      digest: _digest(payload),
    );
  }

  final String gateId;
  final String gateVersion;
  final String topologyId;
  final String topologyDigest;
  final String artifactIdentityDigest;
  final List<FinalGateGovernanceReference> criteria;
  final List<FinalGateGovernanceReference> signOffSequence;
  final List<FinalGateGovernanceReference> decisionMetadata;
  final List<FinalGateGovernanceReference> exceptionMetadata;
  final List<FinalGateGovernanceReference> evidenceReferences;
  final String provenanceDigest;
  final String digest;
}

class ReadinessFinalGateAuthorization {
  const ReadinessFinalGateAuthorization._({
    required this.requestDigest,
    required this.topologyDigest,
    required this.provenanceDigest,
    required this.digest,
  });

  factory ReadinessFinalGateAuthorization.create(
    ReadinessFinalGateRequest request,
  ) {
    final payload = {
      'version': readinessFinalGateRuntimeVersion,
      'requestDigest': request.digest,
      'topologyDigest': request.topologyDigest,
      'provenanceDigest': request.provenanceDigest,
    };
    return ReadinessFinalGateAuthorization._(
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

class ReadinessFinalGateRecord {
  ReadinessFinalGateRecord._({
    required this.id,
    required this.gateVersion,
    required this.topologyId,
    required this.topologyDigest,
    required this.artifactIdentityDigest,
    required List<FinalGateGovernanceReference> criteria,
    required List<FinalGateGovernanceReference> signOffSequence,
    required List<FinalGateGovernanceReference> decisionMetadata,
    required List<FinalGateGovernanceReference> exceptionMetadata,
    required List<FinalGateGovernanceReference> evidenceReferences,
    required this.requestDigest,
    required this.authorizationDigest,
    required this.provenanceDigest,
    required this.digest,
  })  : criteria = List.unmodifiable(criteria),
        signOffSequence = List.unmodifiable(signOffSequence),
        decisionMetadata = List.unmodifiable(decisionMetadata),
        exceptionMetadata = List.unmodifiable(exceptionMetadata),
        evidenceReferences = List.unmodifiable(evidenceReferences);

  final String id;
  final String gateVersion;
  final String topologyId;
  final String topologyDigest;
  final String artifactIdentityDigest;
  final List<FinalGateGovernanceReference> criteria;
  final List<FinalGateGovernanceReference> signOffSequence;
  final List<FinalGateGovernanceReference> decisionMetadata;
  final List<FinalGateGovernanceReference> exceptionMetadata;
  final List<FinalGateGovernanceReference> evidenceReferences;
  final String requestDigest;
  final String authorizationDigest;
  final String provenanceDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'version': readinessFinalGateRuntimeVersion,
        'policyVersion': readinessFinalGatePolicyVersion,
        'id': id,
        'gateVersion': gateVersion,
        'topologyId': topologyId,
        'topologyDigest': topologyDigest,
        'artifactIdentityDigest': artifactIdentityDigest,
        'criteria': criteria.map((item) => item.toJson()).toList(),
        'signOffSequence':
            signOffSequence.map((item) => item.toJson()).toList(),
        'decisionMetadata':
            decisionMetadata.map((item) => item.toJson()).toList(),
        'exceptionMetadata':
            exceptionMetadata.map((item) => item.toJson()).toList(),
        'evidenceReferences':
            evidenceReferences.map((item) => item.toJson()).toList(),
        'requestDigest': requestDigest,
        'authorizationDigest': authorizationDigest,
        'provenanceDigest': provenanceDigest,
        'digest': digest,
      };
}

class ReadinessFinalGateRuntime {
  const ReadinessFinalGateRuntime();

  ReadinessFinalGateRecord assemble({
    required ReadinessFinalGateRequest request,
    required ReadinessFinalGateAuthorization authorization,
  }) {
    _validateRequest(request);
    final expected = ReadinessFinalGateAuthorization.create(request);
    if (authorization.requestDigest != expected.requestDigest ||
        authorization.topologyDigest != expected.topologyDigest ||
        authorization.provenanceDigest != expected.provenanceDigest ||
        authorization.digest != expected.digest) {
      throw ArgumentError('Final-gate authorization is stale.');
    }
    final payload = {
      'version': readinessFinalGateRuntimeVersion,
      'policyVersion': readinessFinalGatePolicyVersion,
      'gateId': request.gateId,
      'gateVersion': request.gateVersion,
      'topologyId': request.topologyId,
      'topologyDigest': request.topologyDigest,
      'artifactIdentityDigest': request.artifactIdentityDigest,
      'criteria': request.criteria.map((item) => item.toJson()).toList(),
      'signOffSequence':
          request.signOffSequence.map((item) => item.toJson()).toList(),
      'decisionMetadata':
          request.decisionMetadata.map((item) => item.toJson()).toList(),
      'exceptionMetadata':
          request.exceptionMetadata.map((item) => item.toJson()).toList(),
      'evidenceReferences':
          request.evidenceReferences.map((item) => item.toJson()).toList(),
      'requestDigest': request.digest,
      'authorizationDigest': authorization.digest,
      'provenanceDigest': request.provenanceDigest,
    };
    final digest = _digest(payload);
    return ReadinessFinalGateRecord._(
      id: '${request.gateId}.${digest.substring(0, 16)}',
      gateVersion: request.gateVersion,
      topologyId: request.topologyId,
      topologyDigest: request.topologyDigest,
      artifactIdentityDigest: request.artifactIdentityDigest,
      criteria: request.criteria,
      signOffSequence: request.signOffSequence,
      decisionMetadata: request.decisionMetadata,
      exceptionMetadata: request.exceptionMetadata,
      evidenceReferences: request.evidenceReferences,
      requestDigest: request.digest,
      authorizationDigest: authorization.digest,
      provenanceDigest: request.provenanceDigest,
      digest: digest,
    );
  }

  ReadinessFinalGateRecord replay({
    required ReadinessFinalGateRequest request,
    required ReadinessFinalGateAuthorization authorization,
    required ReadinessFinalGateRecord expected,
  }) {
    final replayed = assemble(request: request, authorization: authorization);
    if (jsonEncode(replayed.toJson()) != jsonEncode(expected.toJson())) {
      throw StateError('Final-gate replay does not match.');
    }
    return replayed;
  }
}

List<FinalGateGovernanceReference> _canonicalize(
  Iterable<FinalGateGovernanceReference> input,
  List<String> expected,
) {
  final byCategory = <String, FinalGateGovernanceReference>{};
  final references = <String>{};
  final evidence = <String>{};
  for (final item in input) {
    final canonical = FinalGateGovernanceReference.create(
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
      throw ArgumentError('Final-gate provenance is invalid.');
    }
    byCategory[item.category] = item;
  }
  if (byCategory.length != expected.length ||
      expected.any((category) => !byCategory.containsKey(category))) {
    throw ArgumentError('Final-gate catalog coverage is incomplete.');
  }
  return List.unmodifiable(
      [for (final category in expected) byCategory[category]!]);
}

void _validateRequest(ReadinessFinalGateRequest request) {
  _canonicalize(request.criteria, [
    for (final item in FinalGateCriterion.values) 'criterion.${item.name}',
  ]);
  _canonicalize(request.signOffSequence, [
    for (final item in FinalGateSignOffRole.values) 'signoff.${item.name}',
  ]);
  _canonicalize(request.decisionMetadata, [
    for (final item in ReleaseDecisionMetadata.values) 'decision.${item.name}',
  ]);
  _canonicalize(request.exceptionMetadata, [
    for (final item in ExceptionGovernanceMetadata.values)
      'exception.${item.name}',
  ]);
  _canonicalize(request.evidenceReferences, [
    for (final item in FinalGateEvidenceSource.values) 'evidence.${item.name}',
  ]);
}

void _requireValue(String value, String field) {
  if (value.trim().isEmpty || value != value.trim()) {
    throw ArgumentError('$field must be a non-empty canonical value.');
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
