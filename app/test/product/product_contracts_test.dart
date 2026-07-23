import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/product/product_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('product configuration defensively copies static bindings', () {
    final versions = [_version('v1')];
    final bindings = [_binding()];
    final configuration = ProductConfiguration(
      identity: _id('product.configuration', 'foundation'),
      version: versions.single,
      capabilityBindings: bindings,
    );
    final compatibility = ProductCompatibility(
      requiredVersion: versions.single,
      supportedVersions: versions,
    );

    bindings.clear();
    versions.add(_version('v2'));

    expect(configuration.capabilityBindings, [_binding()]);
    expect(compatibility.supportedVersions, [_version('v1')]);
    expect(
      () => configuration.capabilityBindings.clear(),
      throwsUnsupportedError,
    );
    expect(
      () => compatibility.supportedVersions.clear(),
      throwsUnsupportedError,
    );
  });

  test('product interfaces retain compile-time contract boundaries', () {
    ProductContract? contract;
    ProductComposition? composition;
    ProductModule? module;

    _acceptContract(contract);
    _acceptContract(composition);
    _acceptContract(module);

    expect([contract, composition, module], everyElement(isNull));
  });
}

void _acceptContract(ProductContract? contract) {}

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);

ProductIdentity _productIdentity() =>
    ProductIdentity(_id('product.identity', 'pool-os'));

ProductVersion _version(String value) =>
    ProductVersion(_id('product.version', value));

ProductCapabilityBinding _binding() => ProductCapabilityBinding(
      productIdentity: _productIdentity(),
      moduleIdentity: _id('product.module', 'match'),
      capabilityIdentity: _id('product.capability', 'match'),
    );
