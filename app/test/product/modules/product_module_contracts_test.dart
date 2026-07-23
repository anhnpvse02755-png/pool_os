import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/product/modules/product_module_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('module configuration defensively copies static metadata', () {
    final capabilities = [_capability('match')];
    final dependencies = [_dependency()];
    final versions = [_version('v1')];
    final configuration = ProductModuleConfiguration(
      identity: _id('product.module.configuration', 'match'),
      version: versions.single,
      capabilities: capabilities,
      dependencies: dependencies,
    );
    final compatibility = ProductModuleCompatibility(
      requiredVersion: versions.single,
      supportedVersions: versions,
    );

    capabilities.clear();
    dependencies.clear();
    versions.add(_version('v2'));

    expect(configuration.capabilities, [_capability('match')]);
    expect(configuration.dependencies, [_dependency()]);
    expect(compatibility.supportedVersions, [_version('v1')]);
    expect(() => configuration.capabilities.clear(), throwsUnsupportedError);
    expect(() => configuration.dependencies.clear(), throwsUnsupportedError);
  });

  test('module contract remains an interface-only boundary', () {
    ProductModuleContract? contract;

    _acceptContract(contract);

    expect(contract, isNull);
  });
}

void _acceptContract(ProductModuleContract? contract) {}

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);

ProductModuleIdentity _module(String value) =>
    ProductModuleIdentity(_id('product.module.identity', value));

ProductModuleCapability _capability(String value) =>
    ProductModuleCapability(_id('product.module.capability', value));

ProductModuleDependency _dependency() => ProductModuleDependency(
      source: _module('training'),
      target: _module('knowledge'),
    );

ProductModuleVersion _version(String value) =>
    ProductModuleVersion(_id('product.module.version', value));
