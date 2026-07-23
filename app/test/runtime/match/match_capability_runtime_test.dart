import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/capabilities/match/match_capability_contracts.dart';
import 'package:pool_os/runtime/match/match_capability_runtime.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('registers, verifies, and exposes Match capability metadata only', () {
    final dependency = _CapabilityFixture(_metadata('foundation'));
    final target = _CapabilityFixture(_metadata('match'));
    final runtime = const MatchCapabilityBootstrap().initialize(
      registry: MatchCapabilityRegistry([dependency, target]),
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
    final target = _CapabilityFixture(_metadata('match'));
    final capabilities = <MatchCapabilityContract>[target];
    final dependencies = <MatchCapabilityIdentity>[];
    final registry = MatchCapabilityRegistry(capabilities);
    final runtime = const MatchCapabilityBootstrap().initialize(
      registry: registry,
      identity: target.metadata.identity,
      compatibility: _compatibility(),
      dependencies: dependencies,
    );

    capabilities.clear();
    dependencies.add(_identity('other'));

    expect(registry.capabilities, [target]);
    expect(runtime.dependencies, isEmpty);
    expect(() => registry.capabilities.clear(), throwsUnsupportedError);
    expect(() => runtime.dependencies.clear(), throwsUnsupportedError);
    expect(() => runtime.diagnostics.checks.clear(), throwsUnsupportedError);
  });

  test('fails closed for duplicate registration or missing dependency', () {
    final target = _CapabilityFixture(_metadata('match'));

    expect(
      () => MatchCapabilityRegistry([target, target]),
      throwsArgumentError,
    );
    expect(
      () => const MatchCapabilityBootstrap().initialize(
        registry: MatchCapabilityRegistry([target]),
        identity: target.metadata.identity,
        compatibility: _compatibility(),
        dependencies: [_identity('missing')],
      ),
      throwsArgumentError,
    );
  });

  test('fails closed for incompatible Match capability version', () {
    final target = _CapabilityFixture(_metadata('match', version: 'v2'));

    expect(
      () => const MatchCapabilityBootstrap().initialize(
        registry: MatchCapabilityRegistry([target]),
        identity: target.metadata.identity,
        compatibility: _compatibility(),
      ),
      throwsArgumentError,
    );
  });
}

final class _CapabilityFixture implements MatchCapabilityContract {
  const _CapabilityFixture(this.metadata);

  @override
  final MatchCapabilityMetadata metadata;
}

MatchCapabilityMetadata _metadata(String value, {String version = 'v1'}) =>
    MatchCapabilityMetadata(
      identity: _identity(value),
      version: _version(version),
      kinds: const [MatchCapabilityKind.lifecycle],
    );

MatchCapabilityCompatibility _compatibility() => MatchCapabilityCompatibility(
      requiredVersion: _version('v1'),
    );

MatchCapabilityIdentity _identity(String value) => MatchCapabilityIdentity(
      _id('product.match-capability.identity', value),
    );

MatchCapabilityVersion _version(String value) => MatchCapabilityVersion(
      _id('product.match-capability.version', value),
    );

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);
