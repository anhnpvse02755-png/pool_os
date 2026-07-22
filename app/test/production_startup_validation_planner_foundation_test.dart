import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/application/application_bootstrap_host.dart';
import 'package:pool_os/application/production_startup_validation_planner.dart';
import 'package:pool_os/contracts/application_bootstrap_contracts.dart';
import 'package:pool_os/contracts/dependency_composition_root_contracts.dart';
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

  test('startup validation plan is deterministic and replay-safe', () {
    final first = fixture.plan();
    final second = fixture.plan();
    expect(second.toJson(), first.toJson());
    expect(first.digest, hasLength(64));
  });

  test('each lifecycle phase binds the complete aggregate gate', () {
    final plan = fixture.plan();
    expect(plan.bootstrapHostRunId, fixture.hostRun.id);
    expect(plan.bootstrapHostRunDigest, fixture.hostRun.digest);
    expect(plan.activationDeliveryGateId, fixture.gate.id);
    expect(plan.activationDeliveryGateDigest, fixture.gate.digest);
    expect(plan.gateEligibility, ProductionStartupGateEligibility.eligible);
    for (var position = 0; position < plan.entries.length; position++) {
      final entry = plan.entries[position];
      final lifecycle = fixture.hostRun.lifecycle[position];
      expect(entry.position, position);
      expect(entry.lifecyclePhase, lifecycle.phase.name);
      expect(entry.lifecycleEventCode, lifecycle.eventCode);
      expect(entry.lifecycleEntryDigest, lifecycle.digest);
      expect(entry.activationDeliveryGateDigest, fixture.gate.digest);
    }
  });

  test('blocked gate produces aggregate blocked eligibility', () {
    final blocked = _fixture('blocked', blocked: true);
    expect(
      blocked.plan().gateEligibility,
      ProductionStartupGateEligibility.blocked,
    );
    expect(
      blocked.plan().entries.every(
            (entry) =>
                entry.gateEligibility ==
                ProductionStartupGateEligibility.blocked,
          ),
      isTrue,
    );
  });

  test('validation does not infer phase-service ownership', () {
    final json = fixture.plan().toJson().toString();
    expect(json, isNot(contains('serviceId')));
    expect(json, isNot(contains('runtimeNodeId')));
    expect(json, isNot(contains('gateEntryId')));
    expect(json, isNot(contains('deliveryTarget')));
  });

  test('canonical lifecycle order ignores supplied collection order', () {
    final source = fixture.plan();
    final replay = ProductionStartupValidationPlan.create(
      bootstrapHostRun: fixture.hostRun,
      activationDeliveryGate: fixture.gate,
      entries: source.entries.reversed.toList(),
      log: source.log.reversed.toList(),
    );
    expect(replay.toJson(), source.toJson());
  });

  test('validation entries and structural log are immutable', () {
    final plan = fixture.plan();
    expect(() => plan.entries.add(plan.entries.first), throwsUnsupportedError);
    expect(() => plan.log.add(plan.log.first), throwsUnsupportedError);
  });

  test('duplicate lifecycle validation entries fail closed', () {
    final source = fixture.plan();
    expect(
      () => ProductionStartupValidationPlan.create(
        bootstrapHostRun: fixture.hostRun,
        activationDeliveryGate: fixture.gate,
        entries: [
          source.entries.first,
          source.entries.first,
          ...source.entries.skip(2),
        ],
        log: source.log,
      ),
      throwsArgumentError,
    );
  });

  test('startup validation planning does not mutate frozen inputs', () {
    final hostRun = fixture.hostRun.toJson();
    final gate = fixture.gate.toJson();
    fixture.plan();
    expect(fixture.hostRun.toJson(), hostRun);
    expect(fixture.gate.toJson(), gate);
  });
}

class _Fixture {
  const _Fixture({required this.hostRun, required this.gate});

  final ApplicationBootstrapHostRun hostRun;
  final RuntimeActivationDeliveryGateContract gate;

  ProductionStartupValidationPlan plan() =>
      const ProductionStartupValidationPlanner().plan(
        bootstrapHostRun: hostRun,
        activationDeliveryGate: gate,
      );
}

_Fixture _fixture(String suffix, {bool blocked = false}) {
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
  final hostRun = const ApplicationBootstrapHost().start(
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
  final gateValidation = blocked
      ? const RuntimeValidator().validate(
          artifactDigests: {
            'composition': 'c',
            'delivery': 'd',
            'graph': 'g',
            'state': 's',
            'transition': 't',
          },
          expectedDigests: {'graph': 'stale'},
        )
      : validation;
  final readiness = const ProductionReadinessProjector().project(
    configuration: configuration,
    runtimeValidation: gateValidation,
  );
  final gate = const RuntimeActivationDeliveryGateProjector().project(
    readiness: readiness,
    runtimeDelivery: delivery,
  );
  return _Fixture(hostRun: hostRun, gate: gate);
}
