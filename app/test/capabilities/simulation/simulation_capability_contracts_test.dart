import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/capabilities/simulation/simulation_capability_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('simulation capability contracts defensively copy collections', () {
    final kinds = [SimulationCapabilityKind.lifecycle];
    final versions = [_version('v1')];
    final metadata = SimulationCapabilityMetadata(
      identity: _identity(),
      version: versions.single,
      kinds: kinds,
    );
    final compatibility = SimulationCapabilityCompatibility(
      requiredVersion: versions.single,
      supportedVersions: versions,
    );

    kinds.add(SimulationCapabilityKind.resultCollection);
    versions.add(_version('v2'));

    expect(metadata.kinds, [SimulationCapabilityKind.lifecycle]);
    expect(compatibility.supportedVersions, [_version('v1')]);
    expect(() => metadata.kinds.clear(), throwsUnsupportedError);
    expect(
      () => compatibility.supportedVersions.clear(),
      throwsUnsupportedError,
    );
  });

  test('simulation markers retain compile-time contract boundaries', () {
    SimulationCapabilityContract? contract;
    SimulationLifecycleCapability? lifecycle;
    ScenarioPreparationCapability? preparation;
    SimulationExecutionCapability? execution;
    ResultCollectionCapability? results;
    ScenarioValidationCapability? validation;
    SimulationStatisticsCapability? statistics;

    _acceptContract(contract);
    _acceptContract(lifecycle);
    _acceptContract(preparation);
    _acceptContract(execution);
    _acceptContract(results);
    _acceptContract(validation);
    _acceptContract(statistics);

    expect(
      [
        contract,
        lifecycle,
        preparation,
        execution,
        results,
        validation,
        statistics,
      ],
      everyElement(isNull),
    );
  });
}

void _acceptContract(SimulationCapabilityContract? contract) {}

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);

SimulationCapabilityIdentity _identity() => SimulationCapabilityIdentity(
      _id('product.simulation-capability.identity', 'foundation'),
    );

SimulationCapabilityVersion _version(String value) =>
    SimulationCapabilityVersion(
      _id('product.simulation-capability.version', value),
    );
