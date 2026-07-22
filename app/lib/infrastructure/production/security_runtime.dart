import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/infrastructure/production/deployment_topology_runtime.dart';

const securityRuntimeVersion = 1;
const securityRuntimePolicyVersion = 'security-runtime/1.0.0';

enum SecurityIdentityClass {
  userClient,
  humanOperator,
  applicationWorkload,
  infrastructureWorkload,
  releaseBuild,
  externalProvider,
  recoveryProcess,
  auditEvidenceReader,
}

enum SecurityAuthorizationDomain {
  productCommandQuery,
  evidenceHistory,
  knowledgeAuthoringPublication,
  runtimeConfiguration,
  secretKeyCertificateAdministration,
  operationalSecurityEvidence,
  recoveryResource,
  aiProviderCapability,
}

enum SecurityCustodyMetadataClass { secret, key, certificate }

enum SecurityDataClassification { public, internal, confidential, restricted }

enum SecurityEvidenceClass {
  identityLifecycle,
  authenticationDecision,
  authorizationDecision,
  privilegedSession,
  custodyLifecycle,
  dataBoundaryAssessment,
  securityTestRehearsal,
  incidentException,
  complianceMapping,
}

class SecurityGovernanceReference {
  const SecurityGovernanceReference._({
    required this.category,
    required this.referenceId,
    required this.ownerId,
    required this.evidenceIdentity,
    required this.policyVersion,
    required this.digest,
  });

  factory SecurityGovernanceReference.create({
    required String category,
    required String referenceId,
    required String ownerId,
    required String evidenceIdentity,
    required String policyVersion,
  }) {
    for (final value in [
      category,
      referenceId,
      ownerId,
      evidenceIdentity,
      policyVersion,
    ]) {
      if (value.trim().isEmpty || value != value.trim()) {
        throw ArgumentError('Security reference is not canonical.');
      }
    }
    final payload = {
      'category': category,
      'referenceId': referenceId,
      'ownerId': ownerId,
      'evidenceIdentity': evidenceIdentity,
      'policyVersion': policyVersion,
    };
    return SecurityGovernanceReference._(
      category: category,
      referenceId: referenceId,
      ownerId: ownerId,
      evidenceIdentity: evidenceIdentity,
      policyVersion: policyVersion,
      digest: _digest(payload),
    );
  }

  final String category;
  final String referenceId;
  final String ownerId;
  final String evidenceIdentity;
  final String policyVersion;
  final String digest;

  Map<String, dynamic> toJson() => {
        'category': category,
        'referenceId': referenceId,
        'ownerId': ownerId,
        'evidenceIdentity': evidenceIdentity,
        'policyVersion': policyVersion,
        'digest': digest,
      };
}

class SecurityRuntimeRequest {
  SecurityRuntimeRequest._({
    required this.securityId,
    required this.securityVersion,
    required this.topologyId,
    required this.topologyDigest,
    required this.artifactIdentityDigest,
    required List<SecurityGovernanceReference> identityClasses,
    required List<SecurityGovernanceReference> authorizationDomains,
    required List<SecurityGovernanceReference> custodyMetadata,
    required List<SecurityGovernanceReference> dataClassifications,
    required List<SecurityGovernanceReference> evidenceReferences,
    required this.provenanceDigest,
    required this.digest,
  })  : identityClasses = List.unmodifiable(identityClasses),
        authorizationDomains = List.unmodifiable(authorizationDomains),
        custodyMetadata = List.unmodifiable(custodyMetadata),
        dataClassifications = List.unmodifiable(dataClassifications),
        evidenceReferences = List.unmodifiable(evidenceReferences);

