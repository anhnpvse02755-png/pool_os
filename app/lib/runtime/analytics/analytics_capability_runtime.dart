import '../../capabilities/analytics/analytics_capability_contracts.dart';
import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/value_object.dart';

final class AnalyticsCapabilityRegistry {
  AnalyticsCapabilityRegistry(
    Iterable<AnalyticsCapabilityContract> capabilities,
  ) : capabilities = immutableList(capabilities) {
    final identities = <AnalyticsCapabilityIdentity>{};
    for (final capability in this.capabilities) {
      if (!identities.add(capability.metadata.identity)) {
        throw ArgumentError.value(
          capability.metadata.identity,
          'capabilities',
          'Analytics capability identities must be unique',
        );
      }
    }
  }

  final List<AnalyticsCapabilityContract> capabilities;

  AnalyticsCapabilityContract require(AnalyticsCapabilityIdentity identity) {
    for (final capability in capabilities) {
      if (capability.metadata.identity == identity) return capability;
    }
    throw ArgumentError.value(
      identity,
      'identity',
      'Analytics capability is not registered',
    );
  }
}

final class AnalyticsCapabilityDiagnostics extends ValueObject {
  AnalyticsCapabilityDiagnostics({
    Iterable<RuntimeIdentifier> checks = const [],
  }) : checks = immutableList(checks);

  final List<RuntimeIdentifier> checks;

  @override
  List<Object?> get components => [checks.length, ...checks];
}

final class AnalyticsCapabilityRuntime {
  AnalyticsCapabilityRuntime({
    required this.capability,
    Iterable<AnalyticsCapabilityIdentity> dependencies = const [],
    required this.diagnostics,
  }) : dependencies = immutableList(dependencies);

  final AnalyticsCapabilityContract capability;
  final List<AnalyticsCapabilityIdentity> dependencies;
  final AnalyticsCapabilityDiagnostics diagnostics;
}

final class AnalyticsCapabilityBootstrap {
  const AnalyticsCapabilityBootstrap();

  AnalyticsCapabilityRuntime initialize({
    required AnalyticsCapabilityRegistry registry,
    required AnalyticsCapabilityIdentity identity,
    required AnalyticsCapabilityCompatibility compatibility,
    Iterable<AnalyticsCapabilityIdentity> dependencies = const [],
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
        'Analytics capability version is not compatible with the runtime',
      );
    }
    final dependencyList = immutableList(dependencies);
    if (dependencyList.toSet().length != dependencyList.length) {
      throw ArgumentError.value(
        dependencyList,
        'dependencies',
        'Analytics capability dependencies must be unique',
      );
    }
    for (final dependency in dependencyList) {
      registry.require(dependency);
    }
    return AnalyticsCapabilityRuntime(
      capability: capability,
      dependencies: dependencyList,
      diagnostics: AnalyticsCapabilityDiagnostics(
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
      namespace: 'product.analytics-runtime.check',
      value: value,
    );
