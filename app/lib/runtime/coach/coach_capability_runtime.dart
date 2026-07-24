import '../../capabilities/coach/coach_capability_contracts.dart';
import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/value_object.dart';

final class CoachCapabilityRegistry {
  CoachCapabilityRegistry(Iterable<CoachCapabilityContract> capabilities)
      : capabilities = immutableList(capabilities) {
    final identities = <CoachCapabilityIdentity>{};
    for (final capability in this.capabilities) {
      if (!identities.add(capability.metadata.identity)) {
        throw ArgumentError.value(
          capability.metadata.identity,
          'capabilities',
          'Coach capability identities must be unique',
        );
      }
    }
  }

  final List<CoachCapabilityContract> capabilities;

  CoachCapabilityContract require(CoachCapabilityIdentity identity) {
    for (final capability in capabilities) {
      if (capability.metadata.identity == identity) return capability;
    }
    throw ArgumentError.value(
      identity,
      'identity',
      'Coach capability is not registered',
    );
  }
}

final class CoachCapabilityDiagnostics extends ValueObject {
  CoachCapabilityDiagnostics({Iterable<RuntimeIdentifier> checks = const []})
      : checks = immutableList(checks);

  final List<RuntimeIdentifier> checks;

  @override
  List<Object?> get components => [checks.length, ...checks];
}

final class CoachCapabilityRuntime {
  CoachCapabilityRuntime({
    required this.capability,
    Iterable<CoachCapabilityIdentity> dependencies = const [],
    required this.diagnostics,
  }) : dependencies = immutableList(dependencies);

  final CoachCapabilityContract capability;
  final List<CoachCapabilityIdentity> dependencies;
  final CoachCapabilityDiagnostics diagnostics;
}

final class CoachCapabilityBootstrap {
  const CoachCapabilityBootstrap();

  CoachCapabilityRuntime initialize({
    required CoachCapabilityRegistry registry,
    required CoachCapabilityIdentity identity,
    required CoachCapabilityCompatibility compatibility,
    Iterable<CoachCapabilityIdentity> dependencies = const [],
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
        'Coach capability version is not compatible with the runtime',
      );
    }
    final dependencyList = immutableList(dependencies);
    if (dependencyList.toSet().length != dependencyList.length) {
      throw ArgumentError.value(
        dependencyList,
        'dependencies',
        'Coach capability dependencies must be unique',
      );
    }
    for (final dependency in dependencyList) {
      registry.require(dependency);
    }
    return CoachCapabilityRuntime(
      capability: capability,
      dependencies: dependencyList,
      diagnostics: CoachCapabilityDiagnostics(
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
      namespace: 'product.coach-runtime.check',
      value: value,
    );
