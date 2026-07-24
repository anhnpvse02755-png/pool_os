import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/capabilities/simulation/simulation_capability_contracts.dart';
import 'package:pool_os/runtime/simulation/simulation_capability_runtime.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('registers, verifies, and exposes Simulation metadata only', () {
    final dependency = _Fixture(_metadata('foundation'));
    final target = _Fixture(_metadata('simulation'));
    final runtime = const SimulationCapabilityBootstrap().initialize(
      registry: SimulationCapabilityRegistry([dependency, target]),
      identity: target.metadata.identity,
      compatibility: _compatibility(),
      dependencies: [dependency.metadata.identity],
    );

    expect(runtime.capability, same(target));
    expect(runtime.dependencies, [dependency.metadata.identity]);
    expect(
      runtime.diagnostics.checks.map((check) => check.value),
      ['registered', 'version-compatible', 'dependencies-available', 'exposed'],
    );
  });

  test('registry and runtime collections are immutable', () {
    final target = _Fixture(_metadata('simulation'));
    final capabilities = <SimulationCapabilityContract>[target];
    final registry = SimulationCapabilityRegistry(capabilities);
    final runtime = const SimulationCapabilityBootstrap().initialize(
      registry: registry,
      identity: target.metadata.identity,
      compatibility: _compatibility(),
    );
    capabilities.clear();

    expect(registry.capabilities, [target]);
    expect(() => registry.capabilities.clear(), throwsUnsupportedError);
    expect(() => runtime.dependencies.clear(), throwsUnsupportedError);
    expect(() => runtime.diagnostics.checks.clear(), throwsUnsupportedError);
  });

  test('fails closed for duplicate registration or missing dependency', () {
    final target = _Fixture(_metadata('simulation'));
    expect(
      () => SimulationCapabilityRegistry([target, target]),
      throwsArgumentError,
    );
    expect(
      () => const SimulationCapabilityBootstrap().initialize(
        registry: SimulationCapabilityRegistry([target]),
        identity: target.metadata.identity,
        compatibility: _compatibility(),
        dependencies: [_identity('missing')],
      ),
      throwsArgumentError,
    );
  });

  test('fails closed for incompatible Simulation version', () {
    final target = _Fixture(_metadata('simulation', version: 'v2'));
    expect(
      () => const SimulationCapabilityBootstrap().initialize(
        registry: SimulationCapabilityRegistry([target]),
        identity: target.metadata.identity,
        compatibility: _compatibility(),
      ),
      throwsArgumentError,
    );
  });
}

final class _Fixture implements SimulationCapabilityContract {
  const _Fixture(this.metadata);

  @override
  final SimulationCapabilityMetadata metadata;
}

SimulationCapabilityMetadata _metadata(String value, {String version = 'v1'}) =>
    SimulationCapabilityMetadata(
      identity: _identity(value),
      version: _version(version),
      kinds: const [SimulationCapabilityKind.lifecycle],
    );

SimulationCapabilityCompatibility _compatibility() =>
    SimulationCapabilityCompatibility(requiredVersion: _version('v1'));

SimulationCapabilityIdentity _identity(String value) =>
    SimulationCapabilityIdentity(
      _id('product.simulation-capability.identity', value),
    );

SimulationCapabilityVersion _version(String value) =>
    SimulationCapabilityVersion(
      _id('product.simulation-capability.version', value),
    );

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);
