import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/capabilities/match/match_capability_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('match capability contracts defensively copy collections', () {
    final kinds = [MatchCapabilityKind.lifecycle];
    final versions = [_version('v1')];
    final metadata = MatchCapabilityMetadata(
      identity: _identity(),
      version: versions.single,
      kinds: kinds,
    );
    final compatibility = MatchCapabilityCompatibility(
      requiredVersion: versions.single,
      supportedVersions: versions,
    );

    kinds.add(MatchCapabilityKind.scoring);
    versions.add(_version('v2'));

    expect(metadata.kinds, [MatchCapabilityKind.lifecycle]);
    expect(compatibility.supportedVersions, [_version('v1')]);
    expect(() => metadata.kinds.clear(), throwsUnsupportedError);
    expect(
      () => compatibility.supportedVersions.clear(),
      throwsUnsupportedError,
    );
  });

  test('match markers retain compile-time contract boundaries', () {
    MatchCapabilityContract? contract;
    MatchLifecycleCapability? lifecycle;
    RackManagementCapability? rack;
    MatchScoringCapability? scoring;
    MatchValidationCapability? validation;
    MatchStatisticsCapability? statistics;

    _acceptContract(contract);
    _acceptContract(lifecycle);
    _acceptContract(rack);
    _acceptContract(scoring);
    _acceptContract(validation);
    _acceptContract(statistics);

    expect(
      [contract, lifecycle, rack, scoring, validation, statistics],
      everyElement(isNull),
    );
  });
}

void _acceptContract(MatchCapabilityContract? contract) {}

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);

MatchCapabilityIdentity _identity() => MatchCapabilityIdentity(
      _id('product.match-capability.identity', 'foundation'),
    );

MatchCapabilityVersion _version(String value) => MatchCapabilityVersion(
      _id('product.match-capability.version', value),
    );
