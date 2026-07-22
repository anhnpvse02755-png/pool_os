import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/infrastructure/production/deployment_topology_runtime.dart';
import 'package:pool_os/infrastructure/production/security_runtime.dart';

void main() {
  test('assembles accepted security governance catalogs', () {
    final fixture = _fixture();
    final record = _assemble(fixture);
    expect(record.identityClasses, hasLength(8));
    expect(record.authorizationDomains, hasLength(8));
    expect(record.custodyMetadata, hasLength(3));
    expect(record.dataClassifications, hasLength(4));
    expect(record.evidenceReferences, hasLength(9));
    expect(record.topologyDigest, fixture.topology.digest);
  });

  test('reordered catalogs assemble identically', () {
    expect(_assemble(_fixture(reverse: true)).toJson(),
        _assemble(_fixture()).toJson());
  });

  test('independent replay is deterministic', () {
    final fixture = _fixture();
    final expected = _assemble(fixture);
    expect(
      const SecurityRuntime()
          .replay(
            request: fixture.request,
            authorization: fixture.authorization,
            expected: expected,
          )
          .digest,
      expected.digest,
    );
  });

  test('missing and duplicate identity classes fail closed', () {
    final topology = _Topology();
    final identities = _refs('identity', SecurityIdentityClass.values);
    for (final invalid in [
      identities.sublist(1),
      [...identities.sublist(0, 7), identities.first],
    ]) {
      expect(
          () => _request(topology, identities: invalid), throwsArgumentError);
    }
  });

  test('duplicate evidence identity fails closed', () {
    final topology = _Topology();
    final evidence = _refs('evidence', SecurityEvidenceClass.values);
    evidence[1] = SecurityGovernanceReference.create(
      category: evidence[1].category,
      referenceId: evidence[1].referenceId,
      ownerId: evidence[1].ownerId,
      evidenceIdentity: evidence.first.evidenceIdentity,
      policyVersion: 'evidence/1',
    );
    expect(() => _request(topology, evidence: evidence), throwsArgumentError);
  });

  test('stale topology authorization fails closed', () {
    final current = _fixture();
    final stale = _request(_Topology(digest: 'stale'));
    expect(
      () => const SecurityRuntime().assemble(
        request: current.request,
        authorization: SecurityRuntimeAuthorization.create(stale),
      ),
      throwsArgumentError,
    );
  });

  test('security catalogs are immutable', () {
    final record = _assemble(_fixture());
    expect(() => record.identityClasses.add(record.identityClasses.first),
        throwsUnsupportedError);
    expect(
        () =>
            record.authorizationDomains.add(record.authorizationDomains.first),
        throwsUnsupportedError);
    expect(() => record.custodyMetadata.add(record.custodyMetadata.first),
        throwsUnsupportedError);
  });
}

class _Fixture {
  const _Fixture(this.topology, this.request, this.authorization);
  final DeploymentTopologyRecord topology;
  final SecurityRuntimeRequest request;
  final SecurityRuntimeAuthorization authorization;
}

_Fixture _fixture({bool reverse = false}) {
  final topology = _Topology();
  final request = _request(topology, reverse: reverse);
  return _Fixture(
    topology,
    request,
    SecurityRuntimeAuthorization.create(request),
  );
}

SecurityRuntimeRecord _assemble(_Fixture fixture) =>
    const SecurityRuntime().assemble(
      request: fixture.request,
      authorization: fixture.authorization,
    );

SecurityRuntimeRequest _request(
  DeploymentTopologyRecord topology, {
  bool reverse = false,
  List<SecurityGovernanceReference>? identities,
  List<SecurityGovernanceReference>? evidence,
}) {
  final identityItems =
      identities ?? _refs('identity', SecurityIdentityClass.values);
  final domains = _refs('authorization', SecurityAuthorizationDomain.values);
  final custody = _refs('custody', SecurityCustodyMetadataClass.values);
  final classifications =
      _refs('classification', SecurityDataClassification.values);
  final evidenceItems =
      evidence ?? _refs('evidence', SecurityEvidenceClass.values);
  return SecurityRuntimeRequest.create(
    securityId: 'pool-os.security',
    securityVersion: '16.5.0',
    topology: topology,
    identityClasses: reverse ? identityItems.reversed : identityItems,
    authorizationDomains: reverse ? domains.reversed : domains,
    custodyMetadata: reverse ? custody.reversed : custody,
    dataClassifications: reverse ? classifications.reversed : classifications,
    evidenceReferences: reverse ? evidenceItems.reversed : evidenceItems,
  );
}

List<SecurityGovernanceReference> _refs(String prefix, List<Enum> values) => [
      for (final value in values)
        SecurityGovernanceReference.create(
          category: '$prefix.${value.name}',
          referenceId: '$prefix-ref.${value.name}',
          ownerId: 'owner.${value.name}',
          evidenceIdentity: '$prefix-evidence.${value.name}',
          policyVersion: '$prefix/1',
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
