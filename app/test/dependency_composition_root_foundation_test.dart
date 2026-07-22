import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/application_bootstrap_contracts.dart';
import 'package:pool_os/contracts/dependency_composition_root_contracts.dart';
import 'package:pool_os/contracts/runtime_activation_coordination_contracts.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_delivery_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_dependency_resolution_contracts.dart';
import 'package:pool_os/contracts/runtime_service_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_service_exposure_contracts.dart';
import 'package:pool_os/contracts/runtime_service_registry_contracts.dart';
import 'package:pool_os/contracts/runtime_validation_contracts.dart';

void main() {
  final fixture = _fixture('primary');

  test('composition root projection is immutable and deterministic', () {
    final first = fixture.build();
    final second = fixture.build();
    expect(second.toJson(), first.toJson());
    expect(first.entries, hasLength(4));
    expect(
      () => first.entries.add(first.entries.first),
      throwsUnsupportedError,
    );
  });

  test('binds bootstrap entries to runtime services by public service id', () {
    final root = fixture.build();
    expect(root.bootstrapDigest, fixture.bootstrap.digest);
    expect(
      root.runtimeServiceCompositionDigest,
      fixture.serviceComposition.digest,
    );
    for (var index = 0; index < root.entries.length; index++) {
      expect(root.entries[index].serviceId,
          fixture.bootstrap.entries[index].serviceId);
      expect(
        root.entries[index].bootstrapEntryId,
        fixture.bootstrap.entries[index].bootstrapEntryId,
      );
      expect(
        root.entries[index].runtimeNodeId,
        fixture.bootstrap.entries[index].runtimeNodeId,
      );
    }
  });

  test('canonical entry order is independent of supplied order', () {
    final root = DependencyCompositionRootContract.create(
      bootstrap: fixture.bootstrap,
      runtimeServiceComposition: fixture.serviceComposition,
      entries: fixture.build().entries.reversed.toList(),
    );
    expect(root.toJson(), fixture.build().toJson());
  });

  test('rejects stale bootstrap and service composition provenance', () {
    final foreign = _fixture('foreign');
    expect(
      () => const DependencyCompositionRootBuilder().build(
        bootstrap: fixture.bootstrap,
        runtimeServiceComposition: foreign.serviceComposition,
      ),
      throwsArgumentError,
    );
  });

  test('rejects orphan and duplicate service bindings', () {
    final source = fixture.build().entries.first;
    final orphan = DependencyCompositionEntry(
      compositionEntryId: source.compositionEntryId,
      serviceId: 'orphan-service',
      runtimeNodeId: source.runtimeNodeId,
      bootstrapEntryId: source.bootstrapEntryId,
      position: source.position,
      bootstrapDigest: source.bootstrapDigest,
      runtimeServiceCompositionDigest: source.runtimeServiceCompositionDigest,
    );
    expect(
      () => DependencyCompositionRootContract.create(
        bootstrap: fixture.bootstrap,
        runtimeServiceComposition: fixture.serviceComposition,
        entries: [orphan, ...fixture.build().entries.skip(1)],
      ),
      throwsArgumentError,
    );
    expect(
      () => DependencyCompositionRootContract.create(
        bootstrap: fixture.bootstrap,
        runtimeServiceComposition: fixture.serviceComposition,
        entries: [source, source, ...fixture.build().entries.skip(2)],
      ),
      throwsArgumentError,
    );
  });

  test('does not mutate bootstrap or service composition', () {
    final bootstrap = fixture.bootstrap.toJson();
    final services = fixture.serviceComposition.toJson();
    fixture.build();
    expect(fixture.bootstrap.toJson(), bootstrap);
    expect(fixture.serviceComposition.toJson(), services);
  });
}

class _Fixture {
  const _Fixture({required this.bootstrap, required this.serviceComposition});

  final ApplicationBootstrapContract bootstrap;
  final RuntimeServiceCompositionContract serviceComposition;

  DependencyCompositionRootContract build() =>
      const DependencyCompositionRootBuilder().build(
        bootstrap: bootstrap,
        runtimeServiceComposition: serviceComposition,
      );
}

_Fixture _fixture(String suffix) {
  final composition = const RuntimeCompositionEngine().compose(
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
  return _Fixture(
    bootstrap: bootstrap,
    serviceComposition: serviceComposition,
  );
}
