import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/application/application_service_wiring_planner.dart';
import 'package:pool_os/application/runtime_host_initializer.dart';
import 'package:pool_os/contracts/application_bootstrap_contracts.dart';
import 'package:pool_os/contracts/dependency_composition_root_contracts.dart';
import 'package:pool_os/contracts/runtime_activation_coordination_contracts.dart';
import 'package:pool_os/contracts/runtime_activation_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_composition_coordination_contracts.dart';
import 'package:pool_os/contracts/runtime_delivery_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_dependency_resolution_contracts.dart';
import 'package:pool_os/contracts/runtime_dispatch_contracts.dart';
import 'package:pool_os/contracts/runtime_lifecycle_host_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_lifecycle_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_pipeline_contracts.dart';
import 'package:pool_os/contracts/runtime_service_activation_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_service_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_service_exposure_contracts.dart';
import 'package:pool_os/contracts/runtime_service_registry_contracts.dart';
import 'package:pool_os/contracts/runtime_validation_contracts.dart';

void main() {
  final fixture = _fixture('primary');

  test('application service wiring plan is deterministic and replay-safe', () {
    final first = fixture.plan();
    final second = fixture.plan();
    expect(second.toJson(), first.toJson());
    expect(first.digest, hasLength(64));
  });

  test('wiring entries bind initialization and service provenance', () {
    final plan = fixture.plan();
    expect(plan.initializationPlanId, fixture.initialization.id);
    expect(plan.initializationPlanDigest, fixture.initialization.digest);
    expect(plan.serviceCompositionId, fixture.services.id);
    expect(plan.serviceCompositionDigest, fixture.services.digest);
    for (var position = 0; position < plan.entries.length; position++) {
      final entry = plan.entries[position];
      final initialization = fixture.initialization.entries[position];
      final service = fixture.services.nodes[position];
      expect(entry.position, position);
      expect(entry.initializationEntryId, initialization.initializationEntryId);
      expect(entry.serviceId, service.serviceId);
      expect(entry.runtimeNodeId, initialization.runtimeNodeId);
      expect(entry.serviceKey, service.serviceKey);
      expect(entry.serviceType, service.type.name);
    }
  });

  test('canonical wiring order ignores supplied collection order', () {
    final source = fixture.plan();
    final replay = ApplicationServiceWiringPlan.create(
      initializationPlan: fixture.initialization,
      serviceComposition: fixture.services,
      entries: source.entries.reversed.toList(),
      log: source.log.reversed.toList(),
    );
    expect(replay.toJson(), source.toJson());
  });

  test('wiring entries and structural log are immutable', () {
    final plan = fixture.plan();
    expect(() => plan.entries.add(plan.entries.first), throwsUnsupportedError);
    expect(() => plan.log.add(plan.log.first), throwsUnsupportedError);
    expect(
      plan.log.map((entry) => entry.phase),
      ApplicationServiceWiringLogPhase.values,
    );
  });

  test('stale or foreign service composition fails closed', () {
    final foreign = _fixture('foreign');
    expect(
      () => const ApplicationServiceWiringPlanner().plan(
        initializationPlan: fixture.initialization,
        serviceComposition: foreign.services,
      ),
      throwsArgumentError,
    );
  });

  test('duplicate wiring entries fail closed', () {
    final source = fixture.plan();
    expect(
      () => ApplicationServiceWiringPlan.create(
        initializationPlan: fixture.initialization,
        serviceComposition: fixture.services,
        entries: [source.entries.first, source.entries.first],
        log: source.log,
      ),
      throwsArgumentError,
    );
  });

  test('wiring planning does not mutate frozen inputs', () {
    final initialization = fixture.initialization.toJson();
    final services = fixture.services.toJson();
    fixture.plan();
    expect(fixture.initialization.toJson(), initialization);
    expect(fixture.services.toJson(), services);
  });
}

class _Fixture {
  const _Fixture({required this.initialization, required this.services});

  final RuntimeHostInitializationPlan initialization;
  final RuntimeServiceCompositionContract services;

  ApplicationServiceWiringPlan plan() =>
      const ApplicationServiceWiringPlanner().plan(
        initializationPlan: initialization,
        serviceComposition: services,
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
  final pipeline = const RuntimePipelineEngine().build(
    composition: composition,
    stages: [
      PipelineStage(id: 'first.$suffix', runtimeNodeId: 'a.$suffix'),
      PipelineStage(id: 'second.$suffix', runtimeNodeId: 'b.$suffix'),
    ],
    transitions: [
      PipelineTransition(
        fromStageId: 'first.$suffix',
        toStageId: 'second.$suffix',
      ),
    ],
  );
  final coordination = const RuntimeCompositionCoordinator().coordinate(
    composition: composition,
    pipeline: pipeline,
    mappings: [
      RuntimeCoordinationMapping(
        runtimeNodeId: 'a.$suffix',
        pipelineStageId: 'first.$suffix',
      ),
      RuntimeCoordinationMapping(
        runtimeNodeId: 'b.$suffix',
        pipelineStageId: 'second.$suffix',
      ),
    ],
  );
  final dispatch = const RuntimeDispatcher().project(coordination);
  final activationProjection =
      const RuntimeActivationProjector().project(dispatch);
  final lifecycle =
      const RuntimeLifecycleProjector().project(activationProjection);
  final services = const RuntimeServiceCompositionEngine().compose(composition);
  final registry = const RuntimeServiceRegistryBuilder().build(services);
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
    runtimeServiceComposition: services,
  );
  final serviceActivation = const RuntimeServiceActivationProjector().project(
    dependencyCompositionRoot: root,
    runtimeActivationCoordination: activation,
  );
  final host = const RuntimeLifecycleHostProjector().project(
    runtimeServiceActivationProjection: serviceActivation,
    runtimeLifecycleProjection: lifecycle,
  );
  final initialization = const RuntimeHostInitializer().plan(
    activationProjection: serviceActivation,
    lifecycleHostProjection: host,
  );
  return _Fixture(initialization: initialization, services: services);
}
