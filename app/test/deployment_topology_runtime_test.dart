import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/infrastructure/production/deployment_topology_runtime.dart';
import 'package:pool_os/infrastructure/production/release_artifact_identity_runtime.dart';

void main() {
  test('assembles four environments, five zones, and seven boundaries', () {
    final fixture = _fixture();
    final record = _assemble(fixture);

    expect(record.environments, hasLength(4));
    expect(record.zones, hasLength(5));
    expect(record.boundaries, hasLength(7));
    expect(record.artifactIdentityDigest, fixture.artifact.digest);
    expect(record.configurationSchemaIdentity, 'configuration-schema.v1');
  });

  test('reordered declarations canonicalize to identical topology', () {
    final first = _fixture();
    final second = _fixture(reverse: true);

    expect(_assemble(second).toJson(), _assemble(first).toJson());
  });

  test('independent replay is stable', () {
    final fixture = _fixture();
    final expected = _assemble(fixture);
    final replayed = const DeploymentTopologyRuntime().replay(
      request: fixture.request,
      authorization: fixture.authorization,
      expected: expected,
    );

    expect(replayed.toJson(), expected.toJson());
    expect(replayed.digest, expected.digest);
  });

  test('incomplete or duplicate topology inventory fails closed', () {
    final artifact = _artifact();
    final environments = _environments();
    for (final invalid in [
      environments.sublist(1),
      [...environments.sublist(0, 3), environments.first],
    ]) {
      expect(
        () => _request(artifact, environments: invalid),
        throwsArgumentError,
      );
    }
  });

  test('undeclared boundary crossing fails closed', () {
    expect(
      () => DeploymentTrustBoundaryDeclaration.create(
        kind: DeploymentTrustBoundaryKind.applicationToData,
        boundaryId: 'tb-3',
        source: DeploymentEndpoint.edge,
        destination: DeploymentEndpoint.data,
        publicPortContract: 'public-port.v1',
        ownerId: 'data-owner',
      ),
      throwsArgumentError,
    );
  });

  test('stale artifact-bound authorization fails closed', () {
    final current = _fixture();
    final staleArtifact = _artifact(version: '16.0.0');
    final staleRequest = _request(staleArtifact);

    expect(
      () => const DeploymentTopologyRuntime().assemble(
        request: current.request,
        authorization: DeploymentTopologyAuthorization.create(staleRequest),
      ),
      throwsArgumentError,
    );
  });

  test('assembled inventories are immutable', () {
    final record = _assemble(_fixture());

    expect(
      () => record.environments.add(record.environments.first),
      throwsUnsupportedError,
    );
    expect(() => record.zones.add(record.zones.first), throwsUnsupportedError);
    expect(
      () => record.boundaries.add(record.boundaries.first),
      throwsUnsupportedError,
    );
  });
}

class _Fixture {
  const _Fixture(this.artifact, this.request, this.authorization);

  final ReleaseArtifactIdentityRecord artifact;
  final DeploymentTopologyRequest request;
  final DeploymentTopologyAuthorization authorization;
}

_Fixture _fixture({bool reverse = false}) {
  final artifact = _artifact();
  final request = _request(artifact, reverse: reverse);
  return _Fixture(
    artifact,
    request,
    DeploymentTopologyAuthorization.create(request),
  );
}

DeploymentTopologyRecord _assemble(_Fixture fixture) =>
    const DeploymentTopologyRuntime().assemble(
      request: fixture.request,
      authorization: fixture.authorization,
    );

DeploymentTopologyRequest _request(
  ReleaseArtifactIdentityRecord artifact, {
  bool reverse = false,
  List<DeploymentEnvironmentDeclaration>? environments,
}) {
  final environmentItems = environments ?? _environments();
  final zoneItems = _zones();
  final boundaryItems = _boundaries();
  return DeploymentTopologyRequest.create(
    topologyId: 'pool-os.topology',
    topologyVersion: '16.2.0',
    artifactIdentity: artifact,
    environments: reverse ? environmentItems.reversed : environmentItems,
    zones: reverse ? zoneItems.reversed : zoneItems,
    boundaries: reverse ? boundaryItems.reversed : boundaryItems,
  );
}

List<DeploymentEnvironmentDeclaration> _environments() => [
      for (final kind in DeploymentEnvironmentKind.values)
        DeploymentEnvironmentDeclaration.create(
          kind: kind,
          environmentId: 'environment.${kind.name}',
          ownerId: 'platform',
        ),
    ];

List<DeploymentZoneDeclaration> _zones() => [
      for (final kind in DeploymentZoneKind.values)
        DeploymentZoneDeclaration.create(
          kind: kind,
          zoneId: 'zone.${kind.name}',
          ownerId: 'owner.${kind.name}',
        ),
    ];

List<DeploymentTrustBoundaryDeclaration> _boundaries() {
  const crossings = [
    (DeploymentEndpoint.approvedClient, DeploymentEndpoint.edge),
    (DeploymentEndpoint.edge, DeploymentEndpoint.applicationRuntime),
    (DeploymentEndpoint.applicationRuntime, DeploymentEndpoint.data),
    (
      DeploymentEndpoint.applicationRuntime,
      DeploymentEndpoint.outboundIntegration,
    ),
    (
      DeploymentEndpoint.outboundIntegration,
      DeploymentEndpoint.externalProvider,
    ),
    (
      DeploymentEndpoint.applicationRuntime,
      DeploymentEndpoint.operationsControl,
    ),
    (DeploymentEndpoint.data, DeploymentEndpoint.recoveryBoundary),
  ];
  return [
    for (var index = 0;
        index < DeploymentTrustBoundaryKind.values.length;
        index++)
      DeploymentTrustBoundaryDeclaration.create(
        kind: DeploymentTrustBoundaryKind.values[index],
        boundaryId: 'tb-${index + 1}',
        source: crossings[index].$1,
        destination: crossings[index].$2,
        publicPortContract: 'public-port.${index + 1}',
        ownerId: 'owner.tb-${index + 1}',
      ),
  ];
}

ReleaseArtifactIdentityRecord _artifact({String version = '16.1.0'}) {
  final inputs = [
    for (final kind in ReleaseArtifactInputKind.values)
      ReleaseArtifactInputAttestation.create(
        kind: kind,
        identity: kind == ReleaseArtifactInputKind.configurationSchema
            ? 'configuration-schema.v1'
            : 'identity.${kind.name}',
        ownerId: 'owner.${kind.name}',
        contractVersion: '${kind.name}/1',
      ),
  ];
  final request = ReleaseArtifactIdentityRequest.create(
    artifactId: 'pool-os',
    artifactVersion: version,
    createdAt: DateTime.utc(2026, 7, 22),
    inputs: inputs,
  );
  return const ReleaseArtifactIdentityRuntime().assemble(
    request: request,
    authorization: ReleaseArtifactIdentityAuthorization.create(request),
  );
}
