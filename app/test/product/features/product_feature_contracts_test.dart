import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/product/features/product_feature_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('feature configuration defensively copies static metadata', () {
    final capabilities = [_capability('training')];
    final dependencies = [_dependency()];
    final versions = [_version('v1')];
    final configuration = ProductFeatureConfiguration(
      identity: _id('product.feature.configuration', 'training'),
      version: versions.single,
      capabilities: capabilities,
      dependencies: dependencies,
    );
    final compatibility = ProductFeatureCompatibility(
      requiredVersion: versions.single,
      supportedVersions: versions,
    );

    capabilities.clear();
    dependencies.clear();
    versions.add(_version('v2'));

    expect(configuration.capabilities, [_capability('training')]);
    expect(configuration.dependencies, [_dependency()]);
    expect(compatibility.supportedVersions, [_version('v1')]);
    expect(() => configuration.capabilities.clear(), throwsUnsupportedError);
    expect(() => configuration.dependencies.clear(), throwsUnsupportedError);
  });

  test('feature contract remains an interface-only boundary', () {
    ProductFeatureContract? contract;

    _acceptContract(contract);

    expect(contract, isNull);
  });
}

void _acceptContract(ProductFeatureContract? contract) {}

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);

ProductFeatureIdentity _feature(String value) =>
    ProductFeatureIdentity(_id('product.feature.identity', value));

ProductFeatureCapability _capability(String value) =>
    ProductFeatureCapability(_id('product.feature.capability', value));

ProductFeatureDependency _dependency() => ProductFeatureDependency(
      source: _feature('training'),
      target: _feature('knowledge'),
    );

ProductFeatureVersion _version(String value) =>
    ProductFeatureVersion(_id('product.feature.version', value));
