import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/infrastructure/production/release_artifact_identity_runtime.dart';

const deploymentTopologyRuntimeVersion = 1;
const deploymentTopologyPolicyVersion = 'deployment-topology-runtime/1.0.0';

enum DeploymentEnvironmentKind {
  local,
  integration,
  releaseCandidate,
  production,
}

enum DeploymentZoneKind {
  edge,
  applicationRuntime,
  data,
  outboundIntegration,
  operationsControl,
}

enum DeploymentEndpoint {
  approvedClient,
  edge,
  applicationRuntime,
  data,
  outboundIntegration,
  externalProvider,
  operationsControl,
  recoveryBoundary,
}

enum DeploymentTrustBoundaryKind {
  clientToEdge,
  edgeToApplication,
  applicationToData,
  applicationToIntegration,
  integrationToProvider,
  runtimeToOperations,
  dataToRecovery,
}

class DeploymentEnvironmentDeclaration {
  const DeploymentEnvironmentDeclaration._({
    required this.kind,
    required this.environmentId,
    required this.ownerId,
    required this.digest,
  });

  factory DeploymentEnvironmentDeclaration.create({
    required DeploymentEnvironmentKind kind,
    required String environmentId,
    required String ownerId,
  }) {
    _requireValue(environmentId, 'Environment ID');
    _requireValue(ownerId, 'Environment owner');
    final payload = {
      'kind': kind.name,
      'environmentId': environmentId,
      'ownerId': ownerId,
    };
    return DeploymentEnvironmentDeclaration._(
      kind: kind,
      environmentId: environmentId,
      ownerId: ownerId,
      digest: _digest(payload),
    );
  }

  final DeploymentEnvironmentKind kind;
  final String environmentId;
  final String ownerId;
  final String digest;

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'environmentId': environmentId,
        'ownerId': ownerId,
        'digest': digest,
      };
}

class DeploymentZoneDeclaration {
  const DeploymentZoneDeclaration._({
    required this.kind,
    required this.zoneId,
    required this.ownerId,
    required this.digest,
  });

  factory DeploymentZoneDeclaration.create({
    required DeploymentZoneKind kind,
    required String zoneId,
    required String ownerId,
  }) {
    _requireValue(zoneId, 'Zone ID');
    _requireValue(ownerId, 'Zone owner');
    final payload = {
      'kind': kind.name,
      'zoneId': zoneId,
      'ownerId': ownerId,
    };
    return DeploymentZoneDeclaration._(
      kind: kind,
      zoneId: zoneId,
      ownerId: ownerId,
      digest: _digest(payload),
    );
  }

  final DeploymentZoneKind kind;
  final String zoneId;
  final String ownerId;
  final String digest;

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'zoneId': zoneId,
        'ownerId': ownerId,
        'digest': digest,
      };
}

class DeploymentTrustBoundaryDeclaration {
  const DeploymentTrustBoundaryDeclaration._({
    required this.kind,
    required this.boundaryId,
    required this.source,
    required this.destination,
    required this.publicPortContract,
    required this.ownerId,
    required this.digest,
  });

  factory DeploymentTrustBoundaryDeclaration.create({
    required DeploymentTrustBoundaryKind kind,
    required String boundaryId,
    required DeploymentEndpoint source,
    required DeploymentEndpoint destination,
    required String publicPortContract,
    required String ownerId,
  }) {
    _requireValue(boundaryId, 'Boundary ID');
    _requireValue(publicPortContract, 'Public port contract');
    _requireValue(ownerId, 'Boundary owner');
    final expected = _requiredCrossings[kind]!;
    if (source != expected.$1 || destination != expected.$2) {
      throw ArgumentError('Trust boundary crossing is invalid.');
    }
    final payload = {
      'kind': kind.name,
      'boundaryId': boundaryId,
      'source': source.name,
      'destination': destination.name,
      'publicPortContract': publicPortContract,
      'ownerId': ownerId,
    };
    return DeploymentTrustBoundaryDeclaration._(
      kind: kind,
      boundaryId: boundaryId,
      source: source,
      destination: destination,
      publicPortContract: publicPortContract,
      ownerId: ownerId,
      digest: _digest(payload),
    );
  }

  final DeploymentTrustBoundaryKind kind;
  final String boundaryId;
  final DeploymentEndpoint source;
  final DeploymentEndpoint destination;
  final String publicPortContract;
  final String ownerId;
  final String digest;

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'boundaryId': boundaryId,
        'source': source.name,
        'destination': destination.name,
        'publicPortContract': publicPortContract,
        'ownerId': ownerId,
        'digest': digest,
      };
}

