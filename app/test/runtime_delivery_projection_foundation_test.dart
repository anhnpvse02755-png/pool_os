import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/runtime_activation_coordination_contracts.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_delivery_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_dependency_resolution_contracts.dart';
import 'package:pool_os/contracts/runtime_service_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_service_exposure_contracts.dart';
import 'package:pool_os/contracts/runtime_service_registry_contracts.dart';

void main() {
  final runtimeComposition = const RuntimeCompositionEngine().compose(
    nodes: const [
      RuntimeNodeContract(
        id: 'a',
        kind: RuntimeNodeKind.session,
        sourceContractVersion: 1,
        sourceDigest: 'a',
      ),
      RuntimeNodeContract(
        id: 'b',
        kind: RuntimeNodeKind.toolInvocation,
        sourceContractVersion: 1,
        sourceDigest: 'b',
      ),
      RuntimeNodeContract(
        id: 'c',
        kind: RuntimeNodeKind.promptAssembly,
        sourceContractVersion: 1,
        sourceDigest: 'c',
      ),
      RuntimeNodeContract(
        id: 'd',
        kind: RuntimeNodeKind.providerRequest,
        sourceContractVersion: 1,
        sourceDigest: 'd',
      ),
    ],
    edges: const [
      RuntimeEdgeContract(fromId: 'a', toId: 'b'),
      RuntimeEdgeContract(fromId: 'b', toId: 'c'),
      RuntimeEdgeContract(fromId: 'c', toId: 'd'),
    ],
  );
  final serviceComposition = const RuntimeServiceCompositionEngine().compose(
    runtimeComposition,
  );
  final registry =
      const RuntimeServiceRegistryBuilder().build(serviceComposition);
  final dependencies = const RuntimeDependencyResolutionBuilder().build(
    registry: registry,
    runtimeComposition: runtimeComposition,
  );
  final activation =
      const RuntimeActivationCoordinator().coordinate(dependencies);
  final exposure = const RuntimeServiceExposureProjector().project(
    activationCoordination: activation,
    registry: registry,
  );

  test('delivery projection is immutable and deterministic', () {
    final first = const RuntimeDeliveryProjector().project(exposure);
    final second = const RuntimeDeliveryProjector().project(exposure);
    expect(second.toJson(), first.toJson());
    expect(first.entries, hasLength(4));
    expect(
        () => first.entries.add(first.entries.first), throwsUnsupportedError);
  });

  test('v1 policy maps every exposure scope explicitly', () {
    final result = const RuntimeDeliveryProjector().project(exposure);
    expect(result.entries.map((entry) => entry.target), [
      RuntimeDeliveryTarget.runtime,
      RuntimeDeliveryTarget.application,
      RuntimeDeliveryTarget.ai,
      RuntimeDeliveryTarget.api,
    ]);
  });

  test('delivery entries bind exposure provenance', () {
    final result = const RuntimeDeliveryProjector().project(exposure);
    expect(result.exposureId, exposure.id);
    expect(result.exposureDigest, exposure.digest);
    expect(
      result.entries.every((entry) => entry.exposureDigest == exposure.digest),
      isTrue,
    );
  });

  test('duplicate delivery entry or position fails closed', () {
    final result = const RuntimeDeliveryProjector().project(exposure);
    expect(
      () => RuntimeDeliveryProjectionContract.create(
        exposure: exposure,
        entries: [result.entries.first, ...result.entries.take(3)],
      ),
      throwsArgumentError,
    );
  });

  test('orphan delivery entry fails closed', () {
    final result = const RuntimeDeliveryProjector().project(exposure);
    expect(
      () => RuntimeDeliveryProjectionContract.create(
        exposure: exposure,
        entries: result.entries.take(3).toList(),
      ),
      throwsArgumentError,
    );
  });

  test('invalid delivery target or stale exposure fails closed', () {
    final result = const RuntimeDeliveryProjector().project(exposure);
    final first = result.entries.first;
    expect(
      () => RuntimeDeliveryProjectionContract.create(
        exposure: exposure,
        entries: [
          RuntimeDeliveryEntry(
            deliveryId: first.deliveryId,
            exposureId: first.exposureId,
            serviceId: first.serviceId,
            runtimeNodeId: first.runtimeNodeId,
            exposureScope: first.exposureScope,
            target: RuntimeDeliveryTarget.api,
            exposureDigest: 'stale',
            position: first.position,
          ),
          ...result.entries.skip(1),
        ],
      ),
      throwsArgumentError,
    );
  });

  test('projector does not mutate exposure projection', () {
    final before = exposure.toJson();
    const RuntimeDeliveryProjector().project(exposure);
    expect(exposure.toJson(), before);
  });
}
