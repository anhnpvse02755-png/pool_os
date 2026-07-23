import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/capabilities/training/training_capability_contracts.dart';
import 'package:pool_os/runtime/training/training_capability_runtime.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('registers, verifies, and exposes Training metadata only', () {
    final dependency = _Fixture(_metadata('foundation'));
    final target = _Fixture(_metadata('training'));
    final runtime = const TrainingCapabilityBootstrap().initialize(
      registry: TrainingCapabilityRegistry([dependency, target]),
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
    final target = _Fixture(_metadata('training'));
    final capabilities = <TrainingCapabilityContract>[target];
    final registry = TrainingCapabilityRegistry(capabilities);
    final runtime = const TrainingCapabilityBootstrap().initialize(
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
    final target = _Fixture(_metadata('training'));
    expect(
      () => TrainingCapabilityRegistry([target, target]),
      throwsArgumentError,
    );
    expect(
      () => const TrainingCapabilityBootstrap().initialize(
        registry: TrainingCapabilityRegistry([target]),
        identity: target.metadata.identity,
        compatibility: _compatibility(),
        dependencies: [_identity('missing')],
      ),
      throwsArgumentError,
    );
  });

  test('fails closed for incompatible Training version', () {
    final target = _Fixture(_metadata('training', version: 'v2'));
    expect(
      () => const TrainingCapabilityBootstrap().initialize(
        registry: TrainingCapabilityRegistry([target]),
        identity: target.metadata.identity,
        compatibility: _compatibility(),
      ),
      throwsArgumentError,
    );
  });
}

final class _Fixture implements TrainingCapabilityContract {
  const _Fixture(this.metadata);

  @override
  final TrainingCapabilityMetadata metadata;
}

TrainingCapabilityMetadata _metadata(String value, {String version = 'v1'}) =>
    TrainingCapabilityMetadata(
      identity: _identity(value),
      version: _version(version),
      kinds: const [TrainingCapabilityKind.lifecycle],
    );

TrainingCapabilityCompatibility _compatibility() =>
    TrainingCapabilityCompatibility(requiredVersion: _version('v1'));

TrainingCapabilityIdentity _identity(String value) =>
    TrainingCapabilityIdentity(
      _id('product.training-capability.identity', value),
    );

TrainingCapabilityVersion _version(String value) => TrainingCapabilityVersion(
      _id('product.training-capability.version', value),
    );

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);
