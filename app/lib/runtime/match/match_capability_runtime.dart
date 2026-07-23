import '../../capabilities/match/match_capability_contracts.dart';
import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/value_object.dart';

final class MatchCapabilityRegistry {
  MatchCapabilityRegistry(Iterable<MatchCapabilityContract> capabilities)
      : capabilities = immutableList(capabilities) {
    final identities = <MatchCapabilityIdentity>{};
    for (final capability in this.capabilities) {
      if (!identities.add(capability.metadata.identity)) {
        throw ArgumentError.value(
          capability.metadata.identity,
          'capabilities',
          'Match capability identities must be unique',
        );
      }
    }
  }

  final List<MatchCapabilityContract> capabilities;

  MatchCapabilityContract require(MatchCapabilityIdentity identity) {
    for (final capability in capabilities) {
      if (capability.metadata.identity == identity) {
        return capability;
      }
    }
    throw ArgumentError.value(
      identity,
      'identity',
      'Match capability is not registered',
    );
  }
}

final class MatchCapabilityDiagnostics extends ValueObject {
  MatchCapabilityDiagnostics({
    Iterable<RuntimeIdentifier> checks = const [],
  }) : checks = immutableList(checks);

  final List<RuntimeIdentifier> checks;

  @override
  List<Object?> get components => [checks.length, ...checks];
}

final class MatchCapabilityRuntime {
  MatchCapabilityRuntime({
    required this.capability,
    Iterable<MatchCapabilityIdentity> dependencies = const [],
    required this.diagnostics,
  }) : dependencies = immutableList(dependencies);

  final MatchCapabilityContract capability;
  final List<MatchCapabilityIdentity> dependencies;
  final MatchCapabilityDiagnostics diagnostics;
}

final class MatchCapabilityBootstrap {
  const MatchCapabilityBootstrap();

  MatchCapabilityRuntime initialize({
    required MatchCapabilityRegistry registry,
    required MatchCapabilityIdentity identity,
    required MatchCapabilityCompatibility compatibility,
    Iterable<MatchCapabilityIdentity> dependencies = const [],
  }) {
    final capability = registry.require(identity);
    final metadata = capability.metadata;
    final supportedVersions = {
      compatibility.requiredVersion,
      ...compatibility.supportedVersions,
    };
    if (!supportedVersions.contains(metadata.version)) {
      throw ArgumentError.value(
        metadata.version,
        'capability.metadata.version',
        'Match capability version is not compatible with the runtime',
      );
    }

    final dependencyList = immutableList(dependencies);
    if (dependencyList.toSet().length != dependencyList.length) {
      throw ArgumentError.value(
        dependencyList,
        'dependencies',
        'Match capability dependencies must be unique',
      );
    }
    for (final dependency in dependencyList) {
      registry.require(dependency);
    }

    return MatchCapabilityRuntime(
      capability: capability,
      dependencies: dependencyList,
      diagnostics: MatchCapabilityDiagnostics(
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
      namespace: 'product.match-runtime.check',
      value: value,
    );
