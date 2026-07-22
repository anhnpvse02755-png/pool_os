import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/application/application_service_wiring_planner.dart';
import 'package:pool_os/application/product_feature_assembly_planner.dart';
import 'package:pool_os/application/runtime_host_initializer.dart';
import 'package:pool_os/contracts/application_bootstrap_contracts.dart';
import 'package:pool_os/contracts/dependency_composition_root_contracts.dart';
import 'package:pool_os/contracts/product_shell_contracts.dart';
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

  test('feature assembly plan is deterministic and replay-safe', () {
    final first = fixture.plan();
    final second = fixture.plan();
    expect(second.toJson(), first.toJson());
    expect(first.digest, hasLength(64));
  });

  test('entries bind shell features to complete wiring provenance', () {
    final plan = fixture.plan();
    expect(plan.wiringPlanId, fixture.wiring.id);
    expect(plan.wiringPlanDigest, fixture.wiring.digest);
    expect(plan.productShellId, fixture.shell.id);
    expect(plan.productShellDigest, fixture.shell.digest);
    for (var position = 0; position < plan.entries.length; position++) {
      final entry = plan.entries[position];
      final node = fixture.shell.nodes[position];
      expect(entry.position, position);
      expect(entry.featureId, node.featureId);
      expect(entry.category, node.category.name);
      expect(entry.visible, node.visible);
      expect(entry.parentFeatureId, node.parentFeatureId);
      expect(entry.wiringPlanDigest, fixture.wiring.digest);
    }
  });

  test('assembly never infers an individual feature-service mapping', () {
    final json = fixture.plan().toJson().toString();
    expect(json, isNot(contains('serviceId')));
    expect(json, isNot(contains('runtimeNodeId')));
  });

  test('canonical feature order ignores supplied collection order', () {
    final source = fixture.plan();
    final replay = ProductFeatureAssemblyPlan.create(
      wiringPlan: fixture.wiring,
      productShell: fixture.shell,
      entries: source.entries.reversed.toList(),
      log: source.log.reversed.toList(),
    );
    expect(replay.toJson(), source.toJson());
  });

  test('assembly entries and structural log are immutable', () {
    final plan = fixture.plan();
    expect(() => plan.entries.add(plan.entries.first), throwsUnsupportedError);
    expect(() => plan.log.add(plan.log.first), throwsUnsupportedError);
    expect(
      plan.log.map((entry) => entry.phase),
      ProductFeatureAssemblyLogPhase.values,
    );
  });

  test('duplicate feature assembly entries fail closed', () {
    final source = fixture.plan();
    expect(
      () => ProductFeatureAssemblyPlan.create(
        wiringPlan: fixture.wiring,
        productShell: fixture.shell,
        entries: [source.entries.first, source.entries.first],
        log: source.log,
      ),
      throwsArgumentError,
    );
  });

  test('stale shell provenance fails closed', () {
    final source = fixture.plan();
    final stale = ProductFeatureAssemblyEntry.create(
      featureId: source.entries.first.featureId,
      shellEntryId: source.entries.first.shellEntryId,
      category: source.entries.first.category,
      visible: source.entries.first.visible,
      parentFeatureId: source.entries.first.parentFeatureId,
      position: source.entries.first.position,
      shellDigest: 'stale',
      wiringPlanDigest: fixture.wiring.digest,
    );
    expect(
      () => ProductFeatureAssemblyPlan.create(
        wiringPlan: fixture.wiring,
        productShell: fixture.shell,
        entries: [stale, source.entries.last],
        log: source.log,
      ),
      throwsArgumentError,
    );
  });

  test('assembly planning does not mutate frozen inputs', () {
    final wiring = fixture.wiring.toJson();
    final shell = fixture.shell.toJson();
    fixture.plan();
    expect(fixture.wiring.toJson(), wiring);
    expect(fixture.shell.toJson(), shell);
  });
}

class _Fixture {
  const _Fixture({required this.wiring, required this.shell});

  final ApplicationServiceWiringPlan wiring;
  final ProductShellContract shell;

  ProductFeatureAssemblyPlan plan() =>
      const ProductFeatureAssemblyPlanner().plan(
        wiringPlan: wiring,
        productShell: shell,
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
  final wiring = const ApplicationServiceWiringPlanner().plan(
    initializationPlan: initialization,
    serviceComposition: services,
  );
  final shell = const ProductShellBuilder().build(
    exposure: exposure,
    delivery: delivery,
    policy: ProductNavigationPolicy.create(
      entries: [
        ProductNavigationPolicyEntry(
          featureId: 'home.$suffix',
          category: ProductNavigationCategory.home,
          position: 0,
          visible: true,
        ),
        ProductNavigationPolicyEntry(
          featureId: 'training.$suffix',
          category: ProductNavigationCategory.training,
          position: 1,
          visible: true,
          parentFeatureId: 'home.$suffix',
        ),
      ],
    ),
  );
  return _Fixture(wiring: wiring, shell: shell);
}
