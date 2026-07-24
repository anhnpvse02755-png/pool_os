import '../../capabilities/knowledge/knowledge_capability_contracts.dart';
import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/value_object.dart';

final class KnowledgeCapabilityRegistry {
  KnowledgeCapabilityRegistry(
    Iterable<KnowledgeCapabilityContract> capabilities,
  ) : capabilities = immutableList(capabilities) {
    final identities = <KnowledgeCapabilityIdentity>{};
    for (final capability in this.capabilities) {
      if (!identities.add(capability.metadata.identity)) {
        throw ArgumentError.value(
          capability.metadata.identity,
          'capabilities',
          'Knowledge capability identities must be unique',
        );
      }
    }
  }

  final List<KnowledgeCapabilityContract> capabilities;

  KnowledgeCapabilityContract require(KnowledgeCapabilityIdentity identity) {
    for (final capability in capabilities) {
      if (capability.metadata.identity == identity) return capability;
    }
    throw ArgumentError.value(
      identity,
      'identity',
      'Knowledge capability is not registered',
    );
  }
}

final class KnowledgeCapabilityDiagnostics extends ValueObject {
  KnowledgeCapabilityDiagnostics({
    Iterable<RuntimeIdentifier> checks = const [],
  }) : checks = immutableList(checks);

  final List<RuntimeIdentifier> checks;

  @override
  List<Object?> get components => [checks.length, ...checks];
}

final class KnowledgeCapabilityRuntime {
  KnowledgeCapabilityRuntime({
    required this.capability,
    Iterable<KnowledgeCapabilityIdentity> dependencies = const [],
    required this.diagnostics,
  }) : dependencies = immutableList(dependencies);

  final KnowledgeCapabilityContract capability;
  final List<KnowledgeCapabilityIdentity> dependencies;
  final KnowledgeCapabilityDiagnostics diagnostics;
}

final class KnowledgeCapabilityBootstrap {
  const KnowledgeCapabilityBootstrap();

  KnowledgeCapabilityRuntime initialize({
    required KnowledgeCapabilityRegistry registry,
    required KnowledgeCapabilityIdentity identity,
    required KnowledgeCapabilityCompatibility compatibility,
    Iterable<KnowledgeCapabilityIdentity> dependencies = const [],
  }) {
    final capability = registry.require(identity);
    final supportedVersions = {
      compatibility.requiredVersion,
      ...compatibility.supportedVersions,
    };
    if (!supportedVersions.contains(capability.metadata.version)) {
      throw ArgumentError.value(
        capability.metadata.version,
        'capability.metadata.version',
        'Knowledge capability version is not compatible with the runtime',
      );
    }
    final dependencyList = immutableList(dependencies);
    if (dependencyList.toSet().length != dependencyList.length) {
      throw ArgumentError.value(
        dependencyList,
        'dependencies',
        'Knowledge capability dependencies must be unique',
      );
    }
    for (final dependency in dependencyList) {
      registry.require(dependency);
    }
    return KnowledgeCapabilityRuntime(
      capability: capability,
      dependencies: dependencyList,
      diagnostics: KnowledgeCapabilityDiagnostics(
        checks: [
          _check('registered'),
          _check('version-compatible'),
          _check('dependencies-available'),
          _check('exposed'),
        ],
      ),
    );
  }
}

RuntimeIdentifier _check(String value) => RuntimeIdentifier(
      namespace: 'product.knowledge-runtime.check',
      value: value,
    );
