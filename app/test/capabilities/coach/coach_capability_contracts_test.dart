import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/capabilities/coach/coach_capability_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('coach capability contracts defensively copy collections', () {
    final kinds = [CoachCapabilityKind.sessionLifecycle];
    final versions = [_version('v1')];
    final metadata = CoachCapabilityMetadata(
      identity: _identity(),
      version: versions.single,
      kinds: kinds,
    );
    final compatibility = CoachCapabilityCompatibility(
      requiredVersion: versions.single,
      supportedVersions: versions,
    );

    kinds.add(CoachCapabilityKind.feedbackCollection);
    versions.add(_version('v2'));

    expect(metadata.kinds, [CoachCapabilityKind.sessionLifecycle]);
    expect(compatibility.supportedVersions, [_version('v1')]);
    expect(() => metadata.kinds.clear(), throwsUnsupportedError);
    expect(
      () => compatibility.supportedVersions.clear(),
      throwsUnsupportedError,
    );
  });

  test('coach markers retain compile-time contract boundaries', () {
    CoachCapabilityContract? contract;
    CoachSessionLifecycleCapability? lifecycle;
    AdviceGenerationCapability? advice;
    PerformanceReviewCapability? review;
    RecommendationRequestCapability? recommendation;
    FeedbackCollectionCapability? feedback;
    CoachValidationCapability? validation;

    _acceptContract(contract);
    _acceptContract(lifecycle);
    _acceptContract(advice);
    _acceptContract(review);
    _acceptContract(recommendation);
    _acceptContract(feedback);
    _acceptContract(validation);

    expect(
      [
        contract,
        lifecycle,
        advice,
        review,
        recommendation,
        feedback,
        validation,
      ],
      everyElement(isNull),
    );
  });
}

void _acceptContract(CoachCapabilityContract? contract) {}

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);

CoachCapabilityIdentity _identity() => CoachCapabilityIdentity(
      _id('product.coach-capability.identity', 'foundation'),
    );

CoachCapabilityVersion _version(String value) => CoachCapabilityVersion(
      _id('product.coach-capability.version', value),
    );