class DeploymentTopologyRequest {
  DeploymentTopologyRequest._({
    required this.topologyId,
    required this.topologyVersion,
    required this.artifactIdentityId,
    required this.artifactIdentityDigest,
    required this.artifactProvenanceIdentity,
    required this.configurationSchemaIdentity,
    required List<DeploymentEnvironmentDeclaration> environments,
    required List<DeploymentZoneDeclaration> zones,
    required List<DeploymentTrustBoundaryDeclaration> boundaries,
    required this.provenanceDigest,
    required this.digest,
  })  : environments = List.unmodifiable(environments),
        zones = List.unmodifiable(zones),
        boundaries = List.unmodifiable(boundaries);

  factory DeploymentTopologyRequest.create({
    required String topologyId,
    required String topologyVersion,
    required ReleaseArtifactIdentityRecord artifactIdentity,
    required Iterable<DeploymentEnvironmentDeclaration> environments,
    required Iterable<DeploymentZoneDeclaration> zones,
    required Iterable<DeploymentTrustBoundaryDeclaration> boundaries,
  }) {
    _requireValue(topologyId, 'Topology ID');
    _requireValue(topologyVersion, 'Topology version');
    _requireValue(artifactIdentity.artifactId, 'Artifact identity ID');
    _requireValue(artifactIdentity.digest, 'Artifact identity digest');
    _requireValue(
      artifactIdentity.provenanceIdentity,
      'Artifact provenance identity',
    );
    _requireValue(
      artifactIdentity.configurationSchemaIdentity,
      'Configuration schema identity',
    );
    final canonicalEnvironments = [...environments]
      ..sort((left, right) => left.kind.index.compareTo(right.kind.index));
    final canonicalZones = [...zones]
      ..sort((left, right) => left.kind.index.compareTo(right.kind.index));
    final canonicalBoundaries = [...boundaries]
      ..sort((left, right) => left.kind.index.compareTo(right.kind.index));
    _validateEnvironments(canonicalEnvironments);
    _validateZones(canonicalZones);
    _validateBoundaries(canonicalBoundaries);
    final provenancePayload = {
      'artifactIdentityDigest': artifactIdentity.digest,
      'artifactProvenanceIdentity': artifactIdentity.provenanceIdentity,
      'environments':
          canonicalEnvironments.map((item) => item.toJson()).toList(),
      'zones': canonicalZones.map((item) => item.toJson()).toList(),
      'boundaries': canonicalBoundaries.map((item) => item.toJson()).toList(),
    };
    final provenanceDigest = _digest(provenancePayload);
    final payload = {
      'version': deploymentTopologyRuntimeVersion,
      'policyVersion': deploymentTopologyPolicyVersion,
      'topologyId': topologyId,
      'topologyVersion': topologyVersion,
      'artifactIdentityId': artifactIdentity.artifactId,
      'artifactIdentityDigest': artifactIdentity.digest,
      'artifactProvenanceIdentity': artifactIdentity.provenanceIdentity,
      'configurationSchemaIdentity':
          artifactIdentity.configurationSchemaIdentity,
      'provenanceDigest': provenanceDigest,
      'environments':
          canonicalEnvironments.map((item) => item.toJson()).toList(),
      'zones': canonicalZones.map((item) => item.toJson()).toList(),
      'boundaries': canonicalBoundaries.map((item) => item.toJson()).toList(),
    };
    return DeploymentTopologyRequest._(
      topologyId: topologyId,
      topologyVersion: topologyVersion,
      artifactIdentityId: artifactIdentity.artifactId,
      artifactIdentityDigest: artifactIdentity.digest,
      artifactProvenanceIdentity: artifactIdentity.provenanceIdentity,
      configurationSchemaIdentity: artifactIdentity.configurationSchemaIdentity,
      environments: canonicalEnvironments,
      zones: canonicalZones,
      boundaries: canonicalBoundaries,
      provenanceDigest: provenanceDigest,
      digest: _digest(payload),
    );
  }

  final String topologyId;
  final String topologyVersion;
  final String artifactIdentityId;
  final String artifactIdentityDigest;
  final String artifactProvenanceIdentity;
  final String configurationSchemaIdentity;
  final List<DeploymentEnvironmentDeclaration> environments;
  final List<DeploymentZoneDeclaration> zones;
  final List<DeploymentTrustBoundaryDeclaration> boundaries;
  final String provenanceDigest;
  final String digest;
}

class DeploymentTopologyAuthorization {
  const DeploymentTopologyAuthorization._({
    required this.requestDigest,
    required this.artifactIdentityDigest,
    required this.provenanceDigest,
    required this.digest,
  });

