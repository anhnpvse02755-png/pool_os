import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/application/application_service_wiring_planner.dart';
import 'package:pool_os/application/product_feature_assembly_planner.dart';
import 'package:pool_os/application/runtime_host_initializer.dart';
import 'package:pool_os/application/runtime_observability_integration_planner.dart';
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
import 'package:pool_os/contracts/runtime_health_diagnostics_projection_contracts.dart';
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

  test('observability integration plan is deterministic and replay-safe', () {
    final first = fixture.plan();
    final second = fixture.plan();
    expect(second.toJson(), first.toJson());
    expect(first.digest, hasLength(64));
  });

  test('every feature binds the complete health projection provenance', () {
    final plan = fixture.plan();
    expect(plan.healthProjectionId, fixture.health.id);
    expect(plan.healthProjectionDigest, fixture.health.digest);
    expect(plan.featureAssemblyPlanId, fixture.assembly.id);
    expect(plan.featureAssemblyPlanDigest, fixture.assembly.digest);
    for (var position = 0; position < plan.entries.length; position++) {
      final entry = plan.entries[position];
      final feature = fixture.assembly.entries[position];
      expect(entry.position, position);
      expect(entry.assemblyEntryId, feature.assemblyEntryId);
      expect(entry.featureId, feature.featureId);
      expect(entry.healthProjectionDigest, fixture.health.digest);
    }
  });

  test('integration never infers feature-runtime service ownership', () {
    final json = fixture.plan().toJson().toString();
    expect(json, isNot(contains('serviceId')));
    expect(json, isNot(contains('runtimeNodeId')));
  });

  test('canonical feature order ignores supplied collection order', () {
    final source = fixture.plan();
    final replay = RuntimeObservabilityIntegrationPlan.create(
      healthProjection: fixture.health,
      featureAssemblyPlan: fixture.assembly,
      entries: source.entries.reversed.toList(),
      log: source.log.reversed.toList(),
    );
    expect(replay.toJson(), source.toJson());
  });

  test('integration entries and structural log are immutable', () {
    final plan = fixture.plan();
    expect(() => plan.entries.add(plan.entries.first), throwsUnsupportedError);
    expect(() => plan.log.add(plan.log.first), throwsUnsupportedError);
    expect(
      plan.log.map((entry) => entry.phase),
      RuntimeObservabilityIntegrationLogPhase.values,
    );
  });

  test('duplicate integration entries fail closed', () {
    final source = fixture.plan();
    expect(
      () => RuntimeObservabilityIntegrationPlan.create(
        healthProjection: fixture.health,
        featureAssemblyPlan: fixture.assembly,
        entries: [source.entries.first, source.entries.first],
        log: source.log,
      ),
      throwsArgumentError,
    );
  });

  test('stale health provenance fails closed', () {
    final source = fixture.plan();
    final stale = RuntimeObservabilityIntegrationEntry.create(
      assemblyEntryId: source.entries.first.assemblyEntryId,
      featureId: source.entries.first.featureId,
      position: source.entries.first.position,
      featureAssemblyPlanDigest: fixture.assembly.digest,
      healthProjectionDigest: 'stale',
    );
    expect(
      () => RuntimeObservabilityIntegrationPlan.create(
        healthProjection: fixture.health,
        featureAssemblyPlan: fixture.assembly,
        entries: [stale, source.entries.last],
        log: source.log,
      ),
      throwsArgumentError,
    );
  });

  test('observability planning does not mutate frozen inputs', () {
    final health = fixture.health.toJson();
    final assembly = fixture.assembly.toJson();
    fixture.plan();
    expect(fixture.health.toJson(), health);
    expect(fixture.assembly.toJson(), assembly);
  });
}

class _Fixture {
  const _Fixture({required this.health, required this.assembly});

  final RuntimeHealthDiagnosticsProjectionContract health;
  final ProductFeatureAssemblyPlan assembly;

  RuntimeObservabilityIntegrationPlan plan() =>
      const RuntimeObservabilityIntegrationPlanner().plan(
        healthProjection: health,
        featureAssemblyPlan: assembly,
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
  final health = const RuntimeHealthDiagnosticsProjector().project(
    runtimeLifecycleHostProjection: host,
    runtimeValidation: validation,
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
  final assembly = const ProductFeatureAssemblyPlanner().plan(
    wiringPlan: wiring,
    productShell: shell,
  );
  return _Fixture(health: health, assembly: assembly);
}