  factory SecurityRuntimeRequest.create({
    required String securityId,
    required String securityVersion,
    required DeploymentTopologyRecord topology,
    required Iterable<SecurityGovernanceReference> identityClasses,
    required Iterable<SecurityGovernanceReference> authorizationDomains,
    required Iterable<SecurityGovernanceReference> custodyMetadata,
    required Iterable<SecurityGovernanceReference> dataClassifications,
    required Iterable<SecurityGovernanceReference> evidenceReferences,
  }) {
    _requireValue(securityId, 'Security ID');
    _requireValue(securityVersion, 'Security version');
    _requireValue(topology.id, 'Topology ID');
    _requireValue(topology.digest, 'Topology digest');
    _requireValue(topology.artifactIdentityDigest, 'Artifact identity digest');
    final identities = _canonicalize(identityClasses, [
      for (final item in SecurityIdentityClass.values) 'identity.${item.name}',
    ]);
    final domains = _canonicalize(authorizationDomains, [
      for (final item in SecurityAuthorizationDomain.values)
        'authorization.${item.name}',
    ]);
    final custody = _canonicalize(custodyMetadata, [
      for (final item in SecurityCustodyMetadataClass.values)
        'custody.${item.name}',
    ]);
    final classifications = _canonicalize(dataClassifications, [
      for (final item in SecurityDataClassification.values)
        'classification.${item.name}',
    ]);
    final evidence = _canonicalize(evidenceReferences, [
      for (final item in SecurityEvidenceClass.values) 'evidence.${item.name}',
    ]);
    final provenancePayload = {
      'topologyDigest': topology.digest,
      'artifactIdentityDigest': topology.artifactIdentityDigest,
      'identityClasses': identities.map((item) => item.toJson()).toList(),
      'authorizationDomains': domains.map((item) => item.toJson()).toList(),
      'custodyMetadata': custody.map((item) => item.toJson()).toList(),
      'dataClassifications':
          classifications.map((item) => item.toJson()).toList(),
      'evidenceReferences': evidence.map((item) => item.toJson()).toList(),
    };
    final provenanceDigest = _digest(provenancePayload);
    final payload = {
      'version': securityRuntimeVersion,
      'policyVersion': securityRuntimePolicyVersion,
      'securityId': securityId,
      'securityVersion': securityVersion,
      'topologyId': topology.id,
      'topologyDigest': topology.digest,
      'artifactIdentityDigest': topology.artifactIdentityDigest,
      ...provenancePayload,
      'provenanceDigest': provenanceDigest,
    };
    return SecurityRuntimeRequest._(
      securityId: securityId,
      securityVersion: securityVersion,
      topologyId: topology.id,
      topologyDigest: topology.digest,
      artifactIdentityDigest: topology.artifactIdentityDigest,
      identityClasses: identities,
      authorizationDomains: domains,
      custodyMetadata: custody,
      dataClassifications: classifications,
      evidenceReferences: evidence,
      provenanceDigest: provenanceDigest,
      digest: _digest(payload),
    );
  }

  final String securityId;
  final String securityVersion;
  final String topologyId;
  final String topologyDigest;
  final String artifactIdentityDigest;
  final List<SecurityGovernanceReference> identityClasses;
  final List<SecurityGovernanceReference> authorizationDomains;
  final List<SecurityGovernanceReference> custodyMetadata;
  final List<SecurityGovernanceReference> dataClassifications;
  final List<SecurityGovernanceReference> evidenceReferences;
  final String provenanceDigest;
  final String digest;
}

class SecurityRuntimeAuthorization {
  const SecurityRuntimeAuthorization._({
    required this.requestDigest,
    required this.topologyDigest,
    required this.provenanceDigest,
    required this.digest,
  });

