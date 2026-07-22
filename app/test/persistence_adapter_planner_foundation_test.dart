import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/application/application_bootstrap_host.dart';
import 'package:pool_os/application/configuration_adapter_planner.dart';
import 'package:pool_os/application/persistence_adapter_planner.dart';
import 'package:pool_os/application/application_service_wiring_planner.dart';
import 'package:pool_os/application/end_to_end_application_composition_planner.dart';
import 'package:pool_os/application/flutter_application_adapter_planner.dart';
import 'package:pool_os/application/product_feature_assembly_planner.dart';
import 'package:pool_os/application/production_startup_validation_planner.dart';
import 'package:pool_os/application/runtime_host_initializer.dart';
import 'package:pool_os/application/runtime_observability_integration_planner.dart';
import 'package:pool_os/contracts/application_bootstrap_contracts.dart';
import 'package:pool_os/contracts/dependency_composition_root_contracts.dart';
import 'package:pool_os/contracts/product_shell_contracts.dart';
import 'package:pool_os/contracts/production_readiness_validation_contracts.dart';
import 'package:pool_os/contracts/runtime_activation_coordination_contracts.dart';
import 'package:pool_os/contracts/runtime_activation_delivery_gate_contracts.dart';
import 'package:pool_os/contracts/runtime_activation_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_composition_coordination_contracts.dart';
import 'package:pool_os/contracts/runtime_configuration_environment_projection_contracts.dart';
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

  test('persistence adapter is deterministic and replay-safe', () {
    final first = fixture.plan();
    final second = fixture.plan();
    expect(second.toJson(), first.toJson());
    expect(first.digest, hasLength(64));
  });

  test('entries bind exact configuration and delivery provenance', () {
    final plan = fixture.plan();
    expect(
        plan.configurationAdapterPlanId, fixture.configurationAdapterPlan.id);
    expect(
      plan.configurationAdapterPlanDigest,
      fixture.configurationAdapterPlan.digest,
    );
    expect(plan.runtimeDeliveryProjectionId, fixture.deliveryProjection.id);
    expect(
      plan.runtimeDeliveryProjectionDigest,
      fixture.deliveryProjection.digest,
    );
    for (var position = 0; position < plan.entries.length; position++) {
      final entry = plan.entries[position];
      final configurationEntry =
          fixture.configurationAdapterPlan.entries[position];
      expect(entry.featureId, configurationEntry.featureId);
      expect(
        entry.configurationAdapterEntryId,
        configurationEntry.configurationAdapterEntryId,
      );
      expect(entry.position, position);
      expect(
        entry.configurationAdapterPlanDigest,
        fixture.configurationAdapterPlan.digest,
      );
      expect(entry.runtimeDeliveryProjectionDigest,
          fixture.deliveryProjection.digest);
      expect(entry.provenanceDigest, hasLength(64));
    }
  });

  test('canonical order ignores supplied collection order', () {
    final source = fixture.plan();
    final replay = PersistenceAdapterPlan.create(
      configurationAdapterPlan: fixture.configurationAdapterPlan,
      runtimeDeliveryProjection: fixture.deliveryProjection,
      entries: source.entries.reversed.toList(),
      log: source.log.reversed.toList(),
    );
    expect(replay.toJson(), source.toJson());
  });

  test('entries and exact structural log are immutable', () {
    final plan = fixture.plan();
    expect(() => plan.entries.add(plan.entries.first), throwsUnsupportedError);
    expect(() => plan.log.add(plan.log.first), throwsUnsupportedError);
    expect(
      plan.log.map((entry) => entry.phase),
      PersistenceAdapterLogPhase.values,
    );
  });

  test('stale configuration and delivery bindings fail closed', () {
    final source = fixture.plan();
    final staleConfiguration = PersistenceAdapterEntry.create(
      featureId: source.entries.first.featureId,
      configurationAdapterEntryId:
          source.entries.first.configurationAdapterEntryId,
      position: source.entries.first.position,
      configurationAdapterPlanDigest: 'stale',
      runtimeDeliveryProjectionDigest: fixture.deliveryProjection.digest,
    );
    final staleFlutter = PersistenceAdapterEntry.create(
      featureId: source.entries.first.featureId,
      configurationAdapterEntryId:
          source.entries.first.configurationAdapterEntryId,
      position: source.entries.first.position,
      configurationAdapterPlanDigest: fixture.configurationAdapterPlan.digest,
      runtimeDeliveryProjectionDigest: 'stale',
    );
    for (final stale in [staleConfiguration, staleFlutter]) {
      expect(
        () => PersistenceAdapterPlan.create(
          configurationAdapterPlan: fixture.configurationAdapterPlan,
          runtimeDeliveryProjection: fixture.deliveryProjection,
          entries: [stale, source.entries.last],
          log: source.log,
        ),
        throwsArgumentError,
      );
    }
  });

  test('duplicate, orphan, and incomplete feature coverage fail closed', () {
    final source = fixture.plan();
    expect(
      () => PersistenceAdapterPlan.create(
        configurationAdapterPlan: fixture.configurationAdapterPlan,
        runtimeDeliveryProjection: fixture.deliveryProjection,
        entries: [source.entries.first, source.entries.first],
        log: source.log,
      ),
      throwsArgumentError,
    );
    final orphan = PersistenceAdapterEntry.create(
      featureId: source.entries.first.featureId,
      configurationAdapterEntryId: 'orphan-flutter-adapter',
      position: source.entries.first.position,
      configurationAdapterPlanDigest: fixture.configurationAdapterPlan.digest,
      runtimeDeliveryProjectionDigest: fixture.deliveryProjection.digest,
    );
    expect(
      () => PersistenceAdapterPlan.create(
        configurationAdapterPlan: fixture.configurationAdapterPlan,
        runtimeDeliveryProjection: fixture.deliveryProjection,
        entries: [orphan, source.entries.last],
        log: source.log,
      ),
      throwsArgumentError,
    );
    expect(
      () => PersistenceAdapterPlan.create(
        configurationAdapterPlan: fixture.configurationAdapterPlan,
        runtimeDeliveryProjection: fixture.deliveryProjection,
        entries: [source.entries.first],
        log: source.log,
      ),
      throwsArgumentError,
    );
  });

  test('malformed structural log fails closed', () {
    final source = fixture.plan();
    expect(
      () => PersistenceAdapterPlan.create(
        configurationAdapterPlan: fixture.configurationAdapterPlan,
        runtimeDeliveryProjection: fixture.deliveryProjection,
        entries: source.entries,
        log: List.filled(
          PersistenceAdapterLogPhase.values.length,
          source.log.first,
        ),
      ),
      throwsArgumentError,
    );
  });

  test('output excludes configuration values and inputs remain unchanged', () {
    final configuration = fixture.configurationAdapterPlan.toJson();
    final flutter = fixture.deliveryProjection.toJson();
    final json = fixture.plan().toJson().toString();
    expect(fixture.configurationAdapterPlan.toJson(), configuration);
    expect(fixture.deliveryProjection.toJson(), flutter);
    for (final forbidden in [
      'configurationId',
      'environmentId',
      'runtimeNodeId',
      'serviceId',
      'deliveryTarget',
      'secret',
      'featureFlag',
      'providerState',
      'value',
    ]) {
      expect(json, isNot(contains(forbidden)));
    }
  });
}

