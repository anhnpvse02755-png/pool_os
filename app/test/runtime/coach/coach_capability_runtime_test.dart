import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/capabilities/coach/coach_capability_contracts.dart';
import 'package:pool_os/runtime/coach/coach_capability_runtime.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('registers, verifies, and exposes Coach metadata only', () {
    final dependency = _Fixture(_metadata('foundation'));
    final target = _Fixture(_metadata('coach'));
    final runtime = const CoachCapabilityBootstrap().initialize(
      registry: CoachCapabilityRegistry([dependency, target]),
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
    final target = _Fixture(_metadata('coach'));
    final capabilities = <CoachCapabilityContract>[target];
    final registry = CoachCapabilityRegistry(capabilities);
    final runtime = const CoachCapabilityBootstrap().initialize(
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
    final target = _Fixture(_metadata('coach'));
    expect(
        () => CoachCapabilityRegistry([target, target]), throwsArgumentError);
    expect(
      () => const CoachCapabilityBootstrap().initialize(
        registry: CoachCapabilityRegistry([target]),
        identity: target.metadata.identity,
        compatibility: _compatibility(),
        dependencies: [_identity('missing')],
      ),
      throwsArgumentError,
    );
  });

  test('fails closed for incompatible Coach version', () {
    final target = _Fixture(_metadata('coach', version: 'v2'));
    expect(
      () => const CoachCapabilityBootstrap().initialize(
        registry: CoachCapabilityRegistry([target]),
        identity: target.metadata.identity,
        compatibility: _compatibility(),
      ),
      throwsArgumentError,
    );
  });
}

final class _Fixture implements CoachCapabilityContract {
  const _Fixture(this.metadata);

  @override
  final CoachCapabilityMetadata metadata;
}

CoachCapabilityMetadata _metadata(String value, {String version = 'v1'}) =>
    CoachCapabilityMetadata(
      identity: _identity(value),
      version: _version(version),
      kinds: const [CoachCapabilityKind.sessionLifecycle],
    );

CoachCapabilityCompatibility _compatibility() =>
    CoachCapabilityCompatibility(requiredVersion: _version('v1'));

CoachCapabilityIdentity _identity(String value) => CoachCapabilityIdentity(
      _id('product.coach-capability.identity', value),
    );

CoachCapabilityVersion _version(String value) => CoachCapabilityVersion(
      _id('product.coach-capability.version', value),
    );

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);
