import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/application/application_bootstrap_host.dart';
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

  test('bootstrap host is deterministic and replay-safe', () {
    final first = fixture.start();
    final second = fixture.start();
    expect(second.toJson(), first.toJson());
    expect(first.digest, hasLength(64));
  });

  test('startup phases preserve the fixed deterministic order', () {
    final run = fixture.start();
    expect(
      run.lifecycle.map((entry) => entry.phase),
      ApplicationBootstrapPhase.values,
    );
    expect(
      run.lifecycle.map((entry) => entry.position),
      List.generate(ApplicationBootstrapPhase.values.length, (index) => index),
    );
    expect(
      run.lifecycle.map((entry) => entry.eventCode),
      ApplicationBootstrapPhase.values
          .map((phase) => 'application-bootstrap.${phase.name}'),
    );
  });

  test('configuration binds exact bootstrap and composition provenance', () {
    final configuration = fixture.start().configuration;
    expect(configuration.bootstrapId, fixture.bootstrap.id);
    expect(configuration.bootstrapDigest, fixture.bootstrap.digest);
    expect(configuration.compositionRootId, fixture.compositionRoot.id);
    expect(configuration.compositionRootDigest, fixture.compositionRoot.digest);
    expect(configuration.bindings, hasLength(fixture.bootstrap.entries.length));
    for (var index = 0; index < configuration.bindings.length; index++) {
      expect(
        configuration.bindings[index].bootstrapEntryId,
        fixture.bootstrap.entries[index].bootstrapEntryId,
      );
      expect(
        configuration.bindings[index].compositionEntryId,
        fixture.compositionRoot.entries[index].compositionEntryId,
      );
    }
  });

  test('configuration and lifecycle collections are immutable', () {
    final run = fixture.start();
    expect(
      () => run.configuration.bindings.add(run.configuration.bindings.first),
      throwsUnsupportedError,
    );
    expect(
      () => run.lifecycle.add(run.lifecycle.first),
      throwsUnsupportedError,
    );
  });

  test('mixed bootstrap and composition root fail closed', () {
    final foreign = _fixture('foreign');
    expect(
      () => const ApplicationBootstrapHost().start(
        bootstrap: fixture.bootstrap,
        compositionRoot: foreign.compositionRoot,
      ),
      throwsArgumentError,
    );
  });

  test('bootstrap host does not mutate its frozen inputs', () {
    final bootstrap = fixture.bootstrap.toJson();
    final compositionRoot = fixture.compositionRoot.toJson();
    fixture.start();
    expect(fixture.bootstrap.toJson(), bootstrap);
    expect(fixture.compositionRoot.toJson(), compositionRoot);
  });
}

class _Fixture {
  const _Fixture({required this.bootstrap, required this.compositionRoot});

  final ApplicationBootstrapContract bootstrap;
  final DependencyCompositionRootContract compositionRoot;

  ApplicationBootstrapHostRun start() => const ApplicationBootstrapHost().start(
        bootstrap: bootstrap,
        compositionRoot: compositionRoot,
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
    ],
    edges: [RuntimeEdgeContract(fromId: 'a.$suffix', toId: 'b.$suffix')],
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
  final compositionRoot = const DependencyCompositionRootBuilder().build(
    bootstrap: bootstrap,
    runtimeServiceComposition: serviceComposition,
  );
  return _Fixture(bootstrap: bootstrap, compositionRoot: compositionRoot);
}
