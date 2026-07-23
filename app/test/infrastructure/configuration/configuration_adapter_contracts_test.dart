import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/infrastructure/configuration/configuration_adapter_contracts.dart';
import 'package:pool_os/infrastructure/contracts/infrastructure_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('configuration metadata defensively copies contract collections', () {
    final capabilities = [ConfigurationCapability.provide];
    final versions = [_version('v1')];
    final metadata = ConfigurationMetadata(
      adapter: _adapterIdentity(),
      source: _source(),
      capabilities: capabilities,
    );
    final compatibility = ConfigurationCompatibility(
      requiredVersion: versions.single,
      supportedVersions: versions,
    );

    capabilities.add(ConfigurationCapability.snapshot);
    versions.add(_version('v2'));

    expect(metadata.capabilities, [ConfigurationCapability.provide]);
    expect(compatibility.supportedVersions, [_version('v1')]);
    expect(() => metadata.capabilities.clear(), throwsUnsupportedError);
    expect(
        () => compatibility.supportedVersions.clear(), throwsUnsupportedError);
  });

  test('configuration interfaces retain compile-time generic boundaries', () {
    ConfigurationAdapter<RuntimeIdentifier>? adapter;
    ConfigurationProvider<RuntimeIdentifier>? provider;

    _acceptAdapter(adapter);
    _acceptAdapter(provider);

    expect([adapter, provider], everyElement(isNull));
  });
}

void _acceptAdapter(ConfigurationAdapter<RuntimeIdentifier>? adapter) {}

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);

ConfigurationVersion _version(String value) =>
    ConfigurationVersion(_id('configuration.version', value));

ConfigurationSource _source() => ConfigurationSource(
      identity: ConfigurationIdentity(
        _id('configuration.source', 'semantic-source'),
      ),
      version: _version('v1'),
    );

AdapterIdentity _adapterIdentity() => AdapterIdentity(
      id: _id('infrastructure.adapter', 'configuration'),
      version: _id('infrastructure.version', 'v1'),
    );
