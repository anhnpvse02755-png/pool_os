import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/infrastructure/contracts/infrastructure_contracts.dart';
import 'package:pool_os/infrastructure/external/external_service_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('external contract collections are immutable defensive copies', () {
    final capabilities = [ExternalCapability.execute];
    final versions = [_id('external.version', 'v1')];
    final metadata = ExternalCapabilityMetadata(
      adapter: _adapterIdentity(),
      capabilities: capabilities,
    );
    final compatibility = ExternalVersionCompatibility(
      requiredVersion: versions.single,
      supportedVersions: versions,
    );

    capabilities.add(ExternalCapability.health);
    versions.add(_id('external.version', 'v2'));

    expect(metadata.capabilities, [ExternalCapability.execute]);
    expect(compatibility.supportedVersions, [
      _id('external.version', 'v1'),
    ]);
    expect(() => metadata.capabilities.clear(), throwsUnsupportedError);
    expect(
        () => compatibility.supportedVersions.clear(), throwsUnsupportedError);
  });

  test('external adapter ports retain compile-time generic boundaries', () {
    ExternalServiceAdapter<String, RuntimeIdentifier>? adapter;
    OutboundServiceContract<String, RuntimeIdentifier>? outbound;
    ExternalHealthCapability? health;

    _acceptAdapter(adapter);
    _acceptAdapter(outbound);
    _acceptHealth(health);

    expect([adapter, outbound, health], everyElement(isNull));
  });
}

void _acceptAdapter(
  ExternalServiceAdapter<String, RuntimeIdentifier>? adapter,
) {}

void _acceptHealth(ExternalHealthCapability? capability) {}

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);

AdapterIdentity _adapterIdentity() => AdapterIdentity(
      id: _id('infrastructure.adapter', 'external-service'),
      version: _id('infrastructure.version', 'v1'),
    );
