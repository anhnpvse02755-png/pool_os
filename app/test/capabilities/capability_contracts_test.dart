import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/capabilities/capability_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('capability contracts defensively copy metadata collections', () {
    final kinds = [CapabilityKind.match];
    final versions = [_version('v1')];
    final metadata = CapabilityMetadata(
      identity: _identity(),
      version: versions.single,
      kinds: kinds,
    );
    final compatibility = CapabilityCompatibility(
      requiredVersion: versions.single,
      supportedVersions: versions,
    );

    kinds.add(CapabilityKind.training);
    versions.add(_version('v2'));

    expect(metadata.kinds, [CapabilityKind.match]);
    expect(compatibility.supportedVersions, [_version('v1')]);
    expect(() => metadata.kinds.clear(), throwsUnsupportedError);
    expect(
      () => compatibility.supportedVersions.clear(),
      throwsUnsupportedError,
    );
  });

  test('product capability markers retain contract boundaries', () {
    CapabilityContract? contract;
    MatchCapability? match;
    TrainingCapability? training;
    CoachCapability? coach;
    KnowledgeCapability? knowledge;
    AnalyticsCapability? analytics;
    SimulationCapability? simulation;

    _acceptContract(contract);
    _acceptContract(match);
    _acceptContract(training);
    _acceptContract(coach);
    _acceptContract(knowledge);
    _acceptContract(analytics);
    _acceptContract(simulation);

    expect(
      [contract, match, training, coach, knowledge, analytics, simulation],
      everyElement(isNull),
    );
  });
}

void _acceptContract(CapabilityContract? contract) {}

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);

CapabilityIdentity _identity() =>
    CapabilityIdentity(_id('product.capability.identity', 'foundation'));

CapabilityVersion _version(String value) =>
    CapabilityVersion(_id('product.capability.version', value));
