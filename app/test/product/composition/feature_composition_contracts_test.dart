import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/product/composition/feature_composition_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('composition configuration defensively copies static metadata', () {
    final capabilities = [_capability('training')];
    final dependencies = [_dependency()];
    final versions = [_version('v1')];
    final configuration = FeatureCompositionConfiguration(
      identity: _id('feature.composition.configuration', 'training'),
      version: versions.single,
      capabilities: capabilities,
      dependencies: dependencies,
    );
    final compatibility = FeatureCompositionCompatibility(
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

  test('composition contract remains an interface-only boundary', () {
    FeatureCompositionContract? contract;

    _acceptContract(contract);

    expect(contract, isNull);
  });
}

void _acceptContract(FeatureCompositionContract? contract) {}

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);

FeatureCompositionIdentity _composition(String value) =>
    FeatureCompositionIdentity(_id('feature.composition.identity', value));

FeatureCompositionCapability _capability(String value) =>
    FeatureCompositionCapability(_id('feature.composition.capability', value));

FeatureCompositionDependency _dependency() => FeatureCompositionDependency(
      source: _composition('training'),
      target: _composition('knowledge'),
    );

FeatureCompositionVersion _version(String value) =>
    FeatureCompositionVersion(_id('feature.composition.version', value));
