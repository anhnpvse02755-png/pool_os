import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/capabilities/analytics/analytics_capability_contracts.dart';
import 'package:pool_os/runtime/analytics/analytics_capability_runtime.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('registers, verifies, and exposes Analytics metadata only', () {
    final dependency = _Fixture(_metadata('foundation'));
    final target = _Fixture(_metadata('analytics'));
    final runtime = const AnalyticsCapabilityBootstrap().initialize(
      registry: AnalyticsCapabilityRegistry([dependency, target]),
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
    final target = _Fixture(_metadata('analytics'));
    final capabilities = <AnalyticsCapabilityContract>[target];
    final registry = AnalyticsCapabilityRegistry(capabilities);
    final runtime = const AnalyticsCapabilityBootstrap().initialize(
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
    final target = _Fixture(_metadata('analytics'));
    expect(
      () => AnalyticsCapabilityRegistry([target, target]),
      throwsArgumentError,
    );
    expect(
      () => const AnalyticsCapabilityBootstrap().initialize(
        registry: AnalyticsCapabilityRegistry([target]),
        identity: target.metadata.identity,
        compatibility: _compatibility(),
        dependencies: [_identity('missing')],
      ),
      throwsArgumentError,
    );
  });

  test('fails closed for incompatible Analytics version', () {
    final target = _Fixture(_metadata('analytics', version: 'v2'));
    expect(
      () => const AnalyticsCapabilityBootstrap().initialize(
        registry: AnalyticsCapabilityRegistry([target]),
        identity: target.metadata.identity,
        compatibility: _compatibility(),
      ),
      throwsArgumentError,
    );
  });
}

final class _Fixture implements AnalyticsCapabilityContract {
  const _Fixture(this.metadata);

  @override
  final AnalyticsCapabilityMetadata metadata;
}

AnalyticsCapabilityMetadata _metadata(String value, {String version = 'v1'}) =>
    AnalyticsCapabilityMetadata(
      identity: _identity(value),
      version: _version(version),
      kinds: const [AnalyticsCapabilityKind.lifecycle],
    );

AnalyticsCapabilityCompatibility _compatibility() =>
    AnalyticsCapabilityCompatibility(requiredVersion: _version('v1'));

AnalyticsCapabilityIdentity _identity(String value) =>
    AnalyticsCapabilityIdentity(
      _id('product.analytics-capability.identity', value),
    );

AnalyticsCapabilityVersion _version(String value) => AnalyticsCapabilityVersion(
      _id('product.analytics-capability.version', value),
    );

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);
