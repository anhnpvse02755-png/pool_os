import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/product/runtime/product_runtime_assembly_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('runtime configuration defensively copies static metadata', () {
    final capabilities = [_capability('composition')];
    final versions = [_version('v1')];
    final configuration = ProductRuntimeConfiguration(
      identity: _id('product.runtime.configuration', 'main'),
      version: versions.single,
      capabilities: capabilities,
    );
    final compatibility = ProductRuntimeCompatibility(
      requiredVersion: versions.single,
      supportedVersions: versions,
    );

    capabilities.clear();
    versions.add(_version('v2'));

    expect(configuration.capabilities, [_capability('composition')]);
    expect(compatibility.supportedVersions, [_version('v1')]);
    expect(() => configuration.capabilities.clear(), throwsUnsupportedError);
    expect(
        () => compatibility.supportedVersions.clear(), throwsUnsupportedError);
  });

  test('runtime assembly contract remains an interface-only boundary', () {
    ProductRuntimeAssemblyContract? contract;

    _acceptContract(contract);

    expect(contract, isNull);
  });
}

void _acceptContract(ProductRuntimeAssemblyContract? contract) {}

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);

ProductRuntimeCapability _capability(String value) =>
    ProductRuntimeCapability(_id('product.runtime.capability', value));

ProductRuntimeVersion _version(String value) =>
    ProductRuntimeVersion(_id('product.runtime.version', value));
