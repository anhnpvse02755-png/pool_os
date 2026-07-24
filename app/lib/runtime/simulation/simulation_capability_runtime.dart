import '../../capabilities/simulation/simulation_capability_contracts.dart';
import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/value_object.dart';

final class SimulationCapabilityRegistry {
  SimulationCapabilityRegistry(
    Iterable<SimulationCapabilityContract> capabilities,
  ) : capabilities = immutableList(capabilities) {
    final identities = <SimulationCapabilityIdentity>{};
    for (final capability in this.capabilities) {
      if (!identities.add(capability.metadata.identity)) {
        throw ArgumentError.value(
          capability.metadata.identity,
          'capabilities',
          'Simulation capability identities must be unique',
        );
      }
    }
  }

  final List<SimulationCapabilityContract> capabilities;

  SimulationCapabilityContract require(SimulationCapabilityIdentity identity) {
    for (final capability in capabilities) {
      if (capability.metadata.identity == identity) return capability;
    }
    throw ArgumentError.value(
      identity,
      'identity',
      'Simulation capability is not registered',
    );
  }
}

final class SimulationCapabilityDiagnostics extends ValueObject {
  SimulationCapabilityDiagnostics({
    Iterable<RuntimeIdentifier> checks = const [],
  }) : checks = immutableList(checks);

  final List<RuntimeIdentifier> checks;

  @override
  List<Object?> get components => [checks.length, ...checks];
}

final class SimulationCapabilityRuntime {
  SimulationCapabilityRuntime({
    required this.capability,
    Iterable<SimulationCapabilityIdentity> dependencies = const [],
    required this.diagnostics,
  }) : dependencies = immutableList(dependencies);

  final SimulationCapabilityContract capability;
  final List<SimulationCapabilityIdentity> dependencies;
  final SimulationCapabilityDiagnostics diagnostics;
}

final class SimulationCapabilityBootstrap {
  const SimulationCapabilityBootstrap();

  SimulationCapabilityRuntime initialize({
    required SimulationCapabilityRegistry registry,
    required SimulationCapabilityIdentity identity,
    required SimulationCapabilityCompatibility compatibility,
    Iterable<SimulationCapabilityIdentity> dependencies = const [],
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
        'Simulation capability version is not compatible with the runtime',
      );
    }
    final dependencyList = immutableList(dependencies);
    if (dependencyList.toSet().length != dependencyList.length) {
      throw ArgumentError.value(
        dependencyList,
        'dependencies',
        'Simulation capability dependencies must be unique',
      );
    }
    for (final dependency in dependencyList) {
      registry.require(dependency);
    }
    return SimulationCapabilityRuntime(
      capability: capability,
      dependencies: dependencyList,
      diagnostics: SimulationCapabilityDiagnostics(
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
      namespace: 'product.simulation-runtime.check',
      value: value,
    );