  factory DeploymentTopologyAuthorization.create(
    DeploymentTopologyRequest request,
  ) {
    final payload = {
      'version': deploymentTopologyRuntimeVersion,
      'requestDigest': request.digest,
      'artifactIdentityDigest': request.artifactIdentityDigest,
      'provenanceDigest': request.provenanceDigest,
    };
    return DeploymentTopologyAuthorization._(
      requestDigest: request.digest,
      artifactIdentityDigest: request.artifactIdentityDigest,
      provenanceDigest: request.provenanceDigest,
      digest: _digest(payload),
    );
  }

  final String requestDigest;
  final String artifactIdentityDigest;
  final String provenanceDigest;
  final String digest;
}

class DeploymentTopologyRecord {
  DeploymentTopologyRecord._({
    required this.id,
    required this.topologyVersion,
    required this.artifactIdentityId,
    required this.artifactIdentityDigest,
    required this.artifactProvenanceIdentity,
    required this.configurationSchemaIdentity,
    required List<DeploymentEnvironmentDeclaration> environments,
    required List<DeploymentZoneDeclaration> zones,
    required List<DeploymentTrustBoundaryDeclaration> boundaries,
    required this.requestDigest,
    required this.authorizationDigest,
    required this.provenanceDigest,
    required this.digest,
  })  : environments = List.unmodifiable(environments),
        zones = List.unmodifiable(zones),
        boundaries = List.unmodifiable(boundaries);

  final String id;
  final String topologyVersion;
  final String artifactIdentityId;
  final String artifactIdentityDigest;
  final String artifactProvenanceIdentity;
  final String configurationSchemaIdentity;
  final List<DeploymentEnvironmentDeclaration> environments;
  final List<DeploymentZoneDeclaration> zones;
  final List<DeploymentTrustBoundaryDeclaration> boundaries;
  final String requestDigest;
  final String authorizationDigest;
  final String provenanceDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'version': deploymentTopologyRuntimeVersion,
        'policyVersion': deploymentTopologyPolicyVersion,
        'id': id,
        'topologyVersion': topologyVersion,
        'artifactIdentityId': artifactIdentityId,
        'artifactIdentityDigest': artifactIdentityDigest,
        'artifactProvenanceIdentity': artifactProvenanceIdentity,
        'configurationSchemaIdentity': configurationSchemaIdentity,
        'environments': environments.map((item) => item.toJson()).toList(),
        'zones': zones.map((item) => item.toJson()).toList(),
        'boundaries': boundaries.map((item) => item.toJson()).toList(),
        'requestDigest': requestDigest,
        'authorizationDigest': authorizationDigest,
        'provenanceDigest': provenanceDigest,
        'digest': digest,
      };
}

class DeploymentTopologyRuntime {
  const DeploymentTopologyRuntime();

  DeploymentTopologyRecord assemble({
    required DeploymentTopologyRequest request,
    required DeploymentTopologyAuthorization authorization,
  }) {
    _validateEnvironments(request.environments);
    _validateZones(request.zones);
    _validateBoundaries(request.boundaries);
    final expectedAuthorization =
        DeploymentTopologyAuthorization.create(request);
    if (authorization.requestDigest != expectedAuthorization.requestDigest ||
        authorization.artifactIdentityDigest !=
            expectedAuthorization.artifactIdentityDigest ||
        authorization.provenanceDigest !=
            expectedAuthorization.provenanceDigest ||
        authorization.digest != expectedAuthorization.digest) {
      throw ArgumentError('Deployment topology authorization is stale.');
    }
    final payload = {
      'version': deploymentTopologyRuntimeVersion,
      'policyVersion': deploymentTopologyPolicyVersion,
      'topologyId': request.topologyId,
      'topologyVersion': request.topologyVersion,
      'artifactIdentityId': request.artifactIdentityId,
      'artifactIdentityDigest': request.artifactIdentityDigest,
      'artifactProvenanceIdentity': request.artifactProvenanceIdentity,
      'configurationSchemaIdentity': request.configurationSchemaIdentity,
      'environments':
          request.environments.map((item) => item.toJson()).toList(),
      'zones': request.zones.map((item) => item.toJson()).toList(),
      'boundaries': request.boundaries.map((item) => item.toJson()).toList(),
      'requestDigest': request.digest,
      'authorizationDigest': authorization.digest,
      'provenanceDigest': request.provenanceDigest,
    };
    final digest = _digest(payload);
    return DeploymentTopologyRecord._(
      id: '${request.topologyId}.${digest.substring(0, 16)}',
      topologyVersion: request.topologyVersion,
      artifactIdentityId: request.artifactIdentityId,
      artifactIdentityDigest: request.artifactIdentityDigest,
      artifactProvenanceIdentity: request.artifactProvenanceIdentity,
      configurationSchemaIdentity: request.configurationSchemaIdentity,
      environments: request.environments,
      zones: request.zones,
      boundaries: request.boundaries,
      requestDigest: request.digest,
      authorizationDigest: authorization.digest,
      provenanceDigest: request.provenanceDigest,
      digest: digest,
    );
  }

