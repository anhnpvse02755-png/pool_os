import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/application_bootstrap_contracts.dart';
import 'package:pool_os/contracts/dependency_composition_root_contracts.dart';
import 'package:pool_os/contracts/runtime_activation_coordination_contracts.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_delivery_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_dependency_resolution_contracts.dart';
import 'package:pool_os/contracts/runtime_service_activation_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_service_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_service_exposure_contracts.dart';
import 'package:pool_os/contracts/runtime_service_registry_contracts.dart';
import 'package:pool_os/contracts/runtime_validation_contracts.dart';

void main() {
  final fixture = _fixture('primary');

  test('activation projection is immutable and deterministic', () {
    final first = fixture.project();
    final second = fixture.project();
    expect(second.toJson(), first.toJson());
    expect(first.entries, hasLength(4));
    expect(
      () => first.entries.add(first.entries.first),
      throwsUnsupportedError,
    );
  });

  test('binds activation to composition references and M8 coordination', () {
    final projection = fixture.project();
    expect(
      projection.dependencyCompositionRootDigest,
      fixture.root.digest,
    );
    expect(
      projection.runtimeActivationCoordinationDigest,
      fixture.activation.digest,
    );
    expect(
      projection.entries.every(
        (entry) =>
            entry.activationProjectionId == projection.activationProjectionId,
      ),
      isTrue,
    );
    for (var index = 0; index < projection.entries.length; index++) {
      expect(
        projection.entries[index].serviceId,
        fixture.activation.entries[index].serviceId,
      );
      expect(
        projection.entries[index].compositionEntryId,
        fixture.root.entries
            .singleWhere((rootEntry) =>
                rootEntry.serviceId == projection.entries[index].serviceId)
            .compositionEntryId,
      );
    }
  });

  test('canonical activation order is independent of supplied order', () {
    final source = fixture.project();
    final projection = RuntimeServiceActivationProjectionContract.create(
      dependencyCompositionRoot: fixture.root,
      runtimeActivationCoordination: fixture.activation,
      entries: source.entries.reversed.toList(),
    );
    expect(projection.toJson(), source.toJson());
  });

  test('rejects stale or foreign activation coordination', () {
    final foreign = _fixture('foreign');
    expect(
      () => const RuntimeServiceActivationProjector().project(
        dependencyCompositionRoot: fixture.root,
        runtimeActivationCoordination: foreign.activation,
      ),
      throwsArgumentError,
    );
  });

  test('rejects orphan activation entries and duplicate positions', () {
    final source = fixture.project().entries.first;
    final orphan = RuntimeServiceActivationEntry(
      activationProjectionId: source.activationProjectionId,
      dependencyCompositionRootDigest: source.dependencyCompositionRootDigest,
      runtimeActivationCoordinationDigest:
          source.runtimeActivationCoordinationDigest,
      activationId: source.activationId,
      serviceId: 'orphan-service',
      runtimeNodeId: source.runtimeNodeId,
      compositionEntryId: source.compositionEntryId,
      activationPosition: source.activationPosition,
    );
    expect(
      () => RuntimeServiceActivationProjectionContract.create(
        dependencyCompositionRoot: fixture.root,
        runtimeActivationCoordination: fixture.activation,
        entries: [orphan, ...fixture.project().entries.skip(1)],
      ),
      throwsArgumentError,
    );
    expect(
      () => RuntimeServiceActivationProjectionContract.create(
        dependencyCompositionRoot: fixture.root,
        runtimeActivationCoordination: fixture.activation,
        entries: [source, source, ...fixture.project().entries.skip(2)],
      ),
      throwsArgumentError,
    );
  });

  test('does not mutate composition root or activation coordination', () {
    final root = fixture.root.toJson();
    final activation = fixture.activation.toJson();
    fixture.project();
    expect(fixture.root.toJson(), root);
    expect(fixture.activation.toJson(), activation);
  });
}

class _Fixture {
  const _Fixture({required this.root, required this.activation});

  final DependencyCompositionRootContract root;
  final RuntimeActivationCoordinationContract activation;

  RuntimeServiceActivationProjectionContract project() =>
      const RuntimeServiceActivationProjector().project(
        dependencyCompositionRoot: root,
        runtimeActivationCoordination: activation,
      );
}

_Fixture _fixture(String suffix) {
  final composition = RuntimeCompositionContract.create(
    nodes: [
      RuntimeNodeContract(
        id: 'a.$suffix',
        kind: RuntimeNodeKind.session,
        sourceContractVersion: 1,
        sourceDigest: 'a.$suffix',
      ),
      RuntimeNodeContract(
        id: 'b.$suffix',
        kind: RuntimeNodeKind.toolInvocation,
        sourceContractVersion: 1,
        sourceDigest: 'b.$suffix',
      ),
      RuntimeNodeContract(
        id: 'c.$suffix',
        kind: RuntimeNodeKind.promptAssembly,
        sourceContractVersion: 1,
        sourceDigest: 'c.$suffix',
      ),
      RuntimeNodeContract(
        id: 'd.$suffix',
        kind: RuntimeNodeKind.providerRequest,
        sourceContractVersion: 1,
        sourceDigest: 'd.$suffix',
      ),
    ],
    edges: [
      RuntimeEdgeContract(fromId: 'a.$suffix', toId: 'b.$suffix'),
      RuntimeEdgeContract(fromId: 'b.$suffix', toId: 'c.$suffix'),
      RuntimeEdgeContract(fromId: 'c.$suffix', toId: 'd.$suffix'),
    ],
  );
  final serviceComposition =
      const RuntimeServiceCompositionEngine().compose(composition);
  final registry =
      const RuntimeServiceRegistryBuilder().build(serviceComposition);
  final dependencies = const RuntimeDependencyResolutionBuilder().build(
    registry: registry,
    runtimeComposition: composition,
  );
  final activation =
      const RuntimeActivationCoordinator().coordinate(dependencies);
  final exposure = const RuntimeServiceExposureProjector().project(
    activationCoordination: activation,
    registry: registry,
  );
  final delivery = const RuntimeDeliveryProjector().project(exposure);
  final validation = const RuntimeValidator().validate(
    artifactDigests: {
      'composition': composition.digest,
      'delivery': delivery.digest,
      'graph': 'g',
      'state': 's',
      'transition': 't',
    },
  );
  final bootstrap = const ApplicationBootstrapBuilder().build(
    runtimeComposition: composition,
    runtimeValidation: validation,
    runtimeDelivery: delivery,
  );
  final root = const DependencyCompositionRootBuilder().build(
    bootstrap: bootstrap,
    runtimeServiceComposition: serviceComposition,
  );
  return _Fixture(root: root, activation: activation);
}
