import '../../capabilities/training/training_capability_contracts.dart';
import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/value_object.dart';

final class TrainingCapabilityRegistry {
  TrainingCapabilityRegistry(Iterable<TrainingCapabilityContract> capabilities)
      : capabilities = immutableList(capabilities) {
    final identities = <TrainingCapabilityIdentity>{};
    for (final capability in this.capabilities) {
      if (!identities.add(capability.metadata.identity)) {
        throw ArgumentError.value(
          capability.metadata.identity,
          'capabilities',
          'Training capability identities must be unique',
        );
      }
    }
  }

  final List<TrainingCapabilityContract> capabilities;

  TrainingCapabilityContract require(TrainingCapabilityIdentity identity) {
    for (final capability in capabilities) {
      if (capability.metadata.identity == identity) return capability;
    }
    throw ArgumentError.value(
      identity,
      'identity',
      'Training capability is not registered',
    );
  }
}

final class TrainingCapabilityDiagnostics extends ValueObject {
  TrainingCapabilityDiagnostics({Iterable<RuntimeIdentifier> checks = const []})
      : checks = immutableList(checks);

  final List<RuntimeIdentifier> checks;

  @override
  List<Object?> get components => [checks.length, ...checks];
}

final class TrainingCapabilityRuntime {
  TrainingCapabilityRuntime({
    required this.capability,
    Iterable<TrainingCapabilityIdentity> dependencies = const [],
    required this.diagnostics,
  }) : dependencies = immutableList(dependencies);

  final TrainingCapabilityContract capability;
  final List<TrainingCapabilityIdentity> dependencies;
  final TrainingCapabilityDiagnostics diagnostics;
}

final class TrainingCapabilityBootstrap {
  const TrainingCapabilityBootstrap();

  TrainingCapabilityRuntime initialize({
    required TrainingCapabilityRegistry registry,
    required TrainingCapabilityIdentity identity,
    required TrainingCapabilityCompatibility compatibility,
    Iterable<TrainingCapabilityIdentity> dependencies = const [],
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
        'Training capability version is not compatible with the runtime',
      );
    }
    final dependencyList = immutableList(dependencies);
    if (dependencyList.toSet().length != dependencyList.length) {
      throw ArgumentError.value(
        dependencyList,
        'dependencies',
        'Training capability dependencies must be unique',
      );
    }
    for (final dependency in dependencyList) {
      registry.require(dependency);
    }
    return TrainingCapabilityRuntime(
      capability: capability,
      dependencies: dependencyList,
      diagnostics: TrainingCapabilityDiagnostics(
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
      namespace: 'product.training-runtime.check',
      value: value,
    );
