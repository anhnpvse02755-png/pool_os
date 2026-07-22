import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/infrastructure/production/deployment_topology_runtime.dart';
import 'package:pool_os/infrastructure/production/operations_runtime.dart';
import 'package:pool_os/infrastructure/production/release_artifact_identity_runtime.dart';

void main() {
  test('assembles the accepted operational governance inventory', () {
    final fixture = _fixture();
    final record = _assemble(fixture);

    expect(record.supportedStates, hasLength(5));
    expect(record.workstreams, hasLength(9));
    expect(record.evidenceSchemas, hasLength(8));
    expect(record.runbookReferences, hasLength(10));
    expect(record.escalationRules, hasLength(4));
    expect(record.topologyDigest, fixture.topology.digest);
  });

  test('reordered declarations produce identical canonical record', () {
    final first = _fixture();
    final second = _fixture(reverse: true);
    expect(_assemble(second).toJson(), _assemble(first).toJson());
  });

  test('independent replay is deterministic', () {
    final fixture = _fixture();
    final expected = _assemble(fixture);
    final replayed = const OperationsRuntime().replay(
      request: fixture.request,
      authorization: fixture.authorization,
      expected: expected,
    );
    expect(replayed.toJson(), expected.toJson());
  });

  test('missing and duplicate workstreams fail closed', () {
    final topology = _topology();
    final workstreams =
        _references('workstream', OperationsWorkstreamKind.values);
    for (final invalid in [
      workstreams.sublist(1),
      [...workstreams.sublist(0, 8), workstreams.first],
    ]) {
      expect(
        () => _request(topology, workstreams: invalid),
        throwsArgumentError,
      );
    }
  });

  test('duplicate semantic identities across one inventory fail closed', () {
    final topology = _topology();
    final evidence = _references('evidence', OperationsEvidenceKind.values);
    evidence[1] = OperationsOwnedReference.create(
      category: evidence[1].category,
      semanticId: evidence.first.semanticId,
      ownerId: 'operations',
      schemaVersion: 'schema/1',
    );
    expect(
      () => _request(topology, evidenceSchemas: evidence),
      throwsArgumentError,
    );
  });

  test('stale topology authorization fails closed', () {
    final current = _fixture();
    final staleRequest = _request(_topology(version: '16.1.0'));
    expect(
      () => const OperationsRuntime().assemble(
        request: current.request,
        authorization: OperationsRuntimeAuthorization.create(staleRequest),
      ),
      throwsArgumentError,
    );
  });

  test('all operational collections are immutable', () {
    final record = _assemble(_fixture());
    expect(() => record.supportedStates.add(ProductionOperatingState.normal),
        throwsUnsupportedError);
    expect(() => record.workstreams.add(record.workstreams.first),
        throwsUnsupportedError);
    expect(() => record.evidenceSchemas.add(record.evidenceSchemas.first),
        throwsUnsupportedError);
    expect(() => record.runbookReferences.add(record.runbookReferences.first),
        throwsUnsupportedError);
  });
}

class _Fixture {
  const _Fixture(this.topology, this.request, this.authorization);
  final DeploymentTopologyRecord topology;
  final OperationsRuntimeRequest request;
  final OperationsRuntimeAuthorization authorization;
}

_Fixture _fixture({bool reverse = false}) {
  final topology = _topology();
  final request = _request(topology, reverse: reverse);
  return _Fixture(
    topology,
    request,
    OperationsRuntimeAuthorization.create(request),
  );
}

OperationsRuntimeRecord _assemble(_Fixture fixture) =>
    const OperationsRuntime().assemble(
      request: fixture.request,
      authorization: fixture.authorization,
    );

