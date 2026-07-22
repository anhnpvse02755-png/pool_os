import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/infrastructure/production/deployment_topology_runtime.dart';
import 'package:pool_os/infrastructure/production/performance_capacity_runtime.dart';

void main() {
  test('assembles accepted performance governance catalogs', () {
    final fixture = _fixture();
    final record = _assemble(fixture);
    expect(record.objectives, hasLength(9));
    expect(record.workloads, hasLength(8));
    expect(record.resources, hasLength(9));
    expect(record.bottlenecks, hasLength(8));
    expect(record.evidenceReferences, hasLength(9));
    expect(record.topologyDigest, fixture.topology.digest);
  });

  test('catalog order cannot change canonical record', () {
    expect(_assemble(_fixture(reverse: true)).toJson(),
        _assemble(_fixture()).toJson());
  });

  test('independent replay is deterministic', () {
    final fixture = _fixture();
    final expected = _assemble(fixture);
    expect(
      const PerformanceCapacityRuntime()
          .replay(
            request: fixture.request,
            authorization: fixture.authorization,
            expected: expected,
          )
          .digest,
      expected.digest,
    );
  });

  test('missing and duplicate objectives fail closed', () {
    final topology = _Topology();
    final items = _refs('objective', PerformanceObjectiveDimension.values);
    for (final invalid in [
      items.sublist(1),
      [...items.sublist(0, 8), items.first],
    ]) {
      expect(
          () => _request(topology, objectives: invalid), throwsArgumentError);
    }
  });

  test('duplicate evidence identity fails closed', () {
    final topology = _Topology();
    final evidence = _refs('evidence', PerformanceEvidenceClass.values);
    evidence[1] = PerformanceCapacityReference.create(
      category: evidence[1].category,
      referenceId: evidence[1].referenceId,
      ownerId: evidence[1].ownerId,
      evidenceIdentity: evidence.first.evidenceIdentity,
      definitionVersion: 'evidence/1',
    );
    expect(() => _request(topology, evidence: evidence), throwsArgumentError);
  });

  test('stale topology authorization fails closed', () {
    final current = _fixture();
    final stale = _request(_Topology(digest: 'stale'));
    expect(
      () => const PerformanceCapacityRuntime().assemble(
        request: current.request,
        authorization: PerformanceCapacityAuthorization.create(stale),
      ),
      throwsArgumentError,
    );
  });

  test('performance catalogs are immutable', () {
    final record = _assemble(_fixture());
    expect(() => record.objectives.add(record.objectives.first),
        throwsUnsupportedError);
    expect(() => record.workloads.add(record.workloads.first),
        throwsUnsupportedError);
    expect(() => record.resources.add(record.resources.first),
        throwsUnsupportedError);
  });
}

class _Fixture {
  const _Fixture(this.topology, this.request, this.authorization);
  final DeploymentTopologyRecord topology;
  final PerformanceCapacityRequest request;
  final PerformanceCapacityAuthorization authorization;
}

_Fixture _fixture({bool reverse = false}) {
  final topology = _Topology();
  final request = _request(topology, reverse: reverse);
  return _Fixture(
    topology,
    request,
    PerformanceCapacityAuthorization.create(request),
  );
}

PerformanceCapacityRecord _assemble(_Fixture fixture) =>
    const PerformanceCapacityRuntime().assemble(
      request: fixture.request,
      authorization: fixture.authorization,
    );

PerformanceCapacityRequest _request(
  DeploymentTopologyRecord topology, {
  bool reverse = false,
  List<PerformanceCapacityReference>? objectives,
  List<PerformanceCapacityReference>? evidence,
}) {
  final objectiveItems =
      objectives ?? _refs('objective', PerformanceObjectiveDimension.values);
  final workloads = _refs('workload', PerformanceWorkloadClass.values);
  final resources = _refs('resource', PerformanceResourceClass.values);
  final bottlenecks = _refs('bottleneck', PerformanceBottleneckClass.values);
  final evidenceItems =
      evidence ?? _refs('evidence', PerformanceEvidenceClass.values);
  return PerformanceCapacityRequest.create(
    performanceId: 'pool-os.performance',
    performanceVersion: '16.6.0',
    topology: topology,
    objectives: reverse ? objectiveItems.reversed : objectiveItems,
    workloads: reverse ? workloads.reversed : workloads,
    resources: reverse ? resources.reversed : resources,
    bottlenecks: reverse ? bottlenecks.reversed : bottlenecks,
    evidenceReferences: reverse ? evidenceItems.reversed : evidenceItems,
  );
}

List<PerformanceCapacityReference> _refs(String prefix, List<Enum> values) => [
      for (final value in values)
        PerformanceCapacityReference.create(
          category: '$prefix.${value.name}',
          referenceId: '$prefix-ref.${value.name}',
          ownerId: 'owner.${value.name}',
          evidenceIdentity: '$prefix-evidence.${value.name}',
          definitionVersion: '$prefix/1',
        ),
    ];

class _Topology implements DeploymentTopologyRecord {
  _Topology({this.digest = 'topology.digest'});
  @override
  final String digest;
  @override
  String get id => 'topology.id';
  @override
  String get artifactIdentityDigest => 'artifact.digest';
  @override
  String get artifactIdentityId => 'artifact.id';
  @override
  String get artifactProvenanceIdentity => 'artifact.provenance';
  @override
  String get authorizationDigest => 'authorization.digest';
  @override
  List<DeploymentTrustBoundaryDeclaration> get boundaries => const [];
  @override
  String get configurationSchemaIdentity => 'configuration.schema';
  @override
  List<DeploymentEnvironmentDeclaration> get environments => const [];
  @override
  String get provenanceDigest => 'topology.provenance';
  @override
  String get requestDigest => 'request.digest';
  @override
  String get topologyVersion => '16.2.0';
  @override
  List<DeploymentZoneDeclaration> get zones => const [];
  @override
  Map<String, dynamic> toJson() => {'id': id, 'digest': digest};
}