  DeploymentTopologyRecord replay({
    required DeploymentTopologyRequest request,
    required DeploymentTopologyAuthorization authorization,
    required DeploymentTopologyRecord expected,
  }) {
    final replayed = assemble(request: request, authorization: authorization);
    if (jsonEncode(replayed.toJson()) != jsonEncode(expected.toJson())) {
      throw StateError('Deployment topology replay does not match.');
    }
    return replayed;
  }
}

void _validateEnvironments(List<DeploymentEnvironmentDeclaration> items) {
  _validateCanonicalInventory<DeploymentEnvironmentKind>(
    items: items,
    expectedLength: DeploymentEnvironmentKind.values.length,
    kindOf: (item) => item.kind,
    identityOf: (item) => item.environmentId,
    digestIsValid: (item) =>
        item.digest ==
        DeploymentEnvironmentDeclaration.create(
          kind: item.kind,
          environmentId: item.environmentId,
          ownerId: item.ownerId,
        ).digest,
  );
}

void _validateZones(List<DeploymentZoneDeclaration> items) {
  _validateCanonicalInventory<DeploymentZoneKind>(
    items: items,
    expectedLength: DeploymentZoneKind.values.length,
    kindOf: (item) => item.kind,
    identityOf: (item) => item.zoneId,
    digestIsValid: (item) =>
        item.digest ==
        DeploymentZoneDeclaration.create(
          kind: item.kind,
          zoneId: item.zoneId,
          ownerId: item.ownerId,
        ).digest,
  );
}

void _validateBoundaries(List<DeploymentTrustBoundaryDeclaration> items) {
  _validateCanonicalInventory<DeploymentTrustBoundaryKind>(
    items: items,
    expectedLength: DeploymentTrustBoundaryKind.values.length,
    kindOf: (item) => item.kind,
    identityOf: (item) => item.boundaryId,
    digestIsValid: (item) =>
        item.digest ==
        DeploymentTrustBoundaryDeclaration.create(
          kind: item.kind,
          boundaryId: item.boundaryId,
          source: item.source,
          destination: item.destination,
          publicPortContract: item.publicPortContract,
          ownerId: item.ownerId,
        ).digest,
  );
}

void _validateCanonicalInventory<K extends Enum>({
  required List<dynamic> items,
  required int expectedLength,
  required K Function(dynamic item) kindOf,
  required String Function(dynamic item) identityOf,
  required bool Function(dynamic item) digestIsValid,
}) {
  if (items.length != expectedLength) {
    throw ArgumentError('Deployment topology inventory is incomplete.');
  }
  final kinds = <K>{};
  final identities = <String>{};
  for (var position = 0; position < items.length; position++) {
    final item = items[position];
    final kind = kindOf(item);
    if (kind.index != position ||
        !kinds.add(kind) ||
        !identities.add(identityOf(item)) ||
        !digestIsValid(item)) {
      throw ArgumentError('Deployment topology inventory is invalid.');
    }
  }
}

const _requiredCrossings =
    <DeploymentTrustBoundaryKind, (DeploymentEndpoint, DeploymentEndpoint)>{
  DeploymentTrustBoundaryKind.clientToEdge: (
    DeploymentEndpoint.approvedClient,
    DeploymentEndpoint.edge,
  ),
  DeploymentTrustBoundaryKind.edgeToApplication: (
    DeploymentEndpoint.edge,
    DeploymentEndpoint.applicationRuntime,
  ),
  DeploymentTrustBoundaryKind.applicationToData: (
    DeploymentEndpoint.applicationRuntime,
    DeploymentEndpoint.data,
  ),
  DeploymentTrustBoundaryKind.applicationToIntegration: (
    DeploymentEndpoint.applicationRuntime,
    DeploymentEndpoint.outboundIntegration,
  ),
  DeploymentTrustBoundaryKind.integrationToProvider: (
    DeploymentEndpoint.outboundIntegration,
    DeploymentEndpoint.externalProvider,
  ),
  DeploymentTrustBoundaryKind.runtimeToOperations: (
    DeploymentEndpoint.applicationRuntime,
    DeploymentEndpoint.operationsControl,
  ),
  DeploymentTrustBoundaryKind.dataToRecovery: (
    DeploymentEndpoint.data,
    DeploymentEndpoint.recoveryBoundary,
  ),
};

void _requireValue(String value, String field) {
  if (value.trim().isEmpty || value != value.trim()) {
    throw ArgumentError('$field must be a non-empty canonical value.');
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
