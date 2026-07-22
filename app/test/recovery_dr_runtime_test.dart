import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/infrastructure/production/deployment_topology_runtime.dart';
import 'package:pool_os/infrastructure/production/recovery_dr_runtime.dart';

void main() {
  test('assembles accepted recovery governance inventory', () {
    final fixture = _fixture();
    final record = _assemble(fixture);
    expect(record.informationClasses, hasLength(7));
    expect(record.boundaries, hasLength(6));
    expect(record.states, hasLength(9));
    expect(record.validationUnits, hasLength(10));
    expect(record.rehearsalReferences, hasLength(9));
    expect(record.topologyDigest, fixture.topology.digest);
  });

  test('input ordering cannot change record JSON or digest', () {
    expect(_assemble(_fixture(reverse: true)).toJson(),
        _assemble(_fixture()).toJson());
  });

  test('independent replay is deterministic', () {
    final fixture = _fixture();
    final expected = _assemble(fixture);
    expect(
      const RecoveryDrRuntime()
          .replay(
            request: fixture.request,
            authorization: fixture.authorization,
            expected: expected,
          )
          .toJson(),
      expected.toJson(),
    );
  });

  test('missing and duplicate recovery classes fail closed', () {
    final topology = _Topology();
    final classes = _refs('class', RecoveryInformationClass.values);
    for (final invalid in [
      classes.sublist(1),
      [...classes.sublist(0, 6), classes.first],
    ]) {
      expect(() => _request(topology, classes: invalid), throwsArgumentError);
    }
  });

  test('duplicate evidence identity fails closed', () {
    final topology = _Topology();
    final boundaries = _refs('boundary', RecoveryBoundaryKind.values);
    boundaries[1] = RecoveryGovernanceReference.create(
      category: boundaries[1].category,
      referenceId: boundaries[1].referenceId,
      ownerId: boundaries[1].ownerId,
      evidenceIdentity: boundaries.first.evidenceIdentity,
      contractVersion: 'boundary/1',
    );
    expect(
      () => _request(topology, boundaries: boundaries),
      throwsArgumentError,
    );
  });

  test('stale topology authorization fails closed', () {
    final current = _fixture();
    final stale = _request(_Topology(digest: 'topology.stale'));
    expect(
      () => const RecoveryDrRuntime().assemble(
        request: current.request,
        authorization: RecoveryDrAuthorization.create(stale),
      ),
      throwsArgumentError,
    );
  });

  test('recovery output collections are immutable', () {
    final record = _assemble(_fixture());
    expect(() => record.states.add(RecoveryGovernanceState.protected),
        throwsUnsupportedError);
    expect(() => record.informationClasses.add(record.informationClasses.first),
        throwsUnsupportedError);
    expect(() => record.boundaries.add(record.boundaries.first),
        throwsUnsupportedError);
  });
}

class _Fixture {
  const _Fixture(this.topology, this.request, this.authorization);
  final DeploymentTopologyRecord topology;
  final RecoveryDrRequest request;
  final RecoveryDrAuthorization authorization;
}

_Fixture _fixture({bool reverse = false}) {
  final topology = _Topology();
  final request = _request(topology, reverse: reverse);
  return _Fixture(topology, request, RecoveryDrAuthorization.create(request));
}

RecoveryDrRecord _assemble(_Fixture fixture) =>
    const RecoveryDrRuntime().assemble(
      request: fixture.request,
      authorization: fixture.authorization,
    );

RecoveryDrRequest _request(
  DeploymentTopologyRecord topology, {
  bool reverse = false,
  List<RecoveryGovernanceReference>? classes,
  List<RecoveryGovernanceReference>? boundaries,
}) {
  final classItems = classes ?? _refs('class', RecoveryInformationClass.values);
  final boundaryItems =
      boundaries ?? _refs('boundary', RecoveryBoundaryKind.values);
  final units = _refs('unit', RecoveryValidationUnit.values);
  final rehearsals = _refs('rehearsal', RecoveryGovernanceState.values);
  return RecoveryDrRequest.create(
    recoveryId: 'pool-os.recovery',
    recoveryVersion: '16.4.0',
    topology: topology,
    informationClasses: reverse ? classItems.reversed : classItems,
    boundaries: reverse ? boundaryItems.reversed : boundaryItems,
    validationUnits: reverse ? units.reversed : units,
    rehearsalReferences: reverse ? rehearsals.reversed : rehearsals,
  );
}

List<RecoveryGovernanceReference> _refs(String prefix, List<Enum> values) => [
      for (final value in values)
        RecoveryGovernanceReference.create(
          category: '$prefix.${value.name}',
          referenceId: '$prefix-ref.${value.name}',
          ownerId: 'owner.${value.name}',
          evidenceIdentity: '$prefix-evidence.${value.name}',
          contractVersion: '$prefix/1',
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
