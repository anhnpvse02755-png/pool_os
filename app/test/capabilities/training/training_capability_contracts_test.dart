import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/capabilities/training/training_capability_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('training capability contracts defensively copy collections', () {
    final kinds = [TrainingCapabilityKind.lifecycle];
    final versions = [_version('v1')];
    final metadata = TrainingCapabilityMetadata(
      identity: _identity(),
      version: versions.single,
      kinds: kinds,
    );
    final compatibility = TrainingCapabilityCompatibility(
      requiredVersion: versions.single,
      supportedVersions: versions,
    );

    kinds.add(TrainingCapabilityKind.progressTracking);
    versions.add(_version('v2'));

    expect(metadata.kinds, [TrainingCapabilityKind.lifecycle]);
    expect(compatibility.supportedVersions, [_version('v1')]);
    expect(() => metadata.kinds.clear(), throwsUnsupportedError);
    expect(
      () => compatibility.supportedVersions.clear(),
      throwsUnsupportedError,
    );
  });

  test('training markers retain compile-time contract boundaries', () {
    TrainingCapabilityContract? contract;
    TrainingLifecycleCapability? lifecycle;
    ExerciseManagementCapability? exercise;
    SessionPlanningCapability? planning;
    ProgressTrackingCapability? progress;
    TrainingValidationCapability? validation;
    TrainingStatisticsCapability? statistics;

    _acceptContract(contract);
    _acceptContract(lifecycle);
    _acceptContract(exercise);
    _acceptContract(planning);
    _acceptContract(progress);
    _acceptContract(validation);
    _acceptContract(statistics);

    expect(
      [
        contract,
        lifecycle,
        exercise,
        planning,
        progress,
        validation,
        statistics,
      ],
      everyElement(isNull),
    );
  });
}

void _acceptContract(TrainingCapabilityContract? contract) {}

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);

TrainingCapabilityIdentity _identity() => TrainingCapabilityIdentity(
      _id('product.training-capability.identity', 'foundation'),
    );

TrainingCapabilityVersion _version(String value) => TrainingCapabilityVersion(
      _id('product.training-capability.version', value),
    );
