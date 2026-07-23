import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/capabilities/analytics/analytics_capability_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('analytics capability contracts defensively copy collections', () {
    final kinds = [AnalyticsCapabilityKind.lifecycle];
    final versions = [_version('v1')];
    final metadata = AnalyticsCapabilityMetadata(
      identity: _identity(),
      version: versions.single,
      kinds: kinds,
    );
    final compatibility = AnalyticsCapabilityCompatibility(
      requiredVersion: versions.single,
      supportedVersions: versions,
    );

    kinds.add(AnalyticsCapabilityKind.reporting);
    versions.add(_version('v2'));

    expect(metadata.kinds, [AnalyticsCapabilityKind.lifecycle]);
    expect(compatibility.supportedVersions, [_version('v1')]);
    expect(() => metadata.kinds.clear(), throwsUnsupportedError);
    expect(
      () => compatibility.supportedVersions.clear(),
      throwsUnsupportedError,
    );
  });

  test('analytics markers retain compile-time contract boundaries', () {
    AnalyticsCapabilityContract? contract;
    AnalyticsLifecycleCapability? lifecycle;
    StatisticsCollectionCapability? statistics;
    PerformanceAnalysisCapability? performance;
    TrendAnalysisCapability? trend;
    ReportingCapability? reporting;
    AnalyticsValidationCapability? validation;

    _acceptContract(contract);
    _acceptContract(lifecycle);
    _acceptContract(statistics);
    _acceptContract(performance);
    _acceptContract(trend);
    _acceptContract(reporting);
    _acceptContract(validation);

    expect(
      [
        contract,
        lifecycle,
        statistics,
        performance,
        trend,
        reporting,
        validation
      ],
      everyElement(isNull),
    );
  });
}

void _acceptContract(AnalyticsCapabilityContract? contract) {}

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);

AnalyticsCapabilityIdentity _identity() => AnalyticsCapabilityIdentity(
      _id('product.analytics-capability.identity', 'foundation'),
    );

AnalyticsCapabilityVersion _version(String value) => AnalyticsCapabilityVersion(
      _id('product.analytics-capability.version', value),
    );
