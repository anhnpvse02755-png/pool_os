import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/infrastructure/repositories/repository_adapter_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('repository metadata defensively copies contract collections', () {
    final capabilities = [RepositoryCapability.read];
    final versions = [_version('v1')];
    final metadata = RepositoryCapabilityMetadata(
      identity: RepositoryIdentity(_id('repository', 'player')),
      version: versions.single,
      capabilities: capabilities,
    );
    final compatibility = RepositoryCompatibility(
      requiredVersion: versions.single,
      supportedVersions: versions,
    );

    capabilities.add(RepositoryCapability.write);
    versions.add(_version('v2'));

    expect(metadata.capabilities, [RepositoryCapability.read]);
    expect(compatibility.supportedVersions, [_version('v1')]);
    expect(() => metadata.capabilities.clear(), throwsUnsupportedError);
    expect(
        () => compatibility.supportedVersions.clear(), throwsUnsupportedError);
  });

  test('repository adapter markers retain compile-time generic boundaries', () {
    RepositoryAdapter<RuntimeIdentifier>? adapter;
    AggregateRepositoryAdapter<RuntimeIdentifier>? aggregate;
    ReadRepositoryAdapter<RuntimeIdentifier, RuntimeIdentifier>? read;
    WriteRepositoryAdapter<RuntimeIdentifier, RuntimeIdentifier>? write;
    LocalRepositoryAdapter<RuntimeIdentifier>? local;
    ExternalRepositoryAdapter<RuntimeIdentifier>? external;
    ProjectionRepositoryAdapter<RuntimeIdentifier>? projection;

    _acceptAdapter(adapter);
    _acceptAdapter(aggregate);
    _acceptAdapter(read);
    _acceptAdapter(write);
    _acceptAdapter(local);
    _acceptAdapter(external);
    _acceptAdapter(projection);

    expect(
      [adapter, aggregate, read, write, local, external, projection],
      everyElement(isNull),
    );
  });
}

void _acceptAdapter(RepositoryAdapter<RuntimeIdentifier>? adapter) {}

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);

RepositoryVersion _version(String value) =>
    RepositoryVersion(_id('repository.version', value));
