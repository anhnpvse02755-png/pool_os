import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/infrastructure/production/deployment_topology_runtime.dart';
import 'package:pool_os/infrastructure/production/rollout_operational_readiness_runtime.dart';

void main() {
  test('assembles accepted rollout readiness catalogs', () {
    final fixture = _fixture();
    final record = _assemble(fixture);
    expect(record.stages, hasLength(7));
    expect(record.gates, hasLength(11));
    expect(record.communications, hasLength(8));
    expect(record.hypercare, hasLength(8));
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
      const RolloutOperationalReadinessRuntime()
          .replay(
            request: fixture.request,
            authorization: fixture.authorization,
            expected: expected,
          )
          .digest,
      expected.digest,
    );
  });

  test('missing and duplicate gates fail closed', () {
    final topology = _Topology();
    final gates = _refs('gate', ReadinessGate.values);
    for (final invalid in [
      gates.sublist(1),
      [...gates.sublist(0, 10), gates.first],
    ]) {
      expect(() => _request(topology, gates: invalid), throwsArgumentError);
    }
  });

  test('duplicate evidence identity fails closed', () {
    final topology = _Topology();
    final evidence = _refs('evidence', RolloutEvidenceClass.values);
    evidence[1] = RolloutReadinessReference.create(
      category: evidence[1].category,
      referenceId: evidence[1].referenceId,
      ownerId: evidence[1].ownerId,
      evidenceIdentity: evidence.first.evidenceIdentity,
      governanceVersion: 'evidence/1',
    );
    expect(() => _request(topology, evidence: evidence), throwsArgumentError);
  });

  test('stale topology authorization fails closed', () {
    final current = _fixture();
    final stale = _request(_Topology(digest: 'stale'));
    expect(
      () => const RolloutOperationalReadinessRuntime().assemble(
        request: current.request,
        authorization: RolloutReadinessAuthorization.create(stale),
      ),
      throwsArgumentError,
    );
  });

  test('rollout catalogs are immutable', () {
    final record = _assemble(_fixture());
    expect(
        () => record.stages.add(record.stages.first), throwsUnsupportedError);
    expect(() => record.gates.add(record.gates.first), throwsUnsupportedError);
    expect(() => record.hypercare.add(record.hypercare.first),
        throwsUnsupportedError);
  });
}

class _Fixture {
  const _Fixture(this.topology, this.request, this.authorization);
  final DeploymentTopologyRecord topology;
  final RolloutReadinessRequest request;
  final RolloutReadinessAuthorization authorization;
}

_Fixture _fixture({bool reverse = false}) {
  final topology = _Topology();
  final request = _request(topology, reverse: reverse);
  return _Fixture(
    topology,
    request,
    RolloutReadinessAuthorization.create(request),
  );
}

RolloutReadinessRecord _assemble(_Fixture fixture) =>
    const RolloutOperationalReadinessRuntime().assemble(
      request: fixture.request,
      authorization: fixture.authorization,
    );

RolloutReadinessRequest _request(
  DeploymentTopologyRecord topology, {
  bool reverse = false,
  List<RolloutReadinessReference>? gates,
  List<RolloutReadinessReference>? evidence,
}) {
  final stages = _refs('stage', RolloutStage.values);
  final gateItems = gates ?? _refs('gate', ReadinessGate.values);
  final communications = _refs('communication', CommunicationAudience.values);
  final hypercare = _refs('hypercare', HypercareGovernanceItem.values);
  final evidenceItems =
      evidence ?? _refs('evidence', RolloutEvidenceClass.values);
  return RolloutReadinessRequest.create(
    rolloutId: 'pool-os.rollout',
    rolloutVersion: '16.7.0',
    topology: topology,
    stages: reverse ? stages.reversed : stages,
    gates: reverse ? gateItems.reversed : gateItems,
    communications: reverse ? communications.reversed : communications,
    hypercare: reverse ? hypercare.reversed : hypercare,
    evidenceReferences: reverse ? evidenceItems.reversed : evidenceItems,
  );
}

List<RolloutReadinessReference> _refs(String prefix, List<Enum> values) => [
      for (final value in values)
        RolloutReadinessReference.create(
          category: '$prefix.${value.name}',
          referenceId: '$prefix-ref.${value.name}',
          ownerId: 'owner.${value.name}',
          evidenceIdentity: '$prefix-evidence.${value.name}',
          governanceVersion: '$prefix/1',
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
