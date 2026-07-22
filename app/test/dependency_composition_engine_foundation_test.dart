import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/application/dependency_composition_engine.dart';
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

  test('registration planning is deterministic and replay-safe', () {
    final first = fixture.plan();
    final second = fixture.plan();
    expect(second.toJson(), first.toJson());
    expect(first.digest, hasLength(64));
  });

  test('registrations bind exact composition and activation provenance', () {
    final plan = fixture.plan();
    expect(plan.compositionRootId, fixture.root.id);
    expect(plan.compositionRootDigest, fixture.root.digest);
    expect(plan.activationProjectionId, fixture.projection.id);
    expect(plan.activationProjectionDigest, fixture.projection.digest);
    for (var position = 0; position < plan.registrations.length; position++) {
      final registration = plan.registrations[position];
      final activation = fixture.projection.entries[position];
      expect(registration.position, position);
      expect(registration.activationId, activation.activationId);
      expect(registration.compositionEntryId, activation.compositionEntryId);
      expect(registration.serviceId, activation.serviceId);
      expect(registration.runtimeNodeId, activation.runtimeNodeId);
    }
  });

  test('canonical registration order is independent of supplied order', () {
    final source = fixture.plan();
    final replay = DependencyRegistrationPlan.create(
      compositionRoot: fixture.root,
      activationProjection: fixture.projection,
      registrations: source.registrations.reversed.toList(),
      log: source.log.reversed.toList(),
    );
    expect(replay.toJson(), source.toJson());
  });

  test('registration and structural log collections are immutable', () {
    final plan = fixture.plan();
    expect(
      () => plan.registrations.add(plan.registrations.first),
      throwsUnsupportedError,
    );
    expect(() => plan.log.add(plan.log.first), throwsUnsupportedError);
    expect(
      plan.log.map((entry) => entry.phase),
      DependencyCompositionLogPhase.values,
    );
  });

  test('mixed composition root and activation projection fail closed', () {
    final foreign = _fixture('foreign');
    expect(
      () => const DependencyCompositionEngine().plan(
        compositionRoot: fixture.root,
        activationProjection: foreign.projection,
      ),
      throwsArgumentError,
    );
  });

  test('duplicate semantic registrations fail closed', () {
    final source = fixture.plan();
    expect(
      () => DependencyRegistrationPlan.create(
        compositionRoot: fixture.root,
        activationProjection: fixture.projection,
        registrations: [
          source.registrations.first,
          source.registrations.first,
        ],
        log: source.log,
      ),
      throwsArgumentError,
    );
  });

  test('composition planning does not mutate frozen inputs', () {
    final root = fixture.root.toJson();
    final projection = fixture.projection.toJson();
    fixture.plan();
    expect(fixture.root.toJson(), root);
    expect(fixture.projection.toJson(), projection);
  });
}

class _Fixture {
  const _Fixture({required this.root, required this.projection});

  final DependencyCompositionRootContract root;
  final RuntimeServiceActivationProjectionContract projection;

  DependencyRegistrationPlan plan() => const DependencyCompositionEngine().plan(
        compositionRoot: root,
        activationProjection: projection,
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
  final root = const DependencyCompositionRootBuilder().build(
    bootstrap: bootstrap,
    runtimeServiceComposition: serviceComposition,
  );
  final projection = const RuntimeServiceActivationProjector().project(
    dependencyCompositionRoot: root,
    runtimeActivationCoordination: activation,
  );
  return _Fixture(root: root, projection: projection);
}
