import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/infrastructure/production/release_artifact_identity_runtime.dart';

void main() {
  test('assembles all fourteen M15.1 identity fields', () {
    final fixture = _fixture();
    final record = _assemble(fixture);

    expect(record.artifactId, 'pool-os');
    expect(record.artifactVersion, '16.1.0');
    expect(record.artifactDigest, 'artifact.sha256');
    expect(record.sourceRevision, 'source.faf60d3');
    expect(record.dependencySetIdentity, 'dependencies.locked');
    expect(record.buildContractVersion, 'build-contract.v1');
    expect(record.configurationSchemaIdentity, 'configuration-schema.v1');
    expect(record.migrationSetIdentity, 'migrations.none.v1');
    expect(record.knowledgeIdentity, 'knowledge.release.v1');
    expect(record.frozenContractSetIdentity, 'm15.freeze.903c64d3');
    expect(record.providerCompatibilitySet, 'providers.compatible.v1');
    expect(record.evidenceIndexIdentity, 'evidence.m16-1.v1');
    expect(record.createdAt, DateTime.utc(2026, 7, 22));
    expect(record.provenanceIdentity, fixture.request.provenanceIdentity);
  });

  test('canonical input order produces identical JSON and digest', () {
    final first = _fixture();
    final second = _fixture(reverse: true);

    expect(second.request.toJson(), first.request.toJson());
    expect(_assemble(second).toJson(), _assemble(first).toJson());
  });

  test('independent replay returns the exact identity', () {
    final fixture = _fixture();
    final expected = _assemble(fixture);

    final replayed = const ReleaseArtifactIdentityRuntime().replay(
      request: fixture.request,
      authorization: fixture.authorization,
      expected: expected,
    );

    expect(replayed.toJson(), expected.toJson());
    expect(replayed.digest, expected.digest);
  });

  test('missing and duplicate semantic inputs fail closed', () {
    final inputs = _inputs();
    expect(
      () => ReleaseArtifactIdentityRequest.create(
        artifactId: 'pool-os',
        artifactVersion: '16.1.0',
        createdAt: DateTime.utc(2026, 7, 22),
        inputs: inputs.sublist(1),
      ),
      throwsArgumentError,
    );
    expect(
      () => ReleaseArtifactIdentityRequest.create(
        artifactId: 'pool-os',
        artifactVersion: '16.1.0',
        createdAt: DateTime.utc(2026, 7, 22),
        inputs: [...inputs.sublist(0, inputs.length - 1), inputs.first],
      ),
      throwsArgumentError,
    );
  });

  test('mixed semantic identities fail closed', () {
    final inputs = _inputs();
    inputs[1] = ReleaseArtifactInputAttestation.create(
      kind: ReleaseArtifactInputKind.sourceRevision,
      identity: inputs.first.identity,
      ownerId: 'source-control',
      contractVersion: 'source/1',
    );

    expect(
      () => ReleaseArtifactIdentityRequest.create(
        artifactId: 'pool-os',
        artifactVersion: '16.1.0',
        createdAt: DateTime.utc(2026, 7, 22),
        inputs: inputs,
      ),
      throwsArgumentError,
    );
  });

  test('stale authorization fails closed', () {
    final current = _fixture();
    final stale = _fixture(artifactVersion: '16.0.0');

    expect(
      () => const ReleaseArtifactIdentityRuntime().assemble(
        request: current.request,
        authorization: stale.authorization,
      ),
      throwsArgumentError,
    );
  });

  test('request inputs are immutable and creation time must be UTC', () {
    final fixture = _fixture();
    expect(
      () => fixture.request.inputs.add(fixture.request.inputs.first),
      throwsUnsupportedError,
    );
    expect(
      () => ReleaseArtifactIdentityRequest.create(
        artifactId: 'pool-os',
        artifactVersion: '16.1.0',
        createdAt: DateTime(2026, 7, 22),
        inputs: _inputs(),
      ),
      throwsArgumentError,
    );
  });
}

class _Fixture {
  const _Fixture(this.request, this.authorization);

  final ReleaseArtifactIdentityRequest request;
  final ReleaseArtifactIdentityAuthorization authorization;
}

_Fixture _fixture({bool reverse = false, String artifactVersion = '16.1.0'}) {
  final inputs = _inputs();
  final request = ReleaseArtifactIdentityRequest.create(
    artifactId: 'pool-os',
    artifactVersion: artifactVersion,
    createdAt: DateTime.utc(2026, 7, 22),
    inputs: reverse ? inputs.reversed : inputs,
  );
  return _Fixture(
    request,
    ReleaseArtifactIdentityAuthorization.create(request),
  );
}

ReleaseArtifactIdentityRecord _assemble(_Fixture fixture) =>
    const ReleaseArtifactIdentityRuntime().assemble(
      request: fixture.request,
      authorization: fixture.authorization,
    );

List<ReleaseArtifactInputAttestation> _inputs() => [
      _input(ReleaseArtifactInputKind.artifactContent, 'artifact.sha256'),
      _input(ReleaseArtifactInputKind.sourceRevision, 'source.faf60d3'),
      _input(ReleaseArtifactInputKind.dependencySet, 'dependencies.locked'),
      _input(ReleaseArtifactInputKind.buildContract, 'build-contract.v1'),
      _input(
        ReleaseArtifactInputKind.configurationSchema,
        'configuration-schema.v1',
      ),
      _input(ReleaseArtifactInputKind.migrationSet, 'migrations.none.v1'),
      _input(ReleaseArtifactInputKind.knowledge, 'knowledge.release.v1'),
      _input(
        ReleaseArtifactInputKind.frozenContractSet,
        'm15.freeze.903c64d3',
      ),
      _input(
        ReleaseArtifactInputKind.providerCompatibilitySet,
        'providers.compatible.v1',
      ),
      _input(ReleaseArtifactInputKind.evidenceIndex, 'evidence.m16-1.v1'),
    ];

ReleaseArtifactInputAttestation _input(
  ReleaseArtifactInputKind kind,
  String identity,
) =>
    ReleaseArtifactInputAttestation.create(
      kind: kind,
      identity: identity,
      ownerId: 'owner.${kind.name}',
      contractVersion: '${kind.name}/1',
    );