  factory SecurityRuntimeAuthorization.create(SecurityRuntimeRequest request) {
    final payload = {
      'version': securityRuntimeVersion,
      'requestDigest': request.digest,
      'topologyDigest': request.topologyDigest,
      'provenanceDigest': request.provenanceDigest,
    };
    return SecurityRuntimeAuthorization._(
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

class SecurityRuntimeRecord {
  SecurityRuntimeRecord._({
    required this.id,
    required this.securityVersion,
    required this.topologyId,
    required this.topologyDigest,
    required this.artifactIdentityDigest,
    required List<SecurityGovernanceReference> identityClasses,
    required List<SecurityGovernanceReference> authorizationDomains,
    required List<SecurityGovernanceReference> custodyMetadata,
    required List<SecurityGovernanceReference> dataClassifications,
    required List<SecurityGovernanceReference> evidenceReferences,
    required this.requestDigest,
    required this.authorizationDigest,
    required this.provenanceDigest,
    required this.digest,
  })  : identityClasses = List.unmodifiable(identityClasses),
        authorizationDomains = List.unmodifiable(authorizationDomains),
        custodyMetadata = List.unmodifiable(custodyMetadata),
        dataClassifications = List.unmodifiable(dataClassifications),
        evidenceReferences = List.unmodifiable(evidenceReferences);

  final String id;
  final String securityVersion;
  final String topologyId;
  final String topologyDigest;
  final String artifactIdentityDigest;
  final List<SecurityGovernanceReference> identityClasses;
  final List<SecurityGovernanceReference> authorizationDomains;
  final List<SecurityGovernanceReference> custodyMetadata;
  final List<SecurityGovernanceReference> dataClassifications;
  final List<SecurityGovernanceReference> evidenceReferences;
  final String requestDigest;
  final String authorizationDigest;
  final String provenanceDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'version': securityRuntimeVersion,
        'policyVersion': securityRuntimePolicyVersion,
        'id': id,
        'securityVersion': securityVersion,
        'topologyId': topologyId,
        'topologyDigest': topologyDigest,
        'artifactIdentityDigest': artifactIdentityDigest,
        'identityClasses':
            identityClasses.map((item) => item.toJson()).toList(),
        'authorizationDomains':
            authorizationDomains.map((item) => item.toJson()).toList(),
        'custodyMetadata':
            custodyMetadata.map((item) => item.toJson()).toList(),
        'dataClassifications':
            dataClassifications.map((item) => item.toJson()).toList(),
        'evidenceReferences':
            evidenceReferences.map((item) => item.toJson()).toList(),
        'requestDigest': requestDigest,
        'authorizationDigest': authorizationDigest,
        'provenanceDigest': provenanceDigest,
        'digest': digest,
      };
}

class SecurityRuntime {
  const SecurityRuntime();

  SecurityRuntimeRecord assemble({
    required SecurityRuntimeRequest request,
    required SecurityRuntimeAuthorization authorization,
  }) {
    _validateRequest(request);
    final expected = SecurityRuntimeAuthorization.create(request);
    if (authorization.requestDigest != expected.requestDigest ||
        authorization.topologyDigest != expected.topologyDigest ||
        authorization.provenanceDigest != expected.provenanceDigest ||
        authorization.digest != expected.digest) {
      throw ArgumentError('Security authorization is stale.');
    }
    final payload = {
      'version': securityRuntimeVersion,
      'policyVersion': securityRuntimePolicyVersion,
      'securityId': request.securityId,
      'securityVersion': request.securityVersion,
      'topologyId': request.topologyId,
      'topologyDigest': request.topologyDigest,
      'artifactIdentityDigest': request.artifactIdentityDigest,
      'identityClasses':
          request.identityClasses.map((item) => item.toJson()).toList(),
      'authorizationDomains':
          request.authorizationDomains.map((item) => item.toJson()).toList(),
      'custodyMetadata':
          request.custodyMetadata.map((item) => item.toJson()).toList(),
      'dataClassifications':
          request.dataClassifications.map((item) => item.toJson()).toList(),
      'evidenceReferences':
          request.evidenceReferences.map((item) => item.toJson()).toList(),
      'requestDigest': request.digest,
      'authorizationDigest': authorization.digest,
      'provenanceDigest': request.provenanceDigest,
    };
    final digest = _digest(payload);
    return SecurityRuntimeRecord._(
      id: '${request.securityId}.${digest.substring(0, 16)}',
      securityVersion: request.securityVersion,
      topologyId: request.topologyId,
      topologyDigest: request.topologyDigest,
      artifactIdentityDigest: request.artifactIdentityDigest,
      identityClasses: request.identityClasses,
      authorizationDomains: request.authorizationDomains,
      custodyMetadata: request.custodyMetadata,
      dataClassifications: request.dataClassifications,
      evidenceReferences: request.evidenceReferences,
      requestDigest: request.digest,
      authorizationDigest: authorization.digest,
      provenanceDigest: request.provenanceDigest,
      digest: digest,
    );
  }

  SecurityRuntimeRecord replay({
    required SecurityRuntimeRequest request,
    required SecurityRuntimeAuthorization authorization,
    required SecurityRuntimeRecord expected,
  }) {
    final replayed = assemble(request: request, authorization: authorization);
    if (jsonEncode(replayed.toJson()) != jsonEncode(expected.toJson())) {
      throw StateError('Security replay does not match.');
    }
    return replayed;
  }
}

List<SecurityGovernanceReference> _canonicalize(
  Iterable<SecurityGovernanceReference> input,
  List<String> expected,
) {
  final byCategory = <String, SecurityGovernanceReference>{};
  final references = <String>{};
  final evidence = <String>{};
  for (final item in input) {
    final canonical = SecurityGovernanceReference.create(
      category: item.category,
      referenceId: item.referenceId,
      ownerId: item.ownerId,
      evidenceIdentity: item.evidenceIdentity,
      policyVersion: item.policyVersion,
    );
    if (item.digest != canonical.digest ||
        byCategory.containsKey(item.category) ||
        !references.add(item.referenceId) ||
        !evidence.add(item.evidenceIdentity)) {
      throw ArgumentError('Security provenance is invalid.');
    }
    byCategory[item.category] = item;
  }
  if (byCategory.length != expected.length ||
      expected.any((category) => !byCategory.containsKey(category))) {
    throw ArgumentError('Security catalog coverage is incomplete.');
  }
  return List.unmodifiable(
      [for (final category in expected) byCategory[category]!]);
}

void _validateRequest(SecurityRuntimeRequest request) {
  _canonicalize(request.identityClasses, [
    for (final item in SecurityIdentityClass.values) 'identity.${item.name}',
  ]);
  _canonicalize(request.authorizationDomains, [
    for (final item in SecurityAuthorizationDomain.values)
      'authorization.${item.name}',
  ]);
  _canonicalize(request.custodyMetadata, [
    for (final item in SecurityCustodyMetadataClass.values)
      'custody.${item.name}',
  ]);
  _canonicalize(request.dataClassifications, [
    for (final item in SecurityDataClassification.values)
      'classification.${item.name}',
  ]);
  _canonicalize(request.evidenceReferences, [
    for (final item in SecurityEvidenceClass.values) 'evidence.${item.name}',
  ]);
}

void _requireValue(String value, String field) {
  if (value.trim().isEmpty || value != value.trim()) {
    throw ArgumentError('$field must be a non-empty canonical value.');
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
