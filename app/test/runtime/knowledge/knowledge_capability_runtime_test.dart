import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/capabilities/knowledge/knowledge_capability_contracts.dart';
import 'package:pool_os/runtime/knowledge/knowledge_capability_runtime.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('registers, verifies, and exposes Knowledge metadata only', () {
    final dependency = _Fixture(_metadata('foundation'));
    final target = _Fixture(_metadata('knowledge'));
    final runtime = const KnowledgeCapabilityBootstrap().initialize(
      registry: KnowledgeCapabilityRegistry([dependency, target]),
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
    final target = _Fixture(_metadata('knowledge'));
    final capabilities = <KnowledgeCapabilityContract>[target];
    final registry = KnowledgeCapabilityRegistry(capabilities);
    final runtime = const KnowledgeCapabilityBootstrap().initialize(
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
    final target = _Fixture(_metadata('knowledge'));
    expect(
      () => KnowledgeCapabilityRegistry([target, target]),
      throwsArgumentError,
    );
    expect(
      () => const KnowledgeCapabilityBootstrap().initialize(
        registry: KnowledgeCapabilityRegistry([target]),
        identity: target.metadata.identity,
        compatibility: _compatibility(),
        dependencies: [_identity('missing')],
      ),
      throwsArgumentError,
    );
  });

  test('fails closed for incompatible Knowledge version', () {
    final target = _Fixture(_metadata('knowledge', version: 'v2'));
    expect(
      () => const KnowledgeCapabilityBootstrap().initialize(
        registry: KnowledgeCapabilityRegistry([target]),
        identity: target.metadata.identity,
        compatibility: _compatibility(),
      ),
      throwsArgumentError,
    );
  });
}

final class _Fixture implements KnowledgeCapabilityContract {
  const _Fixture(this.metadata);

  @override
  final KnowledgeCapabilityMetadata metadata;
}

KnowledgeCapabilityMetadata _metadata(String value, {String version = 'v1'}) =>
    KnowledgeCapabilityMetadata(
      identity: _identity(value),
      version: _version(version),
      kinds: const [KnowledgeCapabilityKind.lifecycle],
    );

KnowledgeCapabilityCompatibility _compatibility() =>
    KnowledgeCapabilityCompatibility(requiredVersion: _version('v1'));

KnowledgeCapabilityIdentity _identity(String value) =>
    KnowledgeCapabilityIdentity(
      _id('product.knowledge-capability.identity', value),
    );

KnowledgeCapabilityVersion _version(String value) => KnowledgeCapabilityVersion(
      _id('product.knowledge-capability.version', value),
    );

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);
