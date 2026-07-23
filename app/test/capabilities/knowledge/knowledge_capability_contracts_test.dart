import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/capabilities/knowledge/knowledge_capability_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('knowledge capability contracts defensively copy collections', () {
    final kinds = [KnowledgeCapabilityKind.lifecycle];
    final versions = [_version('v1')];
    final metadata = KnowledgeCapabilityMetadata(
      identity: _identity(),
      version: versions.single,
      kinds: kinds,
    );
    final compatibility = KnowledgeCapabilityCompatibility(
      requiredVersion: versions.single,
      supportedVersions: versions,
    );

    kinds.add(KnowledgeCapabilityKind.search);
    versions.add(_version('v2'));

    expect(metadata.kinds, [KnowledgeCapabilityKind.lifecycle]);
    expect(compatibility.supportedVersions, [_version('v1')]);
    expect(() => metadata.kinds.clear(), throwsUnsupportedError);
    expect(
      () => compatibility.supportedVersions.clear(),
      throwsUnsupportedError,
    );
  });

  test('knowledge markers retain compile-time contract boundaries', () {
    KnowledgeCapabilityContract? contract;
    KnowledgeLifecycleCapability? lifecycle;
    KnowledgeSearchCapability? search;
    KnowledgeRetrievalCapability? retrieval;
    KnowledgeClassificationCapability? classification;
    KnowledgeValidationCapability? validation;
    KnowledgeStatisticsCapability? statistics;

    _acceptContract(contract);
    _acceptContract(lifecycle);
    _acceptContract(search);
    _acceptContract(retrieval);
    _acceptContract(classification);
    _acceptContract(validation);
    _acceptContract(statistics);

    expect(
      [
        contract,
        lifecycle,
        search,
        retrieval,
        classification,
        validation,
        statistics,
      ],
      everyElement(isNull),
    );
  });
}

void _acceptContract(KnowledgeCapabilityContract? contract) {}

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);

KnowledgeCapabilityIdentity _identity() => KnowledgeCapabilityIdentity(
      _id('product.knowledge-capability.identity', 'foundation'),
    );

KnowledgeCapabilityVersion _version(String value) => KnowledgeCapabilityVersion(
      _id('product.knowledge-capability.version', value),
    );