OperationsRuntimeRequest _request(
  DeploymentTopologyRecord topology, {
  bool reverse = false,
  List<OperationsOwnedReference>? workstreams,
  List<OperationsOwnedReference>? evidenceSchemas,
}) {
  final workstreamItems =
      workstreams ?? _references('workstream', OperationsWorkstreamKind.values);
  final evidenceItems =
      evidenceSchemas ?? _references('evidence', OperationsEvidenceKind.values);
  final runbookItems = _references('runbook', OperationsRunbookScenario.values);
  final escalationItems =
      _references('severity', OperationsIncidentSeverity.values);
  return OperationsRuntimeRequest.create(
    operationsId: 'pool-os.operations',
    operationsVersion: '16.3.0',
    topology: topology,
    initialState: ProductionOperatingState.normal,
    workstreams: reverse ? workstreamItems.reversed : workstreamItems,
    evidenceSchemas: reverse ? evidenceItems.reversed : evidenceItems,
    runbookReferences: reverse ? runbookItems.reversed : runbookItems,
    escalationRules: reverse ? escalationItems.reversed : escalationItems,
  );
}

List<OperationsOwnedReference> _references(String prefix, List<Enum> values) =>
    [
      for (final value in values)
        OperationsOwnedReference.create(
          category: '$prefix.${value.name}',
          semanticId: '$prefix-ref.${value.name}',
          ownerId: 'owner.${value.name}',
          schemaVersion: '$prefix/1',
        ),
    ];

DeploymentTopologyRecord _topology({String version = '16.2.0'}) {
  final artifact = _artifact();
  final environments = [
    for (final kind in DeploymentEnvironmentKind.values)
      DeploymentEnvironmentDeclaration.create(
        kind: kind,
        environmentId: 'environment.${kind.name}',
        ownerId: 'platform',
      ),
  ];
  final zones = [
    for (final kind in DeploymentZoneKind.values)
      DeploymentZoneDeclaration.create(
        kind: kind,
        zoneId: 'zone.${kind.name}',
        ownerId: 'owner.${kind.name}',
      ),
  ];
  const crossings = [
    (DeploymentEndpoint.approvedClient, DeploymentEndpoint.edge),
    (DeploymentEndpoint.edge, DeploymentEndpoint.applicationRuntime),
    (DeploymentEndpoint.applicationRuntime, DeploymentEndpoint.data),
    (
      DeploymentEndpoint.applicationRuntime,
      DeploymentEndpoint.outboundIntegration
    ),
    (
      DeploymentEndpoint.outboundIntegration,
      DeploymentEndpoint.externalProvider
    ),
    (
      DeploymentEndpoint.applicationRuntime,
      DeploymentEndpoint.operationsControl
    ),
    (DeploymentEndpoint.data, DeploymentEndpoint.recoveryBoundary),
  ];
  final boundaries = [
    for (var index = 0;
        index < DeploymentTrustBoundaryKind.values.length;
        index++)
      DeploymentTrustBoundaryDeclaration.create(
        kind: DeploymentTrustBoundaryKind.values[index],
        boundaryId: 'tb-${index + 1}',
        source: crossings[index].$1,
        destination: crossings[index].$2,
        publicPortContract: 'port.${index + 1}',
        ownerId: 'owner.tb-${index + 1}',
      ),
  ];
  final request = DeploymentTopologyRequest.create(
    topologyId: 'pool-os.topology',
    topologyVersion: version,
    artifactIdentity: artifact,
    environments: environments,
    zones: zones,
    boundaries: boundaries,
  );
  return const DeploymentTopologyRuntime().assemble(
    request: request,
    authorization: DeploymentTopologyAuthorization.create(request),
  );
}

ReleaseArtifactIdentityRecord _artifact() {
  final inputs = [
    for (final kind in ReleaseArtifactInputKind.values)
      ReleaseArtifactInputAttestation.create(
        kind: kind,
        identity: 'identity.${kind.name}',
        ownerId: 'owner.${kind.name}',
        contractVersion: '${kind.name}/1',
      ),
  ];
  final request = ReleaseArtifactIdentityRequest.create(
    artifactId: 'pool-os',
    artifactVersion: '16.1.0',
    createdAt: DateTime.utc(2026, 7, 22),
    inputs: inputs,
  );
  return const ReleaseArtifactIdentityRuntime().assemble(
    request: request,
    authorization: ReleaseArtifactIdentityAuthorization.create(request),
  );
}
