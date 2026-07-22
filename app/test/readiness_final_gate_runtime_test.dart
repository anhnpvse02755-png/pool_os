import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/infrastructure/production/deployment_topology_runtime.dart';
import 'package:pool_os/infrastructure/production/readiness_final_gate_runtime.dart';

void main() {
  test('assembles final-gate governance without making a decision', () {
    final fixture = _fixture();
    final record = _assemble(fixture);
    expect(record.criteria, hasLength(15));
    expect(record.signOffSequence, hasLength(10));
    expect(record.decisionMetadata, hasLength(12));
    expect(record.exceptionMetadata, hasLength(8));
    expect(record.evidenceReferences, hasLength(7));
    expect(record.toJson().containsKey('decision'), isFalse);
  });

  test('catalog order cannot change canonical record', () {
    expect(_assemble(_fixture(reverse: true)).toJson(),
        _assemble(_fixture()).toJson());
  });

  test('independent replay is deterministic', () {
    final fixture = _fixture();
    final expected = _assemble(fixture);
    expect(
      const ReadinessFinalGateRuntime()
          .replay(
            request: fixture.request,
            authorization: fixture.authorization,
            expected: expected,
          )
          .digest,
      expected.digest,
    );
  });

  test('missing and duplicate criteria fail closed', () {
    final topology = _Topology();
    final criteria = _refs('criterion', FinalGateCriterion.values);
    for (final invalid in [
      criteria.sublist(1),
      [...criteria.sublist(0, 14), criteria.first],
    ]) {
      expect(() => _request(topology, criteria: invalid), throwsArgumentError);
    }
  });

  test('duplicate evidence identity fails closed', () {
    final topology = _Topology();
    final evidence = _refs('evidence', FinalGateEvidenceSource.values);
    evidence[1] = FinalGateGovernanceReference.create(
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
      () => const ReadinessFinalGateRuntime().assemble(
        request: current.request,
        authorization: ReadinessFinalGateAuthorization.create(stale),
      ),
      throwsArgumentError,
    );
  });

  test('final-gate catalogs are immutable', () {
    final record = _assemble(_fixture());
    expect(() => record.criteria.add(record.criteria.first),
        throwsUnsupportedError);
    expect(() => record.signOffSequence.add(record.signOffSequence.first),
        throwsUnsupportedError);
    expect(() => record.decisionMetadata.add(record.decisionMetadata.first),
        throwsUnsupportedError);
  });
}

class _Fixture {
  const _Fixture(this.topology, this.request, this.authorization);
  final DeploymentTopologyRecord topology;
  final ReadinessFinalGateRequest request;
  final ReadinessFinalGateAuthorization authorization;
}

_Fixture _fixture({bool reverse = false}) {
  final topology = _Topology();
  final request = _request(topology, reverse: reverse);
  return _Fixture(
    topology,
    request,
    ReadinessFinalGateAuthorization.create(request),
  );
}

ReadinessFinalGateRecord _assemble(_Fixture fixture) =>
    const ReadinessFinalGateRuntime().assemble(
      request: fixture.request,
      authorization: fixture.authorization,
    );

ReadinessFinalGateRequest _request(
  DeploymentTopologyRecord topology, {
  bool reverse = false,
  List<FinalGateGovernanceReference>? criteria,
  List<FinalGateGovernanceReference>? evidence,
}) {
  final criterionItems =
      criteria ?? _refs('criterion', FinalGateCriterion.values);
  final signoffs = _refs('signoff', FinalGateSignOffRole.values);
  final decisions = _refs('decision', ReleaseDecisionMetadata.values);
  final exceptions = _refs('exception', ExceptionGovernanceMetadata.values);
  final evidenceItems =
      evidence ?? _refs('evidence', FinalGateEvidenceSource.values);
  return ReadinessFinalGateRequest.create(
    gateId: 'pool-os.final-gate',
    gateVersion: '16.8.0',
    topology: topology,
    criteria: reverse ? criterionItems.reversed : criterionItems,
    signOffSequence: reverse ? signoffs.reversed : signoffs,
    decisionMetadata: reverse ? decisions.reversed : decisions,
    exceptionMetadata: reverse ? exceptions.reversed : exceptions,
    evidenceReferences: reverse ? evidenceItems.reversed : evidenceItems,
  );
}

List<FinalGateGovernanceReference> _refs(String prefix, List<Enum> values) => [
      for (final value in values)
        FinalGateGovernanceReference.create(
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