class _Fixture {
  const _Fixture({
    required this.configurationAdapterPlan,
    required this.deliveryProjection,
  });

  final ConfigurationAdapterPlan configurationAdapterPlan;
  final RuntimeDeliveryProjectionContract deliveryProjection;

  PersistenceAdapterPlan plan() => const PersistenceAdapterPlanner().plan(
        configurationAdapterPlan: configurationAdapterPlan,
        runtimeDeliveryProjection: deliveryProjection,
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
        kind: RuntimeNodeKind.activation,
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
  final bootstrapHostRun = const ApplicationBootstrapHost().start(
    bootstrap: bootstrap,
    compositionRoot: root,
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
  final configuration =
      const RuntimeConfigurationEnvironmentProjector().project(
    runtimeHealth: health,
    runtimeDelivery: delivery,
  );
  final readiness = const ProductionReadinessProjector().project(
    configuration: configuration,
    runtimeValidation: validation,
  );
  final gate = const RuntimeActivationDeliveryGateProjector().project(
    readiness: readiness,
    runtimeDelivery: delivery,
  );
  final startup = const ProductionStartupValidationPlanner().plan(
    bootstrapHostRun: bootstrapHostRun,
    activationDeliveryGate: gate,
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
  final observability = const RuntimeObservabilityIntegrationPlanner().plan(
    healthProjection: health,
    featureAssemblyPlan: assembly,
  );
  final compositionPlan = const EndToEndApplicationCompositionPlanner().plan(
    startupValidationPlan: startup,
    observabilityIntegrationPlan: observability,
  );
  final flutterPlan = const FlutterApplicationAdapterPlanner().plan(
    applicationCompositionPlan: compositionPlan,
    bootstrapHostRun: bootstrapHostRun,
  );
  final configurationAdapterPlan = const ConfigurationAdapterPlanner().plan(
    configurationProjection: configuration,
    flutterApplicationAdapterPlan: flutterPlan,
  );
  return _Fixture(
    configurationAdapterPlan: configurationAdapterPlan,
    deliveryProjection: delivery,
  );
}
